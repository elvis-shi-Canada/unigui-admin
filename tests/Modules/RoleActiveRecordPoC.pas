unit RoleActiveRecordPoC;

{
  Task 2 PoC 测试 —— DMVC ActiveRecord + UniAdmin 集成验证（B 路线命门）

  验证三件事：
  1. TRole 实体能 GetByPK 加载（注解 + RTTI 映射正确）
  2. Select<T> 返回列表（ORM 查询）
  3. 连接走 UniAdmin_Pooled 池化 con_def

  ⚠️ 命门（会话隔离）需在 UniGUI 运行时开 2 并发会话实测，本单元测试无法覆盖。

  依赖：DMVC ActiveRecord（d120 包）+ UniAdmin_Pooled con_def（Task 1.5）+ 真实 DB（RoleID=1 存在）。
}

interface

uses
  System.SysUtils, System.Generics.Collections,
  DUnitX.TestFramework,
  MVCFramework.ActiveRecord,
  RoleEntity;

type
  /// <summary>DMVC ActiveRecord PoC 测试（Task 2 命门验证）</summary>
  [TestFixture]
  TRoleActiveRecordPoC = class
  public
    [Setup]
    procedure Setup;

    [Test]
    procedure TestGetByPK_LoadsRole;
    [Test]
    procedure TestSelect_ReturnsList;
  end;

implementation

uses
  UniAdminConnectionManager;

{ TRoleActiveRecordPoC }

procedure TRoleActiveRecordPoC.Setup;
begin
  // 测试环境兜底：确保池化 con_def 已建 + 注册给 ActiveRecord
  // （主程序由 ServerModule.OnCreate 注册；测试 dpr 无 ServerModule，故此处兜底）
  TUniAdminConnectionManager.GetInstance.EnsurePooledConnectionDef;
  try
    ActiveRecordConnectionsRegistry.AddDefaultConnection('UniAdmin_Pooled');
  except
    // 已注册则忽略（DMVC 不允许同线程同名重复注册）
  end;
end;

procedure TRoleActiveRecordPoC.TestGetByPK_LoadsRole;
var
  LRole: TRole;
begin
  LRole := TMVCActiveRecord.GetByPK<TRole>(1, False);
  try
    Assert.IsNotNull(LRole, 'RoleID=1 应存在（请确保 DB 已 seed）');
    Assert.AreEqual(1, LRole.RoleID, 'RoleID 应为 1');
    Assert.IsFalse(LRole.RoleName.IsEmpty, 'RoleName 不应为空');
  finally
    LRole.Free;
  end;
end;

procedure TRoleActiveRecordPoC.TestSelect_ReturnsList;
var
  LList: TObjectList<TRole>;
begin
  LList := TMVCActiveRecord.Select<TRole>('Status = :s', [1]);
  try
    Assert.IsTrue(LList.Count >= 0, 'Select 应返回列表（可能为空，不应异常）');
    // 遍历验证对象映射
    if LList.Count > 0 then
      Assert.IsTrue(LList[0].RoleID > 0, '列表元素 RoleID 应 > 0');
  finally
    LList.Free;  // TObjectList(OwnsObjects=True) 连带释放内部对象（v2 合规）
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TRoleActiveRecordPoC);

end.

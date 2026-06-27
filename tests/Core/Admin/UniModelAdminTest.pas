unit UniModelAdminTest;

interface

uses
  System.SysUtils, DUnitX.TestFramework,
  UniModelAdmin.Intf, UniModelAdmin;

type
  /// <summary>
  /// TModelAdminRegistry 单元测试
  /// 参考 UniPluginTest.pas 的 DUnitX 风格
  /// </summary>
  [TestFixture]
  TUniModelAdminTest = class
  private
    FRegistry: IModelAdminRegistry;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    [TestCase('TestRegisterAndFind', '')]
    procedure TestRegisterAndFind;

    [Test]
    [TestCase('TestDuplicateOverwrites', '')]
    procedure TestDuplicateOverwrites;

    [Test]
    [TestCase('TestGetByTableName', '')]
    procedure TestGetByTableName;

    [Test]
    [TestCase('TestFindMissingReturnsFalse', '')]
    procedure TestFindMissingReturnsFalse;

    [Test]
    [TestCase('TestGetAllReturnsAll', '')]
    procedure TestGetAllReturnsAll;
  end;

implementation

procedure TUniModelAdminTest.Setup;
begin
  FRegistry := TModelAdminRegistry.CreateInstance;
  FRegistry.Clear;
end;

procedure TUniModelAdminTest.TearDown;
begin
  if FRegistry <> nil then
    FRegistry.Clear;
  FRegistry := nil;
end;

procedure TUniModelAdminTest.TestRegisterAndFind;
var
  LAdmin: TModelAdmin;
  LFound: TModelAdmin;
begin
  LAdmin := TModelAdmin.Create('user', 'UniAdmin_Users', '用户管理');
  LAdmin.PermissionPrefix := 'user';
  LAdmin.SortOrder := 110;
  FRegistry.Register(LAdmin);

  Assert.AreEqual(1, FRegistry.Count, '注册后计数应为 1');
  Assert.IsTrue(FRegistry.Find('user', LFound), '应能找到已注册的 user');
  Assert.AreEqual('UniAdmin_Users', LFound.TableName, 'TableName 应匹配');
  Assert.AreEqual('用户管理', LFound.DisplayName, 'DisplayName 应匹配');
end;

procedure TUniModelAdminTest.TestDuplicateOverwrites;
var
  LA, LB: TModelAdmin;
  LFound: TModelAdmin;
begin
  LA := TModelAdmin.Create('user', 'UniAdmin_Users', '用户管理');
  FRegistry.Register(LA);
  LB := TModelAdmin.Create('user', 'UniAdmin_Users', '系统用户');
  FRegistry.Register(LB);

  Assert.AreEqual(1, FRegistry.Count, '重复注册应覆盖而非新增');
  FRegistry.Find('user', LFound);
  Assert.AreEqual('系统用户', LFound.DisplayName, '后者应覆盖前者');
end;

procedure TUniModelAdminTest.TestGetByTableName;
var
  LAdmin: TModelAdmin;
  LFound: TModelAdmin;
begin
  LAdmin := TModelAdmin.Create('role', 'UniAdmin_Roles', '角色管理');
  FRegistry.Register(LAdmin);

  LFound := FRegistry.GetByTableName('UniAdmin_Roles');
  Assert.AreEqual('role', LFound.AdminID, '按表名应反查到 AdminID');
end;

procedure TUniModelAdminTest.TestFindMissingReturnsFalse;
var
  LAdmin: TModelAdmin;
begin
  Assert.IsFalse(FRegistry.Find('nonexistent', LAdmin),
    '查不存在的 ID 应返回 False 且不抛异常');
end;

procedure TUniModelAdminTest.TestGetAllReturnsAll;
var
  LA, LB: TModelAdmin;
  LAll: TArray<TModelAdmin>;
begin
  LA := TModelAdmin.Create('user', 'UniAdmin_Users', '用户管理');
  LB := TModelAdmin.Create('role', 'UniAdmin_Roles', '角色管理');
  FRegistry.Register(LA);
  FRegistry.Register(LB);

  LAll := FRegistry.GetAll;
  Assert.AreEqual(2, Length(LAll), 'GetAll 应返回 2 个');
end;

initialization
  TDUnitX.RegisterTestFixture(TUniModelAdminTest);

finalization
  TModelAdminRegistry.CleanupInstance;

end.

unit MenuTest;

interface

uses
  System.SysUtils, System.Types, System.Generics.Collections,
  DUnitX.TestFramework,
  FireDAC.Comp.Client,
  UniContext, UniPlugin.Types,
  MenuDataModule;

type
  /// <summary>
  /// 菜单模块测试类
  /// </summary>
  [TestFixture]
  TMenuTest = class
  private
    FConnection: TFDConnection;
    FContext: IExecutionContext;
    FDataModule: TMenuDataModule;

    procedure SetupDatabase;
    procedure CleanupDatabase;
    function GetTestMenuCode: string;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    // 基础 CRUD 测试
    [Test]
    procedure TestCreateMenu;

    [Test]
    procedure TestGetMenuByID;

    [Test]
    procedure TestGetMenus;

    [Test]
    procedure TestUpdateMenu;

    [Test]
    procedure TestDeleteMenu;

    [Test]
    procedure TestSetMenuStatus;

    [Test]
    procedure TestSetMenuVisible;

    // 树形结构测试
    [Test]
    procedure TestGetMenuTree;

    [Test]
    procedure TestGetChildMenus;

    [Test]
    procedure TestGetMenuPath;

    [Test]
    procedure TestHasChildren;

    [Test]
    procedure TestGetAllChildIDs;

    // 菜单操作测试
    [Test]
    procedure TestMoveMenu;

    [Test]
    procedure TestCopyMenu;

    // 验证测试
    [Test]
    procedure TestMenuCodeExists;

    [Test]
    procedure TestValidateMenuType;

    // 用户/角色权限测试
    [Test]
    procedure TestGetUserMenus;

    [Test]
    procedure TestGetRoleMenus;

    [Test]
    procedure TestBuildMenuTree;

    // 统计测试
    [Test]
    procedure TestGetMenuStats;

    // 边界条件测试
    [Test]
    procedure TestCreateMenuWithDuplicateCode;

    [Test]
    procedure TestCreateMenuWithInvalidType;

    [Test]
    procedure TestCreateMenuWithInvalidParent;

    [Test]
    procedure TestDeleteMenuWithChildren;

    [Test]
    procedure TestMoveMenuToInvalidParent;

    [Test]
    procedure TestCopyMenuWithChildren;
  end;

implementation

{ TMenuTest }

procedure TMenuTest.Setup;
begin
  // 创建数据库连接
  FConnection := TFDConnection.Create(nil);
  FConnection.DriverName := 'MSSQL';
  FConnection.Params.Values['Server'] := '.';
  FConnection.Params.Values['Database'] := 'UniAdminDB';
  FConnection.Params.Values['User_Name'] := 'sa';
  FConnection.Params.Values['Password'] := 'your_password';
  FConnection.Params.Values['LoginTimeout'] := '30';

  try
    FConnection.Connected := True;
  except
    on E: Exception do
      raise Exception.Create('数据库连接失败: ' + E.Message);
  end;

  // 创建模拟上下文
  FContext := TMockExecutionContext.Create;

  // 创建数据模块
  FDataModule := TMenuDataModule.Create(nil);
  if Supports(FDataModule, IContextAware) then
    (FDataModule as IContextAware).SetContext(FContext);

  FDataModule.SetConnection(FConnection);

  // 设置测试数据
  SetupDatabase;
end;

procedure TMenuTest.TearDown;
begin
  CleanupDatabase;

  if Assigned(FDataModule) then
  begin
    FDataModule.Close;
    FreeAndNil(FDataModule);
  end;

  if Assigned(FConnection) then
  begin
    FConnection.Connected := False;
    FreeAndNil(FConnection);
  end;
end;

procedure TMenuTest.SetupDatabase;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;

    // 创建测试菜单表
    LQuery.ExecSQL(
      'IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = ''UniAdmin_Menus'') ' +
      'CREATE TABLE UniAdmin_Menus ( ' +
      '  MenuID INT IDENTITY(1,1) PRIMARY KEY, ' +
      '  MenuCode NVARCHAR(50) NOT NULL UNIQUE, ' +
      '  MenuName NVARCHAR(100) NOT NULL, ' +
      '  ParentID INT DEFAULT 0, ' +
      '  MenuType NVARCHAR(20) DEFAULT ''menu'', ' +
      '  Icon NVARCHAR(100), ' +
      '  Path NVARCHAR(255), ' +
      '  Component NVARCHAR(255), ' +
      '  Permission NVARCHAR(100), ' +
      '  SortOrder INT DEFAULT 0, ' +
      '  Visible INT DEFAULT 1, ' +
      '  Status INT DEFAULT 1, ' +
      '  Description NVARCHAR(500), ' +
      '  CreatedDate DATETIME DEFAULT GETDATE(), ' +
      '  ModifiedDate DATETIME ' +
      ')'
    );

    // 清理测试数据
    LQuery.ExecSQL('DELETE FROM UniAdmin_Menus');
  finally
    LQuery.Free;
  end;
end;

procedure TMenuTest.CleanupDatabase;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.ExecSQL('DELETE FROM UniAdmin_Menus');
  finally
    LQuery.Free;
  end;
end;

function TMenuTest.GetTestMenuCode: string;
begin
  Result := 'TEST_MENU_' + FormatDateTime('yyyymmddhhnnss', Now);
end;

// ========== 基础 CRUD 测试 ==========

procedure TMenuTest.TestCreateMenu;
var
  LMenuID: Integer;
  LMenuCode: string;
begin
  LMenuCode := GetTestMenuCode;

  // 创建根菜单
  LMenuID := FDataModule.CreateMenu(
    LMenuCode,
    '测试菜单',
    0,
    'menu',
    'fa fa-test',
    '/test',
    'TestComponent',
    'test:view',
    10
  );

  Assert.WillNotRaise(
    procedure
    begin
      Assert.IsTrue(LMenuID > 0, '菜单ID应该大于0');
    end
  );
end;

procedure TMenuTest.TestGetMenuByID;
var
  LMenuID: Integer;
  LMenuCode: string;
  LDataSet: TDataSet;
begin
  LMenuCode := GetTestMenuCode;
  LMenuID := FDataModule.CreateMenu(LMenuCode, '测试菜单', 0, 'menu', '', '', '', '', 0);

  LDataSet := FDataModule.GetMenuByID(LMenuID);
  try
    Assert.IsFalse(LDataSet.Eof, '应该找到菜单记录');
    Assert.AreEqual(LMenuCode, LDataSet.FieldByName('MenuCode').AsString);
    Assert.AreEqual('测试菜单', LDataSet.FieldByName('MenuName').AsString);
  finally
    LDataSet.Free;
  end;
end;

procedure TMenuTest.TestGetMenus;
var
  LDataSet: TDataSet;
begin
  FDataModule.CreateMenu(GetTestMenuCode + '_1', '菜单1', 0, 'menu', '', '', '', '', 1);
  FDataModule.CreateMenu(GetTestMenuCode + '_2', '菜单2', 0, 'menu', '', '', '', '', 2);

  LDataSet := FDataModule.GetMenus('', -1);
  try
    Assert.IsTrue(LDataSet.RecordCount >= 2, '应该至少有2条菜单记录');
  finally
    LDataSet.Free;
  end;
end;

procedure TMenuTest.TestUpdateMenu;
var
  LMenuID: Integer;
  LMenuCode: string;
  LDataSet: TDataSet;
begin
  LMenuCode := GetTestMenuCode;
  LMenuID := FDataModule.CreateMenu(LMenuCode, '原始菜单名', 0, 'menu', 'fa-old', '/old', '', '', 0);

  FDataModule.UpdateMenu(LMenuID, '更新后菜单名', 'fa-new', '/new', '', '', -1, -1);

  LDataSet := FDataModule.GetMenuByID(LMenuID);
  try
    Assert.AreEqual('更新后菜单名', LDataSet.FieldByName('MenuName').AsString);
    Assert.AreEqual('fa-new', LDataSet.FieldByName('Icon').AsString);
    Assert.AreEqual('/new', LDataSet.FieldByName('Path').AsString);
  finally
    LDataSet.Free;
  end;
end;

procedure TMenuTest.TestDeleteMenu;
var
  LMenuID: Integer;
  LMenuCode: string;
  LDataSet: TDataSet;
begin
  LMenuCode := GetTestMenuCode;
  LMenuID := FDataModule.CreateMenu(LMenuCode, '待删除菜单', 0, 'menu', '', '', '', '', 0);

  FDataModule.DeleteMenu(LMenuID);

  LDataSet := FDataModule.GetMenuByID(LMenuID);
  try
    Assert.IsTrue(LDataSet.Eof, '菜单应该已被删除');
  finally
    LDataSet.Free;
  end;
end;

procedure TMenuTest.TestSetMenuStatus;
var
  LMenuID: Integer;
  LMenuCode: string;
  LDataSet: TDataSet;
begin
  LMenuCode := GetTestMenuCode;
  LMenuID := FDataModule.CreateMenu(LMenuCode, '测试菜单', 0, 'menu', '', '', '', '', 0);

  FDataModule.SetMenuStatus(LMenuID, 0); // 禁用

  LDataSet := FDataModule.GetMenuByID(LMenuID);
  try
    Assert.AreEqual(0, LDataSet.FieldByName('Status').AsInteger);
  finally
    LDataSet.Free;
  end;
end;

procedure TMenuTest.TestSetMenuVisible;
var
  LMenuID: Integer;
  LMenuCode: string;
  LDataSet: TDataSet;
begin
  LMenuCode := GetTestMenuCode;
  LMenuID := FDataModule.CreateMenu(LMenuCode, '测试菜单', 0, 'menu', '', '', '', '', 0);

  FDataModule.SetMenuVisible(LMenuID, 0); // 隐藏

  LDataSet := FDataModule.GetMenuByID(LMenuID);
  try
    Assert.AreEqual(0, LDataSet.FieldByName('Visible').AsInteger);
  finally
    LDataSet.Free;
  end;
end;

// ========== 树形结构测试 ==========

procedure TMenuTest.TestGetMenuTree;
var
  LParentID: Integer;
  LDataSet: TDataSet;
begin
  // 创建父菜单
  LParentID := FDataModule.CreateMenu(GetTestMenuCode + '_parent', '父菜单', 0, 'directory', '', '', '', '', 0);
  // 创建子菜单
  FDataModule.CreateMenu(GetTestMenuCode + '_child', '子菜单', LParentID, 'menu', '', '', '', '', 0);

  LDataSet := FDataModule.GetMenuTree(True);
  try
    Assert.IsTrue(LDataSet.RecordCount >= 2, '应该至少有2条菜单记录');
  finally
    LDataSet.Free;
  end;
end;

procedure TMenuTest.TestGetChildMenus;
var
  LParentID: Integer;
  LDataSet: TDataSet;
begin
  LParentID := FDataModule.CreateMenu(GetTestMenuCode + '_parent', '父菜单', 0, 'directory', '', '', '', '', 0);
  FDataModule.CreateMenu(GetTestMenuCode + '_child1', '子菜单1', LParentID, 'menu', '', '', '', '', 0);
  FDataModule.CreateMenu(GetTestMenuCode + '_child2', '子菜单2', LParentID, 'menu', '', '', '', '', 0);

  LDataSet := FDataModule.GetChildMenus(LParentID, True);
  try
    Assert.IsTrue(LDataSet.RecordCount >= 2, '应该至少有2条子菜单记录');
  finally
    LDataSet.Free;
  end;
end;

procedure TMenuTest.TestGetMenuPath;
var
  LParentID, LChildID: Integer;
  LPath: string;
begin
  LParentID := FDataModule.CreateMenu(GetTestMenuCode + '_parent', '父菜单', 0, 'directory', '', '', '', '', 0);
  LChildID := FDataModule.CreateMenu(GetTestMenuCode + '_child', '子菜单', LParentID, 'menu', '', '', '', '', 0);

  LPath := FDataModule.GetMenuPath(LChildID);
  Assert.IsTrue(LPath.Contains('父菜单'), '路径应包含父菜单名称');
  Assert.IsTrue(LPath.Contains('子菜单'), '路径应包含子菜单名称');
end;

procedure TMenuTest.TestHasChildren;
var
  LParentID: Integer;
begin
  LParentID := FDataModule.CreateMenu(GetTestMenuCode + '_parent', '父菜单', 0, 'directory', '', '', '', '', 0);

  Assert.IsFalse(FDataModule.HasChildren(LParentID), '初始状态应该没有子菜单');

  FDataModule.CreateMenu(GetTestMenuCode + '_child', '子菜单', LParentID, 'menu', '', '', '', '', 0);
  Assert.IsTrue(FDataModule.HasChildren(LParentID), '添加子菜单后应该返回True');
end;

procedure TMenuTest.TestGetAllChildIDs;
var
  LParentID, LChild1, LChild2: Integer;
  LChildIDs: TArray<Integer>;
begin
  LParentID := FDataModule.CreateMenu(GetTestMenuCode + '_parent', '父菜单', 0, 'directory', '', '', '', '', 0);
  LChild1 := FDataModule.CreateMenu(GetTestMenuCode + '_child1', '子菜单1', LParentID, 'menu', '', '', '', '', 0);
  LChild2 := FDataModule.CreateMenu(GetTestMenuCode + '_child2', '子菜单2', LParentID, 'menu', '', '', '', '', 0);

  LChildIDs := FDataModule.GetAllChildIDs(LParentID);
  Assert.IsTrue(Length(LChildIDs) >= 2, '应该至少有2个子菜单ID');
end;

// ========== 菜单操作测试 ==========

procedure TMenuTest.TestMoveMenu;
var
  LMenuID, LParentID1, LParentID2: Integer;
  LDataSet: TDataSet;
begin
  LParentID1 := FDataModule.CreateMenu(GetTestMenuCode + '_parent1', '父菜单1', 0, 'directory', '', '', '', '', 0);
  LParentID2 := FDataModule.CreateMenu(GetTestMenuCode + '_parent2', '父菜单2', 0, 'directory', '', '', '', '', 0);
  LMenuID := FDataModule.CreateMenu(GetTestMenuCode + '_menu', '移动菜单', LParentID1, 'menu', '', '', '', '', 0);

  FDataModule.MoveMenu(LMenuID, LParentID2, 0);

  LDataSet := FDataModule.GetMenuByID(LMenuID);
  try
    Assert.AreEqual(LParentID2, LDataSet.FieldByName('ParentID').AsInteger, '父节点应该已更新');
  finally
    LDataSet.Free;
  end;
end;

procedure TMenuTest.TestCopyMenu;
var
  LMenuID, LCopyID: Integer;
  LDataSet: TDataSet;
begin
  LMenuID := FDataModule.CreateMenu(GetTestMenuCode + '_original', '原始菜单', 0, 'menu', 'fa-test', '/test', '', '', 0);

  LCopyID := FDataModule.CopyMenu(LMenuID, 0);

  Assert.IsTrue(LCopyID > 0, '复制应该返回新菜单ID');

  LDataSet := FDataModule.GetMenuByID(LCopyID);
  try
    Assert.IsFalse(LDataSet.Eof, '应该找到复制的菜单');
    Assert.IsTrue(LDataSet.FieldByName('MenuCode').AsString.Contains('_copy'), '编码应包含_copy');
  finally
    LDataSet.Free;
  end;
end;

// ========== 验证测试 ==========

procedure TMenuTest.TestMenuCodeExists;
begin
  // 通过 CreateMenu 的异常来验证
  Assert.WillRaise(
    procedure
    var
      LMenuCode: string;
    begin
      LMenuCode := GetTestMenuCode;
      FDataModule.CreateMenu(LMenuCode, '菜单1', 0, 'menu', '', '', '', '', 0);
      FDataModule.CreateMenu(LMenuCode, '菜单2', 0, 'menu', '', '', '', '', 0);
    end,
    Exception,
    '重复编码应该抛出异常'
  );
end;

procedure TMenuTest.TestValidateMenuType;
begin
  // 有效类型
  Assert.WillNotRaise(
    procedure
    begin
      FDataModule.CreateMenu(GetTestMenuCode + '_1', '目录', 0, 'directory', '', '', '', '', 0);
      FDataModule.CreateMenu(GetTestMenuCode + '_2', '菜单', 0, 'menu', '', '', '', '', 0);
      FDataModule.CreateMenu(GetTestMenuCode + '_3', '按钮', 0, 'button', '', '', '', '', 0);
    end
  );
end;

// ========== 边界条件测试 ==========

procedure TMenuTest.TestCreateMenuWithInvalidType;
begin
  Assert.WillRaise(
    procedure
    begin
      FDataModule.CreateMenu(GetTestMenuCode, '测试', 0, 'invalid', '', '', '', '', 0);
    end,
    Exception,
    '无效的菜单类型应该抛出异常'
  );
end;

procedure TMenuTest.TestCreateMenuWithDuplicateCode;
begin
  Assert.WillRaise(
    procedure
    var
      LMenuCode: string;
    begin
      LMenuCode := GetTestMenuCode;
      FDataModule.CreateMenu(LMenuCode, '菜单1', 0, 'menu', '', '', '', '', 0);
      FDataModule.CreateMenu(LMenuCode, '菜单2', 0, 'menu', '', '', '', '', 0);
    end,
    Exception
  );
end;

procedure TMenuTest.TestCreateMenuWithInvalidParent;
begin
  Assert.WillRaise(
    procedure
    begin
      FDataModule.CreateMenu(GetTestMenuCode, '测试', 99999, 'menu', '', '', '', '', 0);
    end,
    Exception,
    '无效的父节点应该抛出异常'
  );
end;

procedure TMenuTest.TestDeleteMenuWithChildren;
begin
  Assert.WillNotRaise(
    procedure
    var
      LParentID: Integer;
    begin
      LParentID := FDataModule.CreateMenu(GetTestMenuCode + '_parent', '父菜单', 0, 'directory', '', '', '', '', 0);
      FDataModule.CreateMenu(GetTestMenuCode + '_child', '子菜单', LParentID, 'menu', '', '', '', '', 0);
      // 应该递归删除父菜单和子菜单
      FDataModule.DeleteMenu(LParentID);
    end
  );
end;

procedure TMenuTest.TestMoveMenuToInvalidParent;
begin
  Assert.WillRaise(
    procedure
    var
      LMenuID: Integer;
    begin
      LMenuID := FDataModule.CreateMenu(GetTestMenuCode, '测试', 0, 'menu', '', '', '', '', 0);
      FDataModule.MoveMenu(LMenuID, 99999, 0);
    end,
    Exception,
    '移动到无效父节点应该抛出异常'
  );
end;

procedure TMenuTest.TestCopyMenuWithChildren;
begin
  Assert.WillNotRaise(
    procedure
    var
      LParentID, LChildID, LCopyID: Integer;
    begin
      LParentID := FDataModule.CreateMenu(GetTestMenuCode + '_parent', '父菜单', 0, 'directory', '', '', '', '', 0);
      LChildID := FDataModule.CreateMenu(GetTestMenuCode + '_child', '子菜单', LParentID, 'menu', '', '', '', '', 0);

      // 复制应该包含子菜单
      LCopyID := FDataModule.CopyMenu(LParentID, 0);

      Assert.IsTrue(FDataModule.HasChildren(LCopyID), '复制的菜单应该包含子菜单');
    end
  );
end;

// ========== 用户/角色权限测试 ==========

procedure TMenuTest.TestGetUserMenus;
var
  LDataSet: TDataSet;
begin
  // 简化测试，只验证方法不抛出异常
  Assert.WillNotRaise(
    procedure
    begin
      LDataSet := FDataModule.GetUserMenus(1);
      LDataSet.Free;
    end
  );
end;

procedure TMenuTest.TestGetRoleMenus;
var
  LDataSet: TDataSet;
begin
  Assert.WillNotRaise(
    procedure
    begin
      LDataSet := FDataModule.GetRoleMenus(1);
      LDataSet.Free;
    end
  );
end;

procedure TMenuTest.TestBuildMenuTree;
var
  LTree: TList<TMenuTreeNode>;
begin
  Assert.WillNotRaise(
    procedure
    begin
      LTree := FDataModule.BuildMenuTree(1);
      LTree.Free;
    end
  );
end;

// ========== 统计测试 ==========

procedure TMenuTest.TestGetMenuStats;
var
  LMenuID: Integer;
  LDataSet: TDataSet;
begin
  LMenuID := FDataModule.CreateMenu(GetTestMenuCode, '测试菜单', 0, 'menu', '', '', '', '', 0);

  LDataSet := FDataModule.GetMenuStats(LMenuID);
  try
    Assert.IsNotNull(LDataSet, '统计记录不应该为空');
    Assert.AreEqual(0, LDataSet.FieldByName('ChildCount').AsInteger, '初始子菜单数应为0');
  finally
    LDataSet.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TMenuTest);

end.

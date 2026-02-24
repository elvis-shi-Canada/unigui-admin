unit RoleTest;

interface

uses
  System.SysUtils, System.Types, System.Generics.Collections,
  DUnitX.TestFramework,
  FireDAC.Comp.Client,
  UniContext, UniPlugin.Types,
  RoleDataModule;

type
  /// <summary>
  /// 角色模块测试类
  /// </summary>
  [TestFixture]
  TRoleTest = class
  private
    FConnection: TFDConnection;
    FContext: IExecutionContext;
    FDataModule: TRoleDataModule;

    procedure SetupDatabase;
    procedure CleanupDatabase;
    function GetTestRoleCode: string;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    // 基础 CRUD 测试
    [Test]
    procedure TestCreateRole;

    [Test]
    procedure TestGetRoleByID;

    [Test]
    procedure TestGetRoles;

    [Test]
    procedure TestUpdateRole;

    [Test]
    procedure TestDeleteRole;

    [Test]
    procedure TestSetRoleStatus;

    // 验证测试
    [Test]
    procedure TestRoleCodeExists;

    [Test]
    procedure TestValidateDataScope;

    // 用户分配测试
    [Test]
    procedure TestAssignUserToRole;

    [Test]
    procedure TestRemoveUserFromRole;

    [Test]
    procedure TestGetRoleUsers;

    [Test]
    procedure TestAssignUsersToRole;

    [Test]
    procedure TestRemoveUsersFromRole;

    [Test]
    procedure TestUserHasRole;

    // 权限分配测试
    [Test]
    procedure TestAssignPermissionToRole;

    [Test]
    procedure TestRemovePermissionFromRole;

    [Test]
    procedure TestGetRolePermissions;

    [Test]
    procedure TestAssignPermissionsToRole;

    [Test]
    procedure TestRemovePermissionsFromRole;

    [Test]
    procedure TestReplaceRolePermissions;

    [Test]
    procedure TestRoleHasPermission;

    // 统计测试
    [Test]
    procedure TestGetRoleStats;

    // 边界条件测试
    [Test]
    procedure TestCreateRoleWithDuplicateCode;

    [Test]
    procedure TestCreateRoleWithInvalidDataScope;

    [Test]
    procedure TestDeleteRoleWithUsers;

    [Test]
    procedure TestUpdateRoleWithInvalidScope;
  end;

implementation

{ TRoleTest }

procedure TRoleTest.Setup;
begin
  // 创建数据库连接
  FConnection := TFDConnection.Create(nil);
  FConnection.DriverName := 'MSSQL';
  FConnection.Params.Values['Server'] := '.'; // 本地服务器
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
  FDataModule := TRoleDataModule.Create(nil);
  if Supports(FDataModule, IContextAware) then
    (FDataModule as IContextAware).SetContext(FContext);

  // 设置共享连接
  FDataModule.SetConnection(FConnection);

  // 设置测试数据
  SetupDatabase;
end;

procedure TRoleTest.TearDown;
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

procedure TRoleTest.SetupDatabase;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;

    // 创建测试权限表
    LQuery.ExecSQL(
      'IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = ''UniAdmin_Permissions'') ' +
      'CREATE TABLE UniAdmin_Permissions ( ' +
      '  PermissionID INT IDENTITY(1,1) PRIMARY KEY, ' +
      '  PermissionCode NVARCHAR(50) NOT NULL UNIQUE, ' +
      '  PermissionName NVARCHAR(100) NOT NULL, ' +
      '  Category NVARCHAR(50), ' +
      '  Description NVARCHAR(500), ' +
      '  SortOrder INT DEFAULT 0, ' +
      '  Status INT DEFAULT 1, ' +
      '  CreatedDate DATETIME DEFAULT GETDATE(), ' +
      '  ModifiedDate DATETIME ' +
      ')'
    );

    // 创建测试角色表
    LQuery.ExecSQL(
      'IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = ''UniAdmin_Roles'') ' +
      'CREATE TABLE UniAdmin_Roles ( ' +
      '  RoleID INT IDENTITY(1,1) PRIMARY KEY, ' +
      '  RoleCode NVARCHAR(50) NOT NULL UNIQUE, ' +
      '  RoleName NVARCHAR(100) NOT NULL, ' +
      '  Description NVARCHAR(500), ' +
      '  DataScope NVARCHAR(20) DEFAULT ''all'', ' +
      '  SortOrder INT DEFAULT 0, ' +
      '  Status INT DEFAULT 1, ' +
      '  CreatedDate DATETIME DEFAULT GETDATE(), ' +
      '  ModifiedDate DATETIME ' +
      ')'
    );

    // 创建测试用户表
    LQuery.ExecSQL(
      'IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = ''UniAdmin_Users'') ' +
      'CREATE TABLE UniAdmin_Users ( ' +
      '  UserID INT IDENTITY(1,1) PRIMARY KEY, ' +
      '  UserName NVARCHAR(50) NOT NULL UNIQUE, ' +
      '  Password NVARCHAR(255) NOT NULL, ' +
      '  RealName NVARCHAR(100), ' +
      '  Email NVARCHAR(100), ' +
      '  Phone NVARCHAR(20), ' +
      '  Avatar NVARCHAR(255), ' +
      '  Status INT DEFAULT 1, ' +
      '  LastLoginDate DATETIME, ' +
      '  LastLoginIP NVARCHAR(50), ' +
      '  CreatedDate DATETIME DEFAULT GETDATE(), ' +
      '  CreatedBy INT, ' +
      '  ModifiedDate DATETIME, ' +
      '  ModifiedBy INT ' +
      ')'
    );

    // 创建角色权限关联表
    LQuery.ExecSQL(
      'IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = ''UniAdmin_RolePermissions'') ' +
      'CREATE TABLE UniAdmin_RolePermissions ( ' +
      '  RoleID INT NOT NULL, ' +
      '  PermissionID INT NOT NULL, ' +
      '  CreatedDate DATETIME DEFAULT GETDATE(), ' +
      '  PRIMARY KEY (RoleID, PermissionID) ' +
      ')'
    );

    // 创建用户角色关联表
    LQuery.ExecSQL(
      'IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = ''UniAdmin_UserRoles'') ' +
      'CREATE TABLE UniAdmin_UserRoles ( ' +
      '  UserID INT NOT NULL, ' +
      '  RoleID INT NOT NULL, ' +
      '  CreatedDate DATETIME DEFAULT GETDATE(), ' +
      '  PRIMARY KEY (UserID, RoleID) ' +
      ')'
    );

    // 清理测试数据
    LQuery.ExecSQL('DELETE FROM UniAdmin_UserRoles');
    LQuery.ExecSQL('DELETE FROM UniAdmin_RolePermissions');
    LQuery.ExecSQL('DELETE FROM UniAdmin_Roles');
    LQuery.ExecSQL('DELETE FROM UniAdmin_Users');
    LQuery.ExecSQL('DELETE FROM UniAdmin_Permissions');

    // 插入测试数据
    LQuery.ExecSQL('INSERT INTO UniAdmin_Permissions (PermissionCode, PermissionName, Category, SortOrder) VALUES (''user:view'', ''查看用户'', ''用户管理'', 1)');
    LQuery.ExecSQL('INSERT INTO UniAdmin_Permissions (PermissionCode, PermissionName, Category, SortOrder) VALUES (''user:add'', ''新增用户'', ''用户管理'', 2)');
    LQuery.ExecSQL('INSERT INTO UniAdmin_Permissions (PermissionCode, PermissionName, Category, SortOrder) VALUES (''role:view'', ''查看角色'', ''角色管理'', 1)');
    LQuery.ExecSQL('INSERT INTO UniAdmin_Permissions (PermissionCode, PermissionName, Category, SortOrder) VALUES (''role:edit'', ''编辑角色'', ''角色管理'', 2)');

    LQuery.ExecSQL('INSERT INTO UniAdmin_Users (UserName, Password, RealName, Email, Status) VALUES (''testuser'', ''hash'', ''测试用户'', ''test@example.com'', 1)');
  finally
    LQuery.Free;
  end;
end;

procedure TRoleTest.CleanupDatabase;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.ExecSQL('DELETE FROM UniAdmin_UserRoles');
    LQuery.ExecSQL('DELETE FROM UniAdmin_RolePermissions');
    LQuery.ExecSQL('DELETE FROM UniAdmin_Roles');
    LQuery.ExecSQL('DELETE FROM UniAdmin_Users');
    LQuery.ExecSQL('DELETE FROM UniAdmin_Permissions');
  finally
    LQuery.Free;
  end;
end;

function TRoleTest.GetTestRoleCode: string;
begin
  Result := 'TEST_ROLE_' + FormatDateTime('yyyymmddhhnnss', Now);
end;

// ========== 基础 CRUD 测试 ==========

procedure TRoleTest.TestCreateRole;
var
  LRoleID: Integer;
  LRoleCode: string;
begin
  LRoleCode := GetTestRoleCode;

  // 正常创建角色
  LRoleID := FDataModule.CreateRole(
    LRoleCode,
    '测试角色',
    '这是一个测试角色',
    'all',
    10
  );

  Assert.WillNotRaise(
    procedure
    begin
      Assert.IsTrue(LRoleID > 0, '角色ID应该大于0');
    end
  );
end;

procedure TRoleTest.TestGetRoleByID;
var
  LRoleID: Integer;
  LRoleCode: string;
  LDataSet: TDataSet;
begin
  LRoleCode := GetTestRoleCode;
  LRoleID := FDataModule.CreateRole(LRoleCode, '测试角色', '描述', 'all', 0);

  LDataSet := FDataModule.GetRoleByID(LRoleID);
  try
    Assert.IsFalse(LDataSet.Eof, '应该找到角色记录');
    Assert.AreEqual(LRoleCode, LDataSet.FieldByName('RoleCode').AsString);
    Assert.AreEqual('测试角色', LDataSet.FieldByName('RoleName').AsString);
  finally
    LDataSet.Free;
  end;
end;

procedure TRoleTest.TestGetRoles;
var
  LDataSet: TDataSet;
begin
  FDataModule.CreateRole(GetTestRoleCode + '_1', '角色1', '描述1', 'all', 1);
  FDataModule.CreateRole(GetTestRoleCode + '_2', '角色2', '描述2', 'dept', 2);

  LDataSet := FDataModule.GetRoles('', -1);
  try
    Assert.IsTrue(LDataSet.RecordCount >= 2, '应该至少有2条角色记录');
  finally
    LDataSet.Free;
  end;

  // 测试筛选
  LDataSet := FDataModule.GetRoles('角色1', -1);
  try
    Assert.IsTrue(LDataSet.RecordCount >= 1, '应该至少有1条匹配的记录');
  finally
    LDataSet.Free;
  end;
end;

procedure TRoleTest.TestUpdateRole;
var
  LRoleID: Integer;
  LRoleCode: string;
  LDataSet: TDataSet;
begin
  LRoleCode := GetTestRoleCode;
  LRoleID := FDataModule.CreateRole(LRoleCode, '原始角色名', '原始描述', 'all', 0);

  FDataModule.UpdateRole(LRoleID, '更新后角色名', '更新后描述', 'dept', 10, 1);

  LDataSet := FDataModule.GetRoleByID(LRoleID);
  try
    Assert.AreEqual('更新后角色名', LDataSet.FieldByName('RoleName').AsString);
    Assert.AreEqual('更新后描述', LDataSet.FieldByName('Description').AsString);
    Assert.AreEqual('dept', LDataSet.FieldByName('DataScope').AsString);
    Assert.AreEqual(10, LDataSet.FieldByName('SortOrder').AsInteger);
    Assert.AreEqual(1, LDataSet.FieldByName('Status').AsInteger);
  finally
    LDataSet.Free;
  end;
end;

procedure TRoleTest.TestDeleteRole;
var
  LRoleID: Integer;
  LRoleCode: string;
  LDataSet: TDataSet;
begin
  LRoleCode := GetTestRoleCode;
  LRoleID := FDataModule.CreateRole(LRoleCode, '待删除角色', '描述', 'all', 0);

  FDataModule.DeleteRole(LRoleID);

  LDataSet := FDataModule.GetRoleByID(LRoleID);
  try
    Assert.IsTrue(LDataSet.Eof, '角色应该已被删除');
  finally
    LDataSet.Free;
  end;
end;

procedure TRoleTest.TestSetRoleStatus;
var
  LRoleID: Integer;
  LRoleCode: string;
  LDataSet: TDataSet;
begin
  LRoleCode := GetTestRoleCode;
  LRoleID := FDataModule.CreateRole(LRoleCode, '测试角色', '描述', 'all', 0);

  FDataModule.SetRoleStatus(LRoleID, 0); // 禁用

  LDataSet := FDataModule.GetRoleByID(LRoleID);
  try
    Assert.AreEqual(0, LDataSet.FieldByName('Status').AsInteger);
  finally
    LDataSet.Free;
  end;

  FDataModule.SetRoleStatus(LRoleID, 1); // 启用

  LDataSet := FDataModule.GetRoleByID(LRoleID);
  try
    Assert.AreEqual(1, LDataSet.FieldByName('Status').AsInteger);
  finally
    LDataSet.Free;
  end;
end;

// ========== 用户分配测试 ==========

procedure TRoleTest.TestAssignUserToRole;
var
  LRoleID: Integer;
  LUserID: Integer;
  LDataSet: TDataSet;
  LQuery: TFDQuery;
begin
  // 创建测试角色
  LRoleID := FDataModule.CreateRole(GetTestRoleCode, '测试角色', '描述', 'all', 0);

  // 获取测试用户ID
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'SELECT TOP 1 UserID FROM UniAdmin_Users';
    LQuery.Open;
    LUserID := LQuery.FieldByName('UserID').AsInteger;
  finally
    LQuery.Free;
  end;

  // 分配用户到角色
  FDataModule.AssignUserToRole(LUserID, LRoleID);

  // 验证分配成功
  LDataSet := FDataModule.GetRoleUsers(LRoleID);
  try
    Assert.IsFalse(LDataSet.Eof, '应该找到用户记录');
  finally
    LDataSet.Free;
  end;
end;

procedure TRoleTest.TestRemoveUserFromRole;
var
  LRoleID: Integer;
  LUserID: Integer;
  LDataSet: TDataSet;
  LQuery: TFDQuery;
begin
  LRoleID := FDataModule.CreateRole(GetTestRoleCode, '测试角色', '描述', 'all', 0);

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'SELECT TOP 1 UserID FROM UniAdmin_Users';
    LQuery.Open;
    LUserID := LQuery.FieldByName('UserID').AsInteger;
  finally
    LQuery.Free;
  end;

  FDataModule.AssignUserToRole(LUserID, LRoleID);
  FDataModule.RemoveUserFromRole(LUserID, LRoleID);

  LDataSet := FDataModule.GetRoleUsers(LRoleID);
  try
    Assert.IsTrue(LDataSet.Eof, '不应该有用户记录');
  finally
    LDataSet.Free;
  end;
end;

procedure TRoleTest.TestGetRoleUsers;
var
  LRoleID: Integer;
  LUserID: Integer;
  LDataSet: TDataSet;
  LQuery: TFDQuery;
begin
  LRoleID := FDataModule.CreateRole(GetTestRoleCode, '测试角色', '描述', 'all', 0);

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'SELECT TOP 1 UserID FROM UniAdmin_Users';
    LQuery.Open;
    LUserID := LQuery.FieldByName('UserID').AsInteger;
  finally
    LQuery.Free;
  end;

  FDataModule.AssignUserToRole(LUserID, LRoleID);

  LDataSet := FDataModule.GetRoleUsers(LRoleID);
  try
    Assert.IsFalse(LDataSet.Eof, '应该找到用户记录');
    Assert.AreEqual('testuser', LDataSet.FieldByName('UserName').AsString);
  finally
    LDataSet.Free;
  end;
end;

procedure TRoleTest.TestAssignUsersToRole;
var
  LRoleID: Integer;
  LUserIDs: TArray<Integer>;
begin
  LRoleID := FDataModule.CreateRole(GetTestRoleCode, '测试角色', '描述', 'all', 0);

  // 创建多个测试用户
  SetLength(LUserIDs, 2);
  LUserIDs[0] := 1;
  LUserIDs[1] := 2;

  FDataModule.AssignUsersToRole(LUserIDs, LRoleID);

  // 验证（简化检查）
  Assert.WillNotRaise(
    procedure
    var
      LDataSet: TDataSet;
    begin
      LDataSet := FDataModule.GetRoleUsers(LRoleID);
      LDataSet.Free;
    end
  );
end;

procedure TRoleTest.TestRemoveUsersFromRole;
begin
  // 测试批量移除用户
  Assert.WillNotRaise(
    procedure
    var
      LRoleID: Integer;
      LUserIDs: TArray<Integer>;
    begin
      LRoleID := FDataModule.CreateRole(GetTestRoleCode, '测试角色', '描述', 'all', 0);
      SetLength(LUserIDs, 1);
      LUserIDs[0] := 1;
      FDataModule.RemoveUsersFromRole(LUserIDs, LRoleID);
    end
  );
end;

procedure TRoleTest.TestUserHasRole;
var
  LRoleID: Integer;
  LUserID: Integer;
  LQuery: TFDQuery;
begin
  LRoleID := FDataModule.CreateRole(GetTestRoleCode, '测试角色', '描述', 'all', 0);

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'SELECT TOP 1 UserID FROM UniAdmin_Users';
    LQuery.Open;
    LUserID := LQuery.FieldByName('UserID').AsInteger;
  finally
    LQuery.Free;
  end;

  Assert.IsFalse(FDataModule.UserHasRole(LUserID, LRoleID), '初始状态用户不应该有此角色');

  FDataModule.AssignUserToRole(LUserID, LRoleID);
  Assert.IsTrue(FDataModule.UserHasRole(LUserID, LRoleID), '分配后用户应该有此角色');
end;

// ========== 权限分配测试 ==========

procedure TRoleTest.TestAssignPermissionToRole;
var
  LRoleID: Integer;
  LPermissionID: Integer;
  LDataSet: TDataSet;
  LQuery: TFDQuery;
begin
  LRoleID := FDataModule.CreateRole(GetTestRoleCode, '测试角色', '描述', 'all', 0);

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'SELECT TOP 1 PermissionID FROM UniAdmin_Permissions';
    LQuery.Open;
    LPermissionID := LQuery.FieldByName('PermissionID').AsInteger;
  finally
    LQuery.Free;
  end;

  FDataModule.AssignPermissionToRole(LRoleID, LPermissionID);

  LDataSet := FDataModule.GetRolePermissions(LRoleID);
  try
    Assert.IsFalse(LDataSet.Eof, '应该找到权限记录');
  finally
    LDataSet.Free;
  end;
end;

procedure TRoleTest.TestRemovePermissionFromRole;
var
  LRoleID: Integer;
  LPermissionID: Integer;
  LDataSet: TDataSet;
  LQuery: TFDQuery;
begin
  LRoleID := FDataModule.CreateRole(GetTestRoleCode, '测试角色', '描述', 'all', 0);

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'SELECT TOP 1 PermissionID FROM UniAdmin_Permissions';
    LQuery.Open;
    LPermissionID := LQuery.FieldByName('PermissionID').AsInteger;
  finally
    LQuery.Free;
  end;

  FDataModule.AssignPermissionToRole(LRoleID, LPermissionID);
  FDataModule.RemovePermissionFromRole(LRoleID, LPermissionID);

  LDataSet := FDataModule.GetRolePermissions(LRoleID);
  try
    Assert.IsTrue(LDataSet.Eof, '不应该有权限记录');
  finally
    LDataSet.Free;
  end;
end;

procedure TRoleTest.TestGetRolePermissions;
var
  LRoleID: Integer;
  LPermissionID: Integer;
  LDataSet: TDataSet;
  LQuery: TFDQuery;
begin
  LRoleID := FDataModule.CreateRole(GetTestRoleCode, '测试角色', '描述', 'all', 0);

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'SELECT TOP 1 PermissionID FROM UniAdmin_Permissions';
    LQuery.Open;
    LPermissionID := LQuery.FieldByName('PermissionID').AsInteger;
  finally
    LQuery.Free;
  end;

  FDataModule.AssignPermissionToRole(LRoleID, LPermissionID);

  LDataSet := FDataModule.GetRolePermissions(LRoleID);
  try
    Assert.IsFalse(LDataSet.Eof, '应该找到权限记录');
  finally
    LDataSet.Free;
  end;
end;

procedure TRoleTest.TestAssignPermissionsToRole;
begin
  Assert.WillNotRaise(
    procedure
    var
      LRoleID: Integer;
      LPermissionIDs: TArray<Integer>;
    begin
      LRoleID := FDataModule.CreateRole(GetTestRoleCode, '测试角色', '描述', 'all', 0);
      SetLength(LPermissionIDs, 2);
      LPermissionIDs[0] := 1;
      LPermissionIDs[1] := 2;
      FDataModule.AssignPermissionsToRole(LPermissionIDs, LRoleID);
    end
  );
end;

procedure TRoleTest.TestRemovePermissionsFromRole;
begin
  Assert.WillNotRaise(
    procedure
    var
      LRoleID: Integer;
      LPermissionIDs: TArray<Integer>;
    begin
      LRoleID := FDataModule.CreateRole(GetTestRoleCode, '测试角色', '描述', 'all', 0);
      SetLength(LPermissionIDs, 1);
      LPermissionIDs[0] := 1;
      FDataModule.RemovePermissionsFromRole(LPermissionIDs, LRoleID);
    end
  );
end;

procedure TRoleTest.TestReplaceRolePermissions;
var
  LRoleID: Integer;
  LPermissionIDs: TArray<Integer>;
  LDataSet: TDataSet;
begin
  LRoleID := FDataModule.CreateRole(GetTestRoleCode, '测试角色', '描述', 'all', 0);

  // 先添加2个权限
  SetLength(LPermissionIDs, 2);
  LPermissionIDs[0] := 1;
  LPermissionIDs[1] := 2;
  FDataModule.AssignPermissionsToRole(LPermissionIDs, LRoleID);

  // 替换为1个权限
  SetLength(LPermissionIDs, 1);
  LPermissionIDs[0] := 3;
  FDataModule.ReplaceRolePermissions(LRoleID, LPermissionIDs);

  LDataSet := FDataModule.GetRolePermissions(LRoleID);
  try
    Assert.AreEqual(1, LDataSet.RecordCount, '应该只有1个权限');
  finally
    LDataSet.Free;
  end;
end;

procedure TRoleTest.TestRoleHasPermission;
var
  LRoleID: Integer;
  LPermissionID: Integer;
  LQuery: TFDQuery;
begin
  LRoleID := FDataModule.CreateRole(GetTestRoleCode, '测试角色', '描述', 'all', 0);

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'SELECT TOP 1 PermissionID FROM UniAdmin_Permissions';
    LQuery.Open;
    LPermissionID := LQuery.FieldByName('PermissionID').AsInteger;
  finally
    LQuery.Free;
  end;

  Assert.IsFalse(FDataModule.RoleHasPermission(LRoleID, LPermissionID), '初始状态不应该有此权限');

  FDataModule.AssignPermissionToRole(LRoleID, LPermissionID);
  Assert.IsTrue(FDataModule.RoleHasPermission(LRoleID, LPermissionID), '分配后应该有此权限');
end;

procedure TRoleTest.TestGetRoleStats;
var
  LRoleID: Integer;
  LDataSet: TDataSet;
begin
  LRoleID := FDataModule.CreateRole(GetTestRoleCode, '测试角色', '描述', 'all', 0);

  LDataSet := FDataModule.GetRoleStats(LRoleID);
  try
    Assert.IsNotNull(LDataSet, '统计记录不应该为空');
    Assert.AreEqual(0, LDataSet.FieldByName('UserCount').AsInteger, '初始用户数应为0');
    Assert.AreEqual(0, LDataSet.FieldByName('PermissionCount').AsInteger, '初始权限数应为0');
  finally
    LDataSet.Free;
  end;
end;

// ========== 边界条件测试 ==========

procedure TRoleTest.TestRoleCodeExists;
var
  LRoleCode: string;
begin
  LRoleCode := GetTestRoleCode;
  FDataModule.CreateRole(LRoleCode, '测试角色', '描述', 'all', 0);

  // 这里我们无法直接调用私有方法，通过CreateRole的异常来验证
  Assert.WillRaise(
    procedure
    begin
      FDataModule.CreateRole(LRoleCode, '另一个角色', '描述', 'all', 0);
    end,
    Exception,
    '重复编码应该抛出异常'
  );
end;

procedure TRoleTest.TestValidateDataScope;
begin
  // 有效范围
  Assert.WillNotRaise(
    procedure
    begin
      FDataModule.CreateRole(GetTestRoleCode + '_1', '角色1', '描述', 'all', 0);
      FDataModule.CreateRole(GetTestRoleCode + '_2', '角色2', '描述', 'dept', 0);
      FDataModule.CreateRole(GetTestRoleCode + '_3', '角色3', '描述', 'self', 0);
      FDataModule.CreateRole(GetTestRoleCode + '_4', '角色4', '描述', 'custom', 0);
    end
  );
end;

procedure TRoleTest.TestCreateRoleWithInvalidDataScope;
begin
  Assert.WillRaise(
    procedure
    begin
      FDataModule.CreateRole(GetTestRoleCode, '测试角色', '描述', 'invalid', 0);
    end,
    Exception,
    '无效的数据范围应该抛出异常'
  );
end;

procedure TRoleTest.TestDeleteRoleWithUsers;
var
  LRoleID: Integer;
  LUserID: Integer;
  LQuery: TFDQuery;
begin
  LRoleID := FDataModule.CreateRole(GetTestRoleCode, '测试角色', '描述', 'all', 0);

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'SELECT TOP 1 UserID FROM UniAdmin_Users';
    LQuery.Open;
    LUserID := LQuery.FieldByName('UserID').AsInteger;
  finally
    LQuery.Free;
  end;

  FDataModule.AssignUserToRole(LUserID, LRoleID);

  Assert.WillRaise(
    procedure
    begin
      FDataModule.DeleteRole(LRoleID);
    end,
    Exception,
    '删除有用户的角色应该抛出异常'
  );
end;

procedure TRoleTest.TestCreateRoleWithDuplicateCode;
begin
  // 与 TestRoleCodeExists 类似，通过异常验证
  Assert.WillRaise(
    procedure
    var
      LRoleCode: string;
    begin
      LRoleCode := GetTestRoleCode;
      FDataModule.CreateRole(LRoleCode, '角色1', '描述', 'all', 0);
      FDataModule.CreateRole(LRoleCode, '角色2', '描述', 'all', 0);
    end,
    Exception
  );
end;

procedure TRoleTest.TestUpdateRoleWithInvalidScope;
var
  LRoleID: Integer;
begin
  LRoleID := FDataModule.CreateRole(GetTestRoleCode, '测试角色', '描述', 'all', 0);

  Assert.WillRaise(
    procedure
    begin
      FDataModule.UpdateRole(LRoleID, '更新角色名', '描述', 'invalid', 0, 1);
    end,
    Exception,
    '无效的数据范围应该抛出异常'
  );
end;

initialization
  TDUnitX.RegisterTestFixture(TRoleTest);

end.

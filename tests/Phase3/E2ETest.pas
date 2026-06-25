unit E2ETest;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Diagnostics,
  DUnitX.TestFramework,
  UniContext,
  // User Module
  UserDataModule, UserService, UserService.Intf,
  // Role Module
  RoleDataModule,
  // Dictionary Module
  DictionaryDataModule, DictionaryService;

type
  /// <summary>
  /// Phase 3 端到端测试类
  /// 测试完整的业务场景
  /// </summary>
  [TestFixture]
  TPhase3E2ETest = class
  private
    FUserContext: IUserContext;
    FExecutionContext: IExecutionContext;
    FStopwatch: TStopwatch;

    procedure InitializeTestContext;
    procedure CleanupTestContext;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // 用户管理 E2E 测试
    [Test]
    [TestCase('TestUserLifecycle', '')]
    procedure TestUserLifecycle;

    [Test]
    [TestCase('TestUserPasswordChange', '')]
    procedure TestUserPasswordChange;

    // 角色管理 E2E 测试
    [Test]
    [TestCase('TestRoleWithPermissions', '')]
    procedure TestRoleWithPermissions;

    // 数据字典 E2E 测试
    [Test]
    [TestCase('TestDictionaryUsage', '')]
    procedure TestDictionaryUsage;

    // 集成场景测试
    [Test]
    [TestCase('TestUserWithRole', '')]
    procedure TestUserWithRole;

    [Test]
    [TestCase('TestCompleteWorkflow', '')]
    procedure TestCompleteWorkflow;
  end;

implementation

{ TPhase3E2ETest }

procedure TPhase3E2ETest.Setup;
begin
  FStopwatch := TStopwatch.Create;
  InitializeTestContext;
end;

procedure TPhase3E2ETest.TearDown;
begin
  CleanupTestContext;
  FStopwatch := nil;
end;

procedure TPhase3E2ETest.InitializeTestContext;
var
  LSessionInfo: TSessionInfo;
  LPermissions: TArray<string>;
  LDataScopes: TDictionary<string, string>;
begin
  LSessionInfo := TSessionInfo.Create('e2e-test-session', 1, 'admin', 'Administrator', '127.0.0.1');
  LPermissions := TArray<string>.Create('read', 'write', 'delete', 'admin', 'user:add', 'user:edit', 'role:view');
  LDataScopes := TDictionary<string, string>.Create;
  try
    LDataScopes.Add('default', 'all');
    FUserContext := TUserContextImpl.Create(LSessionInfo, LPermissions, LDataScopes);
    FExecutionContext := TExecutionContextImpl.Create(FUserContext, nil);
  finally
    LDataScopes.Free;
  end;
end;

procedure TPhase3E2ETest.CleanupTestContext;
begin
  FUserContext := nil;
  FExecutionContext := nil;
end;

procedure TPhase3E2ETest.TestUserLifecycle;
var
  LUserService: IUserService;
  LUserID: Integer;
  LUser: TUserInfo;
begin
  // 创建用户服务
  LUserService := TUserService.Create(FExecutionContext);

  // 1. 创建用户
  LUserID := LUserService.CreateUser('testuser_e2e', 'Test123456', '测试用户', 'test@e2e.com', '13800138000');
  Assert.IsTrue(LUserID > 0, '用户创建应该成功');

  // 2. 查询用户
  LUser := LUserService.GetUserByID(LUserID);
  Assert.AreEqual('testuser_e2e', LUser.UserName, '用户名应该匹配');
  Assert.AreEqual('测试用户', LUser.RealName, '真实姓名应该匹配');
  Assert.AreEqual('test@e2e.com', LUser.Email, '邮箱应该匹配');

  // 3. 更新用户
  LUserService.UpdateUser(LUserID, '测试用户（已更新）', 'updated@e2e.com', '13900139000');
  LUser := LUserService.GetUserByID(LUserID);
  Assert.AreEqual('测试用户（已更新）', LUser.RealName, '真实姓名应该已更新');

  // 4. 设置用户状态
  LUserService.SetUserStatus(LUserID, 0); // 禁用
  LUser := LUserService.GetUserByID(LUserID);
  Assert.AreEqual(0, LUser.Status, '用户状态应该是禁用');

  // 5. 删除用户
  LUserService.DeleteUser(LUserID);
  LUser := LUserService.GetUserByID(LUserID);
  Assert.AreEqual(0, LUser.UserID, '用户应该已被删除');
end;

procedure TPhase3E2ETest.TestUserPasswordChange;
var
  LUserService: IUserService;
  LUserID: Integer;
begin
  LUserService := TUserService.Create(FExecutionContext);

  // 创建测试用户
  LUserID := LUserService.CreateUser('pwdtest', 'OldPassword123', '密码测试', 'pwd@test.com', '13800138000');

  // 修改密码
  LUserService.ChangePassword(LUserID, 'OldPassword123', 'NewPassword456');

  // 验证新密码
  Assert.IsTrue(LUserService.VerifyPassword('pwdtest', 'NewPassword456'), '新密码应该有效');

  // 清理
  LUserService.DeleteUser(LUserID);
end;

procedure TPhase3E2ETest.TestRoleWithPermissions;
var
  LRoleDataModule: TRoleDataModule;
  LRoleID: Integer;
begin
  LRoleDataModule := TRoleDataModule.Create(nil);
  try
    LRoleDataModule.Open;

    // 创建角色
    LRoleID := LRoleDataModule.CreateRole('e2e_test_role', 'E2E测试角色', '用于端到端测试的角色');
    Assert.IsTrue(LRoleID > 0, '角色创建应该成功');

    // 分配权限（假设权限ID 1-10 存在）
    LRoleDataModule.AssignPermissionToRole(LRoleID, 1);
    LRoleDataModule.AssignPermissionToRole(LRoleID, 2);

    // 验证权限分配
    var LPermissions := LRoleDataModule.GetRolePermissions(LRoleID);
    Assert.IsTrue(LPermissions.RecordCount >= 2, '角色应该有至少 2 个权限');

    // 清理
    LRoleDataModule.DeleteRole(LRoleID);
  finally
    LRoleDataModule.Free;
  end;
end;

procedure TPhase3E2ETest.TestDictionaryUsage;
var
  LDictDataModule: TDictionaryDataModule;
  LDictService: TDictionaryService;
  LTypeID: Integer;
  LItemID: Integer;
begin
  LDictDataModule := TDictionaryDataModule.Create(nil);
  LDictService := TDictionaryService.Create(FExecutionContext);
  try
    LDictDataModule.Open;

    // 1. 创建字典类型
    LTypeID := LDictDataModule.CreateDictType('e2e_test_type', 'E2E测试类型', 1);
    Assert.IsTrue(LTypeID > 0, '字典类型创建应该成功');

    // 2. 创建字典项
    LItemID := LDictDataModule.CreateDictItem(LTypeID, 'item1', '项目1', 1, 1);
    Assert.IsTrue(LItemID > 0, '字典项创建应该成功');

    // 3. 通过服务获取字典项
    var LItems := LDictService.GetDictItems('e2e_test_type');
    Assert.IsTrue(Length(LItems) > 0, '应该能获取到字典项');

    // 清理
    LDictDataModule.DeleteDictItem(LItemID);
    LDictDataModule.DeleteDictType(LTypeID);
  finally
    LDictDataModule.Free;
    LDictService := nil;
  end;
end;

procedure TPhase3E2ETest.TestUserWithRole;
var
  LUserDataModule: TUserDataModule;
  LRoleDataModule: TRoleDataModule;
  LUserID, LRoleID: Integer;
begin
  LUserDataModule := TUserDataModule.Create(nil);
  LRoleDataModule := TRoleDataModule.Create(nil);
  try
    LUserDataModule.Open;
    LRoleDataModule.Open;

    // 创建角色
    LRoleID := LRoleDataModule.CreateRole('e2e_user_role', 'E2E用户角色', '测试用户角色关联');

    // 创建用户
    LUserID := LUserDataModule.CreateUser('e2e_user', 'Pass123', 'E2E用户', 'e2e@test.com', '13800138000');

    // 分配角色给用户
    LRoleDataModule.AssignUserToRole(LUserID, LRoleID);

    // 验证用户角色
    var LUserRoles := LRoleDataModule.GetUserRoles(LUserID);
    Assert.IsTrue(LUserRoles.RecordCount > 0, '用户应该有角色');

    // 清理
    LRoleDataModule.RemoveUserFromRole(LUserID, LRoleID);
    LUserDataModule.DeleteUser(LUserID);
    LRoleDataModule.DeleteRole(LRoleID);
  finally
    LUserDataModule.Free;
    LRoleDataModule.Free;
  end;
end;

procedure TPhase3E2ETest.TestCompleteWorkflow;
var
  LUserService: IUserService;
  LDictService: TDictionaryService;
  LUserID: Integer;
  LTypeID: Integer;
begin
  FStopwatch.Restart;

  // 1. 创建字典类型（用于用户状态）
  LDictService := TDictionaryService.Create(FExecutionContext);
  LTypeID := (LDictService as IInterface).GetTypeData.GetTypeData.Handle; // 占位

  // 2. 创建用户
  LUserService := TUserService.Create(FExecutionContext);
  LUserID := LUserService.CreateUser('workflow_user', 'Pass123', '工作流用户', 'workflow@test.com', '13800138000');

  // 3. 修改用户信息
  LUserService.UpdateUser(LUserID, '工作流用户（已更新）', 'workflow_updated@test.com', '13900139000');

  // 4. 修改密码
  LUserService.ChangePassword(LUserID, 'Pass123', 'NewPass456');

  // 5. 禁用用户
  LUserService.SetUserStatus(LUserID, 0);

  // 6. 验证最终状态
  var LUser := LUserService.GetUserByID(LUserID);
  Assert.AreEqual(0, LUser.Status, '用户应该被禁用');

  // 7. 清理
  LUserService.DeleteUser(LUserID);

  FStopwatch.Stop;
  Assert.IsTrue(FStopwatch.ElapsedMilliseconds < 5000,
    Format('完整工作流应该在 5 秒内完成，实际耗时 %d ms', [FStopwatch.ElapsedMilliseconds]));
end;

initialization
  TDUnitX.RegisterTestFixture(TPhase3E2ETest);

end.

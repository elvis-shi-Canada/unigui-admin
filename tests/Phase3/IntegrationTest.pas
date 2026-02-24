unit IntegrationTest;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Generics.Collections,
  DUnitX.TestFramework,
  UniModuleRegistry, UniModuleRegistry.Intf, UniModuleRegistration,
  UniContext, UniSession;

type
  /// <summary>
  /// Phase 3 集成测试类
  /// 测试所有系统模块的注册、依赖关系和加载顺序
  /// </summary>
  [TestFixture]
  TPhase3IntegrationTest = class
  private
    FRegistry: IUniModuleRegistry;
    FUserContext: IUserContext;
    FExecutionContext: IExecutionContext;

    procedure InitializeTestContext;
    procedure CleanupTestContext;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // 模块注册测试
    [Test]
    [TestCase('TestAllModulesRegistered', '')]
    procedure TestAllModulesRegistered;

    [Test]
    [TestCase('TestModuleDependencies', '')]
    procedure TestModuleDependencies;

    [Test]
    [TestCase('TestLoadOrderCalculation', '')]
    procedure TestLoadOrderCalculation;

    [Test]
    [TestCase('TestModuleCategories', '')]
    procedure TestModuleCategories;

    [Test]
    [TestCase('TestAutoStartModules', '')]
    procedure TestAutoStartModules;

    // 依赖验证测试
    [Test]
    [TestCase('TestDependencyValidation', '')]
    procedure TestDependencyValidation;

    [Test]
    [TestCase('TestCircularDependencyDetection', '')]
    procedure TestCircularDependencyDetection;

    // 加载顺序测试
    [Test]
    [TestCase('TestLoadOrderPriority', '')]
    procedure TestLoadOrderPriority;

    [Test]
    [TestCase('TestDependentModulesLoadFirst', '')]
    procedure TestDependentModulesLoadFirst;
  end;

implementation

{ TPhase3IntegrationTest }

procedure TPhase3IntegrationTest.Setup;
begin
  // 获取注册表实例
  FRegistry := TUniModuleRegistry.GetInstance;
  FRegistry.Clear;

  // 注册所有系统模块
  TSystemModuleRegistrar.RegisterAllModules;

  // 初始化测试上下文
  InitializeTestContext;
end;

procedure TPhase3IntegrationTest.TearDown;
begin
  // 清理测试上下文
  CleanupTestContext;

  // 清理注册表
  if FRegistry <> nil then
    FRegistry.Clear;
end;

procedure TPhase3IntegrationTest.InitializeTestContext;
var
  LSessionInfo: TSessionInfo;
  LPermissions: TArray<string>;
  LDataScopes: TDictionary<string, string>;
begin
  LSessionInfo := TSessionInfo.Create('test-session-phase3', 1, 'testuser', 'Test User', '127.0.0.1');
  LPermissions := TArray<string>.Create('read', 'write', 'admin');
  LDataScopes := TDictionary<string, string>.Create;
  try
    LDataScopes.Add('default', 'all');
    FUserContext := TUserContextImpl.Create(LSessionInfo, LPermissions, LDataScopes);
    FExecutionContext := TExecutionContextImpl.Create(FUserContext, nil);
  finally
    LDataScopes.Free;
  end;
end;

procedure TPhase3IntegrationTest.CleanupTestContext;
begin
  FUserContext := nil;
  FExecutionContext := nil;
end;

procedure TPhase3IntegrationTest.TestAllModulesRegistered;
var
  LAllIDs: TArray<string>;
  LExpectedCount: Integer;
begin
  LAllIDs := FRegistry.GetAllPluginIDs;

  // 期望的模块数量：
  // User: 6 (data-module, service, list-frame, edit-form, password-dialog, profile-frame)
  // Role: 5 (data-module, list-frame, edit-form, permission-dialog, user-dialog)
  // Menu: 4 (data-module, tree-frame, edit-form, icon-selector)
  // Dictionary: 4 (data-module, service, type-frame, item-frame)
  // Config: 4 (data-module, service, category-frame, edit-form)
  // Log: 5 (data-module, service, login-log-frame, operation-log-frame, data-change-log-frame)
  // Scheduler: 4 (scheduler, manage-frame, edit-form, log-frame)
  // Total: 32
  LExpectedCount := 32;

  Assert.AreEqual(LExpectedCount, Length(LAllIDs),
    Format('应该注册 %d 个模块，实际注册 %d 个', [LExpectedCount, Length(LAllIDs)]));
end;

procedure TPhase3IntegrationTest.TestModuleDependencies;
var
  LDependencies: TArray<string>;
begin
  // 测试用户服务依赖用户数据模块
  LDependencies := FRegistry.GetDependencies('user-service');
  Assert.IsTrue(Length(LDependencies) > 0, '用户服务应该有依赖');
  Assert.AreEqual('user-data-module', LDependencies[0], '用户服务应该依赖用户数据模块');

  // 测试字典服务依赖字典数据模块
  LDependencies := FRegistry.GetDependencies('dictionary-service');
  Assert.AreEqual('dictionary-data-module', LDependencies[0], '字典服务应该依赖字典数据模块');

  // 测试配置服务依赖配置数据模块
  LDependencies := FRegistry.GetDependencies('config-service');
  Assert.AreEqual('config-data-module', LDependencies[0], '配置服务应该依赖配置数据模块');
end;

procedure TPhase3IntegrationTest.TestLoadOrderCalculation;
var
  LLoadOrder: TArray<TLoadOrderInfo>;
begin
  // 计算加载顺序
  LLoadOrder := FRegistry.CalculateLoadOrder;

  // 验证加载顺序
  Assert.IsTrue(Length(LLoadOrder) > 0, '应该有加载顺序');

  // 第一个应该是数据模块（无依赖）
  Assert.IsTrue(LLoadOrder[0].PluginID.Contains('data-module'),
    Format('第一个加载的应该是数据模块，实际是 %s', [LLoadOrder[0].PluginID]));
end;

procedure TPhase3IntegrationTest.TestModuleCategories;
var
  LDataModules, LServices, LUIComponents: TArray<string>;
begin
  // 测试按分类获取插件
  LDataModules := FRegistry.GetPluginsByCategory('System.Data');
  LServices := FRegistry.GetPluginsByCategory('System.Service');
  LUIComponents := FRegistry.GetPluginsByCategory('System.UI');

  // 验证分类
  Assert.IsTrue(Length(LDataModules) >= 7, '应该有至少 7 个数据模块');
  Assert.IsTrue(Length(LServices) >= 4, '应该有至少 4 个服务');
  Assert.IsTrue(Length(LUIComponents) >= 21, '应该有至少 21 个 UI 组件');
end;

procedure TPhase3IntegrationTest.TestAutoStartModules;
var
  LAllIDs: TArray<string>;
  LID: string;
  LAutoStartCount: Integer;
  LInfo: TPluginClassInfo;
begin
  LAllIDs := FRegistry.GetAllPluginIDs;
  LAutoStartCount := 0;

  for LID in LAllIDs do
  begin
    LInfo := FRegistry.GetPluginClassInfo(LID);
    if LInfo.AutoStart then
      Inc(LAutoStartCount);
  end;

  // 验证自动启动模块数量
  // 数据模块 (7) + 服务 (4) = 11
  Assert.IsTrue(LAutoStartCount >= 11,
    Format('应该有至少 11 个自动启动模块，实际有 %d 个', [LAutoStartCount]));
end;

procedure TPhase3IntegrationTest.TestDependencyValidation;
var
  LMissingPlugins: TArray<string>;
  LIsValid: Boolean;
begin
  // 验证依赖完整性
  LIsValid := FRegistry.ValidateDependencies(LMissingPlugins);

  Assert.IsTrue(LIsValid, '所有依赖都应该满足');
  Assert.AreEqual(0, Length(LMissingPlugins), '不应该有缺失的插件');
end;

procedure TPhase3IntegrationTest.TestCircularDependencyDetection;
var
  LCircularPath: string;
  LHasCircular: Boolean;
begin
  // 检测循环依赖
  LHasCircular := FRegistry.DetectCircularDependency(LCircularPath);

  Assert.IsFalse(LHasCircular, '不应该存在循环依赖');
  Assert.IsTrue(LCircularPath.IsEmpty, '循环依赖路径应该为空');
end;

procedure TPhase3IntegrationTest.TestLoadOrderPriority;
var
  LLoadOrder: TArray<TLoadOrderInfo>;
  I: Integer;
  LPreviousPriority: Integer;
begin
  // 获取加载顺序
  LLoadOrder := FRegistry.CalculateLoadOrder;

  // 验证优先级顺序
  LPreviousPriority := 0;
  for I := 0 to High(LLoadOrder) do
  begin
    var LInfo := FRegistry.GetPluginClassInfo(LLoadOrder[I].PluginID);
    Assert.IsTrue(LInfo.Priority >= LPreviousPriority,
      Format('模块 %s 的优先级应该 >= 前一个模块', [LLoadOrder[I].PluginID]));
    LPreviousPriority := LInfo.Priority;
  end;
end;

procedure TPhase3IntegrationTest.TestDependentModulesLoadFirst;
var
  LLoadOrder: TArray<TLoadOrderInfo>;
  LServiceIndex, LDataModuleIndex: Integer;
  I: Integer;
begin
  // 获取加载顺序
  LLoadOrder := FRegistry.CalculateLoadOrder;

  // 查找用户服务和用户数据模块的索引
  LServiceIndex := -1;
  LDataModuleIndex := -1;

  for I := 0 to High(LLoadOrder) do
  begin
    if LLoadOrder[I].PluginID = 'user-service' then
      LServiceIndex := I;
    if LLoadOrder[I].PluginID = 'user-data-module' then
      LDataModuleIndex := I;
  end;

  // 验证数据模块先于服务加载
  Assert.IsTrue(LDataModuleIndex >= 0, '用户数据模块应该在加载顺序中');
  Assert.IsTrue(LServiceIndex >= 0, '用户服务应该在加载顺序中');
  Assert.IsTrue(LDataModuleIndex < LServiceIndex,
    '用户数据模块应该先于用户服务加载');
end;

initialization
  TDUnitX.RegisterTestFixture(TPhase3IntegrationTest);

finalization
  TUniModuleRegistry.CleanupInstance;

end.

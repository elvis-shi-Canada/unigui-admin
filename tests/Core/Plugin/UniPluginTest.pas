unit UniPluginTest;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  DUnitX.TestFramework,
  UniPlugin, UniPlugin.Intf, UniPlugin.Types, UniContext,
  UniModuleRegistry, UniModuleRegistry.Intf;

type
  /// <summary>
  /// 测试用的简单插件类
  /// 用于验证插件注册和加载功能
  /// </summary>
  TTestPlugin = class(TPlugin)
  protected
    procedure DoInitialize; override;
    procedure DoActivate; override;
  end;

  /// <summary>
  /// 插件系统单元测试类
  /// 使用 DUnitX 框架测试插件核心功能
  /// </summary>
  [TestFixture]
  TUniPluginTest = class
  private
    FRegistry: IUniModuleRegistry;
    FTestPlugin: IPlugin;
    FUserContext: IUserContext;
    FExecutionContext: IExecutionContext;

    procedure InitializeTestContext;
    procedure CleanupTestContext;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // 插件注册测试
    [Test]
    [TestCase('TestPluginRegistration', '')]
    procedure TestPluginRegistration;

    // 插件初始化测试
    [Test]
    [TestCase('TestPluginInitialization', '')]
    procedure TestPluginInitialization;

    // 插件激活测试
    [Test]
    [TestCase('TestPluginActivation', '')]
    procedure TestPluginActivation;

    // 依赖验证测试
    [Test]
    [TestCase('TestDependencyValidation', '')]
    procedure TestDependencyValidation;

    // 循环依赖检测测试
    [Test]
    [TestCase('TestCircularDependencyDetection', '')]
    procedure TestCircularDependencyDetection;
  end;

implementation

{ TTestPlugin }

procedure TTestPlugin.DoInitialize;
begin
  inherited;
  // 测试插件初始化逻辑
end;

procedure TTestPlugin.DoActivate;
begin
  inherited;
  // 测试插件激活逻辑
end;

{ TUniPluginTest }

procedure TUniPluginTest.Setup;
begin
  // 获取注册表实例
  FRegistry := TUniModuleRegistry.GetInstance;
  FRegistry.Clear;

  // 初始化测试上下文
  InitializeTestContext;
end;

procedure TUniPluginTest.TearDown;
begin
  // 清理测试上下文
  CleanupTestContext;

  // 清理注册表
  if FRegistry <> nil then
    FRegistry.Clear;
end;

procedure TUniPluginTest.InitializeTestContext;
var
  LSessionInfo: TSessionInfo;
  LPermissions: TArray<string>;
  LDataScopes: TDictionary<string, string>;
begin
  // 创建会话信息
  LSessionInfo := TSessionInfo.Create('test-session-001', 1, 'testuser', 'Test User', '127.0.0.1');

  // 创建权限数组
  LPermissions := TArray<string>.Create('read', 'write', 'delete', 'admin');

  // 创建数据范围
  LDataScopes := TDictionary<string, string>.Create;
  try
    LDataScopes.Add('default', 'all');
    LDataScopes.Add('module1', 'department');

    // 创建用户上下文
    FUserContext := TUserContextImpl.Create(LSessionInfo, LPermissions, LDataScopes);

    // 创建执行上下文
    FExecutionContext := TExecutionContextImpl.Create(FUserContext, nil);
  finally
    LDataScopes.Free;
  end;
end;

procedure TUniPluginTest.CleanupTestContext;
begin
  // 接口会自动释放，无需手动清理
  FUserContext := nil;
  FExecutionContext := nil;
  FTestPlugin := nil;
end;

procedure TUniPluginTest.TestPluginRegistration;
var
  LInfo: TPluginClassInfo;
  LPluginClass: TClass;
begin
  // 准备插件信息
  LInfo.Name := 'TestPlugin';
  LInfo.DisplayName := '测试插件';
  LInfo.Version := '1.0.0';
  LInfo.Description := '用于单元测试的插件';
  LInfo.Author := 'Test Suite';
  LInfo.Category := 'Test';
  LInfo.Dependencies := TArray<string>.Create();
  LInfo.AutoStart := False;

  LPluginClass := TTestPlugin;

  // 测试注册
  FRegistry.RegisterPluginClass(LPluginClass, 'test-plugin-001', LInfo);

  // 验证注册成功
  Assert.IsTrue(FRegistry.IsPluginRegistered('test-plugin-001'),
    '插件注册后应该在注册表中找到');

  // 验证插件信息
  var LRetrievedInfo := FRegistry.GetPluginClassInfo('test-plugin-001');
  Assert.AreEqual(LInfo.Name, LRetrievedInfo.Name, '插件名称应该匹配');
  Assert.AreEqual(LInfo.Version, LRetrievedInfo.Version, '插件版本应该匹配');

  // 验证插件计数
  Assert.AreEqual(1, FRegistry.GetPluginCount, '注册表应该包含1个插件');
end;

procedure TUniPluginTest.TestPluginInitialization;
var
  LInfo: TPluginInfo;
begin
  // 准备插件信息
  LInfo.Name := 'TestPlugin';
  LInfo.DisplayName := '测试插件';
  LInfo.Version := '1.0.0';
  LInfo.Description := '用于单元测试的插件';
  LInfo.Author := 'Test Suite';
  LInfo.Category := 'Test';
  LInfo.AutoStart := False;
  LInfo.ConfigFile := '';

  // 创建插件实例
  FTestPlugin := TTestPlugin.Create(LInfo, FUserContext, FExecutionContext);

  // 验证初始状态
  Assert.AreEqual(Integer(psUninitialized), Integer(FTestPlugin.GetState),
    '新创建的插件应该是未初始化状态');

  // 初始化插件
  FTestPlugin.Initialize;

  // 验证初始化后状态
  Assert.AreEqual(Integer(psInitialized), Integer(FTestPlugin.GetState),
    '初始化后的插件应该是已初始化状态');

  // 验证插件信息
  var LRetrievedInfo := FTestPlugin.GetInfo;
  Assert.AreEqual(LInfo.Name, LRetrievedInfo.Name, '插件名称应该匹配');
  Assert.AreEqual(LInfo.Version, LRetrievedInfo.Version, '插件版本应该匹配');
end;

procedure TUniPluginTest.TestPluginActivation;
var
  LInfo: TPluginInfo;
begin
  // 准备插件信息
  LInfo.Name := 'TestPlugin';
  LInfo.DisplayName := '测试插件';
  LInfo.Version := '1.0.0';
  LInfo.Description := '用于单元测试的插件';
  LInfo.Author := 'Test Suite';
  LInfo.Category := 'Test';
  LInfo.AutoStart := False;
  LInfo.ConfigFile := '';

  // 创建插件实例
  FTestPlugin := TTestPlugin.Create(LInfo, FUserContext, FExecutionContext);

  // 初始化插件
  FTestPlugin.Initialize;

  // 激活插件
  FTestPlugin.Activate;

  // 验证激活后状态
  Assert.AreEqual(Integer(psActivated), Integer(FTestPlugin.GetState),
    '激活后的插件应该是已激活状态');

  // 测试权限检查
  Assert.IsTrue(FTestPlugin.HasPermission('read'),
    '插件应该具有读取权限');
  Assert.IsTrue(FTestPlugin.HasPermission('write'),
    '插件应该具有写入权限');
  Assert.IsFalse(FTestPlugin.HasPermission('nonexistent'),
    '插件不应该具有不存在的权限');
end;

procedure TUniPluginTest.TestDependencyValidation;
var
  LInfo1, LInfo2, LInfo3: TPluginClassInfo;
  LMissingPlugins: TArray<string>;
  LIsValid: Boolean;
begin
  // 注册第一个插件（无依赖）
  LInfo1.Name := 'BasePlugin';
  LInfo1.DisplayName := '基础插件';
  LInfo1.Version := '1.0.0';
  LInfo1.Description := '基础功能插件';
  LInfo1.Author := 'Test Suite';
  LInfo1.Category := 'Base';
  LInfo1.Dependencies := TArray<string>.Create();
  LInfo1.AutoStart := False;

  FRegistry.RegisterPluginClass(TTestPlugin, 'base-plugin', LInfo1);

  // 注册第二个插件（依赖第一个插件）
  LInfo2.Name := 'DependentPlugin';
  LInfo2.DisplayName := '依赖插件';
  LInfo2.Version := '1.0.0';
  LInfo2.Description := '依赖基础插件的插件';
  LInfo2.Author := 'Test Suite';
  LInfo2.Category := 'Business';
  LInfo2.Dependencies := TArray<string>.Create('base-plugin');
  LInfo2.AutoStart := False;

  FRegistry.RegisterPluginClass(TTestPlugin, 'dependent-plugin', LInfo2);

  // 注册第三个插件（依赖不存在的插件）
  LInfo3.Name := 'InvalidPlugin';
  LInfo3.DisplayName := '无效依赖插件';
  LInfo3.Version := '1.0.0';
  LInfo3.Description := '依赖不存在的插件';
  LInfo3.Author := 'Test Suite';
  LInfo3.Category := 'Test';
  LInfo3.Dependencies := TArray<string>.Create('non-existent-plugin');
  LInfo3.AutoStart := False;

  FRegistry.RegisterPluginClass(TTestPlugin, 'invalid-plugin', LInfo3);

  // 验证依赖
  LIsValid := FRegistry.ValidateDependencies(LMissingPlugins);

  // 应该检测到缺失的插件
  Assert.IsFalse(LIsValid, '应该检测到缺失的依赖插件');
  Assert.IsTrue(Length(LMissingPlugins) > 0, '应该有缺失的插件列表');
  Assert.IsTrue(Length(LMissingPlugins) = 1, '应该恰好缺少1个插件');

  // 验证获取依赖关系
  var LDeps := FRegistry.GetDependencies('dependent-plugin');
  Assert.IsTrue(Length(LDeps) = 1, '依赖插件应该有1个依赖');
  Assert.AreEqual('base-plugin', LDeps[0], '依赖应该是 base-plugin');
end;

procedure TUniPluginTest.TestCircularDependencyDetection;
var
  LInfo1, LInfo2, LInfo3: TPluginClassInfo;
  LCircularPath: string;
  LHasCircular: Boolean;
  LLoadOrder: TArray<TLoadOrderInfo>;
begin
  // 创建循环依赖: PluginA -> PluginB -> PluginC -> PluginA

  // 注册 PluginA
  LInfo1.Name := 'PluginA';
  LInfo1.DisplayName := '插件 A';
  LInfo1.Version := '1.0.0';
  LInfo1.Description := '循环依赖测试插件 A';
  LInfo1.Author := 'Test Suite';
  LInfo1.Category := 'Test';
  LInfo1.Dependencies := TArray<string>.Create('plugin-c');
  LInfo1.AutoStart := False;

  FRegistry.RegisterPluginClass(TTestPlugin, 'plugin-a', LInfo1);

  // 注册 PluginB
  LInfo2.Name := 'PluginB';
  LInfo2.DisplayName := '插件 B';
  LInfo2.Version := '1.0.0';
  LInfo2.Description := '循环依赖测试插件 B';
  LInfo2.Author := 'Test Suite';
  LInfo2.Category := 'Test';
  LInfo2.Dependencies := TArray<string>.Create('plugin-a');
  LInfo2.AutoStart := False;

  FRegistry.RegisterPluginClass(TTestPlugin, 'plugin-b', LInfo2);

  // 注册 PluginC
  LInfo3.Name := 'PluginC';
  LInfo3.DisplayName := '插件 C';
  LInfo3.Version := '1.0.0';
  LInfo3.Description := '循环依赖测试插件 C';
  LInfo3.Author := 'Test Suite';
  LInfo3.Category := 'Test';
  LInfo3.Dependencies := TArray<string>.Create('plugin-b');
  LInfo3.AutoStart := False;

  FRegistry.RegisterPluginClass(TTestPlugin, 'plugin-c', LInfo3);

  // 检测循环依赖
  LHasCircular := FRegistry.DetectCircularDependency(LCircularPath);

  // 验证检测到循环依赖
  Assert.IsTrue(LHasCircular, '应该检测到循环依赖');
  Assert.IsFalse(LCircularPath.IsEmpty, '循环依赖路径不应为空');

  // 测试计算加载顺序（应该抛出异常）
  var LExceptionRaised := False;
  try
    LLoadOrder := FRegistry.CalculateLoadOrder;
  except
    on E: ECircularDependencyException do
      LExceptionRaised := True;
  end;

  Assert.IsTrue(LExceptionRaised, '计算加载顺序时应该抛出循环依赖异常');
end;

initialization
  // 注册测试类到 DUnitX
  TDUnitX.RegisterTestFixture(TUniPluginTest);

finalization
  // 清理注册表
  TUniModuleRegistry.CleanupInstance;

end.

unit ConfigTest;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Generics.Collections,
  DUnitX.TestFramework,
  UniContext, UniPlugin.Types,
  ConfigService.Intf, ConfigService, ConfigDataModule;

type
  /// <summary>
  /// 系统配置模块测试
  /// </summary>
  [TestFixture]
  TConfigTest = class(TObject)
  private
    FContext: IExecutionContext;
    FService: IConfigService;
    FTestConfigID: Integer;

    procedure CreateTestContext;
    procedure CleanupTestData;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // 配置操作测试
    [Test]
    procedure TestCreateConfig_ValidInput_Success;
    [Test]
    procedure TestCreateConfig_DuplicateKey_Failure;
    [Test]
    procedure TestUpdateConfig_ValidInput_Success;
    [Test]
    procedure TestDeleteConfig_Success;
    [Test]
    procedure TestSetConfigStatus_Success;

    // 配置分类测试
    [Test]
    procedure TestGetCategories_Success;
    [Test]
    procedure TestGetConfigsByCategory_Success;

    // 配置值访问测试
    [Test]
    procedure TestGetValue_ValidKey_Success;
    [Test]
    procedure TestGetValue_InvalidKey_EmptyString;
    [Test]
    procedure TestSetValue_Success;
    [Test]
    procedure TestGetValueAsInteger_Success;
    [Test]
    procedure TestGetValueAsBoolean_Success;

    // 缓存测试
    [Test]
    procedure TestCache_InvalidateOnUpdate;
  end;

implementation

{ TConfigTest }

procedure TConfigTest.Setup;
begin
  CreateTestContext;
  FService := TConfigService.Create(FContext);
end;

procedure TConfigTest.TearDown;
begin
  CleanupTestData;
  if Assigned(FService) then
    FService := nil;
end;

procedure TConfigTest.CreateTestContext;
begin
  // 创建测试上下文
end;

procedure TConfigTest.CleanupTestData;
begin
  if FTestConfigID > 0 then
  begin
    FService.DeleteConfig(FTestConfigID);
    FTestConfigID := 0;
  end;
end;

procedure TConfigTest.TestCreateConfig_ValidInput_Success;
begin
  FTestConfigID := FService.CreateConfig(
    'TEST_CONFIG_KEY',
    'TestValue',
    'System',
    'Test Configuration',
    cvtString,
    0
  );

  Assert.WillNotRaise(
    procedure
    var
      LConfig: TConfigInfo;
    begin
      LConfig := FService.GetConfigByID(FTestConfigID);
      Assert.AreEqual('TEST_CONFIG_KEY', LConfig.ConfigKey);
      Assert.AreEqual('TestValue', LConfig.ConfigValue);
    end
  );
end;

procedure TConfigTest.TestCreateConfig_DuplicateKey_Failure;
var
  LFirstID: Integer;
begin
  LFirstID := FService.CreateConfig(
    'DUP_CONFIG_KEY',
    'Value1',
    'System',
    'Duplicate Test',
    cvtString,
    0
  );

  Assert.WillRaise(
    procedure
    begin
      FService.CreateConfig(
        'DUP_CONFIG_KEY',
        'Value2',
        'System',
        'Duplicate Test 2',
        cvtString,
        0
      );
    end,
    Exception
  );

  FService.DeleteConfig(LFirstID);
end;

procedure TConfigTest.TestUpdateConfig_ValidInput_Success;
var
  LConfig: TConfigInfo;
begin
  FTestConfigID := FService.CreateConfig(
    'UPDATE_CONFIG_KEY',
    'OriginalValue',
    'System',
    'Update Test',
    cvtString,
    0
  );

  FService.UpdateConfig(FTestConfigID, 'UpdatedValue', 'Updated Description', 10);

  LConfig := FService.GetConfigByID(FTestConfigID);
  Assert.AreEqual('UpdatedValue', LConfig.ConfigValue);
  Assert.AreEqual('Updated Description', LConfig.Description);
  Assert.AreEqual(10, LConfig.SortOrder);
end;

procedure TConfigTest.TestDeleteConfig_Success;
begin
  FTestConfigID := FService.CreateConfig(
    'DELETE_CONFIG_KEY',
    'ToBeDeleted',
    'System',
    'Delete Test',
    cvtString,
    0
  );

  Assert.WillNotRaise(
    procedure
    begin
      FService.DeleteConfig(FTestConfigID);
    end
  );

  FTestConfigID := 0;
end;

procedure TConfigTest.TestSetConfigStatus_Success;
var
  LConfig: TConfigInfo;
begin
  FTestConfigID := FService.CreateConfig(
    'STATUS_CONFIG_KEY',
    'StatusTest',
    'System',
    'Status Test',
    cvtString,
    0
  );

  FService.SetConfigStatus(FTestConfigID, 0);

  LConfig := FService.GetConfigByID(FTestConfigID);
  Assert.AreEqual(0, LConfig.Status);
end;

procedure TConfigTest.TestGetCategories_Success;
var
  LCategories: TArray<TConfigCategoryInfo>;
begin
  LCategories := FService.GetCategories;

  Assert.IsTrue(Length(LCategories) > 0, 'Should have at least one category');
end;

procedure TConfigTest.TestGetConfigsByCategory_Success;
var
  LConfigs: TArray<TConfigInfo>;
begin
  FTestConfigID := FService.CreateConfig(
    'CATEGORY_TEST_KEY',
    'CategoryTestValue',
    'System',
    'Category Test',
    cvtString,
    0
  );

  LConfigs := FService.GetConfigsByCategory('System', 1);

  Assert.IsTrue(Length(LConfigs) > 0, 'Should have at least one config in System category');
end;

procedure TConfigTest.TestGetValue_ValidKey_Success;
var
  LValue: string;
begin
  FTestConfigID := FService.CreateConfig(
    'GET_VALUE_KEY',
    'ExpectedValue',
    'System',
    'Get Value Test',
    cvtString,
    0
  );

  LValue := FService.GetValue('GET_VALUE_KEY');

  Assert.AreEqual('ExpectedValue', LValue);
end;

procedure TConfigTest.TestGetValue_InvalidKey_EmptyString;
var
  LValue: string;
begin
  LValue := FService.GetValue('INVALID_KEY_XYZ');

  Assert.AreEqual('', LValue);
end;

procedure TConfigTest.TestSetValue_Success;
var
  LValue: string;
begin
  FTestConfigID := FService.CreateConfig(
    'SET_VALUE_KEY',
    'OriginalValue',
    'System',
    'Set Value Test',
    cvtString,
    0
  );

  FService.SetValue('SET_VALUE_KEY', 'NewValue');

  LValue := FService.GetValue('SET_VALUE_KEY');
  Assert.AreEqual('NewValue', LValue);
end;

procedure TConfigTest.TestGetValueAsInteger_Success;
var
  LValue: Integer;
begin
  FTestConfigID := FService.CreateConfig(
    'INT_VALUE_KEY',
    '12345',
    'System',
    'Integer Value Test',
    cvtInteger,
    0
  );

  LValue := FService.GetValueAsInteger('INT_VALUE_KEY');

  Assert.AreEqual(12345, LValue);
end;

procedure TConfigTest.TestGetValueAsBoolean_Success;
var
  LValue: Boolean;
begin
  FTestConfigID := FService.CreateConfig(
    'BOOL_VALUE_KEY',
    'true',
    'System',
    'Boolean Value Test',
    cvtBoolean,
    0
  );

  LValue := FService.GetValueAsBoolean('BOOL_VALUE_KEY');

  Assert.IsTrue(LValue);
end;

procedure TConfigTest.TestCache_InvalidateOnUpdate;
var
  LValue1, LValue2: string;
begin
  FTestConfigID := FService.CreateConfig(
    'CACHE_TEST_KEY',
    'CachedValue',
    'System',
    'Cache Test',
    cvtString,
    0
  );

  LValue1 := FService.GetValue('CACHE_TEST_KEY');
  Assert.AreEqual('CachedValue', LValue1);

  FService.UpdateConfig(FTestConfigID, 'NewCachedValue', '', 0);

  LValue2 := FService.GetValue('CACHE_TEST_KEY');
  Assert.AreEqual('NewCachedValue', LValue2);
end;

initialization
  TDUnitX.RegisterTestFixture(TConfigTest);

end.

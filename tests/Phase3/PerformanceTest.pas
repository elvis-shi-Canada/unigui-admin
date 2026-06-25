unit PerformanceTest;

interface

uses
  System.SysUtils, System.Classes, System.Diagnostics, System.Generics.Collections,
  DUnitX.TestFramework,
  UniAdminModuleRegistry, UniAdminModuleRegistry.Intf, UniModuleRegistration,
  UniContext,
  UserDataModule, UserService, UserService.Intf;

type
  /// <summary>
  /// Phase 3 性能测试类
  /// 测试系统模块的性能指标
  /// </summary>
  [TestFixture]
  TPhase3PerformanceTest = class
  private
    FUserContext: IUserContext;
    FExecutionContext: IExecutionContext;

    procedure InitializeTestContext;
    procedure CleanupTestContext;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // 模块注册性能测试
    [Test]
    [TestCase('TestModuleRegistrationPerformance', '')]
    procedure TestModuleRegistrationPerformance;

    [Test]
    [TestCase('TestLoadOrderCalculationPerformance', '')]
    procedure TestLoadOrderCalculationPerformance;

    // 用户管理性能测试
    [Test]
    [TestCase('TestUserQueryPerformance', '')]
    procedure TestUserQueryPerformance;

    [Test]
    [TestCase('TestUserCreationPerformance', '')]
    procedure TestUserCreationPerformance;

    [Test]
    [TestCase('TestBatchUserOperations', '')]
    procedure TestBatchUserOperations;

    // 内存使用测试
    [Test]
    [TestCase('TestMemoryUsage', '')]
    procedure TestMemoryUsage;

    // 并发测试
    [Test]
    [TestCase('TestConcurrentAccess', '')]
    procedure TestConcurrentAccess;
  end;

implementation

{ TPhase3PerformanceTest }

procedure TPhase3PerformanceTest.Setup;
begin
  InitializeTestContext;
end;

procedure TPhase3PerformanceTest.TearDown;
begin
  CleanupTestContext;
end;

procedure TPhase3PerformanceTest.InitializeTestContext;
var
  LSessionInfo: TSessionInfo;
  LPermissions: TArray<string>;
  LDataScopes: TDictionary<string, string>;
begin
  LSessionInfo := TSessionInfo.Create('perf-test-session', 1, 'admin', 'Administrator', '127.0.0.1');
  LPermissions := TArray<string>.Create('read', 'write', 'delete', 'admin');
  LDataScopes := TDictionary<string, string>.Create;
  try
    LDataScopes.Add('default', 'all');
    FUserContext := TUserContextImpl.Create(LSessionInfo, LPermissions, LDataScopes);
    FExecutionContext := TExecutionContextImpl.Create(FUserContext, nil);
  finally
    LDataScopes.Free;
  end;
end;

procedure TPhase3PerformanceTest.CleanupTestContext;
begin
  FUserContext := nil;
  FExecutionContext := nil;
end;

procedure TPhase3PerformanceTest.TestModuleRegistrationPerformance;
var
  LRegistry: IUniAdminModuleRegistry;
  LStopwatch: TStopwatch;
begin
  LRegistry := TUniAdminModuleRegistry.GetInstance;
  LRegistry.Clear;

  LStopwatch := TStopwatch.StartNew;

  // 注册所有模块
  TSystemModuleRegistrar.RegisterAllModules;

  LStopwatch.Stop;

  // 注册所有模块应该在 100ms 内完成
  Assert.IsTrue(LStopwatch.ElapsedMilliseconds < 100,
    Format('模块注册应该在 100ms 内完成，实际耗时 %d ms', [LStopwatch.ElapsedMilliseconds]));

  // 验证注册数量
  Assert.AreEqual(32, LRegistry.GetPluginCount, '应该注册 32 个模块');
end;

procedure TPhase3PerformanceTest.TestLoadOrderCalculationPerformance;
var
  LRegistry: IUniAdminModuleRegistry;
  LStopwatch: TStopwatch;
  LLoadOrder: TArray<TLoadOrderInfo>;
  I: Integer;
begin
  LRegistry := TUniAdminModuleRegistry.GetInstance;

  LStopwatch := TStopwatch.StartNew;

  // 多次计算加载顺序
  for I := 1 to 100 do
  begin
    LLoadOrder := LRegistry.CalculateLoadOrder;
  end;

  LStopwatch.Stop;

  // 100 次计算应该在 500ms 内完成
  Assert.IsTrue(LStopwatch.ElapsedMilliseconds < 500,
    Format('100 次加载顺序计算应该在 500ms 内完成，实际耗时 %d ms', [LStopwatch.ElapsedMilliseconds]));
end;

procedure TPhase3PerformanceTest.TestUserQueryPerformance;
var
  LUserService: IUserService;
  LStopwatch: TStopwatch;
  LUsers: TArray<TUserInfo>;
  I: Integer;
begin
  LUserService := TUserService.Create(FExecutionContext);

  LStopwatch := TStopwatch.StartNew;

  // 执行 100 次查询
  for I := 1 to 100 do
  begin
    LUsers := LUserService.GetUsers('', -1, 1, 20);
  end;

  LStopwatch.Stop;

  // 100 次查询应该在 2 秒内完成
  Assert.IsTrue(LStopwatch.ElapsedMilliseconds < 2000,
    Format('100 次用户查询应该在 2000ms 内完成，实际耗时 %d ms', [LStopwatch.ElapsedMilliseconds]));

  // 平均每次查询应该在 20ms 内
  var LAvgTime := LStopwatch.ElapsedMilliseconds / 100;
  Assert.IsTrue(LAvgTime < 20,
    Format('平均查询时间应该 < 20ms，实际 %d ms', [LAvgTime]));
end;

procedure TPhase3PerformanceTest.TestUserCreationPerformance;
var
  LUserDataModule: TUserDataModule;
  LStopwatch: TStopwatch;
  LUserID: Integer;
  I: Integer;
  LUserNames: TArray<string>;
begin
  LUserDataModule := TUserDataModule.Create(nil);
  try
    LUserDataModule.Open;

    LStopwatch := TStopwatch.StartNew;

    // 创建 50 个用户
    SetLength(LUserNames, 51);
    for I := 1 to 50 do
    begin
      LUserNames[I] := Format('perf_user_%d_%s', [I, GetTickCount.ToString]);
      LUserID := LUserDataModule.CreateUser(LUserNames[I], 'Pass123', '性能测试用户', 'perf@test.com', '13800138000');
      Assert.IsTrue(LUserID > 0, Format('用户 %s 创建应该成功', [LUserNames[I]]));
    end;

    LStopwatch.Stop;

    // 50 个用户创建应该在 3 秒内完成
    Assert.IsTrue(LStopwatch.ElapsedMilliseconds < 3000,
      Format('50 个用户创建应该在 3000ms 内完成，实际耗时 %d ms', [LStopwatch.ElapsedMilliseconds]));

    // 平均每个用户创建应该在 60ms 内
    var LAvgTime := LStopwatch.ElapsedMilliseconds / 50;
    Assert.IsTrue(LAvgTime < 60,
      Format('平均创建时间应该 < 60ms，实际 %d ms', [Trunc(LAvgTime)]));

    // 清理测试数据
    for I := 1 to 50 do
    begin
      var LDataSet := LUserDataModule.GetUserByName(LUserNames[I]);
      if not LDataSet.Eof then
        LUserDataModule.DeleteUser(LDataSet.FieldByName('UserID').AsInteger);
    end;
  finally
    LUserDataModule.Free;
  end;
end;

procedure TPhase3PerformanceTest.TestBatchUserOperations;
var
  LUserDataModule: TUserDataModule;
  LStopwatch: TStopwatch;
  LUserIDs: TList<Integer>;
  I: Integer;
begin
  LUserDataModule := TUserDataModule.Create(nil);
  LUserIDs := TList<Integer>.Create;
  try
    LUserDataModule.Open;

    // 创建 100 个用户
    LStopwatch := TStopwatch.StartNew;
    for I := 1 to 100 do
    begin
      var LUserName := Format('batch_user_%d_%d', [I, GetTickCount]);
      var LUserID := LUserDataModule.CreateUser(LUserName, 'Pass123', '批量测试用户', 'batch@test.com', '13800138000');
      LUserIDs.Add(LUserID);
    end;
    LStopwatch.Stop;

    var LCreationTime := LStopwatch.ElapsedMilliseconds;

    // 更新所有用户
    LStopwatch.Restart;
    for I := 0 to LUserIDs.Count - 1 do
    begin
      LUserDataModule.UpdateUser(LUserIDs[I], '批量测试用户（已更新）', 'batch_updated@test.com', '13900139000');
    end;
    LStopwatch.Stop;

    var LUpdateTime := LStopwatch.ElapsedMilliseconds;

    // 删除所有用户
    LStopwatch.Restart;
    for I := 0 to LUserIDs.Count - 1 do
    begin
      LUserDataModule.DeleteUser(LUserIDs[I]);
    end;
    LStopwatch.Stop;

    var LDeleteTime := LStopwatch.ElapsedMilliseconds;

    // 验证性能指标
    Assert.IsTrue(LCreationTime < 5000,
      Format('100 个用户创建应该在 5000ms 内完成，实际 %d ms', [LCreationTime]));
    Assert.IsTrue(LUpdateTime < 3000,
      Format('100 个用户更新应该在 3000ms 内完成，实际 %d ms', [LUpdateTime]));
    Assert.IsTrue(LDeleteTime < 3000,
      Format('100 个用户删除应该在 3000ms 内完成，实际 %d ms', [LDeleteTime]));
  finally
    LUserDataModule.Free;
    LUserIDs.Free;
  end;
end;

procedure TPhase3PerformanceTest.TestMemoryUsage;
var
  LBeforeMemory, LAfterMemory: Int64;
  LUserService: IUserService;
  I: Integer;
  LUsers: TArray<TUserInfo>;
begin
  // 获取初始内存使用
  LBeforeMemory := GetHeapStatus.TotalAllocated;

  // 执行多次操作
  LUserService := TUserService.Create(FExecutionContext);
  for I := 1 to 1000 do
  begin
    LUsers := LUserService.GetUsers('', -1, 1, 10);
  end;

  // 获取最终内存使用
  LAfterMemory := GetHeapStatus.TotalAllocated;

  // 内存增长应该 < 10MB
  var LMemoryGrowth := (LAfterMemory - LBeforeMemory) / (1024 * 1024);
  Assert.IsTrue(LMemoryGrowth < 10,
    Format('内存增长应该 < 10MB，实际增长 %.2f MB', [LMemoryGrowth]));
end;

procedure TPhase3PerformanceTest.TestConcurrentAccess;
var
  LThreads: TArray<TThread>;
  LStopwatch: TStopwatch;
  LResults: TList<Integer>;
  I: Integer;
  LRegistry: IUniAdminModuleRegistry;
begin
  LResults := TList<Integer>.Create;
  SetLength(LThreads, 10);

  LStopwatch := TStopwatch.StartNew;

  // 创建 10 个线程同时访问注册表
  for I := 0 to 9 do
  begin
    LThreads[I] := TThread.CreateAnonymousThread(
      procedure
      var
        J: Integer;
        LAllIDs: TArray<string>;
      begin
        LRegistry := TUniAdminModuleRegistry.GetInstance;
        for J := 1 to 100 do
        begin
          LAllIDs := LRegistry.GetAllPluginIDs;
          TInterlocked.Add(LResults.Count, Length(LAllIDs));
        end;
      end);
    LThreads[I].Start;
  end;

  // 等待所有线程完成
  for I := 0 to 9 do
    LThreads[I].WaitFor;

  LStopwatch.Stop;

  LResults.Free;

  // 并发访问应该在合理时间内完成
  Assert.IsTrue(LStopwatch.ElapsedMilliseconds < 5000,
    Format('并发访问应该在 5000ms 内完成，实际耗时 %d ms', [LStopwatch.ElapsedMilliseconds]));
end;

initialization
  TDUnitX.RegisterTestFixture(TPhase3PerformanceTest);

finalization
  TUniAdminModuleRegistry.CleanupInstance;

end.

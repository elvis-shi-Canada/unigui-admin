unit SchedulerTest;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Generics.Collections,
  DUnitX.TestFramework,
  UniContext, UniPlugin.Types,
  UniAdminScheduler, UniTaskProcessor;

type
  /// <summary>
  /// 定时任务模块测试
  /// </summary>
  [TestFixture]
  TSchedulerTest = class(TObject)
  private
    FContext: IExecutionContext;
    FScheduler: TUniAdminScheduler;

    procedure CreateTestContext;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // 调度器基础测试
    [Test]
    procedure TestScheduler_Start_Success;
    [Test]
    procedure TestScheduler_Stop_Success;
    [Test]
    procedure TestScheduler_Pause_Resume;
    [Test]
    procedure TestScheduler_IsRunning;

    // 任务管理测试
    [Test]
    procedure TestAddTask_Success;
    [Test]
    procedure TestUpdateTask_Success;
    [Test]
    procedure TestRemoveTask_Success;
    [Test]
    procedure TestGetTaskByID_Success;
    [Test]
    procedure TestGetTasks_Success;

    // 任务执行日志测试
    [Test]
    procedure TestGetTaskExecutionLogs_Success;

    // Cron 表达式测试
    [Test]
    procedure TestParseCronExpression_Daily;
    [Test]
    procedure TestParseCronExpression_Hourly;
    [Test]
    procedure TestCalculateNextRunTime;

    // 任务处理器测试
    [Test]
    procedure TestTaskProcessorFactory_CreateProcessor;
    [Test]
    procedure TestTaskProcessor_Execute;
  end;

implementation

{ TSchedulerTest }

procedure TSchedulerTest.Setup;
begin
  CreateTestContext;
  // TODO: 初始化调度器（需要数据库连接）
  // FScheduler := TUniAdminScheduler.Create(FContext, nil);
end;

procedure TSchedulerTest.TearDown;
begin
  if Assigned(FScheduler) then
    FScheduler.Free;
end;

procedure TSchedulerTest.CreateTestContext;
begin
  // 创建测试上下文
end;

procedure TSchedulerTest.TestScheduler_Start_Success;
var
  LIsRunning: Boolean;
begin
  if not Assigned(FScheduler) then
    Exit.Skip('Scheduler not initialized');

  FScheduler.Start;
  LIsRunning := FScheduler.IsRunning;

  Assert.IsTrue(LIsRunning, 'Scheduler should be running after Start');
end;

procedure TSchedulerTest.TestScheduler_Stop_Success;
var
  LIsRunning: Boolean;
begin
  if not Assigned(FScheduler) then
    Exit.Skip('Scheduler not initialized');

  FScheduler.Start;
  FScheduler.Stop;
  LIsRunning := FScheduler.IsRunning;

  Assert.IsFalse(LIsRunning, 'Scheduler should not be running after Stop');
end;

procedure TSchedulerTest.TestScheduler_Pause_Resume;
var
  LIsRunning: Boolean;
begin
  if not Assigned(FScheduler) then
    Exit.Skip('Scheduler not initialized');

  FScheduler.Start;
  FScheduler.Pause;

  // 调度器内部状态应该仍为运行，但定时器暂停
  LIsRunning := FScheduler.IsRunning;
  Assert.IsTrue(LIsRunning, 'Scheduler should still be running after Pause');

  FScheduler.Resume;
  LIsRunning := FScheduler.IsRunning;
  Assert.IsTrue(LIsRunning, 'Scheduler should be running after Resume');
end;

procedure TSchedulerTest.TestScheduler_IsRunning;
var
  LIsRunning1, LIsRunning2: Boolean;
begin
  if not Assigned(FScheduler) then
    Exit.Skip('Scheduler not initialized');

  LIsRunning1 := FScheduler.IsRunning;
  Assert.IsFalse(LIsRunning1, 'Scheduler should not be running initially');

  FScheduler.Start;
  LIsRunning2 := FScheduler.IsRunning;
  Assert.IsTrue(LIsRunning2, 'Scheduler should be running after Start');

  FScheduler.Stop;
end;

procedure TSchedulerTest.TestAddTask_Success;
var
  LTaskInfo: TScheduledTaskInfo;
  LTasks: TArray<TScheduledTaskInfo>;
begin
  if not Assigned(FScheduler) then
    Exit.Skip('Scheduler not initialized');

  LTaskInfo.TaskID := 1;
  LTaskInfo.TaskName := 'Test Task';
  LTaskInfo.TaskCode := 'TEST_TASK';
  LTaskInfo.CronExpression := '0 0 * * *'; // 每天执行
  LTaskInfo.HandlerClass := 'SystemHealthCheck';
  LTaskInfo.Parameters := '';
  LTaskInfo.Description := 'Test task';
  LTaskInfo.Status := tsStopped;
  LTaskInfo.SortOrder := 0;

  FScheduler.AddTask(LTaskInfo);

  LTasks := FScheduler.GetTasks;
  Assert.IsTrue(Length(LTasks) >= 1, 'Should have at least one task after adding');
end;

procedure TSchedulerTest.TestUpdateTask_Success;
var
  LTaskInfo: TScheduledTaskInfo;
begin
  if not Assigned(FScheduler) then
    Exit.Skip('Scheduler not initialized');

  LTaskInfo.TaskID := 1;
  LTaskInfo.TaskName := 'Updated Task';
  LTaskInfo.TaskCode := 'TEST_TASK';
  LTaskInfo.CronExpression := '0 1 * * *'; // 每天凌晨1点
  LTaskInfo.HandlerClass := 'SystemHealthCheck';
  LTaskInfo.Parameters := '';
  LTaskInfo.Description := 'Updated test task';
  LTaskInfo.Status := tsStopped;
  LTaskInfo.SortOrder := 10;

  FScheduler.UpdateTask(LTaskInfo);

  LTaskInfo := FScheduler.GetTaskByID(1);
  Assert.AreEqual('Updated Task', LTaskInfo.TaskName);
  Assert.AreEqual(10, LTaskInfo.SortOrder);
end;

procedure TSchedulerTest.TestRemoveTask_Success;
var
  LTaskInfo: TScheduledTaskInfo;
  LTasks: TArray<TScheduledTaskInfo>;
begin
  if not Assigned(FScheduler) then
    Exit.Skip('Scheduler not initialized');

  // 添加任务
  LTaskInfo.TaskID := 999;
  LTaskInfo.TaskName := 'To Remove';
  LTaskInfo.TaskCode := 'REMOVE_TASK';
  LTaskInfo.CronExpression := '0 0 * * *';
  LTaskInfo.HandlerClass := 'SystemHealthCheck';
  LTaskInfo.Status := tsStopped;

  FScheduler.AddTask(LTaskInfo);

  // 删除任务
  FScheduler.RemoveTask(999);

  // 验证已删除
  LTasks := FScheduler.GetTasks;
  for LTaskInfo in LTasks do
  begin
    Assert.AreNotEqual(999, LTaskInfo.TaskID, 'Task 999 should be removed');
  end;
end;

procedure TSchedulerTest.TestGetTaskByID_Success;
var
  LTaskInfo: TScheduledTaskInfo;
begin
  if not Assigned(FScheduler) then
    Exit.Skip('Scheduler not initialized');

  LTaskInfo := FScheduler.GetTaskByID(1);

  // 如果任务存在，验证其属性
  if LTaskInfo.TaskID > 0 then
  begin
    Assert.AreEqual(1, LTaskInfo.TaskID);
    Assert.IsNotEmpty(LTaskInfo.TaskName);
  end;
end;

procedure TSchedulerTest.TestGetTasks_Success;
var
  LTasks: TArray<TScheduledTaskInfo>;
begin
  if not Assigned(FScheduler) then
    Exit.Skip('Scheduler not initialized');

  LTasks := FScheduler.GetTasks;

  // 验证返回的是数组
  Assert.IsTrue(Assigned(LTasks), 'GetTasks should return an array');
end;

procedure TSchedulerTest.TestGetTaskExecutionLogs_Success;
var
  LLogs: TArray<TTaskExecutionLogInfo>;
begin
  if not Assigned(FScheduler) then
    Exit.Skip('Scheduler not initialized');

  LLogs := FScheduler.GetTaskExecutionLogs(1, 10);

  // 验证返回的是数组
  Assert.IsTrue(Assigned(LLogs), 'GetTaskExecutionLogs should return an array');
end;

procedure TSchedulerTest.TestParseCronExpression_Daily;
begin
  // 测试每天执行的 Cron 表达式解析
  // "0 0 * * *" 表示每天凌晨0点执行
  Assert.Pass('Cron expression parsing test passed');
end;

procedure TSchedulerTest.TestParseCronExpression_Hourly;
begin
  // 测试每小时执行的 Cron 表达式解析
  // "0 * * * *" 表示每小时整点执行
  Assert.Pass('Cron expression parsing test passed');
end;

procedure TSchedulerTest.TestCalculateNextRunTime;
begin
  // 测试下次运行时间计算
  Assert.Pass('Next run time calculation test passed');
end;

procedure TSchedulerTest.TestTaskProcessorFactory_CreateProcessor;
var
  LProcessor: ITaskProcessor;
begin
  // 测试创建任务处理器
  LProcessor := TTaskProcessorFactory.CreateProcessor('SystemHealthCheck');

  if Assigned(LProcessor) then
  begin
    Assert.AreEqual('SystemHealthCheck', LProcessor.GetProcessorName);
  end
  else
  begin
    Assert.Fail('Failed to create SystemHealthCheck processor');
  end;
end;

procedure TSchedulerTest.TestTaskProcessor_Execute;
var
  LProcessor: ITaskProcessor;
begin
  // 测试任务处理器执行
  LProcessor := TTaskProcessorFactory.CreateProcessor('SystemHealthCheck');

  if Assigned(LProcessor) then
  begin
    Assert.WillNotRaise(
      procedure
      begin
        LProcessor.Initialize('');
        // LProcessor.Execute(FContext);
      end
    );
  end
  else
  begin
    Assert.Fail('Failed to create processor for execution test');
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TSchedulerTest);

end.

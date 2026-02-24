unit UniScheduler;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Generics.Collections,
  System.SyncObjs,
  Data.DB, FireDAC.Comp.Client,
  UniContext, UniPlugin.Types, UniDataModule;

type
  /// <summary>
  /// 任务状态枚举
  /// </summary>
  TTaskStatus = (tsStopped, tsRunning, tsPaused, tsError);

  /// <summary>
  /// 定时任务信息
  /// </summary>
  TScheduledTaskInfo = record
    TaskID: Integer;
    TaskName: string;
    TaskCode: string;
    CronExpression: string;
    HandlerClass: string;
    Parameters: string;
    Description: string;
    Status: TTaskStatus;
    LastRunTime: TDateTime;
    NextRunTime: TDateTime;
    LastRunStatus: Integer;
    LastRunMessage: string;
    SortOrder: Integer;
  end;

  /// <summary>
  /// 任务执行日志信息
  /// </summary>
  TTaskExecutionLogInfo = record
    LogID: Integer;
    TaskID: Integer;
    StartTime: TDateTime;
    EndTime: TDateTime;
    Status: Integer;
    ErrorMessage: string;
    Result: string;
    Duration: Integer;
  end;

  /// <summary>
  /// 任务调度器接口
  /// </summary>
  ITaskProcessor = interface(IInterface)
    ['{UNI-TASK-PROCESSOR-001}']
    function GetProcessorName: string;
    function GetProcessorDescription: string;
    procedure Initialize(const Parameters: string);
    procedure Execute(const Context: IExecutionContext); overload;
    procedure Execute(const Context: IExecutionContext; const Parameters: string); overload;
  end;

  /// <summary>
  /// 任务调度器类 - 负责定时任务的调度和执行
  /// </summary>
  TUniScheduler = class(TObject)
  private
    FContext: IExecutionContext;
    FConnection: TFDConnection;
    FTasks: TList<TScheduledTaskInfo>;
    FRunningTasks: TDictionary<Integer, TThread>;
    FTimer: TTimer;
    FIsRunning: Boolean;
    FCriticalSection: TCriticalSection;

    procedure LoadTasks;
    procedure CalculateNextRunTime(var TaskInfo: TScheduledTaskInfo);
    function ParseCronExpression(const Expression: string; DateTime: TDateTime): TDateTime;
    procedure CheckAndExecuteTasks;
    procedure ExecuteTask(TaskID: Integer);
    procedure LogTaskExecution(TaskID: Integer; StartTime: TDateTime; Status: Integer;
      const ErrorMessage, Result: string);
    function GetTaskProcessor(const HandlerClass: string): ITaskProcessor;
  public
    constructor Create(const Context: IExecutionContext; const Connection: TFDConnection); reintroduce;
    destructor Destroy; override;

    procedure Start;
    procedure Stop;
    procedure Pause;
    procedure Resume;
    function IsRunning: Boolean;

    procedure ReloadTasks;
    function GetTasks: TArray<TScheduledTaskInfo>;
    function GetTaskByID(TaskID: Integer): TScheduledTaskInfo;
    procedure AddTask(const TaskInfo: TScheduledTaskInfo);
    procedure UpdateTask(const TaskInfo: TScheduledTaskInfo);
    procedure RemoveTask(TaskID: Integer);

    function GetTaskExecutionLogs(TaskID: Integer; Count: Integer): TArray<TTaskExecutionLogInfo>;
  end;

implementation

{ TUniScheduler }

constructor TUniScheduler.Create(const Context: IExecutionContext; const Connection: TFDConnection);
begin
  inherited Create;
  FContext := Context;
  FConnection := Connection;
  FTasks := TList<TScheduledTaskInfo>.Create;
  FRunningTasks := TDictionary<Integer, TThread>.Create;
  FCriticalSection := TCriticalSection.Create;
  FIsRunning := False;

  LoadTasks;
end;

destructor TUniScheduler.Destroy;
begin
  Stop;

  FTasks.Clear;
  FTasks.Free;
  FRunningTasks.Clear;
  FRunningTasks.Free;
  FCriticalSection.Free;

  inherited;
end;

procedure TUniScheduler.LoadTasks;
var
  LQuery: TFDQuery;
  LTaskInfo: TScheduledTaskInfo;
begin
  FCriticalSection.Acquire;
  try
    FTasks.Clear;

    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := FConnection;
      LQuery.SQL.Text :=
        'SELECT TaskID, TaskName, TaskCode, CronExpression, HandlerClass, Parameters, ' +
        'Description, Status, LastRunTime, NextRunTime, LastRunStatus, LastRunMessage, SortOrder ' +
        'FROM UniAdmin_ScheduledTasks ' +
        'WHERE Status = 1 ' +
        'ORDER BY SortOrder, TaskID';

      LQuery.Open;

      while not LQuery.Eof do
      begin
        LTaskInfo.TaskID := LQuery.FieldByName('TaskID').AsInteger;
        LTaskInfo.TaskName := LQuery.FieldByName('TaskName').AsString;
        LTaskInfo.TaskCode := LQuery.FieldByName('TaskCode').AsString;
        LTaskInfo.CronExpression := LQuery.FieldByName('CronExpression').AsString;
        LTaskInfo.HandlerClass := LQuery.FieldByName('HandlerClass').AsString;
        LTaskInfo.Parameters := LQuery.FieldByName('Parameters').AsString;
        LTaskInfo.Description := LQuery.FieldByName('Description').AsString;
        LTaskInfo.Status := tsStopped;
        LTaskInfo.LastRunTime := LQuery.FieldByName('LastRunTime').AsDateTime;
        LTaskInfo.NextRunTime := LQuery.FieldByName('NextRunTime').AsDateTime;
        LTaskInfo.LastRunStatus := LQuery.FieldByName('LastRunStatus').AsInteger;
        LTaskInfo.LastRunMessage := LQuery.FieldByName('LastRunMessage').AsString;
        LTaskInfo.SortOrder := LQuery.FieldByName('SortOrder').AsInteger;

        FTasks.Add(LTaskInfo);
        LQuery.Next;
      end;
    finally
      LQuery.Free;
    end;
  finally
    FCriticalSection.Release;
  end;
end;

procedure TUniScheduler.CalculateNextRunTime(var TaskInfo: TScheduledTaskInfo);
begin
  // 简化的 Cron 表达式解析
  // 支持格式: "0 * * * *" (分 时 日 月 周)
  TaskInfo.NextRunTime := ParseCronExpression(TaskInfo.CronExpression, Now);
end;

function TUniScheduler.ParseCronExpression(const Expression: string; DateTime: TDateTime): TDateTime;
var
  LParts: TArray<string>;
  LMinute, LHour: Integer;
  LNextTime: TDateTime;
begin
  // 简化实现 - 仅支持基本的分、时设置
  LParts := Expression.Split([' ']);

  if Length(LParts) >= 2 then
  begin
    LMinute := StrToIntDef(LParts[0], 0);
    LHour := StrToIntDef(LParts[1], 0);

    LNextTime := EncodeTime(LHour, LMinute, 0, 0);
    Result := DateOf(DateTime) + LNextTime;

    // 如果今天的时间已过，设置为明天
    if Result < DateTime then
      Result := Result + 1;
  end
  else
  begin
    Result := DateTime + EncodeTime(1, 0, 0, 0); // 默认1小时后
  end;
end;

procedure TUniScheduler.Start;
begin
  FCriticalSection.Acquire;
  try
    if FIsRunning then
      Exit;

    FIsRunning := True;

    // 创建定时器，每分钟检查一次
    FTimer := TTimer.Create(nil);
    FTimer.Interval := 60000; // 60秒
    FTimer.OnTimer := CheckAndExecuteTasks;
    FTimer.Enabled := True;
  finally
    FCriticalSection.Release;
  end;
end;

procedure TUniScheduler.Stop;
begin
  FCriticalSection.Acquire;
  try
    if not FIsRunning then
      Exit;

    FIsRunning := False;

    if Assigned(FTimer) then
    begin
      FTimer.Enabled := False;
      FTimer.Free;
      FTimer := nil;
    end;
  finally
    FCriticalSection.Release;
  end;
end;

procedure TUniScheduler.Pause;
begin
  FCriticalSection.Acquire;
  try
    if Assigned(FTimer) then
      FTimer.Enabled := False;
  finally
    FCriticalSection.Release;
  end;
end;

procedure TUniScheduler.Resume;
begin
  FCriticalSection.Acquire;
  try
    if Assigned(FTimer) then
      FTimer.Enabled := True;
  finally
    FCriticalSection.Release;
  end;
end;

function TUniScheduler.IsRunning: Boolean;
begin
  FCriticalSection.Acquire;
  try
    Result := FIsRunning;
  finally
    FCriticalSection.Release;
  end;
end;

procedure TUniScheduler.CheckAndExecuteTasks;
var
  LCurrentTime: TDateTime;
  LTaskInfo: TScheduledTaskInfo;
begin
  if not FIsRunning then
    Exit;

  LCurrentTime := Now;

  FCriticalSection.Acquire;
  try
    for LTaskInfo in FTasks do
    begin
      if (LTaskInfo.Status = tsStopped) and
         (LTaskInfo.NextRunTime > 0) and
         (LTaskInfo.NextRunTime <= LCurrentTime) then
      begin
        ExecuteTask(LTaskInfo.TaskID);
      end;
    end;
  finally
    FCriticalSection.Release;
  end;
end;

procedure TUniScheduler.ExecuteTask(TaskID: Integer);
var
  LTaskInfo: TScheduledTaskInfo;
  LProcessor: ITaskProcessor;
  LStartTime: TDateTime;
  LStatus: Integer;
  LErrorMsg, LResult: string;
  LQuery: TFDQuery;
begin
  FCriticalSection.Acquire;
  try
    // 查找任务
    for LTaskInfo in FTasks do
    begin
      if LTaskInfo.TaskID = TaskID then
      begin
        LTaskInfo.Status := tsRunning;
        Break;
      end;
    end;
  finally
    FCriticalSection.Release;
  end;

  LStartTime := Now;
  LStatus := 1; // 成功
  LErrorMsg := '';
  LResult := '';

  try
    LProcessor := GetTaskProcessor(LTaskInfo.HandlerClass);
    if Assigned(LProcessor) then
    begin
      LProcessor.Initialize(LTaskInfo.Parameters);
      LProcessor.Execute(FContext);
      LResult := '执行成功';
    end
    else
    begin
      LStatus := 0;
      LErrorMsg := '任务处理器不存在: ' + LTaskInfo.HandlerClass;
    end;
  except
    on E: Exception do
    begin
      LStatus := 0;
      LErrorMsg := E.Message;
    end;
  end;

  // 记录执行日志
  LogTaskExecution(TaskID, LStartTime, LStatus, LErrorMsg, LResult);

  // 更新任务状态
  FCriticalSection.Acquire;
  try
    for LTaskInfo in FTasks do
    begin
      if LTaskInfo.TaskID = TaskID then
      begin
        LTaskInfo.Status := tsStopped;
        LTaskInfo.LastRunTime := LStartTime;
        LTaskInfo.LastRunStatus := LStatus;
        LTaskInfo.LastRunMessage := Ifthen(LStatus = 1, LResult, LErrorMsg);
        CalculateNextRunTime(LTaskInfo);
        Break;
      end;
    end;
  finally
    FCriticalSection.Release;
  end;

  // 更新数据库
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'UPDATE UniAdmin_ScheduledTasks ' +
      'SET LastRunTime = :LastRunTime, NextRunTime = :NextRunTime, ' +
      'LastRunStatus = :LastRunStatus, LastRunMessage = :LastRunMessage ' +
      'WHERE TaskID = :TaskID';

    LQuery.Params.ParamByName('TaskID').AsInteger := TaskID;
    LQuery.Params.ParamByName('LastRunTime').AsDateTime := LStartTime;
    LQuery.Params.ParamByName('NextRunTime').AsDateTime := LTaskInfo.NextRunTime;
    LQuery.Params.ParamByName('LastRunStatus').AsInteger := LStatus;
    LQuery.Params.ParamByName('LastRunMessage').AsString := Ifthen(LStatus = 1, LResult, LErrorMsg);

    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

procedure TUniScheduler.LogTaskExecution(TaskID: Integer; StartTime: TDateTime;
  Status: Integer; const ErrorMessage, Result: string);
var
  LQuery: TFDQuery;
  LEndTime: TDateTime;
  LDuration: Integer;
begin
  LEndTime := Now;
  LDuration := MilliSecondsBetween(LEndTime, StartTime);

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'INSERT INTO UniAdmin_TaskExecutionLogs ' +
      '(TaskID, StartTime, EndTime, Status, ErrorMessage, Result, Duration) ' +
      'VALUES (:TaskID, :StartTime, :EndTime, :Status, :ErrorMessage, :Result, :Duration)';

    LQuery.Params.ParamByName('TaskID').AsInteger := TaskID;
    LQuery.Params.ParamByName('StartTime').AsDateTime := StartTime;
    LQuery.Params.ParamByName('EndTime').AsDateTime := LEndTime;
    LQuery.Params.ParamByName('Status').AsInteger := Status;
    LQuery.Params.ParamByName('ErrorMessage').AsString := ErrorMessage;
    LQuery.Params.ParamByName('Result').AsString := Result;
    LQuery.Params.ParamByName('Duration').AsInteger := LDuration;

    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

function TUniScheduler.GetTaskProcessor(const HandlerClass: string): ITaskProcessor;
begin
  // TODO: 实现任务处理器的动态加载
  // 这里需要通过类名动态创建处理器实例
  Result := nil;
end;

procedure TUniScheduler.ReloadTasks;
begin
  LoadTasks;
end;

function TUniScheduler.GetTasks: TArray<TScheduledTaskInfo>;
begin
  FCriticalSection.Acquire;
  try
    Result := FTasks.ToArray;
  finally
    FCriticalSection.Release;
  end;
end;

function TUniScheduler.GetTaskByID(TaskID: Integer): TScheduledTaskInfo;
var
  LTaskInfo: TScheduledTaskInfo;
begin
  Result := Default(TScheduledTaskInfo);

  FCriticalSection.Acquire;
  try
    for LTaskInfo in FTasks do
    begin
      if LTaskInfo.TaskID = TaskID then
      begin
        Result := LTaskInfo;
        Exit;
      end;
    end;
  finally
    FCriticalSection.Release;
  end;
end;

procedure TUniScheduler.AddTask(const TaskInfo: TScheduledTaskInfo);
begin
  FCriticalSection.Acquire;
  try
    FTasks.Add(TaskInfo);
  finally
    FCriticalSection.Release;
  end;
end;

procedure TUniScheduler.UpdateTask(const TaskInfo: TScheduledTaskInfo);
var
  I: Integer;
begin
  FCriticalSection.Acquire;
  try
    for I := 0 to FTasks.Count - 1 do
    begin
      if FTasks[I].TaskID = TaskInfo.TaskID then
      begin
        FTasks[I] := TaskInfo;
        Break;
      end;
    end;
  finally
    FCriticalSection.Release;
  end;
end;

procedure TUniScheduler.RemoveTask(TaskID: Integer);
var
  I: Integer;
begin
  FCriticalSection.Acquire;
  try
    for I := 0 to FTasks.Count - 1 do
    begin
      if FTasks[I].TaskID = TaskID then
      begin
        FTasks.Delete(I);
        Break;
      end;
    end;
  finally
    FCriticalSection.Release;
  end;
end;

function TUniScheduler.GetTaskExecutionLogs(TaskID: Integer; Count: Integer): TArray<TTaskExecutionLogInfo>;
var
  LQuery: TFDQuery;
  LList: TList<TTaskExecutionLogInfo>;
  LLogInfo: TTaskExecutionLogInfo;
begin
  LQuery := TFDQuery.Create(nil);
  LList := TList<TTaskExecutionLogInfo>.Create;
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT TOP ' + IntToStr(Count) + ' * FROM UniAdmin_TaskExecutionLogs ' +
      'WHERE TaskID = :TaskID ' +
      'ORDER BY StartTime DESC';

    LQuery.Params.ParamByName('TaskID').AsInteger := TaskID;
    LQuery.Open;

    while not LQuery.Eof do
    begin
      LLogInfo.LogID := LQuery.FieldByName('LogID').AsInteger;
      LLogInfo.TaskID := LQuery.FieldByName('TaskID').AsInteger;
      LLogInfo.StartTime := LQuery.FieldByName('StartTime').AsDateTime;
      LLogInfo.EndTime := LQuery.FieldByName('EndTime').AsDateTime;
      LLogInfo.Status := LQuery.FieldByName('Status').AsInteger;
      LLogInfo.ErrorMessage := LQuery.FieldByName('ErrorMessage').AsString;
      LLogInfo.Result := LQuery.FieldByName('Result').AsString;
      LLogInfo.Duration := LQuery.FieldByName('Duration').AsInteger;

      LList.Add(LLogInfo);
      LQuery.Next;
    end;

    Result := LList.ToArray;
  finally
    LQuery.Free;
    LList.Free;
  end;
end;

end.

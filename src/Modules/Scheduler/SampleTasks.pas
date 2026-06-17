unit SampleTasks;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, Data.DB, FireDAC.Comp.Client,
  UniContext, UniPlugin.Types, UniScheduler, UniTaskProcessor;

type
  /// <summary>
  /// 清理临时文件任务处理器
  /// </summary>
  TTempFileCleanupTask = class(TTaskProcessorBase)
  protected
    function GetProcessorName: string; override;
    function GetProcessorDescription: string; override;
    procedure DoInitialize; override;
    procedure DoExecute(const Context: IExecutionContext); override;
  end;

  /// <summary>
  /// 清理过期日志任务处理器
  /// </summary>
  TLogCleanupTask = class(TTaskProcessorBase)
  protected
    function GetProcessorName: string; override;
    function GetProcessorDescription: string; override;
    procedure DoInitialize; override;
    procedure DoExecute(const Context: IExecutionContext); override;
  end;

  /// <summary>
  /// 数据库备份任务处理器
  /// </summary>
  TDatabaseBackupTask = class(TTaskProcessorBase)
  protected
    function GetProcessorName: string; override;
    function GetProcessorDescription: string; override;
    procedure DoInitialize; override;
    procedure DoExecute(const Context: IExecutionContext); override;
  end;

  /// <summary>
  /// 系统健康检查任务处理器
  /// </summary>
  TSystemHealthCheckTask = class(TTaskProcessorBase)
  protected
    function GetProcessorName: string; override;
    function GetProcessorDescription: string; override;
    procedure DoInitialize; override;
    procedure DoExecute(const Context: IExecutionContext); override;
  end;

  /// <summary>
  /// 示例任务注册类
  /// </summary>
  TSampleTasksRegister = class(TObject)
  public
    class procedure Register;
  end;

implementation

{ TTempFileCleanupTask }

function TTempFileCleanupTask.GetProcessorName: string;
begin
  Result := 'TempFileCleanup';
end;

function TTempFileCleanupTask.GetProcessorDescription: string;
begin
  Result := '清理系统临时文件';
end;

procedure TTempFileCleanupTask.DoInitialize;
begin
  inherited;
  // 解析参数：保留天数
  // 参数格式: "days=7"
end;

procedure TTempFileCleanupTask.DoExecute(const Context: IExecutionContext);
var
  LTempPath: string;
  LFiles: TArray<string>;
  LFile: string;
  LDays: Integer;
  LDeleteDate: TDateTime;
begin
  // 默认保留7天
  LDays := 7;

  // 从参数中解析天数
  if Parameters.Contains('days=') then
  begin
    LDays := StrToIntDef(
      Parameters.Substring(Parameters.IndexOf('days=') + 5).Split(['=', ';'])[0],
      7
    );
  end;

  LDeleteDate := Now - LDays;
  LTempPath := TPath.GetTempPath;

  // 清理临时文件
  if TDirectory.Exists(LTempPath) then
  begin
    LFiles := TDirectory.GetFiles(LTempPath, '*.*', TSearchOption.soAllDirectories);
    for LFile in LFiles do
    begin
      try
        if TFile.GetCreationTime(LFile) < LDeleteDate then
          TFile.Delete(LFile);
      except
        // 忽略删除失败的文件
      end;
    end;
  end;
end;

{ TLogCleanupTask }

function TLogCleanupTask.GetProcessorName: string;
begin
  Result := 'LogCleanup';
end;

function TLogCleanupTask.GetProcessorDescription: string;
begin
  Result := '清理过期系统日志';
end;

procedure TLogCleanupTask.DoInitialize;
begin
  inherited;
  // 解析参数：保留天数
end;

procedure TLogCleanupTask.DoExecute(const Context: IExecutionContext);
var
  LDays: Integer;
  LQuery: TFDQuery;
  LConnection: TFDConnection;
begin
  // 默认保留30天
  LDays := 30;

  if Parameters.Contains('days=') then
  begin
    LDays := StrToIntDef(
      Parameters.Substring(Parameters.IndexOf('days=') + 5).Split(['=', ';'])[0],
      30
    );
  end;

  // 清理过期的数据库日志记录
  if Assigned(Context) and (Context.GetDatabaseConfig <> nil) then
  begin
    LConnection := TFDConnection.Create(nil);
    try
      LConnection.Params.Values['Server'] := Context.GetDatabaseConfig.GetServerName;
      LConnection.Params.Values['Database'] := Context.GetDatabaseConfig.GetDatabaseName;
      LConnection.LoginPrompt := False;
      LConnection.Connected := True;

      LQuery := TFDQuery.Create(nil);
      try
        LQuery.Connection := LConnection;
        LQuery.SQL.Text :=
          'DELETE FROM UniAdmin_LoginLogs WHERE LoginTime < :BeforeDate;' +
          'DELETE FROM UniAdmin_OperationLogs WHERE CreatedDate < :BeforeDate;' +
          'DELETE FROM UniAdmin_DataChangeLogs WHERE CreatedDate < :BeforeDate';
        LQuery.Params.ParamByName('BeforeDate').AsDateTime := Now - LDays;
        LQuery.ExecSQL;
      finally
        LQuery.Free;
      end;
    finally
      LConnection.Connected := False;
      LConnection.Free;
    end;
  end;
end;

{ TDatabaseBackupTask }

function TDatabaseBackupTask.GetProcessorName: string;
begin
  Result := 'DatabaseBackup';
end;

function TDatabaseBackupTask.GetProcessorDescription: string;
begin
  Result := '数据库备份';
end;

procedure TDatabaseBackupTask.DoInitialize;
begin
  inherited;
  // 解析参数：备份路径、压缩等
end;

procedure TDatabaseBackupTask.DoExecute(const Context: IExecutionContext);
var
  LBackupPath: string;
  LFileName: string;
  LFullFileName: string;
  LQuery: TFDQuery;
  LConnection: TFDConnection;
  LDbName: string;
begin
  // 默认备份路径
  LBackupPath := 'C:\Backup\UniAdmin';

  if Parameters.Contains('path=') then
  begin
    LBackupPath := Parameters.Substring(Parameters.IndexOf('path=') + 5).Split(['=', ';'])[0];
  end;

  // 确保备份目录存在
  if not TDirectory.Exists(LBackupPath) then
    TDirectory.CreateDirectory(LBackupPath);

  // 生成备份文件名
  LFileName := Format('UniAdmin_Backup_%s.bak', [FormatDateTime('yyyymmdd_hhnnss', Now)]);
  LFullFileName := LBackupPath + '\' + LFileName;

  // 执行 SQL Server 数据库备份
  if Assigned(Context) and (Context.GetDatabaseConfig <> nil) then
  begin
    LDbName := Context.GetDatabaseConfig.GetDatabaseName;
    if LDbName = '' then
      LDbName := 'UniAdmin';

    LConnection := TFDConnection.Create(nil);
    try
      LConnection.Params.Values['Server'] := Context.GetDatabaseConfig.GetServerName;
      LConnection.Params.Values['Database'] := 'master'; // 备份需要连接 master
      LConnection.LoginPrompt := False;
      LConnection.Connected := True;

      LQuery := TFDQuery.Create(nil);
      try
        LQuery.Connection := LConnection;
        LQuery.SQL.Text := Format(
          'BACKUP DATABASE [%s] TO DISK = ''%s'' WITH FORMAT, INIT, ' +
          'NAME = ''UniAdmin-Full Backup'', SKIP, NOREWIND, NOUNLOAD, STATS = 10',
          [LDbName, LFullFileName]);
        LQuery.ExecSQL;
      finally
        LQuery.Free;
      end;
    finally
      LConnection.Connected := False;
      LConnection.Free;
    end;
  end;
end;

{ TSystemHealthCheckTask }

function TSystemHealthCheckTask.GetProcessorName: string;
begin
  Result := 'SystemHealthCheck';
end;

function TSystemHealthCheckTask.GetProcessorDescription: string;
begin
  Result := '系统健康检查';
end;

procedure TSystemHealthCheckTask.DoInitialize;
begin
  inherited;
  // 解析参数：检查项目
end;

procedure TSystemHealthCheckTask.DoExecute(const Context: IExecutionContext);
var
  LHealthStatus: string;
  LIssues: TStringList;
  LQuery: TFDQuery;
  LConnection: TFDConnection;
  LDbConnected: Boolean;
begin
  LIssues := TStringList.Create;
  try
    // 检查数据库连接
    LDbConnected := False;
    if Assigned(Context) and (Context.GetDatabaseConfig <> nil) then
    begin
      LConnection := TFDConnection.Create(nil);
      try
        LConnection.Params.Values['Server'] := Context.GetDatabaseConfig.GetServerName;
        LConnection.Params.Values['Database'] := Context.GetDatabaseConfig.GetDatabaseName;
        LConnection.LoginPrompt := False;
        try
          LConnection.Connected := True;
          LDbConnected := True;

          // 检查数据库文件大小
          LQuery := TFDQuery.Create(nil);
          try
            LQuery.Connection := LConnection;
            LQuery.SQL.Text :=
              'SELECT TOP 1 size * 8 / 1024 AS SizeMB FROM sys.master_files ' +
              'WHERE database_id = DB_ID() AND type = 0';
            try
              LQuery.Open;
              if not LQuery.Eof then
              begin
                if LQuery.FieldByName('SizeMB').AsInteger > 1024 * 10 then // 超过10GB
                  LIssues.Add('数据库文件过大: ' +
                    IntToStr(LQuery.FieldByName('SizeMB').AsInteger div 1024) + ' GB');
              end;
            except
              // 忽略检查失败
            end;
          finally
            LQuery.Free;
          end;
        except
          LIssues.Add('数据库连接失败');
        end;
      finally
        LConnection.Connected := False;
        LConnection.Free;
      end;
    end
    else
      LIssues.Add('无法获取数据库配置');

    // 检查临时目录磁盘空间
    try
      var LTempPath := TPath.GetTempPath;
      // 简单检查临时目录是否可写
      var LTestFile := TPath.Combine(LTempPath, 'health_check_test.tmp');
      TFile.WriteAllText(LTestFile, 'test');
      TFile.Delete(LTestFile);
    except
      LIssues.Add('临时目录不可写');
    end;

    // 记录检查结果
    if LIssues.Count = 0 then
      LHealthStatus := '系统健康 - 数据库连接正常'
    else
      LHealthStatus := '发现问题: ' + string.Join('; ', LIssues.ToStringArray);

    // 记录健康检查结果到日志
    if Assigned(Context) and LDbConnected then
    begin
      LConnection := TFDConnection.Create(nil);
      try
        LConnection.Params.Values['Server'] := Context.GetDatabaseConfig.GetServerName;
        LConnection.Params.Values['Database'] := Context.GetDatabaseConfig.GetDatabaseName;
        LConnection.LoginPrompt := False;
        LConnection.Connected := True;

        LQuery := TFDQuery.Create(nil);
        try
          LQuery.Connection := LConnection;
          LQuery.SQL.Text :=
            'INSERT INTO UniAdmin_OperationLogs ' +
            '(UserID, UserName, Module, Operation, Description, Status, CreatedDate) ' +
            'VALUES (0, ''System'', ''HealthCheck'', ''Check'', :Result, 1, GETDATE())';
          LQuery.Params.ParamByName('Result').AsString := LHealthStatus;
          LQuery.ExecSQL;
        finally
          LQuery.Free;
        end;
      finally
        LConnection.Connected := False;
        LConnection.Free;
      end;
    end;
  finally
    LIssues.Free;
  end;
end;

{ TSampleTasksRegister }

class procedure TSampleTasksRegister.Register;
begin
  // 注册示例任务到工厂
  TTaskProcessorFactory.RegisterProcessor('TempFileCleanup', TTempFileCleanupTask);
  TTaskProcessorFactory.RegisterProcessor('LogCleanup', TLogCleanupTask);
  TTaskProcessorFactory.RegisterProcessor('DatabaseBackup', TDatabaseBackupTask);
  TTaskProcessorFactory.RegisterProcessor('SystemHealthCheck', TSystemHealthCheckTask);
end;

initialization
  // 自动注册示例任务
  TSampleTasksRegister.Register;

end.

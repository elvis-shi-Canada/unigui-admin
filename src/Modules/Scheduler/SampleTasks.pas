unit SampleTasks;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils,
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

  // TODO: 调用日志服务的清理方法
  // TLogService.CleanOldLogs(LDays);
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

  // TODO: 执行数据库备份
  // 1. 使用数据库连接执行备份命令
  // 2. 或调用外部备份工具
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
begin
  LIssues := TStringList.Create;
  try
    // 检查磁盘空间
    // if GetDiskFreeSpace < 1024 * 1024 * 1024 then // 小于1GB
    //   LIssues.Add('磁盘空间不足');

    // 检查数据库连接
    // if not TestDatabaseConnection then
    //   LIssues.Add('数据库连接异常');

    // 检查内存使用
    // if GetMemoryUsage > 80 then
    //   LIssues.Add('内存使用率过高');

    // 记录检查结果
    if LIssues.Count = 0 then
      LHealthStatus := '系统健康'
    else
      LHealthStatus := '发现问题: ' + string.Join('; ', LIssues.ToStringArray);

    // TODO: 记录到日志或发送告警
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

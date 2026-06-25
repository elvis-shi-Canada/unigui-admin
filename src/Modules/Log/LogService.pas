unit LogService;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Generics.Collections,
  Data.DB, FireDAC.Comp.Client,
  UniContext, UniPlugin.Types, LogDataModule, MainModule;

type
  /// <summary>
  /// 日志服务类 - 日志业务逻辑实现
  /// </summary>
  TLogService = class(TInterfacedObject)
  private
    FContext: IExecutionContext;
    FDataModule: TLogDataModule;

    procedure InitializeDataModule;
    procedure FinalizeDataModule;
  public
    constructor Create(const Context: IExecutionContext); reintroduce;
    destructor Destroy; override;

    // 登录日志
    procedure LogLogin(UserID: Integer; const UserName, IP, UserAgent: string;
      Status: Integer; const FailReason: string = '');
    procedure LogLogout(UserID: Integer; const UserName: string);
    function GetLoginLogs(const UserName, IP: string; StartTime, EndTime: TDateTime;
      Status: Integer; Page, PageSize: Integer): TDataSet;
    function GetLoginLogCount(const UserName, IP: string; StartTime, EndTime: TDateTime;
      Status: Integer): Integer;

    // 操作日志
    procedure LogOperation(UserID: Integer; const UserName, Module, Operation,
      Description: string; const RequestData, ResponseData: string;
      const IP, UserAgent: string; Duration: Integer; Status: Integer);
    function GetOperationLogs(const UserName, Module: string; StartTime, EndTime: TDateTime;
      Status: Integer; Page, PageSize: Integer): TDataSet;
    function GetOperationLogCount(const UserName, Module: string; StartTime, EndTime: TDateTime;
      Status: Integer): Integer;

    // 数据变更日志
    procedure LogDataChange(UserID: Integer; const UserName, TableName: string;
      RecordID: Integer; const Operation: string; const OldValue, NewValue: string);
    function GetDataChangeLogs(const UserName, TableName: string; StartTime, EndTime: TDateTime;
      Page, PageSize: Integer): TDataSet;
    function GetDataChangeLogCount(const UserName, TableName: string; StartTime,
      EndTime: TDateTime): Integer;

    // 日志清理
    procedure CleanOldLogs(Days: Integer);
  end;

implementation

{ TLogService }

constructor TLogService.Create(const Context: IExecutionContext);
begin
  inherited Create;
  FContext := Context;
  InitializeDataModule;
end;

destructor TLogService.Destroy;
begin
  FinalizeDataModule;
  inherited;
end;

procedure TLogService.InitializeDataModule;
begin
  FDataModule := TLogDataModule.CreateWithConnection(nil, GetMainModule.Connection);
  if Supports(FDataModule, IContextAware) then
    (FDataModule as IContextAware).SetContext(FContext);
  FDataModule.Open;
end;

procedure TLogService.FinalizeDataModule;
begin
  if Assigned(FDataModule) then
  begin
    FDataModule.Close;
    FDataModule.Free;
  end;
end;

procedure TLogService.LogLogin(UserID: Integer; const UserName, IP, UserAgent: string;
  Status: Integer; const FailReason: string);
begin
  FDataModule.AddLoginLog(UserID, UserName, IP, UserAgent, Status, FailReason);
end;

procedure TLogService.LogLogout(UserID: Integer; const UserName: string);
var
  LQuery: TFDQuery;
begin
  // 查找最近的登录记录并更新登出时间
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FDataModule.Connection;
    LQuery.SQL.Text :=
      'SELECT LogID FROM UniAdmin_LoginLogs ' +
      'WHERE UserID = :UserID AND Status = 1 ' +
      'ORDER BY LogID DESC LIMIT 1';

    LQuery.Params.ParamByName('UserID').AsInteger := UserID;
    LQuery.Open;

    if not LQuery.Eof then
      FDataModule.UpdateLogoutTime(LQuery.FieldByName('LogID').AsInteger);
  finally
    LQuery.Free;
  end;
end;

function TLogService.GetLoginLogs(const UserName, IP: string; StartTime, EndTime: TDateTime;
  Status: Integer; Page, PageSize: Integer): TDataSet;
begin
  Result := FDataModule.GetLoginLogs(UserName, IP, StartTime, EndTime, Status, Page, PageSize);
end;

function TLogService.GetLoginLogCount(const UserName, IP: string; StartTime, EndTime: TDateTime;
  Status: Integer): Integer;
begin
  Result := FDataModule.GetLoginLogCount(UserName, IP, StartTime, EndTime, Status);
end;

procedure TLogService.LogOperation(UserID: Integer; const UserName, Module, Operation,
  Description: string; const RequestData, ResponseData: string; const IP, UserAgent: string;
  Duration: Integer; Status: Integer);
begin
  FDataModule.AddOperationLog(UserID, UserName, Module, Operation, Description,
    RequestData, ResponseData, IP, UserAgent, Duration, Status);
end;

function TLogService.GetOperationLogs(const UserName, Module: string; StartTime,
  EndTime: TDateTime; Status: Integer; Page, PageSize: Integer): TDataSet;
begin
  Result := FDataModule.GetOperationLogs(UserName, Module, StartTime, EndTime, Status, Page, PageSize);
end;

function TLogService.GetOperationLogCount(const UserName, Module: string; StartTime,
  EndTime: TDateTime; Status: Integer): Integer;
begin
  Result := FDataModule.GetOperationLogCount(UserName, Module, StartTime, EndTime, Status);
end;

procedure TLogService.LogDataChange(UserID: Integer; const UserName, TableName: string;
  RecordID: Integer; const Operation: string; const OldValue, NewValue: string);
var
  LIP: string;
begin
  LIP := '';
  // IP 地址需要从 HTTP 请求上下文中获取，在 UniGUI 中通过 UniApplication.RemoteAddr 访问
  FDataModule.AddDataChangeLog(UserID, UserName, TableName, RecordID, Operation, OldValue, NewValue, LIP);
end;

function TLogService.GetDataChangeLogs(const UserName, TableName: string; StartTime,
  EndTime: TDateTime; Page, PageSize: Integer): TDataSet;
begin
  Result := FDataModule.GetDataChangeLogs(UserName, TableName, StartTime, EndTime, Page, PageSize);
end;

function TLogService.GetDataChangeLogCount(const UserName, TableName: string; StartTime,
  EndTime: TDateTime): Integer;
begin
  Result := FDataModule.GetDataChangeLogCount(UserName, TableName, StartTime, EndTime);
end;

procedure TLogService.CleanOldLogs(Days: Integer);
var
  LBeforeDate: TDateTime;
begin
  LBeforeDate := Now - Days;

  FDataModule.DeleteLoginLogs(LBeforeDate);
  FDataModule.DeleteOperationLogs(LBeforeDate);
  FDataModule.DeleteDataChangeLogs(LBeforeDate);
end;

end.

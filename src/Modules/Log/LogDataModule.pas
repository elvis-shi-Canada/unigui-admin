unit LogDataModule;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Generics.Collections,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Stan.Param,
  UniContext, UniPlugin.Types, UniDataModule;

type
  /// <summary>
  /// 登录日志记录
  /// </summary>
  TLoginLogInfo = record
    LogID: Integer;
    UserID: Integer;
    UserName: string;
    LoginIP: string;
    LoginTime: TDateTime;
    LogoutTime: TDateTime;
    Status: Integer;
    StatusText: string;
    UserAgent: string;
    FailReason: string;
  end;

  /// <summary>
  /// 操作日志记录
  /// </summary>
  TOperationLogInfo = record
    LogID: Integer;
    UserID: Integer;
    UserName: string;
    Module: string;
    Operation: string;
    Description: string;
    RequestData: string;
    ResponseData: string;
    IP: string;
    UserAgent: string;
    Duration: Integer;
    Status: Integer;
    StatusText: string;
    CreatedDate: TDateTime;
  end;

  /// <summary>
  /// 数据变更日志记录
  /// </summary>
  TDataChangeLogInfo = record
    LogID: Integer;
    UserID: Integer;
    UserName: string;
    TableName: string;
    RecordID: Integer;
    Operation: string;
    OperationText: string;
    OldValue: string;
    NewValue: string;
    IP: string;
    CreatedDate: TDateTime;
  end;

  /// <summary>
  /// 日志审计数据模块 - 提供日志的记录和查询操作
  /// </summary>
  TLogDataModule = class(TUniDataModule)
  public
    // 登录日志操作
    function GetLoginLogs(const UserName, IP: string; StartTime, EndTime: TDateTime;
      Status: Integer; Page, PageSize: Integer): TDataSet;
    function GetLoginLogCount(const UserName, IP: string; StartTime, EndTime: TDateTime;
      Status: Integer): Integer;
    procedure AddLoginLog(UserID: Integer; const UserName, IP, UserAgent: string;
      Status: Integer; const FailReason: string = '');
    procedure UpdateLogoutTime(LogID: Integer);

    // 操作日志操作
    function GetOperationLogs(const UserName, Module: string; StartTime, EndTime: TDateTime;
      Status: Integer; Page, PageSize: Integer): TDataSet;
    function GetOperationLogCount(const UserName, Module: string; StartTime, EndTime: TDateTime;
      Status: Integer): Integer;
    procedure AddOperationLog(UserID: Integer; const UserName, Module, Operation,
      Description, RequestData, ResponseData, IP, UserAgent: string; Duration: Integer;
      Status: Integer);

    // 数据变更日志操作
    function GetDataChangeLogs(const UserName, TableName: string; StartTime, EndTime: TDateTime;
      Page, PageSize: Integer): TDataSet;
    function GetDataChangeLogCount(const UserName, TableName: string; StartTime,
      EndTime: TDateTime): Integer;
    procedure AddDataChangeLog(UserID: Integer; const UserName, TableName: string;
      RecordID: Integer; const Operation: string; const OldValue, NewValue, IP: string);

    // 日志清理
    procedure DeleteLoginLogs(BeforeDate: TDateTime);
    procedure DeleteOperationLogs(BeforeDate: TDateTime);
    procedure DeleteDataChangeLogs(BeforeDate: TDateTime);
  end;

implementation

{ TLogDataModule }

function TLogDataModule.GetLoginLogs(const UserName, IP: string; StartTime, EndTime: TDateTime;
  Status: Integer; Page, PageSize: Integer): TDataSet;
var
  LQuery: TFDQuery;
  LSQL: string;
  LWhere: string;
  LWhereList: TStringList;
  LOffset: Integer;
begin
  LQuery := TFDQuery.Create(nil);
  LWhereList := TStringList.Create;
  try
    LQuery.Connection := Connection;

    LSQL := 'SELECT * FROM UniAdmin_LoginLogs';

    if UserName <> '' then
      LWhereList.Add('UserName LIKE :UserName');

    if IP <> '' then
      LWhereList.Add('LoginIP LIKE :IP');

    if StartTime > 0 then
      LWhereList.Add('LoginTime >= :StartTime');

    if EndTime > 0 then
      LWhereList.Add('LoginTime <= :EndTime');

    if Status >= 0 then
      LWhereList.Add('Status = :Status');

    if LWhereList.Count > 0 then
    begin
      LWhere := ' WHERE ' + LWhereList.Text.Replace(#13#10, ' AND ');
      LSQL := LSQL + LWhere;
    end;

    LSQL := LSQL + ' ORDER BY LoginTime DESC';

    // 分页
    if PageSize > 0 then
    begin
      LOffset := (Page - 1) * PageSize;
      LSQL := LSQL + ' LIMIT ' + IntToStr(PageSize) + ' OFFSET ' +
               IntToStr(LOffset);
    end;

    LQuery.SQL.Text := LSQL;

    if UserName <> '' then
      LQuery.Params.ParamByName('UserName').AsString := '%' + UserName + '%';

    if IP <> '' then
      LQuery.Params.ParamByName('IP').AsString := '%' + IP + '%';

    if StartTime > 0 then
      LQuery.Params.ParamByName('StartTime').AsDateTime := StartTime;

    if EndTime > 0 then
      LQuery.Params.ParamByName('EndTime').AsDateTime := EndTime;

    if Status >= 0 then
      LQuery.Params.ParamByName('Status').AsInteger := Status;

    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    LWhereList.Free;
    raise;
  end;
  LWhereList.Free;
end;

function TLogDataModule.GetLoginLogCount(const UserName, IP: string; StartTime,
  EndTime: TDateTime; Status: Integer): Integer;
var
  LQuery: TFDQuery;
  LSQL: string;
  LWhere: string;
  LWhereList: TStringList;
begin
  LQuery := TFDQuery.Create(nil);
  LWhereList := TStringList.Create;
  try
    LQuery.Connection := Connection;

    LSQL := 'SELECT COUNT(*) AS Cnt FROM UniAdmin_LoginLogs';

    if UserName <> '' then
      LWhereList.Add('UserName LIKE :UserName');

    if IP <> '' then
      LWhereList.Add('LoginIP LIKE :IP');

    if StartTime > 0 then
      LWhereList.Add('LoginTime >= :StartTime');

    if EndTime > 0 then
      LWhereList.Add('LoginTime <= :EndTime');

    if Status >= 0 then
      LWhereList.Add('Status = :Status');

    if LWhereList.Count > 0 then
    begin
      LWhere := ' WHERE ' + LWhereList.Text.Replace(#13#10, ' AND ');
      LSQL := LSQL + LWhere;
    end;

    LQuery.SQL.Text := LSQL;

    if UserName <> '' then
      LQuery.Params.ParamByName('UserName').AsString := '%' + UserName + '%';

    if IP <> '' then
      LQuery.Params.ParamByName('IP').AsString := '%' + IP + '%';

    if StartTime > 0 then
      LQuery.Params.ParamByName('StartTime').AsDateTime := StartTime;

    if EndTime > 0 then
      LQuery.Params.ParamByName('EndTime').AsDateTime := EndTime;

    if Status >= 0 then
      LQuery.Params.ParamByName('Status').AsInteger := Status;

    LQuery.Open;
    Result := LQuery.FieldByName('Cnt').AsInteger;
  finally
    LQuery.Free;
    LWhereList.Free;
  end;
end;

procedure TLogDataModule.AddLoginLog(UserID: Integer; const UserName, IP, UserAgent: string;
  Status: Integer; const FailReason: string);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'INSERT INTO UniAdmin_LoginLogs ' +
      '(UserID, UserName, LoginIP, LoginTime, Status, UserAgent, FailReason) ' +
      'VALUES (:UserID, :UserName, :IP, CURRENT_TIMESTAMP, :Status, :UserAgent, :FailReason)';

    LQuery.Params.ParamByName('UserID').AsInteger := UserID;
    LQuery.Params.ParamByName('UserName').AsString := UserName;
    LQuery.Params.ParamByName('IP').AsString := IP;
    LQuery.Params.ParamByName('Status').AsInteger := Status;
    LQuery.Params.ParamByName('UserAgent').AsString := UserAgent;
    LQuery.Params.ParamByName('FailReason').AsString := FailReason;

    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

procedure TLogDataModule.UpdateLogoutTime(LogID: Integer);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'UPDATE UniAdmin_LoginLogs ' +
      'SET LogoutTime = CURRENT_TIMESTAMP ' +
      'WHERE LogID = :LogID';

    LQuery.Params.ParamByName('LogID').AsInteger := LogID;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

function TLogDataModule.GetOperationLogs(const UserName, Module: string; StartTime,
  EndTime: TDateTime; Status: Integer; Page, PageSize: Integer): TDataSet;
var
  LQuery: TFDQuery;
  LSQL: string;
  LWhere: string;
  LWhereList: TStringList;
  LOffset: Integer;
begin
  LQuery := TFDQuery.Create(nil);
  LWhereList := TStringList.Create;
  try
    LQuery.Connection := Connection;

    LSQL := 'SELECT * FROM UniAdmin_OperationLogs';

    if UserName <> '' then
      LWhereList.Add('UserName LIKE :UserName');

    if Module <> '' then
      LWhereList.Add('Module LIKE :Module');

    if StartTime > 0 then
      LWhereList.Add('CreatedDate >= :StartTime');

    if EndTime > 0 then
      LWhereList.Add('CreatedDate <= :EndTime');

    if Status >= 0 then
      LWhereList.Add('Status = :Status');

    if LWhereList.Count > 0 then
    begin
      LWhere := ' WHERE ' + LWhereList.Text.Replace(#13#10, ' AND ');
      LSQL := LSQL + LWhere;
    end;

    LSQL := LSQL + ' ORDER BY CreatedDate DESC';

    if PageSize > 0 then
    begin
      LOffset := (Page - 1) * PageSize;
      LSQL := LSQL + ' LIMIT ' + IntToStr(PageSize) + ' OFFSET ' +
               IntToStr(LOffset);
    end;

    LQuery.SQL.Text := LSQL;

    if UserName <> '' then
      LQuery.Params.ParamByName('UserName').AsString := '%' + UserName + '%';

    if Module <> '' then
      LQuery.Params.ParamByName('Module').AsString := '%' + Module + '%';

    if StartTime > 0 then
      LQuery.Params.ParamByName('StartTime').AsDateTime := StartTime;

    if EndTime > 0 then
      LQuery.Params.ParamByName('EndTime').AsDateTime := EndTime;

    if Status >= 0 then
      LQuery.Params.ParamByName('Status').AsInteger := Status;

    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    LWhereList.Free;
    raise;
  end;
  LWhereList.Free;
end;

function TLogDataModule.GetOperationLogCount(const UserName, Module: string; StartTime,
  EndTime: TDateTime; Status: Integer): Integer;
var
  LQuery: TFDQuery;
  LSQL: string;
  LWhere: string;
  LWhereList: TStringList;
begin
  LQuery := TFDQuery.Create(nil);
  LWhereList := TStringList.Create;
  try
    LQuery.Connection := Connection;

    LSQL := 'SELECT COUNT(*) AS Cnt FROM UniAdmin_OperationLogs';

    if UserName <> '' then
      LWhereList.Add('UserName LIKE :UserName');

    if Module <> '' then
      LWhereList.Add('Module LIKE :Module');

    if StartTime > 0 then
      LWhereList.Add('CreatedDate >= :StartTime');

    if EndTime > 0 then
      LWhereList.Add('CreatedDate <= :EndTime');

    if Status >= 0 then
      LWhereList.Add('Status = :Status');

    if LWhereList.Count > 0 then
    begin
      LWhere := ' WHERE ' + LWhereList.Text.Replace(#13#10, ' AND ');
      LSQL := LSQL + LWhere;
    end;

    LQuery.SQL.Text := LSQL;

    if UserName <> '' then
      LQuery.Params.ParamByName('UserName').AsString := '%' + UserName + '%';

    if Module <> '' then
      LQuery.Params.ParamByName('Module').AsString := '%' + Module + '%';

    if StartTime > 0 then
      LQuery.Params.ParamByName('StartTime').AsDateTime := StartTime;

    if EndTime > 0 then
      LQuery.Params.ParamByName('EndTime').AsDateTime := EndTime;

    if Status >= 0 then
      LQuery.Params.ParamByName('Status').AsInteger := Status;

    LQuery.Open;
    Result := LQuery.FieldByName('Cnt').AsInteger;
  finally
    LQuery.Free;
    LWhereList.Free;
  end;
end;

procedure TLogDataModule.AddOperationLog(UserID: Integer; const UserName, Module, Operation,
  Description, RequestData, ResponseData, IP, UserAgent: string; Duration: Integer; Status: Integer);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'INSERT INTO UniAdmin_OperationLogs ' +
      '(UserID, UserName, Module, Operation, Description, RequestData, ResponseData, ' +
      'IP, UserAgent, Duration, Status, CreatedDate) ' +
      'VALUES (:UserID, :UserName, :Module, :Operation, :Description, :RequestData, ' +
      ':ResponseData, :IP, :UserAgent, :Duration, :Status, CURRENT_TIMESTAMP)';

    LQuery.Params.ParamByName('UserID').AsInteger := UserID;
    LQuery.Params.ParamByName('UserName').AsString := UserName;
    LQuery.Params.ParamByName('Module').AsString := Module;
    LQuery.Params.ParamByName('Operation').AsString := Operation;
    LQuery.Params.ParamByName('Description').AsString := Description;
    LQuery.Params.ParamByName('RequestData').AsString := RequestData;
    LQuery.Params.ParamByName('ResponseData').AsString := ResponseData;
    LQuery.Params.ParamByName('IP').AsString := IP;
    LQuery.Params.ParamByName('UserAgent').AsString := UserAgent;
    LQuery.Params.ParamByName('Duration').AsInteger := Duration;
    LQuery.Params.ParamByName('Status').AsInteger := Status;

    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

function TLogDataModule.GetDataChangeLogs(const UserName, TableName: string; StartTime,
  EndTime: TDateTime; Page, PageSize: Integer): TDataSet;
var
  LQuery: TFDQuery;
  LSQL: string;
  LWhere: string;
  LWhereList: TStringList;
  LOffset: Integer;
begin
  LQuery := TFDQuery.Create(nil);
  LWhereList := TStringList.Create;
  try
    LQuery.Connection := Connection;

    LSQL := 'SELECT * FROM UniAdmin_DataChangeLogs';

    if UserName <> '' then
      LWhereList.Add('UserName LIKE :UserName');

    if TableName <> '' then
      LWhereList.Add('TableName LIKE :TableName');

    if StartTime > 0 then
      LWhereList.Add('CreatedDate >= :StartTime');

    if EndTime > 0 then
      LWhereList.Add('CreatedDate <= :EndTime');

    if LWhereList.Count > 0 then
    begin
      LWhere := ' WHERE ' + LWhereList.Text.Replace(#13#10, ' AND ');
      LSQL := LSQL + LWhere;
    end;

    LSQL := LSQL + ' ORDER BY CreatedDate DESC';

    if PageSize > 0 then
    begin
      LOffset := (Page - 1) * PageSize;
      LSQL := LSQL + ' LIMIT ' + IntToStr(PageSize) + ' OFFSET ' +
               IntToStr(LOffset);
    end;

    LQuery.SQL.Text := LSQL;

    if UserName <> '' then
      LQuery.Params.ParamByName('UserName').AsString := '%' + UserName + '%';

    if TableName <> '' then
      LQuery.Params.ParamByName('TableName').AsString := '%' + TableName + '%';

    if StartTime > 0 then
      LQuery.Params.ParamByName('StartTime').AsDateTime := StartTime;

    if EndTime > 0 then
      LQuery.Params.ParamByName('EndTime').AsDateTime := EndTime;

    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    LWhereList.Free;
    raise;
  end;
  LWhereList.Free;
end;

function TLogDataModule.GetDataChangeLogCount(const UserName, TableName: string; StartTime,
  EndTime: TDateTime): Integer;
var
  LQuery: TFDQuery;
  LSQL: string;
  LWhere: string;
  LWhereList: TStringList;
begin
  LQuery := TFDQuery.Create(nil);
  LWhereList := TStringList.Create;
  try
    LQuery.Connection := Connection;

    LSQL := 'SELECT COUNT(*) AS Cnt FROM UniAdmin_DataChangeLogs';

    if UserName <> '' then
      LWhereList.Add('UserName LIKE :UserName');

    if TableName <> '' then
      LWhereList.Add('TableName LIKE :TableName');

    if StartTime > 0 then
      LWhereList.Add('CreatedDate >= :StartTime');

    if EndTime > 0 then
      LWhereList.Add('CreatedDate <= :EndTime');

    if LWhereList.Count > 0 then
    begin
      LWhere := ' WHERE ' + LWhereList.Text.Replace(#13#10, ' AND ');
      LSQL := LSQL + LWhere;
    end;

    LQuery.SQL.Text := LSQL;

    if UserName <> '' then
      LQuery.Params.ParamByName('UserName').AsString := '%' + UserName + '%';

    if TableName <> '' then
      LQuery.Params.ParamByName('TableName').AsString := '%' + TableName + '%';

    if StartTime > 0 then
      LQuery.Params.ParamByName('StartTime').AsDateTime := StartTime;

    if EndTime > 0 then
      LQuery.Params.ParamByName('EndTime').AsDateTime := EndTime;

    LQuery.Open;
    Result := LQuery.FieldByName('Cnt').AsInteger;
  finally
    LQuery.Free;
    LWhereList.Free;
  end;
end;

procedure TLogDataModule.AddDataChangeLog(UserID: Integer; const UserName, TableName: string;
  RecordID: Integer; const Operation: string; const OldValue, NewValue, IP: string);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'INSERT INTO UniAdmin_DataChangeLogs ' +
      '(UserID, UserName, TableName, RecordID, Operation, OldValue, NewValue, IP, CreatedDate) ' +
      'VALUES (:UserID, :UserName, :TableName, :RecordID, :Operation, :OldValue, :NewValue, :IP, CURRENT_TIMESTAMP)';

    LQuery.Params.ParamByName('UserID').AsInteger := UserID;
    LQuery.Params.ParamByName('UserName').AsString := UserName;
    LQuery.Params.ParamByName('TableName').AsString := TableName;
    LQuery.Params.ParamByName('RecordID').AsInteger := RecordID;
    LQuery.Params.ParamByName('Operation').AsString := Operation;
    LQuery.Params.ParamByName('OldValue').AsString := OldValue;
    LQuery.Params.ParamByName('NewValue').AsString := NewValue;
    LQuery.Params.ParamByName('IP').AsString := IP;

    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

procedure TLogDataModule.DeleteLoginLogs(BeforeDate: TDateTime);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text := 'DELETE FROM UniAdmin_LoginLogs WHERE LoginTime < :BeforeDate';
    LQuery.Params.ParamByName('BeforeDate').AsDateTime := BeforeDate;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

procedure TLogDataModule.DeleteOperationLogs(BeforeDate: TDateTime);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text := 'DELETE FROM UniAdmin_OperationLogs WHERE CreatedDate < :BeforeDate';
    LQuery.Params.ParamByName('BeforeDate').AsDateTime := BeforeDate;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

procedure TLogDataModule.DeleteDataChangeLogs(BeforeDate: TDateTime);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text := 'DELETE FROM UniAdmin_DataChangeLogs WHERE CreatedDate < :BeforeDate';
    LQuery.Params.ParamByName('BeforeDate').AsDateTime := BeforeDate;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

end.

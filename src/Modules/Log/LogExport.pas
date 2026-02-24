unit LogExport;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Generics.Collections,
  Data.DB, FireDAC.Comp.Client,
  UniContext, UniPlugin.Types, LogDataModule;

type
  /// <summary>
  /// 日志导出格式
  /// </summary>
  TLogExportFormat = (lefExcel, lefCsv, lefJson, lefXml);

  /// <summary>
  /// 日志导出类 - 提供日志导出功能
  /// </summary>
  TLogExport = class(TObject)
  private
    FContext: IExecutionContext;
    FDataModule: TLogDataModule;

    function ExportLoginLogToExcel(const FileName: string; DataSet: TDataSet): Boolean;
    function ExportOperationLogToExcel(const FileName: string; DataSet: TDataSet): Boolean;
    function ExportDataChangeLogToExcel(const FileName: string; DataSet: TDataSet): Boolean;

    function ExportLoginLogToCsv(const FileName: string; DataSet: TDataSet): Boolean;
    function ExportOperationLogToCsv(const FileName: string; DataSet: TDataSet): Boolean;
    function ExportDataChangeLogToCsv(const FileName: string; DataSet: TDataSet): Boolean;
  public
    constructor Create(const Context: IExecutionContext); reintroduce;
    destructor Destroy; override;

    // 导出登录日志
    function ExportLoginLogs(const FileName: string; Format: TLogExportFormat;
      const UserName, IP: string; StartTime, EndTime: TDateTime; Status: Integer): Boolean;

    // 导出操作日志
    function ExportOperationLogs(const FileName: string; Format: TLogExportFormat;
      const UserName, Module: string; StartTime, EndTime: TDateTime; Status: Integer): Boolean;

    // 导出数据变更日志
    function ExportDataChangeLogs(const FileName: string; Format: TLogExportFormat;
      const UserName, TableName: string; StartTime, EndTime: TDateTime): Boolean;
  end;

implementation

{ TLogExport }

constructor TLogExport.Create(const Context: IExecutionContext);
begin
  inherited Create;
  FContext := Context;
  FDataModule := TLogDataModule.Create(nil);
  if Supports(FDataModule, IContextAware) then
    (FDataModule as IContextAware).SetContext(Context);
  FDataModule.Open;
end;

destructor TLogExport.Destroy;
begin
  if Assigned(FDataModule) then
  begin
    FDataModule.Close;
    FDataModule.Free;
  end;
  inherited;
end;

function TLogExport.ExportLoginLogs(const FileName: string; Format: TLogExportFormat;
  const UserName, IP: string; StartTime, EndTime: TDateTime; Status: Integer): Boolean;
var
  LDataSet: TDataSet;
begin
  Result := False;

  // 获取数据
  LDataSet := FDataModule.GetLoginLogs(UserName, IP, StartTime, EndTime, Status, 1, MaxInt);
  try
    case Format of
      lefExcel:
        Result := ExportLoginLogToExcel(FileName, LDataSet);
      lefCsv:
        Result := ExportLoginLogToCsv(FileName, LDataSet);
      lefJson:
        Result := False; // TODO: 实现 JSON 导出
      lefXml:
        Result := False; // TODO: 实现 XML 导出
    end;
  finally
    LDataSet.Free;
  end;
end;

function TLogExport.ExportOperationLogs(const FileName: string; Format: TLogExportFormat;
  const UserName, Module: string; StartTime, EndTime: TDateTime; Status: Integer): Boolean;
var
  LDataSet: TDataSet;
begin
  Result := False;

  LDataSet := FDataModule.GetOperationLogs(UserName, Module, StartTime, EndTime, Status, 1, MaxInt);
  try
    case Format of
      lefExcel:
        Result := ExportOperationLogToExcel(FileName, LDataSet);
      lefCsv:
        Result := ExportOperationLogToCsv(FileName, LDataSet);
      lefJson:
        Result := False; // TODO: 实现 JSON 导出
      lefXml:
        Result := False; // TODO: 实现 XML 导出
    end;
  finally
    LDataSet.Free;
  end;
end;

function TLogExport.ExportDataChangeLogs(const FileName: string; Format: TLogExportFormat;
  const UserName, TableName: string; StartTime, EndTime: TDateTime): Boolean;
var
  LDataSet: TDataSet;
begin
  Result := False;

  LDataSet := FDataModule.GetDataChangeLogs(UserName, TableName, StartTime, EndTime, 1, MaxInt);
  try
    case Format of
      lefExcel:
        Result := ExportDataChangeLogToExcel(FileName, LDataSet);
      lefCsv:
        Result := ExportDataChangeLogToCsv(FileName, LDataSet);
      lefJson:
        Result := False; // TODO: 实现 JSON 导出
      lefXml:
        Result := False; // TODO: 实现 XML 导出
    end;
  finally
    LDataSet.Free;
  end;
end;

function TLogExport.ExportLoginLogToExcel(const FileName: string; DataSet: TDataSet): Boolean;
var
  LStream: TFileStream;
  LWriter: TStreamWriter;
begin
  Result := False;

  // 简化实现 - 使用 CSV 格式作为 Excel 兼容格式
  LStream := TFileStream.Create(FileName, fmCreate);
  try
    LWriter := TStreamWriter.Create(LStream, TEncoding.UTF8);
    try
      // 写入标题行（带 BOM 标识 UTF-8）
      LWriter.WriteLine('LogID,UserID,UserName,LoginIP,LoginTime,LogoutTime,Status,UserAgent,FailReason');

      // 写入数据行
      DataSet.First;
      while not DataSet.Eof do
      begin
        LWriter.WriteLine(Format('%d,%d,%s,%s,%s,%s,%d,%s,%s',
          [DataSet.FieldByName('LogID').AsInteger,
           DataSet.FieldByName('UserID').AsInteger,
           DataSet.FieldByName('UserName').AsString,
           DataSet.FieldByName('LoginIP').AsString,
           FormatDateTime('yyyy-mm-dd hh:nn:ss', DataSet.FieldByName('LoginTime').AsDateTime),
           FormatDateTime('yyyy-mm-dd hh:nn:ss', DataSet.FieldByName('LogoutTime').AsDateTime),
           DataSet.FieldByName('Status').AsInteger,
           DataSet.FieldByName('UserAgent').AsString,
           DataSet.FieldByName('FailReason').AsString]));
        DataSet.Next;
      end;

      Result := True;
    finally
      LWriter.Free;
    end;
  finally
    LStream.Free;
  end;
end;

function TLogExport.ExportOperationLogToExcel(const FileName: string; DataSet: TDataSet): Boolean;
var
  LStream: TFileStream;
  LWriter: TStreamWriter;
begin
  Result := False;

  LStream := TFileStream.Create(FileName, fmCreate);
  try
    LWriter := TStreamWriter.Create(LStream, TEncoding.UTF8);
    try
      LWriter.WriteLine('LogID,UserID,UserName,Module,Operation,Description,IP,Duration,Status,CreatedDate');

      DataSet.First;
      while not DataSet.Eof do
      begin
        LWriter.WriteLine(Format('%d,%d,%s,%s,%s,%s,%s,%d,%d,%s',
          [DataSet.FieldByName('LogID').AsInteger,
           DataSet.FieldByName('UserID').AsInteger,
           DataSet.FieldByName('UserName').AsString,
           DataSet.FieldByName('Module').AsString,
           DataSet.FieldByName('Operation').AsString,
           DataSet.FieldByName('Description').AsString,
           DataSet.FieldByName('IP').AsString,
           DataSet.FieldByName('Duration').AsInteger,
           DataSet.FieldByName('Status').AsInteger,
           FormatDateTime('yyyy-mm-dd hh:nn:ss', DataSet.FieldByName('CreatedDate').AsDateTime)]));
        DataSet.Next;
      end;

      Result := True;
    finally
      LWriter.Free;
    end;
  finally
    LStream.Free;
  end;
end;

function TLogExport.ExportDataChangeLogToExcel(const FileName: string; DataSet: TDataSet): Boolean;
var
  LStream: TFileStream;
  LWriter: TStreamWriter;
begin
  Result := False;

  LStream := TFileStream.Create(FileName, fmCreate);
  try
    LWriter := TStreamWriter.Create(LStream, TEncoding.UTF8);
    try
      LWriter.WriteLine('LogID,UserID,UserName,TableName,RecordID,Operation,IP,CreatedDate');

      DataSet.First;
      while not DataSet.Eof do
      begin
        LWriter.WriteLine(Format('%d,%d,%s,%s,%d,%s,%s,%s',
          [DataSet.FieldByName('LogID').AsInteger,
           DataSet.FieldByName('UserID').AsInteger,
           DataSet.FieldByName('UserName').AsString,
           DataSet.FieldByName('TableName').AsString,
           DataSet.FieldByName('RecordID').AsInteger,
           DataSet.FieldByName('Operation').AsString,
           DataSet.FieldByName('IP').AsString,
           FormatDateTime('yyyy-mm-dd hh:nn:ss', DataSet.FieldByName('CreatedDate').AsDateTime)]));
        DataSet.Next;
      end;

      Result := True;
    finally
      LWriter.Free;
    end;
  finally
    LStream.Free;
  end;
end;

function TLogExport.ExportLoginLogToCsv(const FileName: string; DataSet: TDataSet): Boolean;
begin
  // CSV 导出与 Excel 格式相同
  Result := ExportLoginLogToExcel(FileName, DataSet);
end;

function TLogExport.ExportOperationLogToCsv(const FileName: string; DataSet: TDataSet): Boolean;
begin
  Result := ExportOperationLogToExcel(FileName, DataSet);
end;

function TLogExport.ExportDataChangeLogToCsv(const FileName: string; DataSet: TDataSet): Boolean;
begin
  Result := ExportDataChangeLogToExcel(FileName, DataSet);
end;

end.

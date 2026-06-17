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

    function ExportToJson(const FileName: string; DataSet: TDataSet; const Fields: array of string): Boolean;
    function ExportToXml(const FileName: string; DataSet: TDataSet; const RootName, ItemName: string; const Fields: array of string): Boolean;
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

uses
  System.JSON;

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
        Result := ExportToJson(FileName, LDataSet,
          ['LogID', 'UserID', 'UserName', 'LoginIP', 'LoginTime', 'LogoutTime', 'Status', 'UserAgent', 'FailReason']);
      lefXml:
        Result := ExportToXml(FileName, LDataSet, 'LoginLogs', 'LoginLog',
          ['LogID', 'UserID', 'UserName', 'LoginIP', 'LoginTime', 'LogoutTime', 'Status', 'UserAgent', 'FailReason']);
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
        Result := ExportToJson(FileName, LDataSet,
          ['LogID', 'UserID', 'UserName', 'Module', 'Operation', 'Description', 'IP', 'Duration', 'Status', 'CreatedDate']);
      lefXml:
        Result := ExportToXml(FileName, LDataSet, 'OperationLogs', 'OperationLog',
          ['LogID', 'UserID', 'UserName', 'Module', 'Operation', 'Description', 'IP', 'Duration', 'Status', 'CreatedDate']);
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
        Result := ExportToJson(FileName, LDataSet,
          ['LogID', 'UserID', 'UserName', 'TableName', 'RecordID', 'Operation', 'IP', 'CreatedDate']);
      lefXml:
        Result := ExportToXml(FileName, LDataSet, 'DataChangeLogs', 'DataChangeLog',
          ['LogID', 'UserID', 'UserName', 'TableName', 'RecordID', 'Operation', 'IP', 'CreatedDate']);
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

function TLogExport.ExportToJson(const FileName: string; DataSet: TDataSet;
  const Fields: array of string): Boolean;
var
  LStream: TFileStream;
  LWriter: TStreamWriter;
  LFirst: Boolean;
  I: Integer;
  LField: TField;
  LValue: string;
begin
  Result := False;

  LStream := TFileStream.Create(FileName, fmCreate);
  try
    LWriter := TStreamWriter.Create(LStream, TEncoding.UTF8);
    try
      LWriter.Write('[');

      DataSet.First;
      LFirst := True;
      while not DataSet.Eof do
      begin
        if not LFirst then
          LWriter.Write(',')
        else
          LFirst := False;

        LWriter.Write('{');
        for I := Low(Fields) to High(Fields) do
        begin
          if I > Low(Fields) then
            LWriter.Write(',');

          LField := DataSet.FindField(Fields[I]);
          LWriter.Write('"' + Fields[I] + '":');

          if (LField = nil) or LField.IsNull then
            LWriter.Write('null')
          else
          begin
            case LField.DataType of
              ftInteger, ftSmallint, ftWord, ftLargeint, ftShortint, ftByte:
                LWriter.Write(IntToStr(LField.AsLargeInt));
              ftFloat, ftCurrency, ftBCD, ftFMTBcd, ftSingle:
                LWriter.Write(FloatToStr(LField.AsFloat));
              ftBoolean:
                if LField.AsBoolean then
                  LWriter.Write('true')
                else
                  LWriter.Write('false');
              ftDate, ftTime, ftDateTime, ftTimeStamp:
                begin
                  LValue := FormatDateTime('yyyy-mm-dd''T''hh:nn:ss', LField.AsDateTime);
                  LWriter.Write('"' + LValue + '"');
                end;
            else
              // String types - escape quotes and backslashes
              LValue := LField.AsString;
              LValue := StringReplace(LValue, '\', '\\', [rfReplaceAll]);
              LValue := StringReplace(LValue, '"', '\"', [rfReplaceAll]);
              LValue := StringReplace(LValue, #13#10, '\n', [rfReplaceAll]);
              LValue := StringReplace(LValue, #10, '\n', [rfReplaceAll]);
              LValue := StringReplace(LValue, #13, '\n', [rfReplaceAll]);
              LValue := StringReplace(LValue, #9, '\t', [rfReplaceAll]);
              LWriter.Write('"' + LValue + '"');
            end;
          end;
        end;
        LWriter.Write('}');

        DataSet.Next;
      end;

      LWriter.Write(']');

      Result := True;
    finally
      LWriter.Free;
    end;
  finally
    LStream.Free;
  end;
end;

function TLogExport.ExportToXml(const FileName: string; DataSet: TDataSet;
  const RootName, ItemName: string; const Fields: array of string): Boolean;
var
  LStream: TFileStream;
  LWriter: TStreamWriter;
  I: Integer;
  LField: TField;
  LValue: string;
begin
  Result := False;

  LStream := TFileStream.Create(FileName, fmCreate);
  try
    LWriter := TStreamWriter.Create(LStream, TEncoding.UTF8);
    try
      LWriter.WriteLine('<?xml version="1.0" encoding="UTF-8"?>');
      LWriter.WriteLine('<' + RootName + '>');

      DataSet.First;
      while not DataSet.Eof do
      begin
        LWriter.WriteLine('  <' + ItemName + '>');

        for I := Low(Fields) to High(Fields) do
        begin
          LField := DataSet.FindField(Fields[I]);

          if (LField = nil) or LField.IsNull then
            LWriter.WriteLine('    <' + Fields[I] + '/>')
          else
          begin
            case LField.DataType of
              ftDate, ftTime, ftDateTime, ftTimeStamp:
                LValue := FormatDateTime('yyyy-mm-dd''T''hh:nn:ss', LField.AsDateTime);
            else
              LValue := LField.AsString;
            end;

            // Escape XML special characters
            LValue := StringReplace(LValue, '&', '&amp;', [rfReplaceAll]);
            LValue := StringReplace(LValue, '<', '&lt;', [rfReplaceAll]);
            LValue := StringReplace(LValue, '>', '&gt;', [rfReplaceAll]);
            LValue := StringReplace(LValue, '"', '&quot;', [rfReplaceAll]);
            LValue := StringReplace(LValue, '''', '&apos;', [rfReplaceAll]);

            LWriter.WriteLine('    <' + Fields[I] + '>' + LValue + '</' + Fields[I] + '>');
          end;
        end;

        LWriter.WriteLine('  </' + ItemName + '>');
        DataSet.Next;
      end;

      LWriter.WriteLine('</' + RootName + '>');

      Result := True;
    finally
      LWriter.Free;
    end;
  finally
    LStream.Free;
  end;
end;

end.

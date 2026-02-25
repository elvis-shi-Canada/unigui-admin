unit DataExporter;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Generics.Collections,
  System.JSON, FireDAC.Comp.Client, FireDAC.Comp.DataSet;

type
  TExportFormat = (efCSV, efJSON, efXML, efExcel);

  TDataExporter = class
  private
    FConnection: TFDConnection;
    FQuery: TFDQuery;
    procedure ExportToCSV(const Query: TFDQuery; const FileName: string);
    procedure ExportToJSON(const Query: TFDQuery; const FileName: string);
    procedure ExportToXML(const Query: TFDQuery; const FileName: string);
    function EscapeCSV(const Value: string): string;
    function FieldToJSONValue(Field: TField): TJSONValue;
  public
    constructor Create(const Connection: TFDConnection);
    destructor Destroy; override;
    function ExportTable(const TableName: string; const Format: TExportFormat; const FileName: string): Boolean;
    function ExportQuery(const SQL: string; const Format: TExportFormat; const FileName: string): Boolean;
    function ExportMultiple(const TableNames: TArray<string>; const OutputDir: string; const Format: TExportFormat): Boolean;
    function GetTableList: TArray<string>;
  end;

implementation

constructor TDataExporter.Create(const Connection: TFDConnection);
begin
  inherited Create;
  FConnection := Connection;
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := FConnection;
end;

destructor TDataExporter.Destroy;
begin
  FQuery.Free;
  inherited;
end;

function TDataExporter.EscapeCSV(const Value: string): string;
const
  CR = #13;
  LF = #10;
begin
  Result := Value;
  // 如果值包含逗号、引号或换行符，需要用引号包裹
  if (Pos(',', Result) > 0) or (Pos('"', Result) > 0) or
     (Pos(CR, Result) > 0) or (Pos(LF, Result) > 0) then
  begin
    // 将双引号替换为两个双引号
    Result := StringReplace(Result, '"', '""', [rfReplaceAll]);
    // 用双引号包裹
    Result := '"' + Result + '"';
  end;
end;

procedure TDataExporter.ExportToCSV(const Query: TFDQuery; const FileName: string);
var
  SB: TStringBuilder;
  I: Integer;
  Field: TField;
  Line: string;
begin
  SB := TStringBuilder.Create;
  try
    // CSV 头部
    Line := '';
    for I := 0 to Query.FieldCount - 1 do
    begin
      if I > 0 then Line := Line + ',';
      Line := Line + EscapeCSV(Query.Fields[I].FieldName);
    end;
    SB.AppendLine(Line);

    // 数据行
    Query.First;
    while not Query.Eof do
    begin
      Line := '';
      for I := 0 to Query.FieldCount - 1 do
      begin
        if I > 0 then Line := Line + ',';
        Field := Query.Fields[I];
        if not Field.IsNull then
          Line := Line + EscapeCSV(Field.AsString)
        else
          Line := Line + '';
      end;
      SB.AppendLine(Line);
      Query.Next;
    end;

    TFile.WriteAllText(FileName, SB.ToString, TEncoding.UTF8);
  finally
    SB.Free;
  end;
end;

function TDataExporter.FieldToJSONValue(Field: TField): TJSONValue;
begin
  if Field.IsNull then
    Result := TJSONNull.Create
  else
  begin
    case Field.DataType of
      ftInteger, ftSmallint, ftWord, ftLargeint, ftAutoInc:
        Result := TJSONNumber.Create(Field.AsInteger);
      ftFloat, ftCurrency, ftBCD, ftFMTBcd:
        Result := TJSONNumber.Create(Field.AsFloat);
      ftBoolean:
        Result := TJSONBool.Create(Field.AsBoolean);
      ftDate, ftTime, ftDateTime, ftTimeStamp:
        Result := TJSONString.Create(FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', Field.AsDateTime));
      ftString, ftWideString, ftMemo, ftWideMemo:
        Result := TJSONString.Create(Field.AsString);
    else
      Result := TJSONString.Create(Field.AsString);
    end;
  end;
end;

procedure TDataExporter.ExportToJSON(const Query: TFDQuery; const FileName: string);
var
  RootArray: TJSONArray;
  RowObject: TJSONObject;
  I: Integer;
  Field: TField;
begin
  RootArray := TJSONArray.Create;
  try
    Query.First;
    while not Query.Eof do
    begin
      RowObject := TJSONObject.Create;
      for I := 0 to Query.FieldCount - 1 do
      begin
        Field := Query.Fields[I];
        RowObject.AddPair(Field.FieldName, FieldToJSONValue(Field));
      end;
      RootArray.AddElement(RowObject);
      Query.Next;
    end;

    TFile.WriteAllText(FileName, RootArray.Format(2), TEncoding.UTF8);
  finally
    RootArray.Free;
  end;
end;

procedure TDataExporter.ExportToXML(const Query: TFDQuery; const FileName: string);
var
  SB: TStringBuilder;
  I: Integer;
  Field: TField;
begin
  SB := TStringBuilder.Create;
  try
    SB.AppendLine('<?xml version="1.0" encoding="UTF-8"?>');
    SB.AppendLine('<rows>');

    Query.First;
    while not Query.Eof do
    begin
      SB.AppendLine('  <row>');
      for I := 0 to Query.FieldCount - 1 do
      begin
        Field := Query.Fields[I];
        SB.Append('    <');
        SB.Append(Field.FieldName);
        SB.Append('>');
        if not Field.IsNull then
          SB.Append(StringReplace(StringReplace(Field.AsString,
            '&', '&amp;', [rfReplaceAll]),
            '<', '&lt;', [rfReplaceAll]),
            '>', '&gt;', [rfReplaceAll])
        SB.Append('</');
        SB.Append(Field.FieldName);
        SB.AppendLine('>');
      end;
      SB.AppendLine('  </row>');
      Query.Next;
    end;

    SB.AppendLine('</rows>');
    TFile.WriteAllText(FileName, SB.ToString, TEncoding.UTF8);
  finally
    SB.Free;
  end;
end;

function TDataExporter.ExportTable(const TableName: string; const Format: TExportFormat; const FileName: string): Boolean;
var
  SQL: string;
begin
  Result := False;

  try
    SQL := Format('SELECT * FROM %s', [TableName]);
    FQuery.SQL.Text := SQL;
    FQuery.Open;

    if FQuery.IsEmpty then
    begin
      Writeln('表为空: ' + TableName);
      Exit;
    end;

    case Format of
      efCSV: ExportToCSV(FQuery, FileName);
      efJSON: ExportToJSON(FQuery, FileName);
      efXML: ExportToXML(FQuery, FileName);
      efExcel: ExportToCSV(FQuery, FileName); // Excel使用CSV格式
    end;

    Result := True;
    Writeln('导出成功: ' + FileName);
    Writeln('记录数: ' + IntToStr(FQuery.RecordCount));
  except
    on E: Exception do
    begin
      Writeln('导出失败: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TDataExporter.ExportQuery(const SQL: string; const Format: TExportFormat; const FileName: string): Boolean;
begin
  Result := False;

  try
    FQuery.SQL.Text := SQL;
    FQuery.Open;

    if FQuery.IsEmpty then
    begin
      Writeln('查询结果为空');
      Exit;
    end;

    case Format of
      efCSV: ExportToCSV(FQuery, FileName);
      efJSON: ExportToJSON(FQuery, FileName);
      efXML: ExportToXML(FQuery, FileName);
      efExcel: ExportToCSV(FQuery, FileName);
    end;

    Result := True;
    Writeln('导出成功: ' + FileName);
    Writeln('记录数: ' + IntToStr(FQuery.RecordCount));
  except
    on E: Exception do
    begin
      Writeln('导出失败: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TDataExporter.ExportMultiple(const TableNames: TArray<string>; const OutputDir: string; const Format: TExportFormat): Boolean;
var
  TableName: string;
  Extension: string;
  FileName: string;
  SuccessCount: Integer;
begin
  Result := False;
  SuccessCount := 0;

  case Format of
    efCSV: Extension := '.csv';
    efJSON: Extension := '.json';
    efXML: Extension := '.xml';
    efExcel: Extension := '.csv';
  end;

  if not TDirectory.Exists(OutputDir) then
    TDirectory.CreateDirectory(OutputDir);

  for TableName in TableNames do
  begin
    FileName := TPath.Combine(OutputDir, TableName + Extension);
    if ExportTable(TableName, Format, FileName) then
      Inc(SuccessCount);
  end;

  Writeln;
  Writeln(Format('导出完成: %d/%d 成功', [SuccessCount, Length(TableNames)]));
  Result := SuccessCount = Length(TableNames);
end;

function TDataExporter.GetTableList: TArray<string>;
var
  List: TList<string>;
  Meta: TFDMetaInfoQuery;
begin
  List := TList<string>.Create;
  Meta := TFDMetaInfoQuery.Create(nil);
  try
    Meta.Connection := FConnection;
    Meta.MetaInfoKind := mkTables;
    Meta.Open;

    while not Meta.Eof do
    begin
      List.Add(Meta.FieldByName('TABLE_NAME').AsString);
      Meta.Next;
    end;

    Result := List.ToArray;
  finally
    Meta.Free;
    List.Free;
  end;
end;

end.

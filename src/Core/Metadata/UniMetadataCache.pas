unit UniMetadataCache;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  FireDAC.Comp.Client,
  UniMetadataCache.Intf, UniFieldMetadata;

type
  /// <summary>
  /// 元数据缓存实现
  /// 从数据库自动读取表结构信息并缓存
  /// </summary>
  TUniMetadataCache = class(TInterfacedObject, IUniMetadataCache)
  private
    class var FInstance: IUniMetadataCache;
    FTables: TDictionary<string, TTableMetadata>;
    FConnection: TFDConnection;

    function LoadTableMetadata(const TableName: string): TTableMetadata;
    function GetFieldTypeFromDB(const TypeName: string; Size, Precision: Integer): TFieldType;
  public
    constructor Create(const Connection: TFDConnection);
    destructor Destroy; override;

    function GetTableMetadata(const TableName: string): TTableMetadata;
    procedure RegisterTable(const Metadata: TTableMetadata);
    function HasTable(const TableName: string): Boolean;
    function GetAllTables: TArray<string>;
    procedure Refresh;
    procedure Clear;

    class function GetInstance(const Connection: TFDConnection): IUniMetadataCache; static;
  end;

implementation

{ TUniMetadataCache }

class function TUniMetadataCache.GetInstance(const Connection: TFDConnection): IUniMetadataCache;
begin
  if FInstance = nil then
    FInstance := TUniMetadataCache.Create(Connection);
  Result := FInstance;
end;

constructor TUniMetadataCache.Create(const Connection: TFDConnection);
begin
  inherited Create;
  FConnection := Connection;
  FTables := TDictionary<string, TTableMetadata>.Create;
end;

destructor TUniMetadataCache.Destroy;
var
  LPair: TPair<string, TTableMetadata>;
begin
  for LPair in FTables do
    LPair.Value.Clear;
  FTables.Free;
  inherited;
end;

function TUniMetadataCache.GetFieldTypeFromDB(const TypeName: string;
  Size, Precision: Integer): TFieldType;
begin
  TypeName := UpperCase(TypeName);

  if TypeName.Contains('INT') then
    Result := ftInteger
  else if TypeName.Contains('CHAR') or TypeName.Contains('TEXT') then
    Result := ftString
  else if TypeName.Contains('DECIMAL') or TypeName.Contains('NUMERIC')
    or TypeName.Contains('FLOAT') or TypeName.Contains('DOUBLE') then
    Result := ftFloat
  else if TypeName.Contains('DATE') or TypeName.Contains('TIME') then
    Result := ftDateTime
  else if TypeName.Contains('BIT') or TypeName.Contains('BOOL') then
    Result := ftBoolean
  else if TypeName.Contains('BLOB') or TypeName.Contains('BINARY') then
    Result := ftBlob
  else if TypeName.Contains('GUID') or TypeName.Contains('UUID') then
    Result := ftGuid
  else
    Result := ftUnknown;
end;

function TUniMetadataCache.LoadTableMetadata(const TableName: string): TTableMetadata;
var
  LQuery: TFDQuery;
  LField: TFieldMetadata;
begin
  Result.TableName := TableName;
  Result.DisplayName := TableName;
  Result.PrimaryKey := '';
  Result.DisplayNameField := '';
  Result.Fields := TList<TFieldMetadata>.Create;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;

    // 获取字段信息
    LQuery.SQL.Text := Format(
      'SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, ' +
      'NUMERIC_PRECISION, IS_NULLABLE, COLUMN_DEFAULT ' +
      'FROM INFORMATION_SCHEMA.COLUMNS ' +
      'WHERE TABLE_NAME = ''%s'' ORDER BY ORDINAL_POSITION',
      [TableName]);

    LQuery.Open;
    while not LQuery.Eof do
    begin
      LField.FieldName := LQuery.FieldByName('COLUMN_NAME').AsString;
      LField.DisplayName := LField.FieldName;
      LField.DataType := GetFieldTypeFromDB(
        LQuery.FieldByName('DATA_TYPE').AsString,
        LQuery.FieldByName('CHARACTER_MAXIMUM_LENGTH').AsInteger,
        LQuery.FieldByName('NUMERIC_PRECISION').AsInteger);
      LField.Size := LQuery.FieldByName('CHARACTER_MAXIMUM_LENGTH').AsInteger;
      LField.Precision := LQuery.FieldByName('NUMERIC_PRECISION').AsInteger;
      LField.IsRequired := (LQuery.FieldByName('IS_NULLABLE').AsString = 'NO');
      LField.IsPrimaryKey := False;
      LField.DefaultValue := LQuery.FieldByName('COLUMN_DEFAULT').AsString;

      Result.AddField(LField);
      LQuery.Next;
    end;

    // 获取主键信息
    LQuery.Close;
    LQuery.SQL.Text := Format(
      'SELECT CU.COLUMN_NAME ' +
      'FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC ' +
      'JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE CU ' +
      '  ON TC.CONSTRAINT_NAME = CU.CONSTRAINT_NAME ' +
      'WHERE TC.TABLE_NAME = ''%s'' AND TC.CONSTRAINT_TYPE = ''PRIMARY KEY''',
      [TableName]);

    LQuery.Open;
    if not LQuery.Eof then
    begin
      Result.PrimaryKey := LQuery.FieldByName('COLUMN_NAME').AsString;
      // 更新字段的主键标记
      for LField in Result.Fields do
      begin
        if LField.FieldName = Result.PrimaryKey then
          LField.IsPrimaryKey := True;
      end;
    end;

  finally
    LQuery.Free;
  end;
end;

function TUniMetadataCache.GetTableMetadata(const TableName: string): TTableMetadata;
begin
  if not FTables.ContainsKey(TableName) then
  begin
    FTables.Add(TableName, LoadTableMetadata(TableName));
  end;
  Result := FTables[TableName];
end;

procedure TUniMetadataCache.RegisterTable(const Metadata: TTableMetadata);
begin
  FTables.AddOrSetValue(Metadata.TableName, Metadata);
end;

function TUniMetadataCache.HasTable(const TableName: string): Boolean;
begin
  Result := FTables.ContainsKey(TableName);
end;

function TUniMetadataCache.GetAllTables: TArray<string>;
begin
  Result := FTables.Keys.ToArray;
end;

procedure TUniMetadataCache.Refresh;
var
  LTableNames: TArray<string>;
  LTableName: string;
begin
  LTableNames := GetAllTables;
  Clear;

  for LTableName in LTableNames do
  begin
    FTables.Add(LTableName, LoadTableMetadata(LTableName));
  end;
end;

procedure TUniMetadataCache.Clear;
var
  LPair: TPair<string, TTableMetadata>;
begin
  for LPair in FTables do
    LPair.Value.Clear;
  FTables.Clear;
end;

initialization
  // 单例通过 GetInstance 创建

finalization
  TUniMetadataCache.FInstance := nil;

end.

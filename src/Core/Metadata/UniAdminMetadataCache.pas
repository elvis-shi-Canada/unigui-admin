unit UniAdminMetadataCache;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.Character,
  FireDAC.Comp.Client,
  UniAdminMetadataCache.Intf, UniFieldMetadata;

type
  /// <summary>
  /// 元数据缓存实现
  /// 从数据库自动读取表结构信息并缓存
  /// </summary>
  TUniAdminMetadataCache = class(TInterfacedObject, IUniAdminMetadataCache)
  private
    class var FInstance: IUniAdminMetadataCache;
    class var FLock: TObject;
    FTables: TDictionary<string, TTableMetadata>;
    FConnection: TFDConnection;

    function IsValidTableName(const TableName: string): Boolean;
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

    /// <summary>
    /// 获取元数据缓存实例
    /// 注意: 当前实现为全局单例，不支持多连接场景
    /// TODO: 未来版本考虑支持按连接管理的多实例模式
    /// </summary>
    class function GetInstance(const Connection: TFDConnection): IUniAdminMetadataCache; static;
  end;

implementation

{ TUniAdminMetadataCache }

class function TUniAdminMetadataCache.GetInstance(const Connection: TFDConnection): IUniAdminMetadataCache;
begin
  if FInstance = nil then
  begin
    TMonitor.Enter(FLock);
    try
      if FInstance = nil then
        FInstance := TUniAdminMetadataCache.Create(Connection);
    finally
      TMonitor.Exit(FLock);
    end;
  end;
  Result := FInstance;
end;

constructor TUniAdminMetadataCache.Create(const Connection: TFDConnection);
begin
  inherited Create;
  FConnection := Connection;
  FTables := TDictionary<string, TTableMetadata>.Create;
end;

destructor TUniAdminMetadataCache.Destroy;
var
  LPair: TPair<string, TTableMetadata>;
begin
  for LPair in FTables do
    LPair.Value.Clear;
  FTables.Free;
  inherited;
end;

function TUniAdminMetadataCache.IsValidTableName(const TableName: string): Boolean;
var
  I: Integer;
  C: Char;
begin
  Result := (TableName.Length > 0) and (TableName.Length <= 128);
  if not Result then Exit;

  for I := 1 to TableName.Length do
  begin
    C := TableName[I];
    if not (TCharacter.IsLetterOrDigit(C) or (C = '_')) then
      Exit(False);
  end;
end;

function TUniAdminMetadataCache.GetFieldTypeFromDB(const TypeName: string;
  Size, Precision: Integer): TFieldType;
var
  LTypeName: string;
begin
  LTypeName := UpperCase(TypeName);

  if LTypeName.Contains('INT') then
    Result := ftInteger
  else if LTypeName.Contains('CHAR') or LTypeName.Contains('TEXT') then
    Result := ftString
  else if LTypeName.Contains('DECIMAL') or LTypeName.Contains('NUMERIC')
    or LTypeName.Contains('FLOAT') or LTypeName.Contains('DOUBLE') then
    Result := ftFloat
  else if LTypeName.Contains('DATE') or LTypeName.Contains('TIME') then
    Result := ftDateTime
  else if LTypeName.Contains('BIT') or LTypeName.Contains('BOOL') then
    Result := ftBoolean
  else if LTypeName.Contains('BLOB') or LTypeName.Contains('BINARY') then
    Result := ftBlob
  else if LTypeName.Contains('GUID') or LTypeName.Contains('UUID') then
    Result := ftGuid
  else
    Result := ftUnknown;
end;

function TUniAdminMetadataCache.LoadTableMetadata(const TableName: string): TTableMetadata;
var
  LQuery: TFDQuery;
  LField: TFieldMetadata;
  I: Integer;
begin
  // 初始化结果
  Result.TableName := TableName;
  Result.DisplayName := TableName;
  Result.PrimaryKey := '';
  Result.DisplayNameField := '';
  Result.Fields := TList<TFieldMetadata>.Create;

  // 验证连接
  if not Assigned(FConnection) then
    raise Exception.Create('Database connection is not assigned');

  if not FConnection.Connected then
    raise Exception.Create('Database connection is not open');

  // 验证表名（防止 SQL 注入）
  if not IsValidTableName(TableName) then
    raise Exception.CreateFmt('Invalid table name: %s', [TableName]);

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;

    // 获取字段信息
    try
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
        for I := 0 to Result.Fields.Count - 1 do
        begin
          LField := Result.Fields[I];
          if LField.FieldName = Result.PrimaryKey then
          begin
            LField.IsPrimaryKey := True;
            Result.Fields[I] := LField;
          end;
        end;
      end;

    except
      on E: Exception do
        raise Exception.CreateFmt('Failed to load metadata for table %s: %s', [TableName, E.Message]);
    end;

  finally
    LQuery.Free;
  end;
end;

function TUniAdminMetadataCache.GetTableMetadata(const TableName: string): TTableMetadata;
begin
  if not FTables.ContainsKey(TableName) then
  begin
    FTables.Add(TableName, LoadTableMetadata(TableName));
  end;
  Result := FTables[TableName];
end;

procedure TUniAdminMetadataCache.RegisterTable(const Metadata: TTableMetadata);
begin
  FTables.AddOrSetValue(Metadata.TableName, Metadata);
end;

function TUniAdminMetadataCache.HasTable(const TableName: string): Boolean;
begin
  Result := FTables.ContainsKey(TableName);
end;

function TUniAdminMetadataCache.GetAllTables: TArray<string>;
begin
  Result := FTables.Keys.ToArray;
end;

procedure TUniAdminMetadataCache.Refresh;
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

procedure TUniAdminMetadataCache.Clear;
var
  LPair: TPair<string, TTableMetadata>;
begin
  for LPair in FTables do
    LPair.Value.Clear;
  FTables.Clear;
end;

initialization
  TUniAdminMetadataCache.FLock := TObject.Create;

finalization
  TUniAdminMetadataCache.FInstance := nil;
  FreeAndNil(TUniAdminMetadataCache.FLock);

end.

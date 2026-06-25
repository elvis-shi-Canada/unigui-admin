unit ConfigDataModule;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Generics.Collections,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Stan.Param,
  UniContext, UniPlugin.Types, UniAdminDataModule,
  ConfigService.Intf;

type

  /// <summary>
  /// 系统配置数据模块 - 提供系统配置的 CRUD 操作
  /// </summary>
  TConfigDataModule = class(TUniAdminDataModule)
  public
    // 配置操作
    function GetConfigByID(ConfigID: Integer): TDataSet;
    function GetConfigByKey(const ConfigKey: string): TDataSet;
    function GetConfigs(const Filter, Category: string; Status: Integer = -1): TDataSet;
    function GetConfigsByCategory(const Category: string; Status: Integer = -1): TDataSet;
    function CreateConfig(const ConfigKey, ConfigValue, Category, Description: string;
      ValueType: TConfigValueType; SortOrder: Integer): Integer;
    procedure UpdateConfig(ConfigID: Integer; const ConfigValue, Description: string;
      SortOrder: Integer);
    procedure DeleteConfig(ConfigID: Integer);
    procedure SetConfigStatus(ConfigID, Status: Integer);
    function ConfigKeyExists(const ConfigKey: string; ExcludeID: Integer = 0): Boolean;

    // 配置分类操作
    function GetCategories: TArray<TConfigCategoryInfo>;
    function GetConfigValue(const ConfigKey: string): string;
    function GetConfigValueAsInteger(const ConfigKey: string; Default: Integer = 0): Integer;
    function GetConfigValueAsBoolean(const ConfigKey: string; Default: Boolean = False): Boolean;
    procedure SetConfigValue(const ConfigKey, ConfigValue: string);

    // 辅助方法
    function GetValueTypeText(ValueType: TConfigValueType): string;
    function ParseValueType(const ValueTypeText: string): TConfigValueType;
    function ValidateValue(const Value: string; ValueType: TConfigValueType): Boolean;
    function GetCategoryName(const Category: string): string;
  end;

implementation

{ TConfigDataModule }

function TConfigDataModule.GetConfigByID(ConfigID: Integer): TDataSet;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'SELECT * FROM UniAdmin_Configs WHERE ConfigID = :ConfigID';
    LQuery.Params.ParamByName('ConfigID').AsInteger := ConfigID;
    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    raise;
  end;
end;

function TConfigDataModule.GetConfigByKey(const ConfigKey: string): TDataSet;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'SELECT * FROM UniAdmin_Configs WHERE ConfigKey = :ConfigKey';
    LQuery.Params.ParamByName('ConfigKey').AsString := ConfigKey;
    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    raise;
  end;
end;

function TConfigDataModule.GetConfigs(const Filter, Category: string; Status: Integer): TDataSet;
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

    LSQL := 'SELECT * FROM UniAdmin_Configs';

    if Filter <> '' then
      LWhereList.Add('(ConfigKey LIKE :Filter OR Description LIKE :Filter)');

    if Category <> '' then
      LWhereList.Add('Category = :Category');

    if Status >= 0 then
      LWhereList.Add('Status = :Status');

    if LWhereList.Count > 0 then
    begin
      LWhere := ' WHERE ' + LWhereList.Text.Replace(#13#10, ' AND ');
      LSQL := LSQL + LWhere;
    end;

    LSQL := LSQL + ' ORDER BY Category, SortOrder, ConfigID';

    LQuery.SQL.Text := LSQL;

    if Filter <> '' then
      LQuery.Params.ParamByName('Filter').AsString := '%' + Filter + '%';

    if Category <> '' then
      LQuery.Params.ParamByName('Category').AsString := Category;

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

function TConfigDataModule.GetConfigsByCategory(const Category: string; Status: Integer): TDataSet;
var
  LQuery: TFDQuery;
  LSQL: string;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;

    LSQL := 'SELECT * FROM UniAdmin_Configs WHERE Category = :Category';

    if Status >= 0 then
      LSQL := LSQL + ' AND Status = :Status';

    LSQL := LSQL + ' ORDER BY SortOrder, ConfigID';

    LQuery.SQL.Text := LSQL;
    LQuery.Params.ParamByName('Category').AsString := Category;

    if Status >= 0 then
      LQuery.Params.ParamByName('Status').AsInteger := Status;

    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    raise;
  end;
end;

function TConfigDataModule.CreateConfig(const ConfigKey, ConfigValue, Category, Description: string;
  ValueType: TConfigValueType; SortOrder: Integer): Integer;
var
  LQuery: TFDQuery;
  LValueTypeText: string;
begin
  if ConfigKey.Trim.IsEmpty then
    raise Exception.Create('配置键不能为空');

  if Category.Trim.IsEmpty then
    raise Exception.Create('配置分类不能为空');

  if ConfigKeyExists(ConfigKey) then
    raise Exception.Create('配置键已存在');

  if not ValidateValue(ConfigValue, ValueType) then
    raise Exception.Create('配置值格式不正确');

  LValueTypeText := GetValueTypeText(ValueType);

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'INSERT INTO UniAdmin_Configs ' +
      '(ConfigKey, ConfigValue, Category, Description, ValueType, SortOrder, Status, CreatedDate, CreatedBy) ' +
      'VALUES (:ConfigKey, :ConfigValue, :Category, :Description, :ValueType, :SortOrder, 1, CURRENT_TIMESTAMP, :CreatedBy)';

    LQuery.Params.ParamByName('ConfigKey').AsString := ConfigKey;
    LQuery.Params.ParamByName('ConfigValue').AsString := ConfigValue;
    LQuery.Params.ParamByName('Category').AsString := Category;
    LQuery.Params.ParamByName('Description').AsString := Description;
    LQuery.Params.ParamByName('ValueType').AsString := LValueTypeText;
    LQuery.Params.ParamByName('SortOrder').AsInteger := SortOrder;
    LQuery.Params.ParamByName('CreatedBy').AsInteger := GetCurrentUserID;

    LQuery.ExecSQL;

    LQuery.SQL.Text := 'SELECT last_insert_rowid() AS NewID';
    LQuery.Open;
    Result := LQuery.FieldByName('NewID').AsInteger;
  finally
    LQuery.Free;
  end;
end;

procedure TConfigDataModule.UpdateConfig(ConfigID: Integer; const ConfigValue, Description: string;
  SortOrder: Integer);
var
  LQuery: TFDQuery;
  LValueType: TConfigValueType;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;

    // 获取配置以验证值类型
    LQuery.SQL.Text := 'SELECT ValueType FROM UniAdmin_Configs WHERE ConfigID = :ConfigID';
    LQuery.Params.ParamByName('ConfigID').AsInteger := ConfigID;
    LQuery.Open;

    if LQuery.Eof then
      raise Exception.Create('配置不存在');

    LValueType := ParseValueType(LQuery.FieldByName('ValueType').AsString);
    LQuery.Close;

    if not ValidateValue(ConfigValue, LValueType) then
      raise Exception.Create('配置值格式不正确');

    LQuery.SQL.Text :=
      'UPDATE UniAdmin_Configs ' +
      'SET ConfigValue = :ConfigValue, Description = :Description, SortOrder = :SortOrder, ' +
      'ModifiedDate = CURRENT_TIMESTAMP, ModifiedBy = :ModifiedBy ' +
      'WHERE ConfigID = :ConfigID';

    LQuery.Params.ParamByName('ConfigID').AsInteger := ConfigID;
    LQuery.Params.ParamByName('ConfigValue').AsString := ConfigValue;
    LQuery.Params.ParamByName('Description').AsString := Description;
    LQuery.Params.ParamByName('SortOrder').AsInteger := SortOrder;
    LQuery.Params.ParamByName('ModifiedBy').AsInteger := GetCurrentUserID;

    LQuery.ExecSQL;

    if LQuery.RowsAffected = 0 then
      raise Exception.Create('配置不存在');
  finally
    LQuery.Free;
  end;
end;

procedure TConfigDataModule.DeleteConfig(ConfigID: Integer);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text := 'DELETE FROM UniAdmin_Configs WHERE ConfigID = :ConfigID';
    LQuery.Params.ParamByName('ConfigID').AsInteger := ConfigID;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

procedure TConfigDataModule.SetConfigStatus(ConfigID, Status: Integer);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'UPDATE UniAdmin_Configs ' +
      'SET Status = :Status, ModifiedDate = CURRENT_TIMESTAMP, ModifiedBy = :ModifiedBy ' +
      'WHERE ConfigID = :ConfigID';

    LQuery.Params.ParamByName('ConfigID').AsInteger := ConfigID;
    LQuery.Params.ParamByName('Status').AsInteger := Status;
    LQuery.Params.ParamByName('ModifiedBy').AsInteger := GetCurrentUserID;

    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

function TConfigDataModule.ConfigKeyExists(const ConfigKey: string; ExcludeID: Integer): Boolean;
var
  LQuery: TFDQuery;
  LSQL: string;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;

    LSQL := 'SELECT COUNT(*) AS Cnt FROM UniAdmin_Configs WHERE ConfigKey = :ConfigKey';

    if ExcludeID > 0 then
      LSQL := LSQL + ' AND ConfigID <> :ExcludeID';

    LQuery.SQL.Text := LSQL;
    LQuery.Params.ParamByName('ConfigKey').AsString := ConfigKey;

    if ExcludeID > 0 then
      LQuery.Params.ParamByName('ExcludeID').AsInteger := ExcludeID;

    LQuery.Open;
    Result := LQuery.FieldByName('Cnt').AsInteger > 0;
  finally
    LQuery.Free;
  end;
end;

function TConfigDataModule.GetCategories: TArray<TConfigCategoryInfo>;
var
  LQuery: TFDQuery;
  LList: TList<TConfigCategoryInfo>;
  LInfo: TConfigCategoryInfo;
begin
  LQuery := TFDQuery.Create(nil);
  LList := TList<TConfigCategoryInfo>.Create;
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'SELECT Category, COUNT(*) AS ConfigCount ' +
      'FROM UniAdmin_Configs ' +
      'WHERE Status = 1 ' +
      'GROUP BY Category ' +
      'ORDER BY Category';

    LQuery.Open;

    while not LQuery.Eof do
    begin
      LInfo.Category := LQuery.FieldByName('Category').AsString;
      LInfo.CategoryName := GetCategoryName(LInfo.Category);
      LInfo.Description := '';
      LInfo.ConfigCount := LQuery.FieldByName('ConfigCount').AsInteger;
      LList.Add(LInfo);
      LQuery.Next;
    end;

    Result := LList.ToArray;
  finally
    LQuery.Free;
    LList.Free;
  end;
end;

function TConfigDataModule.GetConfigValue(const ConfigKey: string): string;
var
  LQuery: TFDQuery;
begin
  Result := '';

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'SELECT ConfigValue FROM UniAdmin_Configs ' +
      'WHERE ConfigKey = :ConfigKey AND Status = 1';

    LQuery.Params.ParamByName('ConfigKey').AsString := ConfigKey;
    LQuery.Open;

    if not LQuery.Eof then
      Result := LQuery.FieldByName('ConfigValue').AsString;
  finally
    LQuery.Free;
  end;
end;

function TConfigDataModule.GetConfigValueAsInteger(const ConfigKey: string; Default: Integer): Integer;
var
  LValue: string;
begin
  LValue := GetConfigValue(ConfigKey);
  if LValue.IsEmpty then
    Result := Default
  else
  begin
    if not TryStrToInt(LValue, Result) then
      Result := Default;
  end;
end;

function TConfigDataModule.GetConfigValueAsBoolean(const ConfigKey: string; Default: Boolean): Boolean;
var
  LValue: string;
begin
  LValue := GetConfigValue(ConfigKey);
  if LValue.IsEmpty then
    Result := Default
  else
  begin
    Result := (LValue.ToLower = 'true') or (LValue = '1');
  end;
end;

procedure TConfigDataModule.SetConfigValue(const ConfigKey, ConfigValue: string);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;

    // 检查配置是否存在
    LQuery.SQL.Text := 'SELECT ConfigID FROM UniAdmin_Configs WHERE ConfigKey = :ConfigKey';
    LQuery.Params.ParamByName('ConfigKey').AsString := ConfigKey;
    LQuery.Open;

    if LQuery.Eof then
      raise Exception.CreateFmt('配置 %s 不存在', [ConfigKey]);

    LQuery.Close;

    // 更新配置值
    LQuery.SQL.Text :=
      'UPDATE UniAdmin_Configs ' +
      'SET ConfigValue = :ConfigValue, ModifiedDate = CURRENT_TIMESTAMP, ModifiedBy = :ModifiedBy ' +
      'WHERE ConfigKey = :ConfigKey';

    LQuery.Params.ParamByName('ConfigKey').AsString := ConfigKey;
    LQuery.Params.ParamByName('ConfigValue').AsString := ConfigValue;
    LQuery.Params.ParamByName('ModifiedBy').AsInteger := GetCurrentUserID;

    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

function TConfigDataModule.GetValueTypeText(ValueType: TConfigValueType): string;
begin
  case ValueType of
    cvtString: Result := 'string';
    cvtInteger: Result := 'integer';
    cvtBoolean: Result := 'boolean';
    cvtFloat: Result := 'float';
    cvtJson: Result := 'json';
    cvtXml: Result := 'xml';
    else
      Result := 'string';
  end;
end;

function TConfigDataModule.ParseValueType(const ValueTypeText: string): TConfigValueType;
begin
  if ValueTypeText = 'integer' then
    Result := cvtInteger
  else if ValueTypeText = 'boolean' then
    Result := cvtBoolean
  else if ValueTypeText = 'float' then
    Result := cvtFloat
  else if ValueTypeText = 'json' then
    Result := cvtJson
  else if ValueTypeText = 'xml' then
    Result := cvtXml
  else
    Result := cvtString;
end;

function TConfigDataModule.ValidateValue(const Value: string; ValueType: TConfigValueType): Boolean;
var
  LTemp: Integer;
  LTempFloat: Double;
begin
  Result := True;

  case ValueType of
    cvtInteger:
      Result := Value.IsEmpty or TryStrToInt(Value, LTemp);
    cvtBoolean:
      Result := Value.IsEmpty or
                (Value.ToLower = 'true') or (Value.ToLower = 'false') or
                (Value = '1') or (Value = '0');
    cvtFloat:
      Result := Value.IsEmpty or TryStrToFloat(Value, LTempFloat);
    // string, json, xml 不验证格式
  end;
end;

function TConfigDataModule.GetCategoryName(const Category: string): string;
begin
  // 预定义的分类名称
  if Category = 'System' then
    Result := '系统设置'
  else if Category = 'Security' then
    Result := '安全设置'
  else if Category = 'Email' then
    Result := '邮件设置'
  else if Category = 'SMS' then
    Result := '短信设置'
  else if Category = 'Storage' then
    Result := '存储设置'
  else
    Result := Category;
end;

end.

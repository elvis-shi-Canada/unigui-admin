unit ConfigService;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Generics.Collections,
  Data.DB,
  UniContext, UniPlugin.Types,
  ConfigService.Intf, ConfigDataModule;

type
  /// <summary>
  /// 配置服务类 - 系统配置业务逻辑实现
  /// </summary>
  TConfigService = class(TInterfacedObject, IConfigService)
  private
    FContext: IExecutionContext;
    FDataModule: TConfigDataModule;
    FConfigCache: TDictionary<string, string>;

    procedure InitializeDataModule;
    procedure FinalizeDataModule;
    procedure InitializeCache;
    procedure FinalizeCache;
    function DataSetToConfigInfo(const DataSet: TDataSet): TConfigInfo;
    function GetStatusText(Status: Integer): string;
    function GetCategoryName(const Category: string): string;
    procedure LoadConfigCache;
    procedure RefreshConfigCache(const ConfigKey: string = '');
  public
    constructor Create(const Context: IExecutionContext); reintroduce;
    destructor Destroy; override;

    // 配置操作
    function GetConfigs(const Filter, Category: string; Status: Integer): TArray<TConfigInfo>;
    function GetConfigByID(ConfigID: Integer): TConfigInfo;
    function GetConfigByKey(const ConfigKey: string): TConfigInfo;
    function GetConfigsByCategory(const Category: string; Status: Integer): TArray<TConfigInfo>;
    function CreateConfig(const ConfigKey, ConfigValue, Category, Description: string;
      ValueType: TConfigValueType; SortOrder: Integer): Integer;
    procedure UpdateConfig(ConfigID: Integer; const ConfigValue, Description: string;
      SortOrder: Integer);
    procedure DeleteConfig(ConfigID: Integer);
    procedure SetConfigStatus(ConfigID, Status: Integer);

    // 配置分类
    function GetCategories: TArray<TConfigCategoryInfo>;

    // 配置值访问
    function GetValue(const ConfigKey: string): string;
    procedure SetValue(const ConfigKey, ConfigValue: string);
    function GetValueAsInteger(const ConfigKey: string; Default: Integer = 0): Integer;
    function GetValueAsBoolean(const ConfigKey: string; Default: Boolean = False): Boolean;

    // 缓存管理
    procedure ClearCache;
    procedure RefreshCache(const ConfigKey: string = '');
  end;

implementation

{ TConfigService }

constructor TConfigService.Create(const Context: IExecutionContext);
begin
  inherited Create;
  FContext := Context;
  InitializeDataModule;
  InitializeCache;
  LoadConfigCache;
end;

destructor TConfigService.Destroy;
begin
  FinalizeCache;
  FinalizeDataModule;
  inherited;
end;

procedure TConfigService.InitializeDataModule;
begin
  FDataModule := TConfigDataModule.Create(nil);
  if Supports(FDataModule, IContextAware) then
    (FDataModule as IContextAware).SetContext(FContext);
  FDataModule.Open;
end;

procedure TConfigService.FinalizeDataModule;
begin
  if Assigned(FDataModule) then
  begin
    FDataModule.Close;
    FDataModule.Free;
  end;
end;

procedure TConfigService.InitializeCache;
begin
  FConfigCache := TDictionary<string, string>.Create;
end;

procedure TConfigService.FinalizeCache;
begin
  if Assigned(FConfigCache) then
  begin
    FConfigCache.Clear;
    FConfigCache.Free;
  end;
end;

procedure TConfigService.LoadConfigCache;
var
  LDataSet: TDataSet;
begin
  FConfigCache.Clear;

  LDataSet := FDataModule.GetConfigs('', '', 1);
  try
    while not LDataSet.Eof do
    begin
      FConfigCache.Add(
        LDataSet.FieldByName('ConfigKey').AsString,
        LDataSet.FieldByName('ConfigValue').AsString
      );
      LDataSet.Next;
    end;
  finally
    LDataSet.Free;
  end;
end;

procedure TConfigService.RefreshConfigCache(const ConfigKey: string);
begin
  if ConfigKey.IsEmpty then
    LoadConfigCache
  else
  begin
    if FConfigCache.ContainsKey(ConfigKey) then
      FConfigCache.Remove(ConfigKey);
    FConfigCache.Add(ConfigKey, FDataModule.GetConfigValue(ConfigKey));
  end;
end;

function TConfigService.DataSetToConfigInfo(const DataSet: TDataSet): TConfigInfo;
begin
  Result.ConfigID := DataSet.FieldByName('ConfigID').AsInteger;
  Result.ConfigKey := DataSet.FieldByName('ConfigKey').AsString;
  Result.ConfigValue := DataSet.FieldByName('ConfigValue').AsString;
  Result.Category := DataSet.FieldByName('Category').AsString;
  Result.CategoryName := GetCategoryName(Result.Category);
  Result.Description := DataSet.FieldByName('Description').AsString;

  if DataSet.FieldByName('ValueType').AsString = 'integer' then
    Result.ValueType := cvtInteger
  else if DataSet.FieldByName('ValueType').AsString = 'boolean' then
    Result.ValueType := cvtBoolean
  else if DataSet.FieldByName('ValueType').AsString = 'float' then
    Result.ValueType := cvtFloat
  else if DataSet.FieldByName('ValueType').AsString = 'json' then
    Result.ValueType := cvtJson
  else if DataSet.FieldByName('ValueType').AsString = 'xml' then
    Result.ValueType := cvtXml
  else
    Result.ValueType := cvtString;

  Result.ValueTypeText := DataSet.FieldByName('ValueType').AsString;
  Result.SortOrder := DataSet.FieldByName('SortOrder').AsInteger;
  Result.Status := DataSet.FieldByName('Status').AsInteger;
  Result.StatusText := GetStatusText(Result.Status);

  if not DataSet.FieldByName('CreatedDate').IsNull then
    Result.CreatedDate := DataSet.FieldByName('CreatedDate').AsDateTime
  else
    Result.CreatedDate := 0;

  Result.CreatedBy := DataSet.FieldByName('CreatedBy').AsInteger;

  if not DataSet.FieldByName('ModifiedDate').IsNull then
    Result.ModifiedDate := DataSet.FieldByName('ModifiedDate').AsDateTime
  else
    Result.ModifiedDate := 0;

  Result.ModifiedBy := DataSet.FieldByName('ModifiedBy').AsInteger;
end;

function TConfigService.GetStatusText(Status: Integer): string;
begin
  case Status of
    0: Result := '禁用';
    1: Result := '启用';
    else
      Result := '未知';
  end;
end;

function TConfigService.GetCategoryName(const Category: string): string;
begin
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

function TConfigService.GetConfigs(const Filter, Category: string; Status: Integer): TArray<TConfigInfo>;
var
  LDataSet: TDataSet;
  LList: TList<TConfigInfo>;
begin
  LList := TList<TConfigInfo>.Create;
  try
    LDataSet := FDataModule.GetConfigs(Filter, Category, Status);
    try
      while not LDataSet.Eof do
      begin
        LList.Add(DataSetToConfigInfo(LDataSet));
        LDataSet.Next;
      end;
      Result := LList.ToArray;
    finally
      LDataSet.Free;
    end;
  finally
    LList.Free;
  end;
end;

function TConfigService.GetConfigByID(ConfigID: Integer): TConfigInfo;
var
  LDataSet: TDataSet;
begin
  LDataSet := FDataModule.GetConfigByID(ConfigID);
  try
    if not LDataSet.Eof then
      Result := DataSetToConfigInfo(LDataSet)
    else
      raise Exception.CreateFmt('配置 ID %d 不存在', [ConfigID]);
  finally
    LDataSet.Free;
  end;
end;

function TConfigService.GetConfigByKey(const ConfigKey: string): TConfigInfo;
var
  LDataSet: TDataSet;
begin
  LDataSet := FDataModule.GetConfigByKey(ConfigKey);
  try
    if not LDataSet.Eof then
      Result := DataSetToConfigInfo(LDataSet)
    else
      raise Exception.CreateFmt('配置 %s 不存在', [ConfigKey]);
  finally
    LDataSet.Free;
  end;
end;

function TConfigService.GetConfigsByCategory(const Category: string; Status: Integer): TArray<TConfigInfo>;
var
  LDataSet: TDataSet;
  LList: TList<TConfigInfo>;
begin
  LList := TList<TConfigInfo>.Create;
  try
    LDataSet := FDataModule.GetConfigsByCategory(Category, Status);
    try
      while not LDataSet.Eof do
      begin
        LList.Add(DataSetToConfigInfo(LDataSet));
        LDataSet.Next;
      end;
      Result := LList.ToArray;
    finally
      LDataSet.Free;
    end;
  finally
    LList.Free;
  end;
end;

function TConfigService.CreateConfig(const ConfigKey, ConfigValue, Category, Description: string;
  ValueType: TConfigValueType; SortOrder: Integer): Integer;
begin
  Result := FDataModule.CreateConfig(ConfigKey, ConfigValue, Category, Description, ValueType, SortOrder);
  RefreshCache(ConfigKey);
end;

procedure TConfigService.UpdateConfig(ConfigID: Integer; const ConfigValue, Description: string;
  SortOrder: Integer);
var
  LConfig: TConfigInfo;
begin
  LConfig := GetConfigByID(ConfigID);
  FDataModule.UpdateConfig(ConfigID, ConfigValue, Description, SortOrder);
  RefreshCache(LConfig.ConfigKey);
end;

procedure TConfigService.DeleteConfig(ConfigID: Integer);
var
  LConfig: TConfigInfo;
begin
  LConfig := GetConfigByID(ConfigID);
  FDataModule.DeleteConfig(ConfigID);
  RefreshCache(LConfig.ConfigKey);
end;

procedure TConfigService.SetConfigStatus(ConfigID, Status: Integer);
var
  LConfig: TConfigInfo;
begin
  LConfig := GetConfigByID(ConfigID);
  FDataModule.SetConfigStatus(ConfigID, Status);
  RefreshCache(LConfig.ConfigKey);
end;

function TConfigService.GetCategories: TArray<TConfigCategoryInfo>;
begin
  Result := FDataModule.GetCategories;
end;

function TConfigService.GetValue(const ConfigKey: string): string;
begin
  if FConfigCache.ContainsKey(ConfigKey) then
    Result := FConfigCache[ConfigKey]
  else
  begin
    Result := FDataModule.GetConfigValue(ConfigKey);
    if not Result.IsEmpty then
      FConfigCache.Add(ConfigKey, Result);
  end;
end;

procedure TConfigService.SetValue(const ConfigKey, ConfigValue: string);
begin
  FDataModule.SetConfigValue(ConfigKey, ConfigValue);
  RefreshCache(ConfigKey);
end;

function TConfigService.GetValueAsInteger(const ConfigKey: string; Default: Integer): Integer;
var
  LValue: string;
begin
  LValue := GetValue(ConfigKey);
  if LValue.IsEmpty then
    Result := Default
  else
  begin
    if not TryStrToInt(LValue, Result) then
      Result := Default;
  end;
end;

function TConfigService.GetValueAsBoolean(const ConfigKey: string; Default: Boolean): Boolean;
var
  LValue: string;
begin
  LValue := GetValue(ConfigKey);
  if LValue.IsEmpty then
    Result := Default
  else
  begin
    Result := (LValue.ToLower = 'true') or (LValue = '1');
  end;
end;

procedure TConfigService.ClearCache;
begin
  LoadConfigCache;
end;

procedure TConfigService.RefreshCache(const ConfigKey: string);
begin
  if ConfigKey.IsEmpty then
    LoadConfigCache
  else
  begin
    if FConfigCache.ContainsKey(ConfigKey) then
      FConfigCache.Remove(ConfigKey);
    FConfigCache.Add(ConfigKey, FDataModule.GetConfigValue(ConfigKey));
  end;
end;

end.

unit UniAdminConfigService;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.IOUtils,
  System.JSON, System.SyncObjs, System.Variants,
  UniAdminConfigService.Intf, System.VarUtils;

type
  /// <summary>
  /// 模块配置实现类
  /// 提供单个模块的配置存储和管理
  /// </summary>
  TModuleConfig = class(TInterfacedObject, IModuleConfig)
  private
    FModuleName: string;
    FConfigFile: string;
    FConfigValues: TDictionary<string, Variant>;
    FConfigTypes: TDictionary<string, TConfigValueType>;
    FChangeHandlers: TList<TConfigChangeEvent>;
    FCriticalSection: TCriticalSection;
    FIsModified: Boolean;

    procedure DoChangeNotify(const Key: string; const OldValue, NewValue: Variant);
    function GetVariantType(const Value: Variant): TConfigValueType;
    function VariantToJSON(const Value: Variant; ValueType: TConfigValueType): TJSONValue;
    function JSONToVariant(const JSONValue: TJSONValue; out ValueType: TConfigValueType): Variant;
    procedure InternalClear;
  public
    constructor Create(const ModuleName, ConfigFile: string);
    destructor Destroy; override;

    // IModuleConfig 实现
    function GetModuleName: string;
    function GetConfigFile: string;
    function GetAllKeys: TArray<string>;
    function KeyExists(const Key: string): Boolean;
    function GetString(const Key: string; const DefaultValue: string = ''): string;
    function GetInteger(const Key: string; const DefaultValue: Integer = 0): Integer;
    function GetBoolean(const Key: string; const DefaultValue: Boolean = False): Boolean;
    function GetFloat(const Key: string; const DefaultValue: Double = 0.0): Double;
    function GetDateTime(const Key: string; const DefaultValue: TDateTime = 0): TDateTime;
    function GetStringList(const Key: string): TStringList;
    procedure SetValue(const Key, Value: string); overload;
    procedure SetValue(const Key: string; Value: Integer); overload;
    procedure SetValue(const Key: string; Value: Boolean); overload;
    procedure SetValue(const Key: string; Value: Double); overload;
    procedure SetValue(const Key: string; Value: TDateTime); overload;
    procedure SetStringList(const Key: string; Value: TStrings);
    procedure DeleteKey(const Key: string);
    procedure Clear;
    function LoadFromFile: Boolean;
    function SaveToFile: Boolean;
    procedure RegisterChangeHandler(const Event: TConfigChangeEvent);
    procedure UnregisterChangeHandler(const Event: TConfigChangeEvent);
  end;

  /// <summary>
  /// 统一配置服务实现类
  /// 全局单例，提供配置管理功能
  /// </summary>
  TUniAdminConfigService = class(TInterfacedObject, IUniAdminConfigService)
  private
    class var FInstance: IUniAdminConfigService;
    class var FCS: TCriticalSection;

    FConfigRoot: string;
    FGlobalConfigFile: string;
    FModuleConfigs: TDictionary<string, IModuleConfig>;
    FGlobalConfig: IModuleConfig;
    FGlobalChangeHandlers: TList<TConfigChangeEvent>;
    FCriticalSection: TCriticalSection;

    constructor CreateInstance;
    procedure Initialize;
    function GetModuleConfigFilePath(const ModuleName: string): string;
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>获取全局单例实例</summary>
    class function GetInstance: IUniAdminConfigService;
    /// <summary>释放全局单例实例</summary>
    class procedure ReleaseInstance;

    // IUniAdminConfigService 实现
    function GetConfigRoot: string;
    procedure SetConfigRoot(const Path: string);
    function GetGlobalConfigFile: string;
    function GetModuleConfig(const ModuleName: string): IModuleConfig;
    function HasModuleConfig(const ModuleName: string): Boolean;
    procedure RemoveModuleConfig(const ModuleName: string);
    function GetAllModuleNames: TArray<string>;
    function LoadGlobalConfig: Boolean;
    function SaveGlobalConfig: Boolean;
    function LoadAllModuleConfigs: Boolean;
    function SaveAllModuleConfigs: Boolean;
    function GetGlobalString(const Key: string; const DefaultValue: string = ''): string;
    function GetGlobalInteger(const Key: string; const DefaultValue: Integer = 0): Integer;
    function GetGlobalBoolean(const Key: string; const DefaultValue: Boolean = False): Boolean;
    procedure SetGlobalString(const Key, Value: string);
    procedure SetGlobalInteger(const Key: string; Value: Integer);
    procedure SetGlobalBoolean(const Key: string; Value: Boolean);
    procedure RegisterGlobalChangeHandler(const Event: TConfigChangeEvent);
    procedure UnregisterGlobalChangeHandler(const Event: TConfigChangeEvent);
    function Refresh: Boolean;
  end;

implementation

uses
  UniAdminLogger;

{ TModuleConfig }

constructor TModuleConfig.Create(const ModuleName, ConfigFile: string);
begin
  inherited Create;
  FModuleName := ModuleName;
  FConfigFile := ConfigFile;
  FConfigValues := TDictionary<string, Variant>.Create;
  FConfigTypes := TDictionary<string, TConfigValueType>.Create;
  FChangeHandlers := TList<TConfigChangeEvent>.Create;
  FCriticalSection := TCriticalSection.Create;
  FIsModified := False;
end;

destructor TModuleConfig.Destroy;
begin
  if FIsModified then
    SaveToFile;

  FChangeHandlers.Free;
  FConfigValues.Free;
  FConfigTypes.Free;
  FCriticalSection.Free;
  inherited;
end;

procedure TModuleConfig.DoChangeNotify(const Key: string; const OldValue, NewValue: Variant);
var
  Handler: TConfigChangeEvent;
begin
  FCriticalSection.Enter;
  try
    for Handler in FChangeHandlers do
    begin
      if Assigned(Handler) then
        Handler(FModuleName, Key, OldValue, NewValue);
    end;
  finally
    FCriticalSection.Leave;
  end;
end;

function TModuleConfig.GetVariantType(const Value: Variant): TConfigValueType;
begin
  Result := cvtString;
  case VarType(Value) of
    varString, varUString: Result := cvtString;
    varInteger, varByte, varSmallint, varShortInt, varInt64, varLongWord: Result := cvtInteger;
    varBoolean: Result := cvtBoolean;
    varSingle, varDouble, varCurrency: Result := cvtFloat;
    varDate: Result := cvtDateTime;
  end;
end;

function TModuleConfig.VariantToJSON(const Value: Variant; ValueType: TConfigValueType): TJSONValue;
var
  List: TStringList;
  i: Integer;
  JSONArray: TJSONArray;
begin
  Result := nil;
  case ValueType of
    cvtString:
      Result := TJSONString.Create(VarToStr(Value));
    cvtInteger:
      Result := TJSONNumber.Create(Integer(Value));
    cvtBoolean:
      Result := TJSONBool.Create(Boolean(Value));
    cvtFloat:
      Result := TJSONNumber.Create(Double(Value));
    cvtDateTime:
      Result := TJSONString.Create(FormatDateTime('yyyy-mm-dd hh:nn:ss', VarToDateTime(Value)));
    cvtStringList:
      begin
        JSONArray := TJSONArray.Create;
        try
          if VarIsType(Value, varString) then
          begin
            List := TStringList.Create;
            try
              List.CommaText := VarToStr(Value);
              for i := 0 to List.Count - 1 do
                JSONArray.Add(List[i]);
            finally
              List.Free;
            end;
          end;
          Result := JSONArray;
        except
          JSONArray.Free;
          raise;
        end;
      end;
    cvtObject:
      Result := TJSONObject.ParseJSONValue(VarToStr(Value));
  end;

  if Result = nil then
    Result := TJSONNull.Create;
end;

function TModuleConfig.JSONToVariant(const JSONValue: TJSONValue; out ValueType: TConfigValueType): Variant;
var
  JSONArray: TJSONArray;
  i: Integer;
  List: string;
begin
  Result := Null;
  ValueType := cvtString;

  if JSONValue is TJSONString then
  begin
    Result := JSONValue.Value;
    ValueType := cvtString;
  end
  else if JSONValue is TJSONNumber then
  begin
    Result := TJSONNumber(JSONValue).AsDouble;
    if Frac(Result) = 0 then
    begin
      Result := Trunc(Result);
      ValueType := cvtInteger;
    end
    else
      ValueType := cvtFloat;
  end
  else if JSONValue is TJSONBool then
  begin
    Result := TJSONBool(JSONValue).AsBoolean;
    ValueType := cvtBoolean;
  end
  else if JSONValue is TJSONTrue then
  begin
    Result := True;
    ValueType := cvtBoolean;
  end
  else if JSONValue is TJSONFalse then
  begin
    Result := False;
    ValueType := cvtBoolean;
  end
  else if JSONValue is TJSONArray then
  begin
    JSONArray := TJSONArray(JSONValue);
    List := '';
    for i := 0 to JSONArray.Count - 1 do
    begin
      if i > 0 then
        List := List + ',';
      if JSONArray[i] is TJSONString then
        List := List + JSONArray[i].Value
      else
        List := List + JSONArray[i].ToString;
    end;
    Result := List;
    ValueType := cvtStringList;
  end
  else if JSONValue is TJSONObject then
  begin
    Result := JSONValue.ToString;
    ValueType := cvtObject;
  end
  else if JSONValue is TJSONNull then
  begin
    Result := '';
    ValueType := cvtString;
  end;
end;

function TModuleConfig.GetModuleName: string;
begin
  Result := FModuleName;
end;

function TModuleConfig.GetConfigFile: string;
begin
  Result := FConfigFile;
end;

function TModuleConfig.GetAllKeys: TArray<string>;
begin
  FCriticalSection.Enter;
  try
    Result := FConfigValues.Keys.ToArray;
  finally
    FCriticalSection.Leave;
  end;
end;

function TModuleConfig.KeyExists(const Key: string): Boolean;
begin
  FCriticalSection.Enter;
  try
    Result := FConfigValues.ContainsKey(Key);
  finally
    FCriticalSection.Leave;
  end;
end;

function TModuleConfig.GetString(const Key: string; const DefaultValue: string): string;
var
  Value: Variant;
  Parts: TArray<string>;
  RootJSON, Node: TJSONValue;
  i: Integer;
begin
  FCriticalSection.Enter;
  try
    // 1. 直接查完整键（向后兼容）
    if FConfigValues.TryGetValue(Key, Value) then
      Exit(VarToStr(Value));

    // 2. 点号路径：解析嵌套 JSON 对象（如 'database.connectionString'）
    //    LoadFromFile 把嵌套对象存为顶层键→JSON 字符串，需逐段深入
    if Pos('.', Key) > 0 then
    begin
      Parts := Key.Split(['.']);
      if FConfigValues.TryGetValue(Parts[0], Value) then
      begin
        RootJSON := TJSONObject.ParseJSONValue(VarToStr(Value));
        try
          Node := RootJSON;
          for i := 1 to High(Parts) do
          begin
            if (Node is TJSONObject) and (TJSONObject(Node).Values[Parts[i]] <> nil) then
              Node := TJSONObject(Node).Values[Parts[i]]
            else
            begin
              Node := nil;
              Break;
            end;
          end;
          if Node <> nil then
            Exit(Node.Value);
        finally
          RootJSON.Free;
        end;
      end;
    end;

    Result := DefaultValue;
  finally
    FCriticalSection.Leave;
  end;
end;

function TModuleConfig.GetInteger(const Key: string; const DefaultValue: Integer): Integer;
var
  Value: Variant;
begin
  FCriticalSection.Enter;
  try
    if not FConfigValues.TryGetValue(Key, Value) then
      Result := DefaultValue
    else if VarType(Value) <> varInteger then
      Result := StrToIntDef(VarToStr(Value), DefaultValue)
    else
      Result := Value;
  finally
    FCriticalSection.Leave;
  end;
end;

function TModuleConfig.GetBoolean(const Key: string; const DefaultValue: Boolean): Boolean;
var
  Value: Variant;
begin
  FCriticalSection.Enter;
  try
    if not FConfigValues.TryGetValue(Key, Value) then
      Result := DefaultValue
    else if VarType(Value) <> varBoolean then
      Result := StrToBoolDef(VarToStr(Value), DefaultValue)
    else
      Result := Value;
  finally
    FCriticalSection.Leave;
  end;
end;

function TModuleConfig.GetFloat(const Key: string; const DefaultValue: Double): Double;
var
  Value: Variant;
begin
  FCriticalSection.Enter;
  try
    if not FConfigValues.TryGetValue(Key, Value) then
      Result := DefaultValue
    else if VarType(Value) <> varDouble then
      Result := StrToFloatDef(VarToStr(Value), DefaultValue)
    else
      Result := Value;
  finally
    FCriticalSection.Leave;
  end;
end;

function TModuleConfig.GetDateTime(const Key: string; const DefaultValue: TDateTime): TDateTime;
var
  StrValue: string;
  Value: Variant;
begin
  FCriticalSection.Enter;
  try
    if not FConfigValues.TryGetValue(Key, Value) then
      Result := DefaultValue
    else
    begin
      if VarType(Value) = varDate then
        Result := Value
      else
      begin
        StrValue := VarToStr(Value);
        if TryStrToDateTime(StrValue, Result) then
          Exit
        else
          Result := DefaultValue;
      end;
    end;
  finally
    FCriticalSection.Leave;
  end;
end;

function TModuleConfig.GetStringList(const Key: string): TStringList;
var
  Value: Variant;
begin
  Result := TStringList.Create;
  try
    FCriticalSection.Enter;
    try
      if FConfigValues.TryGetValue(Key, Value) then
        Result.CommaText := VarToStr(Value);
    finally
      FCriticalSection.Leave;
    end;
  except
    Result.Free;
    raise;
  end;
end;

procedure TModuleConfig.SetValue(const Key, Value: string);
var
  OldValue: Variant;
begin
  FCriticalSection.Enter;
  try
    if FConfigValues.TryGetValue(Key, OldValue) and (OldValue = Value) then
      Exit;

    FConfigValues[Key] := Value;
    FConfigTypes[Key] := cvtString;
    FIsModified := True;
    DoChangeNotify(Key, OldValue, Value);
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TModuleConfig.SetValue(const Key: string; Value: Integer);
var
  OldValue: Variant;
begin
  FCriticalSection.Enter;
  try
    if FConfigValues.TryGetValue(Key, OldValue) and (OldValue = Value) then
      Exit;

    FConfigValues[Key] := Value;
    FConfigTypes[Key] := cvtInteger;
    FIsModified := True;
    DoChangeNotify(Key, OldValue, Value);
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TModuleConfig.SetValue(const Key: string; Value: Boolean);
var
  OldValue: Variant;
begin
  FCriticalSection.Enter;
  try
    if FConfigValues.TryGetValue(Key, OldValue) and (OldValue = Value) then
      Exit;

    FConfigValues[Key] := Value;
    FConfigTypes[Key] := cvtBoolean;
    FIsModified := True;
    DoChangeNotify(Key, OldValue, Value);
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TModuleConfig.SetValue(const Key: string; Value: Double);
var
  OldValue: Variant;
begin
  FCriticalSection.Enter;
  try
    if FConfigValues.TryGetValue(Key, OldValue) and (OldValue = Value) then
      Exit;

    FConfigValues[Key] := Value;
    FConfigTypes[Key] := cvtFloat;
    FIsModified := True;
    DoChangeNotify(Key, OldValue, Value);
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TModuleConfig.SetValue(const Key: string; Value: TDateTime);
var
  OldValue: Variant;
begin
  FCriticalSection.Enter;
  try
    if FConfigValues.TryGetValue(Key, OldValue) and (OldValue = Value) then
      Exit;

    FConfigValues[Key] := Value;
    FConfigTypes[Key] := cvtDateTime;
    FIsModified := True;
    DoChangeNotify(Key, OldValue, Value);
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TModuleConfig.SetStringList(const Key: string; Value: TStrings);
var
  OldValue: Variant;
  NewValue: string;
begin
  if Value = nil then
    raise EArgumentException.Create('Value cannot be nil');

  NewValue := Value.CommaText;

  FCriticalSection.Enter;
  try
    if FConfigValues.TryGetValue(Key, OldValue) and (OldValue = NewValue) then
      Exit;

    FConfigValues[Key] := NewValue;
    FConfigTypes[Key] := cvtStringList;
    FIsModified := True;
    DoChangeNotify(Key, OldValue, NewValue);
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TModuleConfig.DeleteKey(const Key: string);
var
  OldValue: Variant;
begin
  FCriticalSection.Enter;
  try
    if FConfigValues.TryGetValue(Key, OldValue) then
    begin
      FConfigValues.Remove(Key);
      FConfigTypes.Remove(Key);
      FIsModified := True;
      DoChangeNotify(Key, OldValue, Null);
    end;
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TModuleConfig.Clear;
begin
  FCriticalSection.Enter;
  try
    InternalClear;
    FIsModified := True;
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TModuleConfig.InternalClear;
begin
  FConfigValues.Clear;
  FConfigTypes.Clear;
end;

function TModuleConfig.LoadFromFile: Boolean;
var
  JSONString: string;
  JSONObject: TJSONObject;
  Pair: TJSONPair;
  Key: string;
  ValueType: TConfigValueType;
  Value: Variant;
begin
  Result := False;

  if not TFile.Exists(FConfigFile) then
    Exit(True);

  try
    JSONString := TFile.ReadAllText(FConfigFile, TEncoding.UTF8);
    if JSONString.Trim.IsEmpty then
      Exit(True);

    JSONObject := TJSONObject.ParseJSONValue(JSONString) as TJSONObject;
    if JSONObject = nil then
      raise EConvertError.Create('Invalid JSON format in config file: ' + FConfigFile);

    FCriticalSection.Enter;
    try
      InternalClear;
      for Pair in JSONObject do
      begin
        Key := Pair.JsonString.Value;
        Value := JSONToVariant(Pair.JsonValue, ValueType);
        FConfigValues.Add(Key, Value);
        FConfigTypes.Add(Key, ValueType);
      end;
      FIsModified := False;
      Result := True;
    finally
      FCriticalSection.Leave;
    end;
  except
    on E: Exception do
    begin
      // 记录错误日志或抛出异常
      Result := False;
    end;
  end;
end;

function TModuleConfig.SaveToFile: Boolean;
var
  JSONObject: TJSONObject;
  Pair: TPair<string, Variant>;
  Key: string;
  ValueType: TConfigValueType;
  JSONValue: TJSONValue;
begin
  Result := False;

  try
    // 确保目录存在
    if not TDirectory.Exists(ExtractFilePath(FConfigFile)) then
      TDirectory.CreateDirectory(ExtractFilePath(FConfigFile));

    JSONObject := TJSONObject.Create;
    try
      FCriticalSection.Enter;
      try
        for Pair in FConfigValues do
        begin
          Key := Pair.Key;
          if FConfigTypes.TryGetValue(Key, ValueType) then
            JSONValue := VariantToJSON(Pair.Value, ValueType)
          else
            JSONValue := VariantToJSON(Pair.Value, GetVariantType(Pair.Value));

          if JSONValue <> nil then
            JSONObject.AddPair(Key, JSONValue);
        end;
      finally
        FCriticalSection.Leave;
      end;

      TFile.WriteAllText(FConfigFile, JSONObject.ToString, TEncoding.UTF8);
      FIsModified := False;
      Result := True;
    finally
      JSONObject.Free;
    end;
  except
    on E: Exception do
    begin
      Result := False;
    end;
  end;
end;

procedure TModuleConfig.RegisterChangeHandler(const Event: TConfigChangeEvent);
begin
  FCriticalSection.Enter;
  try
    if not FChangeHandlers.Contains(Event) then
      FChangeHandlers.Add(Event);
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TModuleConfig.UnregisterChangeHandler(const Event: TConfigChangeEvent);
begin
  FCriticalSection.Enter;
  try
    FChangeHandlers.Remove(Event);
  finally
    FCriticalSection.Leave;
  end;
end;

{ TUniAdminConfigService }

constructor TUniAdminConfigService.Create;
begin
  raise Exception.Create('Use GetInstance to get the global instance of TUniAdminConfigService');
end;

constructor TUniAdminConfigService.CreateInstance;
begin
  inherited Create;
  FCriticalSection := TCriticalSection.Create;
  FModuleConfigs := TDictionary<string, IModuleConfig>.Create;
  FGlobalChangeHandlers := TList<TConfigChangeEvent>.Create;
  Initialize;
end;

destructor TUniAdminConfigService.Destroy;
begin
  FGlobalChangeHandlers.Free;
  FModuleConfigs.Free;
  FCriticalSection.Free;
  inherited;
end;

class function TUniAdminConfigService.GetInstance: IUniAdminConfigService;
begin
  if FInstance = nil then
  begin
    FCS.Enter;
    try
      if FInstance = nil then
      begin
        FInstance := TUniAdminConfigService.CreateInstance;
      end;
    finally
      FCS.Leave;
    end;
  end;
  Result := FInstance;
end;

class procedure TUniAdminConfigService.ReleaseInstance;
begin
  FCS.Enter;
  try
    FInstance := nil;
  finally
    FCS.Leave;
  end;
end;

procedure TUniAdminConfigService.Initialize;
begin
  // 默认配置目录为程序目录下的 Config 文件夹
  FConfigRoot := TPath.Combine(ExtractFilePath(ParamStr(0)), 'Config');
  FGlobalConfigFile := TPath.Combine(FConfigRoot, 'app.json');

  // 确保配置目录存在
  if not TDirectory.Exists(FConfigRoot) then
    TDirectory.CreateDirectory(FConfigRoot);

  // 创建全局配置
  FGlobalConfig := TModuleConfig.Create('_Global', FGlobalConfigFile);
end;

function TUniAdminConfigService.GetModuleConfigFilePath(const ModuleName: string): string;
begin
  Result := TPath.Combine(FConfigRoot, ModuleName + '.json');
end;

function TUniAdminConfigService.GetConfigRoot: string;
begin
  FCriticalSection.Enter;
  try
    Result := FConfigRoot;
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TUniAdminConfigService.SetConfigRoot(const Path: string);
begin
  FCriticalSection.Enter;
  try
    FConfigRoot := Path;
    FGlobalConfigFile := TPath.Combine(FConfigRoot, 'app.json');

    // 确保目录存在
    if not TDirectory.Exists(FConfigRoot) then
      TDirectory.CreateDirectory(FConfigRoot);
  finally
    FCriticalSection.Leave;
  end;
end;

function TUniAdminConfigService.GetGlobalConfigFile: string;
begin
  Result := FGlobalConfigFile;
end;

function TUniAdminConfigService.GetModuleConfig(const ModuleName: string): IModuleConfig;
begin
  FCriticalSection.Enter;
  try
    if not FModuleConfigs.TryGetValue(ModuleName, Result) then
    begin
      Result := TModuleConfig.Create(ModuleName, GetModuleConfigFilePath(ModuleName));
      FModuleConfigs.Add(ModuleName, Result);
    end;
  finally
    FCriticalSection.Leave;
  end;
end;

function TUniAdminConfigService.HasModuleConfig(const ModuleName: string): Boolean;
begin
  FCriticalSection.Enter;
  try
    Result := FModuleConfigs.ContainsKey(ModuleName);
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TUniAdminConfigService.RemoveModuleConfig(const ModuleName: string);
begin
  FCriticalSection.Enter;
  try
    FModuleConfigs.Remove(ModuleName);
  finally
    FCriticalSection.Leave;
  end;
end;

function TUniAdminConfigService.GetAllModuleNames: TArray<string>;
begin
  FCriticalSection.Enter;
  try
    Result := FModuleConfigs.Keys.ToArray;
  finally
    FCriticalSection.Leave;
  end;
end;

function TUniAdminConfigService.LoadGlobalConfig: Boolean;
begin
  Result := (FGlobalConfig as TModuleConfig).LoadFromFile;
end;

function TUniAdminConfigService.SaveGlobalConfig: Boolean;
begin
  Result := (FGlobalConfig as TModuleConfig).SaveToFile;
end;

function TUniAdminConfigService.LoadAllModuleConfigs: Boolean;
var
  ModuleConfig: IModuleConfig;
  AllSuccess: Boolean;
begin
  AllSuccess := True;

  // 先加载全局配置
  if not LoadGlobalConfig then
    AllSuccess := False;

  // 加载所有模块配置
  FCriticalSection.Enter;
  try
    for ModuleConfig in FModuleConfigs.Values do
    begin
      if not ModuleConfig.LoadFromFile then
        AllSuccess := False;
    end;
  finally
    FCriticalSection.Leave;
  end;

  Result := AllSuccess;
end;

function TUniAdminConfigService.SaveAllModuleConfigs: Boolean;
var
  ModuleConfig: IModuleConfig;
  AllSuccess: Boolean;
begin
  AllSuccess := True;

  // 先保存全局配置
  if not SaveGlobalConfig then
    AllSuccess := False;

  // 保存所有模块配置
  FCriticalSection.Enter;
  try
    for ModuleConfig in FModuleConfigs.Values do
    begin
      if not ModuleConfig.SaveToFile then
        AllSuccess := False;
    end;
  finally
    FCriticalSection.Leave;
  end;

  Result := AllSuccess;
end;

function TUniAdminConfigService.GetGlobalString(const Key: string; const DefaultValue: string): string;
begin
  Result := FGlobalConfig.GetString(Key, DefaultValue);
end;

function TUniAdminConfigService.GetGlobalInteger(const Key: string; const DefaultValue: Integer): Integer;
begin
  Result := FGlobalConfig.GetInteger(Key, DefaultValue);
end;

function TUniAdminConfigService.GetGlobalBoolean(const Key: string; const DefaultValue: Boolean): Boolean;
begin
  Result := FGlobalConfig.GetBoolean(Key, DefaultValue);
end;

procedure TUniAdminConfigService.SetGlobalString(const Key, Value: string);
begin
  FGlobalConfig.SetValue(Key, Value);
end;

procedure TUniAdminConfigService.SetGlobalInteger(const Key: string; Value: Integer);
begin
  FGlobalConfig.SetValue(Key, Value);
end;

procedure TUniAdminConfigService.SetGlobalBoolean(const Key: string; Value: Boolean);
begin
  FGlobalConfig.SetValue(Key, Value);
end;

procedure TUniAdminConfigService.RegisterGlobalChangeHandler(const Event: TConfigChangeEvent);
begin
  FCriticalSection.Enter;
  try
    if not FGlobalChangeHandlers.Contains(Event) then
      FGlobalChangeHandlers.Add(Event);
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TUniAdminConfigService.UnregisterGlobalChangeHandler(const Event: TConfigChangeEvent);
begin
  FCriticalSection.Enter;
  try
    FGlobalChangeHandlers.Remove(Event);
  finally
    FCriticalSection.Leave;
  end;
end;

function TUniAdminConfigService.Refresh: Boolean;
begin
  Result := LoadAllModuleConfigs;
end;

initialization
  TUniAdminConfigService.FCS := TCriticalSection.Create;

finalization
  TUniAdminConfigService.FCS.Free;
  TUniAdminConfigService.FInstance := nil;

end.

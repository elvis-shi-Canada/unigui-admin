unit ConfigValidator;

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.IOUtils, System.Generics.Collections,
  System.RegularExpressions;

type
  TValidationRule = record
    Path: string;
    RuleType: string;
    Required: Boolean;
    MinValue: Integer;
    MaxValue: Integer;
    Pattern: string;
    AllowedValues: TArray<string>;
    ErrorMessage: string;
  end;

  TValidationResult = record
    IsValid: Boolean;
    Path: string;
    Message: string;
    Severity: string; // Error, Warning, Info
  end;

  TConfigValidator = class
  private
    FRules: TList<TValidationRule>;
    FResults: TList<TValidationResult>;
    function ValidateRule(const Rule: TValidationRule; const Config: TJSONObject): TValidationResult;
    function GetValueAtPath(const Config: TJSONObject; const Path: string): TJSONValue;
    function ValidateType(const Value: TJSONValue; const ExpectedType: string): Boolean;
    function ValidateRange(const Value: Integer; MinVal, MaxVal: Integer): Boolean;
    function ValidatePattern(const Value, Pattern: string): Boolean;
    function ValidateEnum(const Value: string; const Allowed: TArray<string>): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadRulesFromJSON(const FileName: string);
    procedure AddRule(const Rule: TValidationRule);
    function Validate(const ConfigFile: string): Boolean; overload;
    function Validate(const Config: TJSONObject): Boolean; overload;
    function GetResults: TArray<TValidationResult>;
    function GetErrors: TArray<TValidationResult>;
    function GetWarnings: TArray<TValidationResult>;
    function GenerateReport: string;
    procedure SaveReport(const FileName: string);
    procedure ClearRules;
    procedure ClearResults;
  end;

implementation

constructor TConfigValidator.Create;
begin
  inherited Create;
  FRules := TList<TValidationRule>.Create;
  FResults := TList<TValidationResult>.Create;
end;

destructor TConfigValidator.Destroy;
begin
  FRules.Free;
  FResults.Free;
  inherited;
end;

function TConfigValidator.GetValueAtPath(const Config: TJSONObject; const Path: string): TJSONValue;
var
  Parts: TArray<string>;
  Current: TJSONValue;
  I: Integer;
  Pair: TJSONPair;
begin
  Result := nil;
  Parts := Path.Split(['.']);

  if Length(Parts) = 0 then Exit;

  Current := Config;

  for I := 0 to High(Parts) do
  begin
    if not (Current is TJSONObject) then Exit;

    Pair := (Current as TJSONObject).Get(Parts[I]);
    if not Assigned(Pair) then Exit;

    Current := Pair.JsonValue;
  end;

  Result := Current;
end;

function TConfigValidator.ValidateType(const Value: TJSONValue; const ExpectedType: string): Boolean;
begin
  if SameText(ExpectedType, 'string') then
    Result := Value is TJSONString
  else if SameText(ExpectedType, 'number') then
    Result := (Value is TJSONNumber) and not (Value is TJSONString)
  else if SameText(ExpectedType, 'integer') then
    Result := (Value is TJSONNumber) and (Frac(TJSONNumber(Value).AsDouble) = 0)
  else if SameText(ExpectedType, 'boolean') then
    Result := Value is TJSONBool
  else if SameText(ExpectedType, 'array') then
    Result := Value is TJSONArray
  else if SameText(ExpectedType, 'object') then
    Result := Value is TJSONObject
  else
    Result := True;
end;

function TConfigValidator.ValidateRange(const Value: Integer; MinVal, MaxVal: Integer): Boolean;
begin
  Result := True;
  if (MinVal <> 0) or (MaxVal <> 0) then
    Result := (Value >= MinVal) and (Value <= MaxVal);
end;

function TConfigValidator.ValidatePattern(const Value, Pattern: string): Boolean;
var
  Regex: TRegEx;
  Match: TMatch;
begin
  if Pattern = '' then
  begin
    Result := True;
    Exit;
  end;

  Regex := TRegEx.Create(Pattern);
  Match := Regex.Match(Value);
  Result := Match.Success;
end;

function TConfigValidator.ValidateEnum(const Value: string; const Allowed: TArray<string>): Boolean;
var
  S: string;
begin
  if Length(Allowed) = 0 then
  begin
    Result := True;
    Exit;
  end;

  Result := False;
  for S in Allowed do
  begin
    if SameText(S, Value) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function TConfigValidator.ValidateRule(const Rule: TValidationRule; const Config: TJSONObject): TValidationResult;
var
  Value: TJSONValue;
  StrValue: string;
  IntValue: Integer;
begin
  Result.IsValid := True;
  Result.Path := Rule.Path;
  Result.Severity := 'Info';

  Value := GetValueAtPath(Config, Rule.Path);

  // 检查必填
  if Rule.Required and not Assigned(Value) then
  begin
    Result.IsValid := False;
    Result.Severity := 'Error';
    Result.Message := Rule.ErrorMessage;
    if Result.Message = '' then
      Result.Message := Format('必填字段 "%s" 不存在', [Rule.Path]);
    Exit;
  end;

  if not Assigned(Value) then
    Exit; // 非必填且不存在，跳过

  // 检查类型
  if Rule.RuleType <> '' then
  begin
    if not ValidateType(Value, Rule.RuleType) then
    begin
      Result.IsValid := False;
      Result.Severity := 'Error';
      Result.Message := Format('字段 "%s" 类型不匹配，期望 %s', [Rule.Path, Rule.RuleType]);
      Exit;
    end;
  end;

  // 检查范围（仅数字类型）
  if (Rule.MinValue <> 0) or (Rule.MaxValue <> 0) then
  begin
    if Value is TJSONNumber then
    begin
      IntValue := Trunc(TJSONNumber(Value).AsDouble);
      if not ValidateRange(IntValue, Rule.MinValue, Rule.MaxValue) then
      begin
        Result.IsValid := False;
        Result.Severity := 'Error';
        Result.Message := Format('字段 "%s" 值 %d 不在范围 [%d, %d] 内',
          [Rule.Path, IntValue, Rule.MinValue, Rule.MaxValue]);
        Exit;
      end;
    end;
  end;

  // 检查模式（仅字符串类型）
  if Rule.Pattern <> '' then
  begin
    if Value is TJSONString then
    begin
      StrValue := TJSONString(Value).Value;
      if not ValidatePattern(StrValue, Rule.Pattern) then
      begin
        Result.IsValid := False;
        Result.Severity := 'Error';
        Result.Message := Format('字段 "%s" 值 "%s" 不符合模式 %s',
          [Rule.Path, StrValue, Rule.Pattern]);
        Exit;
      end;
    end;
  end;

  // 检查枚举值（仅字符串类型）
  if Length(Rule.AllowedValues) > 0 then
  begin
    if Value is TJSONString then
    begin
      StrValue := TJSONString(Value).Value;
      if not ValidateEnum(StrValue, Rule.AllowedValues) then
      begin
        Result.IsValid := False;
        Result.Severity := 'Error';
        Result.Message := Format('字段 "%s" 值 "%s" 不在允许的范围内',
          [Rule.Path, StrValue]);
        Exit;
      end;
    end;
  end;
end;

procedure TConfigValidator.LoadRulesFromJSON(const FileName: string);
var
  JSON: TJSONObject;
  RulesArray: TJSONArray;
  I: Integer;
  RuleObj: TJSONObject;
  Rule: TValidationRule;
  AllowedArray: TJSONArray;
  J: Integer;
begin
  if not FileExists(FileName) then Exit;

  JSON := TJSONObject.ParseJSONValue(TFile.ReadAllText(FileName)) as TJSONObject;
  try
    if not Assigned(JSON) then Exit;

    RulesArray := JSON.GetValue('rules') as TJSONArray;
    if not Assigned(RulesArray) then Exit;

    for I := 0 to RulesArray.Count - 1 do
    begin
      RuleObj := RulesArray.Items[I] as TJSONObject;

      Rule.Path := RuleObj.GetValue('path').Value;
      Rule.RuleType := '';
      if RuleObj.TryGetValue('type', RuleObj) then
        Rule.RuleType := RuleObj.Value;

      Rule.Required := False;
      if RuleObj.TryGetValue('required', RuleObj) then
        Rule.Required := TJSONBool(RuleObj).AsBoolean;

      Rule.MinValue := 0;
      Rule.MaxValue := 0;
      if RuleObj.TryGetValue('min', RuleObj) then
        Rule.MinValue := Trunc(TJSONNumber(RuleObj).AsDouble);
      if RuleObj.TryGetValue('max', RuleObj) then
        Rule.MaxValue := Trunc(TJSONNumber(RuleObj).AsDouble);

      Rule.Pattern := '';
      if RuleObj.TryGetValue('pattern', RuleObj) then
        Rule.Pattern := RuleObj.Value;

      Rule.ErrorMessage := '';
      if RuleObj.TryGetValue('message', RuleObj) then
        Rule.ErrorMessage := RuleObj.Value;

      SetLength(Rule.AllowedValues, 0);
      AllowedArray := nil;
      if RuleObj.TryGetValue<TJSONArray>('enum', AllowedArray) then
      begin
        SetLength(Rule.AllowedValues, AllowedArray.Count);
        for J := 0 to AllowedArray.Count - 1 do
          Rule.AllowedValues[J] := AllowedArray.Items[J].Value;
      end;

      FRules.Add(Rule);
    end;
  finally
    JSON.Free;
  end;
end;

procedure TConfigValidator.AddRule(const Rule: TValidationRule);
begin
  FRules.Add(Rule);
end;

function TConfigValidator.Validate(const ConfigFile: string): Boolean;
var
  JSON: TJSONObject;
  Content: string;
begin
  Result := False;

  if not FileExists(ConfigFile) then
  begin
    Writeln('配置文件不存在: ' + ConfigFile);
    Exit;
  end;

  Content := TFile.ReadAllText(ConfigFile, TEncoding.UTF8);
  JSON := TJSONObject.ParseJSONValue(Content) as TJSONObject;

  if not Assigned(JSON) then
  begin
    Writeln('配置文件格式错误: ' + ConfigFile);
    Exit;
  end;

  try
    Result := Validate(JSON);
  finally
    JSON.Free;
  end;
end;

function TConfigValidator.Validate(const Config: TJSONObject): Boolean;
var
  Rule: TValidationRule;
  ResultItem: TValidationResult;
  HasError: Boolean;
begin
  FResults.Clear;
  HasError := False;

  for Rule in FRules do
  begin
    ResultItem := ValidateRule(Rule, Config);
    FResults.Add(ResultItem);

    if not ResultItem.IsValid and (ResultItem.Severity = 'Error') then
      HasError := True;
  end;

  Result := not HasError;
end;

function TConfigValidator.GetResults: TArray<TValidationResult>;
begin
  Result := FResults.ToArray;
end;

function TConfigValidator.GetErrors: TArray<TValidationResult>;
var
  ResultList: TList<TValidationResult>;
  Item: TValidationResult;
begin
  ResultList := TList<TValidationResult>.Create;
  try
    for Item in FResults do
      if not Item.IsValid and (Item.Severity = 'Error') then
        ResultList.Add(Item);

    Result := ResultList.ToArray;
  finally
    ResultList.Free;
  end;
end;

function TConfigValidator.GetWarnings: TArray<TValidationResult>;
var
  ResultList: TList<TValidationResult>;
  Item: TValidationResult;
begin
  ResultList := TList<TValidationResult>.Create;
  try
    for Item in FResults do
      if not Item.IsValid and (Item.Severity = 'Warning') then
        ResultList.Add(Item);

    Result := ResultList.ToArray;
  finally
    ResultList.Free;
  end;
end;

function TConfigValidator.GenerateReport: string;
var
  SB: TStringBuilder;
  Item: TValidationResult;
  ErrorCount, WarningCount: Integer;
begin
  SB := TStringBuilder.Create;
  try
    SB.AppendLine('配置验证报告');
    SB.AppendLine('============');
    SB.AppendLine;

    ErrorCount := 0;
    WarningCount := 0;

    for Item in FResults do
    begin
      if Item.Severity = 'Error' then
        Inc(ErrorCount)
      else if Item.Severity = 'Warning' then
        Inc(WarningCount);

      if not Item.IsValid then
      begin
        SB.Append(Format('[%s] ', [Item.Severity]));
        SB.AppendLine(Format('%s: %s', [Item.Path, Item.Message]));
      end;
    end;

    SB.AppendLine;
    SB.AppendLine(Format('总计: %d 个错误, %d 个警告', [ErrorCount, WarningCount]));

    if (ErrorCount = 0) and (WarningCount = 0) then
      SB.AppendLine('配置验证通过！');

    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

procedure TConfigValidator.SaveReport(const FileName: string);
begin
  TFile.WriteAllText(FileName, GenerateReport, TEncoding.UTF8);
  Writeln('验证报告已保存: ' + FileName);
end;

procedure TConfigValidator.ClearRules;
begin
  FRules.Clear;
end;

procedure TConfigValidator.ClearResults;
begin
  FResults.Clear;
end;

end.

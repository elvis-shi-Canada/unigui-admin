unit CodeGenerator;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Generics.Collections,
  System.JSON;

type
  TCodeTemplate = record
    Name: string;
    Description: string;
    Template: string;
    OutputExtension: string;
  end;

  TCodeGenerator = class
  private
    FTemplatesDir: string;
    FOutputDir: string;
    FTemplates: TDictionary<string, TCodeTemplate>;
    function LoadTemplate(const TemplateName: string): TCodeTemplate;
    function ProcessTemplate(const Template: TCodeTemplate; const Variables: TDictionary<string, string>): string;
    procedure RegisterDefaultTemplates;
  public
    constructor Create(const TemplatesDir, OutputDir: string);
    destructor Destroy; override;
    function Generate(const TemplateName, EntityName: string; const Variables: TDictionary<string, string>): string;
    function GenerateFromJSON(const ConfigFile: string): Boolean;
    function ListTemplates: TArray<string>;
  end;

implementation

constructor TCodeGenerator.Create(const TemplatesDir, OutputDir: string);
begin
  inherited Create;
  FTemplatesDir := TemplatesDir;
  FOutputDir := OutputDir;
  FTemplates := TDictionary<string, TCodeTemplate>.Create;
  RegisterDefaultTemplates;
end;

destructor TCodeGenerator.Destroy;
begin
  FTemplates.Free;
  inherited;
end;

procedure TCodeGenerator.RegisterDefaultTemplates;
var
  Template: TCodeTemplate;
begin
  // Entity模板
  Template.Name := 'entity';
  Template.Description := '实体类';
  Template.OutputExtension := '.pas';
  Template.Template :=
    'unit {{UnitName}};' + sLineBreak +
    '' + sLineBreak +
    'interface' + sLineBreak +
    '' + sLineBreak +
    'type' + sLineBreak +
    '  T{{EntityName}} = class' + sLineBreak +
    '  private' + sLineBreak +
    '    {{PrivateFields}}' + sLineBreak +
    '  public' + sLineBreak +
    '    constructor Create;' + sLineBreak +
    '    destructor Destroy; override;' + sLineBreak +
    '    {{PublicMethods}}' + sLineBreak +
    '    {{Properties}}' + sLineBreak +
    '  end;' + sLineBreak +
    '' + sLineBreak +
    'implementation' + sLineBreak +
    '' + sLineBreak +
    '{ T{{EntityName}} }' + sLineBreak +
    '' + sLineBreak +
    'constructor T{{EntityName}}.Create;' + sLineBreak +
    'begin' + sLineBreak +
    '  inherited;' + sLineBreak +
    'end;' + sLineBreak +
    '' + sLineBreak +
    'destructor T{{EntityName}}.Destroy;' + sLineBreak +
    'begin' + sLineBreak +
    '  inherited;' + sLineBreak +
    'end;' + sLineBreak +
    '' + sLineBreak +
    'end.';
  FTemplates.Add(Template.Name, Template);

  // Service接口模板
  Template.Name := 'service';
  Template.Description := '服务接口';
  Template.OutputExtension := '.Intf.pas';
  Template.Template :=
    'unit {{UnitName}}.Intf;' + sLineBreak +
    '' + sLineBreak +
    'interface' + sLineBreak +
    '' + sLineBreak +
    'type' + sLineBreak +
    '  I{{EntityName}}Service = interface(IInterface)' + sLineBreak +
    '    [''{GUID}'']' + sLineBreak +
    '    function GetById(const Id: Integer): T{{EntityName}};' + sLineBreak +
    '    function GetAll: TArray<T{{EntityName}}>;' + sLineBreak +
    '    function Create(const Entity: T{{EntityName}}): Boolean;' + sLineBreak +
    '    function Update(const Entity: T{{EntityName}}): Boolean;' + sLineBreak +
    '    function Delete(const Id: Integer): Boolean;' + sLineBreak +
    '  end;' + sLineBreak +
    '' + sLineBreak +
    'implementation' + sLineBreak +
    '' + sLineBreak +
    'end.';
  FTemplates.Add(Template.Name, Template);

  // Repository模板
  Template.Name := 'repository';
  Template.Description := '数据访问层';
  Template.OutputExtension := 'Repository.pas';
  Template.Template :=
    'unit {{UnitName}}Repository;' + sLineBreak +
    '' + sLineBreak +
    'interface' + sLineBreak +
    '' + sLineBreak +
    'uses' + sLineBreak +
    '  System.SysUtils, System.Classes;' + sLineBreak +
    '' + sLineBreak +
    'type' + sLineBreak +
    '  T{{EntityName}}Repository = class' + sLineBreak +
    '  private' + sLineBreak +
    '    FConnection: TFDConnection;' + sLineBreak +
    '  public' + sLineBreak +
    '    constructor Create(AConnection: TFDConnection);' + sLineBreak +
    '    function FindById(const Id: Integer): T{{EntityName}};' + sLineBreak +
    '    function FindAll: TArray<T{{EntityName}}>;' + sLineBreak +
    '    function Insert(const Entity: T{{EntityName}}): Boolean;' + sLineBreak +
    '    function Update(const Entity: T{{EntityName}}): Boolean;' + sLineBreak +
    '    function Delete(const Id: Integer): Boolean;' + sLineBreak +
    '  end;' + sLineBreak +
    '' + sLineBreak +
    'implementation' + sLineBreak +
    '' + sLineBreak +
    '{ T{{EntityName}}Repository }' + sLineBreak +
    '' + sLineBreak +
    'constructor T{{EntityName}}Repository.Create(AConnection: TFDConnection);' + sLineBreak +
    'begin' + sLineBreak +
    '  inherited Create;' + sLineBreak +
    '  FConnection := AConnection;' + sLineBreak +
    'end;' + sLineBreak +
    '' + sLineBreak +
    'function T{{EntityName}}Repository.FindById(const Id: Integer): T{{EntityName}};' + sLineBreak +
    'begin' + sLineBreak +
    '  // Implementation' + sLineBreak +
    'end;' + sLineBreak +
    '' + sLineBreak +
    'function T{{EntityName}}Repository.FindAll: TArray<T{{EntityName}}>;' + sLineBreak +
    'begin' + sLineBreak +
    '  // Implementation' + sLineBreak +
    'end;' + sLineBreak +
    '' + sLineBreak +
    'function T{{EntityName}}Repository.Insert(const Entity: T{{EntityName}}): Boolean;' + sLineBreak +
    'begin' + sLineBreak +
    '  // Implementation' + sLineBreak +
    'end;' + sLineBreak +
    '' + sLineBreak +
    'function T{{EntityName}}Repository.Update(const Entity: T{{EntityName}}): Boolean;' + sLineBreak +
    'begin' + sLineBreak +
    '  // Implementation' + sLineBreak +
    'end;' + sLineBreak +
    '' + sLineBreak +
    'function T{{EntityName}}Repository.Delete(const Id: Integer): Boolean;' + sLineBreak +
    'begin' + sLineBreak +
    '  // Implementation' + sLineBreak +
    'end;' + sLineBreak +
    '' + sLineBreak +
    'end.';
  FTemplates.Add(Template.Name, Template);

  // SQL表模板
  Template.Name := 'sql-table';
  Template.Description := 'SQL表结构';
  Template.OutputExtension := '.sql';
  Template.Template :=
    '-- Create {{TableName}} table' + sLineBreak +
    'IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = ''{{TableName}}'')' + sLineBreak +
    'BEGIN' + sLineBreak +
    '  CREATE TABLE {{TableName}} (' + sLineBreak +
    '    Id INT IDENTITY(1,1) PRIMARY KEY,' + sLineBreak +
    '    {{Columns}}' + sLineBreak +
    '    CreatedAt DATETIME DEFAULT GETDATE(),' + sLineBreak +
    '    UpdatedAt DATETIME DEFAULT GETDATE()' + sLineBreak +
    '  );' + sLineBreak +
    'END;' + sLineBreak +
    'GO';
  FTemplates.Add(Template.Name, Template);

  // API Controller模板
  Template.Name := 'api-controller';
  Template.Description := 'API控制器';
  Template.OutputExtension := 'Controller.pas';
  Template.Template :=
    'unit {{UnitName}}Controller;' + sLineBreak +
    '' + sLineBreak +
    'interface' + sLineBreak +
    '' + sLineBreak +
    'uses' + sLineBreak +
    '  System.SysUtils, System.Classes, System.JSON;' + sLineBreak +
    '' + sLineBreak +
    'type' + sLineBreak +
    '  T{{EntityName}}Controller = class' + sLineBreak +
    '  private' + sLineBreak +
    '    FService: I{{EntityName}}Service;' + sLineBreak +
    '  public' + sLineBreak +
    '    constructor Create;' + sLineBreak +
    '    destructor Destroy; override;' + sLineBreak +
    '    function GetAll: TJSONArray;' + sLineBreak +
    '    function GetById(const Id: Integer): TJSONObject;' + sLineBreak +
    '    function Create(const JSON: TJSONObject): TJSONObject;' + sLineBreak +
    '    function Update(const Id: Integer; const JSON: TJSONObject): TJSONObject;' + sLineBreak +
    '    function Delete(const Id: Integer): Boolean;' + sLineBreak +
    '  end;' + sLineBreak +
    '' + sLineBreak +
    'implementation' + sLineBreak +
    '' + sLineBreak +
    '{ T{{EntityName}}Controller }' + sLineBreak +
    '' + sLineBreak +
    'constructor T{{EntityName}}Controller.Create;' + sLineBreak +
    'begin' + sLineBreak +
    '  inherited;' + sLineBreak +
    'end;' + sLineBreak +
    '' + sLineBreak +
    'destructor T{{EntityName}}Controller.Destroy;' + sLineBreak +
    'begin' + sLineBreak +
    '  inherited;' + sLineBreak +
    'end;' + sLineBreak +
    '' + sLineBreak +
    'function T{{EntityName}}Controller.GetAll: TJSONArray;' + sLineBreak +
    'begin' + sLineBreak +
    '  // Implementation' + sLineBreak +
    'end;' + sLineBreak +
    '' + sLineBreak +
    'function T{{EntityName}}Controller.GetById(const Id: Integer): TJSONObject;' + sLineBreak +
    'begin' + sLineBreak +
    '  // Implementation' + sLineBreak +
    'end;' + sLineBreak +
    '' + sLineBreak +
    'function T{{EntityName}}Controller.Create(const JSON: TJSONObject): TJSONObject;' + sLineBreak +
    'begin' + sLineBreak +
    '  // Implementation' + sLineBreak +
    'end;' + sLineBreak +
    '' + sLineBreak +
    'function T{{EntityName}}Controller.Update(const Id: Integer; const JSON: TJSONObject): TJSONObject;' + sLineBreak +
    'begin' + sLineBreak +
    '  // Implementation' + sLineBreak +
    'end;' + sLineBreak +
    '' + sLineBreak +
    'function T{{EntityName}}Controller.Delete(const Id: Integer): Boolean;' + sLineBreak +
    'begin' + sLineBreak +
    '  // Implementation' + sLineBreak +
    'end;' + sLineBreak +
    '' + sLineBreak +
    'end.';
  FTemplates.Add(Template.Name, Template);
end;

function TCodeGenerator.LoadTemplate(const TemplateName: string): TCodeTemplate;
begin
  if not FTemplates.TryGetValue(TemplateName, Result) then
    raise Exception.CreateFmt('Template not found: %s', [TemplateName]);
end;

function TCodeGenerator.ProcessTemplate(const Template: TCodeTemplate; const Variables: TDictionary<string, string>): string;
var
  Output: string;
  Pair: TPair<string, string>;
begin
  Output := Template.Template;

  for Pair in Variables do
  begin
    Output := StringReplace(Output, '{{' + Pair.Key + '}}', Pair.Value, [rfReplaceAll, rfIgnoreCase]);
  end;

  Result := Output;
end;

function TCodeGenerator.Generate(const TemplateName, EntityName: string; const Variables: TDictionary<string, string>): string;
var
  Template: TCodeTemplate;
  Output: string;
  FileName: string;
  Vars: TDictionary<string, string>;
  Guid: TGUID;
  GuidStr: string;
begin
  Vars := TDictionary<string, string>.Create;
  try
    // 复制用户变量
    if Assigned(Variables) then
      for var Pair in Variables do
        Vars.Add(Pair.Key, Pair.Value);

    // 添加默认变量
    Vars.AddOrSetValue('EntityName', EntityName);
    Vars.AddOrSetValue('UnitName', EntityName);
    Vars.AddOrSetValue('TableName', EntityName + 's');
    Vars.AddOrSetValue('PrivateFields', 'FId: Integer;' + sLineBreak + '    FName: string;');
    Vars.AddOrSetValue('PublicMethods', '');
    Vars.AddOrSetValue('Properties',
      'property Id: Integer read FId write FId;' + sLineBreak +
      '    property Name: string read FName write FName;');
    Vars.AddOrSetValue('Columns',
      'Name NVARCHAR(100) NOT NULL,');

    // 生成GUID
    CreateGUID(Guid);
    GuidStr := GUIDToString(Guid);
    Vars.AddOrSetValue('GUID', GuidStr);

    Template := LoadTemplate(TemplateName);
    Output := ProcessTemplate(Template, Vars);

    // 保存文件
    if not TDirectory.Exists(FOutputDir) then
      TDirectory.CreateDirectory(FOutputDir);

    FileName := TPath.Combine(FOutputDir, EntityName + Template.OutputExtension);
    TFile.WriteAllText(FileName, Output, TEncoding.UTF8);

    Result := FileName;
    Writeln('Generated: ' + FileName);
  finally
    Vars.Free;
  end;
end;

function TCodeGenerator.GenerateFromJSON(const ConfigFile: string): Boolean;
var
  JSON: TJSONObject;
  Generations: TJSONArray;
  I: Integer;
  Gen: TJSONObject;
  TemplateName, EntityName: string;
  Variables: TDictionary<string, string>;
  J: Integer;
  VarObj: TJSONValue;
begin
  Result := False;

  if not FileExists(ConfigFile) then
  begin
    Writeln('Config file not found: ' + ConfigFile);
    Exit;
  end;

  JSON := TJSONObject.ParseJSONValue(TFile.ReadAllText(ConfigFile)) as TJSONObject;
  try
    if not Assigned(JSON) then
    begin
      Writeln('Invalid JSON file');
      Exit;
    end;

    Generations := JSON.GetValue('generations') as TJSONArray;
    if not Assigned(Generations) then
    begin
      Writeln('No generations found in config');
      Exit;
    end;

    for I := 0 to Generations.Count - 1 do
    begin
      Gen := Generations.Items[I] as TJSONObject;
      TemplateName := Gen.GetValue('template').Value;
      EntityName := Gen.GetValue('entity').Value;

      Variables := TDictionary<string, string>.Create;
      try
        if Gen.TryGetValue<TJSONValue>('variables', VarObj) and (VarObj is TJSONObject) then
        begin
          for J := 0 to (VarObj as TJSONObject).Count - 1 do
          begin
            Variables.Add(
              (VarObj as TJSONObject).Pairs[J].JsonString.Value,
              (VarObj as TJSONObject).Pairs[J].JsonValue.Value);
          end;
        end;

        Generate(TemplateName, EntityName, Variables);
      finally
        Variables.Free;
      end;
    end;

    Result := True;
  finally
    JSON.Free;
  end;
end;

function TCodeGenerator.ListTemplates: TArray<string>;
begin
  Result := FTemplates.Keys.ToArray;
end;

end.

unit UniPluginLoader;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  UniContext, UniPlugin.Intf, UniModuleRegistry.Intf;

type
  /// <summary>
  /// 插件加载状态
  /// </summary>
  TPluginLoadStatus = record
    PluginName: string;
    IsLoaded: Boolean;
    LoadTime: TDateTime;
    ErrorMessage: string;
  end;

  /// <summary>
  /// 插件加载器接口
  /// </summary>
  IUniPluginLoader = interface(IInterface)
    ['{UNI-PLUGIN-LOADER-001}']
    function LoadPlugin(const PluginName: string; const UserContext: IUserContext;
      const ExecutionContext: IExecutionContext): IPlugin;
    function UnloadPlugin(const PluginName: string): Boolean;
    function LoadAllPlugins(const UserContext: IUserContext;
      const ExecutionContext: IExecutionContext): TArray<TPluginLoadStatus>;
    function IsPluginLoaded(const PluginName: string): Boolean;
    function GetLoadedPlugins: TArray<string>;
    procedure UnloadAllPlugins;
  end;

  /// <summary>
  /// 插件加载器实现
  /// 负责根据注册表信息创建和管理插件实例
  /// </summary>
  TUniPluginLoader = class(TInterfacedObject, IUniPluginLoader)
  private
    FLoadedPlugins: TDictionary<string, IPlugin>;
    FRegistry: IUniModuleRegistry;

    function ValidateDependencies(const PluginName: string): Boolean;
  public
    constructor Create(const Registry: IUniModuleRegistry);
    destructor Destroy; override;

    function LoadPlugin(const PluginName: string; const UserContext: IUserContext;
      const ExecutionContext: IExecutionContext): IPlugin;
    function UnloadPlugin(const PluginName: string): Boolean;
    function LoadAllPlugins(const UserContext: IUserContext;
      const ExecutionContext: IExecutionContext): TArray<TPluginLoadStatus>;
    function IsPluginLoaded(const PluginName: string): Boolean;
    function GetLoadedPlugins: TArray<string>;
    procedure UnloadAllPlugins;
  end;

implementation

{ TUniPluginLoader }

constructor TUniPluginLoader.Create(const Registry: IUniModuleRegistry);
begin
  inherited Create;
  FRegistry := Registry;
  FLoadedPlugins := TDictionary<string, IPlugin>.Create;
end;

destructor TUniPluginLoader.Destroy;
begin
  UnloadAllPlugins;
  FLoadedPlugins.Free;
  inherited;
end;

function TUniPluginLoader.ValidateDependencies(const PluginName: string): Boolean;
var
  LDeps: TArray<string>;
  LDepName: string;
begin
  Result := True;
  LDeps := FRegistry.GetDependencies(PluginName);

  for LDepName in LDeps do
  begin
    if not FLoadedPlugins.ContainsKey(LDepName) then
      Exit(False);
  end;
end;

function TUniPluginLoader.LoadPlugin(const PluginName: string; const UserContext: IUserContext;
  const ExecutionContext: IExecutionContext): IPlugin;
var
  LLoadOrder: TArray<string>;
  LPluginName: string;
begin
  // 检查是否已加载
  if FLoadedPlugins.TryGetValue(PluginName, Result) then
    Exit;

  // 检查依赖关系
  if not ValidateDependencies(PluginName) then
    raise Exception.CreateFmt('Plugin %s dependencies not loaded', [PluginName]);

  // 创建插件实例
  Result := FRegistry.CreatePlugin(PluginName, UserContext, ExecutionContext);
  Result.Initialize;
  FLoadedPlugins.Add(PluginName, Result);
end;

function TUniPluginLoader.UnloadPlugin(const PluginName: string): Boolean;
var
  LPlugin: IPlugin;
  LDependents: TArray<string>;
  LDependent: string;
begin
  Result := False;

  // 检查是否有其他插件依赖此插件
  LDependents := FRegistry.GetDependents(PluginName);
  for LDependent in LDependents do
  begin
    if FLoadedPlugins.ContainsKey(LDependent) then
      raise Exception.CreateFmt('Cannot unload plugin %s: %s depends on it',
        [PluginName, LDependent]);
  end;

  if FLoadedPlugins.TryGetValue(PluginName, LPlugin) then
  begin
    LPlugin.Deactivate;
    FLoadedPlugins.Remove(PluginName);
    Result := True;
  end;
end;

function TUniPluginLoader.LoadAllPlugins(const UserContext: IUserContext;
  const ExecutionContext: IExecutionContext): TArray<TPluginLoadStatus>;
var
  LLoadOrder: TArray<string>;
  LStatusList: TList<TPluginLoadStatus>;
  LStatus: TPluginLoadStatus;
  LPluginName: string;
begin
  LStatusList := TList<TPluginLoadStatus>.Create;
  try
    // 获取加载顺序
    LLoadOrder := FRegistry.GetLoadOrder;

    // 按顺序加载所有插件
    for LPluginName in LLoadOrder do
    begin
      LStatus.PluginName := LPluginName;
      try
        LoadPlugin(LPluginName, UserContext, ExecutionContext);
        LStatus.IsLoaded := True;
        LStatus.LoadTime := Now;
        LStatus.ErrorMessage := '';
      except
        on E: Exception do
        begin
          LStatus.IsLoaded := False;
          LStatus.LoadTime := Now;
          LStatus.ErrorMessage := E.Message;
        end;
      end;
      LStatusList.Add(LStatus);
    end;

    Result := LStatusList.ToArray;
  finally
    LStatusList.Free;
  end;
end;

function TUniPluginLoader.IsPluginLoaded(const PluginName: string): Boolean;
begin
  Result := FLoadedPlugins.ContainsKey(PluginName);
end;

function TUniPluginLoader.GetLoadedPlugins: TArray<string>;
begin
  Result := FLoadedPlugins.Keys.ToArray;
end;

procedure TUniPluginLoader.UnloadAllPlugins;
var
  LPluginName: string;
  LLoadOrder: TArray<string>;
  I: Integer;
begin
  // 按相反顺序卸载
  LLoadOrder := FRegistry.GetLoadOrder;
  for I := High(LLoadOrder) downto 0 do
  begin
    LPluginName := LLoadOrder[I];
    if FLoadedPlugins.ContainsKey(LPluginName) then
      UnloadPlugin(LPluginName);
  end;
end;

end.

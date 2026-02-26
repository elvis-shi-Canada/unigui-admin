unit ServerModule;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils,
  UniGUIServer, UniGUIApplication, UniGUIClasses,
  UniConfigService.Intf, UniModuleRegistry.Intf;

type
  /// <summary>
  /// UniGUI 服务器模块
  /// 继承自 TUniGUIServerModule，负责服务器级别的初始化和配置管理
  /// </summary>
  TServerModule = class(TUniGUIServerModule)
  private
    FConfigService: IUniConfigService;
    FModuleRegistry: IUniModuleRegistry;
    FConfigRoot: string;

    /// <summary>初始化配置服务</summary>
    procedure InitializeConfigService;
    /// <summary>初始化插件注册表</summary>
    procedure InitializeModuleRegistry;
    /// <summary>加载应用配置</summary>
    procedure LoadApplicationConfig;
  protected
    /// <summary>服务器模块创建事件</summary>
    procedure OnCreate(Sender: TObject);
    /// <summary>服务器模块销毁事件</summary>
    procedure OnDestroy(Sender: TObject);
  public
    /// <summary>获取配置服务实例</summary>
    function GetConfigService: IUniConfigService;
    /// <summary>获取插件注册表实例</summary>
    function GetModuleRegistry: IUniModuleRegistry;
    /// <summary>获取配置根目录</summary>
    function GetConfigRoot: string;
  end;

function GetServerModule: TServerModule;

implementation

{$R *.dfm}

uses
  UniConfigService, UniModuleRegistry;

var
  GServerModule: TServerModule;

function GetServerModule: TServerModule;
begin
  Result := GServerModule;
end;

{ TServerModule }

procedure TServerModule.OnCreate(Sender: TObject);
begin
  // 设置全局实例引用
  GServerModule := Self;

  // 确定配置根目录（相对于可执行文件）
  FConfigRoot := TPath.Combine(ExtractFilePath(ParamStr(0)), 'config');

  // 如果目录不存在，尝试使用当前工作目录
  if not TDirectory.Exists(FConfigRoot) then
  begin
    FConfigRoot := TPath.Combine(GetCurrentDir, 'config');
  end;

  // 初始化核心服务
  InitializeConfigService;
  InitializeModuleRegistry;
  LoadApplicationConfig;

  // 记录启动日志
  WriteLn('UniGUI Server Module initialized successfully.');
  WriteLn('Config Root: ' + FConfigRoot);
end;

procedure TServerModule.OnDestroy(Sender: TObject);
begin
  // 清理插件注册表（通过接口引用计数自动释放）
  FModuleRegistry := nil;

  // 清理配置服务（通过接口引用计数自动释放）
  FConfigService := nil;

  // 清理全局实例引用
  GServerModule := nil;

  WriteLn('UniGUI Server Module destroyed.');
end;

procedure TServerModule.InitializeConfigService;
begin
  // 获取配置服务单例实例
  FConfigService := TUniConfigService.GetInstance;

  // 设置配置根目录
  if TDirectory.Exists(FConfigRoot) then
    FConfigService.SetConfigRoot(FConfigRoot)
  else
  begin
    // 如果配置目录不存在，创建它
    TDirectory.CreateDirectory(FConfigRoot);
    FConfigService.SetConfigRoot(FConfigRoot);
    WriteLn('Created config directory: ' + FConfigRoot);
  end;

  // 加载全局配置
  if not FConfigService.LoadGlobalConfig then
  begin
    WriteLn('Warning: Failed to load global configuration. Using defaults.');
  end;
end;

procedure TServerModule.InitializeModuleRegistry;
begin
  // 获取插件注册表单例实例
  FModuleRegistry := TUniModuleRegistry.GetInstance;

  // 注册表初始化完成
  // 插件类的注册由各个插件模块在初始化时完成
  WriteLn('Module Registry initialized.');
end;

procedure TServerModule.LoadApplicationConfig;
var
  AppConfigFile: string;
  AppName, AppTitle: string;
  ServerPort: Integer;
begin
  AppConfigFile := TPath.Combine(FConfigRoot, 'app.json');

  if not TFile.Exists(AppConfigFile) then
  begin
    WriteLn('Warning: Application config file not found: ' + AppConfigFile);
    Exit;
  end;

  // 从配置文件读取应用信息
  AppName := FConfigService.GetGlobalString('application.name', 'UniAdmin 管理系统');
  AppTitle := FConfigService.GetGlobalString('application.title', 'UniAdmin');
  ServerPort := FConfigService.GetGlobalInteger('server.port', 8077);

  // 设置服务器参数
  Self.Port := ServerPort;

  WriteLn(Format('Application: %s (%s)', [AppName, AppTitle]));
  WriteLn(Format('Server Port: %d', [ServerPort]));
end;

function TServerModule.GetConfigService: IUniConfigService;
begin
  Result := FConfigService;
end;

function TServerModule.GetModuleRegistry: IUniModuleRegistry;
begin
  Result := FModuleRegistry;
end;

function TServerModule.GetConfigRoot: string;
begin
  Result := FConfigRoot;
end;

end.

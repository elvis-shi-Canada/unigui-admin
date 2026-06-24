unit ServerModule;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, ShellAPI, uniGUITypes,
  UniGUIServer, UniGUIApplication, UniGUIClasses, UniGUIVars, uniGUIMainModule,
  UniConfigService.Intf, UniModuleRegistry.Intf;

type
  /// <summary>
  /// UniGUI 服务器模块
  /// 继承自 TUniGUIServerModule，负责服务器级别的初始化和配置管理
  /// </summary>
  TServerModule = class(TUniGUIServerModule)
    procedure OnCreate(Sender: TObject);
    procedure OnDestroy(Sender: TObject);
  protected
    /// <summary>UniGUI 服务器模块首次初始化，完成窗体类映射绑定</summary>
    procedure FirstInit; override;
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
  public
    /// <summary>获取配置服务实例</summary>
    function GetConfigService: IUniConfigService;
    /// <summary>获取插件注册表实例</summary>
    function GetModuleRegistry: IUniModuleRegistry;
    /// <summary>获取配置根目录</summary>
    function GetConfigRoot: string;
  end;

function UniServerModule: TServerModule;
procedure ExploreWeb(page:PChar);

implementation

{$R *.dfm}

uses
  UniConfigService, UniModuleRegistry, UniAdminLogger;

{ TServerModule }

procedure ExploreWeb(page:PChar);
var Returnvalue: Integer;
begin
  Returnvalue := ShellExecute(0,'open',page, nil, nil, 1);
end;


function UniServerModule: TServerModule;
begin
  Result:=TServerModule(UniGUIServerInstance);
end;

procedure TServerModule.FirstInit;
begin
  // UniGUI 标准初始化：绑定主模块类/主窗体类/登录窗体类，设置进程路径
  // 缺少此调用会导致 FMainFormClass/FMainModuleClass 为 nil，访问时回退到
  // ServerMonitor 分支触发 'Class TServerControlPanelForm not found'
  InitServerModule(Self);
end;

procedure TServerModule.OnCreate(Sender: TObject);
begin

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
  LogInfo('UniGUI Server Module initialized successfully.');
  LogInfo('Config Root: ' + FConfigRoot);
end;

procedure TServerModule.OnDestroy(Sender: TObject);
begin
  // 清理插件注册表（通过接口引用计数自动释放）
  FModuleRegistry := nil;

  // 清理配置服务（通过接口引用计数自动释放）
  FConfigService := nil;


  LogInfo('UniGUI Server Module destroyed.');
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
    LogInfo('Created config directory: ' + FConfigRoot);
  end;

  // 加载全局配置
  if not FConfigService.LoadGlobalConfig then
  begin
    LogWarn('Failed to load global configuration. Using defaults.');
  end;
end;

procedure TServerModule.InitializeModuleRegistry;
begin
  // 获取插件注册表单例实例
  FModuleRegistry := TUniModuleRegistry.GetInstance;

  // 注册表初始化完成
  // 插件类的注册由各个插件模块在初始化时完成
  LogInfo('Module Registry initialized.');
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
    LogWarn('Application config file not found: ' + AppConfigFile);
    Exit;
  end;

  // 从配置文件读取应用信息
  AppName := FConfigService.GetGlobalString('application.name', 'UniAdmin 管理系统');
  AppTitle := FConfigService.GetGlobalString('application.title', 'UniAdmin');
  ServerPort := FConfigService.GetGlobalInteger('server.port', 8077);

  // 设置服务器参数
  Self.Port := ServerPort;
  Self.Title := AppTitle;

  LogInfo(Format('Application: %s (%s)', [AppName, AppTitle]));
  LogInfo(Format('Server Port: %d', [ServerPort]));
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

initialization
  RegisterServerModuleClass(TServerModule);
end.

unit ServerModule;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, ShellAPI, uniGUITypes,
  UniGUIServer, UniGUIApplication, UniGUIClasses, UniGUIVars, uniGUIMainModule,
  UniAdminConfigService.Intf, UniAdminModuleRegistry.Intf, FireDAC.Phys.MSSQLDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Phys, FireDAC.Comp.Client, FireDAC.Phys.SQLite, FireDAC.Phys.ODBCBase,
  FireDAC.Phys.MSSQL;

type
  /// <summary>
  /// UniGUI 服务器模块
  /// 继承自 TUniGUIServerModule，负责服务器级别的初始化和配置管理
  /// </summary>
  TServerModule = class(TUniGUIServerModule)
    FDPhysMSSQLDriverLink: TFDPhysMSSQLDriverLink;
    FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink;
    FDManager: TFDManager;
    procedure OnCreate(Sender: TObject);
    procedure OnDestroy(Sender: TObject);
  protected
    /// <summary>UniGUI 服务器模块首次初始化，完成窗体类映射绑定</summary>
    procedure FirstInit; override;
  private
    FConfigService: IUniAdminConfigService;
    FModuleRegistry: IUniAdminModuleRegistry;
    FConfigRoot: string;

    /// <summary>初始化配置服务</summary>
    procedure InitializeConfigService;
    /// <summary>初始化插件注册表</summary>
    procedure InitializeModuleRegistry;
    /// <summary>加载应用配置</summary>
    procedure LoadApplicationConfig;
    /// <summary>初始化数据库连接与核心服务（Auth/Metadata/Menu/Permission）</summary>
    procedure InitializeDatabaseServices;
    /// <summary>Application pre-shutdown hook: clears active sessions so MainModule.OnDestroy runs</summary>
    procedure DoBeforeShutdown(Sender: TObject);
  public
    /// <summary>获取配置服务实例</summary>
    function GetConfigService: IUniAdminConfigService;
    /// <summary>获取插件注册表实例</summary>
    function GetModuleRegistry: IUniAdminModuleRegistry;
    /// <summary>获取配置根目录</summary>
    function GetConfigRoot: string;
  end;

function UniServerModule: TServerModule;
procedure ExploreWeb(page:PChar);

implementation

{$R *.dfm}

uses
  UniAdminConfigService, UniAdminModuleRegistry, UniAdminLogger,
  UniAdminConnectionManager, DatabaseInitializer, DatabaseMigrator;

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
  // 切换工作目录到 exe 目录（bin/），确保 SQLite 库文件、config 等相对路径稳定
  // （IDE 运行时 cwd 默认是项目根，会导致库文件/config 落错位置）
  SetCurrentDir(ExtractFilePath(ParamStr(0)));

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
  InitializeDatabaseServices;

  // Register pre-shutdown hook: uniGUI does not destroy active sessions on exit (see DoBeforeShutdown)
  OnBeforeShutdown := DoBeforeShutdown;

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

procedure TServerModule.DoBeforeShutdown(Sender: TObject);
begin
  // uniGUI does NOT destroy active sessions on process exit:
  //   TUniGUISessionManager.Destroy only terminates the manager thread;
  //   TUniGUISessions.Destroy only frees the list container.
  // Neither calls Clear, so active sessions' MainModule.OnDestroy never runs,
  // leaking TUniAdminServices and its Manager/connection graph.
  // OnBeforeShutdown fires before SessionManager.Free (SessionManager still alive),
  // so we Clear here to force-destroy active sessions and trigger MainModule.OnDestroy.
  // RemoveSession wraps each session free in try-except, so a single failing session
  // does not block the rest.
  if (SessionManager = nil) or (SessionManager.Sessions = nil) then
    Exit;
  try
    SessionManager.Sessions.Clear;
    LogInfo('Shutdown: cleared active sessions, MainModule resources released.');
  except
    on E: Exception do
      LogError('Shutdown session cleanup failed: ' + E.Message);
  end;
end;

procedure TServerModule.InitializeConfigService;
begin
  // 获取配置服务单例实例
  FConfigService := TUniAdminConfigService.GetInstance;

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
  FModuleRegistry := TUniAdminModuleRegistry.GetInstance;

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

procedure TServerModule.InitializeDatabaseServices;
var
  LConnection: TFDConnection;
  LMigrator: TDatabaseMigrator;
  LMigrationsDir: string;
begin
  // 建立数据库连接 → 自动建表/灌初始数据 → 应用增量迁移
  // 任一步失败都记录错误但不崩溃，服务器仍可启动
  try
    LConnection := TUniAdminConnectionManager.GetInstance.GetDefaultConnection;
    try
      // 1. 首次连接自动建基础表 + 灌入 admin（开发环境 SQLite 零配置）
      TDatabaseInitializer.Initialize(LConnection);
      // 2. 应用增量迁移脚本（Database/Migrations/*.sql，按版本号，SchemaMigrations 记录）
      //    与 DatabaseInitializer 并存：Initializer 建基础表，Migrator 管后续 Schema 演进
      LMigrationsDir := TPath.Combine(ExtractFilePath(ParamStr(0)), 'Database', 'Migrations');
      LMigrator := TDatabaseMigrator.Create(LConnection, LMigrationsDir);
      try
        LMigrator.Migrate;
      finally
        LMigrator.Free;
      end;
      LogInfo('Database migration completed successfully.');
    finally
      TUniAdminConnectionManager.GetInstance.ReleaseConnection(LConnection);
    end;
  except
    on E: Exception do
      LogError('Database init failed (check DB config in app.json): ' + E.Message);
  end;
end;

function TServerModule.GetConfigService: IUniAdminConfigService;
begin
  Result := FConfigService;
end;

function TServerModule.GetModuleRegistry: IUniAdminModuleRegistry;
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

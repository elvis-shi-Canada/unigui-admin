unit MainModule;

interface

uses
  System.SysUtils, System.Classes,
  UniGUIMainModule, UniGUIApplication, UniGUIClasses,
  UniContext, UniAdminAuthService.Intf,
  UniAdminConfigService.Intf, UniAdminModuleRegistry.Intf,
  FireDAC.Comp.Client,
  UniAdminConnectionManager.Intf, UniAdminServices;

type
  /// <summary>
  /// UniGUI 主模块（每会话单例，会话的"心脏"）
  /// 继承自 TUniGUIMainModule，持有该会话独立的数据库连接、服务容器，
  /// 以及登录后构造的执行上下文（Context，含真实权限）。
  ///
  /// 登录态由本模块按会话隔离持有（SetLoginResult/Context），不再使用
  /// 进程级 class var 传递，避免多用户并发覆盖。
  /// </summary>
  TMainModule = class(TUniGUIMainModule)
    procedure OnCreate(Sender: TObject);
    procedure OnDestroy(Sender: TObject);
  private
    FConfigService: IUniAdminConfigService;
    FModuleRegistry: IUniAdminModuleRegistry;
    FConnection: TFDConnection;
    FServices: IUniAdminServices;
    FContext: IExecutionContext;
  public
    /// <summary>获取配置服务实例</summary>
    function GetConfigService: IUniAdminConfigService;

    /// <summary>获取插件注册表实例</summary>
    function GetModuleRegistry: IUniAdminModuleRegistry;

    /// <summary>
    /// 记录登录结果并构造该会话的执行上下文。
    /// 内部通过 PermissionManager 查询用户真实权限（RBAC）并注入上下文，
    /// 替代旧版硬编码的 ['read','write','delete'] 假权限。
    /// </summary>
    procedure SetLoginResult(const ALogin: TLoginResult);

    /// <summary>当前会话的数据库连接</summary>
    property Connection: TFDConnection read FConnection;
    /// <summary>当前会话的服务容器</summary>
    property Services: IUniAdminServices read FServices;
    /// <summary>当前会话的执行上下文（登录成功后由 SetLoginResult 构造）</summary>
    property Context: IExecutionContext read FContext;
  end;

function GetMainModule: TMainModule;

implementation

{$R *.dfm}

uses
  System.Generics.Collections,
  UniAdminConfigService, UniAdminModuleRegistry, UniAdminLogger, uniGUIVars,
  UniAdminConnectionManager, UniAdminPermissionManager.Intf;


function GetMainModule: TMainModule;
begin
  Result := TMainModule(UniApplication.UniMainModule)
end;

{ TMainModule }

procedure TMainModule.OnCreate(Sender: TObject);
begin

  // 从服务器模块获取配置服务和插件注册表
  // 注意：这些是全局单例，在整个应用中共享
  FConfigService := TUniAdminConfigService.GetInstance;
  FModuleRegistry := TUniAdminModuleRegistry.GetInstance;

  // 创建当前会话的数据库连接（每会话一个独立连接）
  FConnection := TUniAdminConnectionManager.GetInstance.GetDefaultConnection;
  // 创建服务容器，持有该连接（OwnsConnection=True，销毁时释放连接）
  FServices := TUniAdminServices.Create(FConnection, True);

  // 记录日志
  LogInfo('UniGUI Main Module initialized successfully.');
end;

procedure TMainModule.OnDestroy(Sender: TObject);
begin
  // 释放执行上下文（接口引用计数自动释放）
  FContext := nil;

  // 释放服务容器（OwnsConnection=True，连带释放数据库连接）
  FServices := nil;
  FConnection := nil;

  // 清理接口引用（不释放单例，只是减少引用计数）
  FConfigService := nil;
  FModuleRegistry := nil;

  LogInfo('UniGUI Main Module destroyed.');
end;

function TMainModule.GetConfigService: IUniAdminConfigService;
begin
  Result := FConfigService;
end;

function TMainModule.GetModuleRegistry: IUniAdminModuleRegistry;
begin
  Result := FModuleRegistry;
end;

procedure TMainModule.SetLoginResult(const ALogin: TLoginResult);
var
  LSessionInfo: TSessionInfo;
  LUserContext: IUserContext;
  LPermInfos: TArray<TPermissionInfo>;
  LPermissions: TArray<string>;
  LDataScopes: TDictionary<string, string>;
  LIdx: Integer;
begin
  // 重置上下文（接口引用计数释放旧实例）
  FContext := nil;

  if not ALogin.Success then
    Exit;

  // 从权限管理器获取该用户的真实权限码
  // RBAC: UniAdmin_UserRoles → UniAdmin_RolePermissions → UniAdmin_Permissions
  LPermissions := nil;
  if Assigned(FServices) then
  begin
    LPermInfos := FServices.PermissionManager.GetUserPermissions(ALogin.UserID);
    SetLength(LPermissions, Length(LPermInfos));
    for LIdx := 0 to High(LPermInfos) do
      LPermissions[LIdx] := LPermInfos[LIdx].PermissionCode;
  end;

  // 构造会话信息（uniGUI 会话 ID + 真实客户端 IP）
  LSessionInfo := TSessionInfo.Create(
    uniGUIApplication.UniApplication.UniSession.SessionId,
    ALogin.UserID,
    ALogin.UserName,
    ALogin.RealName,
    uniGUIApplication.UniApplication.UniSession.RemoteIP
  );

  // 数据范围默认全部（按资源细粒度查询可后续扩展）
  LDataScopes := TDictionary<string, string>.Create;
  LDataScopes.Add('default', 'all');

  LUserContext := TUserContextImpl.Create(LSessionInfo, LPermissions, LDataScopes);
  FContext := TExecutionContextImpl.Create(LUserContext, nil);

  LogInfo(Format('Login context established: UserID=%d, Permissions=%d',
    [ALogin.UserID, Length(LPermissions)]));
end;

initialization
  // 注册主模块类，供 InitServerModule 绑定到 FMainModuleClass
  RegisterMainModuleClass(TMainModule);
end.

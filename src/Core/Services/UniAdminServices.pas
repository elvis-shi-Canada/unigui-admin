unit UniAdminServices;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  FireDAC.Comp.Client,
  UniAdminConnectionManager.Intf, UniAdminAuthService.Intf, UniAdminMetadataCache.Intf,
  UniAdminMenuManager.Intf, UniAdminPermissionManager.Intf;

type
  /// <summary>
  /// 服务容器接口 - 提供对当前会话所有核心服务的统一访问
  /// </summary>
  IUniAdminServices = interface(IInterface)
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    function Connection: TFDConnection;
    function ConnectionManager: IUniAdminConnectionManager;
    function AuthService: IUniAdminAuthService;
    function MetadataCache: IUniAdminMetadataCache;
    function MenuManager: IUniAdminMenuManager;
    function PermissionManager: IUniAdminPermissionManager;
  end;

  /// <summary>
  /// 服务容器 - 每会话实例，持有该会话的数据库连接和所有核心服务
  /// 由 TMainModule 创建和管理生命周期
  /// </summary>
  TUniAdminServices = class(TInterfacedObject, IUniAdminServices)
  private
    FConnection: TFDConnection;
    FOwnsConnection: Boolean;
    FConnectionManager: IUniAdminConnectionManager;
    FAuthService: IUniAdminAuthService;
    FMetadataCache: IUniAdminMetadataCache;
    FMenuManager: IUniAdminMenuManager;
    FPermissionManager: IUniAdminPermissionManager;
  public
    /// <summary>
    /// 创建服务容器实例
    /// </summary>
    /// <param name="Connection">该会话的数据库连接（必须已连接）</param>
    /// <param name="OwnsConnection">是否在销毁时释放连接</param>
    constructor Create(const Connection: TFDConnection; const OwnsConnection: Boolean = False);
    destructor Destroy; override;

    function Connection: TFDConnection;
    function ConnectionManager: IUniAdminConnectionManager;
    function AuthService: IUniAdminAuthService;
    function MetadataCache: IUniAdminMetadataCache;
    function MenuManager: IUniAdminMenuManager;
    function PermissionManager: IUniAdminPermissionManager;
  end;

implementation

uses
  UniAdminConnectionManager, UniAdminAuthService, UniAdminMetadataCache,
  UniAdminMenuManager, UniAdminPermissionManager;

{ TUniAdminServices }

constructor TUniAdminServices.Create(const Connection: TFDConnection; const OwnsConnection: Boolean);
begin
  inherited Create;
  if not Assigned(Connection) then
    raise Exception.Create('Connection object cannot be nil');
  if not Connection.Connected then
    raise Exception.Create('Connection must be opened before initializing services');

  FConnection := Connection;
  FOwnsConnection := OwnsConnection;

  // 初始化所有核心服务（使用构造函数直接创建，而非 GetInstance 单例）
  FConnectionManager := TUniAdminConnectionManager.GetInstance;
  FAuthService := TUniAdminAuthService.Create(FConnection);
  FMetadataCache := TUniAdminMetadataCache.Create(FConnection);
  FMenuManager := TUniAdminMenuManager.Create(FConnection);
  FPermissionManager := TUniAdminPermissionManager.Create(FConnection);
end;

destructor TUniAdminServices.Destroy;
begin
  // 按照依赖关系的逆序释放服务
  FPermissionManager := nil;
  FMenuManager := nil;
  FMetadataCache := nil;
  FAuthService := nil;
  FConnectionManager := nil;

  if FOwnsConnection and Assigned(FConnection) then
  begin
    if FConnection.Connected then
      FConnection.Connected := False;
    FConnection.Free;
  end;
  FConnection := nil;

  inherited;
end;

function TUniAdminServices.Connection: TFDConnection;
begin
  Result := FConnection;
end;

function TUniAdminServices.ConnectionManager: IUniAdminConnectionManager;
begin
  Result := FConnectionManager;
end;

function TUniAdminServices.AuthService: IUniAdminAuthService;
begin
  Result := FAuthService;
end;

function TUniAdminServices.MetadataCache: IUniAdminMetadataCache;
begin
  Result := FMetadataCache;
end;

function TUniAdminServices.MenuManager: IUniAdminMenuManager;
begin
  Result := FMenuManager;
end;

function TUniAdminServices.PermissionManager: IUniAdminPermissionManager;
begin
  Result := FPermissionManager;
end;

end.

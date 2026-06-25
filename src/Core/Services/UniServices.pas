unit UniServices;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  FireDAC.Comp.Client,
  UniConnectionManager.Intf, UniAuthService.Intf, UniMetadataCache.Intf,
  UniMenuManager.Intf, UniPermissionManager.Intf;

type
  /// <summary>
  /// 服务容器接口 - 提供对当前会话所有核心服务的统一访问
  /// </summary>
  IUniServices = interface(IInterface)
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    function Connection: TFDConnection;
    function ConnectionManager: IUniConnectionManager;
    function AuthService: IUniAuthService;
    function MetadataCache: IUniMetadataCache;
    function MenuManager: IUniMenuManager;
    function PermissionManager: IUniPermissionManager;
  end;

  /// <summary>
  /// 服务容器 - 每会话实例，持有该会话的数据库连接和所有核心服务
  /// 由 TMainModule 创建和管理生命周期
  /// </summary>
  TUniServices = class(TInterfacedObject, IUniServices)
  private
    FConnection: TFDConnection;
    FOwnsConnection: Boolean;
    FConnectionManager: IUniConnectionManager;
    FAuthService: IUniAuthService;
    FMetadataCache: IUniMetadataCache;
    FMenuManager: IUniMenuManager;
    FPermissionManager: IUniPermissionManager;
  public
    /// <summary>
    /// 创建服务容器实例
    /// </summary>
    /// <param name="Connection">该会话的数据库连接（必须已连接）</param>
    /// <param name="OwnsConnection">是否在销毁时释放连接</param>
    constructor Create(const Connection: TFDConnection; const OwnsConnection: Boolean = False);
    destructor Destroy; override;

    function Connection: TFDConnection;
    function ConnectionManager: IUniConnectionManager;
    function AuthService: IUniAuthService;
    function MetadataCache: IUniMetadataCache;
    function MenuManager: IUniMenuManager;
    function PermissionManager: IUniPermissionManager;
  end;

implementation

uses
  UniConnectionManager, UniAuthService, UniMetadataCache,
  UniMenuManager, UniPermissionManager;

{ TUniServices }

constructor TUniServices.Create(const Connection: TFDConnection; const OwnsConnection: Boolean);
begin
  inherited Create;
  if not Assigned(Connection) then
    raise Exception.Create('Connection object cannot be nil');
  if not Connection.Connected then
    raise Exception.Create('Connection must be opened before initializing services');

  FConnection := Connection;
  FOwnsConnection := OwnsConnection;

  // 初始化所有核心服务（使用构造函数直接创建，而非 GetInstance 单例）
  FConnectionManager := TUniConnectionManager.GetInstance;
  FAuthService := TUniAuthService.Create(FConnection);
  FMetadataCache := TUniMetadataCache.Create(FConnection);
  FMenuManager := TUniMenuManager.Create(FConnection);
  FPermissionManager := TUniPermissionManager.Create(FConnection);
end;

destructor TUniServices.Destroy;
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

function TUniServices.Connection: TFDConnection;
begin
  Result := FConnection;
end;

function TUniServices.ConnectionManager: IUniConnectionManager;
begin
  Result := FConnectionManager;
end;

function TUniServices.AuthService: IUniAuthService;
begin
  Result := FAuthService;
end;

function TUniServices.MetadataCache: IUniMetadataCache;
begin
  Result := FMetadataCache;
end;

function TUniServices.MenuManager: IUniMenuManager;
begin
  Result := FMenuManager;
end;

function TUniServices.PermissionManager: IUniPermissionManager;
begin
  Result := FPermissionManager;
end;

end.

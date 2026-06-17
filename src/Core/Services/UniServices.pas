unit UniServices;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  FireDAC.Comp.Client,
  UniConnectionManager.Intf, UniAuthService.Intf, UniMetadataCache.Intf,
  UniMenuManager.Intf, UniPermissionManager.Intf;

type
  /// <summary>
  /// 服务定位器 - 提供对所有核心服务的统一访问
  /// 负责服务的初始化、生命周期管理和访问控制
  /// </summary>
  TUniServices = class
  private
    class var FConnection: TFDConnection;
    class var FConnectionManager: IUniConnectionManager;
    class var FAuthService: IUniAuthService;
    class var FMetadataCache: IUniMetadataCache;
    class var FMenuManager: IUniMenuManager;
    class var FPermissionManager: IUniPermissionManager;
    class var FInitialized: Boolean;
    class var FLock: TObject;

    class procedure InitializeServices; static;
    class procedure FinalizeServices; static;
    class function GetIsInitialized: Boolean; static;
  public
    /// <summary>
    /// 初始化服务定位器
    /// </summary>
    /// <param name="Connection">数据库连接对象</param>
    /// <exception cref="Exception">连接对象为空或未连接时抛出异常</exception>
    class procedure Initialize(const Connection: TFDConnection); static;

    /// <summary>
    /// 关闭服务定位器并释放所有服务
    /// </summary>
    class procedure Shutdown; static;

    /// <summary>
    /// 检查服务是否已初始化
    /// </summary>
    class property IsInitialized: Boolean read GetIsInitialized;

    /// <summary>
    /// 获取数据库连接对象
    /// </summary>
    class function Connection: TFDConnection; static;

    /// <summary>
    /// 获取连接管理器服务
    /// </summary>
    /// <exception cref="Exception">服务未初始化时抛出异常</exception>
    class function ConnectionManager: IUniConnectionManager; static;

    /// <summary>
    /// 获取认证服务
    /// </summary>
    /// <exception cref="Exception">服务未初始化时抛出异常</exception>
    class function AuthService: IUniAuthService; static;

    /// <summary>
    /// 获取元数据缓存服务
    /// </summary>
    /// <exception cref="Exception">服务未初始化时抛出异常</exception>
    class function MetadataCache: IUniMetadataCache; static;

    /// <summary>
    /// 获取菜单管理器服务
    /// </summary>
    /// <exception cref="Exception">服务未初始化时抛出异常</exception>
    class function MenuManager: IUniMenuManager; static;

    /// <summary>
    /// 获取权限管理器服务
    /// </summary>
    /// <exception cref="Exception">服务未初始化时抛出异常</exception>
    class function PermissionManager: IUniPermissionManager; static;
  end;

implementation

uses
  UniConnectionManager, UniAuthService, UniMetadataCache,
  UniMenuManager, UniPermissionManager;

{ TUniServices }

class procedure TUniServices.Initialize(const Connection: TFDConnection);
begin
  if not Assigned(Connection) then
    raise Exception.Create('Connection object cannot be nil');

  if not Connection.Connected then
    raise Exception.Create('Connection must be opened before initializing services');

  FConnection := Connection;
  InitializeServices;
end;

class procedure TUniServices.InitializeServices;
begin
  TMonitor.Enter(FLock);
  try
    if FInitialized then
      Exit;

    if Assigned(FConnection) and FConnection.Connected then
    begin
      // 初始化所有核心服务
      FConnectionManager := TUniConnectionManager.GetInstance;
      FAuthService := TUniAuthService.GetInstance(FConnection);
      FMetadataCache := TUniMetadataCache.GetInstance(FConnection);
      FMenuManager := TUniMenuManager.GetInstance(FConnection);
      FPermissionManager := TUniPermissionManager.GetInstance(FConnection);

      FInitialized := True;
    end;
  finally
    TMonitor.Exit(FLock);
  end;
end;

class procedure TUniServices.Shutdown;
begin
  TMonitor.Enter(FLock);
  try
    FinalizeServices;
    FConnection := nil;
  finally
    TMonitor.Exit(FLock);
  end;
end;

class procedure TUniServices.FinalizeServices;
begin
  // 按照依赖关系的逆序释放服务
  FPermissionManager := nil;
  FMenuManager := nil;
  FMetadataCache := nil;
  FAuthService := nil;
  FConnectionManager := nil;

  FInitialized := False;
end;

class function TUniServices.GetIsInitialized: Boolean;
begin
  Result := FInitialized;
end;

class function TUniServices.Connection: TFDConnection;
begin
  Result := FConnection;
end;

class function TUniServices.ConnectionManager: IUniConnectionManager;
begin
  if not Assigned(FConnectionManager) then
    raise Exception.Create('ConnectionManager not initialized. Call TUniServices.Initialize first.');
  Result := FConnectionManager;
end;

class function TUniServices.AuthService: IUniAuthService;
begin
  if not Assigned(FAuthService) then
    raise Exception.Create('AuthService not initialized. Call TUniServices.Initialize first.');
  Result := FAuthService;
end;

class function TUniServices.MetadataCache: IUniMetadataCache;
begin
  if not Assigned(FMetadataCache) then
    raise Exception.Create('MetadataCache not initialized. Call TUniServices.Initialize first.');
  Result := FMetadataCache;
end;

class function TUniServices.MenuManager: IUniMenuManager;
begin
  if not Assigned(FMenuManager) then
    raise Exception.Create('MenuManager not initialized. Call TUniServices.Initialize first.');
  Result := FMenuManager;
end;

class function TUniServices.PermissionManager: IUniPermissionManager;
begin
  if not Assigned(FPermissionManager) then
    raise Exception.Create('PermissionManager not initialized. Call TUniServices.Initialize first.');
  Result := FPermissionManager;
end;

initialization
  TUniServices.FLock := TObject.Create;
  TUniServices.FInitialized := False;
  TUniServices.FConnection := nil;
  TUniServices.FConnectionManager := nil;
  TUniServices.FAuthService := nil;
  TUniServices.FMetadataCache := nil;
  TUniServices.FMenuManager := nil;
  TUniServices.FPermissionManager := nil;

finalization
  TUniServices.Shutdown;
  FreeAndNil(TUniServices.FLock);

end.

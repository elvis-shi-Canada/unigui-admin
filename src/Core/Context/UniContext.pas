unit UniContext;

interface

uses
  System.SysUtils, System.Generics.Collections;

type
  // 数据库配置接口
  IDatabaseConfig = interface(IInterface)
    ['{5D762A2D-F75D-481E-8696-22A1CBF147BD}']
    function GetConnectionDefName: string;
    function GetConnectionString: string;
    function GetDatabaseName: string;
    function GetServerName: string;
  end;

  // 用户上下文接口
  IUserContext = interface(IInterface)
    ['{A2C8E4B1-7F5A-3D4B-C2DA-8A7E9F1B4C6D}']
    function GetUserID: Integer;
    function GetUserName: string;
    function GetRealName: string;
    function HasPermission(const PermissionCode: string): Boolean;
    function GetUserPermissions: TArray<string>;
    function GetDataScope(const Resource: string): string;
    function GetSessionID: string;
    function GetClientIP: string;
  end;

  // 执行上下文接口
  IExecutionContext = interface(IInterface)
    ['{E3D9F5C2-B4A8-5C3D-D7EA-1B8C4E9A2F6B}']
    function GetUserContext: IUserContext;
    function GetCurrentUserID: Integer;
    function GetCurrentUserName: string;
    function GetCurrentTime: TDateTime;
    function GetDatabaseConfig: IDatabaseConfig;
  end;

  /// <summary>会话状态枚举</summary>
  TSessionState = (
    ssDisconnected,  // 未连接
    ssConnecting,    // 连接中
    ssConnected,     // 已连接
    ssAuthenticating,// 认证中
    ssAuthenticated, // 已认证
    ssDisconnecting, // 断开连接中
    ssError          // 错误状态
  );

  /// <summary>会话信息记录</summary>
  TSessionInfo = record
    /// <summary>会话ID</summary>
    SessionID: string;
    /// <summary>用户ID</summary>
    UserID: Integer;
    /// <summary>用户名</summary>
    UserName: string;
    /// <summary>真实姓名</summary>
    RealName: string;
    /// <summary>客户端IP地址</summary>
    ClientIP: string;
    /// <summary>登录时间</summary>
    LoginTime: TDateTime;
    /// <summary>最后活动时间</summary>
    LastActivityTime: TDateTime;
    /// <summary>会话状态</summary>
    State: TSessionState;
    /// <summary>创建会话信息</summary>
    class function Create(const ASessionID: string; AUserID: Integer;
      const AUserName, ARealName, AClientIP: string): TSessionInfo; static;
  end;

  /// <summary>
  /// 用户上下文实现类
  /// 实现 IUserContext 接口
  /// </summary>
  TUserContextImpl = class(TInterfacedObject, IUserContext)
  private
    FSessionInfo: TSessionInfo;
    FPermissions: TArray<string>;
    FDataScopes: TDictionary<string, string>;
  public
    constructor Create(const ASessionInfo: TSessionInfo;
      const APermissions: TArray<string>; const ADataScopes: TDictionary<string, string>);
    destructor Destroy; override;

    /// <summary>获取用户ID</summary>
    function GetUserID: Integer;
    /// <summary>获取用户名</summary>
    function GetUserName: string;
    /// <summary>获取真实姓名</summary>
    function GetRealName: string;
    /// <summary>检查是否有指定权限</summary>
    function HasPermission(const PermissionCode: string): Boolean;
    /// <summary>获取用户所有权限</summary>
    function GetUserPermissions: TArray<string>;
    /// <summary>获取数据范围</summary>
    function GetDataScope(const Resource: string): string;
    /// <summary>获取会话ID</summary>
    function GetSessionID: string;
    /// <summary>获取客户端IP</summary>
    function GetClientIP: string;
  end;

  /// <summary>
  /// 执行上下文实现类
  /// 实现 IExecutionContext 接口
  /// </summary>
  TExecutionContextImpl = class(TInterfacedObject, IExecutionContext)
  private
    FUserContext: IUserContext;
    FDatabaseConfig: IDatabaseConfig;
  public
    constructor Create(AUserContext: IUserContext; ADatabaseConfig: IDatabaseConfig);

    /// <summary>获取用户上下文</summary>
    function GetUserContext: IUserContext;
    /// <summary>获取当前用户ID</summary>
    function GetCurrentUserID: Integer;
    /// <summary>获取当前用户名</summary>
    function GetCurrentUserName: string;
    /// <summary>获取当前时间</summary>
    function GetCurrentTime: TDateTime;
    /// <summary>获取数据库配置</summary>
    function GetDatabaseConfig: IDatabaseConfig;
  end;

implementation

{ TSessionInfo }

class function TSessionInfo.Create(const ASessionID: string; AUserID: Integer;
  const AUserName, ARealName, AClientIP: string): TSessionInfo;
begin
  Result.SessionID := ASessionID;
  Result.UserID := AUserID;
  Result.UserName := AUserName;
  Result.RealName := ARealName;
  Result.ClientIP := AClientIP;
  Result.LoginTime := Now;
  Result.LastActivityTime := Now;
  Result.State := ssConnected;
end;

{ TUserContextImpl }

constructor TUserContextImpl.Create(const ASessionInfo: TSessionInfo;
  const APermissions: TArray<string>; const ADataScopes: TDictionary<string, string>);
begin
  inherited Create;
  FSessionInfo := ASessionInfo;
  FPermissions := APermissions;
  if ADataScopes <> nil then
    FDataScopes := ADataScopes
  else
    FDataScopes := TDictionary<string, string>.Create;
end;

destructor TUserContextImpl.Destroy;
begin
  FDataScopes.Free;
  inherited;
end;

function TUserContextImpl.GetUserID: Integer;
begin
  Result := FSessionInfo.UserID;
end;

function TUserContextImpl.GetUserName: string;
begin
  Result := FSessionInfo.UserName;
end;

function TUserContextImpl.GetRealName: string;
begin
  Result := FSessionInfo.RealName;
end;

function TUserContextImpl.HasPermission(const PermissionCode: string): Boolean;
var
  LPermission: string;
begin
  Result := False;
  for LPermission in FPermissions do
  begin
    if SameText(LPermission, PermissionCode) then
      Exit(True);
  end;
end;

function TUserContextImpl.GetUserPermissions: TArray<string>;
begin
  Result := Copy(FPermissions);
end;

function TUserContextImpl.GetDataScope(const Resource: string): string;
begin
  if not FDataScopes.TryGetValue(Resource, Result) then
    Result := '';
end;

function TUserContextImpl.GetSessionID: string;
begin
  Result := FSessionInfo.SessionID;
end;

function TUserContextImpl.GetClientIP: string;
begin
  Result := FSessionInfo.ClientIP;
end;

{ TExecutionContextImpl }

constructor TExecutionContextImpl.Create(AUserContext: IUserContext;
  ADatabaseConfig: IDatabaseConfig);
begin
  inherited Create;
  FUserContext := AUserContext;
  FDatabaseConfig := ADatabaseConfig;
end;

function TExecutionContextImpl.GetUserContext: IUserContext;
begin
  Result := FUserContext;
end;

function TExecutionContextImpl.GetCurrentUserID: Integer;
begin
  if FUserContext <> nil then
    Result := FUserContext.GetUserID
  else
    Result := 0;
end;

function TExecutionContextImpl.GetCurrentUserName: string;
begin
  if FUserContext <> nil then
    Result := FUserContext.GetUserName
  else
    Result := '';
end;

function TExecutionContextImpl.GetCurrentTime: TDateTime;
begin
  Result := Now;
end;

function TExecutionContextImpl.GetDatabaseConfig: IDatabaseConfig;
begin
  Result := FDatabaseConfig;
end;

end.

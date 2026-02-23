unit UniSession;

interface

uses
  System.SysUtils, System.SyncObjs, System.Generics.Collections, System.Types,
  UniContext, UniPlugin.Intf;

type
  /// <summary>
  /// 会话状态枚举
  /// </summary>
  TSessionState = (
    ssDisconnected,  // 未连接
    ssConnecting,    // 连接中
    ssConnected,     // 已连接
    ssAuthenticating,// 认证中
    ssAuthenticated, // 已认证
    ssDisconnecting, // 断开连接中
    ssError          // 错误状态
  );

  /// <summary>
  /// 会话信息记录
  /// </summary>
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
    /// <summary>会话数据</summary>
    Data: TDictionary<string, string>;
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

  /// <summary>
  /// UniGUI 会话管理类
  /// 提供会话生命周期管理、插件管理、线程安全保护
  /// </summary>
  TUniSession = class
  private
    FLock: TCriticalSection;
    FSessionInfo: TSessionInfo;
    FLoadedPlugins: TList<IPlugin>;
    FExecutionContext: IExecutionContext;
    FIsActive: Boolean;

    /// <summary>更新会话状态</summary>
    procedure SetSessionState(AState: TSessionState);
    /// <summary>更新最后活动时间</summary>
    procedure UpdateActivityTime;
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>
    /// 用户登录
    /// </summary>
    /// <param name="AUserName">用户名</param>
    /// <param name="APassword">密码</param>
    /// <param name="AClientIP">客户端IP</param>
    /// <returns>登录成功返回 True</returns>
    function Login(const AUserName, APassword, AClientIP: string): Boolean;

    /// <summary>
    /// 用户登出
    /// </summary>
    procedure Logout;

    /// <summary>
    /// 检查会话是否已认证
    /// </summary>
    function IsAuthenticated: Boolean;

    /// <summary>
    /// 获取会话信息
    /// </summary>
    function GetSessionInfo: TSessionInfo;

    /// <summary>
    /// 获取执行上下文
    /// </summary>
    function GetExecutionContext: IExecutionContext;

    /// <summary>
    /// 设置执行上下文
    /// </summary>
    procedure SetExecutionContext(AContext: IExecutionContext);

    /// <summary>
    /// 加载插件
    /// </summary>
    /// <param name="APlugin">插件接口</param>
    /// <returns>加载成功返回 True</returns>
    function LoadPlugin(APlugin: IPlugin): Boolean;

    /// <summary>
    /// 卸载插件
    /// </summary>
    /// <param name="APlugin">插件接口</param>
    /// <returns>卸载成功返回 True</returns>
    function UnloadPlugin(APlugin: IPlugin): Boolean;

    /// <summary>
    /// 获取已加载的插件列表
    /// </summary>
    function GetLoadedPlugins: TArray<IPlugin>;

    /// <summary>
    /// 激活所有插件
    /// </summary>
    procedure ActivateAllPlugins;

    /// <summary>
    /// 停用所有插件
    /// </summary>
    procedure DeactivateAllPlugins;

    /// <summary>
    /// 设置会话数据
    /// </summary>
    /// <param name="AKey">键名</param>
    /// <param name="AValue">值</param>
    procedure SetSessionData(const AKey, AValue: string);

    /// <summary>
    /// 获取会话数据
    /// </summary>
    /// <param name="AKey">键名</param>
    /// <returns>返回对应的值，不存在则返回空字符串</returns>
    function GetSessionData(const AKey: string): string;

    /// <summary>
    /// 删除会话数据
    /// </summary>
    /// <param name="AKey">键名</param>
    procedure RemoveSessionData(const AKey: string);

    /// <summary>
    /// 清空所有会话数据
    /// </summary>
    procedure ClearSessionData;

    /// <summary>
    /// 检查会话是否活动
    /// </summary>
    function IsActive: Boolean;

    /// <summary>
    /// 获取会话超时时间（分钟）
    /// </summary>
    class function GetSessionTimeout: Integer; static;
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
  Result.Data := TDictionary<string, string>.Create;
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
  FDataScopes.Dispose;
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

{ TUniSession }

constructor TUniSession.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FLoadedPlugins := TList<IPlugin>.Create;
  FIsActive := False;

  // 初始化空会话信息
  FSessionInfo := TSessionInfo.Create('', 0, '', '', '');
  FSessionInfo.State := ssDisconnected;
end;

destructor TUniSession.Destroy;
begin
  // 登出并清理资源
  if FIsActive then
    Logout;

  // 清理插件
  DeactivateAllPlugins;
  FLoadedPlugins.Clear;
  FLoadedPlugins.Dispose;

  // 清理会话数据（修复 P0-1：正确释放 Data 字典）
  if FSessionInfo.Data <> nil then
  begin
    FSessionInfo.Data.Clear;
    FSessionInfo.Data.Dispose;
    FSessionInfo.Data := nil;
  end;

  FLock.Dispose;
  inherited;
end;

function TUniSession.Login(const AUserName, APassword, AClientIP: string): Boolean;
var
  LSessionID: string;
  LUserContext: IUserContext;
  LPermissions: TArray<string>;
  LDataScopes: TDictionary<string, string>;
  LGUID: TGUID;
begin
  FLock.Acquire;
  try
    // TODO: 实际项目中应验证用户名和密码
    // 这里简化处理，直接认为登录成功

    // 检查是否已经登录
    if FIsActive then
      Exit(False);

    SetSessionState(ssAuthenticating);

    // 修复 P0-2：使用 GUID 生成会话 ID 提高安全性
    if CreateGUID(LGUID) = 0 then
      LSessionID := GUIDToString(LGUID)
    else
      // 如果 GUID 生成失败，使用时间戳 + 随机数作为后备方案
      LSessionID := FormatDateTime('yyyymmddhhnnsszzz', Now) + '-' + IntToStr(Random(MaxInt));

    // 创建用户上下文
    LPermissions := TArray<string>.Create('read', 'write', 'delete');
    LDataScopes := TDictionary<string, string>.Create;
    try
      LDataScopes.Add('default', 'all');

      // 修复 P0-1：在重新创建 FSessionInfo 前，先释放旧的 Data 字典
      if FSessionInfo.Data <> nil then
      begin
        FSessionInfo.Data.Clear;
        FSessionInfo.Data.Dispose;
      end;

      FSessionInfo := TSessionInfo.Create(LSessionID, 1, AUserName, AUserName, AClientIP);
      LUserContext := TUserContextImpl.Create(FSessionInfo, LPermissions, LDataScopes);

      // 创建执行上下文
      FExecutionContext := TExecutionContextImpl.Create(LUserContext, nil);

      SetSessionState(ssAuthenticated);
      FIsActive := True;
      UpdateActivityTime;

      Result := True;
    except
      LDataScopes.Dispose;
      raise;
    end;
  finally
    FLock.Release;
  end;
end;

procedure TUniSession.Logout;
begin
  FLock.Acquire;
  try
    if not FIsActive then
      Exit;

    SetSessionState(ssDisconnecting);

    // 停用所有插件
    DeactivateAllPlugins;

    // 清理会话数据
    ClearSessionData;

    SetSessionState(ssDisconnected);
    FIsActive := False;
  finally
    FLock.Release;
  end;
end;

function TUniSession.IsAuthenticated: Boolean;
begin
  FLock.Acquire;
  try
    Result := FIsActive and (FSessionInfo.State = ssAuthenticated);
  finally
    FLock.Release;
  end;
end;

function TUniSession.GetSessionInfo: TSessionInfo;
begin
  FLock.Acquire;
  try
    Result := FSessionInfo;
  finally
    FLock.Release;
  end;
end;

function TUniSession.GetExecutionContext: IExecutionContext;
begin
  FLock.Acquire;
  try
    Result := FExecutionContext;
  finally
    FLock.Release;
  end;
end;

procedure TUniSession.SetExecutionContext(AContext: IExecutionContext);
begin
  FLock.Acquire;
  try
    FExecutionContext := AContext;
  finally
    FLock.Release;
  end;
end;

function TUniSession.LoadPlugin(APlugin: IPlugin): Boolean;
begin
  FLock.Acquire;
  try
    if not FIsActive then
      Exit(False);

    if FLoadedPlugins.Contains(APlugin) then
      Exit(False);

    try
      APlugin.Initialize;
      APlugin.Activate;
      FLoadedPlugins.Add(APlugin);
      Result := True;
    except
      Result := False;
    end;
  finally
    FLock.Release;
  end;
end;

function TUniSession.UnloadPlugin(APlugin: IPlugin): Boolean;
begin
  FLock.Acquire;
  try
    if not FLoadedPlugins.Contains(APlugin) then
      Exit(False);

    try
      APlugin.Deactivate;
      FLoadedPlugins.Remove(APlugin);
      Result := True;
    except
      Result := False;
    end;
  finally
    FLock.Release;
  end;
end;

function TUniSession.GetLoadedPlugins: TArray<IPlugin>;
begin
  FLock.Acquire;
  try
    Result := FLoadedPlugins.ToArray;
  finally
    FLock.Release;
  end;
end;

procedure TUniSession.ActivateAllPlugins;
var
  LPlugin: IPlugin;
begin
  FLock.Acquire;
  try
    for LPlugin in FLoadedPlugins do
    begin
      try
        if LPlugin.GetState <> psActivated then
          LPlugin.Activate;
      except
        // 忽略单个插件激活失败的错误
      end;
    end;
  finally
    FLock.Release;
  end;
end;

procedure TUniSession.DeactivateAllPlugins;
var
  LPlugin: IPlugin;
begin
  FLock.Acquire;
  try
    for LPlugin in FLoadedPlugins do
    begin
      try
        if LPlugin.GetState = psActivated then
          LPlugin.Deactivate;
      except
        // 忽略单个插件停用失败的错误
      end;
    end;
  finally
    FLock.Release;
  end;
end;

procedure TUniSession.SetSessionData(const AKey, AValue: string);
begin
  FLock.Acquire;
  try
    if FSessionInfo.Data.ContainsKey(AKey) then
      FSessionInfo.Data[AKey] := AValue
    else
      FSessionInfo.Data.Add(AKey, AValue);
    UpdateActivityTime;
  finally
    FLock.Release;
  end;
end;

function TUniSession.GetSessionData(const AKey: string): string;
begin
  FLock.Acquire;
  try
    if not FSessionInfo.Data.TryGetValue(AKey, Result) then
      Result := '';
    UpdateActivityTime;
  finally
    FLock.Release;
  end;
end;

procedure TUniSession.RemoveSessionData(const AKey: string);
begin
  FLock.Acquire;
  try
    if FSessionInfo.Data.ContainsKey(AKey) then
      FSessionInfo.Data.Remove(AKey);
    UpdateActivityTime;
  finally
    FLock.Release;
  end;
end;

procedure TUniSession.ClearSessionData;
begin
  FLock.Acquire;
  try
    FSessionInfo.Data.Clear;
  finally
    FLock.Release;
  end;
end;

function TUniSession.IsActive: Boolean;
begin
  FLock.Acquire;
  try
    Result := FIsActive;
  finally
    FLock.Release;
  end;
end;

class function TUniSession.GetSessionTimeout: Integer;
begin
  // 默认会话超时时间为30分钟
  Result := 30;
end;

procedure TUniSession.SetSessionState(AState: TSessionState);
begin
  FSessionInfo.State := AState;
end;

procedure TUniSession.UpdateActivityTime;
begin
  FSessionInfo.LastActivityTime := Now;
end;

end.

unit UniGUIMainModule;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.SyncObjs,
  System.DateUtils,
  UniGUIMainModule, UniGUIApplication, UniGUIClasses,
  UniSession, UniConfigService, UniModuleRegistry, UniPlugin.Intf;

type
  /// <summary>
  /// UniGUI 主模块
  /// 继承自 TUniGUIMainModule，负责会话管理和插件生命周期管理
  /// </summary>
  TUniGUIMainModule = class(TUniGUIMainModule)
  private
    FSessionLock: TCriticalSection;
    FSessions: TDictionary<string, TUniSession>;
    FConfigService: IUniConfigService;
    FModuleRegistry: IUniModuleRegistry;

    /// <summary>清理非活动会话</summary>
    procedure CleanupInactiveSessions;
    /// <summary>获取会话超时时间（分钟）</summary>
    function GetSessionTimeoutMinutes: Integer;
  protected
    /// <summary>主模块创建事件</summary>
    procedure OnCreate(Sender: TObject);
    /// <summary>主模块销毁事件</summary>
    procedure OnDestroy(Sender: TObject);
  public
    /// <summary>获取或创建会话实例</summary>
    /// <param name="SessionID">会话ID</param>
    /// <returns>会话实例，如果不存在则创建新会话</returns>
    function GetOrCreateSession(const SessionID: string): TUniSession;

    /// <summary>移除会话实例</summary>
    /// <param name="SessionID">会话ID</param>
    /// <returns>如果移除成功返回True，否则返回False</returns>
    function RemoveSession(const SessionID: string): Boolean;

    /// <summary>检查会话是否存在</summary>
    /// <param name="SessionID">会话ID</param>
    /// <returns>如果会话存在返回True</returns>
    function HasSession(const SessionID: string): Boolean;

    /// <summary>获取所有活动会话ID列表</summary>
    /// <returns>会话ID数组</returns>
    function GetAllSessionIDs: TArray<string>;

    /// <summary>获取活动会话数量</summary>
    /// <returns>会话数量</returns>
    function GetSessionCount: Integer;

    /// <summary>获取配置服务实例</summary>
    function GetConfigService: IUniConfigService;

    /// <summary>获取插件注册表实例</summary>
    function GetModuleRegistry: IUniModuleRegistry;

    /// <summary>按插件ID加载并激活插件</summary>
    /// <param name="PluginID">插件ID</param>
    /// <param name="SessionID">会话ID</param>
    /// <returns>如果加载成功返回True</returns>
    function LoadPluginForSession(const PluginID, SessionID: string): Boolean;
  end;

function UniMainModule: TUniGUIMainModule;

implementation

{$R *.dfm}

var
  GUniMainModule: TUniGUIMainModule;

function UniMainModule: TUniGUIMainModule;
begin
  Result := GUniMainModule;
end;

{ TUniGUIMainModule }

procedure TUniGUIMainModule.OnCreate(Sender: TObject);
begin
  // 设置全局实例引用
  GUniMainModule := Self;

  // 初始化线程安全锁
  FSessionLock := TCriticalSection.Create;
  FSessions := TDictionary<string, TUniSession>.Create;

  // 从服务器模块获取配置服务和插件注册表
  // 注意：这些是全局单例，在整个应用中共享
  FConfigService := TUniConfigService.GetInstance;
  FModuleRegistry := TUniModuleRegistry.GetInstance;

  // 记录日志
  WriteLn('UniGUI Main Module initialized successfully.');
end;

procedure TUniGUIMainModule.OnDestroy(Sender: TObject);
var
  LPair: TPair<string, TUniSession>;
  LSession: TUniSession;
begin
  // 清理所有会话
  FSessionLock.Acquire;
  try
    // 释放所有会话对象
    for LPair in FSessions do
    begin
      LSession := LPair.Value;
      if LSession <> nil then
      begin
        LSession.Free;
      end;
    end;

    // 清空会话字典
    FSessions.Clear;
  finally
    FSessionLock.Release;
  end;

  // 释放会话字典
  FSessions.Free;
  FSessions := nil;

  // 释放线程安全锁
  FSessionLock.Free;
  FSessionLock := nil;

  // 清理接口引用（不释放单例，只是减少引用计数）
  FConfigService := nil;
  FModuleRegistry := nil;

  // 清理全局实例引用
  GUniMainModule := nil;

  WriteLn('UniGUI Main Module destroyed.');
end;

function TUniGUIMainModule.GetOrCreateSession(const SessionID: string): TUniSession;
var
  LSession: TUniSession;
begin
  if SessionID.IsEmpty then
    raise EArgumentException.Create('SessionID cannot be empty');

  FSessionLock.Acquire;
  try
    // 尝试获取现有会话
    if FSessions.TryGetValue(SessionID, LSession) then
    begin
      // 检查会话是否仍然有效
      if (LSession <> nil) and LSession.IsActive then
      begin
        Result := LSession;
        Exit;
      end
      else
      begin
        // 会话已失效，移除并清理
        FSessions.Remove(SessionID);
        if LSession <> nil then
          LSession.Free;
      end;
    end;

    // 创建新会话
    LSession := TUniSession.Create;
    FSessions.Add(SessionID, LSession);
    Result := LSession;

    WriteLn(Format('Session created: %s (Total: %d)', [SessionID, FSessions.Count]));
  finally
    FSessionLock.Release;
  end;
end;

function TUniGUIMainModule.RemoveSession(const SessionID: string): Boolean;
var
  LSession: TUniSession;
begin
  Result := False;

  if SessionID.IsEmpty then
    Exit;

  FSessionLock.Acquire;
  try
    if FSessions.TryGetValue(SessionID, LSession) then
    begin
      // 登出会话
      if (LSession <> nil) and LSession.IsActive then
        LSession.Logout;

      // 释放会话对象
      if LSession <> nil then
        LSession.Free;

      // 从字典中移除
      FSessions.Remove(SessionID);
      Result := True;

      WriteLn(Format('Session removed: %s (Total: %d)', [SessionID, FSessions.Count]));
    end;
  finally
    FSessionLock.Release;
  end;
end;

function TUniGUIMainModule.HasSession(const SessionID: string): Boolean;
var
  LSession: TUniSession;
begin
  Result := False;

  if SessionID.IsEmpty then
    Exit;

  FSessionLock.Acquire;
  try
    if FSessions.TryGetValue(SessionID, LSession) then
    begin
      Result := (LSession <> nil) and LSession.IsActive;
    end;
  finally
    FSessionLock.Release;
  end;
end;

function TUniGUIMainModule.GetAllSessionIDs: TArray<string>;
begin
  FSessionLock.Acquire;
  try
    Result := FSessions.Keys.ToArray;
  finally
    FSessionLock.Release;
  end;
end;

function TUniGUIMainModule.GetSessionCount: Integer;
begin
  FSessionLock.Acquire;
  try
    Result := FSessions.Count;
  finally
    FSessionLock.Release;
  end;
end;

function TUniGUIMainModule.GetConfigService: IUniConfigService;
begin
  Result := FConfigService;
end;

function TUniGUIMainModule.GetModuleRegistry: IUniModuleRegistry;
begin
  Result := FModuleRegistry;
end;

function TUniGUIMainModule.LoadPluginForSession(const PluginID,
  SessionID: string): Boolean;
var
  LSession: TUniSession;
  LPluginInfo: TPluginClassInfo;
  LPluginClass: TClass;
  LPlugin: IPlugin;
begin
  Result := False;

  if PluginID.IsEmpty or SessionID.IsEmpty then
    raise EArgumentException.Create('PluginID and SessionID cannot be empty');

  // 检查插件是否已注册
  if not FModuleRegistry.IsPluginRegistered(PluginID) then
  begin
    WriteLn(Format('Plugin not registered: %s', [PluginID]));
    Exit(False);
  end;

  // 获取插件信息
  LPluginInfo := FModuleRegistry.GetPluginClassInfo(PluginID);
  LPluginClass := LPluginInfo.PluginClass;

  // 获取会话
  LSession := GetOrCreateSession(SessionID);
  if not LSession.IsAuthenticated then
  begin
    WriteLn(Format('Session not authenticated: %s', [SessionID]));
    Exit(False);
  end;

  // 创建插件实例
  if Supports(LPluginClass, IPlugin, LPlugin) then
  begin
    Result := LSession.LoadPlugin(LPlugin);
    if Result then
      WriteLn(Format('Plugin loaded for session: %s -> %s', [PluginID, SessionID]))
    else
      WriteLn(Format('Failed to load plugin for session: %s -> %s', [PluginID, SessionID]));
  end
  else
  begin
    WriteLn(Format('Plugin class does not support IPlugin: %s', [PluginID]));
  end;
end;

procedure TUniGUIMainModule.CleanupInactiveSessions;
var
  LInactiveSessions: TList<string>;
  LPair: TPair<string, TUniSession>;
  LNow: TDateTime;
  LSession: TUniSession;
  LSessionInfo: TSessionInfo;
  LTimeoutMinutes: Integer;
begin
  LInactiveSessions := TList<string>.Create;
  LNow := Now;
  LTimeoutMinutes := GetSessionTimeoutMinutes;

  FSessionLock.Acquire;
  try
    // 查找不活动会话
    for LPair in FSessions do
    begin
      LSession := LPair.Value;
      if (LSession <> nil) and LSession.IsActive then
      begin
        LSessionInfo := LSession.GetSessionInfo;
        // 检查超时
        if MinutesBetween(LNow, LSessionInfo.LastActivityTime) > LTimeoutMinutes then
        begin
          LInactiveSessions.Add(LPair.Key);
        end;
      end;
    end;

    // 清理不活动会话
    for var LSessionID in LInactiveSessions do
    begin
      WriteLn(Format('Cleaning up inactive session: %s', [LSessionID]));
      RemoveSession(LSessionID);
    end;
  finally
    FSessionLock.Release;
    LInactiveSessions.Free;
  end;
end;

function TUniGUIMainModule.GetSessionTimeoutMinutes: Integer;
begin
  // 从配置读取超时时间，默认30分钟
  Result := FConfigService.GetGlobalInteger('server.sessionTimeout', 1800) div 60;
  if Result < 1 then
    Result := 30;
end;

initialization
  RegisterModule(TUniGUIMainModule);

finalization
  // 清理资源

end.

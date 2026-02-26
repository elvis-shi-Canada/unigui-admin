unit MainModule;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.SyncObjs,
  System.DateUtils,
  UniGUIMainModule, UniGUIApplication, UniGUIClasses,
  UniSession, UniConfigService.Intf, UniModuleRegistry.Intf, UniPlugin.Intf, UniPlugin.Types;

type
  /// <summary>
  /// UniGUI 主模块
  /// 继承自 TUniGUIMainModule，负责会话管理和插件生命周期管理
  /// </summary>
  TMainModule = class(TUniGUIMainModule)
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

function GetMainModule: TMainModule;

implementation

{$R *.dfm}

uses
  UniConfigService, UniModuleRegistry;

var
  GMainModule: TMainModule;

function GetMainModule: TMainModule;
begin
  Result := GMainModule;
end;

{ TMainModule }

procedure TMainModule.OnCreate(Sender: TObject);
begin
  // 设置全局实例引用
  GMainModule := Self;

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

procedure TMainModule.OnDestroy(Sender: TObject);
var
  LPair: TPair<string, TUniSession>;
  LSessionList: TList<TUniSession>;
  LSession: TUniSession;
begin
  LSessionList := TList<TUniSession>.Create;

  // 收集所有会话对象
  FSessionLock.Acquire;
  try
    for LPair in FSessions do
    begin
      LSession := LPair.Value;
      if LSession <> nil then
        LSessionList.Add(LSession);
    end;

    // 清空会话字典
    FSessions.Clear;
  finally
    FSessionLock.Release;
  end;

  // 在锁外释放会话对象，避免潜在回调问题
  for LSession in LSessionList do
  begin
    if LSession <> nil then
      LSession.Free;
  end;
  LSessionList.Free;

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
  GMainModule := nil;

  WriteLn('UniGUI Main Module destroyed.');
end;

function TMainModule.GetOrCreateSession(const SessionID: string): TUniSession;
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

function TMainModule.RemoveSession(const SessionID: string): Boolean;
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

function TMainModule.HasSession(const SessionID: string): Boolean;
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

function TMainModule.GetAllSessionIDs: TArray<string>;
begin
  FSessionLock.Acquire;
  try
    Result := FSessions.Keys.ToArray;
  finally
    FSessionLock.Release;
  end;
end;

function TMainModule.GetSessionCount: Integer;
begin
  FSessionLock.Acquire;
  try
    Result := FSessions.Count;
  finally
    FSessionLock.Release;
  end;
end;

function TMainModule.GetConfigService: IUniConfigService;
begin
  Result := FConfigService;
end;

function TMainModule.GetModuleRegistry: IUniModuleRegistry;
begin
  Result := FModuleRegistry;
end;

function TMainModule.LoadPluginForSession(const PluginID,
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

  // 首先获取会话，避免在持有其他资源时获取锁
  LSession := GetOrCreateSession(SessionID);
  if not LSession.IsAuthenticated then
  begin
    WriteLn(Format('Session not authenticated: %s', [SessionID]));
    Exit(False);
  end;

  // 检查插件是否已注册
  if not FModuleRegistry.IsPluginRegistered(PluginID) then
  begin
    WriteLn(Format('Plugin not registered: %s', [PluginID]));
    Exit(False);
  end;

  // 获取插件信息
  LPluginInfo := FModuleRegistry.GetPluginClassInfo(PluginID);

  // 创建插件实例
  LPlugin := FModuleRegistry.CreatePlugin(PluginID, LSession.GetExecutionContext.GetUserContext, LSession.GetExecutionContext);
  if LPlugin <> nil then
  begin
    Result := LSession.LoadPlugin(LPlugin);
    if Result then
      WriteLn(Format('Plugin loaded for session: %s -> %s', [PluginID, SessionID]))
    else
      WriteLn(Format('Failed to load plugin for session: %s -> %s', [PluginID, SessionID]));
  end
  else
  begin
    WriteLn(Format('Failed to create plugin instance: %s', [PluginID]));
  end;
end;

procedure TMainModule.CleanupInactiveSessions;
var
  LInactiveSessions: TList<string>;
  LPair: TPair<string, TUniSession>;
  LNow: TDateTime;
  LSession: TUniSession;
  LSessionInfo: TSessionInfo;
  LTimeoutMinutes: Integer;
  LSessionID: string;
begin
  LInactiveSessions := TList<string>.Create;
  LNow := Now;
  LTimeoutMinutes := GetSessionTimeoutMinutes;

  // 第一阶段：收集不活动会话ID
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
  finally
    FSessionLock.Release;
  end;

  // 第二阶段：释放锁后，逐个清理不活动会话
  for LSessionID in LInactiveSessions do
  begin
    WriteLn(Format('Cleaning up inactive session: %s', [LSessionID]));
    RemoveSession(LSessionID);
  end;

  LInactiveSessions.Free;
end;

function TMainModule.GetSessionTimeoutMinutes: Integer;
begin
  // 从配置读取超时时间，默认30分钟
  Result := FConfigService.GetGlobalInteger('server.sessionTimeout', 1800) div 60;
  if Result < 1 then
    Result := 30;
end;

end.

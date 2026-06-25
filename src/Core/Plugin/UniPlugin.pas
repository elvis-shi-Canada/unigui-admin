unit UniPlugin;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.SyncObjs,
  UniContext, UniPlugin.Intf, UniPlugin.Types, uniGUIForm;

type
  /// <summary>
  /// 插件系统专用异常基类
  /// 用于标识插件生命周期中的错误情况
  /// </summary>
  EPluginException = class(Exception)
  public
    constructor Create(const Msg: string); overload;
    constructor CreateFmt(const Msg: string; const Args: array of const); overload;
  end;

  /// <summary>
  /// 插件状态错误异常
  /// 当操作与当前插件状态不兼容时抛出
  /// </summary>
  EPluginStateError = class(EPluginException)
  public
    constructor Create(const CurrentState, ExpectedState, Operation: string);
  end;

  /// <summary>
  /// 插件类引用类型
  /// </summary>
  TPluginClass = class of TPlugin;

  TPlugin = class(TInterfacedObject, IPlugin)
  private
    FInfo: TPluginInfo;
    FState: TPluginState;
    FUserContext: IUserContext;
    FExecutionContext: IExecutionContext;
    FForms: TList<TFormInfo>;
    FDataModules: TList<TDataModuleInfo>;
    FDataModuleInstances: TDictionary<string, TDataModule>;
    FLock: TCriticalSection;  // 线程安全锁

    function GetStateName(State: TPluginState): string;
    procedure RegisterForm(const FormInfo: TFormInfo);
    procedure RegisterDataModule(const DataModuleInfo: TDataModuleInfo);
  protected
    procedure DoInitialize; virtual;
    procedure DoActivate; virtual;
    procedure DoDeactivate; virtual;
    procedure DoCleanup; virtual;
    procedure RegisterPermissions; virtual;
    procedure RegisterMenus; virtual;
  public
    constructor Create(const Info: TPluginInfo; const UserContext: IUserContext;
      const ExecutionContext: IExecutionContext); virtual;
    destructor Destroy; override;

    procedure Initialize;
    procedure Activate;
    procedure Deactivate;

    function GetInfo: TPluginInfo;
    function GetState: TPluginState;
    function HasPermission(const Permission: string): Boolean;

    /// <summary>
    /// 根据表单名称获取已注册的表单信息
    /// </summary>
    /// <param name="FormName">要查找的表单名称</param>
    /// <returns>匹配的表单信息记录</returns>
    /// <exception cref="EPluginException">当表单未找到时抛出</exception>
    function GetForm(const FormName: string): TFormInfo;

    /// <summary>
    /// 创建表单实例并返回
    /// 此方法根据已注册的表单信息动态创建表单实例
    /// 调用者负责释放返回的表单实例
    /// </summary>
    /// <param name="FormName">要创建的表单名称</param>
    /// <param name="AOwner">表单的所有者组件，通常为 Application 或 nil</param>
    /// <returns>新创建的表单实例</returns>
    /// <exception cref="EPluginException">当表单未注册或创建失败时抛出</exception>
    /// <remarks>
    /// 线程安全：此方法使用临界区保护，可从多线程调用
    /// 内存管理：调用者必须负责释放返回的表单实例 (AOwner=nil 时)
    /// </remarks>
    function CreateForm(const FormName: string; AOwner: TComponent): TUniForm;

    /// <summary>
    /// 获取或创建 DataModule 实例（单例模式）
    /// 首次调用时创建实例并缓存，后续调用返回缓存的实例
    /// </summary>
    /// <param name="DataModuleName">要获取的 DataModule 名称</param>
    /// <returns>DataModule 实例</returns>
    /// <exception cref="EPluginException">当 DataModule 未注册时抛出</exception>
    /// <remarks>
    /// 线程安全：此方法使用临界区保护，确保实例创建的原子性
    /// 生命周期：实例在插件销毁时自动释放
    /// </remarks>
    function GetDataModule(const DataModuleName: string): TDataModule;

    /// <summary>
    /// 创建新的 DataModule 实例（非单例）
    /// 每次调用都创建新的实例，不进行缓存
    /// </summary>
    /// <param name="DataModuleName">要创建的 DataModule 名称</param>
    /// <returns>新创建的 DataModule 实例</returns>
    /// <exception cref="EPluginException">当 DataModule 未注册时抛出</exception>
    /// <remarks>
    /// 线程安全：此方法使用临界区保护
    /// 内存管理：调用者负责释放返回的实例
    /// </remarks>
    function CreateDataModuleWithContext(const DataModuleName: string): TDataModule;

    property UserContext: IUserContext read FUserContext;
    function GetCurrentUserID: Integer;
    property CurrentUserID: Integer read GetCurrentUserID;
  end;

implementation

constructor TPlugin.Create(const Info: TPluginInfo; const UserContext: IUserContext;
  const ExecutionContext: IExecutionContext);
begin
  inherited Create;
  FInfo := Info;
  FUserContext := UserContext;
  FExecutionContext := ExecutionContext;
  FState := psUninitialized;
  FForms := TList<TFormInfo>.Create;
  FDataModules := TList<TDataModuleInfo>.Create;
  FDataModuleInstances := TDictionary<string, TDataModule>.Create;
  FLock := TCriticalSection.Create;
end;

function TPlugin.GetStateName(State: TPluginState): string;
begin
  case State of
    psUninitialized: Result := 'psUninitialized';
    psInitializing: Result := 'psInitializing';
    psInitialized: Result := 'psInitialized';
    psActivated: Result := 'psActivated';
    psDeactivated: Result := 'psDeactivated';
    psError: Result := 'psError';
  else
    Result := 'Unknown';
  end;
end;

destructor TPlugin.Destroy;
begin
  DoCleanup;
  FForms.Free;
  FDataModules.Free;
  FDataModuleInstances.Free;
  FLock.Free;
  inherited;
end;

procedure TPlugin.Initialize;
begin
  FState := psInitializing;
  try
    DoInitialize;
    RegisterPermissions;
    RegisterMenus;
    FState := psInitialized;
  except
    FState := psError;
    raise;
  end;
end;

procedure TPlugin.Activate;
begin
  if FState <> psInitialized then
    raise EPluginStateError.Create(GetStateName(FState), 'psInitialized', 'Activate');
  FState := psActivated;
  DoActivate;
end;

procedure TPlugin.Deactivate;
begin
  if FState <> psActivated then
    raise EPluginStateError.Create(GetStateName(FState), 'psActivated', 'Deactivate');
  FState := psDeactivated;
  DoDeactivate;
end;

procedure TPlugin.DoInitialize;
begin
  // ��������?2??
end;

procedure TPlugin.DoActivate;
begin
  // ��������?2??
end;

procedure TPlugin.DoDeactivate;
begin
  // ��������?2??
end;

procedure TPlugin.DoCleanup;
begin
  // ??���� DataModule ���̨�y
  var LPair: TPair<string, TDataModule>;
  for LPair in FDataModuleInstances do
    LPair.Value.Free;
  FDataModuleInstances.Clear;
end;

procedure TPlugin.RegisterPermissions;
begin
  // ��������?2?? - ����2������?T��??�̨�3
end;

procedure TPlugin.RegisterMenus;
begin
  // ��������?2?? - ����2��2?�̣���??�̨�3
end;

procedure TPlugin.RegisterForm(const FormInfo: TFormInfo);
begin
  FForms.Add(FormInfo);
end;

procedure TPlugin.RegisterDataModule(const DataModuleInfo: TDataModuleInfo);
begin
  FDataModules.Add(DataModuleInfo);
end;

function TPlugin.GetInfo: TPluginInfo;
begin
  Result := FInfo;
end;

function TPlugin.GetState: TPluginState;
begin
  Result := FState;
end;

function TPlugin.HasPermission(const Permission: string): Boolean;
begin
  if Assigned(FUserContext) then
    Result := FUserContext.HasPermission(Permission)
  else
    Result := False;
end;

function TPlugin.GetCurrentUserID: Integer;
begin
  if Assigned(FExecutionContext) then
    Result := FExecutionContext.GetCurrentUserID
  else
    Result := 0;
end;

function TPlugin.GetForm(const FormName: string): TFormInfo;
begin
  FLock.Enter;
  try
    for var LInfo in FForms do
      if LInfo.FormName = FormName then
        Exit(LInfo);
    raise EPluginException.CreateFmt('Form %s not found in plugin %s', [FormName, FInfo.Name]);
  finally
    FLock.Leave;
  end;
end;

function TPlugin.CreateForm(const FormName: string; AOwner: TComponent): TUniForm;
begin
  FLock.Enter;
  try
    // 查找表单信息
    var LInfo: TFormInfo;
    var LFound: Boolean;
    for var LFormInfo in FForms do
    begin
      if LFormInfo.FormName = FormName then
      begin
        LInfo := LFormInfo;
        LFound := True;
        Break;
      end;
    end;

    if not LFound then
      raise EPluginException.CreateFmt('Form %s not found in plugin %s', [FormName, FInfo.Name]);

    // 在锁保护下创建表单实例
    Result := LInfo.FormClass.Create(AOwner) as TUniForm;
  finally
    FLock.Leave;
  end;
end;

function TPlugin.GetDataModule(const DataModuleName: string): TDataModule;
begin
  FLock.Enter;
  try
    if not FDataModuleInstances.TryGetValue(DataModuleName, Result) then
    begin
      Result := CreateDataModuleWithContext(DataModuleName);
      FDataModuleInstances.Add(DataModuleName, Result);
    end;
  finally
    FLock.Leave;
  end;
end;

function TPlugin.CreateDataModuleWithContext(const DataModuleName: string): TDataModule;
begin
  FLock.Enter;
  try
    for var LInfo in FDataModules do
      if LInfo.DataModuleName = DataModuleName then
      begin
        Result := LInfo.DataModuleClass.Create(nil);
        // TODO: 如果 DataModule 支持上下文注入，在此调用 SetContext
        // if Supports(Result, IContextAware) then
        //   (Result as IContextAware).SetContext(FExecutionContext);
        Exit;
      end;
    raise EPluginException.CreateFmt('DataModule %s not found in plugin %s', [DataModuleName, FInfo.Name]);
  finally
    FLock.Leave;
  end;
end;

{ EPluginException }

constructor EPluginException.Create(const Msg: string);
begin
  inherited Create(Msg);
end;

constructor EPluginException.CreateFmt(const Msg: string; const Args: array of const);
begin
  inherited CreateFmt(Msg, Args);
end;

{ EPluginStateError }

constructor EPluginStateError.Create(const CurrentState, ExpectedState, Operation: string);
begin
  inherited CreateFmt(
    'Cannot %s plugin. Current state: %s, Expected state: %s',
    [Operation, CurrentState, ExpectedState]
  );
end;

end.
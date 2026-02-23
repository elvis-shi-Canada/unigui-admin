unit UniPlugin;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  UniContext, UniPlugin.Intf;

type
  TPlugin = class(TInterfacedObject, IPlugin)
  private
    FInfo: TPluginInfo;
    FState: TPluginState;
    FUserContext: IUserContext;
    FExecutionContext: IExecutionContext;
    FForms: TList<TFormInfo>;
    FDataModules: TList<TDataModuleInfo>;
    FDataModuleInstances: TDictionary<string, TDataModule>;

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

    // ¡ä¡ã¨¬?1¨¹¨¤¨ª
    function GetForm(const FormName: string): TFormInfo;
    function CreateForm(const FormName: string; AOwner: TComponent): TUniForm;

    // DataModule 1¨¹¨¤¨ª
    function GetDataModule(const DataModuleName: string): TDataModule;
    function CreateDataModuleWithContext(const DataModuleName: string): TDataModule;

    property UserContext: IUserContext read FUserContext;
    property CurrentUserID: Integer read FExecutionContext.GetCurrentUserID;
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
end;

destructor TPlugin.Destroy;
begin
  DoCleanup;
  FForms.Free;
  FDataModules.Free;
  FDataModuleInstances.Free;
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
    raise Exception.Create('Plugin must be initialized before activation');
  FState := psActivated;
  DoActivate;
end;

procedure TPlugin.Deactivate;
begin
  if FState <> psActivated then
    raise Exception.Create('Plugin is not activated');
  FState := psDeactivated;
  DoDeactivate;
end;

procedure TPlugin.DoInitialize;
begin
  // ¡Á¨®¨¤¨¤?2??
end;

procedure TPlugin.DoActivate;
begin
  // ¡Á¨®¨¤¨¤?2??
end;

procedure TPlugin.DoDeactivate;
begin
  // ¡Á¨®¨¤¨¤?2??
end;

procedure TPlugin.DoCleanup;
begin
  // ??¨¤¨ª DataModule ¨º¦Ì¨¤y
  var LPair: TPair<string, TDataModule>;
  for LPair in FDataModuleInstances do
    LPair.Value.Free;
  FDataModuleInstances.Clear;
end;

procedure TPlugin.RegisterPermissions;
begin
  // ¡Á¨®¨¤¨¤?2?? - ¡Á¡é2¨¢¨¨¡§?T¦Ì??¦Ì¨ª3
end;

procedure TPlugin.RegisterMenus;
begin
  // ¡Á¨®¨¤¨¤?2?? - ¡Á¡é2¨¢2?¦Ì£¤¦Ì??¦Ì¨ª3
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

function TPlugin.GetForm(const FormName: string): TFormInfo;
begin
  for var LInfo in FForms do
    if LInfo.FormName = FormName then
      Exit(LInfo);
  raise Exception.CreateFmt('Form %s not found in plugin %s', [FormName, FInfo.Name]);
end;

function TPlugin.CreateForm(const FormName: string; AOwner: TComponent): TUniForm;
begin
  var LInfo := GetForm(FormName);
  Result := LInfo.FormClass.Create(AOwner) as TUniForm;
end;

function TPlugin.GetDataModule(const DataModuleName: string): TDataModule;
begin
  if not FDataModuleInstances.TryGetValue(DataModuleName, Result) then
  begin
    Result := CreateDataModuleWithContext(DataModuleName);
    FDataModuleInstances.Add(DataModuleName, Result);
  end;
end;

function TPlugin.CreateDataModuleWithContext(const DataModuleName: string): TDataModule;
begin
  for var LInfo in FDataModules do
    if LInfo.DataModuleName = DataModuleName then
    begin
      Result := LInfo.DataModuleClass.Create(nil);
      // ¨¨?1? DataModule ?¡ì3? SetContext¡ê?¡Á¡é¨¨?¨¦?????
      // if Supports(Result, IContextAware) then
      //   (Result as IContextAware).SetContext(FExecutionContext);
      Exit;
    end;
  raise Exception.CreateFmt('DataModule %s not found in plugin %s', [DataModuleName, FInfo.Name]);
end;

end.
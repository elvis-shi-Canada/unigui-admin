unit UniAdminMdiRouter;

interface

uses
  System.SysUtils, System.Classes,
  uniGUIApplication, uniGUIForm, uniPanel, uniGUIBaseClasses, uniGUIFrame,
  uniGUIClasses, uniPageControl, Vcl.Controls,
  UniContext, UniAdminMdiRouter.Intf;

type
  /// <summary>
  /// MDI router implementation (multi-tab mode). Owned by TMainFrame and
  /// bound to a host TUniPageControl. Each routed frame becomes a closable
  /// TUniTabSheet; reopening a class activates its existing tab instead of
  /// recreating it, so filters/scroll/paging state survive.
  ///
  /// Design lineage: FSThemeCrystal's pgcControl + FS.Abas.TAbas pattern,
  /// adapted to UniAdmin's RoutePath-stores-class-name convention.
  /// </summary>
  TUniAdminMdiRouter = class(TInterfacedObject, IMdiRouter)
  private
    FHost: TUniPageControl;

    /// <summary>Resolve a registered class name to a frame metaclass.</summary>
    function FindFrameClass(const AClassName: string): TUniFrameClass;
    /// <summary>Resolve a registered class name to a form metaclass.</summary>
    function FindFormClass(const AClassName: string): TUniFormClass;
    /// <summary>Find an existing tab whose Name equals the class name.</summary>
    function FindTab(const AClassName: string): TUniTabSheet;
    /// <summary>Create-or-activate a tab hosting the frame.</summary>
    procedure ShowFrame(const AClassName, ACaption: string;
      const AContext: IExecutionContext);
    /// <summary>Create and show a modal form (not tabbed).</summary>
    procedure ShowModalForm(const AClassName: string);
    /// <summary>OnClose handler: always allow, tab frees its child frame.</summary>
    procedure OnTabClose(Sender: TObject; var AllowClose: Boolean);
  public
    constructor Create(AHost: TUniPageControl);

    procedure Open(const AClassName: string; const ACaption: string = '';
      AOpenMode: TMdiOpenMode = omEmbed; const AContext: IExecutionContext = nil);
    function CanRoute(const AClassName: string): Boolean;
    procedure Close(const AClassName: string);
    procedure CloseAll;
  end;

implementation

{ TUniAdminMdiRouter }

constructor TUniAdminMdiRouter.Create(AHost: TUniPageControl);
begin
  inherited Create;
  if not Assigned(AHost) then
    raise Exception.Create('MdiRouter host page control cannot be nil');
  FHost := AHost;
end;

function TUniAdminMdiRouter.FindFrameClass(const AClassName: string): TUniFrameClass;
var
  LClass: TPersistentClass;
begin
  Result := nil;
  LClass := GetClass(AClassName);
  if (LClass <> nil) and LClass.InheritsFrom(TUniFrame) then
    Result := TUniFrameClass(LClass);
end;

function TUniAdminMdiRouter.FindFormClass(const AClassName: string): TUniFormClass;
var
  LClass: TPersistentClass;
begin
  Result := nil;
  LClass := GetClass(AClassName);
  if (LClass <> nil) and LClass.InheritsFrom(TUniForm) then
    Result := TUniFormClass(LClass);
end;

function TUniAdminMdiRouter.CanRoute(const AClassName: string): Boolean;
begin
  Result := (AClassName <> '') and
            ((FindFrameClass(AClassName) <> nil) or (FindFormClass(AClassName) <> nil));
end;

function TUniAdminMdiRouter.FindTab(const AClassName: string): TUniTabSheet;
var
  I: Integer;
begin
  Result := nil;
  // The tab's Name holds the class name as a stable identity key, while
  // Caption carries the user-facing title.
  for I := 0 to FHost.PageCount - 1 do
    if SameText(FHost.Pages[I].Name, AClassName) then
      Exit(FHost.Pages[I]);
end;

procedure TUniAdminMdiRouter.ShowFrame(const AClassName, ACaption: string;
  const AContext: IExecutionContext);
var
  LTab: TUniTabSheet;
  LFrame: TUniFrame;
  LFrameClass: TUniFrameClass;
  LDisplayCaption: string;
  LInit: IMdiInitializable;
begin
  // 1. Cache hit: activate existing tab, preserving full frame state.
  // 已初始化过的 Frame 不重复注入 Context / 调 Initialize。
  LTab := FindTab(AClassName);
  if LTab <> nil then
  begin
    FHost.ActivePage := LTab;
    Exit;
  end;

  // 2. Cache miss: resolve, create tab + frame
  LFrameClass := FindFrameClass(AClassName);
  if LFrameClass = nil then
    raise Exception.CreateFmt(
      'Frame class "%s" is not registered. Add RegisterClass(%s) in the unit''s initialization section.',
      [AClassName, AClassName]);

  if ACaption <> '' then
    LDisplayCaption := ACaption
  else
    LDisplayCaption := AClassName;

  LTab := TUniTabSheet.Create(FHost);
  LTab.Name := AClassName;          // identity key for FindTab
  LTab.PageControl := FHost;
  LTab.Caption := LDisplayCaption;  // user-facing title
  LTab.Closable := True;
  LTab.OnClose := OnTabClose;

  // Frame is parented to the tab, so it is freed when the tab is closed.
  LFrame := LFrameClass.Create(LTab);
  LFrame.Parent := LTab;
  LFrame.Align := alClient;

  // 3. 注入会话上下文并触发初始化（仅新建分支）。
  // 若 Frame 实现 IMdiInitializable（如 TBaseCrudFrame），Router 负责把
  // 当前会话 Context 注入并调 Initialize，否则 FContext=nil、DoInitialize
  // 不执行，下游 DoAdd 等钩子因 Context 缺失触发 AV 被静默吞掉。
  if Supports(LFrame, IMdiInitializable, LInit) then
  begin
    LInit.SetContext(AContext);
    LInit.Initialize;
  end;

  FHost.ActivePage := LTab;
end;

procedure TUniAdminMdiRouter.ShowModalForm(const AClassName: string);
var
  LFormClass: TUniFormClass;
  LForm: TUniForm;
begin
  LFormClass := FindFormClass(AClassName);
  if LFormClass = nil then
    raise Exception.CreateFmt(
      'Form class "%s" is not registered. Add RegisterClass(%s) in the unit''s initialization section.',
      [AClassName, AClassName]);

  // Modal forms are short-lived and unaffected by the tab cache.
  LForm := LFormClass.Create(FHost);
  try
    LForm.ShowModal;
  finally
    LForm.Free;
  end;
end;

procedure TUniAdminMdiRouter.OnTabClose(Sender: TObject; var AllowClose: Boolean);
begin
  // Permit the close; the owning TUniTabSheet frees itself and, because the
  // hosted frame is parented to it, the frame is released as well.
  AllowClose := True;
end;

procedure TUniAdminMdiRouter.Open(const AClassName: string; const ACaption: string;
  AOpenMode: TMdiOpenMode; const AContext: IExecutionContext);
begin
  if AClassName = '' then
    Exit;

  case AOpenMode of
    omEmbed: ShowFrame(AClassName, ACaption, AContext);
    omModal: ShowModalForm(AClassName);
  end;
end;

procedure TUniAdminMdiRouter.Close(const AClassName: string);
var
  LTab: TUniTabSheet;
begin
  LTab := FindTab(AClassName);
  if LTab <> nil then
    LTab.Free;   // detaches from PageControl and frees the child frame
end;

procedure TUniAdminMdiRouter.CloseAll;
var
  I: Integer;
begin
  // Iterate backwards: freeing a page mutates the Pages collection.
  for I := FHost.PageCount - 1 downto 0 do
    if FHost.Pages[I].Closable then
      FHost.Pages[I].Free;
end;

end.

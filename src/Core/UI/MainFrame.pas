unit MainFrame;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Generics.Collections, System.UITypes,
  System.StrUtils,
  uniGUIApplication, uniGUIForm, uniLabel, uniButton,
  uniPanel, uniGUIBaseClasses, uniGUIFrame, uniGUIClasses, uniPageControl, Vcl.Menus,
  uniMainMenu, uniStatusBar,
  UniContext, UniAdminMenuManager.Intf, UniAdminMdiRouter.Intf, Vcl.Controls, Vcl.Forms;

type
  /// <summary>
  /// 主窗体框架 - 应用程序主窗口外壳
  /// 提供菜单栏、多标签内容区域（TUniPageControl）和状态栏
  /// 集成会话管理和数据驱动的 MDI 路由
  /// </summary>
  TMainFrame = class(TUniForm)
    UniMainMenu: TUniMainMenu;
    UniContainerPanel: TUniContainerPanel;
    pgcContent: TUniPageControl;
    UniStatusBar: TUniStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    FContext: IExecutionContext;
    FMenuManager: IUniAdminMenuManager;
    FMenuItems: TDictionary<string, TUniMenuItem>;
    FContentFrame: TComponent;
    FMdiRouter: IMdiRouter;

    procedure InitializeComponents;
    procedure InitializeMenus;
    procedure LoadUserMenus;
    procedure CreateDefaultMenus;
    procedure UpdateStatusBar(const AStatusText: string = '');
    procedure OnMenuClick(Sender: TObject);
    function CreateMenuItem(const MenuData: TMenuItem): TUniMenuItem;
    procedure SetContext(const Value: IExecutionContext);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    /// <summary>
    /// 设置执行上下文
    /// </summary>
    procedure SetExecutionContext(const Context: IExecutionContext);

    /// <summary>
    /// 在内容区域显示指定窗体
    /// </summary>
    procedure ShowContent(AForm: TUniForm); overload;

    /// <summary>
    /// 在内容区域显示指定框架
    /// </summary>
    procedure ShowContent(AFrame: TUniFrame); overload;

    /// <summary>
    /// 刷新菜单
    /// </summary>
    procedure RefreshMenus;

    /// <summary>
    /// 刷新状态栏
    /// </summary>
    procedure RefreshStatusBar;

    /// <summary>MDI 路由器（数据驱动菜单路由 + 多标签缓存）</summary>
    property MdiRouter: IMdiRouter read FMdiRouter;

    property Context: IExecutionContext read FContext;
  end;

implementation

{$R *.dfm}

uses
  UniAdminServices, uniGUIVars, UniAdminFormStyler, LoginForm, UniAdminAuthService.Intf,
  UniAdminMdiRouter, MainModule;

{ TMainFrame }

constructor TMainFrame.Create(AOwner: TComponent);
begin
  inherited;
  FMenuItems := TDictionary<string, TUniMenuItem>.Create;
end;

destructor TMainFrame.Destroy;
begin
  // Release router first: it clears the cached tabs while the host page
  // control (pgcContent) is still alive, avoiding dangling references.
  FMdiRouter := nil;
  FMenuItems.Free;
  inherited;
end;

procedure TMainFrame.FormCreate(Sender: TObject);
begin
  // 设置窗体属性
  Caption := 'UniAdmin 管理系统';

  // 应用统一设计系统样式
  TUniAdminFormStyler.AutoStylePanels(Self);

  InitializeComponents;

  // MDI router: binds to the content page control. Each routed frame opens
  // as a closable tab; reopening a class activates its existing tab.
  // New modules are routed purely by UniAdmin_Menus.RoutePath (class name).
  FMdiRouter := TUniAdminMdiRouter.Create(pgcContent);
end;

procedure TMainFrame.FormShow(Sender: TObject);
begin
  // 从 MainModule（每会话）取登录时构造好的执行上下文（含真实权限）。
  // 登录态不再经 LoginForm 的 class var 传递，避免多会话并发覆盖。
  if GetMainModule.Context <> nil then
    SetExecutionContext(GetMainModule.Context);

  InitializeMenus;
  UpdateStatusBar;
end;

procedure TMainFrame.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // 清理资源
  if Assigned(FContentFrame) then
    FContentFrame.Free;
end;

procedure TMainFrame.InitializeComponents;
begin
  // 组件已在 DFM 中创建，无需运行时创建
  // UniGUI 组件通过 DFM 自动初始化
end;

procedure TMainFrame.InitializeMenus;
begin
  try
    FMenuManager := GetMainModule.Services.MenuManager;
    LoadUserMenus;
  except
    on E: Exception do
    begin
      // 如果菜单管理器不可用，创建默认菜单
      CreateDefaultMenus;
    end;
  end;
end;

procedure TMainFrame.LoadUserMenus;
var
  LMenus: TArray<UniAdminMenuManager.Intf.TMenuItem>;
  LMenu: UniAdminMenuManager.Intf.TMenuItem;
  LMenuItem: TUniMenuItem;
  LParentItem: TUniMenuItem;
begin
  if not Assigned(FMenuManager) or not Assigned(Context) then
    Exit;

  // 清除现有菜单项
  UniMainMenu.Items.Clear;
  FMenuItems.Clear;

  // 获取用户菜单
  LMenus := FMenuManager.GetUserMenus(Context.GetUserContext.GetUserID);

  // 构建菜单树
  for LMenu in LMenus do
  begin
    if LMenu.ParentID = 0 then
    begin
      // 顶级菜单
      LMenuItem := CreateMenuItem(LMenu);
      UniMainMenu.Items.Add(LMenuItem);
      FMenuItems.Add(IntToStr(LMenu.MenuID), LMenuItem);
    end;
  end;

  // 添加子菜单
  for LMenu in LMenus do
  begin
    if (LMenu.ParentID > 0) and FMenuItems.TryGetValue(IntToStr(LMenu.ParentID), LParentItem) then
    begin
      LMenuItem := CreateMenuItem(LMenu);
      LParentItem.Add(LMenuItem);
      FMenuItems.Add(IntToStr(LMenu.MenuID), LMenuItem);
    end;
  end;
end;

function TMainFrame.CreateMenuItem(const MenuData: UniAdminMenuManager.Intf.TMenuItem): TUniMenuItem;
begin
  Result := TUniMenuItem.Create(Self);
  Result.Caption := MenuData.MenuName;
  Result.Hint := MenuData.MenuCode;  // 使用 MenuCode 作为提示
  Result.Tag := MenuData.MenuID;
  Result.Visible := MenuData.IsVisible;
  Result.Enabled := True;  // 默认启用

  // Leaf nodes with a routable target (RoutePath = class name) handle clicks;
  // pure category nodes (RoutePath empty) have no OnClick.
  if MenuData.RoutePath <> '' then
    Result.OnClick := OnMenuClick;
end;

procedure TMainFrame.OnMenuClick(Sender: TObject);
var
  LMenuItem: TUniMenuItem;
  LMenuID: Integer;
  LMenuData: UniAdminMenuManager.Intf.TMenuItem;
begin
  if not (Sender is TUniMenuItem) then
    Exit;

  LMenuItem := TUniMenuItem(Sender);
  LMenuID := LMenuItem.Tag;

  UpdateStatusBar('正在加载: ' + LMenuItem.Caption);

  // Data-driven routing: RoutePath stores the target Frame/Form class name.
  // Adding a new module needs ZERO changes here — just RegisterClass the frame
  // unit and set its RoutePath in UniAdmin_Menus.
  // (See docs/plans/2026-06-26-mdi-architecture-design.md)
  if not Assigned(FMenuManager) then
    Exit;

  LMenuData := FMenuManager.GetMenuByID(LMenuID);

  if LMenuData.RoutePath = '' then
    Exit;  // pure category node, nothing to route

  if FMdiRouter.CanRoute(LMenuData.RoutePath) then
  begin
    // Open mode is derived from the class-name suffix: *Form -> modal, else embed.
    // Embedded frames become closable tabs; the menu caption is the tab title.
    if AnsiEndsText('Form', LMenuData.RoutePath) then
      FMdiRouter.Open(LMenuData.RoutePath, '', omModal)
    else
      FMdiRouter.Open(LMenuData.RoutePath, LMenuItem.Caption, omEmbed);
    UpdateStatusBar(LMenuItem.Caption);
  end
  else
    UpdateStatusBar('无法路由: ' + LMenuData.RoutePath + '（Frame 类未注册 RegisterClass）');
end;

procedure TMainFrame.CreateDefaultMenus;
var
  LFileMenu, LHelpMenu: TUniMenuItem;
begin
  // 文件菜单
  LFileMenu := TUniMenuItem.Create(Self);
  LFileMenu.Caption := '文件(&F)';
  UniMainMenu.Items.Add(LFileMenu);

  // 帮助菜单
  LHelpMenu := TUniMenuItem.Create(Self);
  LHelpMenu.Caption := '帮助(&H)';
  UniMainMenu.Items.Add(LHelpMenu);
end;

procedure TMainFrame.ShowContent(AForm: TUniForm);
begin
  if Assigned(FContentFrame) then
    FContentFrame.Free;

  AForm.Show;
  FContentFrame := AForm;
end;

procedure TMainFrame.ShowContent(AFrame: TUniFrame);
begin
  if Assigned(FContentFrame) then
    FContentFrame.Free;

  AFrame.Parent := UniContainerPanel;
  // AFrame.Align := alClient;  // UniGUI 使用 CSS 布局
  AFrame.Show;

  FContentFrame := AFrame;
end;

procedure TMainFrame.SetContext(const Value: IExecutionContext);
begin
  FContext := Value;
  RefreshMenus;
  UpdateStatusBar;
end;

procedure TMainFrame.SetExecutionContext(const Context: IExecutionContext);
begin
  SetContext(Context);
end;

procedure TMainFrame.RefreshMenus;
begin
  InitializeMenus;
end;

procedure TMainFrame.UpdateStatusBar(const AStatusText: string);
var
  LStatusText: string;
begin
  if AStatusText <> '' then
    LStatusText := AStatusText
  else
    LStatusText := '就绪';

  if Assigned(Context) then
  begin
    LStatusText := Format('用户: %s | 会话: %s | %s',
      [Context.GetUserContext.GetRealName,
       Context.GetUserContext.GetSessionID,
       LStatusText]);
  end;

  UniStatusBar.SimpleText := LStatusText;
end;

procedure TMainFrame.RefreshStatusBar;
begin
  UpdateStatusBar;
end;

initialization
  // 注册为主窗体：TMainFrame 继承 TUniForm，IsLoginForm=False，归入 FMainFormClass
  RegisterAppFormClass(TMainFrame);
end.

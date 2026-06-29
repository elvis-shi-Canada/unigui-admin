unit MainFrame;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Generics.Collections, System.UITypes,
  System.StrUtils,
  uniGUIApplication, uniGUIForm, uniLabel, uniButton,
  uniPanel, uniGUIBaseClasses, uniGUIAbstractClasses, uniGUIFrame, uniGUIClasses, uniPageControl,
  uniTreeMenu, uniTreeView, Vcl.Menus, uniMainMenu, uniStatusBar,
  UniContext, UniAdminMenuManager.Intf, UniAdminMdiRouter.Intf, Vcl.Controls, Vcl.Forms;

type
  /// <summary>
  /// 主窗体框架 - FSThemeCrystal 风格主界面（纯 uniGUI 原生控件，无 UniFalcon）
  /// 布局：顶部工具栏 + 侧边树形菜单(TUniTreeMenu) + 多标签内容区 + 状态栏
  /// 菜单数据驱动：trmMenu 树节点由 UniAdmin_Menus 动态构建，Node.Data 存 MenuID，
  /// 点击节点走 MdiRouter 数据驱动路由。
  /// </summary>
  TMainFrame = class(TUniForm)
    pnlTopBar: TUniPanel;
    btnToggleMenu: TUniButton;
    lblAppTitle: TUniLabel;
    lblCurrentUser: TUniLabel;
    btnLogout: TUniButton;
    pnlSidebar: TUniPanel;
    trmMenu: TUniTreeMenu;
    pgcContent: TUniPageControl;
    UniStatusBar: TUniStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure btnToggleMenuClick(Sender: TObject);
    procedure btnLogoutClick(Sender: TObject);
    procedure trmMenuSelectionChange(Sender: TObject);
  private
    FContext: IExecutionContext;
    FMenuManager: IUniAdminMenuManager;
    FMenuItems: TDictionary<string, TUniTreeNode>;
    FContentFrame: TComponent;
    FMdiRouter: IMdiRouter;

    procedure InitializeComponents;
    procedure InitializeMenus;
    procedure LoadUserMenus;
    procedure CreateDefaultMenus;
    procedure UpdateStatusBar(const AStatusText: string = '');
    procedure SetContext(const Value: IExecutionContext);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    /// <summary>设置执行上下文</summary>
    procedure SetExecutionContext(const Context: IExecutionContext);

    /// <summary>在内容区域显示指定窗体</summary>
    procedure ShowContent(AForm: TUniForm); overload;

    /// <summary>在内容区域显示指定框架</summary>
    procedure ShowContent(AFrame: TUniFrame); overload;

    /// <summary>刷新菜单</summary>
    procedure RefreshMenus;

    /// <summary>刷新状态栏</summary>
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
  FMenuItems := TDictionary<string, TUniTreeNode>.Create;
end;

destructor TMainFrame.Destroy;
begin
  // Release router first: clears cached tabs while the host page control is alive.
  FMdiRouter := nil;
  FMenuItems.Free;
  inherited;
end;

procedure TMainFrame.FormCreate(Sender: TObject);
begin
  Caption := 'UniAdmin 管理系统';

  // 应用统一设计系统样式
  TUniAdminFormStyler.AutoStylePanels(Self);

  InitializeComponents;

  // MDI router: binds to the content page control. Each routed frame opens
  // as a closable tab; reopening a class activates its existing tab.
  FMdiRouter := TUniAdminMdiRouter.Create(pgcContent);
end;

procedure TMainFrame.FormShow(Sender: TObject);
begin
  // 从 MainModule（每会话）取登录时构造好的执行上下文（含真实权限）。
  if GetMainModule.Context <> nil then
    SetExecutionContext(GetMainModule.Context);

  InitializeMenus;
  UpdateStatusBar;
end;

procedure TMainFrame.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(FContentFrame) then
    FContentFrame.Free;
end;

procedure TMainFrame.InitializeComponents;
begin
  // 组件已在 DFM 中创建，无需运行时创建
end;

procedure TMainFrame.InitializeMenus;
begin
  try
    FMenuManager := GetMainModule.Services.MenuManager;
    LoadUserMenus;
  except
    on E: Exception do
      CreateDefaultMenus;
  end;
end;

procedure TMainFrame.LoadUserMenus;
var
  LMenus: TArray<UniAdminMenuManager.Intf.TMenuItem>;
  LMenu: UniAdminMenuManager.Intf.TMenuItem;
  LNode, LParentNode: TUniTreeNode;
  LAdded: Boolean;
  LPasses: Integer;
begin
  if not Assigned(FMenuManager) or not Assigned(Context) then
    Exit;

  // TUniTreeMenu 用 TUniTreeNodes 构建（非 TUniMenuItems），Node.Data 存 MenuID
  trmMenu.Items.Clear;
  FMenuItems.Clear;

  LMenus := FMenuManager.GetUserMenus(Context.GetUserContext.GetUserID);

  // 多遍构建：确保父节点先于子节点创建（支持任意层级）
  // Node.Data 存 MenuID（NativeInt → Pointer）。注意：MenuID=0 时 Data=nil，
  // trmMenuClick 的 nil 守卫会跳过该节点——根菜单不应有 MenuID=0 的叶子节点。
  LPasses := 0;
  repeat
    LAdded := False;
    for LMenu in LMenus do
    begin
      if FMenuItems.ContainsKey(IntToStr(LMenu.MenuID)) then
        Continue;  // 已添加

      if LMenu.ParentID = 0 then
      begin
        LNode := trmMenu.Items.AddChild(nil, LMenu.MenuName);
        LNode.Data := Pointer(NativeInt(LMenu.MenuID));
        FMenuItems.Add(IntToStr(LMenu.MenuID), LNode);
        LAdded := True;
      end
      else if FMenuItems.TryGetValue(IntToStr(LMenu.ParentID), LParentNode) then
      begin
        LNode := trmMenu.Items.AddChild(LParentNode, LMenu.MenuName);
        LNode.Data := Pointer(NativeInt(LMenu.MenuID));
        FMenuItems.Add(IntToStr(LMenu.MenuID), LNode);
        LAdded := True;
      end;
    end;
    Inc(LPasses);
  until (not LAdded) or (LPasses > 16);  // 防死循环，16 层足够

  // 检测孤立菜单（ParentID 指向不存在的父节点）
  for LMenu in LMenus do
    if not FMenuItems.ContainsKey(IntToStr(LMenu.MenuID)) then
      UniSession.Log('WARN: 孤立菜单 [' + LMenu.MenuCode + '] ' + LMenu.MenuName +
        ' (ParentID=' + IntToStr(LMenu.ParentID) + ') 未找到父节点，已跳过');

  // 默认展开顶级节点
  if trmMenu.Items.Count > 0 then
    trmMenu.Items[0].Expand(True);
end;

procedure TMainFrame.trmMenuSelectionChange(Sender: TObject);
var
  LNode: TUniTreeNode;
  LMenuID: Integer;
  LMenuData: UniAdminMenuManager.Intf.TMenuItem;
begin
  // OnSelectionChange 是 TUniTreeMenu 的标准事件（ExtJS selectionchange），
  // 比 OnClick(itemclick) 更可靠——官方 UniTreeMenu demo 即用此事件。
  LNode := trmMenu.Selected;
  if (LNode = nil) or (LNode.Data = nil) then
    Exit;

  // 分类节点（有子菜单）不参与路由：ExpanderOnly=False 时点击文字即可
  // 展开/折叠子节点，由 TUniTreeMenu 内置处理。
  if not LNode.IsLeaf then
    Exit;

  LMenuID := Integer(NativeInt(LNode.Data));
  UpdateStatusBar('正在加载: ' + LNode.Text);

  // Data-driven routing: RoutePath stores the target Frame/Form class name.
  if not Assigned(FMenuManager) then
    Exit;

  LMenuData := FMenuManager.GetMenuByID(LMenuID);

  if LMenuData.RoutePath = '' then
  begin
    // 叶子节点但无路由路径：恢复状态栏，避免"正在加载"卡住
    UpdateStatusBar;
    Exit;
  end;

  if FMdiRouter.CanRoute(LMenuData.RoutePath) then
  begin
    // *Form -> modal; otherwise embedded as a closable tab.
    // 注入当前会话 Context，供新建的 CRUD Frame 初始化（SetContext + Initialize）。
    if AnsiEndsText('Form', LMenuData.RoutePath) then
      FMdiRouter.Open(LMenuData.RoutePath, '', omModal)
    else
      FMdiRouter.Open(LMenuData.RoutePath, LNode.Text, omEmbed, Context);
    UpdateStatusBar(LNode.Text);
  end
  else
    UpdateStatusBar('无法路由: ' + LMenuData.RoutePath + '（Frame 类未注册 RegisterClass）');
end;

procedure TMainFrame.CreateDefaultMenus;
begin
  // 菜单管理器不可用时的兜底菜单
  trmMenu.Items.AddChild(nil, '系统');
  trmMenu.Items.AddChild(nil, '帮助');
end;

procedure TMainFrame.btnToggleMenuClick(Sender: TObject);
begin
  // 折叠/展开侧边菜单（FSThemeCrystal 的 btnMenu 同款交互）
  pnlSidebar.Visible := not pnlSidebar.Visible;
end;

procedure TMainFrame.btnLogoutClick(Sender: TObject);
begin
  // 退出并重启会话（回到登录窗体）
  UniApplication.Restart;
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

  AFrame.Parent := pgcContent;
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
    // 顶部栏显示当前用户名（FSThemeCrystal 的 lblUsuarioConectado 同款）
    lblCurrentUser.Caption := Context.GetUserContext.GetRealName;

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

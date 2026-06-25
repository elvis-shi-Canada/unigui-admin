unit MainFrame;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Generics.Collections, System.UITypes,
  uniGUIApplication, uniGUIForm, uniLabel, uniButton,
  uniPanel, uniGUIBaseClasses, uniGUIFrame, uniGUIClasses, Vcl.Menus, uniMainMenu, uniStatusBar,
  UniContext, UniSession, UniMenuManager.Intf, Vcl.Controls, Vcl.Forms;

type
  /// <summary>
  /// 主窗体框架 - 应用程序主窗口外壳
  /// 提供菜单栏、内容区域和状态栏
  /// 集成会话管理和菜单管理
  /// </summary>
  TMainFrame = class(TUniForm)
    UniMainMenu: TUniMainMenu;
    UniContainerPanel: TUniContainerPanel;
    UniStatusBar: TUniStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    FContext: IExecutionContext;
    FMenuManager: IUniMenuManager;
    FMenuItems: TDictionary<string, TUniMenuItem>;
    FContentFrame: TComponent;

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

    property Context: IExecutionContext read FContext;
  end;

implementation

{$R *.dfm}

uses
  UniServices, uniGUIVars, UniFormStyler, LoginForm, UniAuthService.Intf,
  UserListFrame, RoleListFrame, MenuTreeFrame;

{ TMainFrame }

constructor TMainFrame.Create(AOwner: TComponent);
begin
  inherited;
  FMenuItems := TDictionary<string, TUniMenuItem>.Create;
end;

destructor TMainFrame.Destroy;
begin
  FMenuItems.Free;
  inherited;
end;

procedure TMainFrame.FormCreate(Sender: TObject);
begin
  // 设置窗体属性
  Caption := 'UniAdmin 管理系统';

  // 应用统一设计系统样式
  TUniFormStyler.AutoStylePanels(Self);

  InitializeComponents;
end;

procedure TMainFrame.FormShow(Sender: TObject);
var
  LSessionInfo: TSessionInfo;
  LUserContext: IUserContext;
  LPermissions: TArray<string>;
  LDataScopes: TDictionary<string, string>;
  LLoginResult: TLoginResult;
begin
  // 从登录结果创建执行上下文
  LLoginResult := TLoginForm.LastLoginResult;
  if LLoginResult.Success then
  begin
    LSessionInfo := TSessionInfo.Create(
      uniGUIApplication.UniApplication.UniSession.SessionId,
      LLoginResult.UserID,
      LLoginResult.UserName,
      LLoginResult.RealName,
      ''  // ClientIP 由 UniGUI 管理
    );
    LPermissions := TArray<string>.Create('read', 'write', 'delete');
    LDataScopes := TDictionary<string, string>.Create;
    LDataScopes.Add('default', 'all');
    LUserContext := TUserContextImpl.Create(LSessionInfo, LPermissions, LDataScopes);
    SetExecutionContext(TExecutionContextImpl.Create(LUserContext, nil));
  end;

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
    FMenuManager := TUniServices.MenuManager;
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
  LMenus: TArray<UniMenuManager.Intf.TMenuItem>;
  LMenu: UniMenuManager.Intf.TMenuItem;
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

function TMainFrame.CreateMenuItem(const MenuData: UniMenuManager.Intf.TMenuItem): TUniMenuItem;
begin
  Result := TUniMenuItem.Create(Self);
  Result.Caption := MenuData.MenuName;
  Result.Hint := MenuData.MenuCode;  // 使用 MenuCode 作为提示
  Result.Tag := MenuData.MenuID;
  Result.Visible := MenuData.IsVisible;
  Result.Enabled := True;  // 默认启用

  if MenuData.RoutePath <> '' then
    Result.OnClick := OnMenuClick;
end;

procedure TMainFrame.OnMenuClick(Sender: TObject);
var
  LMenuItem: TUniMenuItem;
  LMenuID: Integer;
  LMenuData: UniMenuManager.Intf.TMenuItem;
  LFrame: TUniFrame;
begin
  if not (Sender is TUniMenuItem) then
    Exit;

  LMenuItem := TUniMenuItem(Sender);
  LMenuID := LMenuItem.Tag;

  UpdateStatusBar('正在加载: ' + LMenuItem.Caption);

  // 根据 MenuCode 路由到对应功能模块
  if Assigned(FMenuManager) then
  begin
    LMenuData := FMenuManager.GetMenuByID(LMenuID);
    LFrame := nil;

    if LMenuData.MenuCode = 'system.user' then
      LFrame := TUserListFrame.Create(Self)
    else if LMenuData.MenuCode = 'system.role' then
      LFrame := TRoleListFrame.Create(Self)
    else if LMenuData.MenuCode = 'system.menu' then
      LFrame := TMenuTreeFrame.Create(Self);

    if LFrame <> nil then
    begin
      ShowContent(LFrame);
      UpdateStatusBar(LMenuItem.Caption);
    end
    else
      UpdateStatusBar('功能开发中: ' + LMenuItem.Caption);
  end;
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

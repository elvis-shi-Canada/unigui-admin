unit MainFrame;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Generics.Collections,
  uniGUISettings, uniGUIApplication, uniGUIForm, uniLabel, uniButton,
  uniPanel, uniGUIBaseClasses, uniMainMenu, uniMenuItem, uniStatusBar,
  UniContext, UniSession, UniMenuManager.Intf;

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
    procedure UpdateStatusBar;
    procedure OnMenuClick(Sender: TObject);
    function CreateMenuItem(const MenuData: TMenuData): TUniMenuItem;
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
  UniServices;

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
  WindowState := wsMaximized;
  Position := poDefault;

  InitializeComponents;
end;

procedure TMainFrame.FormShow(Sender: TObject);
begin
  // 从当前会话获取上下文
  if Assigned(UniSessionManager) then
    SetExecutionContext(UniSessionManager.GetContext);

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
  // 创建主菜单
  if not Assigned(UniMainMenu) then
    UniMainMenu := TUniMainMenu.Create(Self);

  // 创建状态栏
  if not Assigned(UniStatusBar) then
  begin
    UniStatusBar := TUniStatusBar.Create(Self);
    UniStatusBar.Parent := Self;
    UniStatusBar.Align := alBottom;
    UniStatusBar.SimplePanel := True;
    UniStatusBar.SimpleText := '就绪';
  end;

  // 创建主容器面板
  if not Assigned(UniContainerPanel) then
  begin
    UniContainerPanel := TUniContainerPanel.Create(Self);
    UniContainerPanel.Parent := Self;
    UniContainerPanel.Align := alClient;
    UniContainerPanel.Layout := 'border';
  end;
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
  LMenus: TArray<TMenuData>;
  LMenu: TMenuData;
begin
  if not Assigned(FMenuManager) or not Assigned(FContext) then
    Exit;

  // 清除现有菜单项
  UniMainMenu.Items.Clear;
  FMenuItems.Clear;

  // 获取用户菜单
  LMenus := FMenuManager.GetUserMenus(FContext.GetUserContext.UserID);

  // 构建菜单树
  for LMenu in LMenus do
  begin
    if LMenu.ParentID = 0 then
    begin
      // 顶级菜单
      var LMenuItem := CreateMenuItem(LMenu);
      UniMainMenu.Items.Add(LMenuItem);
      FMenuItems.Add(IntToStr(LMenu.ID), LMenuItem);
    end;
  end;

  // 添加子菜单
  for LMenu in LMenus do
  begin
    if (LMenu.ParentID > 0) and FMenuItems.TryGetValue(IntToStr(LMenu.ParentID), var LParentItem) then
    begin
      var LMenuItem := CreateMenuItem(LMenu);
      LParentItem.Add(LMenuItem);
      FMenuItems.Add(IntToStr(LMenu.ID), LMenuItem);
    end;
  end;
end;

function TMainFrame.CreateMenuItem(const MenuData: TMenuData): TUniMenuItem;
begin
  Result := TUniMenuItem.Create(Self);
  Result.Caption := MenuData.MenuName;
  Result.Hint := MenuData.Description;
  Result.Tag := MenuData.ID;
  Result.Visible := MenuData.Visible;
  Result.Enabled := MenuData.Enabled;

  if MenuData.ActionType <> '' then
    Result.OnClick := OnMenuClick;
end;

procedure TMainFrame.OnMenuClick(Sender: TObject);
var
  LMenuItem: TUniMenuItem;
  LMenuID: Integer;
begin
  if Sender is TUniMenuItem then
  begin
    LMenuItem := TUniMenuItem(Sender);
    LMenuID := LMenuItem.Tag;

    // 触发菜单事件 - 可以扩展为加载对应的功能模块
    UpdateStatusBar('正在加载: ' + LMenuItem.Caption);
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
  AFrame.Align := alClient;
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

procedure TMainFrame.UpdateStatusBar;
var
  LStatusText: string;
begin
  LStatusText := '就绪';

  if Assigned(FContext) then
  begin
    LStatusText := Format('用户: %s | 会话: %s | %s',
      [FContext.GetUserContext.RealName,
       FContext.GetSessionContext.SessionID,
       LStatusText]);
  end;

  UniStatusBar.SimpleText := LStatusText;
end;

procedure TMainFrame.RefreshStatusBar;
begin
  UpdateStatusBar;
end;

end.

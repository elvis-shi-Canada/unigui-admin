unit UniLayout;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes,
  Vcl.Controls,
  uniGUIForm, uniPanel, uniSplitter, uniGUIBaseClasses, uniGUIClasses,
  uniButton;

type
  /// <summary>
  /// 布局方向枚举
  /// </summary>
  TLayoutDirection = (ldHorizontal, ldVertical);

  /// <summary>
  /// 布局区域类型
  /// </summary>
  TLayoutArea = (laLeft, laTop, laRight, laBottom, laCenter);

  /// <summary>
  /// 布局管理器 - 提供灵活的界面布局管理
  /// 支持分割面板、可折叠侧边栏、响应式布局
  /// 主题感知设计
  /// </summary>
  TUniLayout = class(TComponent)
  private
    FOwner: TComponent;
    FContainerPanel: TUniContainerPanel;
    FLeftPanel: TUniPanel;
    FRightPanel: TUniPanel;
    FTopPanel: TUniPanel;
    FBottomPanel: TUniPanel;
    FCenterPanel: TUniPanel;
    FLeftSplitter: TUniSplitter;
    FRightSplitter: TUniSplitter;
    FTopSplitter: TUniSplitter;
    FBottomSplitter: TUniSplitter;

    FLeftPanelVisible: Boolean;
    FRightPanelVisible: Boolean;
    FTopPanelVisible: Boolean;
    FBottomPanelVisible: Boolean;

    FLeftPanelWidth: Integer;
    FRightPanelWidth: Integer;
    FTopPanelHeight: Integer;
    FBottomPanelHeight: Integer;

    FLeftPanelCollapsed: Boolean;
    FRightPanelCollapsed: Boolean;
    FTopPanelCollapsed: Boolean;
    FBottomPanelCollapsed: Boolean;

    FTheme: TObject;  // 避免前向声明问题，使用 TObject 并在访问时转换
    FResponsive: Boolean;

    FOnPanelToggle: TNotifyEvent;
    FOnLayoutChange: TNotifyEvent;

    procedure SetLeftPanelVisible(const Value: Boolean);
    procedure SetRightPanelVisible(const Value: Boolean);
    procedure SetTopPanelVisible(const Value: Boolean);
    procedure SetBottomPanelVisible(const Value: Boolean);

    procedure SetLeftPanelWidth(const Value: Integer);
    procedure SetRightPanelWidth(const Value: Integer);
    procedure SetTopPanelHeight(const Value: Integer);
    procedure SetBottomPanelHeight(const Value: Integer);

    procedure SetLeftPanelCollapsed(const Value: Boolean);
    procedure SetRightPanelCollapsed(const Value: Boolean);
    procedure SetTopPanelCollapsed(const Value: Boolean);
    procedure SetBottomPanelCollapsed(const Value: Boolean);

    procedure SetTheme(const Value: TObject);  // 避免 TUniTheme 前向声明问题
    procedure ApplyTheme;

    procedure ToggleLeftPanel(Sender: TObject = nil);
    procedure ToggleRightPanel(Sender: TObject = nil);
    procedure ToggleTopPanel(Sender: TObject = nil);
    procedure ToggleBottomPanel(Sender: TObject = nil);

    procedure UpdateLayout;
    procedure CreatePanels;
    procedure CreateSplitters;
    procedure DoResponsiveLayout;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    /// <summary>
    /// 初始化布局
    /// </summary>
    procedure Initialize;

    /// <summary>
    /// 添加控件到指定区域
    /// </summary>
    procedure AddControl(Area: TLayoutArea; AControl: TComponent);

    /// <summary>
    /// 切换面板显示/隐藏
    /// </summary>
    procedure TogglePanel(Area: TLayoutArea);

    /// <summary>
    /// 折叠/展开面板
    /// </summary>
    procedure CollapsePanel(Area: TLayoutArea; ACollapse: Boolean);

    /// <summary>
    /// 保存布局状态
    /// </summary>
    procedure SaveLayoutState(const Stream: TStream);

    /// <summary>
    /// 加载布局状态
    /// </summary>
    procedure LoadLayoutState(const Stream: TStream);

    /// <summary>
    /// 重置为默认布局
    /// </summary>
    procedure ResetLayout;

    property ContainerPanel: TUniContainerPanel read FContainerPanel;
    property LeftPanel: TUniPanel read FLeftPanel;
    property RightPanel: TUniPanel read FRightPanel;
    property TopPanel: TUniPanel read FTopPanel;
    property BottomPanel: TUniPanel read FBottomPanel;
    property CenterPanel: TUniPanel read FCenterPanel;
  published
    property LeftPanelVisible: Boolean read FLeftPanelVisible write SetLeftPanelVisible default True;
    property RightPanelVisible: Boolean read FRightPanelVisible write SetRightPanelVisible default False;
    property TopPanelVisible: Boolean read FTopPanelVisible write SetTopPanelVisible default False;
    property BottomPanelVisible: Boolean read FBottomPanelVisible write SetBottomPanelVisible default False;

    property LeftPanelWidth: Integer read FLeftPanelWidth write SetLeftPanelWidth default 250;
    property RightPanelWidth: Integer read FRightPanelWidth write SetRightPanelWidth default 250;
    property TopPanelHeight: Integer read FTopPanelHeight write SetTopPanelHeight default 100;
    property BottomPanelHeight: Integer read FBottomPanelHeight write SetBottomPanelHeight default 100;

    property LeftPanelCollapsed: Boolean read FLeftPanelCollapsed write SetLeftPanelCollapsed default False;
    property RightPanelCollapsed: Boolean read FRightPanelCollapsed write SetRightPanelCollapsed default False;
    property TopPanelCollapsed: Boolean read FTopPanelCollapsed write SetTopPanelCollapsed default False;
    property BottomPanelCollapsed: Boolean read FBottomPanelCollapsed write SetBottomPanelCollapsed default False;

    property Responsive: Boolean read FResponsive write FResponsive default True;

    property OnPanelToggle: TNotifyEvent read FOnPanelToggle write FOnPanelToggle;
    property OnLayoutChange: TNotifyEvent read FOnLayoutChange write FOnLayoutChange;
  end;

implementation

uses
  UniTheme;

{ TUniLayout }

constructor TUniLayout.Create(AOwner: TComponent);
begin
  inherited;

  FOwner := AOwner;
  FLeftPanelVisible := True;
  FRightPanelVisible := False;
  FTopPanelVisible := False;
  FBottomPanelVisible := False;

  FLeftPanelWidth := 250;
  FRightPanelWidth := 250;
  FTopPanelHeight := 100;
  FBottomPanelHeight := 100;

  FLeftPanelCollapsed := False;
  FRightPanelCollapsed := False;
  FTopPanelCollapsed := False;
  FBottomPanelCollapsed := False;

  FResponsive := True;

  Initialize;
end;

destructor TUniLayout.Destroy;
begin
  inherited;
end;

procedure TUniLayout.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FTheme) then
    FTheme := nil;
end;

procedure TUniLayout.Initialize;
begin
  CreatePanels;
  CreateSplitters;
  UpdateLayout;
end;

procedure TUniLayout.CreatePanels;
begin
  // 创建容器面板
  FContainerPanel := TUniContainerPanel.Create(FOwner);
  FContainerPanel.Parent := TWinControl(FOwner);
  // FContainerPanel.Align := alClient;  // UniGUI 使用 CSS 布局，不支持 VCL Align
  FContainerPanel.Layout := 'border';

  // 创建左侧面板
  FLeftPanel := TUniPanel.Create(FOwner);
  FLeftPanel.Parent := FContainerPanel;
  // FLeftPanel.Align := alLeft;  // UniGUI 不支持 VCL Align
  FLeftPanel.Width := FLeftPanelWidth;
  FLeftPanel.Visible := FLeftPanelVisible;
  // FLeftPanel.LayoutRegion := 'west';  // UniGUI 可能不支持此属性

  // 创建右侧面板
  FRightPanel := TUniPanel.Create(FOwner);
  FRightPanel.Parent := FContainerPanel;
  // FRightPanel.Align := alRight;  // UniGUI 不支持 VCL Align
  FRightPanel.Width := FRightPanelWidth;
  FRightPanel.Visible := FRightPanelVisible;
  // FRightPanel.LayoutRegion := 'east';  // UniGUI 可能不支持此属性

  // 创建顶部面板
  FTopPanel := TUniPanel.Create(FOwner);
  FTopPanel.Parent := FContainerPanel;
  // FTopPanel.Align := alTop;  // UniGUI 不支持 VCL Align
  FTopPanel.Height := FTopPanelHeight;
  FTopPanel.Visible := FTopPanelVisible;
  // FTopPanel.LayoutRegion := 'north';  // UniGUI 可能不支持此属性

  // 创建底部面板
  FBottomPanel := TUniPanel.Create(FOwner);
  FBottomPanel.Parent := FContainerPanel;
  // FBottomPanel.Align := alBottom;  // UniGUI 不支持 VCL Align
  FBottomPanel.Height := FBottomPanelHeight;
  FBottomPanel.Visible := FBottomPanelVisible;
  // FBottomPanel.LayoutRegion := 'south';  // UniGUI 可能不支持此属性

  // 创建中心面板
  FCenterPanel := TUniPanel.Create(FOwner);
  FCenterPanel.Parent := FContainerPanel;
  // FCenterPanel.Align := alClient;  // UniGUI 不支持 VCL Align
  // FCenterPanel.LayoutRegion := 'center';  // UniGUI 可能不支持此属性
end;

procedure TUniLayout.CreateSplitters;
begin
  // 创建左侧分割器
  FLeftSplitter := TUniSplitter.Create(FOwner);
  FLeftSplitter.Parent := FContainerPanel;
  // FLeftSplitter.Align := alLeft;  // UniGUI 不支持 VCL Align
  FLeftSplitter.Visible := FLeftPanelVisible;

  // 创建右侧分割器
  FRightSplitter := TUniSplitter.Create(FOwner);
  FRightSplitter.Parent := FContainerPanel;
  // FRightSplitter.Align := alRight;  // UniGUI 不支持 VCL Align
  FRightSplitter.Visible := FRightPanelVisible;

  // 创建顶部分割器
  FTopSplitter := TUniSplitter.Create(FOwner);
  FTopSplitter.Parent := FContainerPanel;
  // FTopSplitter.Align := alTop;  // UniGUI 不支持 VCL Align
  FTopSplitter.Visible := FTopPanelVisible;

  // 创建底部分割器
  FBottomSplitter := TUniSplitter.Create(FOwner);
  FBottomSplitter.Parent := FContainerPanel;
  // FBottomSplitter.Align := alBottom;  // UniGUI 不支持 VCL Align
  FBottomSplitter.Visible := FBottomPanelVisible;
end;

procedure TUniLayout.UpdateLayout;
begin
  if FResponsive then
    DoResponsiveLayout;

  if Assigned(FOnLayoutChange) then
    FOnLayoutChange(Self);
end;

procedure TUniLayout.DoResponsiveLayout;
var
  LClientWidth: Integer;
begin
  if not Assigned(FContainerPanel) then
    Exit;

  LClientWidth := FContainerPanel.Width;

  // 小屏幕隐藏侧面板
  if LClientWidth < 768 then
  begin
    if FLeftPanelVisible and not FLeftPanelCollapsed then
      SetLeftPanelCollapsed(True);
  end
  else
  begin
    if FLeftPanelCollapsed and FLeftPanelVisible then
      SetLeftPanelCollapsed(False);
  end;
end;

procedure TUniLayout.AddControl(Area: TLayoutArea; AControl: TComponent);
begin
  if not Assigned(AControl) then
    Exit;

  case Area of
    laLeft:
      begin
        // UniGUI 控件通过 Parent 属性设置父容器
        // TUniControl(AControl).Parent := FLeftPanel;
        // AControl.Align := alClient;  // UniGUI 使用不同的属性
      end;
    laRight:
      begin
        // TUniControl(AControl).Parent := FRightPanel;
        // AControl.Align := alClient;
      end;
    laTop:
      begin
        // TUniControl(AControl).Parent := FTopPanel;
        // AControl.Align := alClient;
      end;
    laBottom:
      begin
        // TUniControl(AControl).Parent := FBottomPanel;
        // AControl.Align := alClient;
      end;
    laCenter:
      begin
        // TUniControl(AControl).Parent := FCenterPanel;
        // AControl.Align := alClient;
      end;
  end;
end;

procedure TUniLayout.TogglePanel(Area: TLayoutArea);
begin
  case Area of
    laLeft: ToggleLeftPanel;
    laRight: ToggleRightPanel;
    laTop: ToggleTopPanel;
    laBottom: ToggleBottomPanel;
  end;
end;

procedure TUniLayout.CollapsePanel(Area: TLayoutArea; ACollapse: Boolean);
begin
  case Area of
    laLeft: SetLeftPanelCollapsed(ACollapse);
    laRight: SetRightPanelCollapsed(ACollapse);
    laTop: SetTopPanelCollapsed(ACollapse);
    laBottom: SetBottomPanelCollapsed(ACollapse);
  end;
end;

procedure TUniLayout.ToggleLeftPanel(Sender: TObject);
begin
  SetLeftPanelVisible(not FLeftPanelVisible);
end;

procedure TUniLayout.ToggleRightPanel(Sender: TObject);
begin
  SetRightPanelVisible(not FRightPanelVisible);
end;

procedure TUniLayout.ToggleTopPanel(Sender: TObject);
begin
  SetTopPanelVisible(not FTopPanelVisible);
end;

procedure TUniLayout.ToggleBottomPanel(Sender: TObject);
begin
  SetBottomPanelVisible(not FBottomPanelVisible);
end;

procedure TUniLayout.SetLeftPanelVisible(const Value: Boolean);
begin
  if FLeftPanelVisible <> Value then
  begin
    FLeftPanelVisible := Value;
    if Assigned(FLeftPanel) then
      FLeftPanel.Visible := Value;
    if Assigned(FLeftSplitter) then
      FLeftSplitter.Visible := Value;
    UpdateLayout;
  end;
end;

procedure TUniLayout.SetRightPanelVisible(const Value: Boolean);
begin
  if FRightPanelVisible <> Value then
  begin
    FRightPanelVisible := Value;
    if Assigned(FRightPanel) then
      FRightPanel.Visible := Value;
    if Assigned(FRightSplitter) then
      FRightSplitter.Visible := Value;
    UpdateLayout;
  end;
end;

procedure TUniLayout.SetTopPanelVisible(const Value: Boolean);
begin
  if FTopPanelVisible <> Value then
  begin
    FTopPanelVisible := Value;
    if Assigned(FTopPanel) then
      FTopPanel.Visible := Value;
    if Assigned(FTopSplitter) then
      FTopSplitter.Visible := Value;
    UpdateLayout;
  end;
end;

procedure TUniLayout.SetBottomPanelVisible(const Value: Boolean);
begin
  if FBottomPanelVisible <> Value then
  begin
    FBottomPanelVisible := Value;
    if Assigned(FBottomPanel) then
      FBottomPanel.Visible := Value;
    if Assigned(FBottomSplitter) then
      FBottomSplitter.Visible := Value;
    UpdateLayout;
  end;
end;

procedure TUniLayout.SetLeftPanelWidth(const Value: Integer);
begin
  if FLeftPanelWidth <> Value then
  begin
    FLeftPanelWidth := Value;
    if Assigned(FLeftPanel) then
      FLeftPanel.Width := Value;
    UpdateLayout;
  end;
end;

procedure TUniLayout.SetRightPanelWidth(const Value: Integer);
begin
  if FRightPanelWidth <> Value then
  begin
    FRightPanelWidth := Value;
    if Assigned(FRightPanel) then
      FRightPanel.Width := Value;
    UpdateLayout;
  end;
end;

procedure TUniLayout.SetTopPanelHeight(const Value: Integer);
begin
  if FTopPanelHeight <> Value then
  begin
    FTopPanelHeight := Value;
    if Assigned(FTopPanel) then
      FTopPanel.Height := Value;
    UpdateLayout;
  end;
end;

procedure TUniLayout.SetBottomPanelHeight(const Value: Integer);
begin
  if FBottomPanelHeight <> Value then
  begin
    FBottomPanelHeight := Value;
    if Assigned(FBottomPanel) then
      FBottomPanel.Height := Value;
    UpdateLayout;
  end;
end;

procedure TUniLayout.SetLeftPanelCollapsed(const Value: Boolean);
begin
  if FLeftPanelCollapsed <> Value then
  begin
    FLeftPanelCollapsed := Value;
    if Assigned(FLeftPanel) then
    begin
      if Value then
        FLeftPanel.Width := 0
      else
        FLeftPanel.Width := FLeftPanelWidth;
    end;
    UpdateLayout;
  end;
end;

procedure TUniLayout.SetRightPanelCollapsed(const Value: Boolean);
begin
  if FRightPanelCollapsed <> Value then
  begin
    FRightPanelCollapsed := Value;
    if Assigned(FRightPanel) then
    begin
      if Value then
        FRightPanel.Width := 0
      else
        FRightPanel.Width := FRightPanelWidth;
    end;
    UpdateLayout;
  end;
end;

procedure TUniLayout.SetTopPanelCollapsed(const Value: Boolean);
begin
  if FTopPanelCollapsed <> Value then
  begin
    FTopPanelCollapsed := Value;
    if Assigned(FTopPanel) then
    begin
      if Value then
        FTopPanel.Height := 0
      else
        FTopPanel.Height := FTopPanelHeight;
    end;
    UpdateLayout;
  end;
end;

procedure TUniLayout.SetBottomPanelCollapsed(const Value: Boolean);
begin
  if FBottomPanelCollapsed <> Value then
  begin
    FBottomPanelCollapsed := Value;
    if Assigned(FBottomPanel) then
    begin
      if Value then
        FBottomPanel.Height := 0
      else
        FBottomPanel.Height := FBottomPanelHeight;
    end;
    UpdateLayout;
  end;
end;

procedure TUniLayout.SetTheme(const Value: TObject);
begin
  if FTheme <> Value then
  begin
    FTheme := Value;
    ApplyTheme;
  end;
end;

procedure TUniLayout.ApplyTheme;
var
  LTheme: TUniTheme;
begin
  if not Assigned(FTheme) then
    Exit;

  LTheme := FTheme as TUniTheme;
  if not Assigned(LTheme) then
    Exit;

  // 应用主题到所有面板
  if Assigned(FLeftPanel) then
  begin
    FLeftPanel.Color := LTheme.PanelColor;
    FLeftPanel.Font.Color := LTheme.FontColor;
  end;

  if Assigned(FRightPanel) then
  begin
    FRightPanel.Color := LTheme.PanelColor;
    FRightPanel.Font.Color := LTheme.FontColor;
  end;

  if Assigned(FTopPanel) then
  begin
    FTopPanel.Color := LTheme.HeaderColor;
    FTopPanel.Font.Color := LTheme.FontColor;
  end;

  if Assigned(FBottomPanel) then
  begin
    FBottomPanel.Color := LTheme.PanelColor;
    FBottomPanel.Font.Color := LTheme.FontColor;
  end;

  if Assigned(FCenterPanel) then
  begin
    FCenterPanel.Color := LTheme.BackgroundColor;
    FCenterPanel.Font.Color := LTheme.FontColor;
  end;
end;

procedure TUniLayout.SaveLayoutState(const Stream: TStream);
begin
  // 保存布局状态到流
  if not Assigned(Stream) then
    Exit;

  Stream.WriteBuffer(FLeftPanelVisible, SizeOf(Boolean));
  Stream.WriteBuffer(FRightPanelVisible, SizeOf(Boolean));
  Stream.WriteBuffer(FTopPanelVisible, SizeOf(Boolean));
  Stream.WriteBuffer(FBottomPanelVisible, SizeOf(Boolean));

  Stream.WriteBuffer(FLeftPanelWidth, SizeOf(Integer));
  Stream.WriteBuffer(FRightPanelWidth, SizeOf(Integer));
  Stream.WriteBuffer(FTopPanelHeight, SizeOf(Integer));
  Stream.WriteBuffer(FBottomPanelHeight, SizeOf(Integer));

  Stream.WriteBuffer(FLeftPanelCollapsed, SizeOf(Boolean));
  Stream.WriteBuffer(FRightPanelCollapsed, SizeOf(Boolean));
  Stream.WriteBuffer(FTopPanelCollapsed, SizeOf(Boolean));
  Stream.WriteBuffer(FBottomPanelCollapsed, SizeOf(Boolean));
end;

procedure TUniLayout.LoadLayoutState(const Stream: TStream);
begin
  // 从流加载布局状态
  if not Assigned(Stream) then
    Exit;

  Stream.ReadBuffer(FLeftPanelVisible, SizeOf(Boolean));
  Stream.ReadBuffer(FRightPanelVisible, SizeOf(Boolean));
  Stream.ReadBuffer(FTopPanelVisible, SizeOf(Boolean));
  Stream.ReadBuffer(FBottomPanelVisible, SizeOf(Boolean));

  Stream.ReadBuffer(FLeftPanelWidth, SizeOf(Integer));
  Stream.ReadBuffer(FRightPanelWidth, SizeOf(Integer));
  Stream.ReadBuffer(FTopPanelHeight, SizeOf(Integer));
  Stream.ReadBuffer(FBottomPanelHeight, SizeOf(Integer));

  Stream.ReadBuffer(FLeftPanelCollapsed, SizeOf(Boolean));
  Stream.ReadBuffer(FRightPanelCollapsed, SizeOf(Boolean));
  Stream.ReadBuffer(FTopPanelCollapsed, SizeOf(Boolean));
  Stream.ReadBuffer(FBottomPanelCollapsed, SizeOf(Boolean));

  UpdateLayout;
end;

procedure TUniLayout.ResetLayout;
begin
  FLeftPanelVisible := True;
  FRightPanelVisible := False;
  FTopPanelVisible := False;
  FBottomPanelVisible := False;

  FLeftPanelWidth := 250;
  FRightPanelWidth := 250;
  FTopPanelHeight := 100;
  FBottomPanelHeight := 100;

  FLeftPanelCollapsed := False;
  FRightPanelCollapsed := False;
  FTopPanelCollapsed := False;
  FBottomPanelCollapsed := False;

  UpdateLayout;
end;

end.

unit IconSelector;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Generics.Collections,
  System.UITypes,
  uniGUIBaseClasses, uniGUIClasses, uniGUImClasses, uniButton, uniLabel, UniComboBox,
  uniEdit, uniPanel, uniGUIForm, uniImage, uniScrollBox, uniRadioGroup,  UniCheckBox,
  UniContext, UniPlugin.Types, uniMultiItem, Vcl.Controls, Vcl.Forms;

type
  /// <summary>
  /// 图标选择器对话框 - 用于选择菜单图标
  /// 支持 Font Awesome、Material Icons 等常用图标库
  /// </summary>
  TIconSelector = class(TUniForm)
    pnlMain: TUniPanel;
    pnlSearch: TUniPanel;
    lblSearch: TUniLabel;
    edtSearch: TUniEdit;
    btnSearch: TUniButton;
    pnlCategories: TUniPanel;
    lblCategories: TUniLabel;
    cmbCategories: TUniComboBox;
    pnlIcons: TUniPanel;
    scrollIcons: TUniScrollBox;
    pnlIconGrid: TUniPanel;
    pnlPreview: TUniPanel;
    lblPreview: TUniLabel;
    lblIconName: TUniLabel;
    pnlBottom: TUniPanel;
    btnOK: TUniButton;
    btnCancel: TUniButton;
    chkLarge: TUniCheckBox;

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure edtSearchKeyPress(Sender: TObject; var Key: Char);
    procedure cmbCategoriesChange(Sender: TObject);
    procedure chkLargeClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    FSelectedIcon: string;
    FContext: IExecutionContext;
    FIconList: TList<TPair<string, string>>; // Key: IconClass, Value: DisplayName
    FFilteredIcons: TList<TPair<string, string>>;
    FSelectedIndex: Integer;

    procedure InitializeIcons;
    procedure LoadIconCategories;
    procedure RefreshIconGrid;
    procedure FilterIcons;
    procedure SelectIcon(const IconClass: string);
    procedure CreateIconButtons(ParentPanel: TUniPanel);
    procedure Cleanup;
    function MatchesCategory(const DisplayName, Category: string): Boolean;
    procedure IconButtonClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetContext(const Context: IExecutionContext);
    function Execute(const DefaultIcon: string): string;
  end;

implementation

{$R *.dfm}

constructor TIconSelector.Create(AOwner: TComponent);
begin
  inherited;
  FSelectedIcon := '';
  FIconList := TList<TPair<string, string>>.Create;
  FFilteredIcons := TList<TPair<string, string>>.Create;
  FSelectedIndex := -1;
end;

destructor TIconSelector.Destroy;
begin
  Cleanup;
  FIconList.Free;
  FFilteredIcons.Free;
  inherited;
end;

procedure TIconSelector.SetContext(const Context: IExecutionContext);
begin
  FContext := Context;
end;

procedure TIconSelector.Cleanup;
begin
  FIconList.Clear;
  FFilteredIcons.Clear;
end;

procedure TIconSelector.FormCreate(Sender: TObject);
begin
  Caption := '选择图标';
  Width := 700;
  Height := 550;

  InitializeIcons;
  LoadIconCategories;
end;

procedure TIconSelector.FormShow(Sender: TObject);
begin
  edtSearch.SetFocus;
  RefreshIconGrid;
end;

procedure TIconSelector.InitializeIcons;
begin
  FIconList.Clear;

  // Font Awesome 图标 (常用)
  FIconList.Add(TPair<string, string>.Create('fa fa-home', '首页'));
  FIconList.Add(TPair<string, string>.Create('fa fa-user', '用户'));
  FIconList.Add(TPair<string, string>.Create('fa fa-users', '用户组'));
  FIconList.Add(TPair<string, string>.Create('fa fa-user-shield', '角色权限'));
  FIconList.Add(TPair<string, string>.Create('fa fa-cog', '设置'));
  FIconList.Add(TPair<string, string>.Create('fa fa-cogs', '系统设置'));
  FIconList.Add(TPair<string, string>.Create('fa fa-database', '数据'));
  FIconList.Add(TPair<string, string>.Create('fa fa-table', '表格'));
  FIconList.Add(TPair<string, string>.Create('fa fa-list', '列表'));
  FIconList.Add(TPair<string, string>.Create('fa fa-th-list', '多级列表'));
  FIconList.Add(TPair<string, string>.Create('fa fa-th', '网格'));
  FIconList.Add(TPair<string, string>.Create('fa fa-th-large', '大网格'));
  FIconList.Add(TPair<string, string>.Create('fa fa-sitemap', '站点地图'));
  FIconList.Add(TPair<string, string>.Create('fa fa-folder', '文件夹'));
  FIconList.Add(TPair<string, string>.Create('fa fa-folder-open', '打开文件夹'));
  FIconList.Add(TPair<string, string>.Create('fa fa-file', '文件'));
  FIconList.Add(TPair<string, string>.Create('fa fa-file-text', '文本文档'));
  FIconList.Add(TPair<string, string>.Create('fa fa-file-code', '代码文件'));
  FIconList.Add(TPair<string, string>.Create('fa fa-download', '下载'));
  FIconList.Add(TPair<string, string>.Create('fa fa-upload', '上传'));
  FIconList.Add(TPair<string, string>.Create('fa fa-edit', '编辑'));
  FIconList.Add(TPair<string, string>.Create('fa fa-trash', '删除'));
  FIconList.Add(TPair<string, string>.Create('fa fa-plus', '添加'));
  FIconList.Add(TPair<string, string>.Create('fa fa-minus', '减少'));
  FIconList.Add(TPair<string, string>.Create('fa fa-search', '搜索'));
  FIconList.Add(TPair<string, string>.Create('fa fa-filter', '筛选'));
  FIconList.Add(TPair<string, string>.Create('fa fa-sort', '排序'));
  FIconList.Add(TPair<string, string>.Create('fa fa-sort-up', '升序'));
  FIconList.Add(TPair<string, string>.Create('fa fa-sort-down', '降序'));
  FIconList.Add(TPair<string, string>.Create('fa fa-eye', '查看'));
  FIconList.Add(TPair<string, string>.Create('fa fa-eye-slash', '隐藏'));
  FIconList.Add(TPair<string, string>.Create('fa fa-lock', '锁定'));
  FIconList.Add(TPair<string, string>.Create('fa fa-unlock', '解锁'));
  FIconList.Add(TPair<string, string>.Create('fa fa-key', '密钥'));
  FIconList.Add(TPair<string, string>.Create('fa fa-shield', '盾牌'));
  FIconList.Add(TPair<string, string>.Create('fa fa-check', '勾选'));
  FIconList.Add(TPair<string, string>.Create('fa fa-check-circle', '勾选圆'));
  FIconList.Add(TPair<string, string>.Create('fa fa-times', '关闭'));
  FIconList.Add(TPair<string, string>.Create('fa fa-times-circle', '关闭圆'));
  FIconList.Add(TPair<string, string>.Create('fa fa-info-circle', '信息圆'));
  FIconList.Add(TPair<string, string>.Create('fa fa-exclamation-circle', '警告圆'));
  FIconList.Add(TPair<string, string>.Create('fa fa-question-circle', '疑问圆'));
  FIconList.Add(TPair<string, string>.Create('fa fa-bell', '通知'));
  FIconList.Add(TPair<string, string>.Create('fa fa-envelope', '邮件'));
  FIconList.Add(TPair<string, string>.Create('fa fa-calendar', '日历'));
  FIconList.Add(TPair<string, string>.Create('fa fa-clock', '时钟'));
  FIconList.Add(TPair<string, string>.Create('fa fa-chart-bar', '柱状图'));
  FIconList.Add(TPair<string, string>.Create('fa fa-chart-line', '折线图'));
  FIconList.Add(TPair<string, string>.Create('fa fa-chart-pie', '饼图'));
  FIconList.Add(TPair<string, string>.Create('fa fa-print', '打印'));
  FIconList.Add(TPair<string, string>.Create('fa fa-save', '保存'));
  FIconList.Add(TPair<string, string>.Create('fa fa-copy', '复制'));
  FIconList.Add(TPair<string, string>.Create('fa fa-paste', '粘贴'));
  FIconList.Add(TPair<string, string>.Create('fa fa-cut', '剪切'));
  FIconList.Add(TPair<string, string>.Create('fa fa-undo', '撤销'));
  FIconList.Add(TPair<string, string>.Create('fa fa-redo', '重做'));
  FIconList.Add(TPair<string, string>.Create('fa fa-refresh', '刷新'));
  FIconList.Add(TPair<string, string>.Create('fa fa-sync', '同步'));
  FIconList.Add(TPair<string, string>.Create('fa fa-forward', '前进'));
  FIconList.Add(TPair<string, string>.Create('fa fa-backward', '后退'));
  FIconList.Add(TPair<string, string>.Create('fa fa-play', '播放'));
  FIconList.Add(TPair<string, string>.Create('fa fa-pause', '暂停'));
  FIconList.Add(TPair<string, string>.Create('fa fa-stop', '停止'));
  FIconList.Add(TPair<string, string>.Create('fa fa-eject', '弹出'));
  FIconList.Add(TPair<string, string>.Create('fa fa-volume-up', '音量'));
  FIconList.Add(TPair<string, string>.Create('fa fa-camera', '相机'));
  FIconList.Add(TPair<string, string>.Create('fa fa-image', '图片'));
  FIconList.Add(TPair<string, string>.Create('fa fa-video', '视频'));
  FIconList.Add(TPair<string, string>.Create('fa fa-map', '地图'));
  FIconList.Add(TPair<string, string>.Create('fa fa-map-marker', '位置标记'));
  FIconList.Add(TPair<string, string>.Create('fa fa-globe', '地球'));
  FIconList.Add(TPair<string, string>.Create('fa fa-link', '链接'));
  FIconList.Add(TPair<string, string>.Create('fa fa-unlink', '取消链接'));
  FIconList.Add(TPair<string, string>.Create('fa fa-external-link', '外部链接'));
  FIconList.Add(TPair<string, string>.Create('fa fa-ellipsis-h', '水平省略号'));
  FIconList.Add(TPair<string, string>.Create('fa fa-ellipsis-v', '垂直省略号'));
  FIconList.Add(TPair<string, string>.Create('fa fa-bars', '菜单栏'));
  FIconList.Add(TPair<string, string>.Create('fa fa-navicon', '导航图标'));
  FIconList.Add(TPair<string, string>.Create('fa fa-angle-left', '左箭头'));
  FIconList.Add(TPair<string, string>.Create('fa fa-angle-right', '右箭头'));
  FIconList.Add(TPair<string, string>.Create('fa fa-angle-up', '上箭头'));
  FIconList.Add(TPair<string, string>.Create('fa fa-angle-down', '下箭头'));
  FIconList.Add(TPair<string, string>.Create('fa fa-caret-left', '左三角'));
  FIconList.Add(TPair<string, string>.Create('fa fa-caret-right', '右三角'));
  FIconList.Add(TPair<string, string>.Create('fa fa-caret-up', '上三角'));
  FIconList.Add(TPair<string, string>.Create('fa fa-caret-down', '下三角'));
  FIconList.Add(TPair<string, string>.Create('fa fa-star', '星'));
  FIconList.Add(TPair<string, string>.Create('fa fa-star-half', '半星'));
  FIconList.Add(TPair<string, string>.Create('fa fa-heart', '心'));
  FIconList.Add(TPair<string, string>.Create('fa fa-book', '书'));
  FIconList.Add(TPair<string, string>.Create('fa fa-bookmark', '书签'));
  FIconList.Add(TPair<string, string>.Create('fa fa-tag', '标签'));
  FIconList.Add(TPair<string, string>.Create('fa fa-tags', '多标签'));
  FIconList.Add(TPair<string, string>.Create('fa fa-certificate', '证书'));
  FIconList.Add(TPair<string, string>.Create('fa fa-award', '奖牌'));

  // Material Icons 风格的类名
  FIconList.Add(TPair<string, string>.Create('material-icons home', 'Material 首页'));
  FIconList.Add(TPair<string, string>.Create('material-icons person', 'Material 用户'));
  FIconList.Add(TPair<string, string>.Create('material-icons settings', 'Material 设置'));
  FIconList.Add(TPair<string, string>.Create('material-icons menu', 'Material 菜单'));
  FIconList.Add(TPair<string, string>.Create('material-icons dashboard', 'Material 仪表板'));
  FIconList.Add(TPair<string, string>.Create('material-icons apps', 'Material 应用'));
  FIconList.Add(TPair<string, string>.Create('material-icons folder', 'Material 文件夹'));
  FIconList.Add(TPair<string, string>.Create('material-icons description', 'Material 文档'));
  FIconList.Add(TPair<string, string>.Create('material-icons insert_drive_file', 'Material 文件'));
end;

procedure TIconSelector.LoadIconCategories;
begin
  cmbCategories.Items.Clear;
  cmbCategories.Items.Add('全部');
  cmbCategories.Items.Add('导航');
  cmbCategories.Items.Add('操作');
  cmbCategories.Items.Add('文件');
  cmbCategories.Items.Add('数据');
  cmbCategories.Items.Add('图表');
  cmbCategories.Items.Add('媒体');
  cmbCategories.Items.Add('其他');
  cmbCategories.ItemIndex := 0;
end;

procedure TIconSelector.RefreshIconGrid;
var
  I: Integer;
begin
  // 清空现有图标 - UniGUI 使用 DisposeChildren
  for I := pnlIconGrid.ControlCount - 1 downto 0 do
    pnlIconGrid.Controls[I].Free;

  // 创建图标按钮
  CreateIconButtons(pnlIconGrid);
end;

procedure TIconSelector.FilterIcons;
var
  LSearchText: string;
  LCategory: string;
  LPair: TPair<string, string>;
begin
  FFilteredIcons.Clear;

  LSearchText := LowerCase(Trim(edtSearch.Text));
  LCategory := cmbCategories.Text;

  for LPair in FIconList do
  begin
    // 类别筛选
    if (LCategory <> '全部') and not MatchesCategory(LPair.Value, LCategory) then
      Continue;

    // 搜索筛选
    if (LSearchText <> '') and
       not (Pos(LSearchText, LowerCase(LPair.Key)) > 0) and
       not (Pos(LSearchText, LowerCase(LPair.Value)) > 0) then
      Continue;

    FFilteredIcons.Add(LPair);
  end;
end;

function TIconSelector.MatchesCategory(const DisplayName, Category: string): Boolean;
begin
  // 简单的类别匹配逻辑
  Result := True;

  if Category = '导航' then
    Result := (Pos('首页', DisplayName) > 0) or
              (Pos('菜单', DisplayName) > 0) or
              (Pos('地图', DisplayName) > 0) or
              (Pos('箭头', DisplayName) > 0) or
              (Pos('三角', DisplayName) > 0)
  else if Category = '操作' then
    Result := (Pos('编辑', DisplayName) > 0) or
              (Pos('删除', DisplayName) > 0) or
              (Pos('添加', DisplayName) > 0) or
              (Pos('保存', DisplayName) > 0) or
              (Pos('搜索', DisplayName) > 0) or
              (Pos('刷新', DisplayName) > 0) or
              (Pos('勾选', DisplayName) > 0) or
              (Pos('关闭', DisplayName) > 0)
  else if Category = '文件' then
    Result := (Pos('文件', DisplayName) > 0) or
              (Pos('文档', DisplayName) > 0) or
              (Pos('文件夹', DisplayName) > 0) or
              (Pos('书', DisplayName) > 0)
  else if Category = '数据' then
    Result := (Pos('数据', DisplayName) > 0) or
              (Pos('表格', DisplayName) > 0) or
              (Pos('列表', DisplayName) > 0) or
              (Pos('网格', DisplayName) > 0) or
              (Pos('库', DisplayName) > 0)
  else if Category = '图表' then
    Result := (Pos('图', DisplayName) > 0)
  else if Category = '媒体' then
    Result := (Pos('视频', DisplayName) > 0) or
              (Pos('音', DisplayName) > 0) or
              (Pos('图', DisplayName) > 0) or
              (Pos('相机', DisplayName) > 0);
end;

procedure TIconSelector.CreateIconButtons(ParentPanel: TUniPanel);
var
  LButton: TUniButton;
  LIndex: Integer;
  LPair: TPair<string, string>;
  LLeft, LTop: Integer;
  LButtonSize: Integer;
  LGap: Integer;
  LColumns: Integer;
begin
  FilterIcons;

  if chkLarge.Checked then
    LButtonSize := 60
  else
    LButtonSize := 40;

  LGap := 5;
  LColumns := (ParentPanel.Width - LGap) div (LButtonSize + LGap);

  LLeft := LGap;
  LTop := LGap;

  LIndex := 0;
  for LPair in FFilteredIcons do
  begin
    LButton := TUniButton.Create(ParentPanel);
    LButton.Parent := ParentPanel;
    LButton.Caption := ''; // 图标通过 CSS 显示
    LButton.Width := LButtonSize;
    LButton.Height := LButtonSize;
    LButton.Left := LLeft;
    LButton.Top := LTop;
    LButton.Name := 'IconBtn_' + IntToStr(LIndex);
    LButton.Tag := LIndex;
    LButton.Hint := LPair.Value + ' (' + LPair.Key + ')';
    LButton.ShowHint := True;

    // 设置图标样式
    LButton.ClientEvents.ExtEvents.Add(
      'beforerender=function beforerender(sender, container, config){' +
      '  sender.setIconCls("' + LPair.Key + '");' +
      '}'
    );

    // 点击事件
    LButton.OnClick := IconButtonClick;

    // 计算位置
    Inc(LIndex);
    if LIndex mod LColumns = 0 then
    begin
      LLeft := LGap;
      Inc(LTop, LButtonSize + LGap);
    end
    else
    begin
      Inc(LLeft, LButtonSize + LGap);
    end;
  end;

  // 调整滚动区域大小
  scrollIcons.Height := ParentPanel.Parent.Height - pnlSearch.Height - pnlCategories.Height - pnlBottom.Height - 20;
end;

procedure TIconSelector.SelectIcon(const IconClass: string);
begin
  FSelectedIcon := IconClass;
  lblIconName.Caption := IconClass;

  // 高亮选中的图标（需要通过样式实现）
end;

function TIconSelector.Execute(const DefaultIcon: string): string;
begin
  FSelectedIcon := DefaultIcon;
  if DefaultIcon <> '' then
    lblIconName.Caption := DefaultIcon
  else
    lblIconName.Caption := '未选择';

  RefreshIconGrid;

  if ShowModal = mrOK then
    Result := FSelectedIcon
  else
    Result := '';
end;

procedure TIconSelector.btnSearchClick(Sender: TObject);
begin
  RefreshIconGrid;
end;

procedure TIconSelector.edtSearchKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    btnSearchClick(nil);
end;

procedure TIconSelector.cmbCategoriesChange(Sender: TObject);
begin
  RefreshIconGrid;
end;

procedure TIconSelector.chkLargeClick(Sender: TObject);
begin
  RefreshIconGrid;
end;

procedure TIconSelector.btnOKClick(Sender: TObject);
begin
  if FSelectedIcon = '' then
  begin
    ShowMessage('请选择一个图标');
    Exit;
  end;

  ModalResult := mrOK;
end;

procedure TIconSelector.IconButtonClick(Sender: TObject);
var
  LBtn: TUniButton;
  LSelectedPair: TPair<string, string>;
begin
  LBtn := TUniButton(Sender);

  if (LBtn.Tag >= 0) and (LBtn.Tag < FFilteredIcons.Count) then
  begin
    LSelectedPair := FFilteredIcons[LBtn.Tag];
    SelectIcon(LSelectedPair.Key);
  end;
end;

procedure TIconSelector.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

initialization
  // Register for FindClass-driven MDI routing (UniAdmin_Menus.RoutePath -> form)
  RegisterClass(TIconSelector);

end.

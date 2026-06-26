unit MenuTreeFrame;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Generics.Collections,
  Data.DB, FireDAC.Comp.Client,
  uniGUIBaseClasses, uniGUIClasses, uniGUImClasses, uniEdit, uniButton, uniToolBar,
  uniPanel, uniTreeMenu, uniLabel, uniComboBox, uniSplitter, uniGUIAbstractClasses,
  UniContext, UniPlugin.Types, UniAdminModel,
  BaseCrudFrame, MenuDataModule, uniDBGrid, uniBasicGrid,
  Vcl.Controls;

type
  /// <summary>
  /// 菜单树编辑窗体 - 继承自 TBaseCrudFrame
  /// 提供菜单的树形显示、拖拽排序、增删改功能
  /// </summary>
  TMenuTreeFrame = class(TBaseCrudFrame)
    pnlContainer: TUniPanel;
    pnlLeft: TUniPanel;
    pnlTree: TUniPanel;
    lblTree: TUniLabel;
    treeMenus: TUniTreeMenu;
    pnlTreeToolbar: TUniPanel;
    btnExpandAll: TUniButton;
    btnCollapseAll: TUniButton;
    pnlRight: TUniPanel;
    pnlSearch: TUniPanel;
    lblSearch: TUniLabel;
    edtSearch: TUniEdit;
    cmbStatus: TUniComboBox;
    btnSearch: TUniButton;
    UniDBGrid: TUniDBGrid;
    UniDataSource: TDataSource;
    splitter: TUniSplitter;

    procedure DoInitialize; override;
    procedure DoFinalize; override;
    procedure DoRefresh; override;

    procedure btnSearchClick(Sender: TObject);
    procedure edtSearchKeyPress(Sender: TObject; var Key: Char);
    procedure cmbStatusChange(Sender: TObject);
    procedure treeMenusClick(Sender: TObject);
    procedure treeMenusDragDrop(Sender: TObject; Node, TargetNode: TUniTreeNode;
      var Allow: Boolean);
    procedure treeMenusDragOver(Sender: TObject; Node, TargetNode: TUniTreeNode;
      X, Y: Integer; var Allow: Boolean);
    procedure btnExpandAllClick(Sender: TObject);
    procedure btnCollapseAllClick(Sender: TObject);
    procedure UniDBGridDblClick(Sender: TObject);
  private
    FQuery: TFDQuery;
    FMenuDM: TMenuDataModule;
    FSelectedMenuID: Integer;
    FNodeMap: TDictionary<Integer, TUniTreeNode>;

    procedure LoadMenus;
    procedure ApplyFilter;
    procedure BuildTree(ParentID: Integer; ParentNode: TUniTreeNode = nil);
    procedure SelectMenu(MenuID: Integer);
    procedure RefreshGrid;
    function GetSelectedNodeID: Integer;
    procedure HandleNodeSelect(Sender: TObject);
    procedure SetupDragDrop;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ExpandAll;
    procedure CollapseAll;
  end;

implementation

{$R *.dfm}

uses
  ComCtrls, MainModule;

constructor TMenuTreeFrame.Create(AOwner: TComponent);
begin
  inherited;
  FPermissionPrefix := 'menu';

  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := ModelAdmin.Connection;

  FSelectedMenuID := 0;
  FNodeMap := TDictionary<Integer, TUniTreeNode>.Create;
end;

destructor TMenuTreeFrame.Destroy;
begin
  FNodeMap.Free;
  FQuery.Free;
  inherited;
end;

procedure TMenuTreeFrame.DoInitialize;
begin
  inherited;

  // 创建菜单数据模块 (使用 Self 作为 Owner，共享会话连接)
  FMenuDM := TMenuDataModule.CreateWithConnection(Self, GetMainModule.Connection);
  FMenuDM.SetContext(Context);

  // 设置数据源
  UniDataSource.DataSet := FQuery;

  // 初始化状态下拉框
  cmbStatus.Items.Clear;
  cmbStatus.Items.Add('全部');
  cmbStatus.Items.Add('启用');
  cmbStatus.Items.Add('禁用');
  cmbStatus.ItemIndex := 0;

  // 设置网格列
  if UniDBGrid.Columns.Count = 0 then
  begin
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'MenuID';
      Title.Caption := 'ID';
      Width := 50;
      Visible := False;
    end;
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'MenuCode';
      Title.Caption := '菜单编码';
      Width := 120;
    end;
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'MenuName';
      Title.Caption := '菜单名称';
      Width := 150;
    end;
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'ParentName';
      Title.Caption := '父菜单';
      Width := 120;
    end;
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'MenuType';
      Title.Caption := '类型';
      Width := 80;
    end;
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'Icon';
      Title.Caption := '图标';
      Width := 100;
    end;
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'Path';
      Title.Caption := '路径';
      Width := 150;
    end;
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'Component';
      Title.Caption := '组件';
      Width := 150;
    end;
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'SortOrder';
      Title.Caption := '排序';
      Width := 60;
    end;
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'Visible';
      Title.Caption := '可见';
      Width := 50;
    end;
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'Status';
      Title.Caption := '状态';
      Width := 50;
    end;
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'ChildCount';
      Title.Caption := '子菜单';
      Width := 60;
    end;
  end;

  SetupDragDrop;
end;

procedure TMenuTreeFrame.DoFinalize;
begin
  if FQuery.Active then
    FQuery.Close;
  inherited;
end;

procedure TMenuTreeFrame.DoRefresh;
begin
  inherited;
  LoadMenus;
end;

procedure TMenuTreeFrame.SetupDragDrop;
begin
  // 启用树形菜单的拖拽功能
  // 注意：TUniTreeMenu 可能通过其他属性配置拖拽，而不是 DragMode
  // 或者通过 AllowDragDrop, DragDropMode 等属性设置
  // 如果 UniGUI 版本支持，请使用适当的属性
end;

procedure TMenuTreeFrame.LoadMenus;
begin
  FNodeMap.Clear;
  treeMenus.Items.Clear;

  // 构建树形结构
  BuildTree(0, nil);
end;

procedure TMenuTreeFrame.BuildTree(ParentID: Integer; ParentNode: TUniTreeNode = nil);
var
  LQuery: TFDQuery;
  LNode: TUniTreeNode;
  LStatus: Integer;
  LStatusFilter: string;
  LSearchFilter: string;
  LWhereParts: TStringList;
  LSQL: string;
begin
  LQuery := TFDQuery.Create(nil);
  LWhereParts := TStringList.Create;
  try
    LQuery.Connection := ModelAdmin.Connection;

    // 构建 SQL
    LSQL := 'SELECT MenuID, MenuCode, MenuName, ParentID, MenuType, Icon, ' +
            'SortOrder, Visible, Status ' +
            'FROM UniAdmin_Menus ';

    // 状态筛选
    if cmbStatus.Text = '启用' then
      LStatus := 1
    else if cmbStatus.Text = '禁用' then
      LStatus := 0
    else
      LStatus := -1;

    if LStatus >= 0 then
      LWhereParts.Add('Status = :Status');

    // 搜索条件
    LSearchFilter := Trim(edtSearch.Text);
    if LSearchFilter <> '' then
      LWhereParts.Add('(MenuCode LIKE :Filter OR MenuName LIKE :Filter)');

    // 父节点条件
    LWhereParts.Add('ParentID = :ParentID');

    // 构建 WHERE 子句
    if LWhereParts.Count > 0 then
      LSQL := LSQL + ' WHERE ' + LWhereParts.Text.Replace(#13#10, ' AND ');

    LSQL := LSQL + ' ORDER BY SortOrder ASC, MenuID ASC';

    LQuery.SQL.Text := LSQL;

    // 设置参数
    if LStatus >= 0 then
      LQuery.ParamByName('Status').AsInteger := LStatus;

    if LSearchFilter <> '' then
      LQuery.ParamByName('Filter').AsString := '%' + LSearchFilter + '%';

    LQuery.ParamByName('ParentID').AsInteger := ParentID;

    LQuery.Open;

    while not LQuery.Eof do
    begin
      if Assigned(ParentNode) then
        LNode := treeMenus.Items.AddChildObject(ParentNode,
          LQuery.FieldByName('MenuName').AsString,
          TObject(LQuery.FieldByName('MenuID').AsInteger))
      else
        LNode := treeMenus.Items.AddChildObject(nil,
          LQuery.FieldByName('MenuName').AsString,
          TObject(LQuery.FieldByName('MenuID').AsInteger));

      // 保存节点映射
      FNodeMap.AddOrSetValue(LQuery.FieldByName('MenuID').AsInteger, LNode);

      // 递归加载子节点
      BuildTree(LQuery.FieldByName('MenuID').AsInteger, LNode);

      LQuery.Next;
    end;
  finally
    LWhereParts.Free;
    LQuery.Free;
  end;
end;

procedure TMenuTreeFrame.ApplyFilter;
begin
  LoadMenus;
  RefreshGrid;
end;

procedure TMenuTreeFrame.SelectMenu(MenuID: Integer);
var
  LNode: TUniTreeNode;
begin
  if FNodeMap.TryGetValue(MenuID, LNode) then
  begin
    treeMenus.Selected := LNode;
    FSelectedMenuID := MenuID;
    RefreshGrid;
  end;
end;

procedure TMenuTreeFrame.RefreshGrid;
var
  LSQL: string;
  LFilter: string;
  LStatus: Integer;
  LWhereParts: TStringList;
begin
  LSQL := 'SELECT m.*, p.MenuName AS ParentName, ' +
          '(SELECT COUNT(*) FROM UniAdmin_Menus WHERE ParentID = m.MenuID) AS ChildCount ' +
          'FROM UniAdmin_Menus m ' +
          'LEFT JOIN UniAdmin_Menus p ON m.ParentID = p.MenuID';

  LFilter := Trim(edtSearch.Text);
  LWhereParts := TStringList.Create;
  try
    if LFilter <> '' then
      LWhereParts.Add('(m.MenuCode LIKE :Filter OR m.MenuName LIKE :Filter)');

    if cmbStatus.Text = '启用' then
      LStatus := 1
    else if cmbStatus.Text = '禁用' then
      LStatus := 0
    else
      LStatus := -1;

    if LStatus >= 0 then
      LWhereParts.Add('m.Status = :Status');

    if FSelectedMenuID > 0 then
      LWhereParts.Add('m.MenuID = :MenuID');

    if LWhereParts.Count > 0 then
      LSQL := LSQL + ' WHERE ' + LWhereParts.Text.Replace(#13#10, ' AND ');

    LSQL := LSQL + ' ORDER BY m.ParentID, m.SortOrder, m.MenuID';

    if FQuery.Active then
      FQuery.Close;

    FQuery.SQL.Text := LSQL;

    if LFilter <> '' then
      FQuery.ParamByName('Filter').AsString := '%' + LFilter + '%';

    if LStatus >= 0 then
      FQuery.ParamByName('Status').AsInteger := LStatus;

    if FSelectedMenuID > 0 then
      FQuery.ParamByName('MenuID').AsInteger := FSelectedMenuID;

    FQuery.Open;
  finally
    LWhereParts.Free;
  end;
end;

function TMenuTreeFrame.GetSelectedNodeID: Integer;
begin
  Result := 0;
  if Assigned(treeMenus.Selected) and Assigned(treeMenus.Selected.Data) then
    Result := Integer(treeMenus.Selected.Data);
end;

procedure TMenuTreeFrame.HandleNodeSelect(Sender: TObject);
begin
  FSelectedMenuID := GetSelectedNodeID;
  RefreshGrid;
end;

procedure TMenuTreeFrame.btnSearchClick(Sender: TObject);
begin
  ApplyFilter;
end;

procedure TMenuTreeFrame.edtSearchKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    ApplyFilter;
end;

procedure TMenuTreeFrame.cmbStatusChange(Sender: TObject);
begin
  ApplyFilter;
end;

procedure TMenuTreeFrame.treeMenusClick(Sender: TObject);
begin
  HandleNodeSelect(Sender);
end;

procedure TMenuTreeFrame.treeMenusDragDrop(Sender: TObject; Node, TargetNode: TUniTreeNode;
  var Allow: Boolean);
var
  LMenuID, LTargetParentID: Integer;
  LMenuDM: TMenuDataModule;
begin
  if not Assigned(Node) or not Assigned(TargetNode) then
    Exit;

  LMenuID := Integer(Node.Data);
  LTargetParentID := Integer(TargetNode.Data);

  if LMenuID = LTargetParentID then
    Exit;

  // 执行移动
  try
    LMenuDM := TMenuDataModule.CreateWithConnection(Self, GetMainModule.Connection);
    LMenuDM.SetContext(Context);
    try
      LMenuDM.MoveMenu(LMenuID, LTargetParentID, -1);

      // 刷新显示
      LoadMenus;
      SelectMenu(LMenuID);
    finally
      LMenuDM.Free;
    end;

    ShowMessage('菜单移动成功');
  except
    on E: Exception do
    begin
      ShowMessage('菜单移动失败: ' + E.Message);
    end;
  end;
end;

procedure TMenuTreeFrame.treeMenusDragOver(Sender: TObject; Node, TargetNode: TUniTreeNode;
  X, Y: Integer; var Allow: Boolean);
begin
  // 不允许将节点拖到自己或自己的子节点下
  Allow := Assigned(Node) and Assigned(TargetNode) and (Node <> TargetNode);

  // TODO: 检查 TargetNode 是否是 Node 的子节点
end;

procedure TMenuTreeFrame.btnExpandAllClick(Sender: TObject);
begin
  ExpandAll;
end;

procedure TMenuTreeFrame.btnCollapseAllClick(Sender: TObject);
begin
  CollapseAll;
end;

procedure TMenuTreeFrame.ExpandAll;
var
  LNode: TUniTreeNode;
begin
  if not Assigned(treeMenus) then
    Exit;

  LNode := treeMenus.Items.GetFirstNode;
  while Assigned(LNode) do
  begin
    LNode.Expand(True);
    LNode := LNode.getNextSibling;
  end;
end;

procedure TMenuTreeFrame.CollapseAll;
var
  LNode: TUniTreeNode;
begin
  if not Assigned(treeMenus) then
    Exit;

  LNode := treeMenus.Items.GetFirstNode;
  while Assigned(LNode) do
  begin
    LNode.Collapse(True);
    LNode := LNode.getNextSibling;
  end;
end;

procedure TMenuTreeFrame.UniDBGridDblClick(Sender: TObject);
begin
  // 双击编辑
  if Assigned(BtnEdit) and BtnEdit.Enabled and BtnEdit.Visible then
    BtnEditClick(nil);
end;

initialization
  // Register for FindClass-driven MDI routing (UniAdmin_Menus.RoutePath -> frame)
  RegisterClass(TMenuTreeFrame);

end.

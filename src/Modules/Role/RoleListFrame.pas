unit RoleListFrame;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.UITypes,
  Data.DB, FireDAC.Comp.Client,
  uniGUIBaseClasses, uniGUIClasses, uniGUImClasses, uniEdit, uniButton, uniBasicGrid, uniDBGrid, uniToolBar, uniPanel,
  uniMultiItem, uniComboBox, uniLabel, uniGUIApplication,
  UniContext, UniPlugin.Types, UniModelAdmin,
  BaseCrudFrame, RoleDataModule,
  RolePermissionDialog, RoleUserDialog, Vcl.Dialogs;

type
  /// <summary>
  /// 角色列表窗体 - 继承自 TBaseCrudFrame
  /// 提供角色管理的列表显示、搜索、筛选和 CRUD 操作
  /// </summary>
  TRoleListFrame = class(TBaseCrudFrame)
    pnlSearch: TUniPanel;
    lblSearch: TUniLabel;
    edtSearch: TUniEdit;
    cmbStatus: TUniComboBox;
    btnSearch: TUniButton;
    UniDBGrid: TUniDBGrid;
    UniDataSource: TDataSource;

    procedure DoInitialize; override;
    procedure DoFinalize; override;
    procedure DoRefresh; override;

    procedure btnSearchClick(Sender: TObject);
    procedure edtSearchKeyPress(Sender: TObject; var Key: Char);
    procedure cmbStatusChange(Sender: TObject);
    procedure UniDBGridDblClick(Sender: TObject);
  private
    FQuery: TFDQuery;
    FRoleDM: TRoleDataModule;
    FSelectedRoleID: Integer;
    FAdditionalButtons: array[0..1] of TUniButton; // 权限、用户按钮

    procedure LoadRoles;
    procedure ApplyFilter;
    procedure SetupAdditionalButtons;
    procedure BtnPermissionClick(Sender: TObject);
    procedure BtnUserClick(Sender: TObject);
    function GetSelectedRoleID: Integer;
    function GetStatusText(Status: Integer): string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure OpenPermissionDialog;
    procedure OpenUserDialog;
  end;

implementation

{$R *.dfm}

constructor TRoleListFrame.Create(AOwner: TComponent);
begin
  inherited;
  FPermissionPrefix := 'role';

  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := ModelAdmin.Connection;

  // 创建额外的按钮引用
  FAdditionalButtons[0] := nil; // 权限按钮
  FAdditionalButtons[1] := nil; // 用户按钮
end;

destructor TRoleListFrame.Destroy;
begin
  FQuery.Free;
  inherited;
end;

procedure TRoleListFrame.DoInitialize;
begin
  inherited;

  // 创建角色数据模块
  FRoleDM := TRoleDataModule.Create(Self);
  FRoleDM.SetContext(Context);

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
      FieldName := 'RoleID';
      Title.Caption := 'ID';
      Width := 50;
      Visible := False;
    end;
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'RoleCode';
      Title.Caption := '角色编码';
      Width := 100;
    end;
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'RoleName';
      Title.Caption := '角色名称';
      Width := 120;
    end;
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'Description';
      Title.Caption := '描述';
      Width := 200;
    end;
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'DataScope';
      Title.Caption := '数据范围';
      Width := 80;
    end;
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'StatusText';
      Title.Caption := '状态';
      Width := 60;
    end;
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'UserCount';
      Title.Caption := '用户数';
      Width := 60;
    end;
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'PermissionCount';
      Title.Caption := '权限数';
      Width := 60;
    end;
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'SortOrder';
      Title.Caption := '排序';
      Width := 50;
    end;
  end;

  // 设置额外按钮
  SetupAdditionalButtons;
end;

procedure TRoleListFrame.DoFinalize;
begin
  if FQuery.Active then
    FQuery.Close;
  inherited;
end;

procedure TRoleListFrame.DoRefresh;
begin
  inherited;
  LoadRoles;
end;

procedure TRoleListFrame.SetupAdditionalButtons;
begin
  // 在工具栏上添加权限和用户按钮
  if Assigned(UniToolBar) then
  begin
    // 权限按钮
    FAdditionalButtons[0] := TUniButton.Create(Self);
    FAdditionalButtons[0].Parent := UniToolBar;
    FAdditionalButtons[0].Caption := '权限';
    FAdditionalButtons[0].Hint := '管理角色权限';
    FAdditionalButtons[0].OnClick := BtnPermissionClick;

    // 用户按钮
    FAdditionalButtons[1] := TUniButton.Create(Self);
    FAdditionalButtons[1].Parent := UniToolBar;
    FAdditionalButtons[1].Caption := '用户';
    FAdditionalButtons[1].Hint := '管理角色用户';
    FAdditionalButtons[1].OnClick := BtnUserClick;
  end;
end;

procedure TRoleListFrame.LoadRoles;
var
  LSQL: string;
  LFilter: string;
  LStatus: Integer;
  LWhereParts: TStringList;
begin
  LSQL := 'SELECT r.RoleID, r.RoleCode, r.RoleName, r.Description, r.DataScope, r.Status, ' +
          'r.SortOrder, r.CreatedDate, r.ModifiedDate, ' +
          'CASE WHEN r.Status = 1 THEN ''启用'' ELSE ''禁用'' END AS StatusText, ' +
          '(SELECT COUNT(*) FROM UniAdmin_UserRoles ur WHERE ur.RoleID = r.RoleID) AS UserCount, ' +
          '(SELECT COUNT(*) FROM UniAdmin_RolePermissions rp WHERE rp.RoleID = r.RoleID) AS PermissionCount ' +
          'FROM UniAdmin_Roles r';

  LFilter := Trim(edtSearch.Text);
  LWhereParts := TStringList.Create;
  try
    // 搜索条件
    if LFilter <> '' then
      LWhereParts.Add('(r.RoleCode LIKE :Filter OR r.RoleName LIKE :Filter OR r.Description LIKE :Filter)');

    // 状态筛选
    if cmbStatus.Text = '启用' then
      LStatus := 1
    else if cmbStatus.Text = '禁用' then
      LStatus := 0
    else
      LStatus := -1;

    if LStatus >= 0 then
      LWhereParts.Add('r.Status = :Status');

    // 构建 WHERE 子句
    if LWhereParts.Count > 0 then
      LSQL := LSQL + ' WHERE ' + LWhereParts.Text.Replace(#13#10, ' AND ');

    LSQL := LSQL + ' ORDER BY r.SortOrder ASC, r.RoleID ASC';

    // 执行查询
    if FQuery.Active then
      FQuery.Close;

    FQuery.SQL.Text := LSQL;

    if LFilter <> '' then
      FQuery.ParamByName('Filter').AsString := '%' + LFilter + '%';

    if LStatus >= 0 then
      FQuery.ParamByName('Status').AsInteger := LStatus;

    FQuery.Open;
  finally
    LWhereParts.Free;
  end;
end;

procedure TRoleListFrame.ApplyFilter;
begin
  LoadRoles;
end;

function TRoleListFrame.GetSelectedRoleID: Integer;
begin
  Result := 0;
  if Assigned(FQuery) and FQuery.Active and not FQuery.Eof then
    Result := FQuery.FieldByName('RoleID').AsInteger;
end;

function TRoleListFrame.GetStatusText(Status: Integer): string;
begin
  if Status = 1 then
    Result := '启用'
  else
    Result := '禁用';
end;

procedure TRoleListFrame.btnSearchClick(Sender: TObject);
begin
  ApplyFilter;
end;

procedure TRoleListFrame.edtSearchKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    ApplyFilter;
end;

procedure TRoleListFrame.cmbStatusChange(Sender: TObject);
begin
  ApplyFilter;
end;

procedure TRoleListFrame.UniDBGridDblClick(Sender: TObject);
begin
  // 双击编辑
  if Assigned(BtnEdit) and BtnEdit.Enabled and BtnEdit.Visible then
    BtnEditClick(nil);
end;

procedure TRoleListFrame.BtnPermissionClick(Sender: TObject);
var
  LRoleID: Integer;
begin
  LRoleID := GetSelectedRoleID;
  if LRoleID = 0 then
  begin
    ShowMessage('请先选择一个角色');
    Exit;
  end;

  // 检查权限
  if Assigned(Context) and not Context.GetUserContext.HasPermission('role:edit') then
  begin
    ShowMessage('没有权限管理角色权限');
    Exit;
  end;

  try
    OpenPermissionDialog;
  except
    on E: Exception do
    begin
      ShowMessage('打开权限对话框失败: ' + E.Message);
    end;
  end;
end;

procedure TRoleListFrame.BtnUserClick(Sender: TObject);
var
  LRoleID: Integer;
begin
  LRoleID := GetSelectedRoleID;
  if LRoleID = 0 then
  begin
    ShowMessage('请先选择一个角色');
    Exit;
  end;

  // 检查权限
  if Assigned(Context) and not Context.GetUserContext.HasPermission('role:edit') then
  begin
    ShowMessage('没有权限管理角色用户');
    Exit;
  end;

  try
    OpenUserDialog;
  except
    on E: Exception do
    begin
      ShowMessage('打开用户对话框失败: ' + E.Message);
    end;
  end;
end;

procedure TRoleListFrame.OpenPermissionDialog;
var
  LDialog: TRolePermissionDialog;
  LRoleInfo: TDataSet;
  LRoleName: string;
begin
  try
    LDialog := TRolePermissionDialog.Create(UniApplication);
    try
      LDialog.SetContext(Context);
      LDialog.SetConnection(TFDConnection(ModelAdmin.Connection));

      // 获取角色名称
      LRoleInfo := FRoleDM.GetRoleByID(FSelectedRoleID);
      try
        if not LRoleInfo.Eof then
          LRoleName := LRoleInfo.FieldByName('RoleName').AsString
        else
          LRoleName := '未知角色';
      finally
        LRoleInfo.Free;
      end;

      LDialog.SetRole(FSelectedRoleID, LRoleName);

      if LDialog.Execute then
      begin
        // 刷新列表
        LoadRoles;
      end;
    finally
      LDialog.Free;
    end;
  except
    on E: Exception do
    begin
      ShowMessage('打开权限对话框失败: ' + E.Message);
    end;
  end;
end;

procedure TRoleListFrame.OpenUserDialog;
var
  LDialog: TRoleUserDialog;
  LRoleInfo: TDataSet;
  LRoleName: string;
begin
  try
    LDialog := TRoleUserDialog.Create(UniApplication);
    try
      LDialog.SetContext(Context);
      LDialog.SetConnection(TFDConnection(ModelAdmin.Connection));

      // 获取角色名称
      LRoleInfo := FRoleDM.GetRoleByID(FSelectedRoleID);
      try
        if not LRoleInfo.Eof then
          LRoleName := LRoleInfo.FieldByName('RoleName').AsString
        else
          LRoleName := '未知角色';
      finally
        LRoleInfo.Free;
      end;

      LDialog.SetRole(FSelectedRoleID, LRoleName);

      if LDialog.Execute then
      begin
        // 刷新列表
        LoadRoles;
      end;
    finally
      LDialog.Free;
    end;
  except
    on E: Exception do
    begin
      ShowMessage('打开用户对话框失败: ' + E.Message);
    end;
  end;
end;

end.

unit RoleEditForm;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.UITypes, System.Types,
  Data.DB, Vcl.Forms,
  uniGUIBaseClasses, uniGUIClasses, uniGUImClasses, uniEdit, uniButton, uniLabel, uniMultiItem, uniComboBox, uniPanel, uniSpinEdit,
  UniContext, UniPlugin.Types, uniGUIForm, Vcl.Dialogs,
  RoleDataModule, uniCheckBox, uniMemo, Vcl.Controls;

type
  /// <summary>
  /// 编辑模式枚举
  /// </summary>
  TEditMode = (emAdd, emEdit);

  /// <summary>
  /// 角色编辑窗体 - 新增和编辑角色
  /// </summary>
  TRoleEditForm = class(TUniForm)
    pnlMain: TUniPanel;
    lblRoleCode: TUniLabel;
    edtRoleCode: TUniEdit;
    lblRoleName: TUniLabel;
    edtRoleName: TUniEdit;
    lblDescription: TUniLabel;
    memDescription: TUniMemo;
    lblDataScope: TUniLabel;
    cmbDataScope: TUniComboBox;
    lblSortOrder: TUniLabel;
    spnSortOrder: TUniSpinEdit;
    lblStatus: TUniLabel;
    chkStatus: TUniCheckBox;
    pnlBottom: TUniPanel;
    btnSave: TUniButton;
    btnCancel: TUniButton;

    procedure btnSaveClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FRoleID: Integer;
    FMode: TEditMode;
    FContext: IExecutionContext;
    FRoleDM: TRoleDataModule;
    FRequiredPermission: string;

    procedure ValidateInputs;
    procedure InitForm;
    procedure LoadRole(RoleID: Integer);
    procedure ClearForm;
    function GetDataScopeText(const Scope: string): string;
    function GetDataScopeValue(const Text: string): string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetContext(const Context: IExecutionContext);
    procedure SetAsAddMode;
    procedure SetAsEditMode(RoleID: Integer);
    procedure SetRequiredPermission(const Permission: string);
  end;

implementation

{$R *.dfm}

uses
  UniFormStyler;

constructor TRoleEditForm.Create(AOwner: TComponent);
begin
  inherited;
  FRoleID := 0;
  FMode := emAdd;
  FRequiredPermission := 'role:add'; // 默认权限
end;

destructor TRoleEditForm.Destroy;
begin
  inherited;
end;

procedure TRoleEditForm.SetContext(const Context: IExecutionContext);
begin
  FContext := Context;
  FRoleDM := TRoleDataModule.Create(Self);
  FRoleDM.SetContext(Context);
end;

procedure TRoleEditForm.SetRequiredPermission(const Permission: string);
begin
  FRequiredPermission := Permission;
end;

procedure TRoleEditForm.FormCreate(Sender: TObject);
begin
  TUniFormStyler.AutoStylePanels(Self);
  TUniFormStyler.AutoStyleButtons(Self);
  InitForm;
end;

procedure TRoleEditForm.FormShow(Sender: TObject);
begin
  // 检查权限
  if Assigned(FContext) and not FContext.GetUserContext.HasPermission(FRequiredPermission) then
  begin
    ShowMessage('没有权限执行此操作');
    ModalResult := mrCancel;
    Exit;
  end;
end;

procedure TRoleEditForm.InitForm;
begin
  // 初始化数据范围下拉框
  cmbDataScope.Items.Clear;
  cmbDataScope.Items.Add('全部');      // all
  cmbDataScope.Items.Add('本部门');   // dept
  cmbDataScope.Items.Add('仅本人');   // self
  cmbDataScope.Items.Add('自定义');   // custom
  cmbDataScope.ItemIndex := 0;

  // 初始化状态复选框
  chkStatus.Checked := True;

  // 设置默认排序
  spnSortOrder.Value := 0;
  spnSortOrder.MinValue := 0;
  spnSortOrder.MaxValue := 9999;

  // 设置默认模式
  SetAsAddMode;
end;

procedure TRoleEditForm.ClearForm;
begin
  edtRoleCode.Text := '';
  edtRoleName.Text := '';
  memDescription.Text := '';
  cmbDataScope.ItemIndex := 0;
  spnSortOrder.Value := 0;
  chkStatus.Checked := True;

  edtRoleCode.Enabled := True;
end;

procedure TRoleEditForm.SetAsAddMode;
begin
  FMode := emAdd;
  FRoleID := 0;
  FRequiredPermission := 'role:add';

  Caption := '新增角色';
  ClearForm;
end;

procedure TRoleEditForm.SetAsEditMode(RoleID: Integer);
begin
  FMode := emEdit;
  FRoleID := RoleID;
  FRequiredPermission := 'role:edit';

  Caption := '编辑角色';

  // 加载角色数据
  LoadRole(RoleID);

  // 编辑模式下角色编码不允许修改
  edtRoleCode.Enabled := False;
end;

procedure TRoleEditForm.LoadRole(RoleID: Integer);
var
  LDataSet: TDataSet;
begin
  try
    LDataSet := FRoleDM.GetRoleByID(RoleID);
    try
      if not LDataSet.Eof then
      begin
        edtRoleCode.Text := LDataSet.FieldByName('RoleCode').AsString;
        edtRoleName.Text := LDataSet.FieldByName('RoleName').AsString;
        memDescription.Text := LDataSet.FieldByName('Description').AsString;

        // 设置数据范围
        cmbDataScope.ItemIndex := cmbDataScope.Items.IndexOf(GetDataScopeText(LDataSet.FieldByName('DataScope').AsString));
        if cmbDataScope.ItemIndex < 0 then
          cmbDataScope.ItemIndex := 0;

        spnSortOrder.Value := LDataSet.FieldByName('SortOrder').AsInteger;

        // 设置状态
        chkStatus.Checked := LDataSet.FieldByName('Status').AsInteger = 1;
      end
      else
      begin
        ShowMessage('角色不存在');
        ModalResult := mrCancel;
      end;
    finally
      LDataSet.Free;
    end;
  except
    on E: Exception do
    begin
      ShowMessage('加载角色数据失败: ' + E.Message);
      ModalResult := mrCancel;
    end;
  end;
end;

function TRoleEditForm.GetDataScopeText(const Scope: string): string;
begin
  if Scope = 'all' then
    Result := '全部'
  else if Scope = 'dept' then
    Result := '本部门'
  else if Scope = 'self' then
    Result := '仅本人'
  else if Scope = 'custom' then
    Result := '自定义'
  else
    Result := '全部'; // 默认值
end;

function TRoleEditForm.GetDataScopeValue(const Text: string): string;
begin
  if Text = '全部' then
    Result := 'all'
  else if Text = '本部门' then
    Result := 'dept'
  else if Text = '仅本人' then
    Result := 'self'
  else if Text = '自定义' then
    Result := 'custom'
  else
    Result := 'all'; // 默认值
end;

procedure TRoleEditForm.ValidateInputs;
var
  LRoleCode, LRoleName, LDescription: string;
  LDataScope: string;
  LSortOrder: Integer;
  LDataSet: TDataSet;
begin
  LRoleCode := Trim(edtRoleCode.Text);
  LRoleName := Trim(edtRoleName.Text);
  LDescription := Trim(memDescription.Text);
  LDataScope := GetDataScopeValue(cmbDataScope.Text);
  LSortOrder := Trunc(spnSortOrder.Value);

  // 角色编码验证
  if LRoleCode = '' then
    raise Exception.Create('角色编码不能为空');

  if Length(LRoleCode) < 2 then
    raise Exception.Create('角色编码长度不能少于 2 位');

  if Length(LRoleCode) > 50 then
    raise Exception.Create('角色编码长度不能超过 50 位');

  // 角色编码格式验证（只允许字母、数字、下划线）
  if not System.SysUtils.IsValidIdent(LRoleCode) then
    raise Exception.Create('角色编码只能包含字母、数字和下划线，且必须以字母开头');

  // 角色名称验证
  if LRoleName = '' then
    raise Exception.Create('角色名称不能为空');

  if Length(LRoleName) > 100 then
    raise Exception.Create('角色名称长度不能超过 100 位');

  // 描述验证
  if Length(LDescription) > 500 then
    raise Exception.Create('描述长度不能超过 500 位');

  // 排序值验证
  if (LSortOrder < 0) or (LSortOrder > 9999) then
    raise Exception.Create('排序值必须在 0 到 9999 之间');

  // 数据范围验证（由下拉框保证，不需要额外验证）

  // 角色编码唯一性检查（新增模式）
  if FMode = emAdd then
  begin
    LDataSet := FRoleDM.GetRoleByCode(LRoleCode);
    try
      if not LDataSet.Eof then
        raise Exception.Create('角色编码已存在');
    finally
      LDataSet.Free;
    end;
  end;
end;

procedure TRoleEditForm.btnSaveClick(Sender: TObject);
var
  LRoleCode, LRoleName, LDescription, LDataScope: string;
  LSortOrder, LStatus: Integer;
  LNewRoleID: Integer;
begin
  try
    // 验证输入
    ValidateInputs;

    // 获取输入值
    LRoleCode := Trim(edtRoleCode.Text);
    LRoleName := Trim(edtRoleName.Text);
    LDescription := Trim(memDescription.Text);
    LDataScope := GetDataScopeValue(cmbDataScope.Text);
    LSortOrder := Trunc(spnSortOrder.Value);

    if chkStatus.Checked then
      LStatus := 1
    else
      LStatus := 0;

    // 执行操作
    if FMode = emAdd then
    begin
      LNewRoleID := FRoleDM.CreateRole(LRoleCode, LRoleName, LDescription, LDataScope, LSortOrder);
      ShowMessage('角色创建成功');
      FRoleID := LNewRoleID;
    end
    else
    begin
      FRoleDM.UpdateRole(FRoleID, LRoleName, LDescription, LDataScope, LSortOrder, LStatus);
      ShowMessage('角色更新成功');
    end;

    ModalResult := mrOK;
  except
    on E: Exception do
    begin
      ShowMessage('操作失败: ' + E.Message);
    end;
  end;
end;

procedure TRoleEditForm.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.

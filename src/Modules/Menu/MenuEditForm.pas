unit MenuEditForm;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Generics.Collections,
  System.RegularExpressions, System.UITypes, System.Math,
  uniGUIBaseClasses, uniGUIClasses, uniGUImClasses, uniEdit, uniButton, uniLabel,
  uniComboBox, uniPanel, uniCheckBox, uniGUIForm, UniMemo, UniSpinEdit,
  UniContext, UniPlugin.Types,
  IconSelector, uniMultiItem, Vcl.Controls, Vcl.Forms;

type
  /// <summary>
  /// 菜单编辑窗体 - 新增和编辑菜单
  /// </summary>
  TMenuEditForm = class(TUniForm)
    pnlMain: TUniPanel;
    lblMenuCode: TUniLabel;
    edtMenuCode: TUniEdit;
    lblMenuName: TUniLabel;
    edtMenuName: TUniEdit;
    lblParent: TUniLabel;
    cmbParent: TUniComboBox;
    lblMenuType: TUniLabel;
    cmbMenuType: TUniComboBox;
    lblIcon: TUniLabel;
    edtIcon: TUniEdit;
    btnSelectIcon: TUniButton;
    lblPath: TUniLabel;
    edtPath: TUniEdit;
    lblComponent: TUniLabel;
    edtComponent: TUniEdit;
    lblPermission: TUniLabel;
    edtPermission: TUniEdit;
    lblSortOrder: TUniLabel;
    spnSortOrder: TUniSpinEdit;
    lblVisible: TUniLabel;
    chkVisible: TUniCheckBox;
    lblDescription: TUniLabel;
    memDescription: TUniMemo;
    lblStatus: TUniLabel;
    chkStatus: TUniCheckBox;

    procedure btnSaveClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnSelectIconClick(Sender: TObject);
    procedure cmbMenuTypeChange(Sender: TObject);
  private
    FMenuID: Integer;
    FMode: string; // 'add' 或 'edit'
    FContext: IExecutionContext;
    FParentMenus: TList<TPair<Integer, string>>;

    procedure ValidateInputs;
    procedure InitForm;
    procedure LoadParentMenus;
    procedure LoadMenu(MenuID: Integer);
    function GetMenuTypeID: string;
    function GetSelectedParentID: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetContext(const Context: IExecutionContext);
    procedure SetAsAddMode(ParentID: Integer = 0);
    procedure SetAsEditMode(MenuID: Integer);
  end;

implementation

{$R *.dfm}

uses
  Data.DB, FireDAC.Comp.Client,
  MenuDataModule, UniFormStyler, MainModule;

var
  MenuDataModule: TMenuDataModule;

constructor TMenuEditForm.Create(AOwner: TComponent);
begin
  inherited;
  FMenuID := 0;
  FMode := 'add';
  FParentMenus := TList<TPair<Integer, string>>.Create;
end;

destructor TMenuEditForm.Destroy;
begin
  FParentMenus.Free;
  inherited;
end;

procedure TMenuEditForm.SetContext(const Context: IExecutionContext);
begin
  FContext := Context;
  MenuDataModule := TMenuDataModule.CreateWithConnection(nil, GetMainModule.Connection);
  if Supports(MenuDataModule, IContextAware) then
    (MenuDataModule as IContextAware).SetContext(Context);
  MenuDataModule.Open;
end;

procedure TMenuEditForm.FormCreate(Sender: TObject);
begin
  TUniFormStyler.AutoStylePanels(Self);
  TUniFormStyler.AutoStyleButtons(Self);
  InitForm;
end;

procedure TMenuEditForm.InitForm;
begin
  // 初始化菜单类型下拉框
  cmbMenuType.Items.Clear;
  cmbMenuType.Items.Add('directory'); // 目录
  cmbMenuType.Items.Add('menu');      // 菜单
  cmbMenuType.Items.Add('button');    // 按钮
  cmbMenuType.ItemIndex := 0;

  // 初始化复选框
  chkVisible.Checked := True;
  chkStatus.Checked := True;

  // 初始化排序
  spnSortOrder.Value := 0;
  spnSortOrder.MinValue := 0;
  spnSortOrder.MaxValue := 9999;

  // 加载父菜单列表
  LoadParentMenus;
end;

procedure TMenuEditForm.LoadParentMenus;
var
  LQuery: TFDQuery;
begin
  FParentMenus.Clear;
  cmbParent.Items.Clear;
  cmbParent.Items.Add('(无)'); // 根节点
  FParentMenus.Add(TPair<Integer, string>.Create(0, '(无)'));

  if not Assigned(MenuDataModule) or not MenuDataModule.Connection.Connected then
    Exit;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := MenuDataModule.Connection;
    LQuery.SQL.Text :=
      'SELECT MenuID, MenuName, ParentID ' +
      'FROM UniAdmin_Menus ' +
      'WHERE Status = 1 ' +
      'ORDER BY ParentID, SortOrder, MenuName';

    LQuery.Open;

    while not LQuery.Eof do
    begin
      // 编辑模式下，不显示当前菜单及其子菜单作为父节点选项
      if (FMode = 'edit') and (LQuery.FieldByName('MenuID').AsInteger = FMenuID) then
      begin
        LQuery.Next;
        Continue;
      end;

      FParentMenus.Add(
        TPair<Integer, string>.Create(
          LQuery.FieldByName('MenuID').AsInteger,
          LQuery.FieldByName('MenuName').AsString
        )
      );

      cmbParent.Items.Add(LQuery.FieldByName('MenuName').AsString);
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;

  cmbParent.ItemIndex := 0;
end;

procedure TMenuEditForm.SetAsAddMode(ParentID: Integer);
var
  I: Integer;
begin
  FMode := 'add';
  FMenuID := 0;

  Caption := '新增菜单';

  edtMenuCode.Text := '';
  edtMenuCode.Enabled := True;
  edtMenuName.Text := '';
  cmbMenuType.ItemIndex := 0;
  edtIcon.Text := '';
  edtPath.Text := '';
  edtComponent.Text := '';
  edtPermission.Text := '';
  spnSortOrder.Value := 0;
  chkVisible.Checked := True;
  chkStatus.Checked := True;
  memDescription.Lines.Clear;

  // 设置默认父节点
  for I := 0 to FParentMenus.Count - 1 do
  begin
    if FParentMenus[I].Key = ParentID then
    begin
      cmbParent.ItemIndex := I;
      Break;
    end;
  end;
end;

procedure TMenuEditForm.SetAsEditMode(MenuID: Integer);
var
  I: Integer;
begin
  FMode := 'edit';
  FMenuID := MenuID;

  Caption := '编辑菜单';

  // 重新加载父菜单（排除当前菜单）
  LoadParentMenus;

  // 加载菜单数据
  LoadMenu(MenuID);
end;

procedure TMenuEditForm.LoadMenu(MenuID: Integer);
var
  LDataSet: TDataSet;
  I: Integer;
begin
  if not Assigned(MenuDataModule) then
    Exit;

  LDataSet := MenuDataModule.GetMenuByID(MenuID);
  try
    if LDataSet.Eof then
      raise Exception.CreateFmt('菜单 ID %d 不存在', [MenuID]);

    edtMenuCode.Text := LDataSet.FieldByName('MenuCode').AsString;
    edtMenuCode.Enabled := False; // 菜单编码不允许修改
    edtMenuName.Text := LDataSet.FieldByName('MenuName').AsString;

    // 设置菜单类型
    for I := 0 to cmbMenuType.Items.Count - 1 do
    begin
      if cmbMenuType.Items[I] = LDataSet.FieldByName('MenuType').AsString then
      begin
        cmbMenuType.ItemIndex := I;
        Break;
      end;
    end;

    edtIcon.Text := LDataSet.FieldByName('Icon').AsString;
    edtPath.Text := LDataSet.FieldByName('Path').AsString;
    edtComponent.Text := LDataSet.FieldByName('Component').AsString;
    edtPermission.Text := LDataSet.FieldByName('Permission').AsString;
    spnSortOrder.Value := LDataSet.FieldByName('SortOrder').AsInteger;
    chkVisible.Checked := LDataSet.FieldByName('Visible').AsInteger = 1;
    chkStatus.Checked := LDataSet.FieldByName('Status').AsInteger = 1;

    if not LDataSet.FieldByName('Description').IsNull then
      memDescription.Text := LDataSet.FieldByName('Description').AsString;

    // 设置父节点
    for I := 0 to FParentMenus.Count - 1 do
    begin
      if FParentMenus[I].Key = LDataSet.FieldByName('ParentID').AsInteger then
      begin
        cmbParent.ItemIndex := I;
        Break;
      end;
    end;
  finally
    LDataSet.Free;
  end;
end;

function TMenuEditForm.GetMenuTypeID: string;
begin
  case cmbMenuType.ItemIndex of
    0: Result := 'directory';
    1: Result := 'menu';
    2: Result := 'button';
    else
      Result := 'directory';
  end;
end;

function TMenuEditForm.GetSelectedParentID: Integer;
begin
  if (cmbParent.ItemIndex >= 0) and (cmbParent.ItemIndex < FParentMenus.Count) then
    Result := FParentMenus[cmbParent.ItemIndex].Key
  else
    Result := 0;
end;

procedure TMenuEditForm.ValidateInputs;
var
  LMenuCode, LMenuName: string;
begin
  LMenuCode := Trim(edtMenuCode.Text);
  LMenuName := Trim(edtMenuName.Text);

  // 菜单编码验证
  if LMenuCode = '' then
    raise Exception.Create('菜单编码不能为空');

  if Length(LMenuCode) < 2 then
    raise Exception.Create('菜单编码长度不能少于 2 位');

  if Length(LMenuCode) > 50 then
    raise Exception.Create('菜单编码长度不能超过 50 位');

  if not TRegEx.IsMatch(LMenuCode, '^[a-zA-Z0-9_-]+$') then
    raise Exception.Create('菜单编码只能包含字母、数字、下划线和连字符');

  // 菜单名称验证
  if LMenuName = '' then
    raise Exception.Create('菜单名称不能为空');

  if Length(LMenuName) > 100 then
    raise Exception.Create('菜单名称长度不能超过 100 位');

  // 根据菜单类型进行特定验证
  if GetMenuTypeID = 'menu' then
  begin
    if Trim(edtPath.Text) = '' then
      raise Exception.Create('菜单类型为菜单时，路径不能为空');
  end;

  if GetMenuTypeID = 'button' then
  begin
    if Trim(edtPermission.Text) = '' then
      raise Exception.Create('菜单类型为按钮时，权限标识不能为空');
  end;
end;

procedure TMenuEditForm.btnSaveClick(Sender: TObject);
var
  LMenuCode, LMenuName, LIcon, LPath, LComponent, LPermission: string;
  LParentID: Integer;
  LMenuType: string;
  LSortOrder: Integer;
  LVisible, LStatus: Integer;
begin
  try
    // 验证输入
    ValidateInputs;

    // 获取输入值
    LMenuCode := Trim(edtMenuCode.Text);
    LMenuName := Trim(edtMenuName.Text);
    LIcon := Trim(edtIcon.Text);
    LPath := Trim(edtPath.Text);
    LComponent := Trim(edtComponent.Text);
    LPermission := Trim(edtPermission.Text);
    LParentID := GetSelectedParentID;
    LMenuType := GetMenuTypeID;
    LSortOrder := Integer(spnSortOrder.Value);
    LVisible := IfThen(chkVisible.Checked, 1, 0);
    LStatus := IfThen(chkStatus.Checked, 1, 0);

    // 执行操作
    if FMode = 'add' then
    begin
      MenuDataModule.CreateMenu(
        LMenuCode, LMenuName, LParentID,
        LMenuType, LIcon, LPath, LComponent, LPermission,
        LSortOrder
      );
      ShowMessage('菜单创建成功');
    end
    else
    begin
      MenuDataModule.UpdateMenu(
        FMenuID, LMenuName, LIcon, LPath, LPermission,
        LComponent, LSortOrder, LVisible, LStatus
      );
      ShowMessage('菜单更新成功');
    end;

    ModalResult := mrOK;
  except
    on E: Exception do
    begin
      ShowMessage('操作失败: ' + E.Message);
    end;
  end;
end;

procedure TMenuEditForm.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TMenuEditForm.btnSelectIconClick(Sender: TObject);
var
  LIconSelector: TIconSelector;
  LSelectedIcon: string;
begin
  try
    LIconSelector := TIconSelector.Create(UniApplication);
    try
      LIconSelector.SetContext(FContext);
      LSelectedIcon := LIconSelector.Execute(edtIcon.Text);

      if LSelectedIcon <> '' then
      begin
        edtIcon.Text := LSelectedIcon;
      end;
    finally
      LIconSelector.Free;
    end;
  except
    on E: Exception do
    begin
      ShowMessage('打开图标选择器失败: ' + E.Message);
    end;
  end;
end;

procedure TMenuEditForm.cmbMenuTypeChange(Sender: TObject);
var
  LMenuType: string;
begin
  LMenuType := GetMenuTypeID;

  // 根据菜单类型显示/隐藏相关字段
  if LMenuType = 'directory' then
  begin
    edtPath.Enabled := False;
    edtComponent.Enabled := False;
    edtPermission.Enabled := False;
    edtPath.Text := '';
    edtComponent.Text := '';
    edtPermission.Text := '';
  end
  else if LMenuType = 'menu' then
  begin
    edtPath.Enabled := True;
    edtComponent.Enabled := True;
    edtPermission.Enabled := False;
    edtPermission.Text := '';
  end
  else if LMenuType = 'button' then
  begin
    edtPath.Enabled := False;
    edtComponent.Enabled := False;
    edtPermission.Enabled := True;
    edtPath.Text := '';
    edtComponent.Text := '';
  end;
end;

end.

unit RolePermissionDialog;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Generics.Collections, System.UITypes,
  Data.DB, FireDAC.Comp.Client,
  uniGUIBaseClasses, uniGUIClasses, uniGUImClasses, uniButton, uniLabel, uniListBox,
  uniPanel, uniGUIForm, Vcl.Dialogs,
  UniContext, UniPlugin.Types, UniDataModule;

type
  /// <summary>
  /// 权限选择对话框 - 为角色分配权限
  /// </summary>
  TRolePermissionDialog = class(TUniForm)
    pnlMain: TUniPanel;
    pnlLeft: TUniPanel;
    lblAvailable: TUniLabel;
    lstAvailable: TUniListBox;
    pnlRight: TUniPanel;
    lblAssigned: TUniLabel;
    lstAssigned: TUniListBox;
    pnlCenter: TUniPanel;
    btnAdd: TUniButton;
    btnAddAll: TUniButton;
    btnRemove: TUniButton;
    btnRemoveAll: TUniButton;
    pnlBottom: TUniPanel;
    btnSave: TUniButton;
    btnCancel: TUniButton;
    lblRoleName: TUniLabel;

    procedure FormCreate(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnAddAllClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnRemoveAllClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    FRoleID: Integer;
    FRoleName: string;
    FContext: IExecutionContext;
    FConnection: TFDConnection;
    FAvailablePermissions: TList<TPair<Integer, string>>;
    FAssignedPermissions: TList<TPair<Integer, string>>;

    procedure LoadPermissions;
    procedure SavePermissions;
    procedure AddSelected;
    procedure AddAll;
    procedure RemoveSelected;
    procedure RemoveAll;
    procedure RefreshLists;
    procedure CleanupLists;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetContext(const Context: IExecutionContext);
    procedure SetConnection(const Connection: TFDConnection);
    procedure SetRole(RoleID: Integer; const RoleName: string);
    function Execute: Boolean;
  end;

implementation

{$R *.dfm}

constructor TRolePermissionDialog.Create(AOwner: TComponent);
begin
  inherited;
  FRoleID := 0;
  FRoleName := '';
  FAvailablePermissions := TList<TPair<Integer, string>>.Create;
  FAssignedPermissions := TList<TPair<Integer, string>>.Create;
end;

destructor TRolePermissionDialog.Destroy;
begin
  CleanupLists;
  FAvailablePermissions.Free;
  FAssignedPermissions.Free;
  inherited;
end;

procedure TRolePermissionDialog.SetContext(const Context: IExecutionContext);
begin
  FContext := Context;
end;

procedure TRolePermissionDialog.SetConnection(const Connection: TFDConnection);
begin
  FConnection := Connection;
end;

procedure TRolePermissionDialog.SetRole(RoleID: Integer; const RoleName: string);
begin
  FRoleID := RoleID;
  FRoleName := RoleName;
  lblRoleName.Caption := '角色: ' + RoleName;
end;

procedure TRolePermissionDialog.FormCreate(Sender: TObject);
begin
  Caption := '权限分配';
  Width := 700;
  Height := 500;

  // 初始化列表
  LoadPermissions;
  RefreshLists;
end;

procedure TRolePermissionDialog.LoadPermissions;
var
  LQuery: TFDQuery;
begin
  if not Assigned(FConnection) or not FConnection.Connected then
    raise Exception.Create('数据库未连接');

  // 清空现有列表
  FAvailablePermissions.Clear;
  FAssignedPermissions.Clear;

  // 加载已分配的权限
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT p.PermissionID, p.PermissionCode, p.PermissionName, p.Category ' +
      'FROM UniAdmin_Permissions p ' +
      'INNER JOIN UniAdmin_RolePermissions rp ON p.PermissionID = rp.PermissionID ' +
      'WHERE rp.RoleID = :RoleID ' +
      'ORDER BY p.Category, p.SortOrder, p.PermissionName';

    LQuery.ParamByName('RoleID').AsInteger := FRoleID;
    LQuery.Open;

    while not LQuery.Eof do
    begin
      FAssignedPermissions.Add(
        TPair<Integer, string>.Create(
          LQuery.FieldByName('PermissionID').AsInteger,
          Format('[%s] %s - %s', [
            LQuery.FieldByName('Category').AsString,
            LQuery.FieldByName('PermissionCode').AsString,
            LQuery.FieldByName('PermissionName').AsString
          ])
        )
      );
      LQuery.Next;
    end;
    LQuery.Close;
  finally
    LQuery.Free;
  end;

  // 加载未分配的权限
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT p.PermissionID, p.PermissionCode, p.PermissionName, p.Category ' +
      'FROM UniAdmin_Permissions p ' +
      'WHERE p.PermissionID NOT IN ( ' +
      '  SELECT rp.PermissionID FROM UniAdmin_RolePermissions rp WHERE rp.RoleID = :RoleID ' +
      ') ' +
      'ORDER BY p.Category, p.SortOrder, p.PermissionName';

    LQuery.ParamByName('RoleID').AsInteger := FRoleID;
    LQuery.Open;

    while not LQuery.Eof do
    begin
      FAvailablePermissions.Add(
        TPair<Integer, string>.Create(
          LQuery.FieldByName('PermissionID').AsInteger,
          Format('[%s] %s - %s', [
            LQuery.FieldByName('Category').AsString,
            LQuery.FieldByName('PermissionCode').AsString,
            LQuery.FieldByName('PermissionName').AsString
          ])
        )
      );
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
end;

procedure TRolePermissionDialog.RefreshLists;
var
  LPair: TPair<Integer, string>;
begin
  lstAvailable.Clear;
  lstAssigned.Clear;

  for LPair in FAvailablePermissions do
    lstAvailable.Items.AddObject(LPair.Value, TObject(LPair.Key));

  for LPair in FAssignedPermissions do
    lstAssigned.Items.AddObject(LPair.Value, TObject(LPair.Key));
end;

procedure TRolePermissionDialog.AddSelected;
var
  I: Integer;
  LIndex: Integer;
  LPair: TPair<Integer, string>;
begin
  // 从后向前删除，避免索引问题
  for I := lstAvailable.Items.Count - 1 downto 0 do
  begin
    if lstAvailable.Selected[I] then
    begin
      LIndex := Integer(lstAvailable.Items.Objects[I]);
      for LPair in FAvailablePermissions do
      begin
        if LPair.Key = LIndex then
        begin
          FAssignedPermissions.Add(LPair);
          FAvailablePermissions.Remove(LPair);
          Break;
        end;
      end;
    end;
  end;
  RefreshLists;
end;

procedure TRolePermissionDialog.AddAll;
var
  LPair: TPair<Integer, string>;
begin
  // 将所有可用权限移到已分配
  while FAvailablePermissions.Count > 0 do
  begin
    LPair := FAvailablePermissions[0];
    FAssignedPermissions.Add(LPair);
    FAvailablePermissions.Remove(LPair);
  end;
  RefreshLists;
end;

procedure TRolePermissionDialog.RemoveSelected;
var
  I: Integer;
  LIndex: Integer;
  LPair: TPair<Integer, string>;
begin
  // 从后向前删除，避免索引问题
  for I := lstAssigned.Items.Count - 1 downto 0 do
  begin
    if lstAssigned.Selected[I] then
    begin
      LIndex := Integer(lstAssigned.Items.Objects[I]);
      for LPair in FAssignedPermissions do
      begin
        if LPair.Key = LIndex then
        begin
          FAvailablePermissions.Add(LPair);
          FAssignedPermissions.Remove(LPair);
          Break;
        end;
      end;
    end;
  end;
  RefreshLists;
end;

procedure TRolePermissionDialog.RemoveAll;
var
  LPair: TPair<Integer, string>;
begin
  // 将所有已分配权限移到可用
  while FAssignedPermissions.Count > 0 do
  begin
    LPair := FAssignedPermissions[0];
    FAvailablePermissions.Add(LPair);
    FAssignedPermissions.Remove(LPair);
  end;
  RefreshLists;
end;

procedure TRolePermissionDialog.btnAddClick(Sender: TObject);
begin
  AddSelected;
end;

procedure TRolePermissionDialog.btnAddAllClick(Sender: TObject);
begin
  AddAll;
end;

procedure TRolePermissionDialog.btnRemoveClick(Sender: TObject);
begin
  RemoveSelected;
end;

procedure TRolePermissionDialog.btnRemoveAllClick(Sender: TObject);
begin
  RemoveAll;
end;

procedure TRolePermissionDialog.SavePermissions;
var
  LPermissionIDs: TArray<Integer>;
  LPair: TPair<Integer, string>;
  I: Integer;
  LQuery: TFDQuery;
begin
  if not Assigned(FConnection) or not FConnection.Connected then
    raise Exception.Create('数据库未连接');

  // 构建权限ID数组
  SetLength(LPermissionIDs, FAssignedPermissions.Count);
  I := 0;
  for LPair in FAssignedPermissions do
  begin
    LPermissionIDs[I] := LPair.Key;
    Inc(I);
  end;

  // 开启事务
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;

    FConnection.StartTransaction;
    try
      // 删除现有权限
      LQuery.SQL.Text := 'DELETE FROM UniAdmin_RolePermissions WHERE RoleID = :RoleID';
      LQuery.ParamByName('RoleID').AsInteger := FRoleID;
      LQuery.ExecSQL;

      // 添加新权限
      for I := 0 to High(LPermissionIDs) do
      begin
        LQuery.SQL.Text :=
          'INSERT INTO UniAdmin_RolePermissions (RoleID, PermissionID, CreatedDate) ' +
          'VALUES (:RoleID, :PermissionID, GETDATE())';
        LQuery.ParamByName('RoleID').AsInteger := FRoleID;
        LQuery.ParamByName('PermissionID').AsInteger := LPermissionIDs[I];
        LQuery.ExecSQL;
      end;

      FConnection.Commit;
    except
      FConnection.Rollback;
      raise;
    end;
  finally
    LQuery.Free;
  end;
end;

procedure TRolePermissionDialog.btnSaveClick(Sender: TObject);
begin
  try
    SavePermissions;
    ShowMessage('权限分配成功');
    ModalResult := mrOK;
  except
    on E: Exception do
    begin
      ShowMessage('保存失败: ' + E.Message);
    end;
  end;
end;

procedure TRolePermissionDialog.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TRolePermissionDialog.CleanupLists;
begin
  FAvailablePermissions.Clear;
  FAssignedPermissions.Clear;
end;

function TRolePermissionDialog.Execute: Boolean;
begin
  LoadPermissions;
  RefreshLists;
  Result := ShowModal = mrOK;
end;

end.

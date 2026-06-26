unit RoleUserDialog;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Generics.Collections, System.UITypes,
  Data.DB, FireDAC.Comp.Client,
  uniGUIBaseClasses, uniGUIClasses, uniGUImClasses, uniButton, uniLabel, uniListBox,
  uniPanel, uniEdit, uniGUIForm, Vcl.Dialogs,
  UniContext, UniPlugin.Types, UniAdminDataModule;

type
  /// <summary>
  /// 用户选择对话框 - 为角色分配用户
  /// </summary>
  TRoleUserDialog = class(TUniForm)
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
    edtSearch: TUniEdit;
    btnSearch: TUniButton;

    procedure FormCreate(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnAddAllClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnRemoveAllClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure edtSearchKeyPress(Sender: TObject; var Key: Char);
  private
    FRoleID: Integer;
    FRoleName: string;
    FContext: IExecutionContext;
    FConnection: TFDConnection;
    FAvailableUsers: TList<TPair<Integer, string>>;
    FAssignedUsers: TList<TPair<Integer, string>>;
    FSearchText: string;

    procedure LoadUsers;
    procedure SaveUsers;
    procedure AddSelected;
    procedure AddAll;
    procedure RemoveSelected;
    procedure RemoveAll;
    procedure RefreshLists;
    procedure CleanupLists;
    function FormatUserDisplay(const UserName, RealName, Email: string): string;
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

uses
  UniAdminFormStyler;

constructor TRoleUserDialog.Create(AOwner: TComponent);
begin
  inherited;
  FRoleID := 0;
  FRoleName := '';
  FSearchText := '';
  FAvailableUsers := TList<TPair<Integer, string>>.Create;
  FAssignedUsers := TList<TPair<Integer, string>>.Create;
end;

destructor TRoleUserDialog.Destroy;
begin
  CleanupLists;
  FAvailableUsers.Free;
  FAssignedUsers.Free;
  inherited;
end;

procedure TRoleUserDialog.SetContext(const Context: IExecutionContext);
begin
  FContext := Context;
end;

procedure TRoleUserDialog.SetConnection(const Connection: TFDConnection);
begin
  FConnection := Connection;
end;

procedure TRoleUserDialog.SetRole(RoleID: Integer; const RoleName: string);
begin
  FRoleID := RoleID;
  FRoleName := RoleName;
  lblRoleName.Caption := '角色: ' + RoleName;
end;

procedure TRoleUserDialog.FormCreate(Sender: TObject);
begin
  TUniAdminFormStyler.AutoStylePanels(Self);
  TUniAdminFormStyler.AutoStyleButtons(Self);
  Caption := '用户分配';
  Width := 700;
  Height := 500;

  // 初始化列表
  LoadUsers;
  RefreshLists;
end;

function TRoleUserDialog.FormatUserDisplay(const UserName, RealName, Email: string): string;
begin
  if RealName <> '' then
    Result := Format('%s (%s) - %s', [UserName, RealName, Email])
  else
    Result := Format('%s - %s', [UserName, Email]);
end;

procedure TRoleUserDialog.LoadUsers;
var
  LQuery: TFDQuery;
  LSQL: string;
  LFilter: string;
begin
  if not Assigned(FConnection) or not FConnection.Connected then
    raise Exception.Create('数据库未连接');

  // 清空现有列表
  FAvailableUsers.Clear;
  FAssignedUsers.Clear;

  // 构建搜索条件
  if FSearchText <> '' then
    LFilter := 'AND (u.UserName LIKE :Filter OR u.RealName LIKE :Filter OR u.Email LIKE :Filter)'
  else
    LFilter := '';

  // 加载已分配的用户
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LSQL :=
      'SELECT u.UserID, u.UserName, u.RealName, u.Email ' +
      'FROM UniAdmin_Users u ' +
      'INNER JOIN UniAdmin_UserRoles ur ON u.UserID = ur.UserID ' +
      'WHERE ur.RoleID = :RoleID ';

    LSQL := LSQL + LFilter + ' ORDER BY u.UserName';

    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('RoleID').AsInteger := FRoleID;

    if FSearchText <> '' then
      LQuery.ParamByName('Filter').AsString := '%' + FSearchText + '%';

    LQuery.Open;

    while not LQuery.Eof do
    begin
      FAssignedUsers.Add(
        TPair<Integer, string>.Create(
          LQuery.FieldByName('UserID').AsInteger,
          FormatUserDisplay(
            LQuery.FieldByName('UserName').AsString,
            LQuery.FieldByName('RealName').AsString,
            LQuery.FieldByName('Email').AsString
          )
        )
      );
      LQuery.Next;
    end;
    LQuery.Close;
  finally
    LQuery.Free;
  end;

  // 加载未分配的用户（排除已分配的）
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LSQL :=
      'SELECT u.UserID, u.UserName, u.RealName, u.Email ' +
      'FROM UniAdmin_Users u ' +
      'WHERE u.UserID NOT IN ( ' +
      '  SELECT ur.UserID FROM UniAdmin_UserRoles ur WHERE ur.RoleID = :RoleID ' +
      ') ';

    LSQL := LSQL + LFilter + ' ORDER BY u.UserName';

    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('RoleID').AsInteger := FRoleID;

    if FSearchText <> '' then
      LQuery.ParamByName('Filter').AsString := '%' + FSearchText + '%';

    LQuery.Open;

    while not LQuery.Eof do
    begin
      FAvailableUsers.Add(
        TPair<Integer, string>.Create(
          LQuery.FieldByName('UserID').AsInteger,
          FormatUserDisplay(
            LQuery.FieldByName('UserName').AsString,
            LQuery.FieldByName('RealName').AsString,
            LQuery.FieldByName('Email').AsString
          )
        )
      );
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
end;

procedure TRoleUserDialog.RefreshLists;
var
  LPair: TPair<Integer, string>;
begin
  lstAvailable.Clear;
  lstAssigned.Clear;

  for LPair in FAvailableUsers do
    lstAvailable.Items.AddObject(LPair.Value, TObject(LPair.Key));

  for LPair in FAssignedUsers do
    lstAssigned.Items.AddObject(LPair.Value, TObject(LPair.Key));
end;

procedure TRoleUserDialog.AddSelected;
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
      for LPair in FAvailableUsers do
      begin
        if LPair.Key = LIndex then
        begin
          FAssignedUsers.Add(LPair);
          FAvailableUsers.Remove(LPair);
          Break;
        end;
      end;
    end;
  end;
  RefreshLists;
end;

procedure TRoleUserDialog.AddAll;
var
  LPair: TPair<Integer, string>;
begin
  // 将所有可用用户移到已分配
  while FAvailableUsers.Count > 0 do
  begin
    LPair := FAvailableUsers[0];
    FAssignedUsers.Add(LPair);
    FAvailableUsers.Remove(LPair);
  end;
  RefreshLists;
end;

procedure TRoleUserDialog.RemoveSelected;
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
      for LPair in FAssignedUsers do
      begin
        if LPair.Key = LIndex then
        begin
          FAvailableUsers.Add(LPair);
          FAssignedUsers.Remove(LPair);
          Break;
        end;
      end;
    end;
  end;
  RefreshLists;
end;

procedure TRoleUserDialog.RemoveAll;
var
  LPair: TPair<Integer, string>;
begin
  // 将所有已分配用户移到可用
  while FAssignedUsers.Count > 0 do
  begin
    LPair := FAssignedUsers[0];
    FAvailableUsers.Add(LPair);
    FAssignedUsers.Remove(LPair);
  end;
  RefreshLists;
end;

procedure TRoleUserDialog.btnAddClick(Sender: TObject);
begin
  AddSelected;
end;

procedure TRoleUserDialog.btnAddAllClick(Sender: TObject);
begin
  AddAll;
end;

procedure TRoleUserDialog.btnRemoveClick(Sender: TObject);
begin
  RemoveSelected;
end;

procedure TRoleUserDialog.btnRemoveAllClick(Sender: TObject);
begin
  RemoveAll;
end;

procedure TRoleUserDialog.SaveUsers;
var
  LUserIDs: TArray<Integer>;
  LPair: TPair<Integer, string>;
  I: Integer;
  LQuery: TFDQuery;
begin
  if not Assigned(FConnection) or not FConnection.Connected then
    raise Exception.Create('数据库未连接');

  // 构建用户ID数组
  SetLength(LUserIDs, FAssignedUsers.Count);
  I := 0;
  for LPair in FAssignedUsers do
  begin
    LUserIDs[I] := LPair.Key;
    Inc(I);
  end;

  // 开启事务
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;

    FConnection.StartTransaction;
    try
      // 删除现有用户分配
      LQuery.SQL.Text := 'DELETE FROM UniAdmin_UserRoles WHERE RoleID = :RoleID';
      LQuery.ParamByName('RoleID').AsInteger := FRoleID;
      LQuery.ExecSQL;

      // 添加新用户分配
      for I := 0 to High(LUserIDs) do
      begin
        LQuery.SQL.Text :=
          'INSERT INTO UniAdmin_UserRoles (UserID, RoleID, CreatedDate) ' +
          'VALUES (:UserID, :RoleID, CURRENT_TIMESTAMP)';
        LQuery.ParamByName('UserID').AsInteger := LUserIDs[I];
        LQuery.ParamByName('RoleID').AsInteger := FRoleID;
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

procedure TRoleUserDialog.btnSaveClick(Sender: TObject);
begin
  try
    SaveUsers;
    ShowMessage('用户分配成功');
    ModalResult := mrOK;
  except
    on E: Exception do
    begin
      ShowMessage('保存失败: ' + E.Message);
    end;
  end;
end;

procedure TRoleUserDialog.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TRoleUserDialog.btnSearchClick(Sender: TObject);
begin
  FSearchText := Trim(edtSearch.Text);
  LoadUsers;
  RefreshLists;
end;

procedure TRoleUserDialog.edtSearchKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    btnSearchClick(nil);
end;

procedure TRoleUserDialog.CleanupLists;
begin
  FAvailableUsers.Clear;
  FAssignedUsers.Clear;
end;

function TRoleUserDialog.Execute: Boolean;
begin
  FSearchText := '';
  edtSearch.Text := '';
  LoadUsers;
  RefreshLists;
  Result := ShowModal = mrOK;
end;

initialization
  // Register for FindClass-driven MDI routing (UniAdmin_Menus.RoutePath)
  RegisterClass(TRoleUserDialog);

end.

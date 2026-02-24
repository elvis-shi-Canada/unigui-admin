unit RoleDataModule;

interface

uses
  System.SysUtils, System.Classes, System.Types,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Stan.Param,
  UniContext, UniPlugin.Types, UniDataModule;

type
  /// <summary>
  /// 角色信息记录
  /// </summary>
  TRoleInfo = record
    RoleID: Integer;
    RoleCode: string;
    RoleName: string;
    Description: string;
    DataScope: string;
    SortOrder: Integer;
    Status: Integer;
    CreatedDate: TDateTime;
    ModifiedDate: TDateTime;
  end;

  /// <summary>
  /// 角色数据模块 - 提供角色表的 CRUD 操作和关联管理
  /// </summary>
  TRoleDataModule = class(TUniDataModule)
  private
    function RoleCodeExists(const RoleCode: string; ExcludeRoleID: Integer = 0): Boolean;
    function ValidateDataScope(const DataScope: string): Boolean;
    function GetRoleUserCount(RoleID: Integer): Integer;
  public
    /// <summary>
    /// 根据 ID 获取角色信息
    /// </summary>
    function GetRoleByID(RoleID: Integer): TDataSet;

    /// <summary>
    /// 根据编码获取角色信息
    /// </summary>
    function GetRoleByCode(const RoleCode: string): TDataSet;

    /// <summary>
    /// 获取角色列表（支持筛选）
    /// </summary>
    function GetRoles(const Filter: string = ''; Status: Integer = -1): TDataSet;

    /// <summary>
    /// 创建新角色
    /// </summary>
    function CreateRole(const RoleCode, RoleName, Description: string;
      DataScope: string = 'all'; SortOrder: Integer = 0): Integer;

    /// <summary>
    /// 更新角色信息
    /// </summary>
    procedure UpdateRole(RoleID: Integer; const RoleName, Description: string;
      DataScope: string = 'all'; SortOrder: Integer = -1; Status: Integer = -1);

    /// <summary>
    /// 删除角色
    /// </summary>
    procedure DeleteRole(RoleID: Integer);

    /// <summary>
    /// 设置角色状态
    /// </summary>
    procedure SetRoleStatus(RoleID: Integer; Status: Integer);

    // 用户分配

    /// <summary>
    /// 分配用户到角色
    /// </summary>
    procedure AssignUserToRole(UserID, RoleID: Integer);

    /// <summary>
    /// 从角色移除用户
    /// </summary>
    procedure RemoveUserFromRole(UserID, RoleID: Integer);

    /// <summary>
    /// 获取角色的用户列表
    /// </summary>
    function GetRoleUsers(RoleID: Integer): TDataSet;

    /// <summary>
    /// 获取用户的角色列表
    /// </summary>
    function GetUserRoles(UserID: Integer): TDataSet;

    /// <summary>
    /// 批量分配用户到角色
    /// </summary>
    procedure AssignUsersToRole(const UserIDs: TArray<Integer>; RoleID: Integer);

    /// <summary>
    /// 批量从角色移除用户
    /// </summary>
    procedure RemoveUsersFromRole(const UserIDs: TArray<Integer>; RoleID: Integer);

    // 权限分配

    /// <summary>
    /// 分配权限到角色
    /// </summary>
    procedure AssignPermissionToRole(RoleID, PermissionID: Integer);

    /// <summary>
    /// 从角色移除权限
    /// </summary>
    procedure RemovePermissionFromRole(RoleID, PermissionID: Integer);

    /// <summary>
    /// 获取角色的权限列表
    /// </summary>
    function GetRolePermissions(RoleID: Integer): TDataSet;

    /// <summary>
    /// 批量分配权限到角色
    /// </summary>
    procedure AssignPermissionsToRole(const PermissionIDs: TArray<Integer>; RoleID: Integer);

    /// <summary>
    /// 批量从角色移除权限
    /// </summary>
    procedure RemovePermissionsFromRole(const PermissionIDs: TArray<Integer>; RoleID: Integer);

    /// <summary>
    /// 替换角色的所有权限
    /// </summary>
    procedure ReplaceRolePermissions(RoleID: Integer; const PermissionIDs: TArray<Integer>);

    /// <summary>
    /// 检查角色是否拥有指定权限
    /// </summary>
    function RoleHasPermission(RoleID, PermissionID: Integer): Boolean;

    /// <summary>
    /// 检查用户是否拥有指定角色
    /// </summary>
    function UserHasRole(UserID, RoleID: Integer): Boolean;

    /// <summary>
    /// 获取角色统计信息（用户数、权限数）
    /// </summary>
    function GetRoleStats(RoleID: Integer): TDataSet;
  end;

implementation

{ TRoleDataModule }

function TRoleDataModule.GetRoleByID(RoleID: Integer): TDataSet;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'SELECT RoleID, RoleCode, RoleName, Description, DataScope, SortOrder, Status, ' +
      'CreatedDate, ModifiedDate ' +
      'FROM UniAdmin_Roles ' +
      'WHERE RoleID = :RoleID';
    LQuery.Params.ParamByName('RoleID').AsInteger := RoleID;
    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    raise;
  end;
end;

function TRoleDataModule.GetRoleByCode(const RoleCode: string): TDataSet;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'SELECT RoleID, RoleCode, RoleName, Description, DataScope, SortOrder, Status, ' +
      'CreatedDate, ModifiedDate ' +
      'FROM UniAdmin_Roles ' +
      'WHERE RoleCode = :RoleCode';
    LQuery.Params.ParamByName('RoleCode').AsString := RoleCode;
    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    raise;
  end;
end;

function TRoleDataModule.GetRoles(const Filter: string; Status: Integer): TDataSet;
var
  LQuery: TFDQuery;
  LSQL: string;
  LWhere: string;
  LWhereList: TStringList;
begin
  LQuery := TFDQuery.Create(nil);
  LWhereList := TStringList.Create;
  try
    LQuery.Connection := Connection;

    // 构建 SQL
    LSQL := 'SELECT RoleID, RoleCode, RoleName, Description, DataScope, SortOrder, Status, ' +
            'CreatedDate, ModifiedDate ' +
            'FROM UniAdmin_Roles';

    // 构建条件
    if Filter <> '' then
      LWhereList.Add('(RoleCode LIKE :Filter OR RoleName LIKE :Filter OR Description LIKE :Filter)');

    if Status >= 0 then
      LWhereList.Add('Status = :Status');

    if LWhereList.Count > 0 then
    begin
      LWhere := ' WHERE ' + LWhereList.Text.Replace(#13#10, ' AND ');
      LSQL := LSQL + LWhere;
    end;

    LSQL := LSQL + ' ORDER BY SortOrder ASC, RoleID ASC';

    LQuery.SQL.Text := LSQL;

    // 设置参数
    if Filter <> '' then
      LQuery.Params.ParamByName('Filter').AsString := '%' + Filter + '%';

    if Status >= 0 then
      LQuery.Params.ParamByName('Status').AsInteger := Status;

    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    LWhereList.Free;
    raise;
  end;
  LWhereList.Free;
end;

function TRoleDataModule.CreateRole(const RoleCode, RoleName, Description: string;
  DataScope: string; SortOrder: Integer): Integer;
var
  LQuery: TFDQuery;
begin
  // 验证输入
  if RoleCode.Trim.IsEmpty then
    raise Exception.Create('角色编码不能为空');

  if RoleName.Trim.IsEmpty then
    raise Exception.Create('角色名称不能为空');

  if not ValidateDataScope(DataScope) then
    raise Exception.Create('数据范围参数无效');

  if RoleCodeExists(RoleCode) then
    raise Exception.Create('角色编码已存在');

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'INSERT INTO UniAdmin_Roles ' +
      '(RoleCode, RoleName, Description, DataScope, SortOrder, Status, CreatedDate, ModifiedDate) ' +
      'VALUES (:RoleCode, :RoleName, :Description, :DataScope, :SortOrder, 1, GETDATE(), GETDATE())';

    LQuery.Params.ParamByName('RoleCode').AsString := RoleCode;
    LQuery.Params.ParamByName('RoleName').AsString := RoleName;
    LQuery.Params.ParamByName('Description').AsString := Description;
    LQuery.Params.ParamByName('DataScope').AsString := DataScope;
    LQuery.Params.ParamByName('SortOrder').AsInteger := SortOrder;

    LQuery.ExecSQL;

    // 返回新插入的角色 ID
    LQuery.SQL.Text := 'SELECT SCOPE_IDENTITY() AS NewID';
    LQuery.Open;
    Result := LQuery.FieldByName('NewID').AsInteger;
  finally
    LQuery.Free;
  end;
end;

procedure TRoleDataModule.UpdateRole(RoleID: Integer; const RoleName, Description: string;
  DataScope: string; SortOrder: Integer; Status: Integer);
var
  LQuery: TFDQuery;
  LSQL: TStringList;
  LUpdates: TStringList;
begin
  // 验证输入
  if RoleName.Trim.IsEmpty then
    raise Exception.Create('角色名称不能为空');

  if not ValidateDataScope(DataScope) then
    raise Exception.Create('数据范围参数无效');

  LQuery := TFDQuery.Create(nil);
  LUpdates := TStringList.Create;
  try
    LQuery.Connection := Connection;

    // 构建更新语句
    if RoleName <> '' then
      LUpdates.Add('RoleName = :RoleName');

    LUpdates.Add('Description = :Description');
    LUpdates.Add('DataScope = :DataScope');

    if SortOrder >= 0 then
      LUpdates.Add('SortOrder = :SortOrder');

    if Status >= 0 then
      LUpdates.Add('Status = :Status');

    LUpdates.Add('ModifiedDate = GETDATE()');

    LSQL := TStringList.Create;
    try
      LSQL.Add('UPDATE UniAdmin_Roles SET ' + LUpdates.Text.Replace(#13#10, ', '));
      LSQL.Add('WHERE RoleID = :RoleID');

      LQuery.SQL.Text := LSQL.Text.Replace(#13#10, ' ');

      LQuery.Params.ParamByName('RoleID').AsInteger := RoleID;
      LQuery.Params.ParamByName('RoleName').AsString := RoleName;
      LQuery.Params.ParamByName('Description').AsString := Description;
      LQuery.Params.ParamByName('DataScope').AsString := DataScope;

      if SortOrder >= 0 then
        LQuery.Params.ParamByName('SortOrder').AsInteger := SortOrder;

      if Status >= 0 then
        LQuery.Params.ParamByName('Status').AsInteger := Status;

      LQuery.ExecSQL;
    finally
      LSQL.Free;
    end;
  finally
    LQuery.Free;
    LUpdates.Free;
  end;
end;

procedure TRoleDataModule.DeleteRole(RoleID: Integer);
var
  LQuery: TFDQuery;
  LUserCount: Integer;
begin
  // 检查角色是否有用户
  LUserCount := GetRoleUserCount(RoleID);
  if LUserCount > 0 then
    raise Exception.CreateFmt('该角色下有 %d 个用户，无法删除', [LUserCount]);

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;

    // 删除角色权限关联
    LQuery.SQL.Text := 'DELETE FROM UniAdmin_RolePermissions WHERE RoleID = :RoleID';
    LQuery.Params.ParamByName('RoleID').AsInteger := RoleID;
    LQuery.ExecSQL;

    // 删除角色用户关联
    LQuery.SQL.Text := 'DELETE FROM UniAdmin_UserRoles WHERE RoleID = :RoleID';
    LQuery.ExecSQL;

    // 删除角色
    LQuery.SQL.Text := 'DELETE FROM UniAdmin_Roles WHERE RoleID = :RoleID';
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

procedure TRoleDataModule.SetRoleStatus(RoleID: Integer; Status: Integer);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'UPDATE UniAdmin_Roles ' +
      'SET Status = :Status, ModifiedDate = GETDATE() ' +
      'WHERE RoleID = :RoleID';

    LQuery.Params.ParamByName('RoleID').AsInteger := RoleID;
    LQuery.Params.ParamByName('Status').AsInteger := Status;

    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

// 用户分配

procedure TRoleDataModule.AssignUserToRole(UserID, RoleID: Integer);
var
  LQuery: TFDQuery;
begin
  // 检查是否已分配
  if UserHasRole(UserID, RoleID) then
    Exit;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'INSERT INTO UniAdmin_UserRoles (UserID, RoleID, CreatedDate) ' +
      'VALUES (:UserID, :RoleID, GETDATE())';

    LQuery.Params.ParamByName('UserID').AsInteger := UserID;
    LQuery.Params.ParamByName('RoleID').AsInteger := RoleID;

    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

procedure TRoleDataModule.RemoveUserFromRole(UserID, RoleID: Integer);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'DELETE FROM UniAdmin_UserRoles ' +
      'WHERE UserID = :UserID AND RoleID = :RoleID';

    LQuery.Params.ParamByName('UserID').AsInteger := UserID;
    LQuery.Params.ParamByName('RoleID').AsInteger := RoleID;

    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

function TRoleDataModule.GetRoleUsers(RoleID: Integer): TDataSet;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'SELECT u.UserID, u.UserName, u.RealName, u.Email, u.Status, ' +
      'ur.CreatedDate AS AssignDate ' +
      'FROM UniAdmin_Users u ' +
      'INNER JOIN UniAdmin_UserRoles ur ON u.UserID = ur.UserID ' +
      'WHERE ur.RoleID = :RoleID ' +
      'ORDER BY u.UserName';

    LQuery.Params.ParamByName('RoleID').AsInteger := RoleID;
    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    raise;
  end;
end;

function TRoleDataModule.GetUserRoles(UserID: Integer): TDataSet;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'SELECT r.RoleID, r.RoleCode, r.RoleName, r.Description, r.DataScope, r.Status, ' +
      'ur.CreatedDate AS AssignDate ' +
      'FROM UniAdmin_Roles r ' +
      'INNER JOIN UniAdmin_UserRoles ur ON r.RoleID = ur.RoleID ' +
      'WHERE ur.UserID = :UserID ' +
      'ORDER BY r.SortOrder, r.RoleName';

    LQuery.Params.ParamByName('UserID').AsInteger := UserID;
    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    raise;
  end;
end;

procedure TRoleDataModule.AssignUsersToRole(const UserIDs: TArray<Integer>; RoleID: Integer);
var
  LUserID: Integer;
begin
  for LUserID in UserIDs do
  begin
    try
      AssignUserToRole(LUserID, RoleID);
    except
      // 忽略重复分配错误
    end;
  end;
end;

procedure TRoleDataModule.RemoveUsersFromRole(const UserIDs: TArray<Integer>; RoleID: Integer);
var
  LUserID: Integer;
begin
  for LUserID in UserIDs do
  begin
    RemoveUserFromRole(LUserID, RoleID);
  end;
end;

// 权限分配

procedure TRoleDataModule.AssignPermissionToRole(RoleID, PermissionID: Integer);
var
  LQuery: TFDQuery;
begin
  // 检查是否已分配
  if RoleHasPermission(RoleID, PermissionID) then
    Exit;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'INSERT INTO UniAdmin_RolePermissions (RoleID, PermissionID, CreatedDate) ' +
      'VALUES (:RoleID, :PermissionID, GETDATE())';

    LQuery.Params.ParamByName('RoleID').AsInteger := RoleID;
    LQuery.Params.ParamByName('PermissionID').AsInteger := PermissionID;

    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

procedure TRoleDataModule.RemovePermissionFromRole(RoleID, PermissionID: Integer);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'DELETE FROM UniAdmin_RolePermissions ' +
      'WHERE RoleID = :RoleID AND PermissionID = :PermissionID';

    LQuery.Params.ParamByName('RoleID').AsInteger := RoleID;
    LQuery.Params.ParamByName('PermissionID').AsInteger := PermissionID;

    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

function TRoleDataModule.GetRolePermissions(RoleID: Integer): TDataSet;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'SELECT p.PermissionID, p.PermissionCode, p.PermissionName, p.Category, ' +
      'p.Description, p.SortOrder, ' +
      'rp.CreatedDate AS AssignDate ' +
      'FROM UniAdmin_Permissions p ' +
      'INNER JOIN UniAdmin_RolePermissions rp ON p.PermissionID = rp.PermissionID ' +
      'WHERE rp.RoleID = :RoleID ' +
      'ORDER BY p.Category, p.SortOrder, p.PermissionName';

    LQuery.Params.ParamByName('RoleID').AsInteger := RoleID;
    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    raise;
  end;
end;

procedure TRoleDataModule.AssignPermissionsToRole(const PermissionIDs: TArray<Integer>; RoleID: Integer);
var
  LPermissionID: Integer;
begin
  for LPermissionID in PermissionIDs do
  begin
    try
      AssignPermissionToRole(RoleID, LPermissionID);
    except
      // 忽略重复分配错误
    end;
  end;
end;

procedure TRoleDataModule.RemovePermissionsFromRole(const PermissionIDs: TArray<Integer>; RoleID: Integer);
var
  LPermissionID: Integer;
begin
  for LPermissionID in PermissionIDs do
  begin
    RemovePermissionFromRole(RoleID, LPermissionID);
  end;
end;

procedure TRoleDataModule.ReplaceRolePermissions(RoleID: Integer; const PermissionIDs: TArray<Integer>);
var
  LQuery: TFDQuery;
  LPermissionID: Integer;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;

    // 开启事务
    LQuery.Connection.StartTransaction;
    try
      // 删除现有权限
      LQuery.SQL.Text := 'DELETE FROM UniAdmin_RolePermissions WHERE RoleID = :RoleID';
      LQuery.Params.ParamByName('RoleID').AsInteger := RoleID;
      LQuery.ExecSQL;

      // 添加新权限
      for LPermissionID in PermissionIDs do
      begin
        LQuery.SQL.Text :=
          'INSERT INTO UniAdmin_RolePermissions (RoleID, PermissionID, CreatedDate) ' +
          'VALUES (:RoleID, :PermissionID, GETDATE())';
        LQuery.Params.ParamByName('RoleID').AsInteger := RoleID;
        LQuery.Params.ParamByName('PermissionID').AsInteger := LPermissionID;
        LQuery.ExecSQL;
      end;

      // 提交事务
      LQuery.Connection.Commit;
    except
      // 回滚事务
      LQuery.Connection.Rollback;
      raise;
    end;
  finally
    LQuery.Free;
  end;
end;

function TRoleDataModule.RoleHasPermission(RoleID, PermissionID: Integer): Boolean;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'SELECT COUNT(*) AS Cnt ' +
      'FROM UniAdmin_RolePermissions ' +
      'WHERE RoleID = :RoleID AND PermissionID = :PermissionID';

    LQuery.Params.ParamByName('RoleID').AsInteger := RoleID;
    LQuery.Params.ParamByName('PermissionID').AsInteger := PermissionID;
    LQuery.Open;
    Result := LQuery.FieldByName('Cnt').AsInteger > 0;
  finally
    LQuery.Free;
  end;
end;

function TRoleDataModule.UserHasRole(UserID, RoleID: Integer): Boolean;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'SELECT COUNT(*) AS Cnt ' +
      'FROM UniAdmin_UserRoles ' +
      'WHERE UserID = :UserID AND RoleID = :RoleID';

    LQuery.Params.ParamByName('UserID').AsInteger := UserID;
    LQuery.Params.ParamByName('RoleID').AsInteger := RoleID;
    LQuery.Open;
    Result := LQuery.FieldByName('Cnt').AsInteger > 0;
  finally
    LQuery.Free;
  end;
end;

function TRoleDataModule.GetRoleStats(RoleID: Integer): TDataSet;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'SELECT ' +
      '(SELECT COUNT(*) FROM UniAdmin_UserRoles WHERE RoleID = :RoleID) AS UserCount, ' +
      '(SELECT COUNT(*) FROM UniAdmin_RolePermissions WHERE RoleID = :RoleID) AS PermissionCount';

    LQuery.Params.ParamByName('RoleID').AsInteger := RoleID;
    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    raise;
  end;
end;

// 私有辅助方法

function TRoleDataModule.RoleCodeExists(const RoleCode: string; ExcludeRoleID: Integer): Boolean;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;

    if ExcludeRoleID > 0 then
    begin
      LQuery.SQL.Text := 'SELECT COUNT(*) AS Cnt FROM UniAdmin_Roles WHERE RoleCode = :RoleCode AND RoleID <> :ExcludeRoleID';
      LQuery.Params.ParamByName('ExcludeRoleID').AsInteger := ExcludeRoleID;
    end
    else
    begin
      LQuery.SQL.Text := 'SELECT COUNT(*) AS Cnt FROM UniAdmin_Roles WHERE RoleCode = :RoleCode';
    end;

    LQuery.Params.ParamByName('RoleCode').AsString := RoleCode;
    LQuery.Open;
    Result := LQuery.FieldByName('Cnt').AsInteger > 0;
  finally
    LQuery.Free;
  end;
end;

function TRoleDataModule.ValidateDataScope(const DataScope: string): Boolean;
begin
  // 数据范围：all(全部), dept(本部门), self(仅本人), custom(自定义)
  Result := (DataScope = 'all') or (DataScope = 'dept') or
            (DataScope = 'self') or (DataScope = 'custom');
end;

function TRoleDataModule.GetRoleUserCount(RoleID: Integer): Integer;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text := 'SELECT COUNT(*) AS Cnt FROM UniAdmin_UserRoles WHERE RoleID = :RoleID';
    LQuery.Params.ParamByName('RoleID').AsInteger := RoleID;
    LQuery.Open;
    Result := LQuery.FieldByName('Cnt').AsInteger;
  finally
    LQuery.Free;
  end;
end;

end.

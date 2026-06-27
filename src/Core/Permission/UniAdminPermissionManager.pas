unit UniAdminPermissionManager;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  Data.DB, FireDAC.Comp.Client,
  UniAdminPermissionManager.Intf;

type
  /// <summary>
  /// 权限管理器实现
  /// 提供线程安全的基于角色的访问控制（RBAC）功能
  /// </summary>
  TUniAdminPermissionManager = class(TInterfacedObject, IUniAdminPermissionManager)
  private
    class var FLock: TObject;
    FConnection: TFDConnection;
    FPermissionCache: TDictionary<Integer, TArray<TPermissionInfo>>;
    FRoleCache: TDictionary<Integer, TArray<TRoleInfo>>;
    FCacheEnabled: Boolean;

    /// <summary>
    /// 清空权限缓存
    /// </summary>
    procedure ClearPermissionCache;

    /// <summary>
    /// 清空角色缓存
    /// </summary>
    procedure ClearRoleCache;

    /// <summary>
    /// 清空所有缓存
    /// </summary>
    procedure ClearAllCache;

    /// <summary>
    /// 将字符串转换为数据范围类型
    /// </summary>
    function StringToDataScope(const Scope: string): TDataScopeType;

    /// <summary>
    /// 获取用户的最大数据范围（取所有角色中的最大范围）
    /// 注意: 当前实现未按资源区分数据范围，返回用户所有角色中的最大范围
    /// TODO: 未来版本支持按资源区分数据权限
    /// </summary>
    function GetMaxDataScope(const UserID: Integer; const Resource: string): TDataScopeType;
  public
    constructor Create(const Connection: TFDConnection);
    destructor Destroy; override;

    function HasPermission(const UserID: Integer; const PermissionCode: string): Boolean;
    function GetUserPermissions(const UserID: Integer): TArray<TPermissionInfo>;
    function GetRoles(const UserID: Integer): TArray<TRoleInfo>;
    function AssignRoleToUser(const UserID, RoleID: Integer): Boolean;
    function RemoveRoleFromUser(const UserID, RoleID: Integer): Boolean;
    function GetDataScope(const UserID: Integer; const Resource: string): TDataScopeType;
    function HasRole(const UserID: Integer; const RoleCode: string): Boolean;
  end;

implementation

{ TUniAdminPermissionManager }

constructor TUniAdminPermissionManager.Create(const Connection: TFDConnection);
begin
  inherited Create;
  if not Assigned(Connection) then
    raise Exception.Create('Database connection cannot be nil');

  if not Connection.Connected then
    raise Exception.Create('Database connection is not open');

  FConnection := Connection;
  FPermissionCache := TDictionary<Integer, TArray<TPermissionInfo>>.Create;
  FRoleCache := TDictionary<Integer, TArray<TRoleInfo>>.Create;
  FCacheEnabled := True;
end;

destructor TUniAdminPermissionManager.Destroy;
begin
  ClearAllCache;
  FPermissionCache.Free;
  FRoleCache.Free;
  inherited;
end;

procedure TUniAdminPermissionManager.ClearAllCache;
begin
  ClearPermissionCache;
  ClearRoleCache;
end;

procedure TUniAdminPermissionManager.ClearPermissionCache;
begin
  FPermissionCache.Clear;
end;

procedure TUniAdminPermissionManager.ClearRoleCache;
begin
  FRoleCache.Clear;
end;

function TUniAdminPermissionManager.StringToDataScope(const Scope: string): TDataScopeType;
begin
  if SameText(Scope, 'ALL') then
    Result := dsAll
  else if SameText(Scope, 'CUSTOM') then
    Result := dsCustom
  else if SameText(Scope, 'DEPARTMENT') then
    Result := dsDepartment
  else if SameText(Scope, 'DEPARTMENT_AND_SUB') then
    Result := dsDepartmentAndSub
  else if SameText(Scope, 'SELF') then
    Result := dsSelf
  else
    Result := dsNone;
end;

function TUniAdminPermissionManager.HasPermission(const UserID: Integer;
  const PermissionCode: string): Boolean;
var
  LQuery: TFDQuery;
begin
  Result := False;

  if not Assigned(FConnection) then
    Exit;

  if PermissionCode.IsEmpty then
    Exit(True);

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT COUNT(*) AS CNT ' +
      'FROM UniAdmin_UserRoles ur ' +
      'JOIN UniAdmin_RolePermissions rp ON ur.RoleID = rp.RoleID ' +
      'JOIN UniAdmin_Permissions p ON rp.PermissionID = p.PermissionID ' +
      'WHERE ur.UserID = :UserID AND p.PermissionCode = :PermissionCode';

    LQuery.ParamByName('UserID').AsInteger := UserID;
    LQuery.ParamByName('PermissionCode').AsString := PermissionCode;

    try
      LQuery.Open;
      Result := (LQuery.FieldByName('CNT').AsInteger > 0);
    except
      on E: Exception do
        raise Exception.CreateFmt('Failed to check permission: %s', [E.Message]);
    end;
  finally
    LQuery.Free;
  end;
end;

function TUniAdminPermissionManager.GetUserPermissions(const UserID: Integer): TArray<TPermissionInfo>;
var
  LQuery: TFDQuery;
  LList: TList<TPermissionInfo>;
  LPermission: TPermissionInfo;
begin
  // 检查缓存（线程安全）
  TMonitor.Enter(FLock);
  try
    if FCacheEnabled and FPermissionCache.ContainsKey(UserID) then
      Exit(FPermissionCache[UserID]);
  finally
    TMonitor.Exit(FLock);
  end;

  LList := TList<TPermissionInfo>.Create;
  try
    if not Assigned(FConnection) then
      Exit(LList.ToArray);

    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := FConnection;
      LQuery.SQL.Text :=
        'SELECT DISTINCT p.PermissionID, p.PermissionCode, p.PermissionName, ' +
        'p.ResourceType, p.ResourceCode, p.Action, p.Description ' +
        'FROM UniAdmin_UserRoles ur ' +
        'JOIN UniAdmin_RolePermissions rp ON ur.RoleID = rp.RoleID ' +
        'JOIN UniAdmin_Permissions p ON rp.PermissionID = p.PermissionID ' +
        'WHERE ur.UserID = :UserID ' +
        'ORDER BY p.ResourceType, p.Action';

      LQuery.ParamByName('UserID').AsInteger := UserID;

      try
        LQuery.Open;
        while not LQuery.Eof do
        begin
          LPermission.PermissionID := LQuery.FieldByName('PermissionID').AsInteger;
          LPermission.PermissionCode := LQuery.FieldByName('PermissionCode').AsString;
          LPermission.PermissionName := LQuery.FieldByName('PermissionName').AsString;
          LPermission.ResourceType := LQuery.FieldByName('ResourceType').AsString;
          LPermission.ResourceCode := LQuery.FieldByName('ResourceCode').AsString;
          LPermission.Action := LQuery.FieldByName('Action').AsString;
          LPermission.Description := LQuery.FieldByName('Description').AsString;

          LList.Add(LPermission);
          LQuery.Next;
        end;
      except
        on E: Exception do
          raise Exception.CreateFmt('Failed to get user permissions: %s', [E.Message]);
      end;

      Result := LList.ToArray;

      // 缓存结果（线程安全）
      TMonitor.Enter(FLock);
      try
        if FCacheEnabled then
          FPermissionCache.AddOrSetValue(UserID, Result);
      finally
        TMonitor.Exit(FLock);
      end;
    finally
      LQuery.Free;
    end;
  finally
    LList.Free;
  end;
end;

function TUniAdminPermissionManager.GetRoles(const UserID: Integer): TArray<TRoleInfo>;
var
  LQuery: TFDQuery;
  LList: TList<TRoleInfo>;
  LRole: TRoleInfo;
begin
  // 检查缓存（线程安全）
  TMonitor.Enter(FLock);
  try
    if FCacheEnabled and FRoleCache.ContainsKey(UserID) then
      Exit(FRoleCache[UserID]);
  finally
    TMonitor.Exit(FLock);
  end;

  LList := TList<TRoleInfo>.Create;
  try
    if not Assigned(FConnection) then
      Exit(LList.ToArray);

    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := FConnection;
      LQuery.SQL.Text :=
        'SELECT r.RoleID, r.RoleCode, r.RoleName, r.Description, r.DataScope ' +
        'FROM UniAdmin_UserRoles ur ' +
        'JOIN UniAdmin_Roles r ON ur.RoleID = r.RoleID ' +
        'WHERE ur.UserID = :UserID ' +
        'ORDER BY r.RoleID';

      LQuery.ParamByName('UserID').AsInteger := UserID;

      try
        LQuery.Open;
        while not LQuery.Eof do
        begin
          LRole.RoleID := LQuery.FieldByName('RoleID').AsInteger;
          LRole.RoleCode := LQuery.FieldByName('RoleCode').AsString;
          LRole.RoleName := LQuery.FieldByName('RoleName').AsString;
          LRole.Description := LQuery.FieldByName('Description').AsString;
          LRole.DataScope := LQuery.FieldByName('DataScope').AsString;

          LList.Add(LRole);
          LQuery.Next;
        end;
      except
        on E: Exception do
          raise Exception.CreateFmt('Failed to get user roles: %s', [E.Message]);
      end;

      Result := LList.ToArray;

      // 缓存结果（线程安全）
      TMonitor.Enter(FLock);
      try
        if FCacheEnabled then
          FRoleCache.AddOrSetValue(UserID, Result);
      finally
        TMonitor.Exit(FLock);
      end;
    finally
      LQuery.Free;
    end;
  finally
    LList.Free;
  end;
end;

function TUniAdminPermissionManager.AssignRoleToUser(const UserID, RoleID: Integer): Boolean;
var
  LQuery: TFDQuery;
begin
  Result := False;

  // 输入验证
  if UserID <= 0 then
    raise Exception.Create('UserID must be greater than 0');
  if RoleID <= 0 then
    raise Exception.Create('RoleID must be greater than 0');

  if not Assigned(FConnection) then
    Exit;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;

    // 检查是否已存在
    LQuery.SQL.Text := 'SELECT COUNT(*) AS CNT FROM UniAdmin_UserRoles ' +
                      'WHERE UserID = :UserID AND RoleID = :RoleID';
    LQuery.ParamByName('UserID').AsInteger := UserID;
    LQuery.ParamByName('RoleID').AsInteger := RoleID;

    try
      LQuery.Open;
      if LQuery.FieldByName('CNT').AsInteger > 0 then
      begin
        // 已存在，无需重复分配
        Result := True;
        Exit;
      end;
    except
      on E: Exception do
        raise Exception.CreateFmt('Failed to check existing role assignment: %s', [E.Message]);
    end;

    // 插入新记录
    LQuery.Close;
    LQuery.SQL.Text := 'INSERT INTO UniAdmin_UserRoles (UserID, RoleID, CreatedDate) ' +
                      'VALUES (:UserID, :RoleID, CURRENT_TIMESTAMP)';
    LQuery.ParamByName('UserID').AsInteger := UserID;
    LQuery.ParamByName('RoleID').AsInteger := RoleID;

    try
      LQuery.ExecSQL;
      Result := (LQuery.RowsAffected > 0);

      if Result then
      begin
        // 清除缓存
        TMonitor.Enter(FLock);
        try
          FPermissionCache.Remove(UserID);
          FRoleCache.Remove(UserID);
        finally
          TMonitor.Exit(FLock);
        end;
      end;
    except
      on E: Exception do
        raise Exception.CreateFmt('Failed to assign role to user: %s', [E.Message]);
    end;
  finally
    LQuery.Free;
  end;
end;

function TUniAdminPermissionManager.RemoveRoleFromUser(const UserID, RoleID: Integer): Boolean;
var
  LQuery: TFDQuery;
begin
  Result := False;

  // 输入验证
  if UserID <= 0 then
    raise Exception.Create('UserID must be greater than 0');
  if RoleID <= 0 then
    raise Exception.Create('RoleID must be greater than 0');

  if not Assigned(FConnection) then
    Exit;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'DELETE FROM UniAdmin_UserRoles ' +
                      'WHERE UserID = :UserID AND RoleID = :RoleID';

    LQuery.ParamByName('UserID').AsInteger := UserID;
    LQuery.ParamByName('RoleID').AsInteger := RoleID;

    try
      LQuery.ExecSQL;
      Result := (LQuery.RowsAffected > 0);

      if Result then
      begin
        // 清除缓存
        TMonitor.Enter(FLock);
        try
          FPermissionCache.Remove(UserID);
          FRoleCache.Remove(UserID);
        finally
          TMonitor.Exit(FLock);
        end;
      end;
    except
      on E: Exception do
        raise Exception.CreateFmt('Failed to remove role from user: %s', [E.Message]);
    end;
  finally
    LQuery.Free;
  end;
end;

function TUniAdminPermissionManager.GetDataScope(const UserID: Integer;
  const Resource: string): TDataScopeType;
begin
  Result := GetMaxDataScope(UserID, Resource);
end;

function TUniAdminPermissionManager.GetMaxDataScope(const UserID: Integer;
  const Resource: string): TDataScopeType;
var
  LQuery: TFDQuery;
  LMaxScope: Integer;
  LCurrentScope: Integer;
  LScopeStr: string;
begin
  Result := dsNone; // 默认无权限

  if not Assigned(FConnection) then
    Exit;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT r.DataScope ' +
      'FROM UniAdmin_UserRoles ur ' +
      'JOIN UniAdmin_Roles r ON ur.RoleID = r.RoleID ' +
      'WHERE ur.UserID = :UserID';

    LQuery.ParamByName('UserID').AsInteger := UserID;

    LMaxScope := Ord(dsNone);

    try
      LQuery.Open;
      while not LQuery.Eof do
      begin
        LScopeStr := LQuery.FieldByName('DataScope').AsString;
        LCurrentScope := Ord(StringToDataScope(LScopeStr));

        if LCurrentScope > LMaxScope then
          LMaxScope := LCurrentScope;

        LQuery.Next;
      end;
    except
      on E: Exception do
        raise Exception.CreateFmt('Failed to get data scope: %s', [E.Message]);
    end;

    Result := TDataScopeType(LMaxScope);
  finally
    LQuery.Free;
  end;
end;

function TUniAdminPermissionManager.HasRole(const UserID: Integer;
  const RoleCode: string): Boolean;
var
  LQuery: TFDQuery;
begin
  Result := False;

  if not Assigned(FConnection) then
    Exit;

  if RoleCode.IsEmpty then
    Exit(False);

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT COUNT(*) AS CNT ' +
      'FROM UniAdmin_UserRoles ur ' +
      'JOIN UniAdmin_Roles r ON ur.RoleID = r.RoleID ' +
      'WHERE ur.UserID = :UserID AND r.RoleCode = :RoleCode';

    LQuery.ParamByName('UserID').AsInteger := UserID;
    LQuery.ParamByName('RoleCode').AsString := RoleCode;

    try
      LQuery.Open;
      Result := (LQuery.FieldByName('CNT').AsInteger > 0);
    except
      on E: Exception do
        raise Exception.CreateFmt('Failed to check role: %s', [E.Message]);
    end;
  finally
    LQuery.Free;
  end;
end;

initialization
  TUniAdminPermissionManager.FLock := TObject.Create;

finalization
  FreeAndNil(TUniAdminPermissionManager.FLock);

end.

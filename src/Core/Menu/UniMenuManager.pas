unit UniMenuManager;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.StrUtils,
  Data.DB, FireDAC.Comp.Client,
  UniMenuManager.Intf;

type
  /// <summary>
  /// 菜单管理器实现
  /// 提供线程安全的菜单树管理和权限过滤功能
  /// </summary>
  TUniMenuManager = class(TInterfacedObject, IUniMenuManager)
  private
    class var FInstance: IUniMenuManager;
    class var FLock: TObject;
    FConnection: TFDConnection;
    FMenuCache: TDictionary<Integer, TMenuItem>;
    FMenuTreeCache: TDictionary<Integer, TArray<TMenuItem>>;
    FCacheEnabled: Boolean;

    /// <summary>
    /// 从数据库加载所有菜单项
    /// </summary>
    function LoadAllMenus: TArray<TMenuItem>;

    /// <summary>
    /// 构建菜单树结构
    /// </summary>
    /// <param name="FlatMenus">扁平菜单列表</param>
    /// <returns>菜单树数组</returns>
    function BuildMenuTree(const FlatMenus: TArray<TMenuItem>): TArray<TMenuItem>;

    /// <summary>
    /// 根据用户权限过滤菜单
    /// </summary>
    /// <param name="Menus">菜单列表</param>
    /// <param name="UserPermissions">用户权限代码列表</param>
    /// <returns>过滤后的菜单列表</returns>
    function FilterMenusByPermission(const Menus: TArray<TMenuItem>;
      const UserPermissions: TArray<string>): TArray<TMenuItem>;

    /// <summary>
    /// 获取用户的所有权限代码
    /// </summary>
    function GetUserPermissionCodes(const UserID: Integer): TArray<string>;

    /// <summary>
    /// 递归查找子菜单
    /// </summary>
    function FindChildren(const ParentID: Integer;
      const FlatMenus: TArray<TMenuItem>): TArray<TMenuItem>;

    /// <summary>
    /// 递归过滤菜单树的子菜单
    /// </summary>
    function FilterMenuTree(const Menus: TArray<TMenuItem>;
      const UserPermissions: TArray<string>): TArray<TMenuItem>;

    /// <summary>
    /// 递归删除菜单及其所有子菜单
    /// </summary>
    function DeleteMenuRecursive(const MenuID: Integer): Boolean;

    /// <summary>
    /// 清空缓存（内部方法，不加锁）
    /// </summary>
    procedure ClearCache;

    /// <summary>
    /// 清空缓存（线程安全版本）
    /// </summary>
    procedure ClearCacheLocked;
  public
    constructor Create(const Connection: TFDConnection);
    destructor Destroy; override;

    function GetMenuTree(const UserID: Integer): TArray<TMenuItem>;
    function GetMenuByID(const MenuID: Integer): TMenuItem;
    function AddMenu(const Menu: TMenuItem): Boolean;
    function UpdateMenu(const Menu: TMenuItem): Boolean;
    function DeleteMenu(const MenuID: Integer): Boolean;
    function GetUserMenus(const UserID: Integer): TArray<TMenuItem>;
    procedure RefreshCache;

    /// <summary>
    /// 获取菜单管理器实例
    /// </summary>
    class function GetInstance(const Connection: TFDConnection): IUniMenuManager; static;
  end;

implementation

{ TUniMenuManager }

class function TUniMenuManager.GetInstance(const Connection: TFDConnection): IUniMenuManager;
begin
  if FInstance = nil then
  begin
    TMonitor.Enter(FLock);
    try
      if FInstance = nil then
        FInstance := TUniMenuManager.Create(Connection);
    finally
      TMonitor.Exit(FLock);
    end;
  end;
  Result := FInstance;
end;

constructor TUniMenuManager.Create(const Connection: TFDConnection);
begin
  inherited Create;
  if not Assigned(Connection) then
    raise Exception.Create('Database connection cannot be nil');

  if not Connection.Connected then
    raise Exception.Create('Database connection is not open');

  FConnection := Connection;
  FMenuCache := TDictionary<Integer, TMenuItem>.Create;
  FMenuTreeCache := TDictionary<Integer, TArray<TMenuItem>>.Create;
  FCacheEnabled := True;
end;

destructor TUniMenuManager.Destroy;
begin
  TMonitor.Enter(FLock);
  try
    ClearCache;
  finally
    TMonitor.Exit(FLock);
  end;
  FMenuCache.Free;
  FMenuTreeCache.Free;
  inherited;
end;

procedure TUniMenuManager.ClearCache;
var
  LMenuItem: TMenuItem;
  LKeys: TArray<Integer>;
  I: Integer;
begin
  // 获取所有键并释放动态数组
  LKeys := FMenuCache.Keys.ToArray;
  for I := 0 to High(LKeys) do
  begin
    if FMenuCache.TryGetValue(LKeys[I], LMenuItem) then
      SetLength(LMenuItem.Children, 0);
  end;
  FMenuCache.Clear;
  FMenuTreeCache.Clear;
end;

/// <summary>
/// 清空缓存（线程安全版本）
/// </summary>
procedure TUniMenuManager.ClearCacheLocked;
begin
  TMonitor.Enter(FLock);
  try
    ClearCache;
  finally
    TMonitor.Exit(FLock);
  end;
end;

function TUniMenuManager.LoadAllMenus: TArray<TMenuItem>;
var
  LQuery: TFDQuery;
  LList: TList<TMenuItem>;
  LMenu: TMenuItem;
begin
  LList := TList<TMenuItem>.Create;
  try
    if not Assigned(FConnection) then
      raise Exception.Create('Database connection is not assigned');

    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := FConnection;
      LQuery.SQL.Text :=
        'SELECT MenuID, ParentID, MenuName, MenuCode, Icon, RoutePath, ' +
        'PermissionCode, SortOrder, IsVisible ' +
        'FROM UniAdmin_Menus ' +
        'ORDER BY SortOrder ASC, MenuID ASC';

      try
        LQuery.Open;
        while not LQuery.Eof do
        begin
          LMenu.MenuID := LQuery.FieldByName('MenuID').AsInteger;
          LMenu.ParentID := LQuery.FieldByName('ParentID').AsInteger;
          LMenu.MenuName := LQuery.FieldByName('MenuName').AsString;
          LMenu.MenuCode := LQuery.FieldByName('MenuCode').AsString;
          LMenu.Icon := LQuery.FieldByName('Icon').AsString;
          LMenu.RoutePath := LQuery.FieldByName('RoutePath').AsString;
          LMenu.PermissionCode := LQuery.FieldByName('PermissionCode').AsString;
          LMenu.SortOrder := LQuery.FieldByName('SortOrder').AsInteger;
          LMenu.IsVisible := LQuery.FieldByName('IsVisible').AsInteger <> 0;
          SetLength(LMenu.Children, 0);

          LList.Add(LMenu);
          LQuery.Next;
        end;
      except
        on E: Exception do
          raise Exception.CreateFmt('Failed to load menus: %s', [E.Message]);
      end;

      Result := LList.ToArray;
    finally
      LQuery.Free;
    end;
  finally
    LList.Free;
  end;
end;

function TUniMenuManager.FindChildren(const ParentID: Integer;
  const FlatMenus: TArray<TMenuItem>): TArray<TMenuItem>;
var
  LList: TList<TMenuItem>;
  LMenu: TMenuItem;
begin
  LList := TList<TMenuItem>.Create;
  try
    for LMenu in FlatMenus do
    begin
      if LMenu.ParentID = ParentID then
        LList.Add(LMenu);
    end;
    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

function TUniMenuManager.BuildMenuTree(const FlatMenus: TArray<TMenuItem>): TArray<TMenuItem>;
var
  LRootMenus: TArray<TMenuItem>;
  LMenuQueue: TQueue<TMenuItem>;
  LCurrent: TMenuItem;
  LChildren: TArray<TMenuItem>;
  LChild: TMenuItem;
begin
  // 找到所有根菜单（ParentID = 0 或 ParentID 不存在于列表中）
  LRootMenus := FindChildren(0, FlatMenus);

  // 构建树形结构 - 使用队列代替栈+Delete(0)以获得O(n)性能
  LMenuQueue := TQueue<TMenuItem>.Create;
  try
    // 初始化：将所有根菜单加入队列
    for LChild in LRootMenus do
      LMenuQueue.Enqueue(LChild);

    while LMenuQueue.Count > 0 do
    begin
      LCurrent := LMenuQueue.Dequeue;

      // 查找当前菜单的子菜单
      LChildren := FindChildren(LCurrent.MenuID, FlatMenus);
      if Length(LChildren) > 0 then
      begin
        LCurrent.Children := LChildren;
        // 将子菜单加入队列继续处理
        for LChild in LChildren do
          LMenuQueue.Enqueue(LChild);
      end;
    end;
  finally
    LMenuQueue.Free;
  end;

  Result := LRootMenus;
end;

function TUniMenuManager.GetUserPermissionCodes(const UserID: Integer): TArray<string>;
var
  LQuery: TFDQuery;
  LList: TList<string>;
begin
  LList := TList<string>.Create;
  try
    if not Assigned(FConnection) then
      Exit(LList.ToArray);

    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := FConnection;
      LQuery.SQL.Text :=
        'SELECT DISTINCT p.PermissionCode ' +
        'FROM UniAdmin_UserRoles ur ' +
        'JOIN UniAdmin_RolePermissions rp ON ur.RoleID = rp.RoleID ' +
        'JOIN UniAdmin_Permissions p ON rp.PermissionID = p.PermissionID ' +
        'WHERE ur.UserID = :UserID';

      LQuery.ParamByName('UserID').AsInteger := UserID;

      try
        LQuery.Open;
        while not LQuery.Eof do
        begin
          LList.Add(LQuery.FieldByName('PermissionCode').AsString);
          LQuery.Next;
        end;
      except
        on E: Exception do
        begin
          // 静默失败 - 返回空数组
        end;
      end;

      Result := LList.ToArray;
    finally
      LQuery.Free;
    end;
  finally
    LList.Free;
  end;
end;

function TUniMenuManager.FilterMenuTree(const Menus: TArray<TMenuItem>;
  const UserPermissions: TArray<string>): TArray<TMenuItem>;
var
  I, J: Integer;
  LFilteredList: TList<TMenuItem>;
  LMenu, LFilteredMenu: TMenuItem;
  LFilteredChildren: TArray<TMenuItem>;
  LHasPermission: Boolean;
begin
  LFilteredList := TList<TMenuItem>.Create;
  try
    for I := 0 to High(Menus) do
    begin
      LMenu := Menus[I];

      // 检查菜单权限：
      // 1. 如果菜单没有权限码要求，默认允许访问
      // 2. 如果用户有权限列表且菜单权限码在列表中，则允许访问
      // 注意：修复了原逻辑错误 - 当用户权限为空时不应该显示所有菜单
      LHasPermission := (LMenu.PermissionCode = '') or
                       ((Length(UserPermissions) > 0) and
                        (MatchText(LMenu.PermissionCode, UserPermissions)));

      if LHasPermission then
      begin
        LFilteredMenu := LMenu;
        // 递归过滤子菜单
        if Length(LMenu.Children) > 0 then
        begin
          LFilteredChildren := FilterMenuTree(LMenu.Children, UserPermissions);
          LFilteredMenu.Children := LFilteredChildren;
          // 如果没有子菜单了，但父菜单可见，仍然保留
        end;
        LFilteredList.Add(LFilteredMenu);
      end;
    end;
    Result := LFilteredList.ToArray;
  finally
    LFilteredList.Free;
  end;
end;

function TUniMenuManager.FilterMenusByPermission(const Menus: TArray<TMenuItem>;
  const UserPermissions: TArray<string>): TArray<TMenuItem>;
begin
  Result := FilterMenuTree(Menus, UserPermissions);
end;

function TUniMenuManager.GetMenuTree(const UserID: Integer): TArray<TMenuItem>;
var
  LAllMenus: TArray<TMenuItem>;
  LUserPermissions: TArray<string>;
begin
  // 检查缓存（线程安全）
  TMonitor.Enter(FLock);
  try
    if FCacheEnabled and FMenuTreeCache.ContainsKey(UserID) then
      Exit(FMenuTreeCache[UserID]);
  finally
    TMonitor.Exit(FLock);
  end;

  if not Assigned(FConnection) then
    raise Exception.Create('Database connection is not assigned');

  // 加载所有菜单
  LAllMenus := LoadAllMenus;

  // 构建菜单树
  LAllMenus := BuildMenuTree(LAllMenus);

  // 获取用户权限
  LUserPermissions := GetUserPermissionCodes(UserID);

  // 过滤菜单
  Result := FilterMenusByPermission(LAllMenus, LUserPermissions);

  // 缓存结果（线程安全）
  TMonitor.Enter(FLock);
  try
    if FCacheEnabled then
      FMenuTreeCache.AddOrSetValue(UserID, Result);
  finally
    TMonitor.Exit(FLock);
  end;
end;

function TUniMenuManager.GetMenuByID(const MenuID: Integer): TMenuItem;
var
  LQuery: TFDQuery;
begin
  Result.MenuID := 0;
  Result.ParentID := 0;
  Result.MenuName := '';
  Result.MenuCode := '';
  Result.Icon := '';
  Result.RoutePath := '';
  Result.PermissionCode := '';
  Result.SortOrder := 0;
  Result.IsVisible := False;
  SetLength(Result.Children, 0);

  if not Assigned(FConnection) then
    Exit;

  // 检查缓存（线程安全）
  TMonitor.Enter(FLock);
  try
    if FCacheEnabled and FMenuCache.ContainsKey(MenuID) then
      Exit(FMenuCache[MenuID]);
  finally
    TMonitor.Exit(FLock);
  end;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT MenuID, ParentID, MenuName, MenuCode, Icon, RoutePath, ' +
      'PermissionCode, SortOrder, IsVisible ' +
      'FROM UniAdmin_Menus ' +
      'WHERE MenuID = :MenuID';

    LQuery.ParamByName('MenuID').AsInteger := MenuID;

    try
      LQuery.Open;
      if not LQuery.Eof then
      begin
        Result.MenuID := LQuery.FieldByName('MenuID').AsInteger;
        Result.ParentID := LQuery.FieldByName('ParentID').AsInteger;
        Result.MenuName := LQuery.FieldByName('MenuName').AsString;
        Result.MenuCode := LQuery.FieldByName('MenuCode').AsString;
        Result.Icon := LQuery.FieldByName('Icon').AsString;
        Result.RoutePath := LQuery.FieldByName('RoutePath').AsString;
        Result.PermissionCode := LQuery.FieldByName('PermissionCode').AsString;
        Result.SortOrder := LQuery.FieldByName('SortOrder').AsInteger;
        Result.IsVisible := LQuery.FieldByName('IsVisible').AsInteger <> 0;
        SetLength(Result.Children, 0);

        // 缓存结果（线程安全）
        TMonitor.Enter(FLock);
        try
          if FCacheEnabled then
            FMenuCache.AddOrSetValue(MenuID, Result);
        finally
          TMonitor.Exit(FLock);
        end;
      end;
    except
      on E: Exception do
        raise Exception.CreateFmt('Failed to get menu by ID: %s', [E.Message]);
    end;
  finally
    LQuery.Free;
  end;
end;

function TUniMenuManager.AddMenu(const Menu: TMenuItem): Boolean;
var
  LQuery: TFDQuery;
  LNewMenuID: Integer;
begin
  Result := False;

  // 输入验证
  if Trim(Menu.MenuName) = '' then
    raise Exception.Create('MenuName cannot be empty');
  if Trim(Menu.MenuCode) = '' then
    raise Exception.Create('MenuCode cannot be empty');

  if not Assigned(FConnection) then
    Exit;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'INSERT INTO UniAdmin_Menus ' +
      '(ParentID, MenuName, MenuCode, Icon, RoutePath, PermissionCode, SortOrder, IsVisible) ' +
      'VALUES (:ParentID, :MenuName, :MenuCode, :Icon, :RoutePath, :PermissionCode, :SortOrder, :IsVisible)';

    LQuery.ParamByName('ParentID').AsInteger := Menu.ParentID;
    LQuery.ParamByName('MenuName').AsString := Menu.MenuName;
    LQuery.ParamByName('MenuCode').AsString := Menu.MenuCode;
    LQuery.ParamByName('Icon').AsString := Menu.Icon;
    LQuery.ParamByName('RoutePath').AsString := Menu.RoutePath;
    LQuery.ParamByName('PermissionCode').AsString := Menu.PermissionCode;
    LQuery.ParamByName('SortOrder').AsInteger := Menu.SortOrder;
    LQuery.ParamByName('IsVisible').AsBoolean := Menu.IsVisible;

    try
      LQuery.ExecSQL;
      Result := True;

      // 清除缓存
      RefreshCache;
    except
      on E: Exception do
        raise Exception.CreateFmt('Failed to add menu: %s', [E.Message]);
    end;
  finally
    LQuery.Free;
  end;
end;

function TUniMenuManager.UpdateMenu(const Menu: TMenuItem): Boolean;
var
  LQuery: TFDQuery;
begin
  Result := False;

  // 输入验证
  if Menu.MenuID <= 0 then
    raise Exception.Create('MenuID must be greater than 0');
  if Trim(Menu.MenuName) = '' then
    raise Exception.Create('MenuName cannot be empty');
  if Trim(Menu.MenuCode) = '' then
    raise Exception.Create('MenuCode cannot be empty');

  if not Assigned(FConnection) then
    Exit;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'UPDATE UniAdmin_Menus SET ' +
      'ParentID = :ParentID, ' +
      'MenuName = :MenuName, ' +
      'MenuCode = :MenuCode, ' +
      'Icon = :Icon, ' +
      'RoutePath = :RoutePath, ' +
      'PermissionCode = :PermissionCode, ' +
      'SortOrder = :SortOrder, ' +
      'IsVisible = :IsVisible ' +
      'WHERE MenuID = :MenuID';

    LQuery.ParamByName('ParentID').AsInteger := Menu.ParentID;
    LQuery.ParamByName('MenuName').AsString := Menu.MenuName;
    LQuery.ParamByName('MenuCode').AsString := Menu.MenuCode;
    LQuery.ParamByName('Icon').AsString := Menu.Icon;
    LQuery.ParamByName('RoutePath').AsString := Menu.RoutePath;
    LQuery.ParamByName('PermissionCode').AsString := Menu.PermissionCode;
    LQuery.ParamByName('SortOrder').AsInteger := Menu.SortOrder;
    LQuery.ParamByName('IsVisible').AsBoolean := Menu.IsVisible;
    LQuery.ParamByName('MenuID').AsInteger := Menu.MenuID;

    try
      LQuery.ExecSQL;
      Result := (LQuery.RowsAffected > 0);

      // 清除缓存
      RefreshCache;
    except
      on E: Exception do
        raise Exception.CreateFmt('Failed to update menu: %s', [E.Message]);
    end;
  finally
    LQuery.Free;
  end;
end;

function TUniMenuManager.DeleteMenuRecursive(const MenuID: Integer): Boolean;
var
  LQuery: TFDQuery;
  LChildIDs: TList<Integer>;
  LChildID: Integer;
begin
  Result := False;

  if not Assigned(FConnection) then
    Exit;

  // 首先获取所有子菜单ID
  LChildIDs := TList<Integer>.Create;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'SELECT MenuID FROM UniAdmin_Menus WHERE ParentID = :MenuID';
    LQuery.ParamByName('MenuID').AsInteger := MenuID;

    try
      LQuery.Open;
      while not LQuery.Eof do
      begin
        LChildIDs.Add(LQuery.FieldByName('MenuID').AsInteger);
        LQuery.Next;
      end;
    except
      on E: Exception do
        raise Exception.CreateFmt('Failed to query child menus: %s', [E.Message]);
    end;

    // 递归删除所有子菜单
    for LChildID in LChildIDs do
    begin
      DeleteMenuRecursive(LChildID);
    end;

    // 删除当前菜单
    LQuery.Close;
    LQuery.SQL.Text := 'DELETE FROM UniAdmin_Menus WHERE MenuID = :MenuID';
    LQuery.ParamByName('MenuID').AsInteger := MenuID;

    try
      LQuery.ExecSQL;
      Result := (LQuery.RowsAffected > 0);
    except
      on E: Exception do
        raise Exception.CreateFmt('Failed to delete menu: %s', [E.Message]);
    end;
  finally
    LChildIDs.Free;
    LQuery.Free;
  end;
end;

function TUniMenuManager.DeleteMenu(const MenuID: Integer): Boolean;
begin
  // 输入验证
  if MenuID <= 0 then
    raise Exception.Create('MenuID must be greater than 0');

  Result := DeleteMenuRecursive(MenuID);

  if Result then
    RefreshCache;
end;

function TUniMenuManager.GetUserMenus(const UserID: Integer): TArray<TMenuItem>;
var
  LMenuTree: TArray<TMenuItem>;
  LFlatList: TList<TMenuItem>;

  procedure FlattenMenuTree(const Menus: TArray<TMenuItem>);
  var
    I: Integer;
  begin
    for I := 0 to High(Menus) do
    begin
      LFlatList.Add(Menus[I]);
      if Length(Menus[I].Children) > 0 then
        FlattenMenuTree(Menus[I].Children);
    end;
  end;

begin
  LFlatList := TList<TMenuItem>.Create;
  try
    LMenuTree := GetMenuTree(UserID);
    FlattenMenuTree(LMenuTree);
    Result := LFlatList.ToArray;
  finally
    LFlatList.Free;
  end;
end;

procedure TUniMenuManager.RefreshCache;
begin
  TMonitor.Enter(FLock);
  try
    ClearCache;
  finally
    TMonitor.Exit(FLock);
  end;
end;

initialization
  TUniMenuManager.FLock := TObject.Create;

finalization
  TUniMenuManager.FInstance := nil;
  FreeAndNil(TUniMenuManager.FLock);

end.

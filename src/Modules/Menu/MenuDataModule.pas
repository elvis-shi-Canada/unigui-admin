unit MenuDataModule;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Generics.Collections,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Stan.Param,
  UniContext, UniPlugin.Types, UniDataModule;

type
  /// <summary>
  /// 菜单信息记录
  /// </summary>
  TMenuInfo = record
    MenuID: Integer;
    MenuName: string;
    MenuCode: string;
    ParentID: Integer;
    MenuType: string; // directory(目录), menu(菜单), button(按钮)
    Icon: string;
    Path: string;
    Component: string;
    Permission: string;
    SortOrder: Integer;
    Visible: Integer;
    Status: Integer;
    Description: string;
    CreatedDate: TDateTime;
    ModifiedDate: TDateTime;
  end;

  /// <summary>
  /// 菜单树节点
  /// </summary>
  TMenuTreeNode = record
    MenuID: Integer;
    MenuName: string;
    MenuCode: string;
    ParentID: Integer;
    MenuType: string;
    Icon: string;
    Path: string;
    Component: string;
    Permission: string;
    SortOrder: Integer;
    Visible: Integer;
    Status: Integer;
    HasChildren: Boolean;
    Level: Integer;
  end;

  /// <summary>
  /// 菜单数据模块 - 提供菜单表的 CRUD 操作和树形结构管理
  /// </summary>
  TMenuDataModule = class(TUniDataModule)
  private
    function MenuCodeExists(const MenuCode: string; ExcludeMenuID: Integer = 0): Boolean;
    function ValidateMenuType(const MenuType: string): Boolean;
    function GetChildrenCount(MenuID: Integer): Integer;
    function GetMaxSortOrder(ParentID: Integer): Integer;
    procedure UpdatePath(MenuID: Integer);
    procedure ReorderSiblings(ParentID: Integer);
  public
    /// <summary>
    /// 根据 ID 获取菜单信息
    /// </summary>
    function GetMenuByID(MenuID: Integer): TDataSet;

    /// <summary>
    /// 根据编码获取菜单信息
    /// </summary>
    function GetMenuByCode(const MenuCode: string): TDataSet;

    /// <summary>
    /// 获取菜单列表（支持筛选）
    /// </summary>
    function GetMenus(const Filter: string; Status: Integer = -1): TDataSet;

    /// <summary>
    /// 获取菜单树形结构
    /// </summary>
    function GetMenuTree(IncludeDisabled: Boolean = False): TDataSet;

    /// <summary>
    /// 获取指定父节点下的子菜单
    /// </summary>
    function GetChildMenus(ParentID: Integer; IncludeDisabled: Boolean = False): TDataSet;

    /// <summary>
    /// 获取菜单路径（从根到当前节点的完整路径）
    /// </summary>
    function GetMenuPath(MenuID: Integer): string;

    /// <summary>
    /// 创建新菜单
    /// </summary>
    function CreateMenu(const MenuCode, MenuName: string; ParentID: Integer;
      const MenuType, Icon, Path, Component, Permission: string;
      SortOrder: Integer = 0): Integer;

    /// <summary>
    /// 更新菜单信息
    /// </summary>
    procedure UpdateMenu(MenuID: Integer; const MenuName, Icon, Path, Component,
      Permission: string; SortOrder: Integer = -1; Visible: Integer = -1; Status: Integer = -1);

    /// <summary>
    /// 删除菜单
    /// </summary>
    procedure DeleteMenu(MenuID: Integer);

    /// <summary>
    /// 设置菜单状态
    /// </summary>
    procedure SetMenuStatus(MenuID: Integer; Status: Integer);

    /// <summary>
    /// 设置菜单可见性
    /// </summary>
    procedure SetMenuVisible(MenuID: Integer; Visible: Integer);

    /// <summary>
    /// 移动菜单到新的父节点
    /// </summary>
    procedure MoveMenu(MenuID, NewParentID: Integer; NewSortOrder: Integer = -1);

    /// <summary>
    /// 复制菜单（包括子菜单）
    /// </summary>
    function CopyMenu(MenuID, TargetParentID: Integer): Integer;

    /// <summary>
    /// 检查菜单是否有子节点
    /// </summary>
    function HasChildren(MenuID: Integer): Boolean;

    /// <summary>
    /// 获取菜单的所有子节点ID（递归）
    /// </summary>
    function GetAllChildIDs(MenuID: Integer): TArray<Integer>;

    /// <summary>
    /// 获取用户可访问的菜单（基于权限）
    /// </summary>
    function GetUserMenus(UserID: Integer): TDataSet;

    /// <summary>
    /// 获取角色可访问的菜单（基于权限）
    /// </summary>
    function GetRoleMenus(RoleID: Integer): TDataSet;

    /// <summary>
    /// 构建菜单树（用于前端渲染）
    /// </summary>
    function BuildMenuTree(UserID: Integer): TList<TMenuTreeNode>;

    /// <summary>
    /// 获取菜单统计信息（子菜单数、可见子菜单数）
    /// </summary>
    function GetMenuStats(MenuID: Integer): TDataSet;
  end;

implementation

{ TMenuDataModule }

function TMenuDataModule.GetMenuByID(MenuID: Integer): TDataSet;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'SELECT m.*, ' +
      '(SELECT COUNT(*) FROM UniAdmin_Menus WHERE ParentID = m.MenuID) AS ChildCount, ' +
      'p.MenuName AS ParentName ' +
      'FROM UniAdmin_Menus m ' +
      'LEFT JOIN UniAdmin_Menus p ON m.ParentID = p.MenuID ' +
      'WHERE m.MenuID = :MenuID';
    LQuery.Params.ParamByName('MenuID').AsInteger := MenuID;
    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    raise;
  end;
end;

function TMenuDataModule.GetMenuByCode(const MenuCode: string): TDataSet;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'SELECT m.*, ' +
      '(SELECT COUNT(*) FROM UniAdmin_Menus WHERE ParentID = m.MenuID) AS ChildCount, ' +
      'p.MenuName AS ParentName ' +
      'FROM UniAdmin_Menus m ' +
      'LEFT JOIN UniAdmin_Menus p ON m.ParentID = p.MenuID ' +
      'WHERE m.MenuCode = :MenuCode';
    LQuery.Params.ParamByName('MenuCode').AsString := MenuCode;
    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    raise;
  end;
end;

function TMenuDataModule.GetMenus(const Filter: string; Status: Integer): TDataSet;
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

    LSQL := 'SELECT m.*, ' +
            'p.MenuName AS ParentName, ' +
            '(SELECT COUNT(*) FROM UniAdmin_Menus WHERE ParentID = m.MenuID) AS ChildCount ' +
            'FROM UniAdmin_Menus m ' +
            'LEFT JOIN UniAdmin_Menus p ON m.ParentID = p.MenuID';

    if Filter <> '' then
      LWhereList.Add('(m.MenuCode LIKE :Filter OR m.MenuName LIKE :Filter)');

    if Status >= 0 then
      LWhereList.Add('m.Status = :Status');

    if LWhereList.Count > 0 then
    begin
      LWhere := ' WHERE ' + LWhereList.Text.Replace(#13#10, ' AND ');
      LSQL := LSQL + LWhere;
    end;

    LSQL := LSQL + ' ORDER BY m.ParentID, m.SortOrder, m.MenuID';

    LQuery.SQL.Text := LSQL;

    if Filter <> '' then
      LQuery.Params.ParamByName('Filter').AsString := '%' + Filter + '%';

    if Status >= 0 then
      LQuery.Params.ParamByName('Status').AsInteger := Status;

    LQuery.Open;
    Result := LQuery;
    LQuery := nil;
  finally
    LWhereList.Free;
    if Assigned(LQuery) then
      LQuery.Free;
  end;
end;

function TMenuDataModule.GetMenuTree(IncludeDisabled: Boolean): TDataSet;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'SELECT MenuID, MenuCode, MenuName, ParentID, MenuType, Icon, Path, ' +
      'Component, Permission, SortOrder, Visible, Status, ' +
      'CAST(0 AS BIT) AS HasChildren, ' +
      'CAST(0 AS INT) AS Level ' +
      'FROM UniAdmin_Menus ';

    if not IncludeDisabled then
      LQuery.SQL.Text := LQuery.SQL.Text + 'WHERE Status = 1 ';

    LQuery.SQL.Text := LQuery.SQL.Text + 'ORDER BY ParentID, SortOrder, MenuID';

    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    raise;
  end;
end;

function TMenuDataModule.GetChildMenus(ParentID: Integer; IncludeDisabled: Boolean): TDataSet;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'SELECT MenuID, MenuCode, MenuName, ParentID, MenuType, Icon, Path, ' +
      'Component, Permission, SortOrder, Visible, Status ' +
      'FROM UniAdmin_Menus ' +
      'WHERE ParentID = :ParentID ';

    if not IncludeDisabled then
      LQuery.SQL.Text := LQuery.SQL.Text + 'AND Status = 1 ';

    LQuery.SQL.Text := LQuery.SQL.Text + 'ORDER BY SortOrder, MenuID';

    LQuery.Params.ParamByName('ParentID').AsInteger := ParentID;
    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    raise;
  end;
end;

function TMenuDataModule.GetMenuPath(MenuID: Integer): string;
var
  LQuery: TFDQuery;
  LPath: string;
  LParentID: Integer;
begin
  Result := '';
  LPath := '';
  LParentID := MenuID;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;

    // 递归构建路径
    while LParentID > 0 do
    begin
      LQuery.SQL.Text := 'SELECT MenuID, MenuName, ParentID FROM UniAdmin_Menus WHERE MenuID = :MenuID';
      LQuery.Params.ParamByName('MenuID').AsInteger := LParentID;
      LQuery.Open;

      if LQuery.Eof then
        Break;

      if LPath <> '' then
        LPath := LQuery.FieldByName('MenuName').AsString + ' > ' + LPath
      else
        LPath := LQuery.FieldByName('MenuName').AsString;

      LParentID := LQuery.FieldByName('ParentID').AsInteger;
      LQuery.Close;
    end;

    Result := LPath;
  finally
    LQuery.Free;
  end;
end;

function TMenuDataModule.CreateMenu(const MenuCode, MenuName: string; ParentID: Integer;
  const MenuType, Icon, Path, Component, Permission: string; SortOrder: Integer): Integer;
var
  LQuery: TFDQuery;
  LActualSortOrder: Integer;
begin
  // 验证输入
  if MenuCode.Trim.IsEmpty then
    raise Exception.Create('菜单编码不能为空');

  if MenuName.Trim.IsEmpty then
    raise Exception.Create('菜单名称不能为空');

  if not ValidateMenuType(MenuType) then
    raise Exception.Create('菜单类型参数无效');

  if MenuCodeExists(MenuCode) then
    raise Exception.Create('菜单编码已存在');

  // 验证父节点存在
  if ParentID > 0 then
  begin
    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := Connection;
      LQuery.SQL.Text := 'SELECT COUNT(*) AS Cnt FROM UniAdmin_Menus WHERE MenuID = :ParentID';
      LQuery.Params.ParamByName('ParentID').AsInteger := ParentID;
      LQuery.Open;

      if LQuery.FieldByName('Cnt').AsInteger = 0 then
        raise Exception.Create('父菜单不存在');
    finally
      LQuery.Free;
    end;
  end;

  // 自动排序
  if SortOrder < 0 then
    LActualSortOrder := GetMaxSortOrder(ParentID) + 10
  else
    LActualSortOrder := SortOrder;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'INSERT INTO UniAdmin_Menus ' +
      '(MenuCode, MenuName, ParentID, MenuType, Icon, Path, Component, Permission, ' +
      'SortOrder, Visible, Status, CreatedDate, ModifiedDate) ' +
      'VALUES (:MenuCode, :MenuName, :ParentID, :MenuType, :Icon, :Path, :Component, ' +
      ':Permission, :SortOrder, 1, 1, GETDATE(), GETDATE())';

    LQuery.Params.ParamByName('MenuCode').AsString := MenuCode;
    LQuery.Params.ParamByName('MenuName').AsString := MenuName;
    LQuery.Params.ParamByName('ParentID').AsInteger := ParentID;
    LQuery.Params.ParamByName('MenuType').AsString := MenuType;
    LQuery.Params.ParamByName('Icon').AsString := Icon;
    LQuery.Params.ParamByName('Path').AsString := Path;
    LQuery.Params.ParamByName('Component').AsString := Component;
    LQuery.Params.ParamByName('Permission').AsString := Permission;
    LQuery.Params.ParamByName('SortOrder').AsInteger := LActualSortOrder;

    LQuery.ExecSQL;

    LQuery.SQL.Text := 'SELECT SCOPE_IDENTITY() AS NewID';
    LQuery.Open;
    Result := LQuery.FieldByName('NewID').AsInteger;
  finally
    LQuery.Free;
  end;
end;

procedure TMenuDataModule.UpdateMenu(MenuID: Integer; const MenuName, Icon, Path, Component,
  Permission: string; SortOrder: Integer; Visible: Integer; Status: Integer);
var
  LQuery: TFDQuery;
  LSQL: TStringList;
  LUpdates: TStringList;
  LNeedSortOrder: Boolean;
  LNeedVisible: Boolean;
  LNeedStatus: Boolean;
begin
  if MenuName.Trim.IsEmpty then
    raise Exception.Create('菜单名称不能为空');

  LQuery := TFDQuery.Create(nil);
  LUpdates := TStringList.Create;
  try
    LQuery.Connection := Connection;

    LNeedSortOrder := (SortOrder >= 0);
    LNeedVisible := (Visible >= 0);
    LNeedStatus := (Status >= 0);

    LUpdates.Add('MenuName = :MenuName');
    LUpdates.Add('Icon = :Icon');
    LUpdates.Add('Path = :Path');
    LUpdates.Add('Component = :Component');
    LUpdates.Add('Permission = :Permission');

    if LNeedSortOrder then
      LUpdates.Add('SortOrder = :SortOrder');

    if LNeedVisible then
      LUpdates.Add('Visible = :Visible');

    if LNeedStatus then
      LUpdates.Add('Status = :Status');

    LUpdates.Add('ModifiedDate = GETDATE()');

    LSQL := TStringList.Create;
    try
      LSQL.Add('UPDATE UniAdmin_Menus SET ' + LUpdates.Text.Replace(#13#10, ', '));
      LSQL.Add('WHERE MenuID = :MenuID');

      LQuery.SQL.Text := LSQL.Text.Replace(#13#10, ' ');

      LQuery.Params.ParamByName('MenuID').AsInteger := MenuID;
      LQuery.Params.ParamByName('MenuName').AsString := MenuName;
      LQuery.Params.ParamByName('Icon').AsString := Icon;
      LQuery.Params.ParamByName('Path').AsString := Path;
      LQuery.Params.ParamByName('Component').AsString := Component;
      LQuery.Params.ParamByName('Permission').AsString := Permission;

      if LNeedSortOrder then
        LQuery.Params.ParamByName('SortOrder').AsInteger := SortOrder;

      if LNeedVisible then
        LQuery.Params.ParamByName('Visible').AsInteger := Visible;

      if LNeedStatus then
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

procedure TMenuDataModule.DeleteMenu(MenuID: Integer);
var
  LQuery: TFDQuery;
  LChildCount: Integer;
  LChildIDs: TArray<Integer>;
  LID: Integer;
begin
  // 检查是否有子菜单
  LChildCount := GetChildrenCount(MenuID);
  if LChildCount > 0 then
  begin
    // 递归删除所有子菜单
    LChildIDs := GetAllChildIDs(MenuID);
    for LID in LChildIDs do
    begin
      DeleteMenu(LID);
    end;
  end;

  Connection.StartTransaction;
  try
    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := Connection;
      LQuery.SQL.Text := 'DELETE FROM UniAdmin_Menus WHERE MenuID = :MenuID';
      LQuery.Params.ParamByName('MenuID').AsInteger := MenuID;
      LQuery.ExecSQL;

      Connection.Commit;
    finally
      LQuery.Free;
    end;
  except
    Connection.Rollback;
    raise;
  end;
end;

procedure TMenuDataModule.SetMenuStatus(MenuID: Integer; Status: Integer);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'UPDATE UniAdmin_Menus ' +
      'SET Status = :Status, ModifiedDate = GETDATE() ' +
      'WHERE MenuID = :MenuID';

    LQuery.Params.ParamByName('MenuID').AsInteger := MenuID;
    LQuery.Params.ParamByName('Status').AsInteger := Status;

    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

procedure TMenuDataModule.SetMenuVisible(MenuID: Integer; Visible: Integer);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'UPDATE UniAdmin_Menus ' +
      'SET Visible = :Visible, ModifiedDate = GETDATE() ' +
      'WHERE MenuID = :MenuID';

    LQuery.Params.ParamByName('MenuID').AsInteger := MenuID;
    LQuery.Params.ParamByName('Visible').AsInteger := Visible;

    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

procedure TMenuDataModule.MoveMenu(MenuID, NewParentID: Integer; NewSortOrder: Integer);
var
  LQuery: TFDQuery;
  LActualSortOrder: Integer;
begin
  // 验证新父节点存在
  if NewParentID > 0 then
  begin
    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := Connection;
      LQuery.SQL.Text := 'SELECT COUNT(*) AS Cnt FROM UniAdmin_Menus WHERE MenuID = :ParentID';
      LQuery.Params.ParamByName('ParentID').AsInteger := NewParentID;
      LQuery.Open;

      if LQuery.FieldByName('Cnt').AsInteger = 0 then
        raise Exception.Create('目标父菜单不存在');
    finally
      LQuery.Free;
    end;
  end;

  // 自动排序
  if NewSortOrder < 0 then
    LActualSortOrder := GetMaxSortOrder(NewParentID) + 10
  else
    LActualSortOrder := NewSortOrder;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'UPDATE UniAdmin_Menus ' +
      'SET ParentID = :ParentID, SortOrder = :SortOrder, ModifiedDate = GETDATE() ' +
      'WHERE MenuID = :MenuID';

    LQuery.Params.ParamByName('MenuID').AsInteger := MenuID;
    LQuery.Params.ParamByName('ParentID').AsInteger := NewParentID;
    LQuery.Params.ParamByName('SortOrder').AsInteger := LActualSortOrder;

    LQuery.ExecSQL;

    // 重新排序同级节点
    ReorderSiblings(NewParentID);
  finally
    LQuery.Free;
  end;
end;

function TMenuDataModule.CopyMenu(MenuID, TargetParentID: Integer): Integer;
var
  LQuery: TFDQuery;
  LSourceInfo: TDataSet;
  LNewMenuID: Integer;
  LNewCode: string;
  I: Integer;
begin
  // 获取源菜单信息
  LSourceInfo := GetMenuByID(MenuID);
  try
    if LSourceInfo.Eof then
      raise Exception.Create('源菜单不存在');

    // 生成新编码
    LNewCode := LSourceInfo.FieldByName('MenuCode').AsString + '_copy';
    I := 1;
    while MenuCodeExists(LNewCode) do
    begin
      LNewCode := LSourceInfo.FieldByName('MenuCode').AsString + '_copy' + IntToStr(I);
      Inc(I);
    end;

    // 创建新菜单
    LNewMenuID := CreateMenu(
      LNewCode,
      LSourceInfo.FieldByName('MenuName').AsString + ' (副本)',
      TargetParentID,
      LSourceInfo.FieldByName('MenuType').AsString,
      LSourceInfo.FieldByName('Icon').AsString,
      LSourceInfo.FieldByName('Path').AsString,
      LSourceInfo.FieldByName('Component').AsString,
      LSourceInfo.FieldByName('Permission').AsString,
      LSourceInfo.FieldByName('SortOrder').AsInteger
    );

    // 递归复制子菜单
    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := Connection;
      LQuery.SQL.Text := 'SELECT MenuID FROM UniAdmin_Menus WHERE ParentID = :ParentID ORDER BY SortOrder';
      LQuery.Params.ParamByName('ParentID').AsInteger := MenuID;
      LQuery.Open;

      while not LQuery.Eof do
      begin
        CopyMenu(LQuery.FieldByName('MenuID').AsInteger, LNewMenuID);
        LQuery.Next;
      end;
    finally
      LQuery.Free;
    end;

    Result := LNewMenuID;
  finally
    LSourceInfo.Free;
  end;
end;

function TMenuDataModule.HasChildren(MenuID: Integer): Boolean;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text := 'SELECT COUNT(*) AS Cnt FROM UniAdmin_Menus WHERE ParentID = :MenuID';
    LQuery.Params.ParamByName('MenuID').AsInteger := MenuID;
    LQuery.Open;
    Result := LQuery.FieldByName('Cnt').AsInteger > 0;
  finally
    LQuery.Free;
  end;
end;

function TMenuDataModule.GetAllChildIDs(MenuID: Integer): TArray<Integer>;
var
  LQuery: TFDQuery;
  LList: TList<Integer>;
begin
  LList := TList<Integer>.Create;
  try
    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := Connection;

      // 递归查询所有子节点
      LQuery.SQL.Text :=
        'WITH MenuCTE AS (' +
        '  SELECT MenuID FROM UniAdmin_Menus WHERE ParentID = :MenuID ' +
        '  UNION ALL ' +
        '  SELECT m.MenuID FROM UniAdmin_Menus m ' +
        '  INNER JOIN MenuCTE c ON m.ParentID = c.MenuID ' +
        ') ' +
        'SELECT MenuID FROM MenuCTE';

      LQuery.Params.ParamByName('MenuID').AsInteger := MenuID;
      LQuery.Open;

      while not LQuery.Eof do
      begin
        LList.Add(LQuery.FieldByName('MenuID').AsInteger);
        LQuery.Next;
      end;
    finally
      LQuery.Free;
    end;

    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

function TMenuDataModule.GetUserMenus(UserID: Integer): TDataSet;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'SELECT DISTINCT m.* ' +
      'FROM UniAdmin_Menus m ' +
      'WHERE m.Status = 1 AND m.Visible = 1 ' +
      'AND (m.Permission = '''' OR m.Permission IS NULL OR EXISTS (' +
      '  SELECT 1 FROM UniAdmin_RolePermissions rp ' +
      '  INNER JOIN UniAdmin_UserRoles ur ON rp.RoleID = ur.RoleID ' +
      '  WHERE ur.UserID = :UserID AND rp.PermissionID IN (' +
      '    SELECT PermissionID FROM UniAdmin_Permissions WHERE PermissionCode = m.Permission ' +
      '  ) ' +
      ')) ' +
      'ORDER BY m.ParentID, m.SortOrder, m.MenuID';

    LQuery.Params.ParamByName('UserID').AsInteger := UserID;
    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    raise;
  end;
end;

function TMenuDataModule.GetRoleMenus(RoleID: Integer): TDataSet;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'SELECT DISTINCT m.* ' +
      'FROM UniAdmin_Menus m ' +
      'WHERE m.Status = 1 AND m.Visible = 1 ' +
      'AND (m.Permission = '''' OR m.Permission IS NULL OR EXISTS (' +
      '  SELECT 1 FROM UniAdmin_RolePermissions rp ' +
      '  WHERE rp.RoleID = :RoleID AND rp.PermissionID IN (' +
      '    SELECT PermissionID FROM UniAdmin_Permissions WHERE PermissionCode = m.Permission ' +
      '  ) ' +
      ')) ' +
      'ORDER BY m.ParentID, m.SortOrder, m.MenuID';

    LQuery.Params.ParamByName('RoleID').AsInteger := RoleID;
    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    raise;
  end;
end;

function TMenuDataModule.BuildMenuTree(UserID: Integer): TList<TMenuTreeNode>;
var
  LDataSet: TDataSet;
  LList: TList<TMenuTreeNode>;
  LNode: TMenuTreeNode;
begin
  LList := TList<TMenuTreeNode>.Create;
  try
    LDataSet := GetUserMenus(UserID);
    try
      while not LDataSet.Eof do
      begin
        LNode.MenuID := LDataSet.FieldByName('MenuID').AsInteger;
        LNode.MenuName := LDataSet.FieldByName('MenuName').AsString;
        LNode.MenuCode := LDataSet.FieldByName('MenuCode').AsString;
        LNode.ParentID := LDataSet.FieldByName('ParentID').AsInteger;
        LNode.MenuType := LDataSet.FieldByName('MenuType').AsString;
        LNode.Icon := LDataSet.FieldByName('Icon').AsString;
        LNode.Path := LDataSet.FieldByName('Path').AsString;
        LNode.Component := LDataSet.FieldByName('Component').AsString;
        LNode.Permission := LDataSet.FieldByName('Permission').AsString;
        LNode.SortOrder := LDataSet.FieldByName('SortOrder').AsInteger;
        LNode.Visible := LDataSet.FieldByName('Visible').AsInteger;
        LNode.Status := LDataSet.FieldByName('Status').AsInteger;
        LNode.HasChildren := False;
        LNode.Level := 0;

        LList.Add(LNode);
        LDataSet.Next;
      end;
    finally
      LDataSet.Free;
    end;

    Result := LList;
  except
    LList.Free;
    raise;
  end;
end;

function TMenuDataModule.GetMenuStats(MenuID: Integer): TDataSet;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'SELECT ' +
      '(SELECT COUNT(*) FROM UniAdmin_Menus WHERE ParentID = :MenuID) AS ChildCount, ' +
      '(SELECT COUNT(*) FROM UniAdmin_Menus WHERE ParentID = :MenuID AND Visible = 1) AS VisibleChildCount, ' +
      '(SELECT COUNT(*) FROM UniAdmin_Menus WHERE ParentID = :MenuID AND Status = 1) AS ActiveChildCount';

    LQuery.Params.ParamByName('MenuID').AsInteger := MenuID;
    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    raise;
  end;
end;

// 私有方法

function TMenuDataModule.MenuCodeExists(const MenuCode: string; ExcludeMenuID: Integer): Boolean;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;

    if ExcludeMenuID > 0 then
    begin
      LQuery.SQL.Text := 'SELECT COUNT(*) AS Cnt FROM UniAdmin_Menus WHERE MenuCode = :MenuCode AND MenuID <> :ExcludeMenuID';
      LQuery.Params.ParamByName('ExcludeMenuID').AsInteger := ExcludeMenuID;
    end
    else
    begin
      LQuery.SQL.Text := 'SELECT COUNT(*) AS Cnt FROM UniAdmin_Menus WHERE MenuCode = :MenuCode';
    end;

    LQuery.Params.ParamByName('MenuCode').AsString := MenuCode;
    LQuery.Open;
    Result := LQuery.FieldByName('Cnt').AsInteger > 0;
  finally
    LQuery.Free;
  end;
end;

function TMenuDataModule.ValidateMenuType(const MenuType: string): Boolean;
begin
  Result := (MenuType = 'directory') or (MenuType = 'menu') or (MenuType = 'button');
end;

function TMenuDataModule.GetChildrenCount(MenuID: Integer): Integer;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text := 'SELECT COUNT(*) AS Cnt FROM UniAdmin_Menus WHERE ParentID = :MenuID';
    LQuery.Params.ParamByName('MenuID').AsInteger := MenuID;
    LQuery.Open;
    Result := LQuery.FieldByName('Cnt').AsInteger;
  finally
    LQuery.Free;
  end;
end;

function TMenuDataModule.GetMaxSortOrder(ParentID: Integer): Integer;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text := 'SELECT ISNULL(MAX(SortOrder), 0) AS MaxSort FROM UniAdmin_Menus WHERE ParentID = :ParentID';
    LQuery.Params.ParamByName('ParentID').AsInteger := ParentID;
    LQuery.Open;
    Result := LQuery.FieldByName('MaxSort').AsInteger;
  finally
    LQuery.Free;
  end;
end;

procedure TMenuDataModule.UpdatePath(MenuID: Integer);
begin
  // TODO: 实现路径更新逻辑（如果使用缓存路径）
end;

procedure TMenuDataModule.ReorderSiblings(ParentID: Integer);
var
  LQuery: TFDQuery;
  LSQL: string;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LSQL :=
      'WITH OrderedMenus AS (' +
      '  SELECT MenuID, ROW_NUMBER() OVER (ORDER BY SortOrder, MenuID) AS NewOrder ' +
      '  FROM UniAdmin_Menus WHERE ParentID = :ParentID' +
      ') ' +
      'UPDATE m ' +
      'SET SortOrder = om.NewOrder * 10 ' +
      'FROM UniAdmin_Menus m ' +
      'INNER JOIN OrderedMenus om ON m.MenuID = om.MenuID';

    LQuery.SQL.Text := LSQL;
    LQuery.Params.ParamByName('ParentID').AsInteger := ParentID;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

end.

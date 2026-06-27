unit SystemMenuSetup;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  Data.DB,
  UniContext, UniPlugin.Types,
  UniAdminMenuManager;

type
  /// <summary>
  /// 菜单项信息记录
  /// </summary>
  TMenuItemInfo = record
    MenuName: string;
    MenuCode: string;
    ParentCode: string;
    Icon: string;
    RoutePath: string;
    PermissionCode: string;
    SortOrder: Integer;
    IsVisible: Boolean;
    Description: string;
  end;

  /// <summary>
  /// 权限信息记录
  /// </summary>
  TPermissionInfo = record
    PermissionCode: string;
    PermissionName: string;
    Category: string;
    Description: string;
  end;

  /// <summary>
  /// 系统菜单设置器
  /// 负责初始化和设置系统管理主菜单
  /// </summary>
  TSystemMenuSetup = class
  public
    /// <summary>初始化系统管理菜单</summary>
    class procedure InitializeSystemMenus(const ADataModule: TDataModule);

    /// <summary>获取系统管理菜单定义</summary>
    class function GetSystemMenuDefinitions: TList<TMenuItemInfo>;

    /// <summary>获取权限定义</summary>
    class function GetPermissionDefinitions: TList<TPermissionInfo>;

    /// <summary>合并 ModelAdmin 注册中心的声明到菜单定义
    /// 已手写的菜单（按 MenuCode 匹配）不会被覆盖，保证向后兼容。
    /// </summary>
    class function BuildMenusFromRegistry(
      const ABaseList: TList<TMenuItemInfo>): TList<TMenuItemInfo>;

    /// <summary>合并 ModelAdmin 注册中心的声明到权限定义
    /// 为每个 ModelAdmin 派生 view/add/edit/delete 四件套权限。
    /// 已手写的权限（按 PermissionCode 匹配）不会被覆盖。
    /// </summary>
    class function BuildPermissionsFromRegistry(
      const ABaseList: TList<TPermissionInfo>): TList<TPermissionInfo>;
  end;

implementation

uses
  UniModelAdmin.Intf, UniModelAdmin;

{ TSystemMenuSetup }

class procedure TSystemMenuSetup.InitializeSystemMenus(const ADataModule: TDataModule);
var
  LMenuDefs: TList<TMenuItemInfo>;
  LPermDefs: TList<TPermissionInfo>;
  LMenuItem: TMenuItemInfo;
  LPermission: TPermissionInfo;
begin
  // 获取菜单定义
  LMenuDefs := GetSystemMenuDefinitions;
  try
    // 获取权限定义
    LPermDefs := GetPermissionDefinitions;
    try
      // TODO: 将菜单和权限插入数据库
      // 这里需要在实际实现中根据具体的数据模块进行操作
      // 示例代码：
      // for LMenuItem in LMenuDefs do
      //   CreateMenuItem(ADataModule, LMenuItem);
      //
      // for LPermission in LPermDefs do
      //   CreatePermission(ADataModule, LPermission);
    finally
      LPermDefs.Free;
    end;
  finally
    LMenuDefs.Free;
  end;
end;

class function TSystemMenuSetup.GetSystemMenuDefinitions: TList<TMenuItemInfo>;
var
  LList: TList<TMenuItemInfo>;
  LItem: TMenuItemInfo;

  procedure AddItem(const MenuName, MenuCode, ParentCode, Icon, RoutePath,
    PermissionCode: string; SortOrder: Integer; IsVisible: Boolean;
    const Description: string);
  begin
    LItem.MenuName := MenuName;
    LItem.MenuCode := MenuCode;
    LItem.ParentCode := ParentCode;
    LItem.Icon := Icon;
    LItem.RoutePath := RoutePath;
    LItem.PermissionCode := PermissionCode;
    LItem.SortOrder := SortOrder;
    LItem.IsVisible := IsVisible;
    LItem.Description := Description;
    LList.Add(LItem);
  end;

begin
  LList := TList<TMenuItemInfo>.Create;

  // ========== 系统管理主菜单 ==========
  AddItem('系统管理', 'system', '', 'settings.png', '/system',
    'system:view', 100, True, '系统管理主菜单');

  // ========== 用户管理 ==========
  AddItem('用户管理', 'system:user', 'system', 'user.png', 'TUserListFrame',
    'user:view', 110, True, '用户账号管理');
  AddItem('用户列表', 'system:user:list', 'system:user', 'list.png', '/system/user/list',
    'user:view', 111, True, '');
  AddItem('新增用户', 'system:user:add', 'system:user', 'add.png', '/system/user/add',
    'user:add', 112, True, '');
  AddItem('编辑用户', 'system:user:edit', 'system:user', 'edit.png', '/system/user/edit',
    'user:edit', 113, True, '');
  AddItem('删除用户', 'system:user:delete', 'system:user', 'delete.png', '/system/user/delete',
    'user:delete', 114, True, '');

  // ========== 角色管理 ==========
  AddItem('角色管理', 'system:role', 'system', 'users.png', 'TRoleListFrame',
    'role:view', 120, True, '角色权限管理');
  AddItem('角色列表', 'system:role:list', 'system:role', 'list.png', '/system/role/list',
    'role:view', 121, True, '');
  AddItem('新增角色', 'system:role:add', 'system:role', 'add.png', '/system/role/add',
    'role:add', 122, True, '');
  AddItem('编辑角色', 'system:role:edit', 'system:role', 'edit.png', '/system/role/edit',
    'role:edit', 123, True, '');
  AddItem('删除角色', 'system:role:delete', 'system:role', 'delete.png', '/system/role/delete',
    'role:delete', 124, True, '');
  AddItem('分配权限', 'system:role:permission', 'system:role', 'key.png', '/system/role/permission',
    'role:assign-permission', 125, True, '');
  AddItem('分配用户', 'system:role:user', 'system:role', 'user-plus.png', '/system/role/user',
    'role:assign-user', 126, True, '');

  // ========== 菜单管理 ==========
  AddItem('菜单管理', 'system:menu', 'system', 'menu.png', 'TMenuTreeFrame',
    'menu:view', 130, True, '系统菜单管理');
  AddItem('菜单树', 'system:menu:tree', 'system:menu', 'tree.png', '/system/menu/tree',
    'menu:view', 131, True, '');
  AddItem('新增菜单', 'system:menu:add', 'system:menu', 'add.png', '/system/menu/add',
    'menu:add', 132, True, '');
  AddItem('编辑菜单', 'system:menu:edit', 'system:menu', 'edit.png', '/system/menu/edit',
    'menu:edit', 133, True, '');
  AddItem('删除菜单', 'system:menu:delete', 'system:menu', 'delete.png', '/system/menu/delete',
    'menu:delete', 134, True, '');

  // ========== 数据字典 ==========
  AddItem('数据字典', 'system:dictionary', 'system', 'book.png', '/system/dictionary',
    'dictionary:view', 140, True, '数据字典管理');
  AddItem('字典类型', 'system:dictionary:type', 'system:dictionary', 'type.png', '/system/dictionary/type',
    'dictionary:view', 141, True, '');
  AddItem('字典项', 'system:dictionary:item', 'system:dictionary', 'item.png', '/system/dictionary/item',
    'dictionary:view', 142, True, '');

  // ========== 系统配置 ==========
  AddItem('系统配置', 'system:config', 'system', 'config.png', '/system/config',
    'config:view', 150, True, '系统参数配置');
  AddItem('系统设置', 'system:config:system', 'system:config', 'settings.png', '/system/config/system',
    'config:view', 151, True, '');
  AddItem('安全设置', 'system:config:security', 'system:config', 'security.png', '/system/config/security',
    'config:view', 152, True, '');
  AddItem('邮件设置', 'system:config:email', 'system:config', 'email.png', '/system/config/email',
    'config:view', 153, True, '');

  // ========== 日志审计 ==========
  AddItem('日志审计', 'system:log', 'system', 'file-text.png', '/system/log',
    'log:view', 160, True, '系统日志查询');
  AddItem('登录日志', 'system:log:login', 'system:log', 'login.png', '/system/log/login',
    'log:login', 161, True, '');
  AddItem('操作日志', 'system:log:operation', 'system:log', 'operation.png', '/system/log/operation',
    'log:operation', 162, True, '');
  AddItem('数据变更日志', 'system:log:datachange', 'system:log', 'database.png', '/system/log/datachange',
    'log:datachange', 163, True, '');

  // ========== 定时任务 ==========
  AddItem('定时任务', 'system:scheduler', 'system', 'clock.png', '/system/scheduler',
    'scheduler:view', 170, True, '定时任务管理');
  AddItem('任务列表', 'system:scheduler:list', 'system:scheduler', 'list.png', '/system/scheduler/list',
    'scheduler:view', 171, True, '');
  AddItem('新增任务', 'system:scheduler:add', 'system:scheduler', 'add.png', '/system/scheduler/add',
    'scheduler:add', 172, True, '');
  AddItem('编辑任务', 'system:scheduler:edit', 'system:scheduler', 'edit.png', '/system/scheduler/edit',
    'scheduler:edit', 173, True, '');
  AddItem('删除任务', 'system:scheduler:delete', 'system:scheduler', 'delete.png', '/system/scheduler/delete',
    'scheduler:delete', 174, True, '');
  AddItem('任务日志', 'system:scheduler:log', 'system:scheduler', 'file.png', '/system/scheduler/log',
    'scheduler:log', 175, True, '');

  // ========== 共享组件 ==========
  AddItem('共享组件', 'system:shared', 'system', 'share.png', '/system/shared',
    'shared:view', 180, True, '共享组件管理');
  AddItem('图标选择器', 'system:shared:icon', 'system:shared', 'icon.png', 'TIconSelector',
    'shared:view', 181, True, '');

  // 合并 ModelAdmin 注册中心的声明式菜单（单一真值源）
  Result := BuildMenusFromRegistry(LList);
end;

class function TSystemMenuSetup.GetPermissionDefinitions: TList<TPermissionInfo>;
var
  LList: TList<TPermissionInfo>;
  LItem: TPermissionInfo;

  procedure AddPerm(const Code, Name, Category, Description: string);
  begin
    LItem.PermissionCode := Code;
    LItem.PermissionName := Name;
    LItem.Category := Category;
    LItem.Description := Description;
    LList.Add(LItem);
  end;

begin
  LList := TList<TPermissionInfo>.Create;

  // ========== 用户管理权限 ==========
  AddPerm('user:view', '查看用户', '用户管理', '查看用户列表和详情');
  AddPerm('user:add', '新增用户', '用户管理', '创建新用户');
  AddPerm('user:edit', '编辑用户', '用户管理', '编辑用户信息');
  AddPerm('user:delete', '删除用户', '用户管理', '删除用户账号');
  AddPerm('user:password', '重置密码', '用户管理', '重置用户密码');
  AddPerm('user:status', '修改状态', '用户管理', '启用/禁用用户');

  // ========== 角色管理权限 ==========
  AddPerm('role:view', '查看角色', '角色管理', '查看角色列表和详情');
  AddPerm('role:add', '新增角色', '角色管理', '创建新角色');
  AddPerm('role:edit', '编辑角色', '角色管理', '编辑角色信息');
  AddPerm('role:delete', '删除角色', '角色管理', '删除角色');
  AddPerm('role:assign-permission', '分配权限', '角色管理', '为角色分配权限');
  AddPerm('role:assign-user', '分配用户', '角色管理', '为角色分配用户');

  // ========== 菜单管理权限 ==========
  AddPerm('menu:view', '查看菜单', '菜单管理', '查看菜单树');
  AddPerm('menu:add', '新增菜单', '菜单管理', '创建新菜单');
  AddPerm('menu:edit', '编辑菜单', '菜单管理', '编辑菜单信息');
  AddPerm('menu:delete', '删除菜单', '菜单管理', '删除菜单');
  AddPerm('menu:sort', '菜单排序', '菜单管理', '调整菜单顺序');

  // ========== 数据字典权限 ==========
  AddPerm('dictionary:view', '查看字典', '数据字典', '查看数据字典');
  AddPerm('dictionary:add', '新增字典', '数据字典', '创建字典类型和项');
  AddPerm('dictionary:edit', '编辑字典', '数据字典', '编辑字典信息');
  AddPerm('dictionary:delete', '删除字典', '数据字典', '删除字典类型和项');

  // ========== 系统配置权限 ==========
  AddPerm('config:view', '查看配置', '系统配置', '查看系统配置');
  AddPerm('config:edit', '修改配置', '系统配置', '修改系统参数');
  AddPerm('config:system', '系统设置', '系统配置', '管理系统设置');
  AddPerm('config:security', '安全设置', '系统配置', '管理安全设置');

  // ========== 日志审计权限 ==========
  AddPerm('log:login', '登录日志', '日志审计', '查看登录日志');
  AddPerm('log:operation', '操作日志', '日志审计', '查看操作日志');
  AddPerm('log:datachange', '数据变更日志', '日志审计', '查看数据变更日志');
  AddPerm('log:export', '日志导出', '日志审计', '导出日志数据');

  // ========== 定时任务权限 ==========
  AddPerm('scheduler:view', '查看任务', '定时任务', '查看定时任务');
  AddPerm('scheduler:add', '新增任务', '定时任务', '创建新任务');
  AddPerm('scheduler:edit', '编辑任务', '定时任务', '编辑任务信息');
  AddPerm('scheduler:delete', '删除任务', '定时任务', '删除任务');
  AddPerm('scheduler:start', '启动任务', '定时任务', '启动定时任务');
  AddPerm('scheduler:stop', '停止任务', '定时任务', '停止定时任务');
  AddPerm('scheduler:log', '任务日志', '定时任务', '查看任务执行日志');

  // ========== 共享组件权限 ==========
  AddPerm('shared:view', '查看共享组件', '共享组件', '查看共享组件');

  // 合并 ModelAdmin 注册中心的声明式权限（单一真值源）
  Result := BuildPermissionsFromRegistry(LList);
end;

class function TSystemMenuSetup.BuildMenusFromRegistry(
  const ABaseList: TList<TMenuItemInfo>): TList<TMenuItemInfo>;
var
  LAdmin: TModelAdmin;
  LItem: TMenuItemInfo;
  LExistingCodes: TDictionary<string, Boolean>;
  LItem2: TMenuItemInfo;
begin
  Result := TList<TMenuItemInfo>.Create;
  LExistingCodes := TDictionary<string, Boolean>.Create;
  try
    // 先拷贝基线菜单，记录已有 MenuCode（值类型 record 自动深拷贝）
    for LItem2 in ABaseList do
    begin
      Result.Add(LItem2);
      LExistingCodes.Add(LowerCase(LItem2.MenuCode), True);
    end;

    // 遍历注册中心，为每个 ModelAdmin 补一个菜单项
    for LAdmin in TModelAdminRegistry.CreateInstance.GetAll do
    begin
      LItem.MenuCode := 'system:' + LAdmin.AdminID;
      if LExistingCodes.ContainsKey(LowerCase(LItem.MenuCode)) then
        Continue;  // 已手写定义则尊重，不重复

      LItem.MenuName := LAdmin.DisplayName;
      LItem.ParentCode := LAdmin.ParentMenuCode;
      if LItem.ParentCode = '' then
        LItem.ParentCode := 'system';
      LItem.Icon := LAdmin.Icon;
      // RoutePath 用类名，交给 MdiRouter 的 FindClass 解析
      if LAdmin.FrameClassName <> '' then
        LItem.RoutePath := LAdmin.FrameClassName
      else
        LItem.RoutePath := 'TAutoCrudFrame';
      LItem.PermissionCode := LAdmin.PermissionPrefix + ':view';
      LItem.SortOrder := LAdmin.SortOrder;
      LItem.IsVisible := True;
      LItem.Description := LAdmin.DisplayName + '（自动注册）';
      Result.Add(LItem);
      LExistingCodes.Add(LowerCase(LItem.MenuCode), True);
    end;
  finally
    LExistingCodes.Free;
  end;
end;

class function TSystemMenuSetup.BuildPermissionsFromRegistry(
  const ABaseList: TList<TPermissionInfo>): TList<TPermissionInfo>;
const
  // 标准 CRUD 权限后缀
  CRUD_SUFFIXES: array[0..3] of string = ('view', 'add', 'edit', 'delete');
var
  LAdmin: TModelAdmin;
  LSuffix: string;
  LPerm: TPermissionInfo;
  LExistingCodes: TDictionary<string, Boolean>;
  LItem: TPermissionInfo;
begin
  Result := TList<TPermissionInfo>.Create;
  LExistingCodes := TDictionary<string, Boolean>.Create;
  try
    for LItem in ABaseList do
    begin
      Result.Add(LItem);
      LExistingCodes.Add(LowerCase(LItem.PermissionCode), True);
    end;

    for LAdmin in TModelAdminRegistry.CreateInstance.GetAll do
    begin
      for LSuffix in CRUD_SUFFIXES do
      begin
        LPerm.PermissionCode := LAdmin.PermissionPrefix + ':' + LSuffix;
        if LExistingCodes.ContainsKey(LowerCase(LPerm.PermissionCode)) then
          Continue;
        LPerm.PermissionName := LAdmin.DisplayName + ' ' + LSuffix;
        LPerm.Category := LAdmin.DisplayName;
        LPerm.Description := LAdmin.DisplayName + ' 的 ' + LSuffix + ' 权限';
        Result.Add(LPerm);
        LExistingCodes.Add(LowerCase(LPerm.PermissionCode), True);
      end;
    end;
  finally
    LExistingCodes.Free;
  end;
end;

end.

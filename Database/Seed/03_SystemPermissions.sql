-- =====================================================
-- UniAdmin Phase 3 - 系统权限初始化脚本
-- =====================================================
-- 功能: 初始化系统管理模块的所有权限
-- 版本: 1.0.0
-- 日期: 2026-02-24
-- =====================================================

-- 清除旧的系统权限数据（可选，用于重新初始化）
-- DELETE FROM UniAdmin_Permissions WHERE PermissionCode LIKE 'user:%'
--    OR PermissionCode LIKE 'role:%'
--    OR PermissionCode LIKE 'menu:%'
--    OR PermissionCode LIKE 'dictionary:%'
--    OR PermissionCode LIKE 'config:%'
--    OR PermissionCode LIKE 'log:%'
--    OR PermissionCode LIKE 'scheduler:%';

-- =====================================================
-- 1. 用户管理权限
-- =====================================================
INSERT INTO UniAdmin_Permissions (PermissionCode, PermissionName, Category, Description, SortOrder, CreatedDate, CreatedBy)
VALUES
  ('user:view', '查看用户', '用户管理', '查看用户列表和详情', 101, GETDATE(), 1),
  ('user:add', '新增用户', '用户管理', '创建新用户账号', 102, GETDATE(), 1),
  ('user:edit', '编辑用户', '用户管理', '编辑用户信息', 103, GETDATE(), 1),
  ('user:delete', '删除用户', '用户管理', '删除用户账号', 104, GETDATE(), 1),
  ('user:password', '重置密码', '用户管理', '重置用户密码', 105, GETDATE(), 1),
  ('user:status', '修改状态', '用户管理', '启用/禁用用户', 106, GETDATE(), 1);

-- =====================================================
-- 2. 角色管理权限
-- =====================================================
INSERT INTO UniAdmin_Permissions (PermissionCode, PermissionName, Category, Description, SortOrder, CreatedDate, CreatedBy)
VALUES
  ('role:view', '查看角色', '角色管理', '查看角色列表和详情', 201, GETDATE(), 1),
  ('role:add', '新增角色', '角色管理', '创建新角色', 202, GETDATE(), 1),
  ('role:edit', '编辑角色', '角色管理', '编辑角色信息', 203, GETDATE(), 1),
  ('role:delete', '删除角色', '角色管理', '删除角色', 204, GETDATE(), 1),
  ('role:assign-permission', '分配权限', '角色管理', '为角色分配权限', 205, GETDATE(), 1),
  ('role:assign-user', '分配用户', '角色管理', '为角色分配用户', 206, GETDATE(), 1);

-- =====================================================
-- 3. 菜单管理权限
-- =====================================================
INSERT INTO UniAdmin_Permissions (PermissionCode, PermissionName, Category, Description, SortOrder, CreatedDate, CreatedBy)
VALUES
  ('menu:view', '查看菜单', '菜单管理', '查看菜单树结构', 301, GETDATE(), 1),
  ('menu:add', '新增菜单', '菜单管理', '创建新菜单项', 302, GETDATE(), 1),
  ('menu:edit', '编辑菜单', '菜单管理', '编辑菜单信息', 303, GETDATE(), 1),
  ('menu:delete', '删除菜单', '菜单管理', '删除菜单项', 304, GETDATE(), 1),
  ('menu:sort', '菜单排序', '菜单管理', '调整菜单显示顺序', 305, GETDATE(), 1);

-- =====================================================
-- 4. 数据字典权限
-- =====================================================
INSERT INTO UniAdmin_Permissions (PermissionCode, PermissionName, Category, Description, SortOrder, CreatedDate, CreatedBy)
VALUES
  ('dictionary:view', '查看字典', '数据字典', '查看数据字典', 401, GETDATE(), 1),
  ('dictionary:add', '新增字典', '数据字典', '创建字典类型和字典项', 402, GETDATE(), 1),
  ('dictionary:edit', '编辑字典', '数据字典', '编辑字典信息', 403, GETDATE(), 1),
  ('dictionary:delete', '删除字典', '数据字典', '删除字典类型和字典项', 404, GETDATE(), 1);

-- =====================================================
-- 5. 系统配置权限
-- =====================================================
INSERT INTO UniAdmin_Permissions (PermissionCode, PermissionName, Category, Description, SortOrder, CreatedDate, CreatedBy)
VALUES
  ('config:view', '查看配置', '系统配置', '查看系统配置参数', 501, GETDATE(), 1),
  ('config:edit', '修改配置', '系统配置', '修改系统配置参数', 502, GETDATE(), 1),
  ('config:system', '系统设置', '系统配置', '管理系统基础设置', 503, GETDATE(), 1),
  ('config:security', '安全设置', '系统配置', '管理系统安全设置', 504, GETDATE(), 1);

-- =====================================================
-- 6. 日志审计权限
-- =====================================================
INSERT INTO UniAdmin_Permissions (PermissionCode, PermissionName, Category, Description, SortOrder, CreatedDate, CreatedBy)
VALUES
  ('log:login', '登录日志', '日志审计', '查看用户登录日志', 601, GETDATE(), 1),
  ('log:operation', '操作日志', '日志审计', '查看用户操作日志', 602, GETDATE(), 1),
  ('log:datachange', '数据变更日志', '日志审计', '查看数据变更日志', 603, GETDATE(), 1),
  ('log:export', '日志导出', '日志审计', '导出日志数据', 604, GETDATE(), 1);

-- =====================================================
-- 7. 定时任务权限
-- =====================================================
INSERT INTO UniAdmin_Permissions (PermissionCode, PermissionName, Category, Description, SortOrder, CreatedDate, CreatedBy)
VALUES
  ('scheduler:view', '查看任务', '定时任务', '查看定时任务列表', 701, GETDATE(), 1),
  ('scheduler:add', '新增任务', '定时任务', '创建新定时任务', 702, GETDATE(), 1),
  ('scheduler:edit', '编辑任务', '定时任务', '编辑任务信息', 703, GETDATE(), 1),
  ('scheduler:delete', '删除任务', '定时任务', '删除定时任务', 704, GETDATE(), 1),
  ('scheduler:start', '启动任务', '定时任务', '启动定时任务', 705, GETDATE(), 1),
  ('scheduler:stop', '停止任务', '定时任务', '停止定时任务', 706, GETDATE(), 1),
  ('scheduler:log', '任务日志', '定时任务', '查看任务执行日志', 707, GETDATE(), 1);

-- =====================================================
-- 8. 初始化系统菜单
-- =====================================================

-- 8.1 系统管理主菜单
DECLARE @SystemMenuID INT;
INSERT INTO UniAdmin_Menus (MenuName, MenuCode, ParentID, Icon, RoutePath, PermissionCode, SortOrder, IsVisible, CreatedDate, ModifiedDate)
VALUES ('系统管理', 'system', NULL, 'settings.png', '/system', 'system:view', 100, 1, GETDATE(), GETDATE());
SET @SystemMenuID = SCOPE_IDENTITY();

-- 8.2 用户管理菜单
DECLARE @UserMenuID INT;
INSERT INTO UniAdmin_Menus (MenuName, MenuCode, ParentID, Icon, RoutePath, PermissionCode, SortOrder, IsVisible, CreatedDate, ModifiedDate)
VALUES ('用户管理', 'system:user', @SystemMenuID, 'user.png', '/system/user', 'user:view', 110, 1, GETDATE(), GETDATE());
SET @UserMenuID = SCOPE_IDENTITY();

-- 8.3 角色管理菜单
DECLARE @RoleMenuID INT;
INSERT INTO UniAdmin_Menus (MenuName, MenuCode, ParentID, Icon, RoutePath, PermissionCode, SortOrder, IsVisible, CreatedDate, ModifiedDate)
VALUES ('角色管理', 'system:role', @SystemMenuID, 'users.png', '/system/role', 'role:view', 120, 1, GETDATE(), GETDATE());
SET @RoleMenuID = SCOPE_IDENTITY();

-- 8.4 菜单管理菜单
DECLARE @MenuMenuID INT;
INSERT INTO UniAdmin_Menus (MenuName, MenuCode, ParentID, Icon, RoutePath, PermissionCode, SortOrder, IsVisible, CreatedDate, ModifiedDate)
VALUES ('菜单管理', 'system:menu', @SystemMenuID, 'menu.png', '/system/menu', 'menu:view', 130, 1, GETDATE(), GETDATE());
SET @MenuMenuID = SCOPE_IDENTITY();

-- 8.5 数据字典菜单
DECLARE @DictMenuID INT;
INSERT INTO UniAdmin_Menus (MenuName, MenuCode, ParentID, Icon, RoutePath, PermissionCode, SortOrder, IsVisible, CreatedDate, ModifiedDate)
VALUES ('数据字典', 'system:dictionary', @SystemMenuID, 'book.png', '/system/dictionary', 'dictionary:view', 140, 1, GETDATE(), GETDATE());
SET @DictMenuID = SCOPE_IDENTITY();

-- 8.6 系统配置菜单
DECLARE @ConfigMenuID INT;
INSERT INTO UniAdmin_Menus (MenuName, MenuCode, ParentID, Icon, RoutePath, PermissionCode, SortOrder, IsVisible, CreatedDate, ModifiedDate)
VALUES ('系统配置', 'system:config', @SystemMenuID, 'config.png', '/system/config', 'config:view', 150, 1, GETDATE(), GETDATE());
SET @ConfigMenuID = SCOPE_IDENTITY();

-- 8.7 日志审计菜单
DECLARE @LogMenuID INT;
INSERT INTO UniAdmin_Menus (MenuName, MenuCode, ParentID, Icon, RoutePath, PermissionCode, SortOrder, IsVisible, CreatedDate, ModifiedDate)
VALUES ('日志审计', 'system:log', @SystemMenuID, 'file-text.png', '/system/log', 'log:view', 160, 1, GETDATE(), GETDATE());
SET @LogMenuID = SCOPE_IDENTITY();

-- 8.8 定时任务菜单
DECLARE @SchedulerMenuID INT;
INSERT INTO UniAdmin_Menus (MenuName, MenuCode, ParentID, Icon, RoutePath, PermissionCode, SortOrder, IsVisible, CreatedDate, ModifiedDate)
VALUES ('定时任务', 'system:scheduler', @SystemMenuID, 'clock.png', '/system/scheduler', 'scheduler:view', 170, 1, GETDATE(), GETDATE());
SET @SchedulerMenuID = SCOPE_IDENTITY();

-- =====================================================
-- 9. 为管理员角色分配所有权限
-- =====================================================

-- 假设管理员角色 ID 为 1，如果不是需要调整
DECLARE @AdminRoleID INT;
SELECT @AdminRoleID = RoleID FROM UniAdmin_Roles WHERE RoleCode = 'admin';

IF @AdminRoleID IS NOT NULL
BEGIN
  -- 为管理员角色分配所有系统权限
  INSERT INTO UniAdmin_RolePermissions (RoleID, PermissionID, CreatedDate)
  SELECT @AdminRoleID, PermissionID, GETDATE()
  FROM UniAdmin_Permissions
  WHERE PermissionCode LIKE 'user:%'
     OR PermissionCode LIKE 'role:%'
     OR PermissionCode LIKE 'menu:%'
     OR PermissionCode LIKE 'dictionary:%'
     OR PermissionCode LIKE 'config:%'
     OR PermissionCode LIKE 'log:%'
     OR PermissionCode LIKE 'scheduler:%';
END

-- =====================================================
-- 10. 完成提示
-- =====================================================
PRINT '======================================================';
PRINT '系统权限初始化完成！';
PRINT '======================================================';
PRINT '已初始化权限数量: ' + CAST((SELECT COUNT(*) FROM UniAdmin_Permissions WHERE PermissionCode LIKE 'user:%' OR PermissionCode LIKE 'role:%' OR PermissionCode LIKE 'menu:%' OR PermissionCode LIKE 'dictionary:%' OR PermissionCode LIKE 'config:%' OR PermissionCode LIKE 'log:%' OR PermissionCode LIKE 'scheduler:%') AS VARCHAR(10));
PRINT '已初始化菜单数量: ' + CAST((SELECT COUNT(*) FROM UniAdmin_Menus WHERE MenuCode LIKE 'system:%') AS VARCHAR(10));
PRINT '======================================================';

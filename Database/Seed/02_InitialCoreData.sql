-- =============================================
-- UniAdmin 核心框架层初始数据
-- =============================================

-- 插入管理员用户（密码: admin123）
INSERT INTO UniAdmin_Users (UserName, Password, RealName, Email, Status, CreatedDate)
VALUES ('admin', 'AQAAAAEAACcQAAAAEHuPw9/vN+LJQKy5j8RQK4k7q1lJh8n8n7n8n7n8n7n8n7n8n7n8==', '系统管理员', 'admin@example.com', 1, GETDATE());
GO

-- 插入默认角色
INSERT INTO UniAdmin_Roles (RoleCode, RoleName, Description, DataScope, SortOrder, Status, CreatedDate)
VALUES
    ('admin', '超级管理员', '拥有所有权限', 'all', 1, 1, GETDATE()),
    ('user', '普通用户', '基本用户权限', 'self', 2, 1, GETDATE());
GO

-- 插入系统权限
INSERT INTO UniAdmin_Permissions (PermissionCode, PermissionName, ResourceType, ResourceCode, Action, Description, CreatedDate)
VALUES
    -- 用户管理权限
    ('user:view', '查看用户', 'user', 'UserManagement', 'view', '查看用户列表和详情', GETDATE()),
    ('user:add', '添加用户', 'user', 'UserManagement', 'add', '添加新用户', GETDATE()),
    ('user:edit', '编辑用户', 'user', 'UserManagement', 'edit', '编辑用户信息', GETDATE()),
    ('user:delete', '删除用户', 'user', 'UserManagement', 'delete', '删除用户', GETDATE()),
    ('user:resetpwd', '重置密码', 'user', 'UserManagement', 'resetpwd', '重置用户密码', GETDATE()),

    -- 角色管理权限
    ('role:view', '查看角色', 'role', 'RoleManagement', 'view', '查看角色列表和详情', GETDATE()),
    ('role:add', '添加角色', 'role', 'RoleManagement', 'add', '添加新角色', GETDATE()),
    ('role:edit', '编辑角色', 'role', 'RoleManagement', 'edit', '编辑角色信息', GETDATE()),
    ('role:delete', '删除角色', 'role', 'RoleManagement', 'delete', '删除角色', GETDATE()),
    ('role:assignperm', '分配权限', 'role', 'RoleManagement', 'assignperm', '为角色分配权限', GETDATE()),

    -- 菜单管理权限
    ('menu:view', '查看菜单', 'menu', 'MenuManagement', 'view', '查看菜单列表', GETDATE()),
    ('menu:add', '添加菜单', 'menu', 'MenuManagement', 'add', '添加新菜单', GETDATE()),
    ('menu:edit', '编辑菜单', 'menu', 'MenuManagement', 'edit', '编辑菜单信息', GETDATE()),
    ('menu:delete', '删除菜单', 'menu', 'MenuManagement', 'delete', '删除菜单', GETDATE()),

    -- 系统配置权限
    ('config:view', '查看配置', 'config', 'SystemConfig', 'view', '查看系统配置', GETDATE()),
    ('config:edit', '修改配置', 'config', 'SystemConfig', 'edit', '修改系统配置', GETDATE());
GO

-- 为超级管理员分配所有权限
INSERT INTO UniAdmin_RolePermissions (RoleID, PermissionID)
SELECT 1, PermissionID FROM UniAdmin_Permissions;
GO

-- 为管理员分配超级管理员角色
INSERT INTO UniAdmin_UserRoles (UserID, RoleID)
VALUES (1, 1);
GO

-- 插入系统菜单
INSERT INTO UniAdmin_Menus (ParentID, MenuName, MenuCode, Icon, RoutePath, PermissionCode, SortOrder, IsVisible, CreatedDate)
VALUES
    (NULL, '系统管理', 'system', 'settings', '/system', NULL, 1, 1, GETDATE()),
    (1, '用户管理', 'system.users', 'user', '/system/users', 'user:view', 1, 1, GETDATE()),
    (1, '角色管理', 'system.roles', 'users', '/system/roles', 'role:view', 2, 1, GETDATE()),
    (1, '菜单管理', 'system.menus', 'menu', '/system/menus', 'menu:view', 3, 1, GETDATE()),
    (1, '数据字典', 'system.dictionary', 'book', '/system/dictionary', NULL, 4, 1, GETDATE()),
    (1, '系统配置', 'system.config', 'cog', '/system/config', 'config:view', 5, 1, GETDATE());
GO

-- =============================================
-- UniGUI Admin - 插件管理系统初始数据
-- 版本: 1.0.0
-- 创建日期: 2026-02-23
-- 说明: 初始化核心模块、系统模块和配置数据
-- =============================================

USE [UniGUI_Admin]
GO

-- =============================================
-- 1. 核心模块数据 (ModuleType = Core)
-- 说明: 系统核心功能模块，提供基础服务
-- =============================================

PRINT '开始插入核心模块数据...'
GO

-- 核心框架模块
IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'Core')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Modules] (
        [ModuleId],
        [ModuleCode],
        [ModuleName],
        [ModuleType],
        [Version],
        [Description],
        [Category],
        [AssemblyName],
        [EntryPointType],
        [IsActive],
        [IsSystem],
        [LoadOrder],
        [CreatedBy]
    ) VALUES (
        NEWID(),
        'Core',
        '核心框架',
        'Core',
        '1.0.0',
        '提供插件管理、依赖注入、事件总线等核心功能',
        'Framework',
        'UniAdmin.Plugins.Core.dll',
        'UniAdmin.Plugins.Core.CorePlugin',
        1,
        1,
        1,
        'System'
    )
    PRINT '  + 核心框架模块 (Core)'
END
GO

-- 认证服务模块
IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'AuthService')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Modules] (
        [ModuleId],
        [ModuleCode],
        [ModuleName],
        [ModuleType],
        [Version],
        [Description],
        [Category],
        [AssemblyName],
        [EntryPointType],
        [IsActive],
        [IsSystem],
        [LoadOrder],
        [CreatedBy]
    ) VALUES (
        NEWID(),
        'AuthService',
        '认证服务',
        'Core',
        '1.0.0',
        '提供用户身份验证、登录登出、令牌管理等功能',
        'Security',
        'UniAdmin.Plugins.AuthService.dll',
        'UniAdmin.Plugins.AuthService.AuthServicePlugin',
        1,
        1,
        2,
        'System'
    )
    PRINT '  + 认证服务模块 (AuthService)'
END
GO

-- 权限服务模块
IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'PermissionService')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Modules] (
        [ModuleId],
        [ModuleCode],
        [ModuleName],
        [ModuleType],
        [Version],
        [Description],
        [Category],
        [AssemblyName],
        [EntryPointType],
        [IsActive],
        [IsSystem],
        [LoadOrder],
        [CreatedBy]
    ) VALUES (
        NEWID(),
        'PermissionService',
        '权限服务',
        'Core',
        '1.0.0',
        '提供基于RBAC的权限管理和验证功能',
        'Security',
        'UniAdmin.Plugins.PermissionService.dll',
        'UniAdmin.Plugins.PermissionService.PermissionServicePlugin',
        1,
        1,
        3,
        'System'
    )
    PRINT '  + 权限服务模块 (PermissionService)'
END
GO

-- 菜单服务模块
IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'MenuService')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Modules] (
        [ModuleId],
        [ModuleCode],
        [ModuleName],
        [ModuleType],
        [Version],
        [Description],
        [Category],
        [AssemblyName],
        [EntryPointType],
        [IsActive],
        [IsSystem],
        [LoadOrder],
        [CreatedBy]
    ) VALUES (
        NEWID(),
        'MenuService',
        '菜单服务',
        'Core',
        '1.0.0',
        '提供动态菜单生成和管理功能',
        'UI',
        'UniAdmin.Plugins.MenuService.dll',
        'UniAdmin.Plugins.MenuService.MenuServicePlugin',
        1,
        1,
        4,
        'System'
    )
    PRINT '  + 菜单服务模块 (MenuService)'
END
GO

PRINT '核心模块数据插入完成！'
PRINT ''
GO

-- =============================================
-- 2. 系统模块数据 (ModuleType = System)
-- 说明: 系统管理功能模块
-- =============================================

PRINT '开始插入系统模块数据...'
GO

-- 用户管理模块
IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'UserManagement')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Modules] (
        [ModuleId],
        [ModuleCode],
        [ModuleName],
        [ModuleType],
        [Version],
        [Description],
        [Category],
        [AssemblyName],
        [EntryPointType],
        [IsActive],
        [IsSystem],
        [LoadOrder],
        [CreatedBy]
    ) VALUES (
        NEWID(),
        'UserManagement',
        '用户管理',
        'System',
        '1.0.0',
        '提供用户增删改查、用户状态管理等功能',
        'User',
        'UniAdmin.Plugins.UserManagement.dll',
        'UniAdmin.Plugins.UserManagement.UserManagementPlugin',
        1,
        1,
        10,
        'System'
    )
    PRINT '  + 用户管理模块 (UserManagement)'
END
GO

-- 角色管理模块
IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'RoleManagement')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Modules] (
        [ModuleId],
        [ModuleCode],
        [ModuleName],
        [ModuleType],
        [Version],
        [Description],
        [Category],
        [AssemblyName],
        [EntryPointType],
        [IsActive],
        [IsSystem],
        [LoadOrder],
        [CreatedBy]
    ) VALUES (
        NEWID(),
        'RoleManagement',
        '角色管理',
        'System',
        '1.0.0',
        '提供角色定义、角色权限分配等功能',
        'Role',
        'UniAdmin.Plugins.RoleManagement.dll',
        'UniAdmin.Plugins.RoleManagement.RoleManagementPlugin',
        1,
        1,
        11,
        'System'
    )
    PRINT '  + 角色管理模块 (RoleManagement)'
END
GO

-- 权限管理模块
IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'PermissionManagement')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Modules] (
        [ModuleId],
        [ModuleCode],
        [ModuleName],
        [ModuleType],
        [Version],
        [Description],
        [Category],
        [AssemblyName],
        [EntryPointType],
        [IsActive],
        [IsSystem],
        [LoadOrder],
        [CreatedBy]
    ) VALUES (
        NEWID(),
        'PermissionManagement',
        '权限管理',
        'System',
        '1.0.0',
        '提供权限定义、权限分类管理等功能',
        'Permission',
        'UniAdmin.Plugins.PermissionManagement.dll',
        'UniAdmin.Plugins.PermissionManagement.PermissionManagementPlugin',
        1,
        1,
        12,
        'System'
    )
    PRINT '  + 权限管理模块 (PermissionManagement)'
END
GO

-- 组织架构模块
IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'OrganizationManagement')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Modules] (
        [ModuleId],
        [ModuleCode],
        [ModuleName],
        [ModuleType],
        [Version],
        [Description],
        [Category],
        [AssemblyName],
        [EntryPointType],
        [IsActive],
        [IsSystem],
        [LoadOrder],
        [CreatedBy]
    ) VALUES (
        NEWID(),
        'OrganizationManagement',
        '组织架构',
        'System',
        '1.0.0',
        '提供部门、岗位等组织结构管理功能',
        'Organization',
        'UniAdmin.Plugins.OrganizationManagement.dll',
        'UniAdmin.Plugins.OrganizationManagement.OrganizationManagementPlugin',
        1,
        1,
        13,
        'System'
    )
    PRINT '  + 组织架构模块 (OrganizationManagement)'
END
GO

-- 系统配置模块
IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'SystemConfig')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Modules] (
        [ModuleId],
        [ModuleCode],
        [ModuleName],
        [ModuleType],
        [Version],
        [Description],
        [Category],
        [AssemblyName],
        [EntryPointType],
        [IsActive],
        [IsSystem],
        [LoadOrder],
        [CreatedBy]
    ) VALUES (
        NEWID(),
        'SystemConfig',
        '系统配置',
        'System',
        '1.0.0',
        '提供系统参数配置、字典管理等功能',
        'Config',
        'UniAdmin.Plugins.SystemConfig.dll',
        'UniAdmin.Plugins.SystemConfig.SystemConfigPlugin',
        1,
        1,
        14,
        'System'
    )
    PRINT '  + 系统配置模块 (SystemConfig)'
END
GO

-- 日志管理模块
IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'LogManagement')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Modules] (
        [ModuleId],
        [ModuleCode],
        [ModuleName],
        [ModuleType],
        [Version],
        [Description],
        [Category],
        [AssemblyName],
        [EntryPointType],
        [IsActive],
        [IsSystem],
        [LoadOrder],
        [CreatedBy]
    ) VALUES (
        NEWID(),
        'LogManagement',
        '日志管理',
        'System',
        '1.0.0',
        '提供系统日志查询、分析和导出功能',
        'Log',
        'UniAdmin.Plugins.LogManagement.dll',
        'UniAdmin.Plugins.LogManagement.LogManagementPlugin',
        1,
        1,
        15,
        'System'
    )
    PRINT '  + 日志管理模块 (LogManagement)'
END
GO

-- 系统监控模块
IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'SystemMonitor')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Modules] (
        [ModuleId],
        [ModuleCode],
        [ModuleName],
        [ModuleType],
        [Version],
        [Description],
        [Category],
        [AssemblyName],
        [EntryPointType],
        [IsActive],
        [IsSystem],
        [LoadOrder],
        [CreatedBy]
    ) VALUES (
        NEWID(),
        'SystemMonitor',
        '系统监控',
        'System',
        '1.0.0',
        '提供服务器性能监控、在线用户统计等功能',
        'Monitor',
        'UniAdmin.Plugins.SystemMonitor.dll',
        'UniAdmin.Plugins.SystemMonitor.SystemMonitorPlugin',
        1,
        1,
        16,
        'System'
    )
    PRINT '  + 系统监控模块 (SystemMonitor)'
END
GO

PRINT '系统模块数据插入完成！'
PRINT ''
GO

-- =============================================
-- 3. 模块依赖关系数据
-- 说明: 定义各模块之间的依赖关系
-- =============================================

PRINT '开始插入模块依赖关系数据...'
GO

-- 声明模块ID变量
DECLARE @CoreId UNIQUEIDENTIFIER
DECLARE @AuthServiceId UNIQUEIDENTIFIER
DECLARE @PermissionServiceId UNIQUEIDENTIFIER
DECLARE @MenuServiceId UNIQUEIDENTIFIER
DECLARE @UserManagementId UNIQUEIDENTIFIER
DECLARE @RoleManagementId UNIQUEIDENTIFIER
DECLARE @PermissionManagementId UNIQUEIDENTIFIER
DECLARE @OrganizationManagementId UNIQUEIDENTIFIER
DECLARE @SystemConfigId UNIQUEIDENTIFIER
DECLARE @LogManagementId UNIQUEIDENTIFIER
DECLARE @SystemMonitorId UNIQUEIDENTIFIER

-- 获取各模块ID
SELECT @CoreId = [ModuleId] FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'Core'
SELECT @AuthServiceId = [ModuleId] FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'AuthService'
SELECT @PermissionServiceId = [ModuleId] FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'PermissionService'
SELECT @MenuServiceId = [ModuleId] FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'MenuService'
SELECT @UserManagementId = [ModuleId] FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'UserManagement'
SELECT @RoleManagementId = [ModuleId] FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'RoleManagement'
SELECT @PermissionManagementId = [ModuleId] FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'PermissionManagement'
SELECT @OrganizationManagementId = [ModuleId] FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'OrganizationManagement'
SELECT @SystemConfigId = [ModuleId] FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'SystemConfig'
SELECT @LogManagementId = [ModuleId] FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'LogManagement'
SELECT @SystemMonitorId = [ModuleId] FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'SystemMonitor'
GO

-- AuthService 依赖 Core
IF NOT EXISTS (
    SELECT * FROM [dbo].[UniAdmin_ModuleDependencies]
    WHERE [ModuleId] = (SELECT [ModuleId] FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'AuthService')
    AND [DependsOnModuleId] = (SELECT [ModuleId] FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'Core')
)
BEGIN
    INSERT INTO [dbo].[UniAdmin_ModuleDependencies] ([ModuleId], [DependsOnModuleId], [MinVersion], [DependencyType])
    SELECT [ModuleId], @CoreId, '1.0.0', 'Required'
    FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'AuthService'
    PRINT '  + AuthService -> Core'
END
GO

-- PermissionService 依赖 Core 和 AuthService
IF NOT EXISTS (
    SELECT * FROM [dbo].[UniAdmin_ModuleDependencies]
    WHERE [ModuleId] = (SELECT [ModuleId] FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'PermissionService')
    AND [DependsOnModuleId] = (SELECT [ModuleId] FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'Core')
)
BEGIN
    INSERT INTO [dbo].[UniAdmin_ModuleDependencies] ([ModuleId], [DependsOnModuleId], [MinVersion], [DependencyType])
    SELECT [ModuleId], @CoreId, '1.0.0', 'Required'
    FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'PermissionService'
    PRINT '  + PermissionService -> Core'
END
GO

IF NOT EXISTS (
    SELECT * FROM [dbo].[UniAdmin_ModuleDependencies]
    WHERE [ModuleId] = (SELECT [ModuleId] FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'PermissionService')
    AND [DependsOnModuleId] = (SELECT [ModuleId] FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'AuthService')
)
BEGIN
    INSERT INTO [dbo].[UniAdmin_ModuleDependencies] ([ModuleId], [DependsOnModuleId], [MinVersion], [DependencyType])
    SELECT [ModuleId], @AuthServiceId, '1.0.0', 'Required'
    FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'PermissionService'
    PRINT '  + PermissionService -> AuthService'
END
GO

-- MenuService 依赖 Core 和 AuthService
IF NOT EXISTS (
    SELECT * FROM [dbo].[UniAdmin_ModuleDependencies]
    WHERE [ModuleId] = (SELECT [ModuleId] FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'MenuService')
    AND [DependsOnModuleId] = (SELECT [ModuleId] FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'Core')
)
BEGIN
    INSERT INTO [dbo].[UniAdmin_ModuleDependencies] ([ModuleId], [DependsOnModuleId], [MinVersion], [DependencyType])
    SELECT [ModuleId], @CoreId, '1.0.0', 'Required'
    FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'MenuService'
    PRINT '  + MenuService -> Core'
END
GO

IF NOT EXISTS (
    SELECT * FROM [dbo].[UniAdmin_ModuleDependencies]
    WHERE [ModuleId] = (SELECT [ModuleId] FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'MenuService')
    AND [DependsOnModuleId] = (SELECT [ModuleId] FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'AuthService')
)
BEGIN
    INSERT INTO [dbo].[UniAdmin_ModuleDependencies] ([ModuleId], [DependsOnModuleId], [MinVersion], [DependencyType])
    SELECT [ModuleId], @AuthServiceId, '1.0.0', 'Required'
    FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = 'MenuService'
    PRINT '  + MenuService -> AuthService'
END
GO

-- 所有系统模块都依赖 Core, AuthService, PermissionService
DECLARE @ModuleCode NVARCHAR(50)
DECLARE module_cursor CURSOR FOR
    SELECT [ModuleCode] FROM [dbo].[UniAdmin_Modules] WHERE [ModuleType] = 'System'

OPEN module_cursor
FETCH NEXT FROM module_cursor INTO @ModuleCode

WHILE @@FETCH_STATUS = 0
BEGIN
    -- 依赖 Core
    IF NOT EXISTS (
        SELECT * FROM [dbo].[UniAdmin_ModuleDependencies] d
        INNER JOIN [dbo].[UniAdmin_Modules] m ON d.[ModuleId] = m.[ModuleId]
        WHERE m.[ModuleCode] = @ModuleCode
        AND d.[DependsOnModuleId] = @CoreId
    )
    BEGIN
        INSERT INTO [dbo].[UniAdmin_ModuleDependencies] ([ModuleId], [DependsOnModuleId], [MinVersion], [DependencyType])
        SELECT [ModuleId], @CoreId, '1.0.0', 'Required'
        FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = @ModuleCode
        PRINT '  + ' + @ModuleCode + ' -> Core'
    END

    -- 依赖 AuthService
    IF NOT EXISTS (
        SELECT * FROM [dbo].[UniAdmin_ModuleDependencies] d
        INNER JOIN [dbo].[UniAdmin_Modules] m ON d.[ModuleId] = m.[ModuleId]
        WHERE m.[ModuleCode] = @ModuleCode
        AND d.[DependsOnModuleId] = @AuthServiceId
    )
    BEGIN
        INSERT INTO [dbo].[UniAdmin_ModuleDependencies] ([ModuleId], [DependsOnModuleId], [MinVersion], [DependencyType])
        SELECT [ModuleId], @AuthServiceId, '1.0.0', 'Required'
        FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = @ModuleCode
        PRINT '  + ' + @ModuleCode + ' -> AuthService'
    END

    -- 依赖 PermissionService
    IF NOT EXISTS (
        SELECT * FROM [dbo].[UniAdmin_ModuleDependencies] d
        INNER JOIN [dbo].[UniAdmin_Modules] m ON d.[ModuleId] = m.[ModuleId]
        WHERE m.[ModuleCode] = @ModuleCode
        AND d.[DependsOnModuleId] = @PermissionServiceId
    )
    BEGIN
        INSERT INTO [dbo].[UniAdmin_ModuleDependencies] ([ModuleId], [DependsOnModuleId], [MinVersion], [DependencyType])
        SELECT [ModuleId], @PermissionServiceId, '1.0.0', 'Required'
        FROM [dbo].[UniAdmin_Modules] WHERE [ModuleCode] = @ModuleCode
        PRINT '  + ' + @ModuleCode + ' -> PermissionService'
    END

    FETCH NEXT FROM module_cursor INTO @ModuleCode
END

CLOSE module_cursor
DEALLOCATE module_cursor
GO

PRINT '模块依赖关系数据插入完成！'
PRINT ''
GO

-- =============================================
-- 4. 系统配置数据
-- 说明: 初始化系统配置参数
-- =============================================

PRINT '开始插入系统配置数据...'
GO

-- 系统基本配置
IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Configs] WHERE [ConfigKey] = 'System.Name')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Configs] ([ConfigKey], [ConfigValue], [Category], [DataType], [Description], [DefaultValue], [IsReadOnly], [SortOrder])
    VALUES ('System.Name', 'UniGUI Admin管理系统', 'System', 'String', '系统名称', 'UniGUI Admin管理系统', 1, 1)
    PRINT '  + System.Name'
END
GO

IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Configs] WHERE [ConfigKey] = 'System.Version')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Configs] ([ConfigKey], [ConfigValue], [Category], [DataType], [Description], [DefaultValue], [IsReadOnly], [SortOrder])
    VALUES ('System.Version', '1.0.0', 'System', 'String', '系统版本', '1.0.0', 1, 2)
    PRINT '  + System.Version'
END
GO

IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Configs] WHERE [ConfigKey] = 'System.Company')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Configs] ([ConfigKey], [ConfigValue], [Category], [DataType], [Description], [DefaultValue], [SortOrder])
    VALUES ('System.Company', 'Your Company', 'System', 'String', '公司名称', 'Your Company', 3)
    PRINT '  + System.Company'
END
GO

-- 安全配置
IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Configs] WHERE [ConfigKey] = 'Security.Password.MinLength')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Configs] ([ConfigKey], [ConfigValue], [Category], [DataType], [Description], [DefaultValue], [SortOrder])
    VALUES ('Security.Password.MinLength', '6', 'Security', 'Int', '密码最小长度', '6', 10)
    PRINT '  + Security.Password.MinLength'
END
GO

IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Configs] WHERE [ConfigKey] = 'Security.Password.RequireUppercase')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Configs] ([ConfigKey], [ConfigValue], [Category], [DataType], [Description], [DefaultValue], [SortOrder])
    VALUES ('Security.Password.RequireUppercase', '1', 'Security', 'Bool', '是否需要大写字母', '1', 11)
    PRINT '  + Security.Password.RequireUppercase'
END
GO

IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Configs] WHERE [ConfigKey] = 'Security.Password.RequireLowercase')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Configs] ([ConfigKey], [ConfigValue], [Category], [DataType], [Description], [DefaultValue], [SortOrder])
    VALUES ('Security.Password.RequireLowercase', '1', 'Security', 'Bool', '是否需要小写字母', '1', 12)
    PRINT '  + Security.Password.RequireLowercase'
END
GO

IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Configs] WHERE [ConfigKey] = 'Security.Password.RequireDigit')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Configs] ([ConfigKey], [ConfigValue], [Category], [DataType], [Description], [DefaultValue], [SortOrder])
    VALUES ('Security.Password.RequireDigit', '1', 'Security', 'Bool', '是否需要数字', '1', 13)
    PRINT '  + Security.Password.RequireDigit'
END
GO

IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Configs] WHERE [ConfigKey] = 'Security.Session.Timeout')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Configs] ([ConfigKey], [ConfigValue], [Category], [DataType], [Description], [DefaultValue], [SortOrder])
    VALUES ('Security.Session.Timeout', '30', 'Security', 'Int', '会话超时时间（分钟）', '30', 14)
    PRINT '  + Security.Session.Timeout'
END
GO

IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Configs] WHERE [ConfigKey] = 'Security.MaxLoginAttempts')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Configs] ([ConfigKey], [ConfigValue], [Category], [DataType], [Description], [DefaultValue], [SortOrder])
    VALUES ('Security.MaxLoginAttempts', '5', 'Security', 'Int', '最大登录尝试次数', '5', 15)
    PRINT '  + Security.MaxLoginAttempts'
END
GO

-- 日志配置
IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Configs] WHERE [ConfigKey] = 'Log.Level')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Configs] ([ConfigKey], [ConfigValue], [Category], [DataType], [Description], [DefaultValue], [SortOrder])
    VALUES ('Log.Level', 'Info', 'Log', 'String', '日志级别 (Debug/Info/Warning/Error)', 'Info', 20)
    PRINT '  + Log.Level'
END
GO

IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Configs] WHERE [ConfigKey] = 'Log.RetentionDays')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Configs] ([ConfigKey], [ConfigValue], [Category], [DataType], [Description], [DefaultValue], [SortOrder])
    VALUES ('Log.RetentionDays', '90', 'Log', 'Int', '日志保留天数', '90', 21)
    PRINT '  + Log.RetentionDays'
END
GO

IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Configs] WHERE [ConfigKey] = 'Log.EnableFileLog')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Configs] ([ConfigKey], [ConfigValue], [Category], [DataType], [Description], [DefaultValue], [SortOrder])
    VALUES ('Log.EnableFileLog', '1', 'Log', 'Bool', '是否启用文件日志', '1', 22)
    PRINT '  + Log.EnableFileLog'
END
GO

-- 插件配置
IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Configs] WHERE [ConfigKey] = 'Plugin.AutoLoad')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Configs] ([ConfigKey], [ConfigValue], [Category], [DataType], [Description], [DefaultValue], [SortOrder])
    VALUES ('Plugin.AutoLoad', '1', 'Plugin', 'Bool', '是否自动加载插件', '1', 30)
    PRINT '  + Plugin.AutoLoad'
END
GO

IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Configs] WHERE [ConfigKey] = 'Plugin.EnableHotReload')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Configs] ([ConfigKey], [ConfigValue], [Category], [DataType], [Description], [DefaultValue], [SortOrder])
    VALUES ('Plugin.EnableHotReload', '0', 'Plugin', 'Bool', '是否启用热重载', '0', 31)
    PRINT '  + Plugin.EnableHotReload'
END
GO

IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Configs] WHERE [ConfigKey] = 'Plugin.LoadOrderStrategy')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Configs] ([ConfigKey], [ConfigValue], [Category], [DataType], [Description], [DefaultValue], [SortOrder])
    VALUES ('Plugin.LoadOrderStrategy', 'Dependency', 'Plugin', 'String', '加载顺序策略 (Manual/Dependency)', 'Dependency', 32)
    PRINT '  + Plugin.LoadOrderStrategy'
END
GO

-- UI配置
IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Configs] WHERE [ConfigKey] = 'UI.Theme')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Configs] ([ConfigKey], [ConfigValue], [Category], [DataType], [Description], [DefaultValue], [SortOrder])
    VALUES ('UI.Theme', 'Default', 'UI', 'String', '界面主题', 'Default', 40)
    PRINT '  + UI.Theme'
END
GO

IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Configs] WHERE [ConfigKey] = 'UI.Language')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Configs] ([ConfigKey], [ConfigValue], [Category], [DataType], [Description], [DefaultValue], [SortOrder])
    VALUES ('UI.Language', 'zh-CN', 'UI', 'String', '界面语言', 'zh-CN', 41)
    PRINT '  + UI.Language'
END
GO

IF NOT EXISTS (SELECT * FROM [dbo].[UniAdmin_Configs] WHERE [ConfigKey] = 'UI.PageSize')
BEGIN
    INSERT INTO [dbo].[UniAdmin_Configs] ([ConfigKey], [ConfigValue], [Category], [DataType], [Description], [DefaultValue], [SortOrder])
    VALUES ('UI.PageSize', '20', 'UI', 'Int', '分页大小', '20', 42)
    PRINT '  + UI.PageSize'
END
GO

PRINT '系统配置数据插入完成！'
PRINT ''
GO

-- =============================================
-- 数据初始化完成
-- =============================================

PRINT ''
PRINT '=========================================='
PRINT '插件管理系统初始数据初始化完成！'
PRINT '=========================================='
PRINT ''
PRINT '初始化统计:'
PRINT '  - 核心模块: 4 个 (Core, AuthService, PermissionService, MenuService)'
PRINT '  - 系统模块: 7 个 (UserManagement, RoleManagement 等)'
PRINT '  - 依赖关系: 已建立各模块间的依赖关系'
PRINT '  - 系统配置: 18 个配置项'
PRINT ''
PRINT '初始化的模块列表:'
SELECT
    [ModuleType] AS 模块类型,
    [ModuleCode] AS 模块代码,
    [ModuleName] AS 模块名称,
    [Version] AS 版本,
    CASE [IsActive] WHEN 1 THEN '是' ELSE '否' END AS 已启用
FROM [dbo].[UniAdmin_Modules]
ORDER BY [ModuleType], [LoadOrder]
PRINT ''
PRINT '初始化的配置分类:'
SELECT DISTINCT [Category] AS 配置分类, COUNT(*) AS 配置数量
FROM [dbo].[UniAdmin_Configs]
GROUP BY [Category]
ORDER BY [Category]
PRINT '=========================================='
GO

-- =============================================
-- UniGUI Admin - 插件管理系统表结构
-- 版本: 1.0.0
-- 创建日期: 2026-02-23
-- 说明: 定义插件管理的核心数据表，包括模块注册、配置管理和依赖关系
-- =============================================

USE [UniGUI_Admin]
GO

-- =============================================
-- 表: UniAdmin_Modules (业务插件注册表)
-- 说明: 注册所有业务插件模块的基本信息和状态
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UniAdmin_Modules]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[UniAdmin_Modules] (
        -- 主键
        [ModuleId]        UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),

        -- 基本信息
        [ModuleCode]      NVARCHAR(50)     NOT NULL,  -- 模块代码，唯一标识
        [ModuleName]      NVARCHAR(100)    NOT NULL,  -- 模块名称
        [ModuleType]      NVARCHAR(20)     NOT NULL,  -- 模块类型: Core/System/Business
        [Version]         NVARCHAR(20)     NOT NULL,  -- 版本号

        -- 描述和分类
        [Description]     NVARCHAR(500)    NULL,      -- 模块描述
        [Category]        NVARCHAR(50)     NULL,      -- 分类标签

        -- 程序集信息
        [AssemblyName]    NVARCHAR(255)    NOT NULL,  -- 程序集名称
        [EntryPointType]  NVARCHAR(255)    NOT NULL,  -- 入口类型全名
        [ResourcePath]    NVARCHAR(500)    NULL,      -- 资源文件路径

        -- 状态控制
        [IsActive]        BIT              NOT NULL DEFAULT 0,  -- 是否启用
        [IsSystem]        BIT              NOT NULL DEFAULT 0,  -- 是否系统模块
        [LoadOrder]       INT              NOT NULL DEFAULT 0,  -- 加载顺序

        -- 审计字段
        [CreatedAt]       DATETIME2        NOT NULL DEFAULT GETDATE(),
        [UpdatedAt]       DATETIME2        NOT NULL DEFAULT GETDATE(),
        [CreatedBy]       NVARCHAR(50)     NULL,
        [UpdatedBy]       NVARCHAR(50)     NULL,

        -- 主键约束
        CONSTRAINT [PK_UniAdmin_Modules] PRIMARY KEY CLUSTERED ([ModuleId] ASC)
    )

    PRINT '成功创建表: UniAdmin_Modules'
END
ELSE
BEGIN
    PRINT '表已存在: UniAdmin_Modules'
END
GO

-- 创建唯一索引: 模块代码必须唯一
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'UX_UniAdmin_Modules_ModuleCode' AND object_id = OBJECT_ID('[dbo].[UniAdmin_Modules]'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UX_UniAdmin_Modules_ModuleCode]
    ON [dbo].[UniAdmin_Modules]([ModuleCode] ASC)
    PRINT '成功创建索引: UX_UniAdmin_Modules_ModuleCode'
END
GO

-- 创建索引: 按模块类型查询
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_UniAdmin_Modules_ModuleType' AND object_id = OBJECT_ID('[dbo].[UniAdmin_Modules]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_UniAdmin_Modules_ModuleType]
    ON [dbo].[UniAdmin_Modules]([ModuleType] ASC)
    PRINT '成功创建索引: IX_UniAdmin_Modules_ModuleType'
END
GO

-- 创建索引: 按激活状态查询
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_UniAdmin_Modules_IsActive' AND object_id = OBJECT_ID('[dbo].[UniAdmin_Modules]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_UniAdmin_Modules_IsActive]
    ON [dbo].[UniAdmin_Modules]([IsActive] ASC)
    INCLUDE ([ModuleCode], [ModuleName])
    PRINT '成功创建索引: IX_UniAdmin_Modules_IsActive'
END
GO

-- =============================================
-- 表: UniAdmin_Configs (配置表)
-- 说明: 存储系统配置和模块配置数据
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UniAdmin_Configs]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[UniAdmin_Configs] (
        -- 主键
        [ConfigId]        UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),

        -- 配置键
        [ConfigKey]       NVARCHAR(100)    NOT NULL,  -- 配置键，唯一标识

        -- 配置值
        [ConfigValue]     NVARCHAR(MAX)    NULL,      -- 配置值

        -- 分类信息
        [Category]        NVARCHAR(50)     NULL,      -- 配置分类
        [ModuleId]        UNIQUEIDENTIFIER NULL,      -- 所属模块ID

        -- 元数据
        [DataType]        NVARCHAR(20)     NOT NULL DEFAULT 'String',  -- 数据类型: String/Int/Bool/Json
        [Description]     NVARCHAR(500)    NULL,      -- 配置说明
        [DefaultValue]    NVARCHAR(MAX)    NULL,      -- 默认值

        -- 安全性
        [IsEncrypted]     BIT              NOT NULL DEFAULT 0,  -- 是否加密
        [IsReadOnly]      BIT              NOT NULL DEFAULT 0,  -- 是否只读

        -- 排序
        [SortOrder]       INT              NOT NULL DEFAULT 0,

        -- 审计字段
        [CreatedAt]       DATETIME2        NOT NULL DEFAULT GETDATE(),
        [UpdatedAt]       DATETIME2        NOT NULL DEFAULT GETDATE(),
        [CreatedBy]       NVARCHAR(50)     NULL,
        [UpdatedBy]       NVARCHAR(50)     NULL,

        -- 主键约束
        CONSTRAINT [PK_UniAdmin_Configs] PRIMARY KEY CLUSTERED ([ConfigId] ASC)
    )

    PRINT '成功创建表: UniAdmin_Configs'
END
ELSE
BEGIN
    PRINT '表已存在: UniAdmin_Configs'
END
GO

-- 创建唯一索引: 配置键必须唯一
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'UX_UniAdmin_Configs_ConfigKey' AND object_id = OBJECT_ID('[dbo].[UniAdmin_Configs]'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UX_UniAdmin_Configs_ConfigKey]
    ON [dbo].[UniAdmin_Configs]([ConfigKey] ASC)
    PRINT '成功创建索引: UX_UniAdmin_Configs_ConfigKey'
END
GO

-- 创建索引: 按分类查询
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_UniAdmin_Configs_Category' AND object_id = OBJECT_ID('[dbo].[UniAdmin_Configs]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_UniAdmin_Configs_Category]
    ON [dbo].[UniAdmin_Configs]([Category] ASC)
    PRINT '成功创建索引: IX_UniAdmin_Configs_Category'
END
GO

-- 创建索引: 按模块查询
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_UniAdmin_Configs_ModuleId' AND object_id = OBJECT_ID('[dbo].[UniAdmin_Configs]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_UniAdmin_Configs_ModuleId]
    ON [dbo].[UniAdmin_Configs]([ModuleId] ASC)
    PRINT '成功创建索引: IX_UniAdmin_Configs_ModuleId'
END
GO

-- 外键约束: Configs 关联 Modules
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_UniAdmin_Configs_UniAdmin_Modules')
BEGIN
    ALTER TABLE [dbo].[UniAdmin_Configs]
    ADD CONSTRAINT [FK_UniAdmin_Configs_UniAdmin_Modules]
    FOREIGN KEY ([ModuleId]) REFERENCES [dbo].[UniAdmin_Modules]([ModuleId])
    ON DELETE SET NULL
    PRINT '成功创建外键: FK_UniAdmin_Configs_UniAdmin_Modules'
END
GO

-- =============================================
-- 表: UniAdmin_ModuleDependencies (模块依赖关系表)
-- 说明: 定义模块之间的依赖关系，确保正确的加载顺序
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UniAdmin_ModuleDependencies]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[UniAdmin_ModuleDependencies] (
        -- 主键
        [DependencyId]    UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),

        -- 依赖关系
        [ModuleId]        UNIQUEIDENTIFIER NOT NULL,  -- 当前模块ID
        [DependsOnModuleId] UNIQUEIDENTIFIER NOT NULL,  -- 依赖的模块ID
        [MinVersion]      NVARCHAR(20)     NULL,      -- 最低要求版本

        -- 依赖类型
        [DependencyType]  NVARCHAR(20)     NOT NULL DEFAULT 'Required',  -- Required/Optional

        -- 审计字段
        [CreatedAt]       DATETIME2        NOT NULL DEFAULT GETDATE(),

        -- 主键约束
        CONSTRAINT [PK_UniAdmin_ModuleDependencies] PRIMARY KEY CLUSTERED ([DependencyId] ASC)
    )

    PRINT '成功创建表: UniAdmin_ModuleDependencies'
END
ELSE
BEGIN
    PRINT '表已存在: UniAdmin_ModuleDependencies'
END
GO

-- 创建唯一索引: 防止重复的依赖关系
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'UX_UniAdmin_ModuleDependencies_Module_DependsOn' AND object_id = OBJECT_ID('[dbo].[UniAdmin_ModuleDependencies]'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UX_UniAdmin_ModuleDependencies_Module_DependsOn]
    ON [dbo].[UniAdmin_ModuleDependencies]([ModuleId] ASC, [DependsOnModuleId] ASC)
    PRINT '成功创建索引: UX_UniAdmin_ModuleDependencies_Module_DependsOn'
END
GO

-- 创建索引: 按被依赖模块查询（查找哪些模块依赖当前模块）
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_UniAdmin_ModuleDependencies_DependsOnModuleId' AND object_id = OBJECT_ID('[dbo].[UniAdmin_ModuleDependencies]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_UniAdmin_ModuleDependencies_DependsOnModuleId]
    ON [dbo].[UniAdmin_ModuleDependencies]([DependsOnModuleId] ASC)
    PRINT '成功创建索引: IX_UniAdmin_ModuleDependencies_DependsOnModuleId'
END
GO

-- 外键约束: ModuleDependencies.ModuleId 关联 Modules
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_UniAdmin_ModuleDependencies_UniAdmin_Modules_ModuleId')
BEGIN
    ALTER TABLE [dbo].[UniAdmin_ModuleDependencies]
    ADD CONSTRAINT [FK_UniAdmin_ModuleDependencies_UniAdmin_Modules_ModuleId]
    FOREIGN KEY ([ModuleId]) REFERENCES [dbo].[UniAdmin_Modules]([ModuleId])
    ON DELETE CASCADE
    PRINT '成功创建外键: FK_UniAdmin_ModuleDependencies_UniAdmin_Modules_ModuleId'
END
GO

-- 外键约束: ModuleDependencies.DependsOnModuleId 关联 Modules
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_UniAdmin_ModuleDependencies_UniAdmin_Modules_DependsOnModuleId')
BEGIN
    ALTER TABLE [dbo].[UniAdmin_ModuleDependencies]
    ADD CONSTRAINT [FK_UniAdmin_ModuleDependencies_UniAdmin_Modules_DependsOnModuleId]
    FOREIGN KEY ([DependsOnModuleId]) REFERENCES [dbo].[UniAdmin_Modules]([ModuleId])
    ON DELETE CASCADE
    PRINT '成功创建外键: FK_UniAdmin_ModuleDependencies_UniAdmin_Modules_DependsOnModuleId'
END
GO

-- =============================================
-- 创建触发器: 自动更新 UpdatedAt 字段
-- =============================================

-- Modules 表更新触发器
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TR_UniAdmin_Modules_Update]'))
BEGIN
    DROP TRIGGER [dbo].[TR_UniAdmin_Modules_Update]
    PRINT '删除已存在的触发器: TR_UniAdmin_Modules_Update'
END
GO

CREATE TRIGGER [dbo].[TR_UniAdmin_Modules_Update]
ON [dbo].[UniAdmin_Modules]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[UniAdmin_Modules]
    SET [UpdatedAt] = GETDATE()
    WHERE [ModuleId] IN (SELECT [ModuleId] FROM inserted)
END
GO
PRINT '成功创建触发器: TR_UniAdmin_Modules_Update'
GO

-- Configs 表更新触发器
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TR_UniAdmin_Configs_Update]'))
BEGIN
    DROP TRIGGER [dbo].[TR_UniAdmin_Configs_Update]
    PRINT '删除已存在的触发器: TR_UniAdmin_Configs_Update'
END
GO

CREATE TRIGGER [dbo].[TR_UniAdmin_Configs_Update]
ON [dbo].[UniAdmin_Configs]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[UniAdmin_Configs]
    SET [UpdatedAt] = GETDATE()
    WHERE [ConfigId] IN (SELECT [ConfigId] FROM inserted)
END
GO
PRINT '成功创建触发器: TR_UniAdmin_Configs_Update'
GO

-- =============================================
-- 创建视图: 模块依赖关系视图
-- =============================================
IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[VW_UniAdmin_ModuleDependencies]'))
BEGIN
    DROP VIEW [dbo].[VW_UniAdmin_ModuleDependencies]
    PRINT '删除已存在的视图: VW_UniAdmin_ModuleDependencies'
END
GO

CREATE VIEW [dbo].[VW_UniAdmin_ModuleDependencies] AS
SELECT
    m.[ModuleId] AS ModuleId,
    m.[ModuleCode] AS ModuleCode,
    m.[ModuleName] AS ModuleName,
    m.[Version] AS ModuleVersion,
    dm.[ModuleCode] AS DependsOnModuleCode,
    dm.[ModuleName] AS DependsOnModuleName,
    dm.[Version] AS DependsOnModuleVersion,
    d.[MinVersion],
    d.[DependencyType]
FROM [dbo].[UniAdmin_ModuleDependencies] d
INNER JOIN [dbo].[UniAdmin_Modules] m ON d.[ModuleId] = m.[ModuleId]
INNER JOIN [dbo].[UniAdmin_Modules] dm ON d.[DependsOnModuleId] = dm.[ModuleId]
GO
PRINT '成功创建视图: VW_UniAdmin_ModuleDependencies'
GO

-- =============================================
-- 创建视图: 模块配置视图
-- =============================================
IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[VW_UniAdmin_ModuleConfigs]'))
BEGIN
    DROP VIEW [dbo].[VW_UniAdmin_ModuleConfigs]
    PRINT '删除已存在的视图: VW_UniAdmin_ModuleConfigs'
END
GO

CREATE VIEW [dbo].[VW_UniAdmin_ModuleConfigs] AS
SELECT
    m.[ModuleId],
    m.[ModuleCode],
    m.[ModuleName],
    c.[ConfigKey],
    c.[ConfigValue],
    c.[Category],
    c.[DataType],
    c.[Description],
    c.[IsEncrypted],
    c.[IsReadOnly]
FROM [dbo].[UniAdmin_Modules] m
LEFT JOIN [dbo].[UniAdmin_Configs] c ON m.[ModuleId] = c.[ModuleId]
GO
PRINT '成功创建视图: VW_UniAdmin_ModuleConfigs'
GO

PRINT ''
PRINT '=========================================='
PRINT '插件管理系统数据库表结构创建完成！'
PRINT '=========================================='
PRINT ''
PRINT '已创建的表:'
PRINT '  - UniAdmin_Modules (模块注册表)'
PRINT '  - UniAdmin_Configs (配置表)'
PRINT '  - UniAdmin_ModuleDependencies (依赖关系表)'
PRINT ''
PRINT '已创建的索引:'
PRINT '  - UX_UniAdmin_Modules_ModuleCode (唯一索引)'
PRINT '  - IX_UniAdmin_Modules_ModuleType'
PRINT '  - IX_UniAdmin_Modules_IsActive'
PRINT '  - UX_UniAdmin_Configs_ConfigKey (唯一索引)'
PRINT '  - IX_UniAdmin_Configs_Category'
PRINT '  - IX_UniAdmin_Configs_ModuleId'
PRINT '  - UX_UniAdmin_ModuleDependencies_Module_DependsOn (唯一索引)'
PRINT '  - IX_UniAdmin_ModuleDependencies_DependsOnModuleId'
PRINT ''
PRINT '已创建的外键:'
PRINT '  - FK_UniAdmin_Configs_UniAdmin_Modules'
PRINT '  - FK_UniAdmin_ModuleDependencies_UniAdmin_Modules_ModuleId'
PRINT '  - FK_UniAdmin_ModuleDependencies_UniAdmin_Modules_DependsOnModuleId'
PRINT ''
PRINT '已创建的触发器:'
PRINT '  - TR_UniAdmin_Modules_Update'
PRINT '  - TR_UniAdmin_Configs_Update'
PRINT ''
PRINT '已创建的视图:'
PRINT '  - VW_UniAdmin_ModuleDependencies'
PRINT '  - VW_UniAdmin_ModuleConfigs'
PRINT '=========================================='
GO

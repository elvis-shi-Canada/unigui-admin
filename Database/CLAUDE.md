[根目录](../CLAUDE.md) > **Database**

# Database 模块 — 数据库 Schema 与初始数据

> **职责**: UniAdmin 系统的数据库表结构定义和初始数据
> **数据库**: SQL Server (MSSQL)
> **状态**: ✅ 完成

---

## 目录结构

```
Database/
├── Schema/
│   ├── 01_CreatePluginTables.sql    # 插件管理表（Modules, Configs, ModuleDependencies）
│   ├── 02_CreateCoreTables.sql      # 核心表（Users, Roles, Permissions, Menus）
│   └── 03_CreateSystemTables.sql    # 系统表（DictTypes, Configs, Logs, Tasks）
└── Seed/
    ├── 01_InitialPluginData.sql     # 初始插件注册数据
    ├── 02_InitialCoreData.sql       # 初始用户/角色/菜单数据
    └── 03_SystemPermissions.sql     # 系统权限定义
```

---

## 数据库表总览

```mermaid
erDiagram
    UniAdmin_Modules ||--o{ UniAdmin_Configs : "1:N"
    UniAdmin_Modules ||--o{ UniAdmin_ModuleDependencies : "1:N"
    UniAdmin_Users ||--o{ UniAdmin_UserRoles : "1:N"
    UniAdmin_Roles ||--o{ UniAdmin_UserRoles : "1:N"
    UniAdmin_Roles ||--o{ UniAdmin_RolePermissions : "1:N"
    UniAdmin_Permissions ||--o{ UniAdmin_RolePermissions : "1:N"
    UniAdmin_Users ||--o{ UniAdmin_UserMenus : "1:N"
    UniAdmin_Menus ||--o{ UniAdmin_UserMenus : "1:N"
    UniAdmin_DictTypes ||--o{ UniAdmin_DictItems : "1:N"
    UniAdmin_ScheduledTasks ||--o{ UniAdmin_TaskExecutionLogs : "1:N"

    UniAdmin_Modules {
        UNIQUEIDENTIFIER ModuleId PK
        NVARCHAR ModuleCode UK
        NVARCHAR ModuleName
        NVARCHAR ModuleType
        NVARCHAR Version
        BIT IsActive
        INT LoadOrder
    }
    UniAdmin_Users {
        BIGINT UserID PK
        NVARCHAR UserName UK
        NVARCHAR Password
        NVARCHAR RealName
        INT Status
    }
    UniAdmin_Roles {
        BIGINT RoleID PK
        NVARCHAR RoleCode UK
        NVARCHAR RoleName
        NVARCHAR DataScope
        INT Status
    }
    UniAdmin_Menus {
        BIGINT MenuID PK
        NVARCHAR MenuName
        BIGINT ParentID FK
        NVARCHAR MenuType
        NVARCHAR PermissionCode
    }
    UniAdmin_DictTypes {
        BIGINT TypeID PK
        NVARCHAR TypeCode UK
        NVARCHAR TypeName
    }
    UniAdmin_ScheduledTasks {
        BIGINT TaskID PK
        NVARCHAR TaskName
        NVARCHAR CronExpression
        BIT IsActive
    }
```

---

## 执行顺序

```mermaid
flowchart LR
    S1["1. 01_CreatePluginTables.sql<br/>插件表"] --> S2["2. 02_CreateCoreTables.sql<br/>核心表"]
    S2 --> S3["3. 03_CreateSystemTables.sql<br/>系统表"]
    S3 --> D1["4. 01_InitialPluginData.sql<br/>插件初始数据"]
    D1 --> D2["5. 02_InitialCoreData.sql<br/>核心初始数据"]
    D2 --> D3["6. 03_SystemPermissions.sql<br/>权限数据"]
```

**先执行 Schema（建表），再执行 Seed（数据）。**

---

## 关键设计

- **主键策略**: 插件表使用 `UNIQUEIDENTIFIER`，业务表使用 `BIGINT IDENTITY`
- **索引**: 所有外键和常用查询字段均建有索引
- **审计字段**: 每张表包含 `CreatedAt`、`UpdatedAt` 字段
- **触发器**: `UniAdmin_Modules` 和 `UniAdmin_Configs` 有自动更新 `UpdatedAt` 的触发器
- **视图**: `VW_UniAdmin_ModuleDependencies` 和 `VW_UniAdmin_ModuleConfigs`

---

*模块版本: 1.0*
*最后更新: 2026-06-24*

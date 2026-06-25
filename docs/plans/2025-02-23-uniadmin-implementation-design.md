# UniAdmin 框架实施设计文档

> 基于 Delphi UniGUI 的零代码后台管理框架实施计划
>
> 文档版本: 1.0
> 创建日期: 2025-02-23

---

## 目录

1. [概述](#概述)
2. [架构设计](#架构设计)
3. [第一阶段：插件管理层](#第一阶段插件管理层)
4. [第二阶段：核心框架层](#第二阶段核心框架层)
5. [第三阶段：系统模块层](#第三阶段系统模块层)
6. [开发计划](#开发计划)
7. [附录](#附录)

---

## 概述

### 设计目标

创建一个类似 Django Admin 的零代码后台管理框架，实现：

- **插件化核心** - 框架以插件机制为核心，支持动态扩展
- **设计时可视化配置** - 拖拽组件、属性编辑器完成配置
- **运行时自动驱动** - 配置驱动 CRUD 逻辑，无需编写代码
- **高度可扩展** - 钩子方法 + 插件机制支持自定义业务逻辑
- **元数据驱动** - 数据库元数据 + 配置声明双重驱动

### 核心理念

```
插件化核心 + 设计时配置 → 运行时引擎 → 自动 CRUD
```

### 开发策略

采用**水平分层策略**，按架构层次依次开发：

```
第一阶段: 插件管理层 → 第二阶段: 核心框架层 → 第三阶段: 系统模块层
```

---

## 架构设计

### 整体架构图

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        UniGUI + UniAdmin 完整架构                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                  TUniGUIServerModule (全局唯一)                       │ │
│  │  ─────────────────────────────────────────────────────────────────  │ │
│  │  全局共享服务:                                                       │ │
│  │  • IUniAdminConfigService    - 配置服务（读写 config/app.json）            │ │
│  │  • IUniAdminMetadataCache    - 元数据缓存（表结构、字段信息）               │ │
│  │  • IUniAdminModuleRegistry   - 业务插件注册表                             │ │
│  │                                                                      │ │
│  │  会话管理:                                                            │ │
│  │  • FSessions: TDictionary<string, TUniAdminSession>                       │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                    │ 共享服务引用                         │
│                                    ▼                                     │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                  TUniGUIMainModule (每个会话一个)                     │ │
│  │  ─────────────────────────────────────────────────────────────────  │ │
│  │  核心属性:                                                           │ │
│  │  • Session: TUniAdminSession                                             │ │
│  │  • Plugins: TPluginCollection  ✅ 插件集合                           │ │
│  │                                                                      │ │
│  │  便捷访问:                                                           │ │
│  │  • UniMainModule.Plugins['UserManagement']                          │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                    │ 包含                                │
│                                    ▼                                     │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                       TUniAdminSession (会话对象)                          │ │
│  │  ─────────────────────────────────────────────────────────────────  │ │
│  │  会话信息:                                                           │ │
│  │  • Info: TSessionInfo (SessionID, UserID, UserName, ...)            │ │
│  │  • State: TSessionState                                             │ │
│  │  • Data: TDictionary<string, Variant> (会话数据)                     │ │
│  │                                                                      │ │
│  │  服务实例（会话级别）:                                                │ │
│  │  • AuthService: IUniAdminAuthService                                      │ │
│  │  • MenuManager: IUniAdminMenuManager                                      │ │
│  │  • PermissionManager: IUniAdminPermissionManager                          │ │
│  │                                                                      │ │
│  │  插件字典:                                                           │ │
│  │  • Plugins: TDictionary<string, TPlugin>                             │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                    │                                    │
│                                    ▼                                     │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                        TPlugin (业务插件基类)                         │ │
│  │  ─────────────────────────────────────────────────────────────────  │ │
│  │  插件资源:                                                           │ │
│  │  • Forms: TList<TFormInfo>      (窗体列表)                          │ │
│  │  • DataModules: TList<TDataModuleInfo>  (DataModule定义)             │ │
│  │  • DataModuleInstances: TDictionary<string, TDataModule>  ✅ 拥有    │ │
│  │                                                                      │ │
│  │  上下文接口:                                                         │ │
│  │  • UserContext: IUserContext      (用户信息)                        │ │
│  │  • ExecutionContext: IExecutionContext  (执行上下文)                   │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 项目目录结构

```
unigui-admin/
├── Project/                       # Delphi 项目文件
│   └── UniguiAdmin.dproj
│
├── src/                           # 源代码目录
│   ├── Core/                      # 核心层 (Phase 1-2)
│   │   ├── Plugin/                # 插件管理系统 (Phase 1)
│   │   │   ├── UniPlugin.pas               # TPlugin 基类
│   │   │   ├── UniPlugin.Intf.pas          # 插件接口定义
│   │   │   ├── UniPluginRegistry.pas       # 业务插件注册表
│   │   │   ├── UniAdminPluginLoader.pas         # 插件加载器
│   │   │   └── UniPluginManager.pas        # 轻量级插件管理器
│   │   │
│   │   ├── Session/               # 会话管理
│   │   │   └── UniAdminSession.pas              # TUniAdminSession 类
│   │   │
│   │   ├── Context/               # 上下文接口
│   │   │   ├── UniContext.pas               # 上下文接口定义
│   │   │   └── UniAppConfig.pas             # 应用配置（JSON 文件）
│   │   │
│   │   ├── Config/                # 配置管理
│   │   │   ├── UniAdminConfigService.pas         # 配置服务（全局）
│   │   │   └── UniAdminConfigService.Intf.pas    # 配置服务接口
│   │   │
│   │   ├── Metadata/              # 元数据管理
│   │   │   ├── UniAdminMetadataCache.pas         # 元数据缓存（全局）
│   │   │   ├── UniTableMetadata.pas
│   │   │   └── UniFieldMetadata.pas
│   │   │
│   │   ├── Auth/                  # 认证服务
│   │   │   ├── UniAdminAuthService.pas           # 认证服务（会话级别）
│   │   │   └── UniAdminAuthService.Intf.pas
│   │   │
│   │   ├── Menu/                  # 菜单管理
│   │   │   ├── UniAdminMenuManager.pas           # 菜单服务（会话级别）
│   │   │   └── UniAdminMenuManager.Intf.pas
│   │   │
│   │   ├── Permission/            # 权限管理（RBAC）
│   │   │   ├── UniAdminPermissionManager.pas     # 权限服务（会话级别）
│   │   │   └── UniAdminPermissionManager.Intf.pas
│   │   │
│   │   ├── Data/                  # 数据访问层
│   │   │   ├── UniAdminDataModule.pas            # 数据模块基类
│   │   │   ├── UniAdminDataModule.dfm
│   │   │   ├── UniConnection.pas
│   │   │   └── UniQuery.pas
│   │   │
│   │   └── CRUD/                  # CRUD 框架
│   │       ├── UniBaseCrudFrame.pas         # CRUD 基类代码
│   │       ├── UniBaseCrudFrame.dfm         # CRUD 基类界面
│   │       ├── UniAdminModel.pas            # 配置组件
│   │       └── UniAdminModel.Editor.pas      # 属性编辑器
│   │
│   ├── Frames/                # 通用框架
│   │   ├── MainFrame.pas                   # 主框架
│   │   ├── MainFrame.dfm
│   │   └── LoginForm.pas                   # 登录窗体
│   │       └── LoginForm.dfm
│   │
│   └── Utils/                 # 工具类
│       ├── UniSQLBuilder.pas
│       ├── UniValidators.pas
│       └── UniHelpers.pas
│
├── Plugins/                      # 业务插件目录 (Phase 3)
│   ├── UserManagement/           # 用户管理插件
│   │   ├── UserManagementPlugin.pas
│   │   ├── plugin.json
│   │   ├── UserListFrame.pas
│   │   ├── UserListFrame.dfm
│   │   ├── UserEditForm.pas
│   │   ├── UserEditForm.dfm
│   │   ├── UserDataModule.pas
│   │   └── UserDataModule.dfm
│   │
│   ├── RoleManagement/           # 角色管理插件
│   ├── MenuManagement/           # 菜单管理插件
│   ├── Dictionary/               # 数据字典插件
│   ├── SystemConfig/             # 系统配置插件
│   ├── AuditLog/                 # 日志审计插件
│   └── ScheduledTask/            # 定时任务插件
│
├── Database/                     # 数据库脚本
│   ├── Schema/                    # 表结构脚本
│   │   ├── 01_CreateSystemTables.sql
│   │   ├── 02_CreateMetadataTables.sql
│   │   └── 03_CreatePluginTables.sql
│   └── Seed/                      # 初始化数据
│       └── 01_InitialData.sql
│
├── config/                       # 配置文件
│   └── app.json                  # 应用配置
│
├── docs/                         # 文档
│   └── plans/                     # 开发计划
│
└── bin/                          # 编译输出
```

### 技术栈

| 层次 | 技术 | 说明 |
|-----|------|-----|
| **数据库** | FireDAC | 支持 SQL Server, MySQL, Oracle, PostgreSQL, SQLite |
| **Web框架** | UniGUI | Delphi Web 应用框架 |
| **插件加载** | Delphi Packages | 动态加载 .bpl 文件（轻量级插件） |
| **配置文件** | JSON | config/app.json |
| **编码规范** | 项目 AGENTS.md | PascalCase, T 前缀, 控件前缀 |
| **中文处理** | .pas 保持 GBK | .dfm 使用 char(10) 转义 |

---

## 第一阶段：插件管理层

### 目标

实现一个支持动态包（.bpl）加载的插件管理系统，为整个框架提供可扩展的基础设施。

### 核心组件

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         插件管理层 (Phase 1)                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                      IUniAdminModuleRegistry                              │ │
│  │              插件类型注册表（全局共享）                                │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                    │                                     │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                        TPlugin (业务插件基类)                         │ │
│  │  • Forms: 窗体列表                                                   │ │
│  │  • DataModules: DataModule 列表                                    │ │
│  │  • UserContext: 用户上下文接口                                     │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                    轻量级插件（.bpl）                                 │ │
│  │  • 控件插件 | 操作插件 | 验证插件 | 导出插件                          │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### TPlugin 基类

```pascal
type
  // 插件状态枚举
  TPluginState = (psUninitialized, psInitializing, psInitialized, psActivated, psDeactivated, psError);

  // 用户上下文接口
  IUserContext = interface(IInterface)
    ['{UNI-USER-CONTEXT-001}']
    function GetUserID: Integer;
    function GetUserName: string;
    function GetRealName: string;
    function HasPermission(const PermissionCode: string): Boolean;
    function GetUserPermissions: TArray<string>;
    function GetDataScope(const Resource: string): string;
    function GetSessionID: string;
    function GetClientIP: string;
  end;

  // 执行上下文接口
  IExecutionContext = interface(IInterface)
    ['{UNI-EXECUTION-CONTEXT-001}']
    function GetUserContext: IUserContext;
    function GetCurrentUserID: Integer;
    function GetCurrentUserName: string;
    function GetCurrentTime: TDateTime;
    function GetDatabaseConfig: IDatabaseConfig;
  end;

  TPlugin = class(TObject)
  private
    FInfo: TPluginInfo;
    FState: TPluginState;
    FSession: TUniAdminSession;

    FUserContext: IUserContext;
    FExecutionContext: IExecutionContext;

    FForms: TList<TFormInfo>;
    FDataModules: TList<TDataModuleInfo>;
    FDataModuleInstances: TDictionary<string, TDataModule>;

    procedure RegisterForm(const FormInfo: TFormInfo);
    procedure RegisterDataModule(const DataModuleInfo: TDataModuleInfo);
  protected
    procedure DoInitialize; virtual;
    procedure DoActivate; virtual;
    procedure DoDeactivate; virtual;
    procedure DoCleanup; virtual;
    procedure RegisterPermissions; virtual;
    procedure RegisterMenus; virtual;
  public
    constructor Create(const Session: TUniAdminSession; const Info: TPluginInfo); virtual;
    destructor Destroy; override;

    procedure Initialize;
    procedure Activate;
    procedure Deactivate;
    procedure Cleanup;

    // 窗体管理
    function GetForm(const FormName: string): TFormInfo;
    function CreateForm(const FormName: string; AOwner: TComponent): TUniForm;

    // DataModule 管理（插件自己管理）
    function GetDataModule(const DataModuleName: string): TDataModule;
    function CreateDataModuleWithContext(const DataModuleName: string): TDataModule;

    // 权限检查
    function HasPermission(const Permission: string): Boolean;

    property Info: TPluginInfo read FInfo;
    property State: TPluginState read FState;
    property UserContext: IUserContext read FUserContext;
    property CurrentUserID: Integer read FExecutionContext.GetCurrentUserID;
  end;
```

### plugin.json 格式

```json
{
  "name": "UserManagement",
  "displayName": "用户管理",
  "version": "1.0.0",
  "description": "用户管理模块",
  "author": "UniAdmin Team",
  "category": "system",
  "dependencies": ["AuthService", "PermissionService"],
  "autoStart": false,

  "forms": [
    {
      "name": "UserList",
      "type": "list",
      "displayName": "用户列表",
      "icon": "users",
      "routePath": "/system/users",
      "sortOrder": 1
    }
  ],

  "dataModules": [
    {
      "name": "UserDataModule",
      "class": "TUserDataModule",
      "description": "用户管理数据模块",
      "isShared": true
    }
  ],

  "config": {
    "defaultPageSize": 20,
    "enableAvatarUpload": true
  }
}
```

### 数据库表

```sql
-- 业务插件注册表
CREATE TABLE UniAdmin_Modules (
    ModuleID       INT PRIMARY KEY IDENTITY(1,1),
    ModuleName     NVARCHAR(100)      NOT NULL UNIQUE,
    ModuleType     NVARCHAR(20)       NOT NULL,
    EntryPoint     NVARCHAR(255),
    Version        NVARCHAR(20)       NOT NULL,
    Description    NVARCHAR(500),
    Author         NVARCHAR(100),
    State          NVARCHAR(20)       NOT NULL DEFAULT 'Disabled',
    AutoStart      BIT                NOT NULL DEFAULT 0,
    InstalledDate  DATETIME,
    ModifiedDate   DATETIME,
    CONSTRAINT CK_ModuleType CHECK (ModuleType IN ('business','plugin'))
);

-- 配置表（模块配置，UI可视化管理）
CREATE TABLE UniAdmin_Configs (
    ConfigID       INT PRIMARY KEY IDENTITY(1,1),
    ModuleName     NVARCHAR(100)      NOT NULL,
    Section        NVARCHAR(100)      NOT NULL,
    Key            NVARCHAR(100)      NOT NULL,
    Value          NTEXT,
    ValueType      NVARCHAR(20)       NOT NULL DEFAULT 'string',
    DefaultValue   NTEXT,
    Description    NVARCHAR(500),
    Category       NVARCHAR(100),
    SortOrder      INT                NOT NULL DEFAULT 0,
    CreatedDate    DATETIME           NOT NULL DEFAULT GETDATE(),
    ModifiedDate   DATETIME           NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_Config UNIQUE(ModuleName, Section, [Key])
);

-- 模块依赖关系表
CREATE TABLE UniAdmin_ModuleDependencies (
    DependencyID   INT PRIMARY KEY IDENTITY(1,1),
    ModuleName     NVARCHAR(100)      NOT NULL,
    DependsOn      NVARCHAR(100)      NOT NULL,
    CONSTRAINT FK_DepModule FOREIGN KEY (ModuleName) REFERENCES UniAdmin_Modules(ModuleName),
    CONSTRAINT FK_DependsOn FOREIGN KEY (DependsOn) REFERENCES UniAdmin_Modules(ModuleName)
);
```

### 第一阶段交付物

| 交付物 | 说明 |
|-------|------|
| **TPlugin 基类** | 插件基类实现 |
| **IUniAdminModuleRegistry** | 插件注册表 |
| **插件配置管理** | 配置持久化和可视化 |
| **示例业务插件** | 数据字典模块示例 |
| **数据库脚本** | 模块和配置表 |

---

## 第二阶段：核心框架层

### 目标

在插件管理层之上，构建框架的核心功能组件，实现元数据驱动的 CRUD 引擎。

### 核心组件架构

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         核心框架层详细架构                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                          UI 层                                      │ │
│  │  ┌────────────────────────────────────────────────────────────────┐ │ │
│  │  │                     TBaseCrudFrame                             │ │ │
│  │  │  pnlFilter | pnlToolbar | grdList | pnlPager | pnlEdit         │ │ │
│  │  └────────────────────────────────────────────────────────────────┘ │ │
│  │                              ↑ 使用                                 │ │
│  │  ┌────────────────────────────────────────────────────────────────┐ │ │
│  │  │                    TUniAdminModel                              │ │ │
│  │  │  设计时配置组件：ListDisplay | ListFilter | FieldSets           │ │ │
│  │  └────────────────────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                   │                                     │
│                                   ▼                                     │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                         服务层 (Services)                            │ │
│  │  AuthService | MenuManager | PermissionManager | MetadataCache       │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                   │                                     │
│                                   ▼                                     │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                       数据访问层                                     │ │
│  │  UniAdminDataModule (每个插件管理自己的 DataModule)                     │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 服务分配

| 服务 | 位置 | 共享类型 | 说明 |
|-----|------|---------|------|
| **IUniAdminConfigService** | ServerModule | 全局共享 | 配置服务（读写 config/app.json） |
| **IUniAdminMetadataCache** | ServerModule | 全局共享 | 元数据缓存（表结构、字段信息） |
| **IUniAdminModuleRegistry** | ServerModule | 全局共享 | 业务插件注册表 |
| **IUniAdminAuthService** | Session | 会话级别 | 认证服务 |
| **IUniAdminMenuManager** | Session | 会话级别 | 菜单管理 |
| **IUniAdminPermissionManager** | Session | 会话级别 | 权限管理（RBAC） |
| **TPlugin** | Session.Plugins | 会话级别 | 插件实例 |
| **TDataModule** | Plugin.DataModuleInstances | 插件级别 | 每个插件管理自己的 DataModule |

### config/app.json 配置文件

```json
{
  "version": "1.0.0",
  "application": {
    "name": "UniAdmin 管理系统",
    "title": "UniAdmin",
    "logo": "/images/logo.png",
    "copyright": "© 2025 UniAdmin Team"
  },
  "server": {
    "port": 8077,
    "host": "0.0.0.0",
    "sessionTimeout": 1800,
    "maxSessions": 1000
  },
  "database": {
    "type": "MSSQL",
    "connectionString": "Server=localhost;Port=1433;Database=UniAdmin;User_Name=sa;Password=your_password",
    "connectionTimeout": 30,
    "pooling": true
  },
  "auth": {
    "sessionTimeout": 1800,
    "maxLoginAttempts": 5,
    "passwordPolicy": {
      "minLength": 6,
      "requireComplexity": true
    }
  }
}
```

### RBAC 权限模型

```
用户(User) ──N:M── 角色(Role) ──N:M── 权限
```

```sql
-- 用户表
CREATE TABLE UniAdmin_Users (
    UserID          INT PRIMARY KEY IDENTITY(1,1),
    UserName        NVARCHAR(50)       NOT NULL UNIQUE,
    Password        NVARCHAR(255)      NOT NULL,
    RealName        NVARCHAR(100),
    Email           NVARCHAR(100),
    Status          INT                NOT NULL DEFAULT 1,
    CreatedDate     DATETIME           NOT NULL DEFAULT GETDATE()
);

-- 角色表
CREATE TABLE UniAdmin_Roles (
    RoleID          INT PRIMARY KEY IDENTITY(1,1),
    RoleCode        NVARCHAR(50)       NOT NULL UNIQUE,
    RoleName        NVARCHAR(100)      NOT NULL,
    DataScope      NVARCHAR(20)       NOT NULL DEFAULT 'self'
);

-- 权限表
CREATE TABLE UniAdmin_Permissions (
    PermissionID    INT PRIMARY KEY IDENTITY(1,1),
    PermissionCode  NVARCHAR(100)      NOT NULL UNIQUE,
    PermissionName  NVARCHAR(100)      NOT NULL,
    ResourceType    NVARCHAR(50)       NOT NULL,
    ResourceCode    NVARCHAR(100)      NOT NULL,
    Action          NVARCHAR(20)       NOT NULL
);

-- 用户-角色关联表
CREATE TABLE UniAdmin_UserRoles (
    ID              INT PRIMARY KEY IDENTITY(1,1),
    UserID          INT NOT NULL,
    RoleID          INT NOT NULL,
    CONSTRAINT FK_UserRole_User FOREIGN KEY (UserID) REFERENCES UniAdmin_Users(UserID),
    CONSTRAINT FK_UserRole_Role FOREIGN KEY (RoleID) REFERENCES UniAdmin_Roles(RoleID),
    CONSTRAINT UQ_UserRole UNIQUE(UserID, RoleID)
);

-- 角色-权限关联表
CREATE TABLE UniAdmin_RolePermissions (
    ID              INT PRIMARY KEY IDENTITY(1,1),
    RoleID          INT NOT NULL,
    PermissionID    INT NOT NULL,
    CONSTRAINT FK_RolePermission_Role FOREIGN KEY (RoleID) REFERENCES UniAdmin_Roles(RoleID),
    CONSTRAINT FK_RolePermission_Perm FOREIGN KEY (PermissionID) REFERENCES UniAdmin_Permissions(PermissionID),
    CONSTRAINT UQ_RolePermission UNIQUE(RoleID, PermissionID)
);
```

### TUniAdminModel 配置组件

```pascal
type
  TListDisplayItem = class(TCollectionItem)
  published
    property FieldName: string read FFieldName write FFieldName;
    property Header: string read FHeader write FHeader;
    property Width: Integer read FWidth write FWidth default 100;
    property Sortable: Boolean read FSortable write FSortable default True;
  end;

  TListFilterItem = class(TCollectionItem)
  published
    property FieldName: string read FFieldName write FFieldName;
    property FilterType: string read FFilterType write FFilterType;
    property Control: string read FControl write FControl;
  end;

  TFieldSetItem = class(TCollectionItem)
  published
    property Title: string read FTitle write FTitle;
    property Fields: string read FFields write FFields;
    property Collapsible: Boolean read FCollapsible write FCollapsible default True;
    property Columns: Integer read FColumns write FColumns default 1;
  end;

  TUniAdminModel = class(TComponent)
  published
    // 基本配置
    property TableName: string read FTableName write FTableName;
    property PrimaryKey: string read FPrimaryKey write FPrimaryKey;
    property DisplayName: string read FDisplayName write FDisplayName;
    property SoftDelete: Boolean read FSoftDelete write FSoftDelete default False;

    // 列表配置
    property ListDisplay: TCollection read FListDisplay write FListDisplay;
    property ListFilter: TCollection read FListFilter write FListFilter;
    property SearchFields: string read FSearchFields write FSearchFields;
    property PageSize: Integer read FPageSize write FPageSize default 20;

    // 表单配置
    property FieldSets: TCollection read FFieldSets write FFieldSets;

    // 钩子事件
    property BeforeInsert: TNotifyEvent read FBeforeInsert write FBeforeInsert;
    property AfterInsert: TNotifyEvent read FAfterInsert write FAfterInsert;
    property BeforeUpdate: TNotifyEvent read FBeforeUpdate write FBeforeUpdate;
    property AfterUpdate: TNotifyEvent read FAfterUpdate write FAfterUpdate;
  end;
```

### TBaseCrudFrame CRUD 基类

```pascal
type
  TUniBaseCrudFrame = class(TUniFrame)
  private
    FModelAdmin: TUniAdminModel;
    FPlugin: TPlugin;

    // UI 组件
    pnlFilter: TUniPanel;
    pnlToolbar: TUniPanel;
    pnlGrid: TUniPanel;
    grdList: TUniDBGrid;
    pnlPager: TUniPanel;
    pnlEdit: TUniPanel;

    // 数据组件（从插件获取）
    dsList: TDataSource;
    qryList: TFDQuery;
  public
    procedure Refresh;
    procedure AddNew;
    procedure EditRecord(const ID: Variant);
    procedure DeleteSelected;
    procedure ExportData;
  end;
```

### 第二阶段交付物

| 交付物 | 说明 |
|-------|------|
| **UniAdminDataModule** | 支持多数据库的数据模块基类 |
| **元数据管理系统** | 元数据缓存、解析、管理 |
| **认证服务** | 登录、登出、会话管理 |
| **菜单管理服务** | 菜单树加载、权限过滤 |
| **权限管理服务** | RBAC 权限检查、角色管理 |
| **TUniAdminModel** | 设计时配置组件 |
| **TBaseCrudFrame** | CRUD 基类 Frame |
| **示例 CRUD** | 1-2 个示例模块 |

---

## 第三阶段：系统模块层

### 目标

基于核心框架层，实现系统内置的管理模块，提供完整的后台管理功能。

### 模块清单

| 模块 | 插件类 | 窗体 | DataModule | 权限前缀 |
|-----|--------|------|-------------|---------|
| **用户管理** | TUserManagementPlugin | UserListFrame<br>UserEditForm<br>UserPasswordForm<br>ProfileForm | UserDataModule | user: |
| **角色管理** | TRoleManagementPlugin | RoleListFrame<br>RoleEditForm<br>RolePermissionForm<br>RoleUserForm | RoleDataModule | role: |
| **菜单管理** | TMenuManagementPlugin | MenuListFrame<br>MenuEditForm | MenuDataModule | menu: |
| **数据字典** | TDictionaryPlugin | DictListFrame<br>DictEditForm<br>DictItemEditForm | DictDataModule | dict: |
| **系统配置** | TSystemConfigPlugin | ConfigListFrame<br>ConfigEditForm | ConfigDataModule | config: |
| **日志审计** | TAuditLogPlugin | LoginLogFrame<br>OperationLogFrame<br>DataChangeLogFrame | LogDataModule | log: |
| **定时任务** | TScheduledTaskPlugin | TaskListFrame<br>TaskEditForm<br>TaskLogFrame | TaskDataModule | task: |

### 用户管理模块示例

```pascal
type
  TUserManagementPlugin = class(TPlugin, ILoginAware)
  private
    function GetUserDM: TUserDataModule;
  protected
    procedure DoInitialize; override;
  public
    // 业务方法
    function GetUsers(const Filter: string): TFDQuery;
    procedure CreateUser(const UserName, Password, RealName: string);
    procedure UpdateUser(const UserID: Integer; const RealName, Email: string);
    procedure DeleteUser(const UserID: Integer);
    procedure ResetPassword(const UserID: Integer; const NewPassword: string);

    // 窗体创建
    function CreateUserListFrame(AOwner: TComponent): TUserListFrame;
    function CreateUserEditForm(AOwner: TComponent): TUserEditForm;
  end;
```

### 第三阶段交付物

| 交付物 | 说明 |
|-------|------|
| **UserManagement Plugin** | 完整的用户管理功能 |
| **RoleManagement Plugin** | 角色和权限管理 |
| **MenuManagement Plugin** | 菜单树管理 |
| **Dictionary Plugin** | 数据字典管理 |
| **SystemConfig Plugin** | 系统配置管理 |
| **AuditLog Plugin** | 登录日志、操作日志、数据变更日志 |
| **ScheduledTask Plugin** | 定时任务管理 |
| **MainFrame** | 主界面框架 |
| **初始化脚本** | 完整的数据库初始化 SQL 脚本 |

---

## 开发计划

### 总体时间表

| 阶段 | 周期 | 主要工作 |
|-----|------|---------|
| **第一阶段** | 2-3 周 | 插件管理系统 |
| **第二阶段** | 4-6 周 | 核心框架层 |
| **第三阶段** | 3-4 周 | 系统模块层 |
| **总计** | 9-13 周 | 完整框架 |

### 第一阶段详细计划（2-3 周）

| Week | 任务 | 交付物 |
|------|------|-------|
| 1 | • TPlugin 基类<br>• IUniAdminModuleRegistry<br>• 插件配置管理 | 插件基类和注册表 |
| 2 | • 配置持久化<br>• 配置管理UI<br>• 配置历史 | 配置管理系统 |
| 3 | • 示例业务插件<br>• 单元测试 | 数据字典模块示例 |

### 第二阶段详细计划（4-6 周）

| Week | 任务 | 交付物 |
|------|------|-------|
| 1 | • UniAdminDataModule（多数据库支持）<br>• 配置文件加载 | 数据访问层 |
| 2 | • UniAdminMetadataCache<br>• 元数据解析 | 元数据管理 |
| 3 | • AuthService<br>• MenuManager<br>• PermissionManager | 核心服务 |
| 4 | • TUniAdminModel<br>• 属性编辑器 | 配置组件 |
| 5 | • TBaseCrudFrame<br>• CRUD 引擎 | CRUD 基类 |
| 6 | • 集成测试<br>• 示例模块 | 验证框架 |

### 第三阶段详细计划（3-4 周）

| Week | 任务 | 交付物 |
|------|------|-------|
| 1-2 | • UserManagement Plugin<br>• RoleManagement Plugin<br>• MenuManagement Plugin | 核心模块 |
| 2-3 | • Dictionary Plugin<br>• SystemConfig Plugin | 扩展模块 |
| 3-4 | • AuditLog Plugin<br>• ScheduledTask Plugin<br>• MainFrame 集成 | 日志任务 + 主界面 |

---

## 附录

### A. 上下文一致性保障

| 层次 | 机制 | 说明 |
|-----|------|------|
| **登录层** | Session.Login() | 设置用户信息，加载权限菜单，激活插件 |
| **插件层** | 上下文接口 | 插件保存 UserContext 和 ExecutionContext |
| **DataModule层** | SetContext() | 注入上下文，可访问当前用户信息 |
| **数据操作层** | SetAuditFields() | 自动填充审计字段 |
| **数据查询层** | ApplyDataScope() | 自动应用数据权限过滤 |

### B. 使用示例

```pascal
// 登录
procedure TLoginForm.btnLoginClick(Sender: TObject);
begin
  LoginResult := AuthService.Login(edtUserName.Text, edtPassword.Text);
  if LoginResult.Success then
  begin
    UniMainModule.Session.Login(LoginResult.UserID, LoginResult.UserName);
    UniMainModule.Session.ActivateAllPlugins;
    UniMainModule.SendToMainFrame;
  end;
end;

// 在 Frame 中使用
procedure TUserListFrame.LoadData;
var
  UserPlugin: TUserManagementPlugin;
begin
  UserPlugin := UniMainModule.Plugins['UserManagement'] as TUserManagementPlugin;
  dsList.DataSet := UserPlugin.GetUsers('');
end;

// 在 DataModule 中使用
procedure TUserDataModule.CreateUser(const UserName, Password: string);
begin
  if not HasPermission('user:add') then
    raise Exception.Create('没有权限');

  Cmd.ParamByName('CreatedBy').AsInteger := CurrentUserID;
  Cmd.ParamByName('CreatedDate').AsDateTime := Context.GetCurrentTime;
  Cmd.Execute;
end;
```

### C. 命名规范速查

| 类型 | 命名规则 | 示例 |
|-----|---------|------|
| Unit 单元 | PascalCase | UniUserManagementPlugin |
| Form/Frame 类 | T + PascalCase + Frame/Form | TUserListFrame |
| DataModule 类 | T + PascalCase + DataModule | TUserDataModule |
| 控件 | 前缀 + PascalCase | btnSave, edtUserName, grdUsers |
| 私有字段 | F + PascalCase | FUserID, FUserName |
| 参数 | PascalCase | AUserName, AOwner |
| 常量 | 全大写 + 下划线 | MAX_RETRY_COUNT |

---

*文档版本: 1.0*
*最后更新: 2025-02-23*

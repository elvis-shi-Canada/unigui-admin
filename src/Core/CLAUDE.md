[根目录](../../CLAUDE.md) > **src** > **Core**

# Core 模块 - 核心框架层

> **职责**: 提供 UniAdmin 框架的核心基础设施和公共服务
> **状态**: ✅ 完成
> **覆盖率**: 90%

---

## 模块职责

Core 模块是 UniAdmin 框架的基础设施层，提供：

- **插件系统** - 动态加载、注册和管理业务插件
- **数据访问** - 统一的数据访问层和连接管理
- **认证授权** - 用户认证和权限管理
- **菜单管理** - 动态菜单生成和权限过滤
- **元数据管理** - 数据库表结构和字段元数据缓存
- **UI 框架** - CRUD 基类和配置驱动组件
- **服务定位** - 依赖注入和服务生命周期管理

---

## 目录结构

```
Core/
├── Context/                # 执行上下文
│   └── UniContext.pas     # 上下文接口和实现
├── Plugin/                 # 插件系统
│   ├── UniPlugin.Intf.pas          # 插件接口
│   ├── UniPlugin.Types.pas         # 插件类型定义
│   ├── UniPlugin.pas               # 插件基类
│   ├── UniModuleRegistry.Intf.pas  # 模块注册接口
│   ├── UniModuleRegistry.pas       # 模块注册实现
│   ├── UniModuleRegistration.pas   # 模块注册配置
│   └── UniPluginLoader.pas         # 插件加载器
├── Data/                   # 数据访问
│   ├── UniConnectionManager.Intf.pas  # 连接管理接口
│   ├── UniConnectionManager.pas      # 连接管理实现
│   └── UniDataModule.pas             # 数据模块基类
├── Metadata/               # 元数据管理
│   ├── UniMetadataCache.Intf.pas     # 元数据缓存接口
│   ├── UniMetadataCache.pas          # 元数据缓存实现
│   └── UniFieldMetadata.pas          # 字段元数据
├── Auth/                   # 认证服务
│   ├── UniAuthService.Intf.pas        # 认证接口
│   └── UniAuthService.pas            # 认证实现
├── Menu/                   # 菜单管理
│   ├── UniMenuManager.Intf.pas        # 菜单接口
│   ├── UniMenuManager.pas            # 菜单实现
│   └── SystemMenuSetup.pas           # 系统菜单配置
├── Permission/             # 权限管理
│   ├── UniPermissionManager.Intf.pas  # 权限接口
│   └── UniPermissionManager.pas      # 权限实现
├── Services/               # 核心服务
│   └── UniServices.pas      # 服务定位器
├── Session/                # 会话管理
│   └── UniSession.pas       # 会话上下文
├── Scheduler/              # 调度器
│   ├── UniScheduler.pas     # 任务调度器
│   └── UniTaskProcessor.pas # 任务处理器
├── Config/                 # 配置服务
│   ├── UniConfigService.Intf.pas  # 配置接口
│   └── UniConfigService.pas      # 配置实现
├── Main/                   # 主模块
│   ├── ServerModule.pas    # UniGUI 服务器模块
│   └── MainModule.pas      # UniGUI 主模块
└── UI/                     # UI 组件
    ├── LoginForm.pas       # 登录窗体
    ├── MainFrame.pas       # 主窗体
    ├── BaseCrudFrame.pas   # CRUD 基类
    ├── UniModelAdmin.pas   # 模型管理组件
    ├── UniPropertyEditor.pas # 属性编辑器
    ├── UniLayout.pas       # 布局组件
    ├── UniTheme.pas        # 主题组件
    └── Templates/          # UI 模板
        ├── BaseFormTemplate.pas
        ├── DialogTemplate.pas
        ├── EditFormTemplate.pas
        ├── GridTemplate.pas
        ├── QueryPanelTemplate.pas
        ├── SplitterTemplate.pas
        ├── StatusBarTemplate.pas
        ├── TabSheetTemplate.pas
        └── WizardTemplate.pas
```

---

## 入口与启动

### 主程序入口

**文件**: `UniAdmin.dpr`

```pascal
program UniAdmin;

begin
  Application.Initialize;
  Application.ServerModuleClass := TServerModule;
  Application.MainModuleClass := TMainModule;
  Application.LoginFormClass := TLoginForm;
  Application.MainFormClass := TMainFrame;
  Application.Run;
end;
```

### 启动流程

```
UniAdmin.dpr
    ↓
ServerModule (服务器初始化)
    ↓
MainModule (主模块初始化)
    ↓
LoginForm (用户登录)
    ↓
MainFrame (主界面加载)
    ↓
插件加载 (UniModuleRegistry)
    ↓
菜单生成 (UniMenuManager)
```

---

## 对外接口

### 插件系统接口

**IPlugin** (`UniPlugin.Intf.pas`)

```pascal
IPlugin = interface(IInterface)
  ['{GUID}']
  procedure Initialize;
  procedure Activate;
  procedure Deactivate;
  function GetInfo: TPluginInfo;
end;
```

### 认证服务接口

**IUniAuthService** (`UniAuthService.Intf.pas`)

```pascal
IUniAuthService = interface(IInterface)
  ['{GUID}']
  function Login(const UserName, Password: string): Boolean;
  procedure Logout;
  function GetCurrentUserID: Integer;
  function GetCurrentUser: TUserInfo;
end;
```

### 菜单管理接口

**IUniMenuManager** (`UniMenuManager.Intf.pas`)

```pascal
IUniMenuManager = interface(IInterface)
  ['{GUID}']
  function GetMenuTree(const UserID: Integer): TMenuNodeArray;
  procedure AddMenuItem(const Item: TMenuItem);
  procedure UpdateMenuItem(const Item: TMenuItem);
  procedure DeleteMenuItem(const MenuID: Integer);
end;
```

### 权限管理接口

**IUniPermissionManager** (`UniPermissionManager.Intf.pas`)

```pascal
IUniPermissionManager = interface(IInterface)
  ['{GUID}']
  function CheckPermission(const UserID: Integer; const Permission: string): Boolean;
  function GetUserPermissions(const UserID: Integer): TPermissionArray;
  procedure AssignRolePermissions(const RoleID: Integer; const Permissions: array of string);
end;
```

---

## 关键依赖与配置

### 依赖项

| 依赖 | 版本 | 用途 |
|------|------|------|
| UniGUI | 1.6+ | Web 应用框架 |
| FireDAC | - | 数据访问组件 |
| Delphi 12 | Athens | 开发环境 |

### 配置文件

**app.json** (`config/app.json`)

```json
{
  "version": "1.0.0",
  "application": {
    "name": "UniAdmin 管理系统",
    "title": "UniAdmin"
  },
  "server": {
    "port": 8077,
    "host": "0.0.0.0",
    "sessionTimeout": 1800
  },
  "database": {
    "type": "MSSQL",
    "connectionString": "Server=localhost;Database=UniAdmin;..."
  }
}
```

---

## 数据模型

### 核心数据表

| 表名 | 说明 | 关键字段 |
|------|------|----------|
| `UniAdmin_Users` | 用户表 | UserID, UserName, Password, Status |
| `UniAdmin_Roles` | 角色表 | RoleID, RoleCode, RoleName, DataScope |
| `UniAdmin_Permissions` | 权限表 | PermissionID, PermissionCode, ResourceType |
| `UniAdmin_UserRoles` | 用户角色关联 | UserID, RoleID |
| `UniAdmin_RolePermissions` | 角色权限关联 | RoleID, PermissionID |
| `UniAdmin_Menus` | 菜单表 | MenuID, MenuName, ParentID, MenuType |
| `UniAdmin_Modules` | 模块注册表 | ModuleID, ModuleCode, AssemblyName |
| `UniAdmin_Configs` | 系统配置 | ConfigID, ConfigKey, ConfigValue |

---

## 测试与质量

### 单元测试

**测试文件**: `tests/Core/Plugin/UniPluginTest.pas`

```pascal
TUniPluginTest = class(TTestCase)
published
  procedure TestPluginRegistration;
  procedure TestPluginActivation;
  procedure TestPluginDependencies;
end;
```

### 运行测试

```bash
cd tests
UniAdminTests.exe
```

---

## 常见问题 (FAQ)

### Q: 如何创建新的插件?

A: 参考 `DictionaryPlugin.pas` 实现示例：

1. 实现 `IPlugin` 接口
2. 在 `UniModuleRegistration.pas` 中注册
3. 编译为 BPL 包或直接链接到主程序

### Q: 如何扩展权限系统?

A: 实现 `IUniPermissionManager` 接口并注册：

```pascal
TUniServices.RegisterService<IUniPermissionManager>(TCustomPermissionManager);
```

### Q: 数据库连接失败怎么办?

A: 检查 `config/app.json` 中的连接字符串，确保：
- SQL Server 服务已启动
- 用户名密码正确
- 防火墙允许连接

---

## 相关文件清单

### 核心接口文件

- `UniPlugin.Intf.pas` - 插件接口
- `UniPlugin.Types.pas` - 插件类型定义
- `UniModuleRegistry.Intf.pas` - 模块注册接口
- `UniAuthService.Intf.pas` - 认证接口
- `UniMenuManager.Intf.pas` - 菜单接口
- `UniPermissionManager.Intf.pas` - 权限接口
- `UniMetadataCache.Intf.pas` - 元数据接口
- `UniConfigService.Intf.pas` - 配置接口

### 核心实现文件

- `UniPlugin.pas` - 插件基类
- `UniModuleRegistry.pas` - 模块注册
- `UniAuthService.pas` - 认证实现
- `UniMenuManager.pas` - 菜单实现
- `UniPermissionManager.pas` - 权限实现
- `UniMetadataCache.pas` - 元数据缓存
- `UniConfigService.pas` - 配置实现

### UI 框架文件

- `BaseCrudFrame.pas` - CRUD 基类
- `UniModelAdmin.pas` - 模型管理组件
- `LoginForm.pas` - 登录窗体
- `MainFrame.pas` - 主窗体

---

## 变更记录 (Changelog)

| 日期 | 操作 | 说明 |
|------|------|------|
| 2026-03-02 | 初始化 | 创建 Core 模块文档 |

---

*模块版本: 1.0*
*最后更新: 2026-03-02*

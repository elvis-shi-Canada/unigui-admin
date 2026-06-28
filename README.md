# UniAdmin

> A zero-code admin framework built on Delphi 12 Athens + UniGUI, inspired by Django Admin.

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Delphi](https://img.shields.io/badge/Delphi-12%20Athens-E62020.svg)
![Platform](https://img.shields.io/badge/Platform-Windows-0078D6.svg)
![UniGUI](https://img.shields.io/badge/UniGUI-1.6%2B-00A4EF.svg)
![Database](https://img.shields.io/badge/Database-SQL%20Server-CC2927.svg)

基于 Delphi 12 Athens + UniGUI 的零代码后台管理框架，借鉴 Django Admin 设计理念。插件化核心、设计时配置、运行时驱动——通过配置声明即可生成完整 CRUD，无需编写重复代码。

## 特性

- **插件化架构** — 动态加载、注册、依赖解析的业务模块扩展
- **声明式 Admin 引擎** — 一个 `TModelAdmin` 记录即可声明 `list_display` / `search_fields` / 权限前缀，引擎自动派生网格列、参数化查询、菜单与权限（Django Admin 风格）
- **元数据驱动** — 自动发现数据库 Schema，元数据缓存驱动网格列生成
- **RBAC 权限** — 用户-角色-权限三级模型，声明式引擎按前缀自动派生 `view/add/edit/delete`
- **任务调度** — Cron 表达式驱动的定时任务，内置健康检查、日志清理、数据库备份
- **日志审计** — 登录日志、操作日志、数据变更日志，支持 Excel/CSV/JSON/XML 导出
- **数据驱动 MDI** — 菜单路由零代码，Frame 缓存保状态，新增模块不改主框架

## 技术栈

| 组件 | 版本/技术 |
|------|-----------|
| 语言 | Delphi 12 Athens |
| Web 框架 | UniGUI 1.6+ |
| 数据访问 | FireDAC |
| 数据库 | SQL Server |
| 测试 | DUnitX |

## 快速开始

### 环境要求

- Embarcadero RAD Studio 12 Athens
- Visual Studio 2022 BuildTools（MSBuild）
- VS Code + DelphiLSP 扩展（可选）

### 构建

VS Code 中按 `Ctrl+Shift+B`，或终端执行：

```bash
.vscode/CompileOmniPascalServerProject.bat build
```

### 构建并运行

VS Code 中运行 `test` 任务，或终端执行：

```bash
.vscode/CompileOmniPascalServerProject.bat test
```

### 清理

```bash
clean.bat
```

## 项目结构

```
src/
├── Core/              核心框架
│   ├── Admin/         声明式引擎（TModelAdmin、查询生成器、注册中心）
│   ├── Auth/          认证服务
│   ├── Config/        配置管理
│   ├── Context/       执行上下文
│   ├── Data/          数据访问层
│   ├── Main/          服务器/主模块
│   ├── Menu/          菜单管理
│   ├── Metadata/      元数据缓存
│   ├── Permission/    权限管理
│   ├── Plugin/        插件系统
│   ├── Scheduler/     任务调度
│   ├── Services/      服务定位器
│   ├── Session/       会话管理
│   └── UI/            UI 框架（BaseCrudFrame、AutoCrudFrame、MainFrame、MdiRouter、模板）
├── Modules/           业务模块
│   ├── User/          用户管理
│   ├── Role/          角色管理
│   ├── Menu/          菜单管理
│   ├── Dictionary/    数据字典
│   ├── Config/        系统配置
│   ├── Log/           日志审计
│   └── Scheduler/     定时任务
└── Plugins/           插件扩展
    └── Dictionary/    字典插件示例
```

## 模块完成度

| 模块 | 状态 | 说明 |
|------|------|------|
| 核心框架 | ✅ 完成 | 插件系统、认证授权、元数据缓存、服务定位器 |
| 用户管理 | ✅ 完成 | CRUD、密码管理、操作日志集成 |
| 角色管理 | ✅ 完成 | 角色定义、权限分配、数据范围 |
| 菜单管理 | ✅ 完成 | 动态树形菜单、路径更新、权限过滤 |
| 数据字典 | ✅ 完成 | 字典类型/项管理、缓存机制 |
| 系统配置 | ✅ 完成 | 分类管理、多类型值、缓存 |
| 日志审计 | ✅ 完成 | 三类日志 + Excel/CSV/JSON/XML 导出 |
| 定时任务 | ✅ 完成 | Cron 调度、日志清理、数据库备份、健康检查 |
| 插件系统 | ✅ 完成 | 生命周期管理、依赖解析、循环检测、示例插件 |
| UI 模板 | ✅ 完成 | 9 个模板（表单、对话框、网格、向导等） |
| 辅助工具 | ✅ 完成 | 10 个工具（代码生成、性能分析、日志查看等） |

## MDI 架构（数据驱动路由）

主界面采用**数据驱动的 MDI 路由**：菜单项的 `RoutePath` 字段直接存储目标 Frame/Form 类名，`TUniAdminMdiRouter` 在运行时通过 `FindClass` 动态加载，每个模块作为可关闭标签页（TUniPageControl）打开；切换菜单时标签页状态完整保留（筛选/分页/滚动）。

**新增一个业务模块，主框架零修改——只需 3 步：**

1. 编写 `TUniFrame` 子类，并在单元 `initialization` 段注册类：
   ```pascal
   initialization
     RegisterClass(TMyListFrame);
   ```
2. 在 `UniAdmin_Menus` 表中，将该菜单的 `RoutePath` 设为 `'TMyListFrame'`
3. 完成！点击菜单即自动路由打开

**核心机制：**

| 机制 | 说明 |
|------|------|
| 数据驱动路由 | `RoutePath`（类名）→ `FindClass` 动态实例化，告别 if-else 硬编码 |
| 多标签缓存 | 每模块一个可关闭标签页（TUniPageControl），切换保留状态 |
| 打开方式推导 | 类名以 `Form` 结尾 → 模态窗口；否则 → 嵌入内容区 |
| 开闭原则 | 新增模块对扩展开放，对 MainFrame 修改封闭（SOLID-O） |

> 📐 设计参考：**FSThemeCrystal**（Falcon Sistemas 出品的 uniGUI + UniFalcon 水晶主题 Demo），借鉴其 `FindClass` 动态加载与 Panel 缓存模式。
> 完整方案详见 [MDI 架构设计方案](docs/plans/2026-06-26-mdi-architecture-design.md)。

## 声明式 Admin 引擎（Django Admin 风格）

在 MDI 路由之上，本项目实现了 Django Admin 风格的**声明式 CRUD**：业务模块只需在单元 `initialization` 段向 `TModelAdminRegistry` 注册一份声明（表名、列表字段、搜索字段、权限前缀），引擎自动派生网格列、参数化查询、菜单项和权限码，**无需手写 SQL、无需手写网格列定义**。

**一个完整声明（UserListFrame 落地示例）：**

```pascal
initialization
  TModelAdminRegistry.CreateInstance.Register(
    TModelAdmin.Create('user', 'UniAdmin_Users', '用户管理')
      .WithFrame('TUserListFrame')
      .WithListDisplay([
        TAdminFieldConfig.Create('UserID', 'ID', 50),
        TAdminFieldConfig.Create('UserName', '用户名', 100),
        TAdminFieldConfig.Create('Email', '邮箱', 150),
        TAdminFieldConfig.Create('Status', '状态', 60)
      ])
      .WithSearchFields(['UserName', 'RealName', 'Email'])
      .WithFilterFields(['Status'])
      .WithPermissionPrefix('user')
      .WithSortOrder(110)
      .WithParentMenuCode('system')
  );
  RegisterClass(TUserListFrame);
```

**核心单元：**

| 单元 | 职责 |
|------|------|
| `Core/Admin/UniModelAdmin.Intf.pas` | `TModelAdmin` 声明记录 + fluent 链式 API + `IModelAdminRegistry` 接口 |
| `Core/Admin/UniModelAdmin.pas` | 进程级注册中心单例（双检锁惰性创建，`initialization` 段注册、`finalization` 段清理） |
| `Core/Admin/UniQueryBuilder.pas` | 通用参数化 SELECT/WHERE 生成器，标识符白名单防 SQL 注入 |
| `Core/UI/AutoCrudFrame.pas` | 零样板的声明式 CRUD Frame，`BindAdmin(AdminID)` 即用 |
| `Core/UI/BaseCrudFrame.pas` | 基类新增 `AutoGridFromMeta` 开关，从元数据缓存派生网格列（默认关闭，向后兼容） |
| `Core/Menu/SystemMenuSetup.pas` | `BuildMenusFromRegistry` / `BuildPermissionsFromRegistry` 从声明自动派生菜单与权限 |

**自动派生能力（声明 → 运行时）：**

| 声明字段 | 自动产出 |
|---------|---------|
| `TableName` + 元数据缓存 | 网格列（跳过 Password / 审计字段） |
| `SearchFields` | LIKE-OR 参数化搜索（共享单参数，去重） |
| `FilterFields` | 等值参数化筛选 |
| `PermissionPrefix` | `prefix:view/add/edit/delete` 四件套权限 + 按钮可见性 |
| `ParentMenuCode` + `SortOrder` + `FrameClassName` | 菜单项（`RoutePath` 指向类名，MdiRouter 解析） |

### 快速开始（端到端开发一个声明式模块）

以"商品管理"为例，从零到菜单自动出现，完整 5 步。主框架、菜单表、权限表零手改。

**第 1 步：建数据库表**

在 `Database/Schema/` 加建表 SQL，或直接在 DB 执行。表名 `Products`：

```sql
CREATE TABLE Products (
  ProductID  INTEGER PRIMARY KEY AUTOINCREMENT,
  Name       TEXT NOT NULL,
  SKU        TEXT,
  Price      NUMERIC(10,2),
  Status     INTEGER NOT NULL DEFAULT 1,
  CreatedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

**第 2 步：编写 Frame 单元（.pas）**

新建 `src/Modules/Product/ProductListFrame.pas`。继承 `TAutoCrudFrame`，搜索框/网格/数据源已内置，只需声明字段配置：

```pascal
unit ProductListFrame;

interface

uses
  System.SysUtils, System.Classes,
  Data.DB, FireDAC.Comp.Client,
  uniGUIBaseClasses, uniGUIClasses, uniEdit, uniButton,
  uniBasicGrid, uniDBGrid, uniPanel, uniGUIFrame,
  BaseCrudFrame, UniModelAdmin.Intf;

type
  TProductListFrame = class(TAutoCrudFrame)
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  UniModelAdmin;

{$R *.dfm}

constructor TProductListFrame.Create(AOwner: TComponent);
begin
  inherited;
  BindAdmin('product');   // 一行绑定：读注册中心声明，开启网格/查询/权限派生
end;

initialization
  // 声明：菜单/权限由 DatabaseInitializer.SeedFromRegistry 幂等写入 DB
  TModelAdminRegistry.CreateInstance.Register(
    TModelAdmin.Create('product', 'Products', '商品管理')
      .WithFrame('TProductListFrame')
      .WithListDisplay([
        TAdminFieldConfig.Create('ProductID', 'ID', 50),
        TAdminFieldConfig.Create('Name', '商品名', 150),
        TAdminFieldConfig.Create('SKU', 'SKU', 100),
        TAdminFieldConfig.Create('Price', '价格', 80),
        TAdminFieldConfig.Create('Status', '状态', 60)
      ])
      .WithSearchFields(['Name', 'SKU'])
      .WithFilterFields(['Status'])
      .WithPermissionPrefix('product')
      .WithSortOrder(200)
      .WithParentMenuCode('system')
  );

  RegisterClass(TProductListFrame);   // MdiRouter 路由必需

end.
```

**第 3 步：编写 Frame DFM（.dfm）**

新建 `src/Modules/Product/ProductListFrame.dfm`。继承内置工具栏与网格，中文用 `#编码` 转义、不加引号（见 AGENTS.md 规则 9/10）：

```dfm
inherited ProductListFrame: TProductListFrame
  Width = 800
  Height = 600
end
```

> `TAutoCrudFrame` 的工具栏、搜索框、网格、数据源都在基类 DFM 里，子类通常无需新增控件。

**第 4 步：加入项目（dpr）**

在 `src/UniAdmin.dpr` 的 `uses` 子句追加一行：

```pascal
  ProductListFrame in 'Modules\Product\ProductListFrame.pas' {ProductListFrame: TUniFrame};
```

**第 5 步：构建并运行**

```bash
.vscode/CompileOmniPascalServerProject.bat test
```

启动后用 `admin` / `admin123` 登录。**"商品管理"菜单自动出现**，点击即路由到 Frame：

| 自动产出 | 来源 |
|---------|------|
| 菜单项"商品管理" | `SeedFromRegistry` 写入 `UniAdmin_Menus`（`MenuCode='system:product'`） |
| `product:view/add/edit/delete` 权限 | 写入 `UniAdmin_Permissions`，admin 角色自动获得 |
| 网格列（ID/商品名/SKU/价格/状态） | `ListDisplay` 声明（MSSQL 下也可走元数据派生） |
| 搜索框 LIKE 查询 | `SearchFields` 声明 → `TQueryClauseBuilder` |
| 增删改按钮可见性 | `PermissionPrefix='product'` → 按角色权限过滤 |

> 💡 **SQLite 开发环境提示**：若用 SQLite 且未声明 `ListDisplay`，网格列会派生失败（SQLite 不支持 `INFORMATION_SCHEMA`，`BuildGridFromMetadata` 静默降级为空网格）。声明 `ListDisplay` 可绕过此限制。生产用 MSSQL 则无此问题。

### 进阶：自定义查询逻辑

继承 `TBaseCrudFrame`（而非 `TAutoCrudFrame`）可获得完全控制权，仍享受元数据派生网格列 + 权限挂钩：

```pascal
procedure TProductListFrame.DoInitialize;
begin
  AutoGridFromMeta := True;      // 从 Products 元数据自动建列
  ModelTableName := 'Products';
  inherited;                      // 触发 BuildGridFromMetadata
  UniDataSource.DataSet := FQuery;
end;
```

> 📐 设计理念：Django 的 `admin.site.register(Model, ModelAdmin)` 单一真值源——本项目用 `TModelAdminRegistry` 实现同样的声明即配置，菜单/权限/查询从声明派生而非各自硬编码。
> 完整设计与 TDD 落地步骤详见 [声明式 Admin 引擎实现计划](docs/superpowers/plans/2026-06-27-declarative-admin-engine.md)。

## 数据库

数据库 Schema 位于 `Database/` 目录：

```
Database/
├── Schema/
│   ├── 01_CreatePluginTables.sql   插件管理表
│   ├── 02_CreateCoreTables.sql     核心表（用户、角色、权限、菜单）
│   └── 03_CreateSystemTables.sql   系统表（字典、配置、日志、任务）
└── Seed/
    ├── 01_InitialPluginData.sql    初始插件数据
    ├── 02_InitialCoreData.sql      初始核心数据
    └── 03_SystemPermissions.sql    系统权限数据
```

## 测试

```bash
cd tests && UniAdminTests.exe
```

当前测试覆盖：插件系统、配置服务、字典服务、**声明式引擎（ModelAdmin 注册中心、查询生成器注入防护）**。

## 文档

- [开发指南](docs/DevelopmentGuide.md) ｜ [中文版](docs/01-开发指南.md)
- [架构设计](docs/uniadmin-framework-design.md) ｜ [中文版](docs/02-架构设计.md)
- [CRUD 框架](docs/TBaseCrudFrame-Architecture-Guide.md) ｜ [中文版](docs/03-CRUD框架.md)
- [API 文档](docs/API.md) ｜ [中文版](docs/04-API文档.md)
- [部署指南](docs/DEPLOYMENT.md) ｜ [中文版](docs/05-部署指南.md)
- [安全指南](docs/Security.md) ｜ [中文版](docs/06-安全指南.md)
- [MDI 架构设计](docs/plans/2026-06-26-mdi-architecture-design.md) — 数据驱动路由与多标签缓存方案
- [声明式 Admin 引擎实现计划](docs/superpowers/plans/2026-06-27-declarative-admin-engine.md) — Django Admin 风格声明式 CRUD 的 TDD 落地全过程
- [UniFalcon 接入评估](docs/plans/2026-06-26-unifalcon-integration-assessment.md) — 30 控件 + 11 主题，UI 质感升级方案

扩展资料：[UniGUI 组件参考手册](component-reference-manual.md)、[开发者手册](developer-manual.md)

## 贡献

欢迎提交 Issue 和 Pull Request！提 PR 前请先阅读 [贡献指南](docs/CONTRIBUTING.md)。

如果这个项目对你有帮助，欢迎 ⭐ Star 支持一下！

## 许可证

本项目基于 [MIT License](LICENSE) 开源。

Copyright © 2026 jianfeihua

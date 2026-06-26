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
- **零代码 CRUD** — 通过 TUniAdminModel 组件声明式配置，运行时自动生成列表和表单
- **元数据驱动** — 自动发现数据库 Schema，配置驱动 UI 生成
- **RBAC 权限** — 用户-角色-权限三级模型，支持数据范围控制
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
│   └── UI/            UI 框架（BaseCrudFrame、MainFrame、MdiRouter、模板）
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

当前测试覆盖：插件系统、配置服务、字典服务。

## 文档

- [开发指南](docs/DevelopmentGuide.md) ｜ [中文版](docs/01-开发指南.md)
- [架构设计](docs/uniadmin-framework-design.md) ｜ [中文版](docs/02-架构设计.md)
- [CRUD 框架](docs/TBaseCrudFrame-Architecture-Guide.md) ｜ [中文版](docs/03-CRUD框架.md)
- [API 文档](docs/API.md) ｜ [中文版](docs/04-API文档.md)
- [部署指南](docs/DEPLOYMENT.md) ｜ [中文版](docs/05-部署指南.md)
- [安全指南](docs/Security.md) ｜ [中文版](docs/06-安全指南.md)
- [MDI 架构设计](docs/plans/2026-06-26-mdi-architecture-design.md) — 数据驱动路由与多标签缓存方案
- [UniFalcon 接入评估](docs/plans/2026-06-26-unifalcon-integration-assessment.md) — 30 控件 + 11 主题，UI 质感升级方案

扩展资料：[UniGUI 组件参考手册](component-reference-manual.md)、[开发者手册](developer-manual.md)

## 贡献

欢迎提交 Issue 和 Pull Request！提 PR 前请先阅读 [贡献指南](docs/CONTRIBUTING.md)。

如果这个项目对你有帮助，欢迎 ⭐ Star 支持一下！

## 许可证

本项目基于 [MIT License](LICENSE) 开源。

Copyright © 2026 jianfeihua

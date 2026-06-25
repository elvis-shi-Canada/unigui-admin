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
│   └── UI/            UI 框架（BaseCrudFrame、模板）
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

扩展资料：[UniGUI 组件参考手册](component-reference-manual.md)、[开发者手册](developer-manual.md)

## 贡献

欢迎提交 Issue 和 Pull Request！提 PR 前请先阅读 [贡献指南](docs/CONTRIBUTING.md)。

如果这个项目对你有帮助，欢迎 ⭐ Star 支持一下！

## 许可证

本项目基于 [MIT License](LICENSE) 开源。

Copyright © 2026 jianfeihua

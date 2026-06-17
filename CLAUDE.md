# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

UniAdmin 是基于 Delphi 12 Athens + UniGUI 的零代码后台管理框架，借鉴 Django Admin 设计理念：
- **插件化核心** - 支持动态扩展业务模块
- **设计时配置** - 通过 TUniModelAdmin 组件声明式配置
- **运行时驱动** - 配置驱动 CRUD 逻辑，无需编写重复代码

## 构建与运行

```bash
# 编译项目（VS Code 任务）
Ctrl+Shift+B → 选择 "build"

# 或直接运行脚本
.vscode/CompileOmniPascalServerProject.bat build

# 编译并运行
.vscode/CompileOmniPascalServerProject.bat test

# 运行单元测试
cd tests && UniAdminTests.exe
```

**项目入口**: `src/UniAdmin.dproj`
**输出目录**: `bin/`

## 架构概览

```
┌─────────────────────────────────────────────────────────────┐
│  配置声明层 (设计时): TUniModelAdmin 组件                    │
│  ListDisplay | ListFilter | FieldSets | FieldControls       │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  运行时引擎层: TBaseCrudFrame 基类                           │
│  Initialize | BuildGrid | BuildForm | ExecuteCRUD           │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  元数据定义层 (数据库)                                       │
│  UniAdmin_Tables | UniAdmin_Fields | UniAdmin_Menus         │
└─────────────────────────────────────────────────────────────┘
```

**技术栈**: Delphi 12 Athens | UniGUI | FireDAC | SQL Server | DUnitX

**目录结构**:
- `src/Core/` - 核心框架（Context, Plugin, Data, Metadata, Auth, Menu, Permission, Services, UI）
- `src/Modules/` - 业务模块（User, Role, Menu, Dictionary, Config, Log, Scheduler）
- `src/Plugins/` - 插件扩展
- `tests/` - 单元测试

## 关键开发规范

> ⚠️ **重要**: 以下规则从历史编译错误中总结，违反会导致编译失败。完整规则见 MEMORY.md。

### Delphi 窗体文件结构

每个 Delphi 窗体**必须**包含两个同名文件：
- `.pas` - 窗体代码（逻辑和事件处理器）
- `.dfm` - 窗体设计（可视化布局）
- 两个文件**必须**在同一目录

**只有 TForm/TFrame/TDataModule 及其子类才能拥有独立的 .dfm 文件**
- ✓ `TUniForm`, `TUniFrame`, `TUniDataModule` - 可有 .dfm
- ✗ `TUniPanel`, `TUniButton` 等控件类 - 不可有 .dfm

### DFM 文件中文字符转义

```dfm
// 纯中文：无引号
Caption = #29992#25143#30331#24405

// 中文+标点：标点用单引号
Caption = #20851#38190#35789':'

// 中文+英文：英文部分用单引号
Caption = #26159'(&Y)'

// 纯英文：单引号
Caption = 'OK'

// ❌ 错误格式
Caption = '#29992#25143'    // 纯中文不需要外层引号
Caption = #20851#38190#35789:  // 标点必须用引号
```

### 常见编译错误预防

| 错误 | 原因 | 解决方案 |
|------|------|----------|
| E2003 Undeclared identifier | 缺少 uses 引用 | 搜索类型定义位置，添加 uses |
| E2003 'Dispose' | 类实例用 Dispose | 类实例用 `.Free`，Dispose 仅用于 New 分配的指针 |
| E2035 Not enough parameters | 参数数量不匹配 | 检查方法声明，确保参数匹配 |
| Record 字段错误 | 假设字段名 | 使用前查看实际 record 定义 |

### 泛型集合操作 (TList\<T\>)

```pascal
// ❌ 错误：索引访问返回只读副本
FTasks[I].Field := Value;

// ✓ 正确：先取出，修改，再赋回
LItem := FTasks[I];
LItem.Field := Value;
FTasks[I] := LItem;

// ❌ 错误：for-in 循环变量只读
for LItem in FTasks do
  LItem.Field := Value;

// ✓ 正确：使用索引循环
for I := 0 to FTasks.Count - 1 do
begin
  LItem := FTasks[I];
  LItem.Field := Value;
  FTasks[I] := LItem;
end;
```

### 单元引用速查

| 单元 | 用途 |
|------|------|
| `System.Math` | `IfThen()` 整数版本 |
| `System.StrUtils` | `IfThen()` 字符串版本 |
| `System.DateUtils` | `DateOf`, `MilliSecondsBetween`, `EncodeTime` |
| `System.UITypes` | `mrOK`, `mrCancel`, `caFree` |
| `System.Generics.Collections` | `TPair<>`, `TDictionary<>` |
| `FireDAC.Comp.Client` | `TFDQuery`, `TFDConnection` |
| `FireDAC.Stan.Param` | 消除 TFDParam 内联函数警告 |

### UniGUI 特定规范

- **事件签名**：必须包含 `Sender: TObject` 参数
- **定时器**：使用 `TUniTimer` 而非 VCL 的 `TTimer`
- **窗体释放**：不需要 `Action := caFree`，框架自动管理
- **消息提示**：使用 `ShowMessage()`，非 `UniGUIApplication.ShowMessage()`

## 核心开发模式

### CRUD 模块开发

```pascal
// 继承基类
TMyListFrame = class(TBaseCrudFrame)
protected
  procedure DoInitialize; override;  // 初始化网格列
  procedure DoRefresh; override;     // 加载数据
end;

// 配置 ModelAdmin
ModelAdmin.TableName := 'MyTable';
ModelAdmin.PrimaryKey := 'ID';
ModelAdmin.ListDisplay.Add('FieldName');
```

### 插件开发

```pascal
type
  TMyPlugin = class(TPlugin, IPlugin)
  protected
    procedure DoInitialize; override;
    procedure DoActivate; override;
  end;

// 注册插件
TUniModuleRegistry.GetInstance.RegisterPluginClass(
  TMyPlugin, 'my-plugin', LPluginInfo);
```

### 服务层模式

```pascal
// 定义接口 (.Intf.pas 文件)
IMyService = interface(IInterface)
  ['{GUID}']
  function GetData(const ID: Integer): TData;
end;

// 实现服务
TMyService = class(TInterfacedObject, IMyService)
public
  function GetData(const ID: Integer): TData;
end;

// 注册到服务定位器
TUniServices.RegisterService<IMyService>(TMyService);
```

## 常见开发任务

### 添加新模块
1. 在 `src/Modules/` 创建目录
2. 创建 DataModule (数据访问)
3. 创建 Service (业务逻辑)
4. 创建 Frame (UI 界面)
5. 在 `UniAdmin.dpr` 中注册

### 添加新插件
1. 在 `src/Plugins/` 创建目录
2. 实现 `IPlugin` 接口
3. 创建插件配置文件
4. 在 `UniModuleRegistration.pas` 中注册

## 参考资源

- [TBaseCrudFrame 架构指南](./docs/TBaseCrudFrame-Architecture-Guide.md)
- [Delphi DFM/PAS 文件规范](./docs/Delphi-DFM-PAS-File-Standards.md)
- [UniGUI 官方文档](http://www.unigui.com/doc/)
- **案例库**: `D:\BaiduNetdiskDownload\vcl\UniGUI_1600\uniGUI\Demos`

## 记忆管理

本项目使用 MEMORY.md 管理项目记忆：
- **位置**: `.claude/projects/.../memory/MEMORY.md`
- **更新**: 使用 `Write` 或 `Edit` 工具直接更新
- **禁止**: 禁止使用 Serena MCP 记忆工具

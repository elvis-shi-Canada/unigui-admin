# Delphi + UniGUI Admin Project

## Project Overview

This is a Delphi + UniGUI web administration panel project. UniGUI extends Delphi VCL to create web applications using the component-based development model.

## Build/Compile Commands

### Build Project
```bash
# Using VS Code task (recommended)
# Press Ctrl+Shift+B -> Select "build"

# Or run directly
.vscode/CompileOmniPascalServerProject.bat build
```

### Build and Test (Run Application)
```bash
# Using VS Code task
# Run task "test"

# Or run directly
.vscode/CompileOmniPascalServerProject.bat test
```

### Clean Build Artifacts
```bash
./clean.bat
```

### Build System Details
- Uses MSBuild from Visual Studio 2022 BuildTools
- Delphi compiler: Embarcadero RAD Studio 12 (version 23.0)
- Project file: `Project/UniguiAdmin.dproj`
- Output directory: `bin/`

## Project Structure

```
unigui-admin/
├── .vscode/                    # VS Code configuration
│   ├── CompileOmniPascalServerProject.bat  # Build script
│   ├── tasks.json              # VS Code tasks
│   └── settings.json           # LSP settings
├── Project/                    # Delphi project files
│   ├── UniguiAdmin.dproj       # Main project file
│   └── UniguiAdmin.delphilsp.json  # LSP configuration
├── bin/                        # Compiled output
├── src/                        # Source units (if organized)
└── AGENTS.md
```

## Code Style Guidelines

### File Structure - Delphi Forms

**CRITICAL**: Every Delphi form consists of TWO files:
1. `.dfm` - Form design (visual layout)
2. `.pas` - Form code (logic and event handlers)

### Chinese Character Handling

**CRITICAL RULES for encoding**:
- `.dfm` files: Always escape Chinese characters using `char(10)` encoding
- `.pas` files: Always preserve GBK-encoded Chinese characters intact
- Never convert pas files to UTF-8 if they contain Chinese - this will corrupt the encoding

### Naming Conventions

```pascal
// Unit names: PascalCase, descriptive
unit MainForm;      // Good
unit main_form;     // Bad - no underscores
unit main;          // Bad - too vague

// Form/Class names: T prefix + PascalCase
TMainForm = class(TUniForm)       // Good
TUserListFrame = class(TUniFrame) // Good

// Component names: Prefix based on type
btnSave: TUniButton;      // btn prefix for buttons
edtUsername: TUniEdit;    // edt prefix for edits
lblTitle: TUniLabel;      // lbl prefix for labels
grdUsers: TUniDBGrid;     // grd prefix for grids
dsUsers: TDataSource;     // ds prefix for datasources
qryUsers: TADOQuery;      // qry prefix for queries
cboStatus: TUniComboBox;  // cbo prefix for comboboxes

// Private fields: F prefix
FCurrentUser: TUser;
FConnection: TADOConnection;

// Local variables: No prefix, descriptive
UserList: TList;
RowIndex: Integer;

// Constants: ALL_CAPS with underscores
const
  MAX_RETRY_COUNT = 3;
  DEFAULT_TIMEOUT = 30000;
```

### Code Organization

```pascal
unit UnitName;

interface

uses
  // System units first
  System.SysUtils, System.Classes,
  // VCL/UniGUI units second
  Vcl.Controls, Vcl.Forms,
  UniGUIBaseClasses, UniGUIClasses, UniForm,
  // Project units last
  DataAccess, UserModule;

type
  TMyForm = class(TUniForm)
    // Components declared here
    btnSave: TUniButton;
    procedure btnSaveClick(Sender: TObject);
  private
    { Private declarations }
    FData: TObject;
    procedure LoadData;
  public
    { Public declarations }
    class procedure ShowForm(AParent: TComponent);
  end;

implementation

{$R *.dfm}

// Implementation follows declaration order

end.
```

### Error Handling

```pascal
// Always use try-finally for resource management
Query := TADOQuery.Create(nil);
try
  Query.Connection := FConnection;
  Query.SQL.Text := 'SELECT * FROM Users';
  Query.Open;
  // Process data
finally
  Query.Free;
end;

// Use try-except for expected error conditions
try
  DoSomethingRisky;
except
  on E: Exception do
  begin
    ShowMessage('Error: ' + E.Message);
    LogError(E);
  end;
end;
```

### High Cohesion, Low Coupling

- Keep form logic in form units
- Create separate DataModule units for database access
- Use interfaces for cross-module communication
- **AVOID global variables** - use DataModules or dependency injection

## Architecture Guidelines

### UniGUI-Specific Patterns

```pascal
// Form creation pattern - use class methods
class procedure TUserForm.ShowForm(AParent: TComponent);
var
  Form: TUserForm;
begin
  Form := TUserForm.Create(AParent);
  try
    Form.ShowModal;
  finally
    // UniGUI handles cleanup automatically in most cases
  end;
end;

// Session-aware code
procedure TMainForm.UniFormCreate(Sender: TObject);
begin
  // Access session data
  Caption := UniApplication.ServerModule.Title;
end;
```

### Database Access

- Use ADO components (TADOConnection, TADOQuery, TADOCommand)
- Centralize connection in a DataModule
- Use parameterized queries to prevent SQL injection

```pascal
// Good - parameterized
Query.SQL.Text := 'SELECT * FROM Users WHERE Status = :Status';
Query.Parameters.ParamByName('Status').Value := Status;

// Bad - string concatenation (SQL injection risk)
Query.SQL.Text := 'SELECT * FROM Users WHERE Status = ' + IntToStr(Status);
```

## Important Constraints

1. **No compatibility code** - Focus on current environment and requirements only
2. **No global variables** - Use proper dependency injection or DataModules
3. **Always preserve GBK encoding** in .pas files with Chinese content
4. **Always escape Chinese** in .dfm files using `char(10)` format

## Development Tools

- **IDE**: Embarcadero RAD Studio 12
- **Editor**: VS Code with DelphiLSP extension
- **Build**: MSBuild via CompileOmniPascalServerProject.bat
- **Documentation**: Use Context7 for latest Delphi/UniGUI documentation

## Common Tasks

### Adding a New Form
1. Create .pas file with form class declaration
2. Create corresponding .dfm file (can be auto-generated by IDE)
3. Add form to project .dproj file
4. Register form in MainModule if needed

### Adding Database Access
1. Add TADOConnection to a DataModule
2. Create query components as needed
3. Use parameterized queries always
4. Handle connection errors gracefully

## 开发工具使用指南

### Serena MCP 语义代码分析

**优先使用 Serena MCP** 替代常规代码搜索和编辑，特别是在符号导航和精确代码操作时。

**何时使用 Serena：**
- 符号导航（查找定义、引用、实现）
- 结构化代码库中的精确代码操作
- 优先使用符号级操作，而非基于文件的 grep/sed

**关键工具：**
| 工具 | 用途 |
|------|------|
| `find_symbol` | 跨代码库按名称查找符号 |
| `find_referencing_symbols` | 查找引用给定符号的所有符号 |
| `get_symbols_overview` | 获取文件的顶层符号概览 |
| `read_file` | 读取项目目录内的文件内容 |

**使用建议：**
- 理解代码结构时，先用 `get_symbols_overview`
- 查找类型/方法定义时，用 `find_symbol`
- 查找所有调用点时，用 `find_referencing_symbols`
- 避免简单的文本 grep，优先使用语义分析
- 记忆文件可在 `.serena/memories/` 中查看/编辑

## Demo References (案例库参考)

项目可参考以下 UniGUI 案例库（详细分类见 `.serena/memories/unigui-demos-catalog.md`）：

### UniGUI 官方 Demos
- **路径**: `D:\BaiduNetdiskDownload\vcl\UniGUI_1600\uniGUI\Demos`
- **Desktop**: ~250个桌面端案例
- **Touch**: ~60个移动端案例

### UniFalcon 扩展控件
- **路径**: `D:\BaiduNetdiskDownload\vcl\UniFalcon\Demos`
- **控件数**: ~40个扩展控件（含移动版）

### 常用场景映射
| 场景 | 推荐案例路径 |
|------|-------------|
| 后台管理系统 | `Desktop/MegaDemo`, `Desktop/AllFeaturesDemo` |
| 登录认证 | `Desktop/LoginForm`, `Desktop/HTTP Basic Authentication` |
| 数据表格 | `Desktop/Grid*`, `Desktop/HyperGrid*` |
| 图表报表 | `Desktop/ChartDemo*`, `Desktop/FastReport*` |
| 文件上传 | `Desktop/FileUpload*` |
| 移动端 | `Touch/` 目录 |
| 扩展控件 | `UniFalcon/Demos/FS*` |

## 记忆进化记录

### 5️⃣ 类型未声明错误修复规则（预防：E2003 Undeclared identifier）

**触发场景**
- 在新单元中使用已存在的类型
- 复制粘贴代码到不同单元
- 重构代码后类型位置发生变化
- 测试代码引用核心模块的类型

**错误模式**
```
[dcc32 Error] UniPluginTest.pas(108): E2003 Undeclared identifier: 'TSessionInfo'
[dcc32 Error] UniPluginTest.pas(125): E2003 Undeclared identifier: 'TUserContextImpl'
```
根本原因是测试单元 uses 部分缺少 `UniSession` 引用。

**正确行为**
1. 遇到 E2003 错误时，首先使用 search_content 查找类型的定义位置
2. 确认类型所在单元后，在 uses 部分添加引用
3. 不要假设类型位置，必须通过搜索验证
4. 记录类型-单元映射关系便于后续查阅

**验证方法**
- 搜索类型定义：`search_content --pattern "TTypeName\s*="`
- 确认所在单元后添加 uses 引用
- 重新编译验证错误是否解决

### 6️⃣ 记录字段名不匹配规则（预防：E2003 Undeclared identifier）

**触发场景**
- 使用 record 类型时假设字段名
- 代码复制后未对照实际声明修改
- 重构后字段名变更未同步所有使用处

**错误模式**
```pascal
LInfo.Name := 'TestPlugin'; // 编译错误：Undeclared identifier 'Name'
// TPluginClassInfo 实际字段是 PluginID，不是 Name
```

**正确行为**
1. 使用 record 前，先用 search_content 或 read_file 查看实际字段定义
2. 对照 interface 部分的 record 声明编写代码
3. 不要根据其他类似类型推断字段名
4. 特别注意 `TPluginClassInfo` vs `TPluginInfo` 的区别：
   - TPluginClassInfo: PluginID, ClassName, PluginClass...
   - TPluginInfo: Name, DisplayName, Version...

**验证方法**
- 搜索 record 定义查看字段
- 对照实际声明编写赋值代码
- 编译验证字段名正确性

### 7️⃣ Dispose 误用规则（预防：E2003 Undeclared identifier: 'Dispose'）

**触发场景**
- 从 C# 等语言切换到 Delphi 开发
- 混淆了 Dispose 和 Free 的用法
- 使用类实例时错误调用 Dispose

**错误模式**
```pascal
FDataScopes.Dispose;  // 错误！E2003 Undeclared identifier: 'Dispose'
FLock.Dispose;        // 错误！
```

**正确行为**
1. Delphi 中 TObject 派生类使用 `Free` 释放：
   ```pascal
   FDataScopes.Free;
   FLock.Free;
   ```
2. `Dispose` 只用于配合 `New` 分配的指针：
   ```pascal
   var P: PInteger;
   New(P);
   Dispose(P);  // 正确用法
   ```
3. 类实例永远不要使用 `Dispose`
4. 从其他语言迁移代码时，将 `.Dispose()` 替换为 `.Free`

**验证方法**
- 编译前检查所有类实例的释放语句
- 确保使用 `.Free` 而非 `.Dispose`
- 预期输出：无 E2003 编译错误

### 8️⃣ 方法参数数量不匹配规则（预防：E2035 Not enough actual parameters / E2034 Too many actual parameters）

**触发场景**
- 修改了方法签名后未同步所有调用点
- 假设了方法的参数数量，未对照实际声明
- 重构时从字段改为方法调用
- 接口定义变更后调用方未更新

**错误模式**
```pascal
// 方法声明（3个参数）
procedure AddDependency(const FromPluginID, ToPluginID, MinVersion: string);

// 错误调用（只传2个参数）
FRegistry.AddDependency('plugin-a', 'plugin-c');  // E2035 Not enough actual parameters

// 正确调用（传3个参数）
FRegistry.AddDependency('plugin-a', 'plugin-c', '');
```

**正确行为**
1. 编写方法调用前，先用 `search_content` 或 `find_symbol` 查看方法声明
2. 对照 interface 部分的方法签名编写调用代码
3. 修改方法签名后，立即搜索所有调用点并同步更新
4. 对于可选参数，使用默认值显式传递

**验证方法**
- 搜索方法声明确认参数数量和类型
- 编译前检查所有调用点的参数匹配
- 预期输出：无 E2035 / E2034 编译错误

### 9️⃣ Delphi .dfm文件中文字符转义规范（预防：格式错误）

**触发场景**
- 处理Delphi .dfm文件中的中文字符
- 需要将中文转换为`#编码`格式
- 涉及字符串属性的引号处理

**错误模式**
> 错误示例：`'#29992#25143'` 或 `"#29992#25143"`（转义后仍保留引号）
> 错误示例：`'UniAdmin #31649#29702'`（混合内容引号未去除）

**正确行为**
1. **转义中文字符**：将中文字符转换为`#编码`格式，例如`用户名` → `#29992#25143#21517`
2. **去除引号**：转义后的`#编码`格式不需要引号包裹
   - 纯编码：`'#29992#25143'` → `#29992#25143`
   - 混合内容：`'UniAdmin #31649#29702'` → `UniAdmin #31649#29702`
3. **保留必要引号**：仅保留包含未转义中文的字符串引号
4. **多步骤处理**：按优先级处理不同场景
   - 步骤1：纯`#编码`的单引号包裹
   - 步骤2：纯`#编码`的双引号包裹
   - 步骤3：混合内容的引号包裹
   - 步骤4：清理残留引号

**验证方法**
- 检查.dfm文件中`#编码`格式是否无引号包裹
- 验证混合内容（英文+#编码）的引号已去除
- 确认纯ASCII字符串的引号保持不变
- 使用Delphi编译器验证文件格式正确性

**正则表达式参考**
```python
# 纯#编码单引号
r"'((?:#[0-9]+)+)'"

# 纯#编码双引号
r'"((?:#[0-9]+)+)"'

# 混合内容（包含#编码）
r"'([^']*(?:#[0-9]+)+[^']*)'"
r'"([^"]*(?:#[0-9]+)+[^"]*)"'
```

### 🔟 Delphi窗体文件结构规范（预防：文件缺失或位置错误）

**触发场景**
- 创建新的Delphi窗体或框架
- 移动或重命名窗体文件
- 检查编译错误时排查文件结构
- 从其他项目复制窗体代码

**错误模式**
> 错误示例1：只创建.pas文件，忘记创建对应的.dfm文件
> 错误示例2：将.pas和.dfm文件放在不同目录中
> 错误示例3：.dfm文件中文字符转义后仍保留引号，如`'#29992#25143'`

**正确行为**
1. **双文件结构**：每个Delphi窗体必须包含两个同名文件
   - `.pas` - 窗体代码（逻辑和事件处理器）
   - `.dfm` - 窗体设计（可视化布局）
   - 例如：`LoginForm.pas` 和 `LoginForm.dfm`

2. **目录位置要求**：.pas和.dfm文件必须在同一目录中
   - 不能将文件分散到不同文件夹
   - 移动文件时必须同时移动两个文件
   - 重命名时必须同时重命名两个文件

3. **中文字符转义**：.dfm文件中的中文必须转换为`#编码`格式
   - 转义格式：`用户名` → `#29992#25143#21517`
   - **关键规则**：转义后的`#编码`不需要引号包裹
   - 正确：`Caption = #29992#25143#21517`
   - 错误：`Caption = '#29992#25143#21517'` 或 `Caption = "#29992#25143#21517"`

4. **文件配对检查**：创建或修改窗体时验证文件完整性
   - 检查是否存在对应的.dfm文件
   - 检查.dfm文件中的中文是否正确转义
   - 确认两个文件在同一目录

**验证方法**
- 使用文件管理器检查窗体目录，确认每个.pas文件都有对应的.dfm文件
- 打开.dfm文件，检查中文字符是否为`#编码`格式且无引号包裹
- 使用Delphi编译器编译项目，确认无文件缺失错误
- 预期输出：窗体正常编译，中文显示正确

**快速检查清单**
```
□ .pas文件存在
□ .dfm文件存在
□ 两个文件在同一目录
□ .dfm中中文已转义为#编码
□ #编码格式无引号包裹
```


### 1️⃣1️⃣ UniGUI 启动入口规范（预防：进程启动后立即退出 ExitCode 0）

**触发场景**
- UniGUI standalone exe 编译通过但运行无反应
- 修改 dpr 主块后
- 新建 UniGUI 项目
- 怀疑服务器未启动

**错误模式**
```pascal
// 错误：dpr 主块为空或缺少关键调用
begin
  SetConsoleOutputCP(CP_UTF8);
  // 注释错误地声称"不需要 Application.Run"
end.
```
进程退出码 0，无错误信息，无监听端口。

根本原因：UniGUI **不存在**"首次请求自动初始化"机制。CLAUDE.md/文档中出现的 `Application.ServerModuleClass` / `MainModuleClass` / `LoginFormClass` 属性在 UniGUI 1.6 中**不存在**，是虚构 API。

**正确行为**
dpr 必须显式三步启动，且 uses 必须含 `Forms`：
```pascal
uses
  Forms,  // 关键：VCL.Forms 提供 Application 全局变量
  uniGUIApplication,
  ServerModule in 'Core\Main\ServerModule.pas',
  ...

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  TServerModule.Create(Application);  // 创建 ServerModule 实例
  Application.Run;                    // 启动消息循环
end.
```
ServerModule.pas 必须有 initialization 段注册类：
```pascal
uses ..., UniGUIVars;

initialization
  RegisterServerModuleClass(TServerModule);
```
参考：官方 demo `D:\BaiduNetdiskDownload\vcl\UniGUI_1600\uniGUI\Demos\Desktop\AllFeaturesDemo\mdemo.dpr`

**验证方法**
- 运行 exe，5 秒后检查进程是否存活（不应退出）
- `Get-NetTCPConnection -OwningProcess <pid> -State Listen` 应显示配置端口（默认 8077）
- `Invoke-WebRequest http://localhost:8077/` 应返回 200

---

### 1️⃣2️⃣ DFM 事件方法可见性规范（预防：Error reading ... Invalid property value）

**触发场景**
- DFM 中绑定 OnCreate/OnDestroy/OnClick 等事件
- 新建 Form/Module/Frame 并添加事件处理方法
- 代码重组后移动了方法声明位置

**错误模式**
```pascal
TServerModule = class(TUniGUIServerModule)
private
  ...
protected
  procedure OnCreate(Sender: TObject);   // 错！DFM 找不到
  procedure OnDestroy(Sender: TObject);
public
```
运行时错误：`Exception EReadError ... Error reading ServerModule.OnCreate: Invalid property value`

根本原因：DFM 流读取器通过 RTTI 查找方法，Delphi RTTI 默认只暴露 `published` 成员，`protected`/`private` 区的方法不可达。

**正确行为**
DFM 引用的事件处理方法必须放在默认 `published` 区（紧接 `class(...)` 后，`private` 前）：
```pascal
TServerModule = class(TUniGUIServerModule)
  procedure OnCreate(Sender: TObject);    // 默认 = published
  procedure OnDestroy(Sender: TObject);
private
  FConfigService: IUniConfigService;
  ...
protected
  // 仅放非事件处理方法
public
  ...
```

**验证方法**
- 编译后运行 exe，若无 EReadError 即正确
- 对照官方 demo：类声明开头无可见性修饰符的方法即为 published
- 规则：凡 DFM 中 `OnXxx = MethodName` 引用的方法，必须在 published 区

---

### 1️⃣3️⃣ bat/cmd 文件纯 ASCII 规范（预防：编码错误导致命令解析失败）

**触发场景**
- 在 .bat/.cmd 文件中添加中文注释
- 用 UTF-8 编码的工具（write/编辑器）写入 bat 文件
- bat 文件迁移自其他系统

**错误模式**
```bat
REM 项目根目录（基于本 bat 文件位置，避免硬编码绝对路径）
SET ROOT=%~dp0..
```
错误：`'文件位置，避免硬编码绝对路径)SET' 不是内部或外部命令`

根本原因：
- write 工具默认 UTF-8 编码
- Windows cmd 以系统 ANSI 编码（中文 Windows = GBK/CP936）解析 bat
- UTF-8 中文字节被 GBK 错切，破坏换行符识别
- REM 行尾的中文与下一行命令合并，被当作无效命令

**正确行为**
- `.bat`/`.cmd` 文件**必须纯 ASCII**，禁止中文注释
- 中文说明改英文，或完全删除注释
- 项目编码规范补充：.pas 用 GBK，.dfm 用 `#编码` 转义，**.bat/.cmd 用纯 ASCII**

**验证方法**
- `Get-Content <file>.bat` 应无乱码
- 双击或 cmd 调用 bat，无"不是内部或外部命令"错误
- 检查：bat 文件中无任何非 ASCII 字符（`Format-Hex <file>.bat | Select-String -NotMatch "^[0-9a-fA-F\s]+" ` 应为空）

---

### 1️⃣4️⃣ uniGUIRegClasses 必须显式加入 dpr（预防：Class TServerControlPanelForm not found）

**触发场景**
- 访问 `/server` 监控页
- uniGUI Web Server Monitor 功能
- 任何 `FindClass('TServerControlPanelForm')` 调用路径

**错误模式**
```
Class TServerControlPanelForm not found : Addr: $00F926E2
```
根本原因：`uniGUIRegClasses.pas` 是独立单元，不被任何 uniGUI 单元间接引用。其 initialization 段调用 `RegisterClasses([..., TServerControlPanelForm, ...])`，不加入 dpr uses 则类不注册，`FindClass` 失败。

**正确行为**
dpr uses 子句必须显式包含 `uniGUIRegClasses`：
```pascal
uses
  Forms,
  UniGUIVars,
  uniGUIApplication,
  uniGUIClasses,
  uniGUIForm,
  uniGUIRegClasses,  // 注册 TServerControlPanelForm + TUniControlLogin 等
  ...
```

**验证方法**
- 编译后在 exe 中访问 `/server`，不再报 EClassNotFound
- 确认 dpr uses 含 `uniGUIRegClasses`

---

### 1️⃣5️⃣ DFM 事件属性必须显式绑定（预防：FormCreate 静默不执行）

**触发场景**
- 窗体有事件处理方法（FormCreate、FormShow 等）但运行时行为异常
- 初始化代码似乎从未执行（字段为 nil、属性未设置）
- 从其他项目复制窗体代码后功能缺失

**错误模式**
.pas 中声明了事件方法：
```pascal
TLoginForm = class(TUniLoginForm)
  procedure FormCreate(Sender: TObject);
  procedure FormShow(Sender: TObject);
```
.dfm 中**缺失**对应的 `OnCreate` / `OnShow` 属性：
```dfm
object LoginForm: TLoginForm
  Caption = #29992#25143#30331#24405
  OldCreateOrder = False
  MonitoredKeys.Keys = <>
  // ← 缺少 OnCreate = FormCreate 和 OnShow = FormShow！
```

后果：`FormCreate` **永远不会被调用**。初始化代码静默跳过，字段保持 nil，窗体大小/属性不生效。无编译错误，无运行时异常——极难发现。

**与规则 1️⃣2️⃣ 的区别**
- 1️⃣2️⃣ 解决的是方法可见性问题（protected vs published，RTTI 找不到方法）
- 本规则解决的是 DFM 中根本没有写 `OnCreate = FormCreate` 属性行

**正确行为**
每次创建/修改窗体后，必须验证 DFM 包含所有事件绑定：
```dfm
object MyForm: TMyForm
  OnCreate = FormCreate       ← 必须存在
  OnShow = FormShow           ← 必须存在
  OnClose = FormClose         ← 必须存在
  OnKeyPress = FormKeyPress   ← 必须存在
```

**验证方法**
```bash
# 检查 .pas 中声明的所有 procedure 是否在 .dfm 中有对应的 On 属性
grep "procedure.*Form" MyForm.pas    # 找到所有事件方法
grep "On.*=" MyForm.dfm              # 找到所有已绑定的事件
```
两者应一一对应。任何 .pas 中的事件方法在 .dfm 中找不到对应 `OnXxx = MethodName` 的，即为遗漏。

---


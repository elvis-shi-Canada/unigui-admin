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

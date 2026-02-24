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

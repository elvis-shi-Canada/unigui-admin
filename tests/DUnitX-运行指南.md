# DUnitX 测试运行指南

## 前置要求

- Delphi 10.1 Berlin 或更高版本 (推荐 Delphi 12)
- DUnitX 框架 (已包含在 Delphi IDE 中)

## 方法一: 在 Delphi IDE 中运行 (推荐)

### 步骤 1: 打开测试项目

1. 启动 Delphi IDE
2. 选择 `File → Open → Project...`
3. 导航到 `tests\UniAdminTests.dpr` 并打开

### 步骤 2: 配置项目搜索路径

1. 在 Project Manager 中右键点击 `UniAdminTests` 项目
2. 选择 `Options...`
3. 在左侧树中展开 `Building → Delphi Compiler`
4. 点击 `Search Path`
5. 添加以下路径到搜索路径 (每行一个):
   ```
   $(BDSCOMMONDIR)\DUnitX\src
   ..\src\Core\Plugin
   ..\src\Core\Context
   ..\src\Core\Module
   ..\src\Core\Main
   ..\src\Plugins\Dictionary
   ..\src\Frames
   ```
6. 点击 `OK` 保存

### 步骤 3: 运行测试

1. 按 `F9` 键或点击工具栏上的 `Run` 按钮
2. 控制台窗口将显示测试结果
3. 查看输出:
   - 绿色 `[PASS]` - 测试通过
   - 红色 `[FAIL]` - 测试失败
   - 黄色 `[ERROR]` - 测试错误

### 步骤 4: 查看详细结果

测试报告将保存到 `tests\TestResults.xml`，可以用以下工具查看:
- NUnit Test Result Viewer
- Visual Studio (如果安装)
- 或任何 XML 查看器

## 方法二: 使用命令行编译和运行

### 编译测试项目

```bash
dcc32 -U"$(BDSCOMMONDIR)\DUnitX\src;..\src\Core\Plugin;..\src\Core\Context" ^
      -E..\tests\bin ^
      -N0..\tests\dcu ^
      tests\UniAdminTests.dpr
```

### 运行测试可执行文件

```bash
cd tests\bin
UniAdminTests.exe
```

## 测试用例说明

### 当前测试套件 (UniPluginTest.pas)

| 测试名称 | 说明 |
|---------|------|
| `TestPluginRegistration` | 测试插件注册功能 |
| `TestPluginInitialization` | 测试插件初始化流程 |
| `TestPluginActivation` | 测试插件激活/停用 |
| `TestDependencyValidation` | 测试依赖验证 |
| `TestCircularDependencyDetection` | 测试循环依赖检测 |

### 预期测试结果

```
===== DUnitX Test Runner =====
Total tests run: 5
Passed: 5
Failed: 0
Errors: 0
Skipped: 0
Execution time: XXX ms
```

## 常见问题

### Q1: 编译错误 "Cannot find DUnitX.TestFramework"

**解决方案:**
- 确保已添加 `$(BDSCOMMONDIR)\DUnitX\src` 到搜索路径
- 检查 DUnitX 是否已安装 (通常在 `C:\Users\Public\Documents\Embarcadero\Studio\23.0\DUnitX`)

### Q2: "File not found: UniPlugin.pas"

**解决方案:**
- 确保所有源代码路径已添加到搜索路径
- 检查相对路径是否正确 (测试项目在 `tests/`，源代码在 `src/`)

### Q3: 测试运行但没有输出

**解决方案:**
- 检查是否是控制台应用类型 (`{$APPTYPE CONSOLE}` 已定义)
- 尝试从命令提示符运行生成的 .exe 文件

### Q4: 如何调试测试用例?

**解决方案:**
1. 在测试代码中设置断点
2. 按 `F5` 或点击 `Run → Step Over`
3. 可以检查变量值和调用堆栈

## 添加新测试用例

### 1. 创建测试单元

```delphi
unit MyNewTest;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TMyNewTest = class
  public
    [Test]
    procedure TestSomething;
  end;

implementation

procedure TMyNewTest.TestSomething;
begin
  // 测试代码
  Assert.WillRaise(
    procedure: begin raise Exception.Create('Test'); end,
    Exception
  );
end;

initialization
  TDUnitX.RegisterTestFixture(TMyNewTest);

end.
```

### 2. 注册到测试项目

在 `UniAdminTests.dpr` 的 `uses` 子句中添加:
```delphi
MyNewTest in 'Path\To\MyNewTest.pas',
```

## 测试覆盖率

要查看测试覆盖率，可以使用:
- Delphi 的内置覆盖率工具 (需要特定版本)
- AQTime (第三方工具)
- 或者简单的代码审查

## 持续集成

### 将测试集成到 CI/CD

```bash
# 示例批处理脚本
msbuild UniAdminTests.dproj /p:Config=Release
tests\bin\UniAdminTests.exe -exit
if %ERRORLEVEL% NEQ 0 exit 1
```

---

**文档版本:** 1.0
**创建日期:** 2026-02-24
**适用版本:** Delphi 12, DUnitX

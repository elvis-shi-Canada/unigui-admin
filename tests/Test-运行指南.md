# UniAdmin 测试运行指南

**文档版本**: 1.0
**更新日期**: 2026-02-25
**适用项目**: UniAdmin (Delphi + UniGUI)

---

## 目录

1. [快速开始](#快速开始)
2. [环境准备](#环境准备)
3. [运行测试](#运行测试)
4. [分析结果](#分析结果)
5. [常见问题](#常见问题)
6. [测试报告](#测试报告)

---

## 快速开始

### 最简步骤（5分钟）

```bash
# 方式 1: 使用批处理脚本（推荐）
cd c:\Users\SW\Desktop\unigui-admin
run_tests.bat
# 选择选项 1 - 在 Delphi IDE 中打开测试项目
# 按 F9 运行测试

# 方式 2: 直接运行已编译的测试
cd c:\Users\SW\Desktop\unigui-admin\tests\Win32\Debug
UniAdminTests.exe
```

### 测试结果位置

- **控制台输出**: 直接显示在控制台
- **XML 报告**: `tests/TestResults.xml` (NUnit 格式)
- **HTML 报告**: 可通过 IDE 生成

---

## 环境准备

### 必需组件

| 组件 | 版本要求 | 安装状态 |
|-----|---------|---------|
| Delphi IDE | 12 (Athens) 或更高 | 需要确认 |
| DUnitX | 框架已包含 | ✅ 已集成 |
| FireDAC | 数据库组件 | ✅ 已包含 |
| UniGUI | Web 框架 | ✅ 已包含 |

### 项目路径配置

确保以下路径正确：

```
项目根目录: c:\Users\SW\Desktop\unigui-admin\
测试项目: tests\UniAdminTests.dpr
源代码: src\
测试代码: tests\
```

---

## 运行测试

### 方法 1: Delphi IDE 中运行（推荐）⭐

#### 步骤 1: 打开测试项目

```bash
# 方式 A: 双击打开
tests\UniAdminTests.dproj

# 方式 B: 使用批处理脚本
run_tests.bat
# 选择选项 1
```

#### 步骤 2: 配置搜索路径

在 Delphi IDE 中:
1. Project → Options → Building → Delphi Compiler
2. 添加以下搜索路径:
   ```
   $(ProjectDir)\..\src\Core\Plugin
   $(ProjectDir)\..\src\Core\Session
   $(ProjectDir)\..\src\Core\Context
   $(ProjectDir)\..\src\Core\Config
   $(ProjectDir)\..\src\Core\Auth
   $(ProjectDir)\..\src\Core\Permission
   $(ProjectDir)\..\src\Core\Menu
   $(ProjectDir)\..\src\Core\Data
   $(ProjectDir)\..\src\Core\Metadata
   $(ProjectDir)\..\src\Core\UI
   $(ProjectDir)\..\src\Modules\Config
   ```
3. 点击 OK 保存

#### 步骤 3: 运行测试

```
按 F9 或点击 "Run" 按钮
```

#### 步骤 4: 查看结果

测试运行后，IDE 会显示:
- 测试通过/失败统计
- 失败测试的详细信息
- 执行时间

---

### 方法 2: 命令行运行

#### 步骤 1: 编译测试项目

```bash
cd c:\Users\SW\Desktop\unigui-admin
msbuild tests\UniAdminTests.dproj /p:Config=Debug /t:Clean,Build
```

#### 步骤 2: 运行测试

```bash
cd tests\Win32\Debug
UniAdminTests.exe
```

#### 步骤 3: 查看输出

控制台会显示:
```
DUnitX Test Runner for Delphi
----------------------------

Running tests...

[  PASSED  ] TestPluginRegistration (12ms)
[  PASSED  ] TestPluginInitialization (8ms)
[  PASSED  ] TestPluginActivation (15ms)
[  PASSED  ] TestDependencyValidation (10ms)
[  PASSED  ] TestCircularDependencyDetection (20ms)

Tests: 5
Passed: 5
Failed: 0
Skipped: 0
Time: 0.065s

Done.. press <Enter> key to quit.
```

---

### 方法 3: 使用 TestInsight（高级）

TestInsight 提供图形化测试结果界面。

#### 启用 TestInsight

1. 在 Delphi IDE 中打开测试项目
2. Project → Options → TestInsight
3. 勾选 "Enable TestInsight"
4. 重新编译并运行

#### 查看结果

TestInsight 窗口会显示:
- 测试树形结构
- 实时运行状态
- 详细的错误信息
- 测试覆盖率（如果启用）

---

## 分析结果

### 测试结果示例

```
✅ PASSED - 测试通过
❌ FAILED - 测试失败
⏭️ SKIPPED - 测试跳过
⏸️ DISABLED - 测试已禁用
```

### 测试报告格式

#### XML 报告（NUnit 格式）

```xml
<?xml version="1.0" encoding="utf-8"?>
<test-results name="UniAdminTests">
  <test-suite name="UniPluginTest">
    <test-case name="TestPluginRegistration" executed="true" result="Success" />
    <test-case name="TestPluginInitialization" executed="true" result="Success" />
    <test-case name="TestPluginActivation" executed="true" result="Success" />
    <test-case name="TestDependencyValidation" executed="true" result="Success" />
    <test-case name="TestCircularDependencyDetection" executed="true" result="Success" />
  </test-suite>
</test-results>
```

#### HTML 报告

IDE 可生成更友好的 HTML 报告，包含:
- 测试统计图表
- 失败详情
- 执行时间分析
- 历史趋势

---

## 常见问题

### Q1: 编译错误 - "找不到文件"

**症状**:
```
[Fatal Error] Unit1.pas(7): File not found: 'UniPlugin.pas'
```

**解决方案**:
1. Project → Options → Building → Delphi Compiler
2. Search Path 添加源代码目录
3. 清理并重新编译

---

### Q2: 运行时错误 - "无法访问数据库"

**症状**:
```
Exception: EDatabaseError
Message: Unable to connect to database server
```

**解决方案**:
1. 检查 `config/app.json` 中的数据库连接字符串
2. 确保数据库服务器运行中
3. 验证用户名和密码正确
4. 测试数据库连接:
   ```sql
   -- SQL Server 测试
   SELECT @@VERSION
   ```

---

### Q3: 测试超时

**症状**:
```
Timeout waiting for test to complete
```

**解决方案**:
1. 检查是否有死锁或无限循环
2. 增加测试超时时间
3. 使用调试器逐步执行

---

### Q4: 部分测试失败

**症状**:
```
Tests: 10
Passed: 8
Failed: 2
```

**解决方案**:
1. 查看失败测试的详细错误信息
2. 检查测试数据是否正确
3. 验证测试环境配置
4. 逐个调试失败的测试

---

### Q5: 内存泄漏

**症状**:
```
Memory Leak Detected!
Address: 0x00A1B2C3
Size: 128 bytes
```

**解决方案**:
1. 启用 FastMM 内存调试器
2. 仔细检查对象创建和释放
3. 确保使用 try-finally 块
4. 检查接口引用计数

---

## 测试报告

### Phase 1 测试报告

**文件**: `tests/Phase1-TestReport.md`
**内容**: Phase 1（插件管理层）测试结果
**更新日期**: 2026-02-24

### 测试验证报告

**文件**: `tests/TestValidationReport.md`
**内容**: 完整的测试覆盖和验证计划
**更新日期**: 2026-02-25

### 更新报告

测试运行后，请更新:

1. **Phase 1 测试报告**
   ```markdown
   | 测试套件 | 通过 | 失败 | 跳过 | 状态 |
   |---------|-----|-----|-----|-----|
   | UniPluginTest | 5/5 | 0/5 | 0/5 | ✅ 已完成 |
   ```

2. **测试验证报告**
   ```markdown
   | # | 测试方法 | 状态 |
   |---|---------|-----|
   | 1 | TestPluginRegistration | ✅ Pass |
   ```

3. **提交更新**
   ```bash
   git add tests/Phase1-TestReport.md
   git add tests/TestValidationReport.md
   git commit -m "test: 更新测试执行结果"
   ```

---

## 高级技巧

### 运行特定测试

```pascal
// 在 IDE 中，右键点击测试方法
// 选择 "Run This Test"

// 或使用命令行
UniAdminTests.exe -test=TestPluginRegistration
```

### 运行测试套件

```pascal
// 运行整个测试类
UniAdminTests.exe -suite=TUniPluginTest
```

### 生成代码覆盖率

1. 安装 Delphi Code Coverage 工具
2. 配置覆盖率选项
3. 运行测试
4. 查看覆盖率报告

### 调试测试

1. 设置断点在测试方法中
2. 按 F7（步入）或 F8（步过）
3. 检查变量值
4. 使用 "Evaluate/Modify" 窗口

---

## 检查清单

### 运行测试前

- [ ] Delphi IDE 已安装并可用
- [ ] 项目搜索路径已配置
- [ ] 数据库服务器运行中
- [ ] 测试数据已准备

### 运行测试时

- [ ] 所有测试文件已编译
- [ ] 测试可执行文件已生成
- [ ] 控制台输出正常显示
- [ ] 测试结果已记录

### 运行测试后

- [ ] 测试通过率 > 80%
- [ ] 失败测试已分析
- [ ] 测试报告已更新
- [ ] 问题已记录到 issue 跟踪系统

---

## 联系和支持

**文档维护**: AI Agent
**最后更新**: 2026-02-25
**版本**: 1.0

**问题反馈**:
- 查看 `tests/TestValidationReport.md` 中的问题清单
- 检查项目 GitHub Issues
- 联系开发团队

---

**附录**: 相关文档链接

- [DUnitX 官方文档](https://github.com/VSoftTechnologies/DUnitX)
- [Delphi 测试指南](https://docwiki.embarcadero.com/RADStudio/Sydney/en/Testing_Frameworks)
- [UniAdmin 项目文档](../../README.md)

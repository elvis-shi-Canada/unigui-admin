# UniAdmin 开发指南

> **项目**: UniAdmin 通用后台管理系统框架
> **目标受众**: 新开发者
> **版本**: 1.0.0

---

## 目录

1. [快速开始](#快速开始)
2. [开发环境搭建](#开发环境搭建)
3. [项目结构](#项目结构)
4. [编码规范](#编码规范)
5. [调试技巧](#调试技巧)
6. [常见问题](#常见问题)
7. [最佳实践](#最佳实践)

---

## 快速开始

### 5 分钟快速上手

```bash
# 1. 克隆项目
git clone https://github.com/uniadmin/uniadmin.git
cd uniadmin

# 2. 运行编译和测试
.\build_and_test.bat

# 3. 启动开发服务器
cd bin
UniAdminServer.exe --dev

# 4. 访问 Web 界面
# 浏览器打开: http://localhost:8077
# 默认账号: admin / admin123
```

### 下一步

- 阅读 [项目结构](#项目结构) 了解代码组织
- 阅读 [编码规范](#编码规范) 了解代码风格
- 尝试创建一个简单的模块

---

## 开发环境搭建

### 必需软件

#### 1. Delphi 12 Athens

**下载**: https://www.embarcadero.com/products/delphi

**安装组件**:
- VCL
- Web (UniGUI)
- Database (FireDAC)

**许可证**:
- Community Edition (免费，个人使用)
- Professional / Enterprise (商业项目)

#### 2. 数据库服务器

选择以下之一：

**SQL Server Express** (推荐新手)
```bash
# 下载地址
https://www.microsoft.com/sql-server/sql-server-downloads-express

# 安装后配置
服务器: localhost\SQLEXPRESS
端口: 1433
用户: sa
```

**MySQL Community Server**
```bash
# 下载地址
https://dev.mysql.com/downloads/mysql/

# 安装后配置
端口: 3306
root 密码: (自行设置)
```

**PostgreSQL**
```bash
# 下载地址
https://www.postgresql.org/download/windows/

# 安装后配置
端口: 5432
用户: postgres
```

#### 3. 版本控制

**Git**
```bash
# 下载地址
https://git-scm.com/download/win

# 验证安装
git --version
```

**推荐 Git 客户端**:
- SourceTree (免费，图形化)
- TortoiseGit (集成到资源管理器)

### 可选软件

#### 1. 代码编辑器

**Visual Studio Code**
```bash
# 下载地址
https://code.visualstudio.com/

# 推荐插件
- Pascal
- GitLens
- Bookmarks
- Error Lens
```

#### 2. API 测试工具

**Postman**
```bash
# 下载地址
https://www.postman.com/downloads/
```

#### 3. 数据库管理工具

**DBeaver** (推荐，支持多种数据库)
```bash
# 下载地址
https://dbeaver.io/download/
```

**SQL Server Management Studio** (仅 SQL Server)

### IDE 配置

#### Delphi IDE 设置

**工具 → 选项 → 编辑器**

| 设置项 | 推荐值 | 说明 |
|--------|--------|------|
| 右边距 | 120 | 代码行长度限制 |
| 缩进大小 | 2 | 空格缩进 |
| Tab 键 | 插入空格 | 不要使用制表符 |
| 自动完成 | 启用 | 加快编码速度 |
| 代码模板 | 自定义 | 添加常用代码片段 |

**工具 → 选项 → 调试器**

| 设置项 | 推荐值 | 说明 |
|--------|--------|------|
| 断点字体 | Consolas 10 | 清晰可读 |
| 调用栈深度 | 20 | 足够深 |
| 自动变量 | 启用 | 快速查看变量值 |

#### 环境变量

```bash
# 设置 UniGUI 路径
UNIGUI_PATH=C:\Program Files (x86)\FMSoft\Framework\uniGUI

# 设置数据库路径
DB_PATH=C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS

# 添加到 PATH
%PATH%;%UNIGUI_PATH%\bin
```

---

## 项目结构

### 目录布局

```
UniAdmin/
├── docs/                    # 文档目录
│   ├── plans/               # 实施计划
│   ├── API.md               # API 文档
│   └── Security.md          # 安全文档
├── src/                     # 源代码目录
│   ├── Core/                # 核心框架
│   │   ├── Context/         # 执行上下文
│   │   ├── Plugin/          # 插件系统
│   │   ├── Data/            # 数据访问
│   │   ├── Metadata/        # 元数据管理
│   │   ├── Auth/            # 认证服务
│   │   ├── Menu/            # 菜单管理
│   │   ├── Permission/      # 权限管理
│   │   ├── Services/        # 核心服务
│   │   ├── Session/         # 会话管理
│   │   └── UI/              # UI 组件
│   ├── Modules/             # 业务模块
│   │   ├── User/            # 用户管理
│   │   ├── Role/            # 角色管理
│   │   ├── Menu/            # 菜单管理
│   │   ├── Dictionary/      # 数据字典
│   │   ├── Config/          # 系统配置
│   │   ├── Log/             # 日志审计
│   │   └── Scheduler/       # 定时任务
│   └── Plugins/             # 插件
│       └── Dictionary/      # 示例插件
├── tests/                   # 测试目录
│   ├── Core/                # 核心测试
│   ├── Modules/             # 模块测试
│   └── Phase3/              # Phase 3 集成测试
├── tools/                   # 工具脚本
├── Database/                # 数据库脚本
│   ├── Schema/              # 表结构
│   └── Seed/                # 初始数据
├── config/                  # 配置文件
├── assets/                  # 静态资源
├── bin/                     # 编译输出
├── dcu/                     # 中间文件
└── logs/                    # 日志文件
```

### 核心组件说明

#### 插件系统

**UniPlugin.pas** - 插件基类
```pascal
TPlugin = class(TInterfacedObject, IPlugin)
  // 插件生命周期方法
  procedure Initialize;
  procedure Activate;
  procedure Deactivate;
end;
```

**UniAdminModuleRegistry.pas** - 插件注册表
```pascal
// 注册插件
TUniAdminModuleRegistry.GetInstance.RegisterPluginClass(
  TMyPlugin,
  'my-plugin',
  LPluginInfo
);
```

#### 数据访问层

**UniAdminDataModule.pas** - 数据模块基类
```pascal
TUniBaseModule = class(TDataModule)
  // 审计字段自动填充
  procedure SetAuditFields(DataSet: TDataSet; UserID: Integer);
end;
```

#### 服务层

**UniAdminServices.pas** - 服务定位器
```pascal
// 访问服务
var AuthService := TUniAdminServices.AuthService;
var MenuManager := TUniAdminServices.MenuManager;
```

### 创建新模块

#### 步骤 1: 创建模块目录

```bash
mkdir src\Modules\Product
```

#### 步骤 2: 创建数据模块

```pascal
// src/Modules/Product/ProductDataModule.pas
unit ProductDataModule;

interface

uses
  System.SysUtils, System.Classes,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Definitions,
  UniAdminDataModule;

type
  TProductDataModule = class(TUniBaseModule)
    FDTableProducts: TFDTable;
    FDQueryGetProducts: TFDQuery;
    FDConnection: TFDConnection;
  private
  public
    procedure Open; override;
    function GetProducts(const Filter: string): TDataSet;
  end;

implementation

procedure TProductDataModule.Open;
begin
  inherited;
  FDConnection.Connected := True;
  FDTableProducts.Open;
end;

function TProductDataModule.GetProducts(const Filter: string): TDataSet;
begin
  FDQueryGetProducts.Close;
  FDQueryGetProducts.ParamByName('Filter').AsString := Filter + '%';
  FDQueryGetProducts.Open;
  Result := FDQueryGetProducts;
end;

end.
```

#### 步骤 3: 创建服务类

```pascal
// src/Modules/Product/ProductService.pas
unit ProductService;

interface

uses
  System.SysUtils,
  UniContext, UniPlugin.Types;

type
  IProductService = interface(IInterface)
    ['{PRODUCT-SERVICE-001}']
    function GetProducts(const Filter: string): string;
  end;

  TProductService = class(TInterfacedObject, IProductService)
  public
    function GetProducts(const Filter: string): string;
  end;

implementation

function TProductService.GetProducts(const Filter: string): string;
begin
  // 业务逻辑实现
  Result := '[]';
end;

end.
```

#### 步骤 4: 创建 UI 组件

```pascal
// src/Modules/Product/ProductListFrame.pas
unit ProductListFrame;

interface

uses
  System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms,
  UniGUIBaseModule, UniGUIClasses, UniGUIForm, UniGUIFrame,
  BaseCrudFrame;

type
  TProductListFrame = class(TBaseCrudFrame)
  private
  protected
    procedure DoInitialize; override;
  public
  end;

implementation

procedure TProductListFrame.DoInitialize;
begin
  inherited;
  // 初始化 UI
end;

end.
```

---

## 编码规范

### Pascal 代码风格

#### 命名约定

| 类型 | 命名规则 | 示例 |
|------|----------|------|
| 类 | T + PascalCase | TUserDataModule |
| 接口 | I + PascalCase | IUserService |
| 记录 | PascalCase | TUserInfo |
| 函数/过程 | PascalCase | GetUserByID |
| 变量 | PascalCase (局部), F + PascalCase (私有) | FUserName |
| 常量 | 全大写 + 下划线 | MAX_RETRY_COUNT |
| 参数 | A + PascalCase | AUserID |

#### 代码格式

```pascal
// 好的示例
function TUserService.GetUserByID(AUserID: Integer): TUserInfo;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'SELECT * FROM Users WHERE UserID = :UserID';
    LQuery.ParamByName('UserID').AsInteger := AUserID;
    LQuery.Open;

    if not LQuery.Eof then
      Result := DataSetToUserInfo(LQuery)
    else
      Result := Default(TUserInfo);
  finally
    LQuery.Free;
  end;
end;

// 避免的示例
function TUserService.getuserByID(id:integer):TUserInfo;
var q:TFDQuery;
begin
  q:=TFDQuery.Create(nil);
  q.Connection:=FConnection;
  // ... 缩进不一致，缺少空格
end;
```

#### 注释规范

```pascal
/// <summary>
/// 用户管理服务类
/// 提供用户查询、创建、更新和删除功能
/// </summary>
TUserService = class(TInterfacedObject, IUserService)
public
  /// <summary>
  /// 根据用户 ID 获取用户信息
  /// </summary>
  /// <param name="AUserID">用户 ID</param>
  /// <returns>用户信息记录，如果未找到返回默认值</returns>
  function GetUserByID(AUserID: Integer): TUserInfo;
end;

// 单行注释用于解释复杂逻辑
// 使用三层嵌套循环来查找匹配项
```

#### 异常处理

```pascal
// 好的示例
function TUserService.CreateUser(const AInfo: TUserInfo): Integer;
begin
  Result := 0;
  try
    // 参数验证
    if AInfo.UserName.IsEmpty then
      raise EArgumentException.Create('用户名不能为空');

    // 业务逻辑
    Result := FDataModule.CreateUser(AInfo);

    // 记录日志
    LogOperation('User', 'Create', Format('创建用户: %s', [AInfo.UserName]));
  except
    on E: EArgumentException do
      raise; // 重新抛出已知异常
    on E: EFDatabaseError do
    begin
      // 包装数据库异常
      LogError('创建用户失败: ' + E.Message);
      raise EServiceException.Create('系统错误，请稍后重试');
    end;
    on E: Exception do
    begin
      // 记录未预期的异常
      LogError('未知错误: ' + E.Message);
      raise;
    end;
  end;
end;
```

### 数据库规范

#### SQL 编写规范

```sql
-- 好的示例
SELECT
    u.UserID,
    u.UserName,
    u.RealName,
    u.Email,
    r.RoleName
FROM UniAdmin_Users u
LEFT JOIN UniAdmin_UserRoles ur ON u.UserID = ur.UserID
LEFT JOIN UniAdmin_Roles r ON ur.RoleID = r.RoleID
WHERE u.Status = 1
ORDER BY u.CreatedDate DESC
OFFSET 0 ROWS FETCH NEXT 20 ROWS ONLY;

-- 避免的示例
SELECT * FROM Users WHERE Status=1
```

#### 参数化查询

```pascal
// 好的示例 - 使用参数
FDQuery.SQL.Text := 'SELECT * FROM Users WHERE UserName = :UserName';
FDQuery.ParamByName('UserName').AsString := AUserName;
FDQuery.Open;

// 避免 - SQL 注入风险
FDQuery.SQL.Text := Format('SELECT * FROM Users WHERE UserName = ''%s''', [AUserName]);
```

---

## 调试技巧

### Delphi 调试器

#### 设置断点

1. 在代码行号处点击，设置断点
2. 按 F9 编译并运行
3. 程序将在断点处暂停

#### 条件断点

右键断点 → 断点属性 → 条件

```pascal
// 当 UserID > 100 时才中断
UserID > 100
```

#### 查看变量

- 局部变量窗口: 查看当前作用域变量
- 监视窗口: 添加自定义表达式
- 调用堆栈: 查看函数调用链

### 日志调试

#### 输出调试信息

```pascal
uses
  System.SysUtils;

// 输出到调试控制台
OutputDebugString(PChar(Format('用户 ID: %d', [AUserID])));

// 使用日志服务
LogService.LogDebug(Format('查询参数: %s', [AFilter]));
```

#### 日志级别

```pascal
// 调试日志 - 仅开发环境
LogService.LogDebug('进入方法 GetUserByID');

// 信息日志 - 正常业务流程
LogService.LogInfo('创建用户成功');

// 警告日志 - 需要注意但不影响运行
LogService.LogWarn('数据库连接数接近上限');

// 错误日志 - 需要立即处理
LogService.LogError('数据库连接失败', E);
```

### 数据库调试

#### 查看 SQL 语句

```pascal
// 在 FireDAC 中启用 SQL 监控
FDConnection.ResourceOptions.MacroCreate := True;
FDConnection.ResourceOptions.MacroExpand := True;
FDConnection.Connected := True;

// 输出实际执行的 SQL
OutputDebugString(PChar(FDQuery.SQL.Text));
```

#### 分析慢查询

```sql
-- 启用查询分析
SET STATISTICS TIME ON;
SET STATISTICS IO ON;

-- 执行查询
SELECT * FROM UniAdmin_Users;

-- 查看执行计划
SET SHOWPLAN_ALL ON;
```

---

## 常见问题

### 编译问题

#### Q: 编译错误 "找不到文件 XXX.dfm"

**A**:
1. 确保 .dfm 文件与 .pas 文件在同一目录
2. 检查项目文件 (.dpr) 中是否包含该单元
3. 尝试清理并重新编译

```bash
# 清理编译产物
del /Q dcu\*.*
del /Q bin\*.*

# 重新编译
dcc32 ProjectName.dpr
```

#### Q: 链接错误 "未解析的外部符号"

**A**:
1. 检查接口单元是否在 uses 子句中
2. 确认所有必要的单元都已编译
3. 检查单元路径配置

### 运行时问题

#### Q: "不支持的数据库驱动"

**A**:
1. 确认 FireDAC 驱动已安装
2. 检查连接字符串中的 DriverID
3. 安装相应的数据库客户端

#### Q: Session 丢失

**A**:
1. 检查 Session 超时设置
2. 确认 Cookie 配置正确
3. 检查服务器时间是否同步

### 性能问题

#### Q: 页面加载慢

**A**:
1. 启用缓存
2. 优化数据库查询
3. 使用分页
4. 压缩静态资源

---

## 最佳实践

### SOLID 原则

```pascal
// 单一职责原则
class TUserDataModule // 只负责数据访问
class TUserService     // 只负责业务逻辑
class TUserListFrame   // 只负责 UI 展示

// 开闭原则 - 通过扩展而非修改
type
  TPlugin = class
    procedure DoInitialize; virtual; // 子类可覆盖
  end;

// 里氏替换原则
IUserService = interface(IInterface)
  // 接口定义清晰，子类完全兼容
end;

// 接口隔离原则
IUserReadable = interface
  function GetUserByID(ID: Integer): TUserInfo;
end;

IUserWritable = interface
  procedure CreateUser(const Info: TUserInfo): Integer;
end;

// 依赖倒置原则
TUserService = class
private
  FDataAccess: IUserDataAccess; // 依赖抽象而非具体实现
end;
```

### DRY (Don't Repeat Yourself)

```pascal
// 创建基类避免重复代码
TBaseCrudFrame = class(TFrame)
protected
  procedure DoSearch; virtual;
  procedure DoAdd; virtual;
  procedure DoEdit; virtual;
  procedure DoDelete; virtual;
end;

// 子类继承基类
TUserListFrame = class(TBaseCrudFrame)
protected
  procedure DoSearch; override; // 只实现特定逻辑
end;
```

### 内存管理

```pascal
// 好的示例
procedure ProcessUsers;
var
  LList: TList<Integer>;
begin
  LList := TList<Integer>.Create;
  try
    // 处理逻辑
  finally
    LList.Free; // 确保释放
  end;
end;

// 更好的示例 - 使用接口
procedure ProcessUsers;
var
  LService: IUserListService; // 接口自动管理生命周期
begin
  LService := TUserListService.Create;
  // 无需手动释放
end;
```

---

## 资源链接

### 官方文档
- [Delphi 文档](https://docwiki.embarcadero.com/)
- [UniGUI 文档](http://www.unigui.com/doc)
- [FireDAC 文档](https://docwiki.embarcadero.com/libraries/en/FireDAC)

### 社区
- [Delphi 社区论坛](https://forums.embarcadero.com/)
- [Stack Overflow - Delphi 标签](https://stackoverflow.com/questions/tagged/delphi)

### 工具
- [GExperts](http://www.gexperts.org/) - Delphi 增强工具
- [DelphiSpeedUp](https://github.com/DelphiBundle/DelphiSpeedUp) - IDE 加速

---

**文档版本**: 1.0
**最后更新**: 2026-02-24

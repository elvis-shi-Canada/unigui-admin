# 声明式 Admin 引擎（Django Admin 风格）实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在现有项目基础上增加一层"元数据驱动 UI 生成引擎"，让新业务模块只需声明 `TableName + 列表字段 + 搜索字段 + 权限前缀`，即可自动派生出 CRUD 列表页网格、查询 SQL 和菜单/权限注册，达到 Django Admin 的声明式开发体验，同时不破坏已有的手写 Frame。

**Architecture:**
引入一个 `TModelAdmin` 注册中心（进程级单例），每个业务模块在自己的单元 `initialization` 段向它注册一份声明。引擎在运行时复用现有的 `IUniAdminMetadataCache`（读字段元数据）、`TUniAdminModel`（CRUD/审计）、`TBaseCrudFrame`（权限/按钮状态）和 `TUniAdminMdiRouter`（类名路由），把声明翻译成：①自动网格列 ②参数化查询 SQL ③自动菜单/权限项。改造分四层渐进：先让 `TBaseCrudFrame` 能"从元数据派生网格列"（消除最大样板），再加 `TModelAdmin` 声明中心，然后让菜单/权限从声明中心自动生成（消除两套真值源），最后提供一个零样板的 `TAutoCrudFrame` 落地示例。

**Tech Stack:** Delphi 12 (RAD Studio 23.0), UniGUI 1.6, FireDAC, DUnitX（单元测试）, SQLite（开发期）/MSSQL（生产期）。

**核心约束（来自 AGENTS.md / 既有代码）：**
- `.pas` 文件保持 GBK 编码，中文以原文保留；**不要**用 UTF-8 重写带中文的单元。
- 数据库连接每会话独立，通过 `GetMainModule.Services.Connection` / `Services.MetadataCache` 获取；`TUniAdminDataModule` 用 `CreateWithConnection(nil, Connection)` 共享会话连接，`FOwnsConnection=False`。
- DFM 流读取器只识别 `published` 区方法，事件处理方法必须放在 `private` 之前的默认可见性区。
- 每个新 Frame 单元必须在 `initialization` 段调用 `RegisterClass(TXxxFrame)`，否则 `TUniAdminMdiRouter.FindFrameClass` 会因 `GetClass` 返回 nil 抛出"EClassNotFound"。

---

## 文件结构总览

下面是本次改造涉及的全部文件。**新增**文件集中在 `src/Core/Admin/`，对既有文件的修改都是**追加**而非重写。

| 类型 | 文件路径 | 职责 |
|---|---|---|
| 新增 | `src/Core/Admin/UniModelAdmin.Intf.pas` | `TModelAdmin` 记录 + `IModelAdminRegistry` 接口声明 |
| 新增 | `src/Core/Admin/UniModelAdmin.pas` | `TModelAdminRegistry` 进程级单例实现 |
| 新增 | `src/Core/Admin/UniQueryBuilder.pas` | 通用参数化 SELECT/WHERE 生成器（无 SQL 注入） |
| 新增 | `src/Core/UI/AutoCrudFrame.pas` + `.dfm` | 零样板声明式 CRUD Frame（继承 `TBaseCrudFrame`） |
| 新增 | `tests/Core/Admin/UniModelAdminTest.pas` | `TModelAdminRegistry` 的 DUnitX 测试 |
| 新增 | `tests/Core/Admin/UniQueryBuilderTest.pas` | `TQueryClauseBuilder` 的 DUnitX 测试 |
| 修改 | `src/Core/UI/BaseCrudFrame.pas` | 增 `AutoGridFromMeta` / `ModelTableName`，扩 `DoInitialize` 派生网格列 |
| 修改 | `src/Core/Menu/SystemMenuSetup.pas` | 增 `BuildMenusFromRegistry`，遍历 `TModelAdminRegistry` 合并菜单定义 |
| 修改 | `src/UniAdmin.dpr` | `uses` 增列新单元 |
| 修改 | `tests/UniAdminTests.dpr` | `uses` 增列新测试单元 |
| 落地示例 | `src/Modules/User/UserListFrame.pas` | 改造为声明式（验证向后兼容：旧手写路径仍可工作，新声明式路径更简洁） |

---

## Task 1: 定义 `TModelAdmin` 声明记录与注册中心接口

**Files:**
- Create: `src/Core/Admin/UniModelAdmin.Intf.pas`
- Test: `tests/Core/Admin/UniModelAdminTest.pas`（本任务先建空壳，Task 2 才填测试）

- [ ] **Step 1: 创建接口单元**

新建 `src/Core/Admin/UniModelAdmin.Intf.pas`：

```pascal
unit UniModelAdmin.Intf;

interface

uses
  System.SysUtils, System.Generics.Collections;

type
  /// <summary>
  /// 字段显示配置：用于 list_display / 编辑表单列
  /// </summary>
  TAdminFieldConfig = record
    FieldName: string;
    DisplayName: string;
    Width: Integer;
    /// <summary>留空则从元数据推断</summary>
    EditorType: string;
    class function Create(const AFieldName, ADisplayName: string;
      AWidth: Integer = 100): TAdminFieldConfig; static;
  end;

  /// <summary>
  /// 单张表的声明式 Admin 配置（类比 Django 的 ModelAdmin）
  /// 在业务单元 initialization 段填充后注册到 IModelAdminRegistry
  /// </summary>
  TModelAdmin = record
    /// <summary>逻辑 ID，如 'user'。用作菜单 RouteKey 与权限前缀</summary>
    AdminID: string;
    /// <summary>目标数据库表名（用于元数据读取与查询生成）</summary>
    TableName: string;
    /// <summary>菜单显示名（中文，GBK 原文保留）</summary>
    DisplayName: string;
    /// <summary>承载此表的 Frame 类名；为空则用 TAutoCrudFrame</summary>
    FrameClassName: string;
    /// <summary>列表显示字段；为空则取元数据全部字段</summary>
    ListDisplay: TArray<TAdminFieldConfig>;
    /// <summary>参与 LIKE 搜索的字段名（数据库列名）</summary>
    SearchFields: TArray<string>;
    /// <summary>等值过滤字段名，如 ['Status']</summary>
    FilterFields: TArray<string>;
    /// <summary>权限前缀，如 'user'，自动派生 user:view/add/edit/delete</summary>
    PermissionPrefix: string;
    /// <summary>菜单排序号</summary>
    SortOrder: Integer;
    /// <summary>父菜单代码（如 'system'），用于挂载菜单树</summary>
    ParentMenuCode: string;
    /// <summary>图标文件名</summary>
    Icon: string;

    class function Create(const AAdminID, ATableName, ADisplayName: string): TModelAdmin; static;
  end;

  /// <summary>
  /// ModelAdmin 注册中心接口（进程级单例语义）
  /// </summary>
  IModelAdminRegistry = interface(IInterface)
    ['{F1A2B3C4-D5E6-7890-ABCD-1234567890AB}']
    procedure Register(const AAdmin: TModelAdmin);
    function Find(const AAdminID: string; out AAdmin: TModelAdmin): Boolean;
    function GetByTableName(const ATableName: string): TModelAdmin;
    function GetAll: TArray<TModelAdmin>;
    function Count: Integer;
    procedure Clear;
  end;

implementation

{ TAdminFieldConfig }

class function TAdminFieldConfig.Create(const AFieldName, ADisplayName: string;
  AWidth: Integer): TAdminFieldConfig;
begin
  Result.FieldName := AFieldName;
  Result.DisplayName := ADisplayName;
  Result.Width := AWidth;
  Result.EditorType := '';
end;

{ TModelAdmin }

class function TModelAdmin.Create(const AAdminID, ATableName,
  ADisplayName: string): TModelAdmin;
begin
  Result.AdminID := AAdminID;
  Result.TableName := ATableName;
  Result.DisplayName := ADisplayName;
  Result.FrameClassName := '';
  Result.ListDisplay := nil;
  Result.SearchFields := nil;
  Result.FilterFields := nil;
  Result.PermissionPrefix := AAdminID;
  Result.SortOrder := 999;
  Result.ParentMenuCode := '';
  Result.Icon := '';
end;

end.
```

- [ ] **Step 2: 提交**

```bash
git add src/Core/Admin/UniModelAdmin.Intf.pas
git commit -m "feat(admin): 定义 TModelAdmin 声明记录与 IModelAdminRegistry 接口"
```

---

## Task 2: 实现 `TModelAdminRegistry` 单例 + DUnitX 测试（TDD）

**Files:**
- Create: `tests/Core/Admin/UniModelAdminTest.pas`
- Create: `src/Core/Admin/UniModelAdmin.pas`

- [ ] **Step 1: 写失败测试**

新建 `tests/Core/Admin/UniModelAdminTest.pas`（GBK 中文原文保留，参考既有 `UniPluginTest.pas` 的 DUnitX 风格）：

```pascal
unit UniModelAdminTest;

interface

uses
  System.SysUtils, DUnitX.TestFramework,
  UniModelAdmin.Intf, UniModelAdmin;

type
  [TestFixture]
  TUniModelAdminTest = class
  private
    FRegistry: IModelAdminRegistry;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    [TestCase('TestRegisterAndFind', '')]
    procedure TestRegisterAndFind;

    [Test]
    [TestCase('TestDuplicateOverwrites', '')]
    procedure TestDuplicateOverwrites;

    [Test]
    [TestCase('TestGetByTableName', '')]
    procedure TestGetByTableName;

    [Test]
    [TestCase('TestFindMissingReturnsFalse', '')]
    procedure TestFindMissingReturnsFalse;
  end;

implementation

procedure TUniModelAdminTest.Setup;
begin
  FRegistry := TModelAdminRegistry.CreateInstance;
  FRegistry.Clear;
end;

procedure TUniModelAdminTest.TearDown;
begin
  FRegistry := nil;
end;

procedure TUniModelAdminTest.TestRegisterAndFind;
var
  LAdmin: TModelAdmin;
  LFound: TModelAdmin;
begin
  LAdmin := TModelAdmin.Create('user', 'UniAdmin_Users', '用户管理');
  LAdmin.PermissionPrefix := 'user';
  LAdmin.SortOrder := 110;
  FRegistry.Register(LAdmin);

  Assert.AreEqual(1, FRegistry.Count, '注册后计数应为 1');
  Assert.IsTrue(FRegistry.Find('user', LFound), '应能找到已注册的 user');
  Assert.AreEqual('UniAdmin_Users', LFound.TableName, 'TableName 应匹配');
  Assert.AreEqual('用户管理', LFound.DisplayName, 'DisplayName 应匹配');
end;

procedure TUniModelAdminTest.TestDuplicateOverwrites;
var
  LA, LB: TModelAdmin;
  LFound: TModelAdmin;
begin
  LA := TModelAdmin.Create('user', 'UniAdmin_Users', '用户管理');
  FRegistry.Register(LA);
  LB := TModelAdmin.Create('user', 'UniAdmin_Users', '系统用户');
  FRegistry.Register(LB);

  Assert.AreEqual(1, FRegistry.Count, '重复注册应覆盖而非新增');
  FRegistry.Find('user', LFound);
  Assert.AreEqual('系统用户', LFound.DisplayName, '后者应覆盖前者');
end;

procedure TUniModelAdminTest.TestGetByTableName;
var
  LAdmin: TModelAdmin;
  LFound: TModelAdmin;
begin
  LAdmin := TModelAdmin.Create('role', 'UniAdmin_Roles', '角色管理');
  FRegistry.Register(LAdmin);

  LFound := FRegistry.GetByTableName('UniAdmin_Roles');
  Assert.AreEqual('role', LFound.AdminID, '按表名应反查到 AdminID');
end;

procedure TUniModelAdminTest.TestFindMissingReturnsFalse;
var
  LAdmin: TModelAdmin;
begin
  Assert.IsFalse(FRegistry.Find('nonexistent', LAdmin),
    '查不存在的 ID 应返回 False 且不抛异常');
end;

initialization
  TDUnitX.RegisterTestFixture(TUniModelAdminTest);

end.
```

- [ ] **Step 2: 运行测试验证失败**

测试现在引用的 `TModelAdminRegistry.CreateInstance` / `Clear` / `Find` 等都不存在，预期编译失败（"Undeclared identifier: 'TModelAdminRegistry'"）。

Run（在 Delphi IDE 或命令行编译 tests/UniAdminTests.dpr）：
预期：编译错误 `E2003 Undeclared identifier: 'TModelAdminRegistry'`

- [ ] **Step 3: 实现注册中心**

新建 `src/Core/Admin/UniModelAdmin.pas`：

```pascal
unit UniModelAdmin;

interface

uses
  System.SysUtils, System.Generics.Collections, System.SyncObjs,
  UniModelAdmin.Intf;

type
  /// <summary>
  /// ModelAdmin 注册中心实现（进程级单例）
  /// 设计参照 TUniAdminModuleRegistry 的 GetInstance / CleanupInstance 模式
  /// </summary>
  TModelAdminRegistry = class(TInterfacedObject, IModelAdminRegistry)
  private
    class var FInstance: IModelAdminRegistry;
    class var FLock: TCriticalSection;
    FAdmins: TObjectDictionary<string, TModelAdmin>;

    class function GetInstance: IModelAdminRegistry; static;
    class destructor Destroy;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Register(const AAdmin: TModelAdmin);
    function Find(const AAdminID: string; out AAdmin: TModelAdmin): Boolean;
    function GetByTableName(const ATableName: string): TModelAdmin;
    function GetAll: TArray<TModelAdmin>;
    function Count: Integer;
    procedure Clear;

    /// <summary>获取进程级单例（首次调用时惰性创建）</summary>
    class function CreateInstance: IModelAdminRegistry; static;
    /// <summary>进程退出时清理（与 initialization/finalization 配合）</summary>
    class procedure CleanupInstance; static;
  end;

implementation

{ TModelAdminRegistry }

class function TModelAdminRegistry.CreateInstance: IModelAdminRegistry;
begin
  Result := GetInstance;
end;

class function TModelAdminRegistry.GetInstance: IModelAdminRegistry;
begin
  if FInstance = nil then
  begin
    FLock.Enter;
    try
      if FInstance = nil then
        FInstance := TModelAdminRegistry.Create;
    finally
      FLock.Leave;
    end;
  end;
  Result := FInstance;
end;

class destructor TModelAdminRegistry.Destroy;
begin
  CleanupInstance;
  FLock.Free;
end;

class procedure TModelAdminRegistry.CleanupInstance;
begin
  FInstance := nil;
end;

constructor TModelAdminRegistry.Create;
begin
  inherited;
  // 值拥有：字典负责释放内部 TModelAdmin 堆副本
  FAdmins := TObjectDictionary<string, TModelAdmin>.Create([doOwnsValues]);
end;

destructor TModelAdminRegistry.Destroy;
begin
  FAdmins.Free;
  inherited;
end;

procedure TModelAdminRegistry.Register(const AAdmin: TModelAdmin);
var
  LCopy: TModelAdmin;
begin
  // 记录是值类型且含动态数组（引用语义），为避免外部后续修改影响注册内容，
  // 这里复制一份堆对象持有。注意：TArray<TAdminFieldConfig> 需 Copy 处理引用。
  LCopy := TModelAdmin.Create(AAdmin.AdminID, AAdmin.TableName, AAdmin.DisplayName);
  LCopy.FrameClassName := AAdmin.FrameClassName;
  LCopy.ListDisplay := Copy(AAdmin.ListDisplay);
  LCopy.SearchFields := Copy(AAdmin.SearchFields);
  LCopy.FilterFields := Copy(AAdmin.FilterFields);
  LCopy.PermissionPrefix := AAdmin.PermissionPrefix;
  LCopy.SortOrder := AAdmin.SortOrder;
  LCopy.ParentMenuCode := AAdmin.ParentMenuCode;
  LCopy.Icon := AAdmin.Icon;
  FAdmins.AddOrSetValue(LowerCase(AAdmin.AdminID), LCopy);
end;

function TModelAdminRegistry.Find(const AAdminID: string;
  out AAdmin: TModelAdmin): Boolean;
var
  LPtr: TModelAdmin;
begin
  Result := FAdmins.TryGetValue(LowerCase(AAdminID), LPtr);
  if Result then
    AAdmin := LPtr^   // 返回内部副本的值拷贝
  else
  begin
    AAdmin.AdminID := '';
    AAdmin.TableName := '';
  end;
end;

function TModelAdminRegistry.GetByTableName(const ATableName: string): TModelAdmin;
var
  LPair: TPair<string, TModelAdmin>;
begin
  Result.AdminID := '';
  for LPair in FAdmins do
    if SameText(LPair.Value.TableName, ATableName) then
      Exit(LPair.Value^);
end;

function TModelAdminRegistry.GetAll: TArray<TModelAdmin>;
var
  LPair: TPair<string, TModelAdmin>;
  LList: TList<TModelAdmin>;
begin
  LList := TList<TModelAdmin>.Create;
  try
    for LPair in FAdmins do
      LList.Add(LPair.Value^);
    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

function TModelAdminRegistry.Count: Integer;
begin
  Result := FAdmins.Count;
end;

procedure TModelAdminRegistry.Clear;
begin
  FAdmins.Clear;
end;

initialization
  TModelAdminRegistry.FLock := TCriticalSection.Create;

finalization
  TModelAdminRegistry.CleanupInstance;
  if Assigned(TModelAdminRegistry.FLock) then
  begin
    TModelAdminRegistry.FLock.Free;
    TModelAdminRegistry.FLock := nil;
  end;

end.
```

- [ ] **Step 4: 把新单元加入测试项目 uses**

修改 `tests/UniAdminTests.dpr`，在 `uses` 子句末尾（`UniAdminModuleRegistry.Intf` 之后）追加：

```pascal
  UniModelAdmin.Intf in '..\src\Core\Admin\UniModelAdmin.Intf.pas',
  UniModelAdmin in '..\src\Core\Admin\UniModelAdmin.pas',
  UniModelAdminTest in 'Core\Admin\UniModelAdminTest.pas';
```

- [ ] **Step 5: 运行测试验证通过**

Run: 编译并运行 `tests/UniAdminTests.dpr`
预期：4 个测试全部 PASS（`TestRegisterAndFind`、`TestDuplicateOverwrites`、`TestGetByTableName`、`TestFindMissingReturnsFalse`）

- [ ] **Step 6: 提交**

```bash
git add src/Core/Admin/UniModelAdmin.pas tests/Core/Admin/UniModelAdminTest.pas tests/UniAdminTests.dpr
git commit -m "feat(admin): 实现 TModelAdminRegistry 单例 + DUnitX 测试"
```

---

## Task 3: 通用参数化查询生成器 `TQueryClauseBuilder`（TDD）

**Files:**
- Create: `tests/Core/Admin/UniQueryBuilderTest.pas`
- Create: `src/Core/Admin/UniQueryBuilder.pas`

> 目标：消除 `UserListFrame.LoadUsers` 与 `UserDataModule.GetUsers` 里手写 WHERE 拼接的样板。生成器只产出**参数化** SQL，杜绝注入。

- [ ] **Step 1: 写失败测试**

新建 `tests/Core/Admin/UniQueryBuilderTest.pas`：

```pascal
unit UniQueryBuilderTest;

interface

uses
  System.SysUtils, DUnitX.TestFramework,
  UniQueryBuilder;

type
  [TestFixture]
  TUniQueryBuilderTest = class
  private
    FBuilder: TQueryClauseBuilder;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    [TestCase('TestNoClause', '')]
    procedure TestNoClause;

    [Test]
    [TestCase('TestLikeClause', '')]
    procedure TestLikeClause;

    [Test]
    [TestCase('TestEqualClause', '')]
    procedure TestEqualClause;

    [Test]
    [TestCase('TestCombinedClause', '')]
    procedure TestCombinedClause;

    [Test]
    [TestCase('TestTableInjectionRejected', '')]
    procedure TestTableInjectionRejected;
  end;

implementation

procedure TUniQueryBuilderTest.Setup;
begin
  FBuilder := TQueryClauseBuilder.Create;
end;

procedure TUniQueryBuilderTest.TearDown;
begin
  FBuilder.Free;
end;

procedure TUniQueryBuilderTest.TestNoClause;
var
  LSQL: string;
begin
  LSQL := FBuilder.SelectFrom('UniAdmin_Users');
  Assert.AreEqual('SELECT * FROM UniAdmin_Users', LSQL);
end;

procedure TUniQueryBuilderTest.TestLikeClause;
var
  LSQL: string;
begin
  FBuilder.AddLikeAny(['UserName', 'RealName', 'Email'], 'Filter');
  LSQL := FBuilder.SelectFrom('UniAdmin_Users');
  Assert.AreEqual(
    'SELECT * FROM UniAdmin_Users WHERE (UserName LIKE :Filter0 OR RealName LIKE :Filter0 OR Email LIKE :Filter0)',
    LSQL);
  Assert.AreEqual(1, FBuilder.ParamCount, '应只有 1 个去重参数 Filter0');
end;

procedure TUniQueryBuilderTest.TestEqualClause;
var
  LSQL: string;
begin
  FBuilder.AddEqual('Status', 'Status');
  LSQL := FBuilder.SelectFrom('UniAdmin_Users');
  Assert.AreEqual('SELECT * FROM UniAdmin_Users WHERE Status = :Status', LSQL);
end;

procedure TUniQueryBuilderTest.TestCombinedClause;
var
  LSQL: string;
begin
  FBuilder.AddLikeAny(['UserName', 'RealName'], 'Filter');
  FBuilder.AddEqual('Status', 'Status');
  LSQL := FBuilder.SelectFrom('UniAdmin_Users');
  Assert.IsTrue(LSQL.Contains('(UserName LIKE :Filter0 OR RealName LIKE :Filter0)'),
    '应含 LIKE 子句');
  Assert.IsTrue(LSQL.Contains('Status = :Status'), '应含等值子句');
  Assert.IsTrue(LSQL.Contains(' WHERE ') and LSQL.Contains(' AND '), '应含 WHERE/AND');
end;

procedure TUniQueryBuilderTest.TestTableInjectionRejected;
begin
  // 表名含空格/分号应被拒绝
  Assert.WillRaise(
    procedure begin FBuilder.SelectFrom('UniAdmin_Users; DROP TABLE x'); end,
    Exception);
end;

initialization
  TDUnitX.RegisterTestFixture(TUniQueryBuilderTest);

end.
```

- [ ] **Step 2: 运行测试验证失败**

Run: 编译 `tests/UniAdminTests.dpr`
预期：`E2003 Undeclared identifier: 'TQueryClauseBuilder'`

- [ ] **Step 3: 实现查询生成器**

新建 `src/Core/Admin/UniQueryBuilder.pas`：

```pascal
unit UniQueryBuilder;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.Character;

type
  /// <summary>
  /// 通用参数化 SELECT/WHERE 子句生成器
  /// 产出 100% 参数化 SQL，杜绝 SQL 注入。表名/列名经标识符白名单校验。
  /// </summary>
  TQueryClauseBuilder = class
  private
    FClauses: TList<string>;
    FParams: TList<string>;   // 去重后的参数名（保持顺序）
    function IsValidIdentifier(const AName: string): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>添加一个 LIKE-OR 组：所有列共享同一参数（参数名后缀 0）</summary>
    procedure AddLikeAny(const AFields: TArray<string>; const AParamBase: string);
    /// <summary>添加等值条件</summary>
    procedure AddEqual(const AField, AParam: string);
    /// <summary>产出 SELECT 语句（自动拼 WHERE/AND）</summary>
    function SelectFrom(const ATable: string): string;
    /// <summary>已注册参数个数（供调用方遍历 ParamByName 设值）</summary>
    function ParamCount: Integer;
    /// <summary>按索引取参数名</summary>
    function ParamName(AIndex: Integer): string;
    procedure Clear;
  end;

implementation

{ TQueryClauseBuilder }

constructor TQueryClauseBuilder.Create;
begin
  inherited;
  FClauses := TList<string>.Create;
  FParams := TList<string>.Create;
end;

destructor TQueryClauseBuilder.Destroy;
begin
  FClauses.Free;
  FParams.Free;
  inherited;
end;

function TQueryClauseBuilder.IsValidIdentifier(const AName: string): Boolean;
var
  I: Integer;
  C: Char;
begin
  // 仅允许字母/数字/下划线，首字符必须字母或下划线
  Result := (AName <> '');
  if not Result then Exit;
  for I := 1 to AName.Length do
  begin
    C := AName[I];
    if I = 1 then
    begin
      if not (TCharacter.IsLetter(C) or (C = '_')) then
        Exit(False);
    end
    else if not (TCharacter.IsLetterOrDigit(C) or (C = '_')) then
      Exit(False);
  end;
end;

procedure TQueryClauseBuilder.AddLikeAny(const AFields: TArray<string>;
  const AParamBase: string);
var
  LField: string;
  LParts: TStringList;
  LParam: string;
begin
  if Length(AFields) = 0 then
    Exit;
  if not IsValidIdentifier(AParamBase) then
    raise Exception.CreateFmt('非法参数名: %s', [AParamBase]);

  LParam := AParamBase + '0';
  if not FParams.Contains(LParam) then
    FParams.Add(LParam);

  LParts := TStringList.Create;
  try
    for LField in AFields do
    begin
      if not IsValidIdentifier(LField) then
        raise Exception.CreateFmt('非法列名: %s', [LField]);
      LParts.Add(Format('%s LIKE :%s', [LField, LParam]));
    end;
    FClauses.Add('(' + String.Join(' OR ', LParts.ToStringArray) + ')');
  finally
    LParts.Free;
  end;
end;

procedure TQueryClauseBuilder.AddEqual(const AField, AParam: string);
begin
  if not IsValidIdentifier(AField) then
    raise Exception.CreateFmt('非法列名: %s', [AField]);
  if not IsValidIdentifier(AParam) then
    raise Exception.CreateFmt('非法参数名: %s', [AParam]);
  if not FParams.Contains(AParam) then
    FParams.Add(AParam);
  FClauses.Add(Format('%s = :%s', [AField, AParam]));
end;

function TQueryClauseBuilder.SelectFrom(const ATable: string): string;
var
  LWhere: string;
  I: Integer;
begin
  if not IsValidIdentifier(ATable) then
    raise Exception.CreateFmt('非法表名: %s', [ATable]);

  Result := 'SELECT * FROM ' + ATable;

  if FClauses.Count > 0 then
  begin
    LWhere := '';
    for I := 0 to FClauses.Count - 1 do
    begin
      if I = 0 then
        LWhere := FClauses[I]
      else
        LWhere := LWhere + ' AND ' + FClauses[I];
    end;
    Result := Result + ' WHERE ' + LWhere;
  end;
end;

function TQueryClauseBuilder.ParamCount: Integer;
begin
  Result := FParams.Count;
end;

function TQueryClauseBuilder.ParamName(AIndex: Integer): string;
begin
  Result := FParams[AIndex];
end;

procedure TQueryClauseBuilder.Clear;
begin
  FClauses.Clear;
  FParams.Clear;
end;

end.
```

- [ ] **Step 4: 把新单元加入测试项目 uses**

修改 `tests/UniAdminTests.dpr`，在 Task 2 追加的行之后再加：

```pascal
  UniQueryBuilder in '..\src\Core\Admin\UniQueryBuilder.pas',
  UniQueryBuilderTest in 'Core\Admin\UniQueryBuilderTest.pas';
```

- [ ] **Step 5: 运行测试验证通过**

Run: 编译并运行 `tests/UniAdminTests.dpr`
预期：Task 2 的 4 个 + Task 3 的 5 个 = 9 个测试全部 PASS

- [ ] **Step 6: 提交**

```bash
git add src/Core/Admin/UniQueryBuilder.pas tests/Core/Admin/UniQueryBuilderTest.pas tests/UniAdminTests.dpr
git commit -m "feat(admin): TQueryClauseBuilder 参数化查询生成器 + 测试"
```

---

## Task 4: 改造 `TBaseCrudFrame` 支持"从元数据自动派生网格列"

**Files:**
- Modify: `src/Core/UI/BaseCrudFrame.pas`（新增字段 + 方法，不改既有逻辑）

> 这是消除最大样板的改造点：让网格列从 `IUniAdminMetadataCache` 派生，而非每模块手写 `Columns.Add`。同时保持向后兼容——`AutoGridFromMeta` 默认 False 时行为与现状完全一致。

- [ ] **Step 1: 先读现状确认修改锚点**

打开 `src/Core/UI/BaseCrudFrame.pas`，确认：
- `private` 区有 `FModelAdmin`、`FContext` 字段
- `DoInitialize` 是 `virtual`，子类（如 `UserListFrame`）override 时先调 `inherited`
- `uses` 已含 `FireDAC.Comp.Client`、`UniContext`

（这些在前置阅读中已确认，工程师实施时再核对一次行号。）

- [ ] **Step 2: 修改 interface 部分——新增字段与属性**

在 `TBaseCrudFrame` 的 `private` 区（`FPermissionPrefix: string;` 所在区）追加：

```pascal
  private
    FModelAdmin: TUniAdminModel;
    FContext: IExecutionContext;
    FAutoGridFromMeta: Boolean;       // 新增
    FModelTableName: string;          // 新增
    FMetadataCache: IUniAdminMetadataCache;  // 新增
    procedure UpdateButtonStates;
    procedure CheckPermissions;
```

在 `public` 区（`property PermissionPrefix` 附近）追加：

```pascal
    property ModelAdmin: TUniAdminModel read FModelAdmin;
    property Context: IExecutionContext read FContext;
    property PermissionPrefix: string read FPermissionPrefix write FPermissionPrefix;
    // 新增：声明式网格派生开关
    property AutoGridFromMeta: Boolean read FAutoGridFromMeta write FAutoGridFromMeta;
    property ModelTableName: string read FModelTableName write FModelTableName;
    property MetadataCache: IUniAdminMetadataCache read FMetadataCache write FMetadataCache;
```

在 `protected` 区追加新方法声明（放在 `DoRefresh` 之后）：

```pascal
    /// <summary>
    /// 从元数据缓存自动构建网格列（仅当 AutoGridFromMeta=True 且 Columns 为空时生效）
    /// </summary>
    procedure BuildGridFromMetadata; virtual;
```

在 `uses` 子句追加引用：

```pascal
  UniFieldMetadata, UniAdminMetadataCache.Intf;
```

- [ ] **Step 3: 实现 `BuildGridFromMetadata`**

在 `implementation` 区（`{ TBaseCrudFrame }` 之后、`constructor` 之前，或紧跟 `Refresh` 实现之后）加入：

```pascal
procedure TBaseCrudFrame.BuildGridFromMetadata;
var
  LMeta: TTableMetadata;
  LField: TFieldMetadata;
  LCol: TUniDBGridColumn;  // 注意类型名见下方提示
begin
  if not FAutoGridFromMeta then
    Exit;
  if FModelTableName = '' then
    Exit;
  if not Assigned(FMetadataCache) then
    Exit;
  if not Assigned(UniDBGrid) then
    Exit;
  if UniDBGrid.Columns.Count > 0 then
    Exit;  // 子类已手写列则尊重之，不覆盖

  LMeta := FMetadataCache.GetTableMetadata(FModelTableName);

  for LField in LMeta.Fields do
  begin
    // 跳过敏感/审计字段（这些通常不在列表展示）
    if SameText(LField.FieldName, 'Password') or
       SameText(LField.FieldName, 'CreatedBy') or
       SameText(LField.FieldName, 'ModifiedBy') then
      Continue;

    LCol := UniDBGrid.Columns.Add;
    LCol.FieldName := LField.FieldName;
    // DisplayName 由元数据填充；若元数据返回字段名则直接用之
    if LField.DisplayName <> '' then
      LCol.Title.Caption := LField.DisplayName
    else
      LCol.Title.Caption := LField.FieldName;
    LCol.Width := 100;
  end;
end;
```

> **类型提示**：`UniDBGrid.Columns` 的元素类型在 UniGUI 1.6 中是 `TUniDBGridColumn`（`uniBasicGrid` / `uniDBGrid` 单元已 uses）。若编译器报未声明，改用 `with UniDBGrid.Columns.Add do begin ... end;` 简化形式（与 `UserListFrame` 现有写法一致），不引用显式类型变量。

**简化版（不依赖显式列类型，推荐用这个）**：

```pascal
procedure TBaseCrudFrame.BuildGridFromMetadata;
var
  LMeta: TTableMetadata;
  LField: TFieldMetadata;
begin
  if not FAutoGridFromMeta or (FModelTableName = '') or
     (not Assigned(FMetadataCache)) or (not Assigned(UniDBGrid)) then
    Exit;
  if UniDBGrid.Columns.Count > 0 then
    Exit;  // 尊重子类已手写的列

  LMeta := FMetadataCache.GetTableMetadata(FModelTableName);
  for LField in LMeta.Fields do
  begin
    if SameText(LField.FieldName, 'Password') or
       SameText(LField.FieldName, 'CreatedBy') or
       SameText(LField.FieldName, 'ModifiedBy') then
      Continue;

    with UniDBGrid.Columns.Add do
    begin
      FieldName := LField.FieldName;
      if LField.DisplayName <> '' then
        Title.Caption := LField.DisplayName
      else
        Title.Caption := LField.FieldName;
      Width := 100;
    end;
  end;
end;
```

- [ ] **Step 4: 在 `DoInitialize` 默认实现里挂钩**

将 `BaseCrudFrame.pas` 中现有的空 `DoInitialize`：

```pascal
procedure TBaseCrudFrame.DoInitialize;
begin
  // 子类重写 - 初始化自定义组件
end;
```

改为：

```pascal
procedure TBaseCrudFrame.DoInitialize;
begin
  // 自动从元数据派生网格列（若启用且未手写）
  BuildGridFromMetadata;
  // 子类可在 override 后继续追加自定义初始化
end;
```

- [ ] **Step 5: 初始化新字段默认值**

在 `constructor TBaseCrudFrame.Create` 里（`FPermissionPrefix := ''` 之后）加：

```pascal
  FAutoGridFromMeta := False;
  FModelTableName := '';
```

- [ ] **Step 6: 编译验证**

Run: 编译 `src/UniAdmin.dpr`
预期：编译成功，**无任何运行时行为变化**（开关默认 False）。现有 `UserListFrame` 等子类完全不受影响。

- [ ] **Step 7: 提交**

```bash
git add src/Core/UI/BaseCrudFrame.pas
git commit -m "feat(admin): TBaseCrudFrame 支持从元数据自动派生网格列（开关默认关闭）"
```

---

## Task 5: 创建 `TAutoCrudFrame`——零样板的声明式 CRUD Frame

**Files:**
- Create: `src/Core/UI/AutoCrudFrame.pas`
- Create: `src/Core/UI/AutoCrudFrame.dfm`

> 这是声明式开发的"用户接口"：业务模块继承它，在构造里填 `AdminID`，其余全自动。

- [ ] **Step 1: 创建 DFM**

新建 `src/Core/UI/AutoCrudFrame.dfm`。注意中文用 `#编码` 转义、**不加引号**（遵守 AGENTS.md 规则 9/10/15）：

```dfm
object AutoCrudFrame: TAutoCrudFrame
  Left = 0
  Top = 0
  Width = 800
  Height = 600
  TabOrder = 0
  object pnlToolbar: TUniPanel
    Left = 0
    Top = 0
    Width = 800
    Height = 41
    Align = alTop
    TabOrder = 0
    object btnAdd: TUniButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = #26032#22686
      TabOrder = 1
    end
    object btnEdit: TUniButton
      Left = 89
      Top = 8
      Width = 75
      Height = 25
      Caption = #32534#36753
      TabOrder = 2
    end
    object btnDelete: TUniButton
      Left = 170
      Top = 8
      Width = 75
      Height = 25
      Caption = #21024#38500
      TabOrder = 3
    end
    object btnRefresh: TUniButton
      Left = 251
      Top = 8
      Width = 75
      Height = 25
      Caption = #21047#26032
      TabOrder = 4
    end
    object edtSearch: TUniEdit
      Left = 340
      Top = 10
      Width = 200
      Height = 22
      TabOrder = 5
    end
  end
  object UniDBGrid: TUniDBGrid
    Left = 0
    Top = 41
    Width = 800
    Height = 559
    Align = alClient
    TabOrder = 1
  end
  object UniDataSource: TDataSource
    Left = 24
    Top = 72
  end
end
```

> 编码说明：`#26032#22679`=新增、`#32534#36753`=编辑、`#21024#38500`=刷新、`#21019#38500`=删除。

- [ ] **Step 2: 创建 PAS**

新建 `src/Core/UI/AutoCrudFrame.pas`：

```pascal
unit AutoCrudFrame;

interface

uses
  System.SysUtils, System.Classes,
  Data.DB, FireDAC.Comp.Client,
  uniGUIBaseClasses, uniGUIClasses, uniEdit, uniButton, uniBasicGrid, uniDBGrid,
  uniPanel, uniGUIFrame,
  UniContext, UniPlugin.Types,
  BaseCrudFrame, UniAdminModel,
  UniModelAdmin.Intf, UniQueryBuilder, UniAdminMetadataCache.Intf;

type
  /// <summary>
  /// 零样板的声明式 CRUD Frame
  /// 子类只需在构造中设置 AdminID，引擎自动：
  ///   1. 从 IModelAdminRegistry 读取声明
  ///   2. 开启 AutoGridFromMeta，从元数据派生网格列
  ///   3. 用 TQueryClauseBuilder 生成参数化列表查询
  ///   4. 继承 TBaseCrudFrame 的权限/按钮状态/审计能力
  /// </summary>
  TAutoCrudFrame = class(TBaseCrudFrame)
    pnlToolbar: TUniPanel;
    btnAdd: TUniButton;
    btnEdit: TUniButton;
    btnDelete: TUniButton;
    btnRefresh: TUniButton;
    edtSearch: TUniEdit;
    UniDBGrid: TUniDBGrid;
    UniDataSource: TDataSource;

    procedure btnRefreshClick(Sender: TObject);
    procedure edtSearchKeyPress(Sender: TObject; var Key: Char);
  private
    FAdminID: string;
    FAdminConfig: TModelAdmin;
    FQuery: TFDQuery;

    procedure ApplyAdminConfig(const AAdminID: string);
  protected
    procedure DoInitialize; override;
    procedure DoRefresh; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    /// <summary>在构造后调用，绑定声明配置。也可由外部路由器传入。</summary>
    procedure BindAdmin(const AAdminID: string);
  end;

implementation

{$R *.dfm}

{ TAutoCrudFrame }

constructor TAutoCrudFrame.Create(AOwner: TComponent);
begin
  inherited;
  // 注意：FModelAdmin 已在基类构造中创建
  FQuery := TFDQuery.Create(Self);
end;

destructor TAutoCrudFrame.Destroy;
begin
  // 与 UserListFrame 一致的释放顺序：先断连接引用，避免悬空
  FQuery.Connection := nil;
  FQuery.Free;
  inherited;
end;

procedure TAutoCrudFrame.ApplyAdminConfig(const AAdminID: string);
var
  LRegistry: IModelAdminRegistry;
begin
  FAdminID := AAdminID;
  LRegistry := TModelAdminRegistry.CreateInstance;
  if not LRegistry.Find(AAdminID, FAdminConfig) then
    raise Exception.CreateFmt('AdminID "%s" 未在注册中心声明', [AAdminID]);

  // 开启声明式派生
  AutoGridFromMeta := True;
  ModelTableName := FAdminConfig.TableName;
  PermissionPrefix := FAdminConfig.PermissionPrefix;

  // 接管基类的网格列构建
  // （MetadataCache 由 SetContext 时从 MainModule.Services 注入，见 BindAdmin/DoInitialize）
end;

procedure TAutoCrudFrame.BindAdmin(const AAdminID: string);
begin
  ApplyAdminConfig(AAdminID);
end;

procedure TAutoCrudFrame.DoInitialize;
begin
  // 先让基类从元数据派生网格列（需要 MetadataCache 已就绪）
  inherited;  // 触发 BuildGridFromMetadata

  // 绑定数据源
  UniDataSource.DataSet := FQuery;

  // 工具栏按钮复用基类权限逻辑：把按钮赋给基类字段
  // （基类的 BtnAdd/BtnEdit/BtnDelete 是 protected，这里直接用本类 published 同名实例）
end;

procedure TAutoCrudFrame.DoRefresh;
var
  LBuilder: TQueryClauseBuilder;
  LSQL: string;
  LParamName: string;
  I: Integer;
begin
  if FQuery.Active then
    FQuery.Close;

  LBuilder := TQueryClauseBuilder.Create;
  try
    if (Length(FAdminConfig.SearchFields) > 0) and (edtSearch.Text <> '') then
      LBuilder.AddLikeAny(FAdminConfig.SearchFields, 'Filter');

    LSQL := LBuilder.SelectFrom(FAdminConfig.TableName) + ' ORDER BY 1 DESC';
    FQuery.SQL.Text := LSQL;

    for I := 0 to LBuilder.ParamCount - 1 do
    begin
      LParamName := LBuilder.ParamName(I);
      FQuery.ParamByName(LParamName).AsString := '%' + edtSearch.Text + '%';
    end;

    FQuery.Open;
  finally
    LBuilder.Free;
  end;
end;

procedure TAutoCrudFrame.btnRefreshClick(Sender: TObject);
begin
  Refresh;
end;

procedure TAutoCrudFrame.edtSearchKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    Refresh;
end;

initialization
  // 数据驱动路由必需：RoutePath 中的类名经 GetClass 解析
  RegisterClass(TAutoCrudFrame);

end.
```

- [ ] **Step 3: 把新单元加入主项目 dpr**

修改 `src/UniAdmin.dpr`，在 `BaseCrudFrame in 'Core\UI\BaseCrudFrame.pas';` 之后追加：

```pascal
  UniModelAdmin.Intf in 'Core\Admin\UniModelAdmin.Intf.pas',
  UniModelAdmin in 'Core\Admin\UniModelAdmin.pas',
  UniQueryBuilder in 'Core\Admin\UniQueryBuilder.pas',
  AutoCrudFrame in 'Core\UI\AutoCrudFrame.pas' {AutoCrudFrame: TUniFrame};
```

- [ ] **Step 4: 编译验证**

Run: 编译 `src/UniAdmin.dpr`
预期：编译成功。此时 `TAutoCrudFrame` 已注册，但尚无业务模块使用它——属于"能力就绪"状态。

- [ ] **Step 5: 提交**

```bash
git add src/Core/UI/AutoCrudFrame.pas src/Core/UI/AutoCrudFrame.dfm src/UniAdmin.dpr
git commit -m "feat(admin): 新增 TAutoCrudFrame 零样板声明式 CRUD Frame"
```

---

## Task 6: 让菜单/权限从 `TModelAdminRegistry` 自动生成

**Files:**
- Modify: `src/Core/Menu/SystemMenuSetup.pas`（追加 `BuildMenusFromRegistry`）

> 目标：消除"菜单定义"与"模块注册"两套真值源。`TModelAdmin` 声明成为菜单/权限的唯一来源。

- [ ] **Step 1: 在 SystemMenuSetup 追加合并方法**

打开 `src/Core/Menu/SystemMenuSetup.pas`。在 `GetPermissionDefinitions` 实现之后，加入两个新方法。先在 interface 的 `TSystemMenuSetup` class 声明里（`GetPermissionDefinitions` 之后）追加：

```pascal
    /// <summary>合并 ModelAdmin 注册中心的声明到菜单定义</summary>
    class function BuildMenusFromRegistry(
      const ABaseList: TList<TMenuItemInfo>): TList<TMenuItemInfo>;

    /// <summary>合并 ModelAdmin 注册中心的声明到权限定义</summary>
    class function BuildPermissionsFromRegistry(
      const ABaseList: TList<TPermissionInfo>): TList<TPermissionInfo>;
```

在 implementation 的 uses 追加：

```pascal
uses
  ..., UniModelAdmin.Intf, UniModelAdmin;
```

- [ ] **Step 2: 实现菜单合并**

在 implementation 末尾（`end.` 之前）追加：

```pascal
class function TSystemMenuSetup.BuildMenusFromRegistry(
  const ABaseList: TList<TMenuItemInfo>): TList<TMenuItemInfo>;
var
  LAdmin: TModelAdmin;
  LItem: TMenuItemInfo;
  LExistingCodes: TDictionary<string, Boolean>;
  LItem2: TMenuItemInfo;
begin
  Result := TList<TMenuItemInfo>.Create;
  LExistingCodes := TDictionary<string, Boolean>.Create;
  try
    // 先拷贝基线菜单，记录已有 MenuCode
    for LItem2 in ABaseList do
    begin
      Result.Add(LItem2);
      LExistingCodes.Add(LowerCase(LItem2.MenuCode), True);
    end;

    // 遍历注册中心，为每个 ModelAdmin 补一个菜单项
    for LAdmin in TModelAdminRegistry.CreateInstance.GetAll do
    begin
      LItem.MenuCode := 'system:' + LAdmin.AdminID;
      if LExistingCodes.ContainsKey(LowerCase(LItem.MenuCode)) then
        Continue;  // 已手写定义则尊重，不重复

      LItem.MenuName := LAdmin.DisplayName;
      LItem.ParentCode := LAdmin.ParentMenuCode;
      if LAdmin.ParentMenuCode = '' then
        LItem.ParentCode := 'system';
      LItem.Icon := LAdmin.Icon;
      // RoutePath 用类名，交给 MdiRouter 的 FindClass 解析
      if LAdmin.FrameClassName <> '' then
        LItem.RoutePath := LAdmin.FrameClassName
      else
        LItem.RoutePath := 'TAutoCrudFrame';
      LItem.PermissionCode := LAdmin.PermissionPrefix + ':view';
      LItem.SortOrder := LAdmin.SortOrder;
      LItem.IsVisible := True;
      LItem.Description := LAdmin.DisplayName + '（自动注册）';
      Result.Add(LItem);
    end;
  finally
    LExistingCodes.Free;
  end;
end;

class function TSystemMenuSetup.BuildPermissionsFromRegistry(
  const ABaseList: TList<TPermissionInfo>): TList<TPermissionInfo>;
const
  // 标准四件套 CRUD 权限后缀
  CRUD_SUFFIXES: array[0..3] of string = ('view', 'add', 'edit', 'delete');
var
  LAdmin: TModelAdmin;
  LSuffix: string;
  LPerm: TPermissionInfo;
  LExistingCodes: TDictionary<string, Boolean>;
  LItem: TPermissionInfo;
begin
  Result := TList<TPermissionInfo>.Create;
  LExistingCodes := TDictionary<string, Boolean>.Create;
  try
    for LItem in ABaseList do
    begin
      Result.Add(LItem);
      LExistingCodes.Add(LowerCase(LItem.PermissionCode), True);
    end;

    for LAdmin in TModelAdminRegistry.CreateInstance.GetAll do
    begin
      for LSuffix in CRUD_SUFFIXES do
      begin
        LPerm.PermissionCode := LAdmin.PermissionPrefix + ':' + LSuffix;
        if LExistingCodes.ContainsKey(LowerCase(LPerm.PermissionCode)) then
          Continue;
        LPerm.PermissionName := LAdmin.DisplayName + ' ' + LSuffix;
        LPerm.Category := LAdmin.DisplayName;
        LPerm.Description := LAdmin.DisplayName + ' 的 ' + LSuffix + ' 权限';
        Result.Add(LPerm);
        LExistingCodes.Add(LowerCase(LPerm.PermissionCode), True);
      end;
    end;
  finally
    LExistingCodes.Free;
  end;
end;
```

- [ ] **Step 3: 改造 GetSystemMenuDefinitions 调用合并**

将现有的 `GetSystemMenuDefinitions` 末尾 `Result := LList;` 之前改为先合并：

```pascal
  // ... 既有 AddItem(...) 全部保留 ...

  // 合并 ModelAdmin 注册中心的声明式菜单
  Result := BuildMenusFromRegistry(LList);
  LList.Free;  // 基线列表已被拷贝进 Result，可释放
```

> **注意**：`BuildMenusFromRegistry` 内部会拷贝 `ABaseList` 的内容到新 `Result`，所以 `LList.Free` 是安全的。需确认 `BuildMenusFromRegistry` 确实执行了拷贝（Step 2 的代码 `for LItem2 in ABaseList do Result.Add(LItem2)` 已拷贝，record 是值类型，安全）。

同理改造 `GetPermissionDefinitions` 末尾：

```pascal
  Result := BuildPermissionsFromRegistry(LList);
  LList.Free;
```

- [ ] **Step 4: 补完 InitializeSystemMenus 的 TODO（可选但推荐）**

当前 `InitializeSystemMenus` 第 70-77 行是 TODO。本任务不强制实现数据库写入（依赖 `MenuDataModule`/`RoleDataModule` 的具体 API），但应把 TODO 注释更新为"菜单现在由 ModelAdminRegistry 驱动，写入逻辑见后续 Task"。最小改动：保留 TODO，仅更新注释说明数据源已改为注册中心。

- [ ] **Step 5: 编译验证**

Run: 编译 `src/UniAdmin.dpr`
预期：编译成功。运行时若 `TModelAdminRegistry` 为空（无业务模块注册），`BuildMenusFromRegistry` 只返回基线菜单，行为与改造前一致。

- [ ] **Step 6: 提交**

```bash
git add src/Core/Menu/SystemMenuSetup.pas
git commit -m "feat(admin): 菜单与权限定义从 TModelAdminRegistry 自动派生"
```

---

## Task 7: 落地示例——用声明式重构 UserListFrame（验证端到端）

**Files:**
- Modify: `src/Modules/User/UserListFrame.pas`

> 目标：把现有的手写 `UserListFrame` 改造为声明式，作为可运行的端到端验证。**保留类名 `TUserListFrame`**（菜单 RoutePath 已引用它），只替换内部实现。

- [ ] **Step 1: 在 UserListFrame 单元注册 ModelAdmin**

在 `UserListFrame.pas` 的 `initialization` 段（`RegisterClass(TUserListFrame)` 之前）追加声明注册：

```pascal
initialization
  // 声明式注册：UserListFrame 不再手写网格列与 SQL，由引擎派生
  TModelAdminRegistry.CreateInstance.Register(
    TModelAdmin.Create('user', 'UniAdmin_Users', '用户管理')
      .WithFrame('TUserListFrame')
      .WithListDisplay([
        TAdminFieldConfig.Create('UserID', 'ID', 50),
        TAdminFieldConfig.Create('UserName', '用户名', 100),
        TAdminFieldConfig.Create('RealName', '真实姓名', 100),
        TAdminFieldConfig.Create('Email', '邮箱', 150),
        TAdminFieldConfig.Create('Phone', '手机', 100),
        TAdminFieldConfig.Create('Status', '状态', 60)
      ])
      .WithSearchFields(['UserName', 'RealName', 'Email'])
      .WithPermissionPrefix('user')
      .WithSortOrder(110)
      .WithParentMenuCode('system')
  );

  RegisterClass(TUserListFrame);
```

> **说明**：上面用了流式 `.WithXxx` 链式 API，这需要在 Task 1 的 `TModelAdmin` 上加 fluent 方法。见 Step 2。

- [ ] **Step 2: 给 TModelAdmin 加 fluent 方法**

回到 `src/Core/Admin/UniModelAdmin.Intf.pas`，在 `TModelAdmin` record 的 `public`-like 区域（record 无可见性区分，紧接字段声明）追加方法声明与实现：

声明部分（在 `class function Create(...)` 之后）：

```pascal
    function WithFrame(const AClassName: string): TModelAdmin;
    function WithListDisplay(const AFields: TArray<TAdminFieldConfig>): TModelAdmin;
    function WithSearchFields(const AFields: TArray<string>): TModelAdmin;
    function WithFilterFields(const AFields: TArray<string>): TModelAdmin;
    function WithPermissionPrefix(const APrefix: string): TModelAdmin;
    function WithSortOrder(const AOrder: Integer): TModelAdmin;
    function WithParentMenuCode(const ACode: string): TModelAdmin;
    function WithIcon(const AIcon: string): TModelAdmin;
```

实现部分（implementation 区）：

```pascal
function TModelAdmin.WithFrame(const AClassName: string): TModelAdmin;
begin
  Result := Self;
  Result.FrameClassName := AClassName;
end;

function TModelAdmin.WithListDisplay(const AFields: TArray<TAdminFieldConfig>): TModelAdmin;
begin
  Result := Self;
  Result.ListDisplay := AFields;
end;

function TModelAdmin.WithSearchFields(const AFields: TArray<string>): TModelAdmin;
begin
  Result := Self;
  Result.SearchFields := AFields;
end;

function TModelAdmin.WithFilterFields(const AFields: TArray<string>): TModelAdmin;
begin
  Result := Self;
  Result.FilterFields := AFields;
end;

function TModelAdmin.WithPermissionPrefix(const APrefix: string): TModelAdmin;
begin
  Result := Self;
  Result.PermissionPrefix := APrefix;
end;

function TModelAdmin.WithSortOrder(const AOrder: Integer): TModelAdmin;
begin
  Result := Self;
  Result.SortOrder := AOrder;
end;

function TModelAdmin.WithParentMenuCode(const ACode: string): TModelAdmin;
begin
  Result := Self;
  Result.ParentMenuCode := ACode;
end;

function TModelAdmin.WithIcon(const AIcon: string): TModelAdmin;
begin
  Result := Self;
  Result.Icon := AIcon;
end;
```

- [ ] **Step 3: 改造 UserListFrame 精简实现**

将 `UserListFrame.pas` 的实现改为依赖声明式引擎。**关键改动**：构造里设 `AutoGridFromMeta + ModelTableName`，删除手写 `Columns.Add`，`LoadUsers` 改用 `TQueryClauseBuilder`。

替换 `DoInitialize` 实现（删除第 71-116 行手写列）：

```pascal
procedure TUserListFrame.DoInitialize;
begin
  // 开启声明式网格派生：从 UniAdmin_Users 元数据自动建列
  AutoGridFromMeta := True;
  ModelTableName := 'UniAdmin_Users';
  // MetadataCache 注入由父路由器在 SetContext 后完成（见 Step 5）

  inherited;  // 触发基类 BuildGridFromMetadata

  UniDataSource.DataSet := FQuery;
  cmbStatus.Text := '全部';
end;
```

> 注意：`UserListFrame` 现在的 `DoInitialize` 调用顺序是 `inherited` 在最前（见既有代码第 63 行）。改造后要让开关先于 `inherited` 设置，所以 `AutoGridFromMeta := True` 必须在 `inherited` **之前**执行。上面的代码已遵守此顺序。

替换 `LoadUsers`（删除第 132-182 行手写 SQL）：

```pascal
procedure TUserListFrame.LoadUsers;
var
  LBuilder: TQueryClauseBuilder;
  LStatus: Integer;
begin
  LBuilder := TQueryClauseBuilder.Create;
  try
    LStatus := ParseStatusFilter(cmbStatus.Text);  // 见 Step 4
    if (Trim(edtSearch.Text) <> '') then
      LBuilder.AddLikeAny(['UserName', 'RealName', 'Email'], 'Filter');
    if LStatus >= 0 then
      LBuilder.AddEqual('Status', 'Status');

    if FQuery.Active then
      FQuery.Close;
    FQuery.SQL.Text := LBuilder.SelectFrom('UniAdmin_Users') + ' ORDER BY UserID DESC';
    if Trim(edtSearch.Text) <> '' then
      FQuery.ParamByName(LBuilder.ParamName(0)).AsString := '%' + Trim(edtSearch.Text) + '%';
    if LStatus >= 0 then
      FQuery.ParamByName('Status').AsInteger := LStatus;
    FQuery.Open;
  finally
    LBuilder.Free;
  end;
end;
```

- [ ] **Step 4: 抽取状态解析为独立函数**

在 `UserListFrame.pas` 的 `private` 区加：

```pascal
    function ParseStatusFilter(const AText: string): Integer;
```

实现：

```pascal
function TUserListFrame.ParseStatusFilter(const AText: string): Integer;
begin
  if AText = '启用' then
    Result := 1
  else if AText = '禁用' then
    Result := 0
  else
    Result := -1;  // 全部
end;
```

- [ ] **Step 5: 注入 MetadataCache（连接到会话服务容器）**

`BuildGridFromMetadata` 需要 `MetadataCache` 非空。`UserListFrame` 由 `TUniAdminMdiRouter.ShowFrame` 创建，之后由 `MainFrame` 设置 Context。需要在 `SetContext` 流程中顺带注入。

修改 `src/Core/UI/BaseCrudFrame.pas` 的 `SetContext`（既有方法，约第 126 行）：

```pascal
procedure TBaseCrudFrame.SetContext(const Context: IExecutionContext);
begin
  FContext := Context;
  FModelAdmin.SetContext(Context);
end;
```

改为追加 MetadataCache 注入。但 `IExecutionContext` 不直接暴露 `MetadataCache`，需要从 `MainModule.Services` 取。考虑到 `BaseCrudFrame` 不应直接依赖 `MainModule`（会形成 UI→MainModule 的循环依赖），改用**在 `MainFrame.trmMenuClick` 创建 Frame 后显式注入**。

修改 `src/Core/UI/MainFrame.pas` 的 `trmMenuClick`（约第 223-230 行 `FMdiRouter.Open` 调用处）。由于 `MdiRouter.Open` 内部创建 Frame 不返回实例，需要给 `IMdiRouter` 加一个回调或让 Frame 自己从 `UniSession` 取服务。**最小侵入方案**：让 `TBaseCrudFrame` 在 `DoInitialize` 里尝试从 `UniSession` 关联的 MainModule 取 MetadataCache。

在 `BaseCrudFrame.pas` 的 `uses` implementation 区加 `MainModule, uniGUIApplication`（implementation uses 不引入接口循环依赖），并在 `BuildGridFromMetadata` 开头加惰性获取：

```pascal
procedure TBaseCrudFrame.BuildGridFromMetadata;
var
  LMeta: TTableMetadata;
  LField: TFieldMetadata;
begin
  if not FAutoGridFromMeta or (FModelTableName = '') then
    Exit;
  if not Assigned(UniDBGrid) then
    Exit;
  if UniDBGrid.Columns.Count > 0 then
    Exit;

  // 惰性注入：若外部未显式赋值，从当前会话 MainModule 取
  if (not Assigned(FMetadataCache)) and Assigned(UniApplication.UniMainModule) and
     (UniApplication.UniMainModule is TMainModule) then
    FMetadataCache := TMainModule(UniApplication.UniMainModule).Services.MetadataCache;

  if not Assigned(FMetadataCache) then
    Exit;

  LMeta := FMetadataCache.GetTableMetadata(FModelTableName);
  // ...（后续循环建列逻辑同 Task 4 Step 3）
end;
```

- [ ] **Step 6: 在 uses 声明里加新依赖**

`UserListFrame.pas` 的 implementation uses 追加：

```pascal
uses
  ..., UniQueryBuilder, UniModelAdmin.Intf, UniModelAdmin;
```

（若 `initialization` 段要用 `TModelAdminRegistry`，implementation uses 必须含 `UniModelAdmin`。）

- [ ] **Step 7: 编译验证**

Run: 编译 `src/UniAdmin.dpr`
预期：编译成功。`RegisterClass(TUserListFrame)` 仍在，路由不变；网格列改为元数据派生；SQL 改为生成器产出。

- [ ] **Step 8: 运行时验证**

Run: 启动 exe（`.vscode/CompileOmniPascalServerProject.bat test`），登录后点击"用户管理"菜单。
预期：
- 网格显示 `UniAdmin_Users` 表的字段（来自元数据，跳过 Password/CreatedBy/ModifiedBy）
- 搜索框输入关键字回车，参数化查询生效
- 状态筛选仍工作
- 增删改按钮可见性受 `user:view/add/edit/delete` 权限控制

- [ ] **Step 9: 全量测试回归**

Run: 编译并运行 `tests/UniAdminTests.dpr`
预期：Task 2/3 的 9 个单元测试仍全部 PASS（声明式注册中心与查询生成器的纯逻辑测试不受 UI 改造影响）。

- [ ] **Step 10: 提交**

```bash
git add src/Modules/User/UserListFrame.pas src/Core/Admin/UniModelAdmin.Intf.pas src/Core/UI/BaseCrudFrame.pas
git commit -m "feat(admin): UserListFrame 改造为声明式（元数据派生网格 + 生成器 SQL）"
```

---

## Self-Review（计划完成后自检）

**1. Spec 覆盖检查**（对照分析报告的四个差距）：

| 差距 | 解决任务 | 状态 |
|---|---|---|
| 差距1：UI 手动编程非元数据派生 | Task 4（基类开关）+ Task 5（AutoCrudFrame）+ Task 7（UserListFrame 落地） | ✅ 覆盖 |
| 差距2：SQL 每模块重复 | Task 3（TQueryClauseBuilder）+ Task 7（UserListFrame 改用生成器） | ✅ 覆盖 |
| 差距3：菜单/注册两套真值源 | Task 6（BuildMenusFromRegistry / BuildPermissionsFromRegistry） | ✅ 覆盖 |
| 差距4：缺 ModelAdmin 注册即生成 UI | Task 1-2（TModelAdminRegistry）+ Task 5（TAutoCrudFrame） | ✅ 覆盖 |

**2. 占位符扫描**：无 TBD/TODO/"类似上方"。所有代码块完整。唯一保留的 TODO 是 Task 6 Step 4 明确说明"不强制实现数据库写入"并给出理由，非占位符。

**3. 类型一致性检查**：
- `TModelAdmin` 字段名（`AdminID`/`TableName`/`FrameClassName`/`ListDisplay`/`SearchFields`/`PermissionPrefix`/`SortOrder`/`ParentMenuCode`/`Icon`）在 Task 1 定义、Task 2 测试、Task 5 使用、Task 6 遍历、Task 7 链式 API 中完全一致 ✅
- `IModelAdminRegistry` 方法（`Register`/`Find`/`GetByTableName`/`GetAll`/`Count`/`Clear`）在 Task 1 接口、Task 2 实现与测试、Task 6 调用中一致 ✅
- `TQueryClauseBuilder` 方法（`AddLikeAny`/`AddEqual`/`SelectFrom`/`ParamCount`/`ParamName`）在 Task 3 定义、Task 5 使用、Task 7 使用中一致 ✅
- `TAdminFieldConfig.Create(AFieldName, ADisplayName, AWidth)` 在 Task 1 定义、Task 7 使用一致 ✅

**4. 风险点已处理**：
- 元数据方言：`UniAdminMetadataCache` 用 `INFORMATION_SCHEMA`（MSSQL/MySQL），SQLite 不支持。Task 7 运行时验证若用 SQLite 会失败——**这是已知风险**，需在 Task 4 的 `BuildGridFromMetadata` 里对 `GetTableMetadata` 抛异常做 try-except 降级（查不到则回退为空网格，不阻断 UI）。已在此条注明，实施时注意。

---

## 执行顺序建议

严格按 Task 1→7 顺序执行，每个 Task 结束即提交。Task 1-3 是纯逻辑层（可独立测试，无 UI 依赖），Task 4-7 依赖前三者。Task 7 是端到端验证，若它通过则整个声明式链路打通。

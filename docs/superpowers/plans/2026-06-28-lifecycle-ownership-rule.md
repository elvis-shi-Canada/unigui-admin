# 生命周期所有权规则 + ORM 转型 Implementation Plan（B 路线）

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans. Steps use checkbox (`- [ ]`).

**Goal:** 走 **B 路线（DMVC ActiveRecord）**——用声明式 ORM（注解 + RTTI + 自动 SQL）消灭手写 CRUD 重复 + `TDataSet` 不自洽传播，让 UniAdmin 数据层对齐其 Django Admin 基因。

**Architecture:** DMVC ActiveRecord 实体（`[MVCTable]`/`[MVCTableField]` 注解 + RTTI 内省 + 自动 SQL）+ `UniAdmin_Pooled` 池化连接（Task 1.5）+ v2 生命周期规则（`TObjectList<T>` 所有权转移合规）。

**Tech Stack:** Delphi 12 Athens、UniGUI 1.6+、FireDAC、**DMVC ActiveRecord（d120 包）**、DUnitX。

## Global Constraints

- **路线**：B（DMVC ActiveRecord）。旧 A+ 路线（QuerySingle/QueryList + DTO 生成）**作废**，思路留存 `docs/superpowers/specs/2026-06-29-crud-paradigm-comparison.md`。
- **规则**：v2 精确边界（成员管理 / 所有权转移合规 / 禁止 `TDataSet` 不自洽句柄），权威文本 `CLAUDE.md` + spec §2。
- **DMVC 依赖**：`D:\BaiduNetdiskDownload\vcl\dmvcframework\packages\d120\dmvcframeworkRT.dpk`（Delphi 12 现成包）。
- **连接**：`UniAdmin_Pooled` 池化 con_def（Task 1.5 已建）。
- **编译**：`.vscode/CompileOmniPascalServerProject.bat build`。
- **不主动 git 提交**：commit 步骤为建议打点，实际由用户 `/ship` 工作流决定。

---

## File Structure

| 文件 | 责任 | 动作 |
|------|------|------|
| `CLAUDE.md` / `AGENTS.md` | v2 规则 | ✅ 已落盘 |
| `src/Core/Data/UniAdminConnectionManager.pas` | 池化连接 | ✅ 已改造（Task 1.5） |
| `src/UniAdmin.dpr` / `tests/UniAdminTests.dpr` | 项目入口 | Modify — 加 DMVC 单元 + 实体单元 |
| `src/Modules/*/Entities/` | ActiveRecord 实体 | Create — 每模块一个（TRole/TMenu/TUser/...） |
| `src/Modules/*/XxxService.pas` | 业务服务 | Modify — 改调 ActiveRecord |
| `src/Modules/*/XxxDataModule.pas` | 旧数据模块 | Modify/Remove — ActiveRecord 取代 |
| `tests/Modules/*.pas` | 测试 | Modify — 消费 ActiveRecord 对象 |

---

## Task 1: ✅ 已完成 — 立规矩（v2 精确边界）

规则已落盘 `CLAUDE.md`/`AGENTS.md`。详见 spec §2。

---

## Task 1.5: ✅ 已完成 — 连接池化（借鉴 BeeCloudERP）

`TUniAdminConnectionManager` 已接入 FireDAC 池化 con_def（`UniAdmin_Pooled`，`EnsurePooledConnDef` + `ConnectionDefName` + 池化 `ReleaseConnection`）。编译通过（仅 `CreateDefaultConnection` 未用 hint）。为 B 路线 con_def 集成铺路。

---

## Task 2: 🧪 DMVC 接入 PoC（命门验证）⭐

**目标**：验证 DMVC ActiveRecord 能在 UniGUI 会话里跑通 + 连接隔离。**这是 B 路线的命门，不过则回 A+。**

**Files:**
- Modify: `src/UniAdmin.dpr`（加 DMVC 单元到 uses）
- Modify: 项目 Library Path（d120 包）
- Create: `src/Modules/Role/Entities/RoleEntity.pas`（PoC 实体）
- Create: `tests/Modules/RoleActiveRecordPoC.pas`（PoC 测试）

- [ ] **Step 1: DMVC d120 包接入 Library Path**

在 IDE/项目选项加 Library Path：`D:\BaiduNetdiskDownload\vcl\dmvcframework\packages\d120\`（或先编译 `dmvcframeworkRT.dpk` 生成 dcu）。验证：新建空单元 `uses MVCFramework.ActiveRecord;` 能编译。

- [ ] **Step 2: 连接集成（ActiveRecord 接 UniAdmin_Pooled）**

DMVC ActiveRecord 走 `CurrentConnection`（per-thread registry + con_def 名）。在 ServerModule 启动或 MainModule OnCreate 注册：
```pascal
uses MVCFramework.ActiveRecord;
// 首次：把 Task 1.5 的池化 con_def 注册给 ActiveRecord
ActiveRecordConnectionsRegistry.AddDefaultConnection('UniAdmin_Pooled');
```
> 验证 `UniAdmin_Pooled` con_def 已由 `EnsurePooledConnDef` 创建（Task 1.5）。

- [ ] **Step 3: 定义 PoC 实体 `TRole`**

```pascal
unit RoleEntity;
interface
uses
  System.SysUtils,
  MVCFramework.ActiveRecord;
type
  [MVCTable('UniAdmin_Roles')]
  TRole = class(TMVCActiveRecord)
  strict private
    [MVCTableField('RoleID', [foPrimaryKey])] FRoleID: Integer;
    [MVCTableField('RoleCode', [])] FRoleCode: string;
    [MVCTableField('RoleName', [])] FRoleName: string;
    [MVCTableField('Status', [])] FStatus: Integer;
  private
    function GetRoleID: Integer;
    procedure SetRoleID(const Value: Integer);
    // ... 其余 property 读写
  public
    property RoleID: Integer read GetRoleID write SetRoleID;
    property RoleCode: string read FRoleCode write FRoleCode;
    property RoleName: string read FRoleName write FRoleName;
    property Status: Integer read FStatus write FStatus;
  end;
implementation
// GetRoleID/SetRoleID 等简单实现（或用 published 字段直曝）
end.
```

- [ ] **Step 4: PoC 测试 — GetByPK + Select 跑通**

```pascal
[Test] procedure TestActiveRecord_GetByPK;
var LRole: TRole;
begin
  LRole := TMVCActiveRecord.GetByPK<TRole>(1, False);
  try
    Assert.IsTrue(Assigned(LRole));
    Assert.IsTrue(LRole.RoleID = 1);
  finally
    LRole.Free;
  end;
end;

[Test] procedure TestActiveRecord_SelectList;
var LList: TObjectList<TRole>;
begin
  LList := TMVCActiveRecord.Select<TRole>('Status = :s', [1]);
  try
    Assert.IsTrue(LList.Count >= 0);
  finally
    LList.Free;
  end;
end;
```

- [ ] **Step 5: 会话隔离实测（命门核心）**

开 2 个并发 UniGUI 会话，各执行 `GetByPK<TRole>(1)`，确认：
- 两个会话拿到正确数据，**不串连接**（per-thread 隔离生效）
- 无连接泄漏 / 冲突异常

- [ ] **Step 6: PoC 评估决策**

- ✅ **通过** → 进 Task 3（正式接入）+ Task 4（样板推广）
- ❌ **失败**（连接串/隔离问题）→ 回 A+ 路线（见范式对比文档 §4）

---

## Task 3: DMVC 正式接入

**Files:** `src/UniAdmin.dpr`, `src/Core/Main/ServerModule.pas`（或 MainModule）

- [ ] **Step 1:** `UniAdmin.dpr` uses 加 DMVC 核心单元（`MVCFramework.ActiveRecord` 等）+ `RoleEntity`。
- [ ] **Step 2:** 启动时注册连接（`ActiveRecordConnectionsRegistry.AddDefaultConnection('UniAdmin_Pooled')`），放 ServerModule FirstInit 或 MainModule OnCreate（评估生命周期：每会话 vs 全局）。
- [ ] **Step 3:** 编译通过，确认 DMVC 单元链接正常。

---

## Task 4: 样板 — TRole 实体 + RoleService/RoleTest 改造（Recipe）

**Files:**
- Create: `src/Modules/Role/Entities/RoleEntity.pas`（Task 2 的 PoC 实体完善）
- Modify: `src/Modules/Role/RoleService.pas`（改调 ActiveRecord）
- Modify: `tests/Modules/RoleTest.pas`（消费对象，非 DataSet）

### 重构 Recipe（黄金模式，Task 5-9 复用）

把一个 `TDataSet` 返回方法改造为 ActiveRecord：

1. **定义实体**：`[MVCTable('表名')]` + `[MVCTableField('列名', [选项])]` 注解字段 + published 属性。
2. **查询**：`GetByPK<T>(id)` / `Select<T>(where, params)` 返回 `T` / `TObjectList<T>`（v2 合规所有权转移）。
3. **写入**：`LObj := T.Create; 设属性; LObj.Store`（自动 INSERT/UPDATE）；`LObj.Delete`。
4. **Service 改造**：去掉手写 SQL + DataSet 中转，直接调 ActiveRecord。
5. **测试改造**：`LDataSet.FieldByName` → `LObj.属性`，删 `LDataSet.Free`（用 `try-finally LObj.Free` / `LList.Free`）。

- [ ] **Step 1:** 完善 `TRole` 实体（字段对照 UniAdmin_Roles 表）。
- [ ] **Step 2:** RoleService 改造（GetRoleByID→`GetByPK<TRole>`，GetRoles→`Select<TRole>`，CreateRole→`TRole.Create+Store`，等）。
- [ ] **Step 3:** RoleTest 改造（消费对象，删 DataSet）。
- [ ] **Step 4:** 编译 + 测试全绿。
- [ ] **Step 5:** Commit。

---

## Task 5-9: 推广（Menu / User / Dictionary / Config / Log）

每模块一个 Task，套 Task 4 Recipe：

- **Task 5 — Menu**：`TMenu` 实体（`UniAdmin_Menus`）+ MenuService/MenuTest。注意 `GetMenuTree`（树形）→ Task 10 处理。
- **Task 6 — User**：`TUser` 实体（`UniAdmin_Users`）+ UserService/UserEditForm + 补 UserTest（无现成测试）。⚠️ UserService.pas(71) 有 pre-existing E2010（`CreateWithConnection(Self,...)`），本 Task 一并消除（ActiveRecord 取代 DataModule 后该调用消失）。
- **Task 7 — Dictionary**：`TDictType`/`TDictItem` 实体 + DictionaryService/DictionaryTest。
- **Task 8 — Config**：`TConfig` 实体 + ConfigService/ConfigTest。
- **Task 9 — Log**：`TLoginLog`/`TOperationLog`/`TDataChangeLog` 实体 + LogService/LogTest。LogExport 导出场景若需流式，用 `Select<T>(SQL)` 分页。

每 Task：定义实体 → Service 改调 ActiveRecord → 测试改消费对象 → 编译测试全绿 → Commit。

---

## Task 10: 复杂查询（Select<T> 原生 SQL）

ActiveRecord 的简单 CRUD 自动，但树形/统计/多表 JOIN 用 `Select<T>(SQL, params)`：

- [ ] **GetMenuTree / GetChildMenus**：`Select<TMenu>('ParentID = :p ORDER BY SortOrder', [PID])` + 调用方构建树（或保留 BuildMenuTree）。
- [ ] **GetRoleStats**：`Select<TRoleStats>('SELECT ... GROUP BY ...', [])` 或 `GetScalar`。
- [ ] **GetRoleUsers / GetRolePermissions**（多表 JOIN）：`Select<TUserRoleInfo>('SELECT ... FROM ... JOIN ...', [RoleID])`，定义投影实体。
- [ ] 编译 + 测试。

---

## Task 11: TUniAdminDataModule 退役 + 全量验证

- [ ] **Step 1:** 评估 `TUniAdminDataModule` 是否还有模块依赖（grep）；全转 ActiveRecord 后可退役或降级为纯连接持有。
- [ ] **Step 2:** grep 确认零 `TDataSet` 传播：
  `grep -nE "function T\w+\.\w+\([^)]*\): TDataSet" src/Modules/` → **0 命中**
- [ ] **Step 3:** 全量编译 + `UniAdminTests.exe` 全绿。
- [ ] **Step 4:** 验收对照 spec §8。
- [ ] **Step 5:** Commit 收尾。

```bash
git add -A
git commit -m "feat(data): B 路线落地——DMVC ActiveRecord 取代手写 CRUD，零 TDataSet 传播"
```

---

## 执行顺序与并行性

- Task 1 / 1.5 ✅ 已完成。
- **Task 2（PoC）是 B 路线命门，必须先过**；不过回 A+。
- Task 2 过 → Task 3（接入）→ Task 4（样板验证 Recipe）→ Task 5-9（推广，可部分并行）→ Task 10（复杂查询）→ Task 11（收尾）。
- Task 6（User）因 pre-existing E2010 + 无测试，单独串行重点 review。

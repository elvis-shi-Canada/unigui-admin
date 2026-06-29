# 生命周期所有权规则 与 ORM 转型 — 设计规格 (Spec)

> **日期**：2026-06-28（v2 规则）/ 2026-06-29（转 B 路线）
> **状态**：B 路线（DMVC ActiveRecord）— 驱动 `docs/superpowers/plans/2026-06-28-lifecycle-ownership-rule.md`
> **关联**：`2026-06-29-crud-paradigm-comparison.md`（范式对比 + B 决策依据）

---

## 1. 背景与问题

UniAdmin 数据访问层三套生命周期机制混用，且 DataModule 层大面积返回 `TDataSet`（不自洽资源句柄）。同时 CRUD **手写重复**（6 表 × ~6 方法 ≈ 36+ 手写 SQL），缺乏复用。

**两条改造主线**：
- **生命周期**：消灭 `TDataSet` 不自洽传播（v2 规则）
- **复用性**：消灭手写 CRUD 重复（走 DMVC ActiveRecord，B 路线）

详见范式对比文档 §2、§3。

---

## 2. 规则定义（v2 精确边界，✅ 已落盘 CLAUDE.md/AGENTS.md）

### 2.1 核心原则
每个对象实例必须有**唯一、明确的所有者**，由所有者负责释放。两条细则：
- **① 成员管理**：类的字段成员由该类自己释放（析构 Free 或 Owner 机制），不让外部代劳。
- **② 所有权转移（合法契约）**：方法返回自洽强类型对象（如 `TObjectList<T>` OwnsObjects=True），调用方 `try-finally Free`——**合规**。

### 2.2 禁止反模式
不得返回**不自洽资源句柄**（`TDataSet`/`TFDQuery`：连接依赖 + 销毁陷阱 LRN-20260626-003 + 契约隐晦）。

### 2.3 落地手段（四级优先）
1. 值类型/接口（record/`TArray<T>`/接口，零管理）
2. 显式所有权转移（`TObjectList<T>` OwnsObjects=True）
3. 成员管理（`TComponent` Owner 机制 / `TInterfacedObject` 析构 Free）
4. 借而不拥有（外部资源只引用不释放）

> 完整判定表见 `CLAUDE.md`「对象生命周期所有权规则（强制）」章节。

---

## 3. 技术方案：B 路线 — DMVC ActiveRecord（Delphi 版 Django ORM）

### 3.1 方案选型（为何走 B）
- UniAdmin UI 层已是 Django Admin 范式（`TUniAdminModel`+`TBaseCrudFrame`+元数据），数据层是缺口。
- Delphi 的"声明式+ORM" = **DMVC ActiveRecord**（注解 + RTTI + 自动 SQL），比 BeeCloudERP 模板方法先进一个时代，且契合基因。
- DMVC 返回 `TObjectList<T>`（OwnsObjects=True）= v2 规则的**合规所有权转移**，天然合规。

### 3.2 实体定义（声明式，借鉴 DMVC）
```pascal
[MVCTable('UniAdmin_Roles')]
TRole = class(TMVCActiveRecord)
strict private
  [MVCTableField('RoleID', [foPrimaryKey])] FRoleID: Integer;
  [MVCTableField('RoleCode', [])] FRoleCode: string;
  [MVCTableField('RoleName', [])] FRoleName: string;
  // ... 字段即声明，RTTI 内省自动映射 + 自动 SQL
published
  property RoleID: Integer read FRoleID write FRoleID;
  property RoleCode: string read FRoleCode write FRoleCode;
  property RoleName: string read FRoleName write FRoleName;
end;
```

### 3.3 CRUD 用法（ORM 自动，零手写 SQL）
```pascal
// 查询
LRole := TMVCActiveRecord.GetByPK<TRole>(1);     try ... finally LRole.Free;
LList := TMVCActiveRecord.Select<TRole>('Status = :s', [1]);  try ... finally LList.Free;
// 写入
LRole := TRole.Create; LRole.RoleCode := 'admin'; LRole.Store;  // 自动 INSERT/UPDATE
LRole.Delete;
```

### 3.4 连接集成（命门，PoC 验证）
DMVC ActiveRecord 走 `CurrentConnection`（per-thread registry + con_def 名）。Task 1.5 已建 `UniAdmin_Pooled` 池化 con_def，为 ActiveRecord 的 `AddDefaultConnection('UniAdmin_Pooled')` 集成铺路。PoC 需验证 UniGUI 会话隔离。

---

## 4. 重构策略（B 路线，渐进式）

| Task | 内容 | 状态/风险 |
|------|------|:---:|
| 1 | 立规矩（v2 精确边界） | ✅ 已完成 |
| 1.5 | 🔌 连接池化（借鉴 BeeCloudERP） | ✅ 代码完成，编译通过 |
| **2** | 🧪 **DMVC 接入 PoC**（d120 包 + 连接集成 + 1 实体跑通 + 会话隔离实测） | ⭐ 命门验证 |
| 3 | DMVC 正式接入（Library Path / dpr uses / FDConnectionDefs / 中间件） | 中 |
| 4 | 样板：`TRole` ActiveRecord 实体 + RoleService/RoleTest 改造 | 中 |
| 5-9 | 推广 Menu / User / Dictionary / Config / Log | 中-高 |
| 10 | 复杂查询（树形/统计/JOIN 用 `Select<T>(SQL)`） | 中 |
| 11 | `TUniAdminDataModule` 退役评估 + 全量验证 | 低 |

> 旧 A+ 路线（QuerySingle/QueryList Helper + DTO 代码生成 + DTO 重构）**作废**，由 B 路线取代。

---

## 5. 违规方法精确清单（待 ActiveRecord 取代）

- **RoleDataModule（7）**：GetRoleByID/ByCode/Roles/RoleUsers/UserRoles/RolePermissions/RoleStats
- **MenuDataModule（8）**：GetMenuByID/ByCode/Menus/Tree/ChildMenus/UserMenus/RoleMenus/Stats
- **DictionaryDataModule（7）**：GetDictTypeByID/ByCode/Types + GetDictItemByID/ByType/ByCode/AllItems
- **ConfigDataModule（4）**：GetConfigByID/ByKey/Configs/ByCategory
- **UserDataModule（3）**：GetUserByID/ByName/Users
- **LogExport**：待核实

B 路线下，这些 `GetXxx: TDataSet` 被 ActiveRecord 的 `GetByPK<T>`/`Select<T>`（返回 `T`/`TObjectList<T>`，v2 合规）取代。

---

## 6. 全局约束

- **语言/框架**：Delphi 12 Athens + UniGUI 1.6+ + FireDAC + **DMVC ActiveRecord（d120 包）**。
- **测试**：DUnitX；`TDUnitX.RegisterTestFixture`；`Assert.IsTrue/AreEqual`。
- **编译**：`.vscode/CompileOmniPascalServerProject.bat build`。
- **连接**：`UniAdmin_Pooled` 池化 con_def（Task 1.5）。
- **不破坏行为**：重构改数据访问方式，业务逻辑不变。
- **TDD**：每个 ActiveRecord 实体须有特征化测试；无测试模块先补。

---

## 7. 风险与回滚

| 风险 | 缓解 |
|------|------|
| DMVC 连接集成命门（per-thread + UniGUI 会话） | Task 2 PoC 先验证，失败则回 A+ 或混合 |
| DMVC 框架依赖（编译/部署/学习） | d120 现成包；分模块渐进 |
| 复杂查询（树形/统计/JOIN）ActiveRecord 不直接支持 | Task 10 用 `Select<T>(SQL, params)` 原生 SQL + 对象映射 |
| UniAdmin_Users 等表无 ORM 实体 | Task 4 样板验证模式后批量转 |

**回滚**：每 Task 独立 commit；Task 2 PoC 失败可整体回 A+（A+ plan 思路保留在范式对比文档）。

---

## 8. 验收标准

1. ✅ `CLAUDE.md`/`AGENTS.md` 含 v2 规则章节。
2. ✅ `TUniAdminConnectionManager` 池化（Task 1.5）。
3. `TMVCActiveRecord` 接入 UniAdmin，per-thread 连接隔离 PoC 通过。
4. `src/Modules` 下 `grep "function T\w+\.\w+\([^)]*\): TDataSet"` 返回 **0**。
5. 各业务模块用 ActiveRecord 实体（`GetByPK<T>`/`Select<T>`/`Store`），无手写 CRUD SQL。
6. 全量编译通过，`UniAdminTests.exe` 全绿。

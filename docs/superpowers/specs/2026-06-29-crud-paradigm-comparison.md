# BeeCloudERP 设计模式探索 与 CRUD 范式对比

> **日期**：2026-06-29
> **目的**：保存对 `D:\Code\Projects\BeeCloudERP`（同栈 Delphi+UniGUI ERP）的架构探索成果，对比三种 CRUD 范式（手写 / OOP 继承 / 元编程声明式），并记录"走 B 路线（DMVC ActiveRecord）"的决策依据。
> **关联**：`2026-06-28-lifecycle-ownership-rule-design.md`（v2 规则）、`2026-06-28-lifecycle-ownership-rule.md`（plan）

---

## 1. BeeCloudERP 设计模式探索

### 1.1 完整继承链（两条主线）

**DataModule 链（数据层复用核心）**：
```
TDataModule
└─ TdmBasic_Custom (libBasic_CustomD)            ← 字段可见性 / PriceVisible
   └─ TdmEditView_Custom (libEditView_CustomD)   ← ⭐ 批量操作核心（FireDAC 线，当前在用）
      │   qryMaster: TFDQuery（成员）
      │   lstDataset: TList（需保存 DataSet 注册表）
      │   fldKeyFieldName（通用主键字段名）
      │   doAddSaveList / doDeleteSaveList         ← 注册
      │   doOpenAllDataSet(sKeyFieldValue)         ← 通用打开（按主键参数化）
      │   doUpdateBatchDataSet / doCancelBatchDataSet  ← 通用批量提交/取消
      │   DataSetsModified (ChangeCount>0)         ← 脏数据检测
      │   钩子: doAddCalcField / doSetDataStyle (virtual)
      └─ TdmEntry_Custom (libEntry_CustomD)       ← 主从联动
         │   qryDetails: TFDQuery
         │   qryDetailsAfterInsert: 明细自动填主键
         └─ 业务 DM（EAP/FC 各模块）
```
> 注：`libDB_CustomD`（ADO 线，TdmMaintenance_Custom → TdmDB_Custom）是**遗留代码**，`libMaintenance_CustomD.pas` 已不在仓库；当前在用是 FireDAC 线（`libEditView_CustomD`）。

**Frame 链（UI 层复用核心）**：
```
TUniFrame
└─ TfrBasic_Custom (libBasic_CustomA)        ← Context / Rights / tmpDataSet / sFunctionCode
   └─ TfrFunction_Custom (libFunction_CustomA) ← 图像列表
      ├─ TfrListView_Custom   ← 列表: grdList+工具栏+actDelete + 钩子(doCreateForm/doBeforeDelete/doSaveData)
      ├─ TfrEditView_Custom   ← 编辑视图
      ├─ TfrGridEdit_Custom   ← 网格编辑
      ├─ TfrTreeEdit_Custom   ← 树编辑
      ├─ TfrDetailsGrid_Custom ← 明细网格
      └─ TfrSearch_Custom     ← 搜索
         └─ 业务 Frame
```

### 1.2 六大设计模式（带代码证据）

| # | 模式 | 证据 | 作用 |
|---|------|------|------|
| ① | **模板方法（Template Method, GoF）** | `TfrListView_Custom.actDeleteExecute`: 遍历选中→`doBeforeDelete`→Delete→`doSaveData` | 基类定流程，子类填钩子——"不重复写"头号功臣 |
| ② | **分层超类型（Layered Supertype, POEAA）** | Basic→EditView→Entry 三层逐层加能力 | 业务 DM 白拿三层能力 |
| ③ | **好莱坞原则（Don't call us, we'll call you）** | 基类调子类 virtual 钩子（`doBeforeDelete`/`doAddCalcField`） | 反转控制，子类被动 |
| ④ | **配置驱动 / DFM 声明式** | 子类配 DFM（qryMaster/grdList/CommandText），.pas 极少（libEntry 40 行） | 声明组件，行为由基类 |
| ⑤ | **数据集绑定 + 批量更新（Table Gateway + Unit of Work 雏形）** | `lstDataset` + `doUpdateBatchDataSet` 统一 ApplyUpdates；主从联动 `qryDetailsAfterInsert` | 一次提交所有改动，事务一致 |
| ⑥ | **开闭原则（OCP）** | 基类 virtual 钩子开放扩展，业务不改基类只继承 | 新业务零侵入 |

### 1.3 连接管理借鉴（已落地 Task 1.5）
`BASE/Unit/Config.DataBase.pas` 的 **FireDAC Private ConnDef + Pooled** 模式（`FDManager.AddConnectionDef(CON_DEF_NAME, ..., Pooled=True, POOL_MaximumItems=100)` + `ConnectionDefName := CON_DEF_NAME`）已借鉴到 UniAdmin `TUniAdminConnectionManager`（Task 1.5，编译通过），根治 LRN-20260627-003 连接泄漏。

> **关键澄清**：BeeCloudERP 虽 `uses MVCFramework.ActiveRecord`，但 grep 证实**业务查询全用传统手写 TFDQuery/ADO SQL，从未调用 ActiveRecord API**——它不是 ORM 实战范本，其价值在**连接管理 + 模板方法基类**。

---

## 2. 三种 CRUD 范式对比

| 维度 | UniAdmin 现状（手写） | BeeCloudERP（OOP 继承） | Django Admin（元编程/声明式） |
|------|------|------|------|
| **核心模式** | 复制粘贴 | 模板方法 + 分层超类型 + DFM | **Metaclass + 声明式 + ORM + 内省** |
| **数据定义** | 手写 SQL | DFM DataSet + CommandText | `title = models.CharField(...)` 字段即声明 |
| **CRUD 来源** | 每表手写 Get/Create/Update/Delete | 基类 Open/Post/Delete | **ORM 自动**（`Model.objects.filter()` / `.save()`） |
| **UI 来源** | `TBaseCrudFrame`（已声明式）✓ | 基类 Frame + DFM | **Admin 自动生成**（list_display→列表，字段→表单） |
| **配置方式** | 代码 | DFM（设计时） | 声明式属性（`list_display`/`list_filter`） |
| **样板量** | 最多（~36 手写方法） | 少（配 DFM + 钩子） | **近乎零**（Model + 几行 register） |

### 2.1 Django Admin 的四大杀手锏
1. **元编程（Metaclass）**：`ModelBase` 元类在类创建时自动收集字段、生成 schema。
2. **声明式编程**：一行字段声明 = 类型 + 约束 + 表单 widget + 列表列。
3. **ORM/ActiveRecord**：`Article.objects.filter()` 自动 SQL；`.save()` 自动 INSERT/UPDATE。
4. **运行时内省**：Admin 从 `Model._meta` 自动生成列表/表单/权限/URL 路由——零样板。

### 2.2 先进性阶梯
```
手写重复（UniAdmin 现状）           ← 最落后
    ↓
模板方法 + 继承（BeeCloudERP）       ← OOP 范式，成熟但需配 DFM+钩子
    ↓
声明式 + 元编程 + ORM（Django Admin）← 最先进，零样板，自动生成
```
**结论：Django Admin 范式明显更先进——是 BeeCloudERP 模板方法的下一代演进（被动填空 → 主动生成）。**

---

## 3. B 路线决策（走 DMVC ActiveRecord）

### 3.1 决策依据
1. **基因一致**：UniAdmin 开篇即"借鉴 Django Admin"——UI 层（`TUniAdminModel` + `TBaseCrudFrame` + `MetadataCache` + `TModelAdminRegistry`）**已是 Django Admin 范式**。数据层是唯一缺口（手写 CRUD）。
2. **Delphi 实现声明式+ORM**：Delphi 无 Python 动态元类，但有 **RTTI + Attribute 注解**——这正是 **DMVC ActiveRecord** 的路线：
   ```pascal
   [MVCTable('UniAdmin_Users')]
   TUser = class(TMVCActiveRecord)
     [MVCTableField('UserID', [foPrimaryKey])] FUserID: Integer;
     [MVCTableField('UserName', [])] FUserName: string;  // RTTI 内省
   end;
   // ORM 自动 SQL：TMVCActiveRecord.GetByPK<TUser>(1) / .Store
   ```
   **DMVC ActiveRecord = Delphi 版 Django ORM**，比 BeeCloudERP 模板方法先进一个时代。
3. **生命周期合规**：DMVC `Select<T>: TObjectList<T>`（OwnsObjects=True）是 v2 规则的**合规所有权转移**；`TDataSet` 才是不自洽违规。B 路线天然合规。

### 3.2 B 路线风险（命门）
- **连接集成**：DMVC ActiveRecord 的 class function 查询走 `CurrentConnection`（per-thread registry + con_def 名），而 UniAdmin 是每会话代码实例连接。需 PoC 验证。
- **UniGUI 会话线程模型**：DMVC per-thread 连接能否真正隔离 UniGUI 会话，需实测。
- **缓解**：Task 1.5（连接池化，`CON_DEF_NAME` 模式）已为 con_def 集成铺路。

### 3.3 策略：长期 B + 短期过渡
- **长期**：全面 DMVC ActiveRecord（声明式 + ORM，最先进，契合基因）。
- **短期过渡**（PoC 攻克命门前）：
  - Task 1.5 连接池化 ✅（已完成，为 B con_def 铺路）
  - 可选：借鉴 BeeCloudERP 给 `TUniAdminDataModule` 增厚通用 Open/Post/Delete（模板方法，独立减负，非终极方向）

---

## 4. 三条路线一览（决策矩阵留存）

| 路线 | 范式 | 先进性 | 契合基因 | Delphi 可行性 | 代价 |
|------|------|:---:|:---:|:---:|------|
| **B（DMVC ActiveRecord）** | 声明式+ORM | ⭐⭐⭐ | ⭐⭐⭐ | ✅ 注解+RTTI | 框架依赖+连接命门 |
| A+（代码生成 DTO） | 编译期声明式 | ⭐⭐ | ⭐⭐ | ✅ 零依赖 | 无 ORM 自动 SQL |
| BeeCloudERP 式（模板方法） | OOP 继承 | ⭐⭐ | ⭐ 偏离 | ✅ 最成熟 | 仍配 DFM+钩子 |

**决策：走 B**（长期最优 + 基因一致），短期用 Task 1.5 + 可选模板方法过渡。

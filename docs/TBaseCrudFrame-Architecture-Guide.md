# TBaseCrudFrame 设计架构详解

> **文档版本**: 1.0
> **创建日期**: 2026-03-04
> **适用框架**: UniAdmin 零代码后台管理框架

---

## 目录

1. [整体架构图](#一整体架构图)
2. [各组件核心能力与关系代码示例](#二各组件核心能力与关系代码示例)
3. [为何这样设计？](#三为何这样设计)
4. [组件职责总结](#四组件职责总结)
5. [设计决策背后的原因](#五设计决策背后的原因)

---

## 一、整体架构图

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           TBaseCrudFrame (CRUD 基类)                          │
│  职责：提供标准 CRUD 操作的 UI 框架，协调各组件交互                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  pnlFilter (筛选面板) - 可选                                         │    │
│  │  职责：放置查询条件控件，如搜索框、下拉选择等                            │    │
│  │  示例：edtSearch, cmbStatus, btnSearch                               │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                    │ 查询条件触发                            │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  pnlToolBar (工具栏面板)                                             │    │
│  │  职责：放置 CRUD 操作按钮                                            │    │
│  │  ├─ BtnAdd    (新增)    → ModelAdmin.Insert                         │    │
│  │  ├─ BtnEdit   (编辑)    → ModelAdmin.Edit                           │    │
│  │  ├─ BtnDelete (删除)    → ModelAdmin.Delete                         │    │
│  │  ├─ BtnSave   (保存)    → ModelAdmin.Save                           │    │
│  │  ├─ BtnCancel (取消)    → ModelAdmin.Cancel                         │    │
│  │  └─ BtnRefresh(刷新)    → Refresh                                   │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                    │ 操作触发                                │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  grdList (数据网格)                                                  │    │
│  │  职责：展示数据列表，支持选择、排序                                    │    │
│  │  关联：UniDataSource → TDataSet (由子类提供)                          │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                    │ 选择记录                                │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  pnlPager (分页面板) - 可选                                         │    │
│  │  职责：显示分页信息，提供翻页控件                                      │    │
│  │  示例：lblPageInfo, btnFirst, btnPrev, btnNext, btnLast              │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  pnlEdit (编辑面板) - 可选                                          │    │
│  │  职责：放置表单编辑控件（通常在新增/编辑时展开）                         │    │
│  │  示例：edtUserName, edtRealName, edtEmail 等                          │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  TUniAdminModel (模型管理组件)                                       │    │
│  │  职责：管理 CRUD 状态，协调数据操作，自动填充审计字段                     │    │
│  │  ├─ 状态管理：csBrowse, csEdit, csInsert                             │    │
│  │  ├─ 操作方法：Insert, Edit, Delete, Save, Cancel                     │    │
│  │  ├─ 权限检查：CanEdit, CanInsert, CanDelete, CanSave                 │    │
│  │  └─ 审计字段：自动填充 CreatedBy, ModifiedBy 等                       │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 二、各组件核心能力与关系代码示例

### 2.1 TBaseCrudFrame 基类核心代码

```pascal
/// <summary>
/// CRUD 基类窗体 - 提供标准 CRUD 操作界面
/// 子类继承此窗体可获得标准的 CRUD 功能
/// </summary>
TBaseCrudFrame = class(TUniFrame)
private
  FModelAdmin: TUniAdminModel;      // ← 核心组件：管理 CRUD 状态
  FContext: IExecutionContext;      // ← 执行上下文：权限、用户信息
  FPermissionPrefix: string;        // ← 权限前缀：如 'user', 'role'

  // 工具栏按钮 - 声明为 protected，子类可访问
  UniToolBar: TUniToolBar;
  BtnAdd: TUniButton;
  BtnEdit: TUniButton;
  BtnDelete: TUniButton;
  BtnSave: TUniButton;
  BtnCancel: TUniButton;
  BtnRefresh: TUniButton;

  // 数据组件
  UniDBGrid: TUniDBGrid;
  UniDataSource: TDataSource;

  // ===== 核心能力 1：状态同步 =====
  /// <summary>
  /// 响应 ModelAdmin 状态变化，更新按钮可用状态
  /// 这是框架的核心：数据状态驱动 UI 状态
  /// </summary>
  procedure DoStateChange(Sender: TObject);
  procedure UpdateButtonStates;

  // ===== 核心能力 2：权限检查 =====
  /// <summary>
  /// 根据权限前缀和用户权限，显示/隐藏按钮
  /// </summary>
  procedure CheckPermissions;

  // ===== 核心能力 3：按钮事件处理 =====
  procedure BtnAddClick(Sender: TObject);
  procedure BtnEditClick(Sender: TObject);
  procedure BtnDeleteClick(Sender: TObject);
  procedure BtnSaveClick(Sender: TObject);
  procedure BtnCancelClick(Sender: TObject);
  procedure BtnRefreshClick(Sender: TObject);

protected
  // ===== 钩子方法：子类可重写 =====
  procedure DoBindControls; virtual;    // 绑定编辑控件到数据源
  procedure DoUnbindControls; virtual;  // 解绑编辑控件
  procedure DoInitialize; virtual;      // 初始化自定义组件
  procedure DoFinalize: virtual;        // 清理自定义资源
  procedure DoRefresh: virtual;         // 自定义刷新逻辑

public
  // ===== 核心能力 4：生命周期管理 =====
  procedure Initialize; virtual;        // 初始化窗体
  procedure Finalize; virtual;          // 清理窗体
  procedure Refresh; virtual;           // 刷新数据

  property ModelAdmin: TUniAdminModel read FModelAdmin;
  property Context: IExecutionContext read FContext;
end;
```

---

### 2.2 TUniAdminModel 组件核心代码

```pascal
/// <summary>
/// 数据模型管理员 - 提供标准 CRUD 操作
/// 负责管理 DataSet 的 CRUD 状态，提供标准的数据操作接口
/// </summary>
TUniAdminModel = class(TComponent)
private
  FDataSet: TDataSet;                  // ← 关联的数据集
  FContext: IExecutionContext;         // ← 执行上下文（审计字段用）
  FState: TCrudState;                  // ← 当前状态：Browse/Edit/Insert
  FOriginalValues: TDictionary<string, Variant>; // ← 原始值备份（取消时恢复）
  FOnStateChange: TNotifyEvent;        // ← 状态变化事件

public
  // ===== 核心能力 1：CRUD 操作 =====
  procedure Insert; virtual;   // 进入新增状态
  procedure Edit; virtual;     // 进入编辑状态
  procedure Delete; virtual;   // 删除当前记录
  procedure Save; virtual;     // 保存当前更改
  procedure Cancel; virtual;   // 取消当前更改

  // ===== 核心能力 2：状态检查 =====
  function CanEdit: Boolean;    // 是否可以编辑
  function CanInsert: Boolean;  // 是否可以新增
  function CanDelete: Boolean;  // 是否可以删除
  function CanSave: Boolean;    // 是否可以保存
  function CanCancel: Boolean;  // 是否可以取消

  // ===== 核心能力 3：审计字段自动填充 =====
  /// <summary>
  /// 自动填充审计字段（CreatedDate, CreatedBy, ModifiedDate, ModifiedBy）
  /// 这是框架的核心能力之一，无需手动设置这些字段
  /// </summary>
  procedure FillAuditFields(const IsInsert: Boolean);
end;

// ===== 状态枚举 =====
TCrudState = (csBrowse, csEdit, csInsert, csPendingEdit);
//                     ↓        ↓       ↓
//                  浏览状态  编辑状态  新增状态
```

---

### 2.3 组件交互流程代码示例

```pascal
// ===== 场景 1：新增用户 =====
procedure TBaseCrudFrame.BtnAddClick(Sender: TObject);
begin
  try
    // 1. 调用 ModelAdmin 进入新增状态
    FModelAdmin.Insert;           // DataSet.Append, State := csInsert

    // 2. 子类重写的钩子：绑定编辑控件
    DoBindControls;               // 子类将编辑框绑定到 DataSet 字段

    // 3. 更新按钮状态（保存/取消可用，其他禁用）
    UpdateButtonStates;           // 响应 ModelAdmin.State = csInsert
  except
    on E: Exception do
    begin
      UpdateButtonStates;         // 出错时恢复按钮状态
      raise;
    end;
  end;
end;

// ===== 场景 2：保存数据 =====
procedure TBaseCrudFrame.BtnSaveClick(Sender: TObject);
begin
  try
    // 1. 子类重写的钩子：解绑编辑控件（验证数据）
    DoUnbindControls;             // 子类验证并保存编辑框值到 DataSet

    // 2. 调用 ModelAdmin 保存
    FModelAdmin.Save;             // DataSet.Post, State := csBrowse

    // 3. 更新按钮状态
    UpdateButtonStates;           // 响应 ModelAdmin.State = csBrowse
  except
    on E: Exception do
    begin
      DoBindControls;             // 出错时重新绑定，用户可继续编辑
      UpdateButtonStates;
      raise;
    end;
  end;
end;

// ===== 场景 3：状态驱动按钮更新 =====
procedure TBaseCrudFrame.UpdateButtonStates;
begin
  // 根据 ModelAdmin 的状态决定按钮是否可用
  if Assigned(BtnAdd) then
    BtnAdd.Enabled := FModelAdmin.CanInsert;    // csBrowse 时可用

  if Assigned(BtnEdit) then
    BtnEdit.Enabled := FModelAdmin.CanEdit;     // csBrowse 且有记录时可用

  if Assigned(BtnDelete) then
    BtnDelete.Enabled := FModelAdmin.CanDelete; // csBrowse 且有记录时可用

  if Assigned(BtnSave) then
    BtnSave.Enabled := FModelAdmin.CanSave;     // csEdit/csInsert 时可用

  if Assigned(BtnCancel) then
    BtnCancel.Enabled := FModelAdmin.CanCancel; // csEdit/csInsert 时可用
end;
```

---

### 2.4 子类使用示例：TUserListFrame

```pascal
/// <summary>
/// 用户列表窗体 - 继承自 TBaseCrudFrame
/// 展示如何使用框架提供的能力
/// </summary>
TUserListFrame = class(TBaseCrudFrame)
private
  FQuery: TFDQuery;              // ← 子类提供的数据集

  // pnlFilter 上的控件（由子类声明和布局）
  edtSearch: TUniEdit;           // 搜索框
  cmbStatus: TUniEdit;           // 状态下拉
  btnSearch: TUniButton;         // 搜索按钮

  procedure btnSearchClick(Sender: TObject);

protected
  // ===== 重写钩子方法 =====
  procedure DoInitialize; override;     // 初始化网格列
  procedure DoRefresh; override;        // 加载数据
  procedure DoBindControls; override;   // 绑定编辑控件（如果使用 pnlEdit）

public
  constructor Create(AOwner: TComponent); override;
end;

constructor TUserListFrame.Create(AOwner: TComponent);
begin
  inherited;
  FPermissionPrefix := 'user';           // ← 设置权限前缀

  FQuery := TFDQuery.Create(nil);        // ← 创建数据集
  FQuery.Connection := ModelAdmin.Connection;
  UniDataSource.DataSet := FQuery;       // ← 关联数据源
end;

procedure TUserListFrame.DoInitialize;
begin
  inherited;

  // ===== 配置网格列 =====
  // 子类负责定义网格显示哪些字段
  if UniDBGrid.Columns.Count = 0 then
  begin
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'UserID';
      Title.Caption := 'ID';
      Width := 50;
    end;
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'UserName';
      Title.Caption := '用户名';
      Width := 100;
    end;
    // ... 更多列
  end;
end;

procedure TUserListFrame.DoRefresh;
begin
  inherited;

  // ===== 加载数据 =====
  // 子类负责编写查询逻辑
  FQuery.Close;
  FQuery.SQL.Text := 'SELECT UserID, UserName, RealName, Email, Phone, Status ' +
                     'FROM UniAdmin_Users ORDER BY UserID DESC';
  FQuery.Open;
end;

procedure TUserListFrame.btnSearchClick(Sender: TObject);
begin
  // ===== 筛选逻辑 =====
  // pnlFilter 上的按钮触发查询
  FQuery.Close;
  FQuery.SQL.Text := 'SELECT * FROM UniAdmin_Users ' +
                     'WHERE UserName LIKE :Search ORDER BY UserID DESC';
  FQuery.ParamByName('Search').AsString := '%' + edtSearch.Text + '%';
  FQuery.Open;
end;
```

---

## 三、为何这样设计？

### 3.1 设计原则

| 设计原则 | 体现 | 代码示例 |
|---------|------|----------|
| **单一职责** | 每个组件职责明确 | `TBaseCrudFrame` 负责 UI 协调，`TUniAdminModel` 负责数据状态 |
| **开闭原则** | 通过钩子方法扩展 | 子类重写 `DoInitialize`、`DoRefresh` 等方法 |
| **依赖倒置** | 依赖抽象接口 | `IExecutionContext` 接口解耦具体实现 |
| **模板方法** | 定义算法骨架 | `BtnAddClick` → `DoBindControls` → `UpdateButtonStates` |
| **状态驱动** | 状态变化驱动 UI 更新 | `ModelAdmin.State` 变化 → 触发 `OnStateChange` |

---

### 3.2 核心设计模式

#### 模式 1：模板方法模式

```pascal
// 基类定义算法骨架
procedure TBaseCrudFrame.BtnAddClick(Sender: TObject);
begin
  try
    FModelAdmin.Insert;       // ← 固定步骤：状态管理
    DoBindControls;           // ← 可变步骤：子类实现绑定逻辑
    UpdateButtonStates;       // ← 固定步骤：UI 同步
  except
    UpdateButtonStates;
    raise;
  end;
end;

// 子类实现可变步骤
procedure TUserListFrame.DoBindControls;
begin
  // 将编辑框绑定到数据集字段
  edtUserName.DataField := 'UserName';
  edtRealName.DataField := 'RealName';
  edtEmail.DataField := 'Email';
end;
```

#### 模式 2：状态模式

```pascal
// ModelAdmin 维护状态
type TCrudState = (csBrowse, csEdit, csInsert);

// 状态决定操作可用性
function TUniAdminModel.CanSave: Boolean;
begin
  Result := (FState in [csEdit, csInsert]);  // 只有编辑/新增状态可保存
end;

// UI 响应状态变化
procedure TBaseCrudFrame.UpdateButtonStates;
begin
  BtnSave.Enabled := ModelAdmin.CanSave;    // 根据状态决定按钮状态
end;
```

#### 模式 3：观察者模式

```pascal
// ModelAdmin 作为被观察者
type TUniAdminModel = class(TComponent)
  FOnStateChange: TNotifyEvent;  // ← 状态变化事件
end;

// BaseCrudFrame 作为观察者
constructor TBaseCrudFrame.Create(AOwner: TComponent);
begin
  inherited;
  FModelAdmin := TUniAdminModel.Create(Self);
  FModelAdmin.OnStateChange := DoStateChange;  // ← 订阅状态变化
end;

procedure TBaseCrudFrame.DoStateChange(Sender: TObject);
begin
  UpdateButtonStates;  // ← 响应状态变化
end;
```

---

### 3.3 设计优势

#### 1. **零代码 CRUD** - 配置驱动

子类只需继承 `TBaseCrudFrame`，无需编写 CRUD 逻辑：

```pascal
// 不使用框架：需要手动编写
procedure TForm1.btnAddClick(Sender: TObject);
begin
  qryUsers.Append;
  qryUsers.FieldByName('CreatedDate').AsDateTime := Now;
  qryUsers.FieldByName('CreatedBy').AsInteger := CurrentUserID;
  // 设置按钮状态...
  edtUserName.Enabled := True;
  edtUserName.SetFocus;
  // ... 更多代码
end;

// 使用框架：自动获得
TUserListFrame = class(TBaseCrudFrame)  // ← 继承即获得 CRUD 能力
  // 无需编写 BtnAddClick、BtnSaveClick 等方法
end;
```

#### 2. **审计字段自动填充**

```pascal
// 不使用框架：每次保存都要手动设置
qryUsers.FieldByName('ModifiedDate').AsDateTime := Now;
qryUsers.FieldByName('ModifiedBy').AsInteger := CurrentUserID;
qryUsers.Post;

// 使用框架：自动填充
procedure TUniAdminModel.FillAuditFields(const IsInsert: Boolean);
begin
  // ModelAdmin.Save 时自动调用
  if FDataSet.FindField('ModifiedDate') <> nil then
    FDataSet.FieldByName('ModifiedDate').AsDateTime := FContext.GetCurrentTime;
  if FDataSet.FindField('ModifiedBy') <> nil then
    FDataSet.FieldByName('ModifiedBy').AsInteger := FContext.GetCurrentUserID;
end;
```

#### 3. **权限驱动的 UI**

```pascal
// 不使用框架：手动检查权限
btnAdd.Visible := HasPermission('user:add');
btnEdit.Visible := HasPermission('user:edit');
btnDelete.Visible := HasPermission('user:delete');

// 使用框架：自动检查
FPermissionPrefix := 'user';  // ← 设置前缀
CheckPermissions;             // ← 自动检查所有按钮
```

#### 4. **状态驱动的按钮管理**

```pascal
// 不使用框架：手动管理按钮状态
procedure UpdateButtons;
begin
  if qryUsers.State in [dsInsert, dsEdit] then
  begin
    btnSave.Enabled := True;
    btnCancel.Enabled := True;
    btnAdd.Enabled := False;
    btnEdit.Enabled := False;
    btnDelete.Enabled := False;
  end
  else
  begin
    btnSave.Enabled := False;
    btnCancel.Enabled := False;
    btnAdd.Enabled := True;
    btnEdit.Enabled := not qryUsers.IsEmpty;
    btnDelete.Enabled := not qryUsers.IsEmpty;
  end;
end;

// 使用框架：自动同步
procedure TBaseCrudFrame.DoStateChange(Sender: TObject);
begin
  UpdateButtonStates;  // ← ModelAdmin 状态变化时自动调用
end;
```

---

## 四、组件职责总结

| 组件 | 职责 | 核心能力 | 子类需要做什么 |
|-----|------|----------|---------------|
| **TBaseCrudFrame** | UI 框架协调器 | • 按钮事件处理<br>• 状态同步<br>• 权限检查 | • 重写钩子方法<br>• 提供数据集<br>• 声明筛选控件 |
| **TUniAdminModel** | 数据状态管理器 | • CRUD 状态管理<br>• 审计字段填充<br>• 原始值备份 | • 设置 DataSet<br>• 设置 Context |
| **pnlFilter** | 筛选条件容器 | • 放置查询控件<br>• 触发查询操作 | • 添加编辑框/下拉框<br>• 编写查询逻辑 |
| **pnlToolBar** | 工具栏容器 | • 放置操作按钮<br>• 自动禁用/启用 | 无需操作，基类管理 |
| **grdList** | 数据展示网格 | • 显示数据列表<br>• 选择记录 | • 配置列定义 |
| **pnlPager** | 分页控件容器 | • 显示分页信息<br>• 提供翻页操作 | • 添加分页控件<br>• 编写翻页逻辑 |
| **pnlEdit** | 编辑表单容器 | • 放置编辑控件 | • 添加编辑框<br>• 实现绑定逻辑 |

---

## 五、设计决策背后的原因

### Q1: 为什么将 CRUD 状态管理从 UI 层分离到 `TUniAdminModel`？

**A: 职责分离 + 可测试性**

```pascal
// 分离前：状态逻辑散落在 UI 代码中
procedure TForm1.btnAddClick(Sender: TObject);
begin
  if qryUsers.State <> dsBrowse then Exit;  // ← 状态检查
  qryUsers.Append;
  // ... UI 逻辑
  btnSave.Enabled := True;                  // ← 状态响应
end;

// 分离后：状态逻辑集中在 ModelAdmin
procedure TBaseCrudFrame.BtnAddClick(Sender: TObject);
begin
  FModelAdmin.Insert;        // ← 状态逻辑
  DoBindControls;            // ← UI 逻辑
  UpdateButtonStates;        // ← 状态响应
end;

// 好处：ModelAdmin 可以单独测试
[Test]
procedure TestModelAdminInsert;
begin
  ModelAdmin.Insert;
  Assert.AreEqual(csInsert, ModelAdmin.State);
  Assert.IsTrue(ModelAdmin.CanSave);
end;
```

### Q2: 为什么使用钩子方法而不是抽象方法？

**A: 灵活性 - 子类按需重写**

```pascal
// 如果使用抽象方法：子类必须实现所有方法
procedure DoBindControls; abstract;  // ← 强制实现
procedure DoUnbindControls; abstract;
procedure DoInitialize; abstract;
// ... 问题：如果子类不需要某个功能，也要提供空实现

// 使用虚方法：子类按需重写
procedure DoBindControls; virtual;   // ← 可选实现
begin
  // 空实现，子类不需要时不重写
end;
```

### Q3: 为什么 `pnlFilter` 和 `pnlEdit` 是可选的？

**A: 灵活性 - 不同场景需求不同**

```
只读列表场景：
  ├─ pnlToolBar (显示导出、刷新按钮)
  ├─ grdList
  └─ pnlPager
  无 pnlFilter（无筛选需求）
  无 pnlEdit（只读模式）

简单编辑场景：
  ├─ pnlFilter
  ├─ pnlToolBar
  ├─ grdList
  └─ 内嵌编辑列（点击网格单元格直接编辑）
  无 pnlEdit（网格内编辑）

复杂编辑场景：
  ├─ pnlFilter
  ├─ pnlToolBar
  ├─ grdList
  ├─ pnlPager
  └─ pnlEdit (展开详细的编辑表单)
```

---

## 附录

### 相关文件

| 文件 | 路径 | 说明 |
|-----|------|------|
| `BaseCrudFrame.pas` | `src/Core/UI/` | CRUD 基类实现 |
| `UniAdminModel.pas` | `src/Core/UI/` | 模型管理组件 |
| `UserListFrame.pas` | `src/Modules/User/` | 用户列表示例 |
| `2025-02-23-uniadmin-implementation-design.md` | `docs/plans/` | 设计文档 |

### 扩展阅读

- [Django Admin 设计理念](https://docs.djangoproject.com/en/stable/ref/contrib/admin/)
- [设计模式：可复用面向对象软件的基础](https://en.wikipedia.org/wiki/Design_Patterns)
- [SOLID 原则](https://en.wikipedia.org/wiki/SOLID)

---

*文档版本: 1.0*
*最后更新: 2026-03-04*
*维护者: UniAdmin 开发团队*

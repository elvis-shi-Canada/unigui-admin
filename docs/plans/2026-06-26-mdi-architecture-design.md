# UniAdmin MDI 架构设计方案

> 基于 FSThemeCrystal Demo 的设计参考，融合 UniAdmin 插件系统与元数据驱动理念
> 创建日期：2026-06-26
> 状态：📋 设计阶段

---

## 1. 背景与目标

### 1.1 设计参考来源

**FSThemeCrystal**（巴西 Falcon Sistemas 出品，作者 Marlon Nardi）是一套基于 uniGUI + UniFalcon 的财务管理 Demo，其 MDI 界面架构设计精良，值得借鉴。源码位置：`D:\BaiduNetdiskDownload\vcl\UniFalcon\Demos\FSThemeCrystal`。

### 1.2 改造目标

| 目标 | 衡量标准 |
|------|---------|
| **数据驱动路由** | 新增业务模块时，MainFrame 路由代码零修改 |
| **页面状态缓存** | 切换菜单后再切回，保留列表筛选/分页/滚动位置 |
| **开闭原则** | 对扩展开放（加菜单+Frame），对修改封闭（不改 MainFrame） |
| **向后兼容** | 不破坏现有 UserListFrame/RoleListFrame/MenuTreeFrame |

---

## 2. 现状分析

### 2.1 当前架构

```
TMainFrame (TUniForm)
├── UniMainMenu (顶部下拉菜单)
├── UniContainerPanel (内容区, alClient)
└── UniStatusBar (状态栏, alBottom)
```

### 2.2 核心痛点

#### 痛点 1：硬编码路由（违反 OCP）

`MainFrame.pas:195-231` 的 `OnMenuClick`：

```pascal
// Current: every new module requires editing MainFrame
if LMenuData.MenuCode = 'system.user' then
  LFrame := TUserListFrame.Create(Self)
else if LMenuData.MenuCode = 'system.role' then
  LFrame := TRoleListFrame.Create(Self)
else if LMenuData.MenuCode = 'system.menu' then
  LFrame := TMenuTreeFrame.Create(Self);
```

**问题**：每新增一个模块，必须修改 MainFrame，违反开闭原则（SOLID 的 O）。

#### 痛点 2：无页面缓存（状态丢失）

`MainFrame.pas:257-267` 的 `ShowContent`：

```pascal
// Current: destroys and recreates on every switch
if Assigned(FContentFrame) then
  FContentFrame.Free;        // state lost!
AFrame.Parent := UniContainerPanel;
AFrame.Show;
FContentFrame := AFrame;
```

**问题**：用户在「用户列表」筛选了数据，切到「角色管理」再切回，筛选条件丢失，需重新查询。

#### 痛点 3：RoutePath 字段闲置

`UniAdminMenuManager.Intf.pas:18` 定义了 `RoutePath: string`，数据库 `UniAdmin_Menus` 表也有该列，但 `OnMenuClick` 只用 `MenuCode`，从未读取 `RoutePath`。

---

## 3. FSThemeCrystal 设计模式提炼

### 3.1 四大可借鉴模式

| 模式 | 实现要点 | UniAdmin 适用性 |
|------|---------|----------------|
| **数据驱动菜单路由** | 菜单项名 `actXxx` → 类名 `TfrmXxx`，`FindClass` 动态加载 | ⭐⭐⭐⭐⭐ |
| **Panel 缓存池** | 业务 Panel 用 `Tag=1` 标记，切换只显隐不销毁 | ⭐⭐⭐⭐⭐ |
| **Tag 行为编码** | `Tag` 编码打开方式（标签页/模态/退出） | ⭐⭐⭐⭐ |
| **客户端布局** | `AlignmentControl=uniAlignmentClient` + `Layout='border'` | ⭐⭐⭐ |

### 3.2 关键代码模式（来自 FS.Abas.pas）

```pascal
// Dynamic frame loading by class name string
FCurrentFrame := TUniFrameClass(FindClass(NameFrame));
Fr := FCurrentFrame.Create(TabSheet);
Fr.Align := alClient;
Fr.Parent := TabSheet;
```

```pascal
// Each frame unit registers itself
initialization
  RegisterClass(TfrmDashboard);
```

---

## 4. 架构设计

### 4.1 总体架构

```
┌─────────────────────────────────────────────────────────────┐
│                     TMainFrame (外壳)                        │
│  ┌──────────────┐  ┌──────────────────────────────────────┐ │
│  │  菜单区       │  │  内容区 (ContentHost)                 │ │
│  │  (TreeMenu/  │  │  ┌─────────────────────────────────┐  │ │
│  │   MainMenu)  │  │  │  Frame 缓存池                    │  │ │
│  │              │  │  │  ┌─────────┐ ┌─────────┐        │  │ │
│  │  点击菜单     │──┼──│  │ Frame A │ │ Frame B │  ...   │  │ │
│  │      │       │  │  │  │(Visible)│ │(Hidden) │        │  │ │
│  │      ▼       │  │  │  └─────────┘ └─────────┘        │  │ │
│  │  MenuRouter  │  │  └─────────────────────────────────┘  │ │
│  │  (FindClass) │  │                                      │ │
│  └──────────────┘  └──────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────┐│
│  │  StatusBar                                              ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

### 4.2 核心组件

| 组件 | 职责 | 复用/新增 |
|------|------|----------|
| `UniAdminMenuManager` | 菜单数据 + 权限过滤（已有） | 复用 |
| `UniAdmin_Menus.RoutePath` | 存储 Frame 类名 | 复用（激活） |
| `IMdiRouter` / `TMdiRouter` | 路由服务：类名 → Frame 实例 | **新增** |
| `TMainFrame.ContentHost` | 内容宿主 + 缓存管理 | 改造 |
| Frame 注册机制 | `initialization` 段 `RegisterClass` | **新增约定** |

---

## 5. 详细设计

### 5.1 数据模型：激活 RoutePath

`UniAdmin_Menus.RoutePath` 字段语义重新定义：

| RoutePath 值 | 含义 | 打开方式 |
|-------------|------|---------|
| `TUserListFrame` | Frame 类名 | 嵌入内容区（默认） |
| `TUserEditForm` | Form 类名 | 模态窗口 |
| _(空)_ | 无路由 | 纯分类节点 |

**Seed 数据示例**（`Database/Seed/`）：

```sql
-- RoutePath stores the Frame/Form class name
UPDATE UniAdmin_Menus SET RoutePath = 'TUserListFrame'  WHERE MenuCode = 'system.user';
UPDATE UniAdmin_Menus SET RoutePath = 'TRoleListFrame'  WHERE MenuCode = 'system.role';
UPDATE UniAdmin_Menus SET RoutePath = 'TMenuTreeFrame'  WHERE MenuCode = 'system.menu';
```

### 5.2 路由服务设计

新增接口 `IMdiRouter`（`src/Core/UI/UniAdminMdiRouter.Intf.pas`）：

```pascal
type
  /// <summary>Open mode for a routed target</summary>
  TMdiOpenMode = (omEmbed,    // embed into content host (default)
                  omModal);   // show as modal form

  /// <summary>
  /// MDI router: resolves a class name to a Frame/Form instance
  /// and manages the content cache.
  /// </summary>
  IMdiRouter = interface(IInterface)
    ['{GUID}']
    /// <summary>Open target by class name with caching</summary>
    procedure Open(const AClassName: string; AOpenMode: TMdiOpenMode = omEmbed);

    /// <summary>Check whether a class is registered and routable</summary>
    function CanRoute(const AClassName: string): Boolean;

    /// <summary>Close and release a cached frame by class name</summary>
    procedure Close(const AClassName: string);

    /// <summary>Close all cached frames</summary>
    procedure CloseAll;
  end;
```

### 5.3 页面缓存设计

`TMdiRouter` 内部维护缓存字典：

```pascal
TMdiRouter = class(TInterfacedObject, IMdiRouter)
private
  FHost: TUniContainerPanel;                          // content host
  FCache: TDictionary<string, TUniFrame>;             // className -> instance
  procedure ShowFrame(const AClassName: string);
public
  procedure Open(const AClassName: string; AOpenMode: TMdiOpenMode);
  // ...
end;

procedure TMdiRouter.ShowFrame(const AClassName: string);
var
  LFrame: TUniFrame;
  LPair: TPair<string, TUniFrame>;
begin
  // 1. Hide all cached frames
  for LPair in FCache do
    LPair.Value.Visible := False;

  // 2. Cache hit? show it (preserves state!)
  if FCache.TryGetValue(AClassName, LFrame) then
  begin
    LFrame.Visible := True;
    Exit;
  end;

  // 3. Cache miss? create, register, show
  LFrame := TUniFrameClass(FindClass(AClassName)).Create(FHost);
  LFrame.Parent := FHost;
  LFrame.Align := alClient;
  LFrame.Visible := True;
  FCache.Add(AClassName, LFrame);
end;
```

### 5.4 行为编码：OpenMode 推导

打开方式优先级：

1. **显式约定**：RoutePath 以 `Form` 结尾 → `omModal`；以 `Frame` 结尾 → `omEmbed`
2. **未来扩展**：可在 `UniAdmin_Menus` 新增 `OpenMode` 列显式控制（YAGNI，暂不实现）

```pascal
function DetectOpenMode(const AClassName: string): TMdiOpenMode;
begin
  if AnsiEndsText('Form', AClassName) then
    Result := omModal
  else
    Result := omEmbed;
end;
```

### 5.5 MainFrame 改造对比

**改造前**（硬编码）：

```pascal
procedure TMainFrame.OnMenuClick(Sender: TObject);
begin
  LMenuData := FMenuManager.GetMenuByID(LMenuID);
  if LMenuData.MenuCode = 'system.user' then
    LFrame := TUserListFrame.Create(Self)        // ❌ hardcoded
  else if LMenuData.MenuCode = 'system.role' then
    LFrame := TRoleListFrame.Create(Self)        // ❌ hardcoded
  else if ...;
  ShowContent(LFrame);
end;
```

**改造后**（数据驱动）：

```pascal
procedure TMainFrame.OnMenuClick(Sender: TObject);
var
  LMenuData: UniAdminMenuManager.Intf.TMenuItem;
begin
  LMenuData := FMenuManager.GetMenuByID(TUniMenuItem(Sender).Tag);
  if LMenuData.RoutePath = '' then
    Exit;                                        // pure category node
  FMdiRouter.Open(LMenuData.RoutePath);          // ✅ zero routing code
end;
```

### 5.6 Frame 注册约定

每个业务 Frame 单元**必须**在 `initialization` 段注册自身：

```pascal
unit UserListFrame;
// ...
implementation
// ...
initialization
  RegisterClass(TUserListFrame);   // required for FindClass routing
end.
```

> **注意**：UniGUI 的 `RegisterClass` 注册到全局类注册表，`FindClass` 按名称查找。这是 Delphi RTTI 的经典模式，插件化思维的基石。

---

## 6. 实施计划

### 阶段 1：路由服务（核心，预计 2h）

- [ ] 新建 `UniAdminMdiRouter.Intf.pas` / `.pas`
- [ ] 实现 `TMdiRouter`（FindClass + 缓存字典）
- [ ] 注册到 `UniAdminServices` 服务定位器

### 阶段 2：MainFrame 改造（预计 1h）

- [ ] `OnMenuClick` 改用 `FMdiRouter.Open(RoutePath)`
- [ ] 移除硬编码 if-else
- [ ] 移除 `uses UserListFrame, RoleListFrame, MenuTreeFrame`（解耦！）

### 阶段 3：Frame 注册（预计 30min）

- [ ] 为所有业务 Frame 添加 `initialization RegisterClass(...)`
- [ ] 涉及：UserListFrame, RoleListFrame, MenuTreeFrame, 及各 Modules 下 Frame

### 阶段 4：Seed 数据（预计 15min）

- [ ] 更新 `UniAdmin_Menus` 的 RoutePath 字段

### 阶段 5：验证（预计 30min）

- [ ] 编译通过
- [ ] 菜单点击能正确打开对应 Frame
- [ ] 切换菜单后切回，验证状态保留

---

## 7. 风险与对策

| 风险 | 影响 | 对策 |
|------|------|------|
| Frame 未 RegisterClass → FindClass 返回 nil | 点击菜单无反应 | 路由服务内 `GetClass` 预检 + 友好提示 |
| 缓存 Frame 占用内存 | 会话内存增长 | 提供 `CloseAll`；超阈值时 LRU 淘汰（未来） |
| RoutePath 历史数据为空 | 升级后菜单失效 | Seed 脚本批量回填 |
| Frame 依赖 MainModule 服务 | 创建时上下文未就绪 | Frame 在 `OnShow/OnReady` 时按需获取服务，而非 Create 时 |

---

## 8. 与 FSThemeCrystal 的取舍

| FSThemeCrystal 做法 | UniAdmin 是否采纳 | 理由 |
|---------------------|------------------|------|
| 空壳 MainForm + Frame 注入登录 | ❌ 不采纳 | UniAdmin 的 `TUniLoginForm` 更标准 |
| `act→Tfrm` 命名映射 | ❌ 不采纳 | UniAdmin 用 RoutePath 直接存类名，更直观 |
| `Tag` 整数编码行为 | ❌ 不采纳 | 用类名后缀（Form/Frame）推导，语义更清晰 |
| `FindClass` 动态加载 | ✅ 采纳 | 核心，解耦关键 |
| Panel/TabSheet 缓存 | ✅ 采纳 | 性能与体验提升显著 |
| 客户端布局 | ⏳ 后续 | 第二阶段优化 |
| UniFalcon 主题控件 | ⏳ 后续 | 第三阶段评估引入 |

---

## 9. 附录

### 9.1 相关文件

- 现状：`src/Core/UI/MainFrame.pas`、`src/Core/Menu/UniAdminMenuManager.pas`
- 参考：`D:\BaiduNetdiskDownload\vcl\UniFalcon\Demos\FSThemeCrystal\`
- 框架知识：`C:\Users\SW\.claude\skills\unigui-framework-skill`

### 9.2 术语表

| 术语 | 含义 |
|------|------|
| MDI | Multiple Document Interface，多文档界面 |
| RoutePath | 菜单路由路径，UniAdmin 中存储目标 Frame/Form 类名 |
| FindClass | Delphi RTTI 函数，按类名字符串查找已注册的类 |
| 缓存池 | 保留已创建的 Frame 实例，切换时显隐而非销毁重建 |

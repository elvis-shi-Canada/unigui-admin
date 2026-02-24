# Phase 3: 系统模块层 - 实施计划

> **项目**: UniAdmin 通用后台管理系统框架  
> **阶段**: Phase 3 - 系统模块层  
> **基于**: Phase 1 (插件管理层) ✅ + Phase 2 (核心框架层) ✅  
> **周期**: 3-4 周  
> **任务数**: 42 个

---

## 阶段概述

Phase 3 将基于 Phase 2 的核心框架（TBaseCrudFrame、IUniAuthService、IUniPermissionManager 等）实现 7 个系统管理模块。这些模块是所有后台管理系统的基础功能。

### Phase 2 基础设施回顾

在开始 Phase 3 之前，回顾 Phase 2 提供的核心能力：

| 组件 | 文件 | 功能 |
|------|------|------|
| CRUD 基类 | `BaseCrudFrame.pas` | 提供标准增删改查操作界面 |
| 认证服务 | `UniAuthService.pas` | 用户登录、密码管理 |
| 权限管理 | `UniPermissionManager.pas` | RBAC 权限检查 |
| 菜单管理 | `UniMenuManager.pas` | 菜单树管理 |
| 数据访问 | `UniDataModule.pas` | 数据库操作基类 |
| 元数据缓存 | `UniMetadataCache.pas` | 表结构元数据 |

### Phase 3 模块清单

| 模块 | 任务范围 | 优先级 | 依赖 |
|------|---------|:------:|------|
| 1. 用户管理 | 51-57 | P0 | 无 |
| 2. 角色管理 | 58-63 | P0 | 用户管理 |
| 3. 菜单管理 | 64-68 | P0 | 无 |
| 4. 数据字典 | 69-73 | P1 | 无 |
| 5. 系统配置 | 74-78 | P1 | 无 |
| 6. 日志审计 | 79-85 | P1 | 用户管理 |
| 7. 定时任务 | 86-92 | P2 | 无 |
| 8. 集成测试 | 93-100 | - | 以上全部 |

---

## 模块 1: 用户管理模块 (Tasks 51-57)

### 模块概述

用户管理模块是系统最核心的模块，提供用户账号的完整生命周期管理。所有模块都依赖用户管理提供的认证和授权基础。

### 数据库表

```sql
-- 已在 Phase 2 创建
UniAdmin_Users (
    UserID INT PRIMARY KEY,
    UserName NVARCHAR(50) UNIQUE,
    Password NVARCHAR(255),
    RealName NVARCHAR(100),
    Email NVARCHAR(100),
    Phone NVARCHAR(20),
    Avatar NVARCHAR(255),
    Status INT,
    LastLoginDate DATETIME,
    LastLoginIP NVARCHAR(50),
    CreatedDate DATETIME,
    CreatedBy INT,
    ModifiedDate DATETIME,
    ModifiedBy INT
)
```

### 任务分解

#### Task 51: 创建用户管理数据模块
**文件**: `src/Modules/User/UserDataModule.pas`

**职责**:
- 继承自 `TUniBaseModule`
- 封装用户表的 CRUD 操作
- 提供用户查询方法（按用户名、邮箱、状态）
- 密码验证和更新
- 用户状态切换

**关键方法**:
```pascal
type
  TUserDataModule = class(TUniBaseModule)
  public
    // 用户查询
    function GetUserByID(UserID: Integer): TDataSet;
    function GetUserByName(const UserName: string): TDataSet;
    function GetUsers(const Filter: string; Status: Integer): TDataSet;
    
    // 用户操作
    function CreateUser(const UserName, Password, RealName, Email: string): Integer;
    procedure UpdateUser(UserID: Integer; const RealName, Email, Phone: string);
    procedure DeleteUser(UserID: Integer);
    
    // 密码管理
    function VerifyPassword(const UserName, Password: string): Boolean;
    procedure ChangePassword(UserID: Integer; const NewPassword: string);
    procedure ResetPassword(UserID: Integer; const NewPassword: string);
    
    // 状态管理
    procedure SetUserStatus(UserID: Integer; Status: Integer);
    procedure UpdateLastLogin(UserID: Integer; const IP: string);
  end;
```

**验收标准**:
- [ ] 继承 TUniBaseModule
- [ ] 所有数据库操作使用参数化查询
- [ ] 密码使用 SHA256 哈希
- [ ] 支持事务回滚

---

#### Task 52: 创建用户列表窗体
**文件**: `src/Modules/User/UserListFrame.pas`

**职责**:
- 继承自 `TBaseCrudFrame`
- 显示用户列表（网格视图）
- 支持搜索和筛选
- 工具栏操作：新增、编辑、删除、刷新

**UI 布局**:
```
┌─────────────────────────────────────────────────────────┐
│ 🔍 搜索: [____________] 状态: [全部▼] [🔍 搜索]          │
├─────────────────────────────────────────────────────────┤
│ [➕新增] [✏️编辑] [🗑️删除] [🔄刷新]                       │
├─────────────────────────────────────────────────────────┤
│ 用户名 │ 真实姓名 │ 邮箱         │ 电话 │ 状态 │ 最后登录 │
│────────┼──────────┼──────────────┼──────┼──────┼─────────│
│ admin  │ 管理员   │ a@demo.com   │ ...  │ 启用 │ 2分钟前 │
│ user1  │ 测试用户 │ u1@demo.com  │ ...  │ 启用 │ 1天前   │
└─────────────────────────────────────────────────────────┘
```

**权限配置**:
- `PermissionPrefix = 'user'`
- `user:view` - 查看用户列表
- `user:add` - 新增用户
- `user:edit` - 编辑用户
- `user:delete` - 删除用户

**验收标准**:
- [ ] 继承 TBaseCrudFrame
- [ ] 显示用户列表（包含用户名、真实姓名、邮箱、电话、状态、最后登录时间）
- [ ] 支持按用户名/真实姓名搜索
- [ ] 支持按状态筛选（全部/启用/禁用）
- [ ] 权限控制正确
- [ ] 删除前确认提示

---

#### Task 53: 创建用户编辑窗体
**文件**: `src/Modules/User/UserEditForm.pas`

**职责**:
- 用户信息新增/编辑表单
- 表单验证
- 密码设置（新增时必填，编辑时可选）

**UI 布局**:
```
┌─────────────────────────────────────────┐
│           用户信息                        │
├─────────────────────────────────────────┤
│ 用户名:   [admin____________] *          │
│ 真实姓名: [管理员__________] *          │
│ 邮箱:     [a@demo.com______] *          │
│ 手机:     [13800138000____]              │
│                                          │
│ [🔒修改密码]                             │
│   新密码: [____________]                 │
│   确认密码: [__________]                 │
│                                          │
│ 状态:     ◉ 启用  ○ 禁用                 │
│                                          │
│        [💾保存] [❌取消]                  │
└─────────────────────────────────────────┘
```

**表单验证规则**:
- 用户名：必填，3-50字符，字母数字下划线，唯一
- 真实姓名：必填，2-100字符
- 邮箱：必填，有效邮箱格式，唯一
- 手机：可选，有效手机格式
- 密码：新增时必填，8-50字符

**验收标准**:
- [ ] 新增和编辑模式复用同一个表单
- [ ] 所有必填字段有标记
- [ ] 客户端验证 + 服务器端验证
- [ ] 密码在编辑模式下为可选
- [ ] 用户名和邮箱唯一性检查
- [ ] 保存成功后刷新列表

---

#### Task 54: 创建密码管理功能
**文件**: `src/Modules/User/UserPasswordDialog.pas`

**职责**:
- 管理员重置用户密码
- 用户修改自己的密码

**UI 布局**:
```
┌─────────────────────────────────────────┐
│           修改密码                        │
├─────────────────────────────────────────┤
│ 用户: admin                              │
│                                          │
│ 旧密码:   [____________] * (本人修改)    │
│ 新密码:   [____________] *               │
│ 确认密码: [____________] *               │
│                                          │
│ 强度: ████████  强                       │
│                                          │
│        [💾确认] [❌取消]                  │
└─────────────────────────────────────────┘
```

**业务规则**:
- 管理员重置：不需要旧密码，可设置任意密码
- 用户修改：需要验证旧密码
- 新密码强度检查（长度、复杂度）
- 修改后记录操作日志

**验收标准**:
- [ ] 管理员模式和用户模式
- [ ] 密码强度指示器
- [ ] 新密码和确认密码一致性检查
- [ ] 修改成功后提示并记录日志

---

#### Task 55: 创建用户个人资料页面
**文件**: `src/Modules/User/UserProfileFrame.pas`

**职责**:
- 用户查看和编辑个人资料
- 修改密码入口
- 头像上传（可选）

**UI 布局**:
```
┌─────────────────────────────────────────┐
│  👤 admin                                │
│  ┌──────┐                                │
│  │ 头像 │  [更换头像]                    │
│  └──────┘                                │
│                                          │
│  用户名:   admin                         │
│  真实姓名: [管理员__________]            │
│  邮箱:     [a@demo.com______]            │
│  手机:     [13800138000____]             │
│                                          │
│  最后登录: 2026-02-24 10:30:00           │
│  登录IP:  192.168.1.100                  │
│                                          │
│  [🔒修改密码] [💾保存]                    │
└─────────────────────────────────────────┘
```

**验收标准**:
- [ ] 显示当前用户完整信息
- [ ] 可编辑真实姓名、邮箱、手机
- [ ] 用户名不可修改
- [ ] 显示最后登录信息
- [ ] 头像上传占位（Phase 4 实现）

---

#### Task 56: 创建用户服务类
**文件**: `src/Modules/User/UserService.pas` + `UserService.Intf.pas`

**职责**:
- 用户业务逻辑封装
- 用户权限检查
- 与认证服务集成

**接口定义**:
```pascal
type
  IUniUserService = interface(IInterface)
    ['{UNI-USER-SERVICE-001}']
    // 用户查询
    function GetUserByID(UserID: Integer): TUser_info;
    function GetUserByName(const UserName: string): TUserInfo;
    function GetUsers(const Filter: string; Page, PageSize: Integer): TArray<TUserInfo>;
    
    // 用户操作
    function CreateUser(const Info: TUserInfo): Integer;
    procedure UpdateUser(const Info: TUserInfo);
    procedure DeleteUser(UserID: Integer);
    
    // 状态管理
    procedure SetUserStatus(UserID, Status: Integer);
    function IsUserAvailable(UserID: Integer): Boolean;
    
    // 密码管理
    procedure ChangePassword(UserID: Integer; const OldPassword, NewPassword: string);
    procedure ResetPassword(UserID: Integer; const NewPassword: string);
  end;
  
  TUserInfo = record
    UserID: Integer;
    UserName: string;
    RealName: string;
    Email: string;
    Phone: string;
    Status: Integer;
    CreatedDate: TDateTime;
    // ... 其他字段
  end;
```

**验收标准**:
- [ ] 接口和实现分离
- [ ] 所有操作记录操作日志
- [ ] 权限检查集成
- [ ] 事务处理

---

#### Task 57: 用户管理模块集成测试
**文件**: `tests/Modules/UserTest.pas`

**测试用例**:
- [ ] 创建用户 - 正常流程
- [ ] 创建用户 - 重复用户名
- [ ] 创建用户 - 无效邮箱
- [ ] 编辑用户 - 正常流程
- [ ] 删除用户 - 正常流程
- [ ] 修改密码 - 正常流程
- [ ] 修改密码 - 旧密码错误
- [ ] 用户状态切换
- [ ] 权限检查

**验收标准**:
- [ ] 所有测试用例通过
- [ ] 代码覆盖率 > 80%

---

## 模块 2: 角色管理模块 (Tasks 58-63)

### 模块概述

角色管理模块实现 RBAC 模型中的角色管理，包括角色的定义、权限分配和用户分配。

### 数据库表

```sql
UniAdmin_Roles (
    RoleID INT PRIMARY KEY,
    RoleCode NVARCHAR(50) UNIQUE,
    RoleName NVARCHAR(100),
    Description NVARCHAR(500),
    DataScope NVARCHAR(20),
    SortOrder INT,
    Status INT,
    CreatedDate DATETIME,
    ModifiedDate DATETIME
)

UniAdmin_UserRoles (
    ID INT PRIMARY KEY,
    UserID INT,
    RoleID INT,
    CreatedDate DATETIME,
    UNIQUE(UserID, RoleID)
)

UniAdmin_RolePermissions (
    ID INT PRIMARY KEY,
    RoleID INT,
    PermissionID INT,
    CreatedDate DATETIME,
    UNIQUE(RoleID, PermissionID)
)
```

### 任务分解

#### Task 58: 创建角色数据模块
**文件**: `src/Modules/Role/RoleDataModule.pas`

**职责**:
- 角色表的 CRUD 操作
- 角色-用户关联管理
- 角色-权限关联管理

**关键方法**:
```pascal
type
  TRoleDataModule = class(TUniBaseModule)
  public
    // 角色操作
    function GetRoleByID(RoleID: Integer): TDataSet;
    function GetRoles: TDataSet;
    function CreateRole(const RoleCode, RoleName, Description: string): Integer;
    procedure UpdateRole(RoleID: Integer; const RoleName, Description: string);
    procedure DeleteRole(RoleID: Integer);
    
    // 用户分配
    procedure AssignUserToRole(UserID, RoleID: Integer);
    procedure RemoveUserFromRole(UserID, RoleID: Integer);
    function GetRoleUsers(RoleID: Integer): TDataSet;
    function GetUserRoles(UserID: Integer): TDataSet;
    
    // 权限分配
    procedure AssignPermissionToRole(RoleID, PermissionID: Integer);
    procedure RemovePermissionFromRole(RoleID, PermissionID: Integer);
    function GetRolePermissions(RoleID: Integer): TDataSet;
  end;
```

---

#### Task 59: 创建角色列表窗体
**文件**: `src/Modules/Role/RoleListFrame.pas`

**职责**:
- 角色列表显示
- 搜索和筛选
- 权限分配入口

**UI 布局**:
```
┌─────────────────────────────────────────────────────────┐
│ 🔍 搜索: [____________] [🔍 搜索]                       │
├─────────────────────────────────────────────────────────┤
│ [➕新增] [✏️编辑] [🗑️删除] [🔐权限] [👥用户] [🔄刷新]     │
├─────────────────────────────────────────────────────────┤
│ 角色编码 │ 角色名称 │ 描述         │ 状态 │ 用户数 │权限数│
│─────────┼──────────┼──────────────┼──────┼───────┼─────│
│ admin   │ 管理员   │ 系统管理员   │ 启用 │ 5     │ 全部 │
│ user    │ 普通用户 │ 基础用户权限 │ 启用 │ 20    │ 15  │
└─────────────────────────────────────────────────────────┘
```

---

#### Task 60: 创建角色编辑窗体
**文件**: `src/Modules/Role/RoleEditForm.pas`

**职责**:
- 角色信息新增/编辑
- 数据范围选择

**UI 布局**:
```
┌─────────────────────────────────────────┐
│           角色信息                        │
├─────────────────────────────────────────┤
│ 角色编码: [admin____________] *          │
│ 角色名称: [管理员__________] *          │
│ 描述:     [系统管理员______]             │
│                                          │
│ 数据范围:                                │
│   ○ 全部数据                             │
│   ○ 本部门数据                           │
│   ◉ 仅本人数据                           │
│   ○ 自定义数据                           │
│                                          │
│ 状态:     ◉ 启用  ○ 禁用                 │
│                                          │
│        [💾保存] [❌取消]                  │
└─────────────────────────────────────────┘
```

---

#### Task 61: 创建角色权限分配窗体
**文件**: `src/Modules/Role/RolePermissionForm.pas`

**职责**:
- 为角色分配权限
- 树形展示权限结构

**UI 布局**:
```
┌─────────────────────────────────────────┐
│ 角色: 管理员 - 权限分配                  │
├─────────────────────────────────────────┤
│ ☑ 用户管理                              │
│   ☑ 查看                                │
│   ☑ 新增                                │
│   ☑ 编辑                                │
│   ☑ 删除                                │
│ ☑ 角色管理                              │
│   ☑ 查看                                │
│   ☑ 新增                                │
│   ☐ 编辑                                │
│   ☐ 删除                                │
│                                          │
│        [💾保存] [❌取消]                  │
└─────────────────────────────────────────┘
```

---

#### Task 62: 创建角色用户分配窗体
**文件**: `src/Modules/Role/RoleUserAssignForm.pas`

**职责**:
- 为角色分配用户
- 移除角色的用户

**UI 布局**:
```
┌─────────────────────────────────────────┐
│ 角色: 管理员 - 用户分配                  │
├─────────────────────────────────────────┤
│ 已分配用户 (5)               可选用户 (15)│
│ ┌─────────────┐         ┌─────────────┐ │
│ │ admin       │   ◀─▶   │ user1       │ │
│ │ operator1   │         │ user2       │ │
│ │ operator2   │    │    │ user3       │ │
│ │ ...         │    ▼    │ ...         │ │
│ └─────────────┘         └─────────────┘ │
│        [➕添加] [➖移除]                   │
│                                          │
│        [💾保存] [❌取消]                  │
└─────────────────────────────────────────┘
```

---

#### Task 63: 角色管理模块集成测试
**文件**: `tests/Modules/RoleTest.pas`

**测试用例**:
- [ ] 创建角色 - 正常流程
- [ ] 创建角色 - 重复角色编码
- [ ] 分配权限 - 正常流程
- [ ] 分配用户 - 正常流程
- [ ] 删除角色 - 有用户时提示
- [ ] 权限继承检查

---

## 模块 3: 菜单管理模块 (Tasks 64-68)

### 模块概述

菜单管理模块提供系统菜单的树形结构管理，支持多级菜单、图标配置和权限绑定。

### 数据库表

```sql
UniAdmin_Menus (
    MenuID INT PRIMARY KEY,
    ParentID INT,
    MenuName NVARCHAR(100),
    MenuCode NVARCHAR(100) UNIQUE,
    Icon NVARCHAR(50),
    RoutePath NVARCHAR(255),
    PermissionCode NVARCHAR(100),
    SortOrder INT,
    IsVisible BIT,
    CreatedDate DATETIME,
    ModifiedDate DATETIME
)
```

### 任务分解

#### Task 64: 创建菜单数据模块
**文件**: `src/Modules/Menu/MenuDataModule.pas`

**职责**:
- 菜单树查询
- 菜单 CRUD 操作
- 菜单排序

**关键方法**:
```pascal
type
  TMenuDataModule = class(TUniBaseModule)
  public
    function GetMenuTree: TDataSet;
    function GetMenuByID(MenuID: Integer): TDataSet;
    function GetMenusByParent(ParentID: Integer): TDataSet;
    function CreateMenu(const MenuName, MenuCode, Icon, RoutePath: string; 
      ParentID: Integer): Integer;
    procedure UpdateMenu(MenuID: Integer; const MenuName, Icon, RoutePath: string);
    procedure DeleteMenu(MenuID: Integer);
    procedure UpdateMenuOrder(MenuID: Integer; NewOrder: Integer);
  end;
```

---

#### Task 65: 创建菜单树编辑窗体
**文件**: `src/Modules/Menu/MenuTreeFrame.pas`

**职责**:
- 树形展示菜单结构
- 拖拽排序
- 右键菜单操作

**UI 布局**:
```
┌─────────────────────────────────────────┐
│ 系统管理                    [➕根菜单]   │
│ ├─ 用户管理               [✏️][🗑️]      │
│ │  └─ 用户列表                            │
│ ├─ 角色管理                              │
│ │  ├─ 角色列表                            │
│ │  └─ 权限分配                            │
│ └─ 菜单管理                              │
└─────────────────────────────────────────┘
```

---

#### Task 66: 创建菜单编辑窗体
**文件**: `src/Modules/Menu/MenuEditForm.pas`

**职责**:
- 菜单信息编辑
- 父菜单选择
- 图标选择

**UI 布局**:
```
┌─────────────────────────────────────────┐
│           菜单信息                        │
├─────────────────────────────────────────┤
│ 父菜单:  [系统管理 ▼] (无)               │
│                                          │
│ 菜单名称: [用户管理________] *          │
│ 菜单编码: [user:manage_____] *          │
│                                          │
│ 图标:     [user.png ▼]      [预览]      │
│ 路由:     [/system/users___]            │
│ 权限:     [user:view ▼]                 │
│                                          │
│ 排序号:   [10__]                         │
│ 可见:     ☑ 显示在菜单中                 │
│                                          │
│        [💾保存] [❌取消]                  │
└─────────────────────────────────────────┘
```

---

#### Task 67: 创建图标选择器
**文件**: `src/Modules/Menu/IconPickerDialog.pas`

**职责**:
- 图标预览和选择
- 支持自定义图标上传

**UI 布局**:
```
┌─────────────────────────────────────────┐
│           选择图标                        │
├─────────────────────────────────────────┤
│ 搜索: [___________]                      │
│                                          │
│ 👤 user.png    🏠 home.png    ⚙️ gear.png│
│ 👥 users.png   📁 folder.png  📄 file.png│
│ 🔒 lock.png    🔓 unlock.png  🔑 key.png│
│ ...                                     │
│                                          │
│        [✔️确定] [❌取消]                  │
└─────────────────────────────────────────┘
```

---

#### Task 68: 菜单管理模块集成测试
**文件**: `tests/Modules/MenuTest.pas`

**测试用例**:
- [ ] 创建根菜单
- [ ] 创建子菜单
- [ ] 菜单排序
- [ ] 删除有子菜单的菜单
- [ ] 权限绑定
- [ ] 菜单树渲染

---

## 模块 4: 数据字典模块 (Tasks 69-73)

> **注意**: 基础的数据字典插件已在 Phase 1 中创建。此模块将增强为完整的系统级模块。

### 任务分解

#### Task 69: 增强数据字典数据模块
**文件**: `src/Modules/Dictionary/DictionaryDataModule.pas`

**职责**:
- 字典类型管理
- 字典项管理
- 字典缓存

---

#### Task 70: 创建字典类型管理窗体
**文件**: `src/Modules/Dictionary/DictTypeFrame.pas`

---

#### Task 71: 创建字典项管理窗体
**文件**: `src/Modules/Dictionary/DictItemFrame.pas`

---

#### Task 72: 创建字典服务
**文件**: `src/Modules/Dictionary/DictionaryService.pas`

---

#### Task 73: 数据字典模块测试
**文件**: `tests/Modules/DictionaryTest.pas`

---

## 模块 5: 系统配置模块 (Tasks 74-78)

### 模块概述

系统配置模块提供系统级参数的配置管理。

### 数据库表

```sql
UniAdmin_Configs (
    ConfigID INT PRIMARY KEY,
    ConfigKey NVARCHAR(100) UNIQUE,
    ConfigValue NVARCHAR(MAX),
    Category NVARCHAR(50),
    Description NVARCHAR(500),
    ValueType NVARCHAR(20),
    CreatedDate DATETIME,
    ModifiedDate DATETIME
)
```

### 任务分解

#### Task 74: 创建配置数据模块
**文件**: `src/Modules/Config/ConfigDataModule.pas`

---

#### Task 75: 创建配置分类管理
**文件**: `src/Modules/Config/ConfigCategoryFrame.pas`

**分类**:
- 系统设置 (System)
- 安全设置 (Security)
- 邮件设置 (Email)
- 短信设置 (SMS)
- 存储设置 (Storage)

---

#### Task 76: 创建配置编辑窗体
**文件**: `src/Modules/Config/ConfigEditForm.pas`

---

#### Task 77: 创建配置服务
**文件**: `src/Modules/Config/ConfigService.pas`

---

#### Task 78: 系统配置模块测试
**文件**: `tests/Modules/ConfigTest.pas`

---

## 模块 6: 日志审计模块 (Tasks 79-85)

### 模块概述

日志审计模块记录系统操作日志，包括登录日志、操作日志和数据变更日志。

### 数据库表

```sql
UniAdmin_LoginLogs (
    LogID INT PRIMARY KEY,
    UserID INT,
    UserName NVARCHAR(50),
    LoginIP NVARCHAR(50),
    LoginTime DATETIME,
    Status INT,
    UserAgent NVARCHAR(500)
)

UniAdmin_OperationLogs (
    LogID INT PRIMARY KEY,
    UserID INT,
    UserName NVARCHAR(50),
    Module NVARCHAR(50),
    Operation NVARCHAR(50),
    Description NVARCHAR(500),
    RequestData NVARCHAR(MAX),
    ResponseData NVARCHAR(MAX),
    IP NVARCHAR(50),
    CreatedDate DATETIME
)

UniAdmin_DataChangeLogs (
    LogID INT PRIMARY KEY,
    UserID INT,
    UserName NVARCHAR(50),
    TableName NVARCHAR(100),
    RecordID INT,
    Operation NVARCHAR(20),
    OldValue NVARCHAR(MAX),
    NewValue NVARCHAR(MAX),
    CreatedDate DATETIME
)
```

### 任务分解

#### Task 79: 创建日志数据模块
**文件**: `src/Modules/Log/LogDataModule.pas`

---

#### Task 80: 创建登录日志查询窗体
**文件**: `src/Modules/Log/LoginLogFrame.pas`

---

#### Task 81: 创建操作日志查询窗体
**文件**: `src/Modules/Log/OperationLogFrame.pas`

---

#### Task 82: 创建数据变更日志查询窗体
**文件**: `src/Modules/Log/DataChangeLogFrame.pas`

---

#### Task 83: 创建日志服务
**文件**: `src/Modules/Log/LogService.pas`

---

#### Task 84: 创建日志导出功能
**文件**: `src/Modules/Log/LogExport.pas`

---

#### Task 85: 日志审计模块测试
**文件**: `tests/Modules/LogTest.pas`

---

## 模块 7: 定时任务模块 (Tasks 86-92)

### 模块概述

定时任务模块提供系统定时任务的调度管理。

### 数据库表

```sql
UniAdmin_ScheduledTasks (
    TaskID INT PRIMARY KEY,
    TaskName NVARCHAR(100),
    TaskCode NVARCHAR(100) UNIQUE,
    CronExpression NVARCHAR(100),
    HandlerClass NVARCHAR(200),
    Parameters NVARCHAR(MAX),
    Status INT,
    LastRunTime DATETIME,
    NextRunTime DATETIME,
    CreatedDate DATETIME,
    ModifiedDate DATETIME
)

UniAdmin_TaskExecutionLogs (
    LogID INT PRIMARY KEY,
    TaskID INT,
    StartTime DATETIME,
    EndTime DATETIME,
    Status INT,
    ErrorMessage NVARCHAR(MAX),
    Result NVARCHAR(MAX)
)
```

### 任务分解

#### Task 86: 创建任务调度器基础
**文件**: `src/Modules/Scheduler/SchedulerService.pas`

---

#### Task 87: 创建任务管理窗体
**文件**: `src/Modules/Scheduler/TaskListFrame.pas`

---

#### Task 88: 创建任务编辑窗体
**文件**: `src/Modules/Scheduler/TaskEditForm.pas`

---

#### Task 89: 创建任务执行日志窗体
**文件**: `src/Modules/Scheduler/TaskLogFrame.pas`

---

#### Task 90: 创建任务处理器基类
**文件**: `src/Modules/Scheduler/TaskHandler.pas`

---

#### Task 91: 示例任务实现
**文件**: `src/Modules/Scheduler/SampleHandlers.pas`

---

#### Task 92: 定时任务模块测试
**文件**: `tests/Modules/SchedulerTest.pas`

---

## Phase 3 集成 (Tasks 93-100)

### Task 93: 注册所有模块到插件系统
**文件**: `src/Core/Plugin/UniModuleRegistry.pas` 更新

---

### Task 94: 创建系统管理主菜单
**文件**: `src/Core/Menu/SystemMenuSetup.pas`

---

### Task 95: 集成权限初始化
**文件**: `Database/Seed/03_SystemPermissions.sql`

---

### Task 96: 集成测试
**文件**: `tests/Phase3/IntegrationTest.pas`

---

### Task 97: E2E 测试
**文件**: `tests/Phase3/E2ETest.pas`

---

### Task 98: 性能测试
**文件**: `tests/Phase3/PerformanceTest.pas`

---

### Task 99: API 文档更新
**文件**: `docs/API.md` 更新

---

### Task 100: Phase 3 验收报告
**文件**: `docs/Phase3-Report.md`

---

## 执行计划

### 第 1 周：用户管理模块 (Tasks 51-57)
- Day 1-2: 数据模块 + 列表窗体
- Day 3-4: 编辑窗体 + 密码管理
- Day 5: 个人资料 + 服务 + 测试

### 第 2 周：角色管理模块 (Tasks 58-63) + 菜单管理 (Tasks 64-68)
- Day 1-3: 角色管理
- Day 4-5: 菜单管理

### 第 3 周：数据字典 (Tasks 69-73) + 系统配置 (Tasks 74-78)
- Day 1-2: 数据字典
- Day 3-5: 系统配置

### 第 4 周：日志审计 (Tasks 79-85) + 集成 (Tasks 93-100)
- Day 1-3: 日志审计
- Day 4-5: 集成测试和文档

---

## 验收标准

### 功能验收
- [ ] 所有模块的 CRUD 功能正常
- [ ] 权限控制正确执行
- [ ] 数据验证有效
- [ ] 操作日志记录完整

### 质量验收
- [ ] 代码编译无错误
- [ ] 遵循 Phase 2 的架构
- [ ] 单元测试覆盖率 > 80%
- [ ] 代码审查通过

### 性能验收
- [ ] 列表查询 < 1秒 (1000条数据)
- [ ] 表单保存 < 500ms
- [ ] 内存占用合理

---

**文档版本**: 1.0  
**创建日期**: 2026-02-24  
**作者**: Claude (AI Agent)  
**状态**: 待执行

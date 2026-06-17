[根目录](../../CLAUDE.md) > **src** > **Modules**

# Modules 模块 - 业务模块层

> **职责**: 提供系统管理的核心业务功能模块
> **状态**: ✅ 完成
> **覆盖率**: 85%

---

## 模块职责

Modules 模块包含 UniAdmin 系统的核心业务功能，提供：

- **用户管理** - 用户增删改查、密码管理、个人中心
- **角色管理** - 角色定义、权限分配、用户关联
- **菜单管理** - 动态菜单树、图标配置、排序管理
- **数据字典** - 字典类型管理、字典项维护
- **系统配置** - 系统参数配置、分类管理
- **日志审计** - 登录日志、操作日志、数据变更日志
- **定时任务** - 任务调度、执行日志、手动执行
- **共享组件** - 图标选择器等通用组件

---

## 目录结构

```
Modules/
├── User/                   # 用户管理
│   ├── UserListFrame.pas      # 用户列表
│   ├── UserEditForm.pas       # 用户编辑
│   ├── UserPasswordDialog.pas # 密码修改
│   ├── UserProfileFrame.pas   # 个人中心
│   ├── UserDataModule.pas     # 数据模块
│   ├── UserService.Intf.pas   # 服务接口
│   └── UserService.pas        # 服务实现
├── Role/                   # 角色管理
│   ├── RoleListFrame.pas      # 角色列表
│   ├── RoleEditForm.pas       # 角色编辑
│   ├── RolePermissionDialog.pas # 权限分配
│   ├── RoleUserDialog.pas     # 用户关联
│   └── RoleDataModule.pas     # 数据模块
├── Menu/                   # 菜单管理
│   ├── MenuTreeFrame.pas      # 菜单树
│   ├── MenuEditForm.pas       # 菜单编辑
│   └── MenuDataModule.pas     # 数据模块
├── Dictionary/             # 数据字典
│   ├── DictTypeFrame.pas      # 字典类型
│   ├── DictItemFrame.pas      # 字典项
│   ├── DictionaryDataModule.pas # 数据模块
│   ├── DictionaryService.Intf.pas # 服务接口
│   └── DictionaryService.pas  # 服务实现
├── Config/                 # 系统配置
│   ├── ConfigCategoryFrame.pas # 配置分类
│   ├── ConfigEditForm.pas     # 配置编辑
│   ├── ConfigDataModule.pas   # 数据模块
│   ├── ConfigService.Intf.pas # 服务接口
│   └── ConfigService.pas      # 服务实现
├── Log/                    # 日志审计
│   ├── LoginLogFrame.pas      # 登录日志
│   ├── OperationLogFrame.pas  # 操作日志
│   ├── DataChangeLogFrame.pas # 数据变更日志
│   ├── LogDataModule.pas      # 数据模块
│   ├── LogService.pas         # 服务实现
│   └── LogExport.pas          # 日志导出
├── Scheduler/              # 定时任务
│   ├── TaskManageFrame.pas    # 任务管理
│   ├── TaskLogFrame.pas       # 任务日志
│   └── SampleTasks.pas        # 示例任务
└── Shared/                 # 共享组件
    └── IconSelector.pas       # 图标选择器
```

---

## 入口与启动

### 模块注册

所有业务模块在主程序 `UniAdmin.dpr` 中注册：

```pascal
uses
  // 业务模块 - 用户管理
  UserListFrame in 'Modules\User\UserListFrame.pas',
  UserEditForm in 'Modules\User\UserEditForm.pas',
  UserService in 'Modules\User\UserService.pas',
  // 业务模块 - 角色管理
  RoleListFrame in 'Modules\Role\RoleListFrame.pas',
  RoleEditForm in 'Modules\Role\RoleEditForm.pas',
  // ... 其他模块
```

### 菜单集成

系统菜单在 `SystemMenuSetup.pas` 中配置：

```pascal
procedure SetupSystemMenus;
begin
  // 用户管理菜单
  RegisterMenu('User', '用户管理', 'UserListFrame', 'user:list');

  // 角色管理菜单
  RegisterMenu('Role', '角色管理', 'RoleListFrame', 'role:list');

  // ... 其他菜单
end;
```

---

## 对外接口

### 用户服务接口

**IUserService** (`User/UserService.Intf.pas`)

```pascal
IUserService = interface(IInterface)
  ['{GUID}']
  function GetUsers(const Filter: string): TDataSet;
  function GetUserByID(UserID: Integer): TUserInfo;
  function CreateUser(const Info: TUserInfo): Integer;
  procedure UpdateUser(const Info: TUserInfo);
  procedure DeleteUser(UserID: Integer);
  procedure ChangePassword(UserID: Integer; const NewPassword: string);
end;
```

### 角色服务接口

**IRoleService** (隐式接口，通过 RoleDataModule)

```pascal
// 功能包括:
// - 角色增删改查
// - 权限分配
// - 用户关联
```

### 字典服务接口

**IDictionaryService** (`Dictionary/DictionaryService.Intf.pas`)

```pascal
IDictionaryService = interface(IInterface)
  ['{GUID}']
  function GetDictTypes: TDataSet;
  function GetDictItems(TypeCode: string): TDataSet;
  procedure AddDictType(const Info: TDictTypeInfo);
  procedure AddDictItem(const Info: TDictItemInfo);
end;
```

### 配置服务接口

**IConfigService** (`Config/ConfigService.Intf.pas`)

```pascal
IConfigService = interface(IInterface)
  ['{GUID}']
  function GetConfig(const Key: string): string;
  procedure SetConfig(const Key, Value: string);
  function GetConfigByCategory(Category: string): TDataSet;
end;
```

---

## 关键依赖与配置

### 依赖项

| 依赖 | 模块 | 用途 |
|------|------|------|
| Core.UI | BaseCrudFrame | CRUD 基类 |
| Core.Auth | UniAuthService | 认证服务 |
| Core.Permission | UniPermissionManager | 权限检查 |
| Core.Data | UniDataModule | 数据访问基类 |

### 数据库依赖

| 表名 | 使用模块 | 说明 |
|------|----------|------|
| `UniAdmin_Users` | User, Role | 用户信息 |
| `UniAdmin_Roles` | Role | 角色信息 |
| `UniAdmin_UserRoles` | User, Role | 用户角色关联 |
| `UniAdmin_Menus` | Menu | 菜单树 |
| `UniAdmin_DictTypes` | Dictionary | 字典类型 |
| `UniAdmin_DictItems` | Dictionary | 字典项 |
| `UniAdmin_Configs` | Config | 系统配置 |
| `UniAdmin_LoginLogs` | Log | 登录日志 |
| `UniAdmin_OperationLogs` | Log | 操作日志 |
| `UniAdmin_DataChangeLogs` | Log | 数据变更日志 |
| `UniAdmin_Tasks` | Scheduler | 定时任务 |
| `UniAdmin_TaskLogs` | Scheduler | 任务执行日志 |

---

## 数据模型

### 用户模型

```pascal
TUserInfo = record
  UserID: Integer;
  UserName: string;
  RealName: string;
  Email: string;
  Phone: string;
  Avatar: string;
  Status: Integer;
  CreatedDate: TDateTime;
  ModifiedDate: TDateTime;
end;
```

### 角色模型

```pascal
TRoleInfo = record
  RoleID: Integer;
  RoleCode: string;
  RoleName: string;
  Description: string;
  DataScope: string;  // 'all', 'dept', 'self', 'custom'
  SortOrder: Integer;
  Status: Integer;
end;
```

### 字典模型

```pascal
TDictTypeInfo = record
  TypeID: Integer;
  TypeCode: string;
  TypeName: string;
  Description: string;
  SortOrder: Integer;
  Status: Integer;
end;

TDictItemInfo = record
  ItemID: Integer;
  TypeID: Integer;
  ItemCode: string;
  ItemName: string;
  ItemValue: string;
  SortOrder: Integer;
  Status: Integer;
end;
```

---

## 测试与质量

### 测试覆盖

| 模块 | 测试状态 | 说明 |
|------|----------|------|
| User | ⚠️ 待补充 | 需要用户服务单元测试 |
| Role | ⚠️ 待补充 | 需要角色权限测试 |
| Menu | ⚠️ 待补充 | 需要菜单树测试 |
| Dictionary | ❓ 未评估 | 评估中 |
| Config | ❓ 未评估 | 评估中 |
| Log | ⚠️ 待补充 | 需要日志导出测试 |
| Scheduler | ⚠️ 待补充 | 需要任务调度测试 |

### 推荐测试用例

```pascal
// 用户服务测试
TUserServiceTest = class(TTestCase)
published
  procedure TestCreateUser;
  procedure TestDuplicateUserName;
  procedure TestChangePassword;
  procedure TestDeleteUserWithRoles;
end;

// 角色服务测试
TRoleServiceTest = class(TTestCase)
published
  procedure TestCreateRole;
  procedure TestAssignPermissions;
  procedure TestAssignUsers;
  procedure TestDataScopeFiltering;
end;
```

---

## 常见问题 (FAQ)

### Q: 如何添加新的业务模块?

A: 参考现有模块结构：

1. 在 `Modules/` 创建目录
2. 创建 DataModule (数据访问)
3. 创建 Service (业务逻辑，可选)
4. 创建 Frame (列表界面)
5. 创建 Form (编辑界面)
6. 在主程序注册
7. 在 SystemMenuSetup 添加菜单

### Q: 如何实现数据权限过滤?

A: 在 DataModule 的查询中添加数据权限过滤：

```pascal
// 根据角色数据权限过滤
if UserRole.DataScope = 'self' then
  SQL.Add('AND CreatedBy = :UserID')
else if UserRole.DataScope = 'dept' then
  SQL.Add('AND DeptID IN (SELECT DeptID FROM UserDepts WHERE UserID = :UserID)');
```

### Q: 如何导出日志?

A: 使用 `LogExport.pas` 中的导出功能：

```pascal
with TLogExport.Create do
try
  ExportToExcel('LoginLog', AStartDate, AEndDate, 'LoginLogs.xlsx');
finally
  Free;
end;
```

---

## 相关文件清单

### 用户管理

- `User/UserListFrame.pas` - 用户列表界面
- `User/UserEditForm.pas` - 用户编辑窗体
- `User/UserPasswordDialog.pas` - 密码修改对话框
- `User/UserProfileFrame.pas` - 个人中心
- `User/UserDataModule.pas` - 用户数据模块
- `User/UserService.Intf.pas` - 用户服务接口
- `User/UserService.pas` - 用户服务实现

### 角色管理

- `Role/RoleListFrame.pas` - 角色列表界面
- `Role/RoleEditForm.pas` - 角色编辑窗体
- `Role/RolePermissionDialog.pas` - 权限分配对话框
- `Role/RoleUserDialog.pas` - 用户关联对话框
- `Role/RoleDataModule.pas` - 角色数据模块

### 菜单管理

- `Menu/MenuTreeFrame.pas` - 菜单树界面
- `Menu/MenuEditForm.pas` - 菜单编辑窗体
- `Menu/MenuDataModule.pas` - 菜单数据模块

### 数据字典

- `Dictionary/DictTypeFrame.pas` - 字典类型界面
- `Dictionary/DictItemFrame.pas` - 字典项界面
- `Dictionary/DictionaryDataModule.pas` - 字典数据模块
- `Dictionary/DictionaryService.Intf.pas` - 字典服务接口
- `Dictionary/DictionaryService.pas` - 字典服务实现

### 系统配置

- `Config/ConfigCategoryFrame.pas` - 配置分类界面
- `Config/ConfigEditForm.pas` - 配置编辑窗体
- `Config/ConfigDataModule.pas` - 配置数据模块
- `Config/ConfigService.Intf.pas` - 配置服务接口
- `Config/ConfigService.pas` - 配置服务实现

### 日志审计

- `Log/LoginLogFrame.pas` - 登录日志界面
- `Log/OperationLogFrame.pas` - 操作日志界面
- `Log/DataChangeLogFrame.pas` - 数据变更日志界面
- `Log/LogDataModule.pas` - 日志数据模块
- `Log/LogService.pas` - 日志服务
- `Log/LogExport.pas` - 日志导出

### 定时任务

- `Scheduler/TaskManageFrame.pas` - 任务管理界面
- `Scheduler/TaskLogFrame.pas` - 任务日志界面
- `Scheduler/SampleTasks.pas` - 示例任务

### 共享组件

- `Shared/IconSelector.pas` - 图标选择器

---

## 变更记录 (Changelog)

| 日期 | 操作 | 说明 |
|------|------|------|
| 2026-03-02 | 初始化 | 创建 Modules 模块文档 |

---

*模块版本: 1.0*
*最后更新: 2026-03-02*

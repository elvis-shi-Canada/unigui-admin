# UniAdmin API 文档

## 目录

1. [核心服务](#核心服务)
2. [数据访问层](#数据访问层)
3. [UI 组件](#ui-组件)
4. [使用示例](#使用示例)
5. [最佳实践](#最佳实践)

---

## 核心服务

### IUniConnectionManager
数据库连接管理服务，提供线程安全的连接池功能。

**单元位置**：`src/Core/Data/UniConnectionManager.pas`

```pascal
IUniConnectionManager = interface
  ['{YOUR-GUID-HERE}']
  
  /// <summary>
  /// 获取数据库连接
  /// </summary>
  /// <param name="Params">连接参数</param>
  /// <returns>FireDAC 连接对象</returns>
  function GetConnection(const Params: TConnectionParams): TFDConnection;

  /// <summary>
  /// 获取默认连接（使用配置文件）
  /// </summary>
  function GetDefaultConnection: TFDConnection;

  /// <summary>
  /// 释放连接回连接池
  /// </summary>
  /// <param name="Connection">要释放的连接</param>
  procedure ReleaseConnection(var Connection: TFDConnection);

  /// <summary>
  /// 测试数据库连接
  /// </summary>
  /// <param name="Params">连接参数</param>
  /// <returns>连接是否成功</returns>
  function TestConnection(const Params: TConnectionParams): Boolean;

  /// <summary>
  /// 获取当前活动连接数
  /// </summary>
  function GetActiveConnectionCount: Integer;
end;
```

**使用示例**：
```pascal
var
  ConnMgr: IUniConnectionManager;
  Conn: TFDConnection;
begin
  ConnMgr := TUniServices.ConnectionManager;
  Conn := ConnMgr.GetDefaultConnection;
  try
    // 使用连接执行查询
    Conn.ExecSQL('UPDATE Users SET Status = 1 WHERE ID = :ID', [UserID]);
  finally
    ConnMgr.ReleaseConnection(Conn);
  end;
end;
```

---

### IUniMetadataManager
元数据管理服务，提供数据库表结构信息和审计字段自动填充。

**单元位置**：`src/Core/Metadata/UniMetadataManager.pas`

```pascal
IUniMetadataManager = interface
  ['{YOUR-GUID-HERE}']
  
  /// <summary>
  /// 获取表的所有字段信息
  /// </summary>
  function GetTableFields(const TableName: string): TArray<TFieldInfo>;

  /// <summary>
  /// 获取表的显示名称
  /// </summary>
  function GetTableDisplayName(const TableName: string): string;

  /// <summary>
  /// 检查字段是否为审计字段
  /// </summary>
  function IsAuditField(const FieldName: string): Boolean;

  /// <summary>
  /// 自动填充审计字段
  /// </summary>
  /// <param name="TableName">表名</param>
  /// <param name="DataSet">数据集</param>
  /// <param name="UserID">当前用户ID</param>
  procedure FillAuditFields(const TableName: string; 
                            DataSet: TDataSet; 
                            UserID: Integer);

  /// <summary>
  /// 获取主键字段名
  /// </summary>
  function GetPrimaryKeyField(const TableName: string): string;

  /// <summary>
  /// 刷新元数据缓存
  /// </summary>
  procedure RefreshMetadata;
end;
```

**使用示例**：
```pascal
var
  MetaMgr: IUniMetadataManager;
  Fields: TArray<TFieldInfo>;
  Field: TFieldInfo;
begin
  MetaMgr := TUniServices.MetadataManager;
  
  // 获取表字段信息
  Fields := MetaMgr.GetTableFields('Users');
  
  for Field in Fields do
  begin
    WriteLn(Field.FieldName + ': ' + Field.DisplayName);
  end;
  
  // 自动填充审计字段
  MetaMgr.FillAuditFields('Users', Query, CurrentUserID);
end;
```

---

### IUniAuthService
用户认证服务，提供登录、登出、密码管理等功能。

**单元位置**：`src/Core/Services/UniAuthService.pas`

```pascal
IUniAuthService = interface
  ['{YOUR-GUID-HERE}']
  
  /// <summary>
  /// 用户登录
  /// </summary>
  /// <param name="UserName">用户名</param>
  /// <param name="Password">密码</param>
  /// <returns>登录结果，包含 Token 和用户信息</returns>
  function Login(const UserName, Password: string): TLoginResult;

  /// <summary>
  /// 用户登出
  /// </summary>
  /// <param name="SessionID">会话ID</param>
  procedure Logout(const SessionID: string);

  /// <summary>
  /// 验证 Token 是否有效
  /// </summary>
  /// <param name="Token">访问令牌</param>
  /// <returns>Token 是否有效</returns>
  function ValidateToken(const Token: string): Boolean;

  /// <summary>
  /// 修改密码
  /// </summary>
  /// <param name="UserID">用户ID</param>
  /// <param name="OldPassword">旧密码</param>
  /// <param name="NewPassword">新密码</param>
  /// <returns>是否修改成功</returns>
  function ChangePassword(const UserID: Integer; 
                          const OldPassword, NewPassword: string): Boolean;

  /// <summary>
  /// 验证密码强度
  /// </summary>
  /// <param name="Password">待验证的密码</param>
  /// <returns>密码强度：0-5（5为最强）</returns>
  function ValidatePassword(const Password: string): Integer;

  /// <summary>
  /// 根据 Token 获取用户信息
  /// </summary>
  function GetUserByToken(const Token: string): TUserInfo;

  /// <summary>
  /// 检查用户是否在线
  /// </summary>
  function IsUserOnline(const UserID: Integer): Boolean;
end;
```

**使用示例**：
```pascal
var
  AuthService: IUniAuthService;
  LoginResult: TLoginResult;
begin
  AuthService := TUniServices.AuthService;
  
  // 登录
  LoginResult := AuthService.Login('admin', 'password123');
  
  if LoginResult.Success then
  begin
    ShowMessage('登录成功！Token: ' + LoginResult.Token);
  end
  else
  begin
    ShowMessage('登录失败：' + LoginResult.ErrorMessage);
  end;
  
  // 验证密码强度
  if AuthService.ValidatePassword('weak') < 3 then
    ShowMessage('密码强度不足，请使用更强的密码');
end;
```

---

### IUniPermissionManager
权限管理服务，提供 RBAC 权限检查和管理功能。

**单元位置**：`src/Core/Services/UniPermissionManager.pas`

```pascal
IUniPermissionManager = interface
  ['{YOUR-GUID-HERE}']
  
  /// <summary>
  /// 检查用户是否拥有指定权限
  /// </summary>
  /// <param name="UserID">用户ID</param>
  /// <param name="PermissionCode">权限码</param>
  /// <returns>是否有权限</returns>
  function HasPermission(const UserID: Integer; 
                         const PermissionCode: string): Boolean;

  /// <summary>
  /// 获取用户的所有权限
  /// </summary>
  /// <param name="UserID">用户ID</param>
  /// <returns>权限信息数组</returns>
  function GetUserPermissions(const UserID: Integer): TArray<TPermissionInfo>;

  /// <summary>
  /// 获取用户的所有角色
  /// </summary>
  /// <param name="UserID">用户ID</param>
  /// <returns>角色信息数组</returns>
  function GetRoles(const UserID: Integer): TArray<TRoleInfo>;

  /// <summary>
  /// 为用户分配角色
  /// </summary>
  /// <param name="UserID">用户ID</param>
  /// <param name="RoleID">角色ID</param>
  /// <returns>是否分配成功</returns>
  function AssignRoleToUser(const UserID, RoleID: Integer): Boolean;

  /// <summary>
  /// 移除用户的角色
  /// </summary>
  function RemoveRoleFromUser(const UserID, RoleID: Integer): Boolean;

  /// <summary>
  /// 获取用户对指定资源的数据范围
  /// </summary>
  /// <param name="UserID">用户ID</param>
  /// <param name="Resource">资源标识</param>
  /// <returns>数据范围：all/custom/self</returns>
  function GetDataScope(const UserID: Integer; 
                        const Resource: string): string;

  /// <summary>
  /// 刷新权限缓存
  /// </summary>
  procedure RefreshCache(const UserID: Integer);
end;
```

**使用示例**：
```pascal
var
  PermMgr: IUniPermissionManager;
  Roles: TArray<TRoleInfo>;
begin
  PermMgr := TUniServices.PermissionManager;
  
  // 检查权限
  if not PermMgr.HasPermission(CurrentUserID, 'user:delete') then
  begin
    ShowMessage('您没有删除用户的权限');
    Exit;
  end;
  
  // 获取用户角色
  Roles := PermMgr.GetRoles(CurrentUserID);
  
  // 获取数据范围
  case PermMgr.GetDataScope(CurrentUserID, 'user:list') of
    'all': ShowMessage('可以查看所有用户');
    'self': ShowMessage('只能查看自己的信息');
    'custom': ShowMessage('可以查看指定部门的用户');
  end;
end;
```

---

### IUniMenuManager
菜单管理服务，提供菜单树的获取和管理功能。

**单元位置**：`src/Core/Services/UniMenuManager.pas`

```pascal
IUniMenuManager = interface
  ['{YOUR-GUID-HERE}']
  
  /// <summary>
  /// 获取完整的菜单树
  /// </summary>
  /// <returns>菜单项数组（树形结构）</returns>
  function GetMenuTree: TArray<TMenuItem>;

  /// <summary>
  /// 根据ID获取菜单
  /// </summary>
  function GetMenuByID(const MenuID: Integer): TMenuItem;

  /// <summary>
  /// 添加新菜单
  /// </summary>
  function AddMenu(const Menu: TMenuItem): Boolean;

  /// <summary>
  /// 更新菜单信息
  /// </summary>
  function UpdateMenu(const Menu: TMenuItem): Boolean;

  /// <summary>
  /// 删除菜单（级联删除子菜单）
  /// </summary>
  function DeleteMenu(const MenuID: Integer): Boolean;

  /// <summary>
  /// 获取用户有权限访问的菜单
  /// </summary>
  /// <param name="UserID">用户ID</param>
  /// <returns>过滤后的菜单树</returns>
  function GetUserMenus(const UserID: Integer): TArray<TMenuItem>;

  /// <summary>
  /// 根据权限码过滤菜单
  /// </summary>
  function FilterMenusByPermission(
    const Menus: TArray<TMenuItem>; 
    const Permissions: TArray<string>): TArray<TMenuItem>;
end;
```

**使用示例**：
```pascal
var
  MenuMgr: IUniMenuManager;
  Menus: TArray<TMenuItem>;
begin
  MenuMgr := TUniServices.MenuManager;
  
  // 获取当前用户的菜单
  Menus := MenuMgr.GetUserMenus(CurrentUserID);
  
  // 构建菜单树 UI
  BuildMenuTree(Menus);
end;
```

---

### IUniThemeManager
主题管理服务，提供主题切换和管理功能。

**单元位置**：`src/Core/Services/UniThemeManager.pas`

```pascal
IUniThemeManager = interface
  ['{YOUR-GUID-HERE}']
  
  /// <summary>
  /// 获取当前主题
  /// </summary>
  function GetCurrentTheme: string;

  /// <summary>
  /// 设置当前主题
  /// </summary>
  procedure SetCurrentTheme(const ThemeName: string);

  /// <summary>
  /// 获取所有可用主题
  /// </summary>
  function GetAvailableThemes: TArray<string>;

  /// <summary>
  /// 保存用户主题偏好
  /// </summary>
  procedure SaveUserPreference(const UserID: Integer; 
                               const ThemeName: string);

  /// <summary>
  /// 加载用户主题偏好
  /// </summary>
  function LoadUserPreference(const UserID: Integer): string;
end;
```

---

### IUniLayoutManager
布局管理服务，提供窗体布局的保存和恢复功能。

**单元位置**：`src/Core/Services/UniLayoutManager.pas`

```pascal
IUniLayoutManager = interface
  ['{YOUR-GUID-HERE}']
  
  /// <summary>
  /// 保存窗体布局
  /// </summary>
  procedure SaveLayout(const FormName: string; 
                       const LayoutJSON: string);

  /// <summary>
  /// 加载窗体布局
  /// </summary>
  function LoadLayout(const FormName: string): string;

  /// <summary>
  /// 保存用户布局偏好
  /// </summary>
  procedure SaveUserLayout(const UserID: Integer; 
                           const FormName: string; 
                           const LayoutJSON: string);

  /// <summary>
  /// 加载用户布局偏好
  /// </summary>
  function LoadUserLayout(const UserID: Integer; 
                          const FormName: string): string;
end;
```

---

## 数据访问层

### TConnectionParams
数据库连接参数记录。

```pascal
TConnectionParams = record
  DriverID: string;      // 驱动类型：MySQL/PostgreSQL/SQLite
  Server: string;        // 服务器地址
  Port: Integer;         // 端口号
  Database: string;      // 数据库名
  UserName: string;      // 用户名
  Password: string;      // 密码
  CharacterSet: string;  // 字符集
  class function Create(const DriverID, Server, Database, 
                        UserName, Password: string): TConnectionParams; static;
end;
```

### TFieldInfo
字段元数据信息。

```pascal
TFieldInfo = record
  FieldName: string;       // 字段名
  DisplayName: string;     // 显示名称
  DataType: string;        // 数据类型
  FieldSize: Integer;      // 字段大小
  Required: Boolean;       // 是否必填
  PrimaryKey: Boolean;     // 是否主键
  DisplayFormat: string;   // 显示格式
  EditFormat: string;      // 编辑格式
  PickList: string;        // 选项列表（JSON）
end;
```

### TLoginResult
登录结果。

```pascal
TLoginResult = record
  Success: Boolean;        // 是否成功
  Token: string;           // 访问令牌
  UserID: Integer;         // 用户ID
  UserName: string;        // 用户名
  DisplayName: string;     // 显示名称
  ErrorMessage: string;    // 错误信息
  class function CreateError(const Msg: string): TLoginResult; static;
end;
```

### TMenuItem
菜单项信息。

```pascal
TMenuItem = record
  ID: Integer;
  ParentID: Integer;
  MenuName: string;
  MenuCode: string;
  MenuType: string;        // menu/button
  Icon: string;
  Path: string;
  PermissionCode: string;
  SortNo: Integer;
  Visible: Boolean;
  Children: TArray<TMenuItem>;
end;
```

### TPermissionInfo
权限信息。

```pascal
TPermissionInfo = record
  ID: Integer;
  PermissionCode: string;
  PermissionName: string;
  Resource: string;
  Action: string;
end;
```

### TRoleInfo
角色信息。

```pascal
TRoleInfo = record
  ID: Integer;
  RoleCode: string;
  RoleName: string;
  Description: string;
end;
```

### TUserInfo
用户信息。

```pascal
TUserInfo = record
  ID: Integer;
  UserName: string;
  DisplayName: string;
  Email: string;
  Phone: string;
  Status: Integer;
  CreatedDate: TDateTime;
end;
```

---

## UI 组件

### TUniBaseModule
数据模块基类，提供通用的数据访问功能。

**单元位置**：`src/Core/Data/UniBaseModule.pas`

**主要方法**：
```pascal
type
  TUniBaseModule = class(TDataModule)
  protected
    procedure DoBeforePost(DataSet: TDataSet); virtual;
    procedure DoAfterPost(DataSet: TDataSet); virtual;
    procedure DoBeforeDelete(DataSet: TDataSet); virtual;
    procedure DoAfterOpen(DataSet: TDataSet); virtual;
  public
    procedure RefreshData; virtual;
    procedure SaveChanges; virtual;
    procedure CancelChanges; virtual;
  end;
```

### TUniPropertyEditor
属性编辑器基类，用于创建属性编辑界面。

**单元位置**：`src/UI/Components/UniPropertyEditor.pas`

**主要方法**：
```pascal
type
  TUniPropertyEditor = class(TFrame)
  protected
    procedure InitializeControls; virtual;
    procedure LoadData; virtual;
    procedure SaveData; virtual;
    procedure ValidateData; virtual;
  public
    procedure Edit(const ID: Integer); virtual;
    procedure AddNew; virtual;
  end;
```

### TUniBaseCrudFrame
CRUD 窗体基类，提供标准的增删改查界面。

**单元位置**：`src/UI/Framework/UniBaseCrudFrame.pas`

**主要方法**：
```pascal
type
  TUniBaseCrudFrame = class(TFrame)
  protected
    procedure DoInitialize; virtual;
    procedure DoSearch; virtual;
    procedure DoAdd; virtual;
    procedure DoEdit; virtual;
    procedure DoDelete; virtual;
    procedure DoRefresh; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Initialize; virtual;
  end;
```

### TUniLoginForm
登录窗体。

**单元位置**：`src/UI/Forms/UniLoginForm.pas`

**主要方法**：
```pascal
type
  TUniLoginForm = class(TUniForm)
    procedure btnLoginClick(Sender: TObject);
  private
    FLoginResult: TLoginResult;
  public
    property LoginResult: TLoginResult read FLoginResult;
  end;
```

### TUniMainForm
主窗体框架。

**单元位置**：`src/UI/Forms/UniMainForm.pas`

**主要方法**：
```pascal
type
  TUniMainForm = class(TUniForm)
    procedure Initialize; virtual;
    procedure LoadUserMenus; virtual;
    procedure ShowDashboard; virtual;
  end;
```

---

## 使用示例

### 服务定位器

```pascal
uses UniServices;

procedure InitializeServices;
begin
  // 初始化服务
  TUniServices.Initialize(Connection);
  
  // 访问服务
  var LAuthService := TUniServices.AuthService;
  var LPermMgr := TUniServices.PermissionManager;
  var LMenuMgr := TUniServices.MenuManager;
end;

procedure UseServices;
begin
  // 获取服务实例
  var AuthService := TUniServices.AuthService;
  
  // 调用服务方法
  var Result := AuthService.Login('admin', 'password');
  
  if Result.Success then
  begin
    // 登录成功
    CurrentUserID := Result.UserID;
    CurrentToken := Result.Token;
  end;
end;
```

### 创建 CRUD 窗体

```pascal
type
  TUserCrudFrame = class(TUniBaseCrudFrame)
  protected
    procedure DoInitialize; override;
    function GetTableName: string; override;
    function GetTitle: string; override;
  end;

implementation

procedure TUserCrudFrame.DoInitialize;
begin
  inherited;
  
  // 配置查询
  Query.SQL.Text := 'SELECT * FROM Users WHERE Deleted = 0';
  
  // 配置编辑器
  PropertyEditor.RegisterEditor('Users', 'UserName', '用户名', etString, 50);
  PropertyEditor.RegisterEditor('Users', 'DisplayName', '显示名称', etString, 100);
  PropertyEditor.RegisterEditor('Users', 'Email', '邮箱', etString, 100);
  PropertyEditor.RegisterEditor('Users', 'Status', '状态', enum, 0, '启用=1,禁用=0');
end;

function TUserCrudFrame.GetTableName: string;
begin
  Result := 'Users';
end;

function TUserCrudFrame.GetTitle: string;
begin
  Result := '用户管理';
end;
```

### 使用权限检查

```pascal
procedure DeleteUser(UserID: Integer);
begin
  // 检查权限
  if not TUniServices.PermissionManager.HasPermission(
         CurrentUserID, 'user:delete') then
  begin
    ShowMessage('您没有删除用户的权限');
    Exit;
  end;
  
  // 检查数据范围
  var DataScope := TUniServices.PermissionManager
                    .GetDataScope(CurrentUserID, 'user:delete');
  
  if DataScope = 'self' then
  begin
    if UserID <> CurrentUserID then
    begin
      ShowMessage('您只能删除自己的账号');
      Exit;
    end;
  end;
  
  // 执行删除
  Connection.ExecSQL('UPDATE Users SET Deleted = 1 WHERE ID = :ID', [UserID]);
  
  ShowMessage('删除成功');
end;
```

### 获取用户菜单

```pascal
procedure LoadUserMenus;
begin
  var MenuMgr := TUniServices.MenuManager;
  var Menus := MenuMgr.GetUserMenus(CurrentUserID);
  
  for var Menu in Menus do
  begin
    AddMenuItem(Menu.MenuName, Menu.Path, Menu.Icon);
    
    // 递归加载子菜单
    for var SubMenu in Menu.Children do
    begin
      AddSubMenuItem(SubMenu.MenuName, SubMenu.Path, SubMenu.Icon);
    end;
  end;
end;
```

### 使用元数据管理器

```pascal
procedure CreatePropertyEditors(const TableName: string);
begin
  var MetaMgr := TUniServices.MetadataManager;
  var Fields := MetaMgr.GetTableFields(TableName);
  
  for var Field in Fields do
  begin
    if MetaMgr.IsAuditField(Field.FieldName) then
      Continue; // 跳过审计字段
      
    PropertyEditor.RegisterEditor(
      TableName,
      Field.FieldName,
      Field.DisplayName,
      StringToEditorType(Field.DataType),
      Field.FieldSize,
      Field.PickList
    );
  end;
end;
```

---

## 最佳实践

### 1. 服务使用

✅ **推荐**：通过服务定位器访问服务
```pascal
var AuthService := TUniServices.AuthService;
```

❌ **不推荐**：直接创建服务实例
```pascal
var AuthService := TUniAuthService.Create; // 错误！
```

### 2. 数据库连接

✅ **推荐**：使用连接管理器
```pascal
var Conn := TUniServices.ConnectionManager.GetDefaultConnection;
try
  // 使用连接
finally
  TUniServices.ConnectionManager.ReleaseConnection(Conn);
end;
```

❌ **不推荐**：直接创建连接
```pascal
var Conn := TFDConnection.Create(nil); // 不推荐
```

### 3. 权限检查

✅ **推荐**：在服务层检查权限
```pascal
function UserService.DeleteUser(UserID: Integer): Boolean;
begin
  if not PermissionManager.HasPermission(UserID, 'user:delete') then
    raise EUnauthorizedException.Create('无权限');
    
  // 执行删除
end;
```

❌ **不推荐**：只在 UI 层检查权限
```pascal
procedure DeleteButtonClick(Sender: TObject);
begin
  // UI 层检查可以，但服务层也必须检查
end;
```

### 4. 异常处理

✅ **推荐**：捕获并处理特定异常
```pascal
try
  AuthService.Login(UserName, Password);
except
  on E: EAuthenticationException do
    ShowMessage('认证失败：' + E.Message);
  on E: EFDatabaseError do
    ShowMessage('数据库错误');
end;
```

### 5. 资源释放

✅ **推荐**：使用 try-finally
```pascal
var Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := Conn;
    Query.Open('SELECT * FROM Users');
    // 处理数据
  finally
    Query.Free;
  end;
end;
```

### 6. 审计字段

✅ **推荐**：自动填充审计字段
```pascal
// 在保存前自动填充
MetadataManager.FillAuditFields('Users', Query, CurrentUserID);
Query.Post;
```

---

## 依赖关系图

```
TUniServices (服务定位器)
    |
    +-- IUniConnectionManager (连接管理)
    +-- IUniMetadataManager (元数据管理)
    +-- IUniAuthService (认证服务)
    +-- IUniPermissionManager (权限管理)
    +-- IUniMenuManager (菜单管理)
    +-- IUniThemeManager (主题管理)
    +-- IUniLayoutManager (布局管理)

UI 层依赖
    |
    +-- TUniLoginForm (登录窗体) → IUniAuthService
    +-- TUniMainForm (主窗体) → IUniMenuManager
    +-- TUniBaseCrudFrame (CRUD基类) → IUniMetadataManager
    +-- TUniPropertyEditor (属性编辑器) → IUniMetadataManager
```

---

## 更新日志

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| 1.0 | 2026-02-24 | 初始版本，Phase 2 API 文档 |

---

## 联系方式

如有 API 使用问题，请参考：
- 设计文档：`docs/uniadmin-framework-design.md`
- 安全文档：`docs/Security.md`
- 示例代码：`src/Examples/`

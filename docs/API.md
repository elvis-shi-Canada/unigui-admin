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

---

## Phase 3 系统模块 API

### IUniUserService
用户管理服务接口，提供用户业务的完整功能。

**单元位置**：`src/Modules/User/UserService.Intf.pas`

```pascal
IUniUserService = interface(IInterface)
  ['{UNI-USER-SERVICE-001}']

  /// <summary>获取用户列表（分页）</summary>
  function GetUsers(const Filter: string; Status: Integer;
    Page, PageSize: Integer): TArray<TUserInfo>;

  /// <summary>获取用户总数</summary>
  function GetUsersCount(const Filter: string; Status: Integer): Integer;

  /// <summary>根据ID获取用户</summary>
  function GetUserByID(UserID: Integer): TUserInfo;

  /// <summary>根据用户名获取用户</summary>
  function GetUserByName(const UserName: string): TUserInfo;

  /// <summary>创建用户</summary>
  function CreateUser(const UserName, Password, RealName,
    Email, Phone: string): Integer;

  /// <summary>更新用户信息</summary>
  procedure UpdateUser(UserID: Integer; const RealName, Email, Phone: string);

  /// <summary>删除用户</summary>
  procedure DeleteUser(UserID: Integer);

  /// <summary>设置用户状态</summary>
  procedure SetUserStatus(UserID, Status: Integer);

  /// <summary>检查用户是否可用</summary>
  function IsUserAvailable(UserID: Integer): Boolean;

  /// <summary>修改密码</summary>
  procedure ChangePassword(UserID: Integer; const OldPassword,
    NewPassword: string);

  /// <summary>重置密码</summary>
  procedure ResetPassword(UserID: Integer; const NewPassword: string);

  /// <summary>验证密码</summary>
  function VerifyPassword(const UserName, Password: string): Boolean;

  /// <summary>检查用户名是否存在</summary>
  function UserNameExists(const UserName: string): Boolean;

  /// <summary>检查邮箱是否存在</summary>
  function EmailExists(const Email: string): Boolean;
end;
```

**使用示例**：
```pascal
var
  UserService: IUniUserService;
  Users: TArray<TUserInfo>;
begin
  UserService := TUniUserService.Create(ExecutionContext);

  // 获取用户列表
  Users := UserService.GetUsers('admin', -1, 1, 20);

  // 创建用户
  var UserID := UserService.CreateUser('newuser', 'Pass123',
    '新用户', 'new@example.com', '13800138000');

  // 修改密码
  UserService.ChangePassword(UserID, 'Pass123', 'NewPass456');
end;
```

---

### TDictionaryService
数据字典服务类，提供字典类型和字典项的管理功能。

**单元位置**：`src/Modules/Dictionary/DictionaryService.pas`

```pascal
TDictionaryService = class(TInterfacedObject, IDictionaryService)
public
  /// <summary>获取所有字典类型</summary>
  function GetDictTypes: TArray<TDictTypeInfo>;

  /// <summary>根据编码获取字典类型</summary>
  function GetDictTypeByCode(const Code: string): TDictTypeInfo;

  /// <summary>获取字典项列表（带缓存）</summary>
  function GetDictItems(const DictTypeCode: string): TArray<TDictItemInfo>;

  /// <summary>刷新字典缓存</summary>
  procedure RefreshCache;

  /// <summary>获取字典项显示名称</summary>
  function GetDictItemDisplay(const DictTypeCode,
    ItemCode: string): string;
end;
```

**使用示例**：
```pascal
var
  DictService: TDictionaryService;
  Items: TArray<TDictItemInfo>;
begin
  DictService := TDictionaryService.Create(ExecutionContext);

  // 获取用户状态字典
  Items := DictService.GetDictItems('user_status');

  // 显示字典项
  for var Item in Items do
  begin
    ComboBox.Items.Add(Item.ItemName);
    ComboBox.ItemIndex := ComboBox.Items.AddObject(Item.ItemName,
      TObject(Item.ItemValue));
  end;
end;
```

---

### TConfigService
系统配置服务类，提供配置参数的管理和缓存功能。

**单元位置**：`src/Modules/Config/ConfigService.pas`

```pascal
TConfigService = class(TInterfacedObject, IConfigService)
public
  /// <summary>获取字符串配置</summary>
  function GetGlobalString(const ConfigKey: string): string;

  /// <summary>获取整数配置</summary>
  function GetGlobalInteger(const ConfigKey: string): Integer;

  /// <summary>获取布尔配置</summary>
  function GetGlobalBoolean(const ConfigKey: string): Boolean;

  /// <summary>获取分类配置</summary>
  function GetCategoryConfigs(const Category: string): TArray<TConfigInfo>;

  /// <summary>设置配置值</summary>
  procedure SetConfig(const ConfigKey, ConfigValue: string);

  /// <summary>刷新配置缓存</summary>
  procedure RefreshCache;
end;
```

**支持的配置值类型**：
- `string` - 字符串
- `integer` - 整数
- `boolean` - 布尔值
- `json` - JSON 对象
- `encrypted` - 加密字符串
- `file` - 文件路径

**使用示例**：
```pascal
var
  ConfigService: TConfigService;
begin
  ConfigService := TConfigService.Create(ExecutionContext);

  // 获取系统配置
  var SiteName := ConfigService.GetGlobalString('site.name');
  var MaxUploadSize := ConfigService.GetGlobalInteger('upload.maxsize');
  var EnableRegister := ConfigService.GetGlobalBoolean('user.register.enabled');

  // 设置配置
  ConfigService.SetConfig('site.name', 'UniAdmin 管理系统');
end;
```

---

### TLogService
日志审计服务类，提供日志记录和查询功能。

**单元位置**：`src/Modules/Log/LogService.pas`

```pascal
TLogService = class(TInterfacedObject, ILogService)
public
  /// <summary>记录登录日志</summary>
  procedure LogLogin(const UserName, LoginIP, UserAgent: string;
    Status: Integer);

  /// <summary>记录操作日志</summary>
  procedure LogOperation(const Module, Operation, Description: string;
    const RequestData, ResponseData: string; const IP: string);

  /// <summary>记录数据变更日志</summary>
  procedure LogDataChange(const TableName: string; RecordID: Integer;
    const Operation, OldValue, NewValue: string);

  /// <summary>获取登录日志</summary>
  function GetLoginLogs(const StartTime, EndTime: TDateTime;
    Page, PageSize: Integer): TArray<TLoginLogInfo>;

  /// <summary>获取操作日志</summary>
  function GetOperationLogs(const StartTime, EndTime: TDateTime;
    const Module: string; Page, PageSize: Integer): TArray<TOperationLogInfo>;

  /// <summary>导出日志（CSV/Excel）</summary>
  function ExportLogs(const LogType: string;
    const StartTime, EndTime: TDateTime; const Format: string): string;
end;
```

**使用示例**：
```pascal
var
  LogService: TLogService;
begin
  LogService := TLogService.Create(ExecutionContext);

  // 记录登录
  LogService.LogLogin('admin', '192.168.1.100',
    'Mozilla/5.0...', 1);

  // 记录操作
  LogService.LogOperation('User', 'Delete',
    '删除用户 testuser', '{"UserID": 123}', '{"Success": true}', '192.168.1.100');

  // 导出日志
  var FilePath := LogService.ExportLogs('login',
    EncodeDateTime(2026, 2, 1, 0, 0, 0),
    EncodeDateTime(2026, 2, 28, 23, 59, 59), 'csv');
end;
```

---

### TUniScheduler
定时任务调度器类，提供基于 Cron 表达式的任务调度功能。

**单元位置**：`src/Modules/Scheduler/UniScheduler.pas`

```pascal
TUniScheduler = class(TInterfacedObject, ISchedulerService)
public
  /// <summary>启动调度器</summary>
  procedure Start;

  /// <summary>停止调度器</summary>
  procedure Stop;

  /// <summary>添加任务</summary>
  function AddTask(const TaskName, CronExpression: string;
    const HandlerClass: string; const Parameters: string): Integer;

  /// <summary>移除任务</summary>
  procedure RemoveTask(TaskID: Integer);

  /// <summary>暂停任务</summary>
  procedure PauseTask(TaskID: Integer);

  /// <summary>恢复任务</summary>
  procedure ResumeTask(TaskID: Integer);

  /// <summary>获取任务状态</summary>
  function GetTaskStatus(TaskID: Integer): TTaskStatus;

  /// <summary>手动触发任务执行</summary>
  procedure ExecuteTask(TaskID: Integer);
end;
```

**Cron 表达式格式**：
```
* * * * * *
│ │ │ │ │ │
│ │ │ │ │ └─ 星期几 (0-6, 0=周日)
│ │ │ │ └─── 月份 (1-12)
│ │ │ └───── 日期 (1-31)
│ │ └─────── 小时 (0-23)
│ └───────── 分钟 (0-59)
└─────────── 秒 (0-59)
```

**使用示例**：
```pascal
var
  Scheduler: TUniScheduler;
begin
  Scheduler := TUniScheduler.Create;
  Scheduler.Start;

  // 添加每天凌晨 2 点执行的任务
  var TaskID := Scheduler.AddTask('数据清理',
    '0 0 2 * * ?', 'TCleanupTaskHandler', '{"Days": 30}');

  // 添加每 5 分钟执行的任务
  TaskID := Scheduler.AddTask('系统监控',
    '0 */5 * * * ?', 'TMonitorTaskHandler', '');

  // 手动触发任务
  Scheduler.ExecuteTask(TaskID);
end;
```

---

### TSystemModuleRegistrar
系统模块注册器类，负责注册所有 Phase 3 模块到插件系统。

**单元位置**：`src/Core/Plugin/UniModuleRegistration.pas`

```pascal
TSystemModuleRegistrar = class
public
  /// <summary>注册所有系统模块</summary>
  class procedure RegisterAllModules;

  /// <summary>注册用户管理模块</summary>
  class procedure RegisterUserModule;

  /// <summary>注册角色管理模块</summary>
  class procedure RegisterRoleModule;

  /// <summary>注册菜单管理模块</summary>
  class procedure RegisterMenuModule;

  /// <summary>注册数据字典模块</summary>
  class procedure RegisterDictionaryModule;

  /// <summary>注册系统配置模块</summary>
  class procedure RegisterConfigModule;

  /// <summary>注册日志审计模块</summary>
  class procedure RegisterLogModule;

  /// <summary>注册定时任务模块</summary>
  class procedure RegisterSchedulerModule;
end;
```

**使用示例**：
```pascal
// 应用程序启动时注册所有模块
procedure TUniServerModule.UniServerModuleCreate(Sender: TObject);
begin
  // 注册所有 Phase 3 系统模块
  TSystemModuleRegistrar.RegisterAllModules;
end;
```

---

### TSystemMenuSetup
系统菜单设置器类，负责初始化系统管理菜单。

**单元位置**：`src/Core/Menu/SystemMenuSetup.pas`

```pascal
TSystemMenuSetup = class
public
  /// <summary>初始化系统管理菜单</summary>
  class procedure InitializeSystemMenus(const ADataModule: TDataModule);

  /// <summary>获取系统管理菜单定义</summary>
  class function GetSystemMenuDefinitions: TList<TMenuItemInfo>;

  /// <summary>获取权限定义</summary>
  class function GetPermissionDefinitions: TList<TPermissionInfo>;
end;
```

**菜单结构**：
```
系统管理 (system)
├── 用户管理 (system:user)
├── 角色管理 (system:role)
├── 菜单管理 (system:menu)
├── 数据字典 (system:dictionary)
├── 系统配置 (system:config)
├── 日志审计 (system:log)
└── 定时任务 (system:scheduler)
```

---

## Phase 3 数据类型

### TUserInfo
用户信息记录。

```pascal
TUserInfo = record
  UserID: Integer;
  UserName: string;
  RealName: string;
  Email: string;
  Phone: string;
  Status: Integer;
  LastLoginDate: TDateTime;
  LastLoginIP: string;
  CreatedDate: TDateTime;
  ModifiedDate: TDateTime;
end;
```

### TDictTypeInfo
字典类型信息记录。

```pascal
TDictTypeInfo = record
  TypeID: Integer;
  TypeCode: string;
  TypeName: string;
  Description: string;
  SortOrder: Integer;
end;
```

### TDictItemInfo
字典项信息记录。

```pascal
TDictItemInfo = record
  ItemID: Integer;
  ItemCode: string;
  ItemName: string;
  ItemValue: string;
  SortOrder: Integer;
  Status: Integer;
end;
```

### TConfigInfo
配置信息记录。

```pascal
TConfigInfo = record
  ConfigID: Integer;
  ConfigKey: string;
  ConfigValue: string;
  Category: string;
  Description: string;
  ValueType: string;
end;
```

### TLoginLogInfo
登录日志信息记录。

```pascal
TLoginLogInfo = record
  LogID: Integer;
  UserID: Integer;
  UserName: string;
  LoginIP: string;
  LoginTime: TDateTime;
  Status: Integer;
  UserAgent: string;
end;
```

---

## 更新日志

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| 1.0 | 2026-02-24 | 初始版本，Phase 2 API 文档 |
| 1.1 | 2026-02-24 | 添加 Phase 3 系统模块 API |

---

## 联系方式

如有 API 使用问题，请参考：
- 设计文档：`docs/uniadmin-framework-design.md`
- 安全文档：`docs/Security.md`
- 示例代码：`src/Examples/`

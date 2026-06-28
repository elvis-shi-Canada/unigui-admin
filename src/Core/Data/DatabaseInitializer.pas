unit DatabaseInitializer;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Comp.Client, FireDAC.Stan.Param;

type
  /// <summary>
  /// 数据库自动初始化器
  /// 首次连接时检测表是否存在，不存在则建全表 + 灌入初始 admin 数据。
  /// 幂等：重复执行不报错（CREATE TABLE IF NOT EXISTS）。
  /// 当前以 SQLite 为开发环境；表结构与 Database/Schema/*.sql 对齐。
  /// </summary>
  TDatabaseInitializer = class
  private
    class procedure ExecScript(const AConn: TFDConnection; const ASQL: string);
    class function TableExists(const AConn: TFDConnection; const ATableName: string): Boolean;
    class procedure CreateAllTables(const AConn: TFDConnection);
    class procedure SeedInitialData(const AConn: TFDConnection);
    /// <summary>从 TModelAdminRegistry 派生菜单/权限并幂等写入 DB。
    /// 每次启动都执行，确保新声明的模块自动进入系统（已存在则跳过）。</summary>
    class procedure SeedFromRegistry(const AConn: TFDConnection);
    /// <summary>按 MenuCode 查 MenuID（用于解析父子关系）</summary>
    class function GetMenuIDByCode(const AConn: TFDConnection; const AMenuCode: string): Integer;
  public
    class procedure Initialize(const AConn: TFDConnection);
  end;

implementation

uses
  System.Hash, UniAdminLogger,
  UniModelAdmin.Intf, UniModelAdmin;

{ TDatabaseInitializer }

class procedure TDatabaseInitializer.ExecScript(const AConn: TFDConnection;
  const ASQL: string);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := AConn;
    LQuery.ExecSQL(ASQL);
  finally
    LQuery.Free;
  end;
end;

class function TDatabaseInitializer.TableExists(const AConn: TFDConnection;
  const ATableName: string): Boolean;
var
  LQuery: TFDQuery;
begin
  // SQLite 系统表 sqlite_master 存储所有表/索引的 schema
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := AConn;
    LQuery.Open('SELECT COUNT(*) FROM sqlite_master WHERE type=:T AND name=:N',
      ['table', ATableName]);
    Result := LQuery.Fields[0].AsInteger > 0;
  finally
    LQuery.Free;
  end;
end;

class procedure TDatabaseInitializer.CreateAllTables(const AConn: TFDConnection);
const
  // 全部建表语句（SQLite 语法）。MSSQL→SQLite 转换要点：
  //   INT IDENTITY(1,1) → INTEGER PRIMARY KEY AUTOINCREMENT
  //   NVARCHAR(n)       → TEXT
  //   NVARCHAR(MAX)     → TEXT
  //   DATETIME          → DATETIME (TEXT affinity，存 ISO8601 字符串)
  //   BIT               → INTEGER (0/1)
  //   DEFAULT CURRENT_TIMESTAMP → DEFAULT CURRENT_TIMESTAMP
  //   UNIQUEIDENTIFIER  → TEXT (存 GUID 字符串)
  C_DDL: array[0..15] of string = (
    // ---- 1. 插件表（03 schema 中的 Modules/Configs/ModuleDependencies）----
    // 注：01_CreatePluginTables.sql 用 UNIQUEIDENTIFIER 主键 + 审计用 CreatedAt/UpdatedAt，
    //     与 03 的 Configs 字段（ConfigKey/ConfigValue/Category）不同。这里采用 03 的字段约定，
    //     保持 ConfigKey 唯一，便于 ConfigService 使用。
    'CREATE TABLE IF NOT EXISTS UniAdmin_Modules (' +
      'ModuleID INTEGER PRIMARY KEY AUTOINCREMENT,' +
      'ModuleCode TEXT NOT NULL UNIQUE,' +
      'ModuleName TEXT NOT NULL,' +
      'ModuleType TEXT NOT NULL,' +
      'Version TEXT,' +
      'Description TEXT,' +
      'AssemblyName TEXT,' +
      'EntryPointType TEXT,' +
      'IsActive INTEGER NOT NULL DEFAULT 1,' +
      'IsSystem INTEGER NOT NULL DEFAULT 0,' +
      'LoadOrder INTEGER NOT NULL DEFAULT 0,' +
      'CreatedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,' +
      'ModifiedDate DATETIME)',

    // ---- 2. 配置表（ConfigService 用 ConfigKey/ConfigValue/Category）----
    'CREATE TABLE IF NOT EXISTS UniAdmin_Configs (' +
      'ConfigID INTEGER PRIMARY KEY AUTOINCREMENT,' +
      'ConfigKey TEXT NOT NULL UNIQUE,' +
      'ConfigValue TEXT,' +
      'Category TEXT NOT NULL,' +
      'Description TEXT,' +
      'ValueType TEXT NOT NULL DEFAULT ''string'',' +
      'SortOrder INTEGER NOT NULL DEFAULT 0,' +
      'Status INTEGER NOT NULL DEFAULT 1,' +
      'CreatedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,' +
      'CreatedBy INTEGER,' +
      'ModifiedDate DATETIME,' +
      'ModifiedBy INTEGER)',

    'CREATE TABLE IF NOT EXISTS UniAdmin_ModuleDependencies (' +
      'ID INTEGER PRIMARY KEY AUTOINCREMENT,' +
      'ModuleID INTEGER NOT NULL,' +
      'DependsOnModuleID INTEGER NOT NULL,' +
      'MinVersion TEXT,' +
      'DependencyType TEXT NOT NULL DEFAULT ''Required'',' +
      'CreatedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP)',

    // ---- 3. 核心表：用户/角色/权限/菜单 ----
    'CREATE TABLE IF NOT EXISTS UniAdmin_Users (' +
      'UserID INTEGER PRIMARY KEY AUTOINCREMENT,' +
      'UserName TEXT NOT NULL UNIQUE,' +
      'Password TEXT NOT NULL,' +
      'RealName TEXT,' +
      'Email TEXT,' +
      'Phone TEXT,' +
      'Avatar TEXT,' +
      'Status INTEGER NOT NULL DEFAULT 1,' +
      'LastLoginDate DATETIME,' +
      'LastLoginIP TEXT,' +
      'CreatedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,' +
      'CreatedBy INTEGER,' +
      'ModifiedDate DATETIME,' +
      'ModifiedBy INTEGER)',

    'CREATE TABLE IF NOT EXISTS UniAdmin_Roles (' +
      'RoleID INTEGER PRIMARY KEY AUTOINCREMENT,' +
      'RoleCode TEXT NOT NULL UNIQUE,' +
      'RoleName TEXT NOT NULL,' +
      'Description TEXT,' +
      'DataScope TEXT NOT NULL DEFAULT ''self'',' +
      'SortOrder INTEGER NOT NULL DEFAULT 0,' +
      'Status INTEGER NOT NULL DEFAULT 1,' +
      'CreatedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,' +
      'ModifiedDate DATETIME)',

    'CREATE TABLE IF NOT EXISTS UniAdmin_Permissions (' +
      'PermissionID INTEGER PRIMARY KEY AUTOINCREMENT,' +
      'PermissionCode TEXT NOT NULL UNIQUE,' +
      'PermissionName TEXT NOT NULL,' +
      'ResourceType TEXT NOT NULL,' +
      'ResourceCode TEXT NOT NULL,' +
      'Action TEXT NOT NULL,' +
      'Description TEXT,' +
      'CreatedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP)',

    'CREATE TABLE IF NOT EXISTS UniAdmin_UserRoles (' +
      'ID INTEGER PRIMARY KEY AUTOINCREMENT,' +
      'UserID INTEGER NOT NULL,' +
      'RoleID INTEGER NOT NULL,' +
      'CreatedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,' +
      'UNIQUE(UserID, RoleID))',

    'CREATE TABLE IF NOT EXISTS UniAdmin_RolePermissions (' +
      'ID INTEGER PRIMARY KEY AUTOINCREMENT,' +
      'RoleID INTEGER NOT NULL,' +
      'PermissionID INTEGER NOT NULL,' +
      'CreatedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,' +
      'UNIQUE(RoleID, PermissionID))',

    'CREATE TABLE IF NOT EXISTS UniAdmin_Menus (' +
      'MenuID INTEGER PRIMARY KEY AUTOINCREMENT,' +
      'ParentID INTEGER,' +
      'MenuName TEXT NOT NULL,' +
      'MenuCode TEXT NOT NULL UNIQUE,' +
      'Icon TEXT,' +
      'RoutePath TEXT,' +
      'PermissionCode TEXT,' +
      'SortOrder INTEGER NOT NULL DEFAULT 0,' +
      'IsVisible INTEGER NOT NULL DEFAULT 1,' +
      'CreatedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,' +
      'ModifiedDate DATETIME)',

    'CREATE TABLE IF NOT EXISTS UniAdmin_UserMenus (' +
      'ID INTEGER PRIMARY KEY AUTOINCREMENT,' +
      'UserID INTEGER NOT NULL,' +
      'MenuID INTEGER NOT NULL,' +
      'CreatedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,' +
      'UNIQUE(UserID, MenuID))',

    // ---- 4. 系统表：字典/日志/任务 ----
    'CREATE TABLE IF NOT EXISTS UniAdmin_DictTypes (' +
      'TypeID INTEGER PRIMARY KEY AUTOINCREMENT,' +
      'TypeCode TEXT NOT NULL UNIQUE,' +
      'TypeName TEXT NOT NULL,' +
      'Description TEXT,' +
      'SortOrder INTEGER NOT NULL DEFAULT 0,' +
      'Status INTEGER NOT NULL DEFAULT 1,' +
      'CreatedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,' +
      'CreatedBy INTEGER,' +
      'ModifiedDate DATETIME,' +
      'ModifiedBy INTEGER)',

    'CREATE TABLE IF NOT EXISTS UniAdmin_DictItems (' +
      'ItemID INTEGER PRIMARY KEY AUTOINCREMENT,' +
      'TypeID INTEGER NOT NULL,' +
      'ItemCode TEXT NOT NULL,' +
      'ItemName TEXT NOT NULL,' +
      'ItemValue TEXT,' +
      'SortOrder INTEGER NOT NULL DEFAULT 0,' +
      'Status INTEGER NOT NULL DEFAULT 1,' +
      'Remark TEXT,' +
      'CreatedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,' +
      'CreatedBy INTEGER,' +
      'ModifiedDate DATETIME,' +
      'ModifiedBy INTEGER,' +
      'UNIQUE(TypeID, ItemCode))',

    'CREATE TABLE IF NOT EXISTS UniAdmin_LoginLogs (' +
      'LogID INTEGER PRIMARY KEY AUTOINCREMENT,' +
      'UserID INTEGER,' +
      'UserName TEXT,' +
      'LoginIP TEXT,' +
      'LoginTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,' +
      'LogoutTime DATETIME,' +
      'Status INTEGER NOT NULL DEFAULT 1,' +
      'UserAgent TEXT,' +
      'FailReason TEXT)',

    'CREATE TABLE IF NOT EXISTS UniAdmin_OperationLogs (' +
      'LogID INTEGER PRIMARY KEY AUTOINCREMENT,' +
      'UserID INTEGER,' +
      'UserName TEXT,' +
      'Module TEXT NOT NULL,' +
      'Operation TEXT NOT NULL,' +
      'Description TEXT,' +
      'RequestData TEXT,' +
      'ResponseData TEXT,' +
      'IP TEXT,' +
      'UserAgent TEXT,' +
      'Duration INTEGER,' +
      'Status INTEGER NOT NULL DEFAULT 1,' +
      'CreatedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP)',

    'CREATE TABLE IF NOT EXISTS UniAdmin_DataChangeLogs (' +
      'LogID INTEGER PRIMARY KEY AUTOINCREMENT,' +
      'UserID INTEGER,' +
      'UserName TEXT,' +
      'TableName TEXT NOT NULL,' +
      'RecordID INTEGER,' +
      'Operation TEXT NOT NULL,' +
      'OldValue TEXT,' +
      'NewValue TEXT,' +
      'IP TEXT,' +
      'CreatedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP)',

    'CREATE TABLE IF NOT EXISTS UniAdmin_ScheduledTasks (' +
      'TaskID INTEGER PRIMARY KEY AUTOINCREMENT,' +
      'TaskName TEXT NOT NULL,' +
      'TaskCode TEXT NOT NULL UNIQUE,' +
      'CronExpression TEXT NOT NULL,' +
      'HandlerClass TEXT NOT NULL,' +
      'Parameters TEXT,' +
      'Description TEXT,' +
      'Status INTEGER NOT NULL DEFAULT 0,' +
      'LastRunTime DATETIME,' +
      'NextRunTime DATETIME,' +
      'LastRunStatus INTEGER,' +
      'LastRunMessage TEXT,' +
      'SortOrder INTEGER NOT NULL DEFAULT 0,' +
      'CreatedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,' +
      'CreatedBy INTEGER,' +
      'ModifiedDate DATETIME,' +
      'ModifiedBy INTEGER)'
  );
var
  i: Integer;
begin
  for i := Low(C_DDL) to High(C_DDL) do
    ExecScript(AConn, C_DDL[i]);

  // TaskExecutionLogs（依赖 ScheduledTasks，单独建以保持外键顺序）
  ExecScript(AConn,
    'CREATE TABLE IF NOT EXISTS UniAdmin_TaskExecutionLogs (' +
    'LogID INTEGER PRIMARY KEY AUTOINCREMENT,' +
    'TaskID INTEGER NOT NULL,' +
    'StartTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,' +
    'EndTime DATETIME,' +
    'Status INTEGER NOT NULL DEFAULT 0,' +
    'ErrorMessage TEXT,' +
    'Result TEXT,' +
    'Duration INTEGER)');
end;

class procedure TDatabaseInitializer.SeedInitialData(const AConn: TFDConnection);
var
  LQuery: TFDQuery;
  LHash: string;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := AConn;

    // 密码哈希必须与 UniAdminAuthService.HashPassword 一致（THashSHA2.GetHashString，SHA256）
    LHash := THashSHA2.GetHashString('admin123');

    // 角色：超级管理员（DataScope=all 表示看全部数据）
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_Roles (RoleID, RoleCode, RoleName, Description, DataScope, SortOrder, Status) ' +
      'VALUES (1, ''admin'', ''超级管理员'', ''系统超级管理员，拥有全部权限'', ''all'', 0, 1)');

    // 用户：admin / admin123（Status=1 启用）
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_Users (UserID, UserName, Password, RealName, Email, Status) ' +
      'VALUES (1, ''admin'', ''' + LHash + ''', ''系统管理员'', ''admin@example.com'', 1)');

    // 关联：admin 用户 → admin 角色
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_UserRoles (UserID, RoleID) VALUES (1, 1)');

    // 系统根菜单（让主界面至少有一个可见菜单结构）
    // 注：根菜单 'system' 是声明式模块的公共父节点，必须由这里播种，
    //     因为它不属于任何具体业务模块的声明。
    //     RoutePath 留空：根菜单是分类节点，点击仅展开/折叠子菜单，不路由（见 MainFrame.trmMenuClick）。
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_Menus (MenuID, ParentID, MenuName, MenuCode, Icon, RoutePath, SortOrder, IsVisible) ' +
      'VALUES (1, 0, ''系统管理'', ''system'', ''settings'', '''', 1, 1)');
    // 注：用户管理(system:user)由 UserListFrame 的 TModelAdmin 声明驱动，
    //     不再在此硬编码。见 SeedFromRegistry。
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_Menus (MenuID, ParentID, MenuName, MenuCode, Icon, RoutePath, SortOrder, IsVisible) ' +
      'VALUES (3, 1, ''角色管理'', ''system.role'', ''users'', ''TRoleListFrame'', 2, 1)');
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_Menus (MenuID, ParentID, MenuName, MenuCode, Icon, RoutePath, SortOrder, IsVisible) ' +
      'VALUES (4, 1, ''菜单管理'', ''system.menu'', ''list'', ''TMenuTreeFrame'', 3, 1)');
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_Menus (MenuID, ParentID, MenuName, MenuCode, Icon, RoutePath, SortOrder, IsVisible) ' +
      'VALUES (5, 1, ''数据字典'', ''system.dictionary'', ''book'', '''', 4, 1)');
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_Menus (MenuID, ParentID, MenuName, MenuCode, Icon, RoutePath, SortOrder, IsVisible) ' +
      'VALUES (6, 1, ''系统配置'', ''system.config'', ''cog'', ''TConfigCategoryFrame'', 5, 1)');
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_Menus (MenuID, ParentID, MenuName, MenuCode, Icon, RoutePath, SortOrder, IsVisible) ' +
      'VALUES (7, 1, ''日志审计'', ''system.log'', ''file-text'', '''', 6, 1)');
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_Menus (MenuID, ParentID, MenuName, MenuCode, Icon, RoutePath, SortOrder, IsVisible) ' +
      'VALUES (8, 1, ''定时任务'', ''system.scheduler'', ''clock'', '''', 7, 1)');
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_Menus (MenuID, ParentID, MenuName, MenuCode, Icon, RoutePath, SortOrder, IsVisible) ' +
      'VALUES (9, 1, ''共享组件'', ''system.shared'', ''share'', '''', 8, 1)');

    // 子菜单：为分类节点添加可路由的叶子菜单
    // 数据字典子菜单
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_Menus (MenuID, ParentID, MenuName, MenuCode, Icon, RoutePath, SortOrder, IsVisible) ' +
      'VALUES (10, 5, ''字典类型'', ''system.dictionary:type'', ''list'', ''TDictTypeFrame'', 1, 1)');
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_Menus (MenuID, ParentID, MenuName, MenuCode, Icon, RoutePath, SortOrder, IsVisible) ' +
      'VALUES (11, 5, ''字典项'', ''system.dictionary:item'', ''list'', ''TDictItemFrame'', 2, 1)');
    // 日志审计子菜单
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_Menus (MenuID, ParentID, MenuName, MenuCode, Icon, RoutePath, SortOrder, IsVisible) ' +
      'VALUES (12, 7, ''登录日志'', ''system.log:login'', ''file-text'', ''TLoginLogFrame'', 1, 1)');
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_Menus (MenuID, ParentID, MenuName, MenuCode, Icon, RoutePath, SortOrder, IsVisible) ' +
      'VALUES (13, 7, ''操作日志'', ''system.log:operation'', ''file-text'', ''TOperationLogFrame'', 2, 1)');
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_Menus (MenuID, ParentID, MenuName, MenuCode, Icon, RoutePath, SortOrder, IsVisible) ' +
      'VALUES (14, 7, ''数据变更日志'', ''system.log:data'', ''file-text'', ''TDataChangeLogFrame'', 3, 1)');
    // 定时任务子菜单
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_Menus (MenuID, ParentID, MenuName, MenuCode, Icon, RoutePath, SortOrder, IsVisible) ' +
      'VALUES (15, 8, ''任务管理'', ''system.scheduler:manage'', ''list'', ''TTaskManageFrame'', 1, 1)');
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_Menus (MenuID, ParentID, MenuName, MenuCode, Icon, RoutePath, SortOrder, IsVisible) ' +
      'VALUES (16, 8, ''任务日志'', ''system.scheduler:log'', ''file-text'', ''TTaskLogFrame'', 2, 1)');
    // 共享组件子菜单
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_Menus (MenuID, ParentID, MenuName, MenuCode, Icon, RoutePath, SortOrder, IsVisible) ' +
      'VALUES (17, 9, ''图标选择器'', ''system.shared:icon'', ''icon'', ''TIconSelector'', 1, 1)');

    // 权限：为所有菜单创建对应权限
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_Permissions (PermissionID, PermissionCode, PermissionName, ResourceType, ResourceCode, Action, Description) ' +
      'VALUES (1, ''user:view'', ''查看用户'', ''user'', ''UserManagement'', ''view'', ''查看用户列表和详情'')');
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_Permissions (PermissionID, PermissionCode, PermissionName, ResourceType, ResourceCode, Action, Description) ' +
      'VALUES (2, ''role:view'', ''查看角色'', ''role'', ''RoleManagement'', ''view'', ''查看角色列表和详情'')');
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_Permissions (PermissionID, PermissionCode, PermissionName, ResourceType, ResourceCode, Action, Description) ' +
      'VALUES (3, ''menu:view'', ''查看菜单'', ''menu'', ''MenuManagement'', ''view'', ''查看菜单列表'')');
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_Permissions (PermissionID, PermissionCode, PermissionName, ResourceType, ResourceCode, Action, Description) ' +
      'VALUES (4, ''dictionary:view'', ''查看字典'', ''dictionary'', ''DictionaryManagement'', ''view'', ''查看数据字典'')');
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_Permissions (PermissionID, PermissionCode, PermissionName, ResourceType, ResourceCode, Action, Description) ' +
      'VALUES (5, ''config:view'', ''查看配置'', ''config'', ''SystemConfig'', ''view'', ''查看系统配置'')');
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_Permissions (PermissionID, PermissionCode, PermissionName, ResourceType, ResourceCode, Action, Description) ' +
      'VALUES (6, ''log:view'', ''查看日志'', ''log'', ''LogManagement'', ''view'', ''查看系统日志'')');
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_Permissions (PermissionID, PermissionCode, PermissionName, ResourceType, ResourceCode, Action, Description) ' +
      'VALUES (7, ''scheduler:view'', ''查看任务'', ''scheduler'', ''SchedulerManagement'', ''view'', ''查看定时任务'')');
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_Permissions (PermissionID, PermissionCode, PermissionName, ResourceType, ResourceCode, Action, Description) ' +
      'VALUES (8, ''shared:view'', ''查看共享组件'', ''shared'', ''SharedManagement'', ''view'', ''查看共享组件'')');

    // 角色-权限关联：admin 角色拥有所有权限
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_RolePermissions (RoleID, PermissionID) VALUES (1, 1)');
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_RolePermissions (RoleID, PermissionID) VALUES (1, 2)');
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_RolePermissions (RoleID, PermissionID) VALUES (1, 3)');
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_RolePermissions (RoleID, PermissionID) VALUES (1, 4)');
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_RolePermissions (RoleID, PermissionID) VALUES (1, 5)');
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_RolePermissions (RoleID, PermissionID) VALUES (1, 6)');
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_RolePermissions (RoleID, PermissionID) VALUES (1, 7)');
    LQuery.ExecSQL(
      'INSERT OR IGNORE INTO UniAdmin_RolePermissions (RoleID, PermissionID) VALUES (1, 8)');
  finally
    LQuery.Free;
  end;
end;

class procedure TDatabaseInitializer.Initialize(const AConn: TFDConnection);
begin
  if not Assigned(AConn) then
    Exit;

  try
    // SQLite 默认关闭外键约束，显式开启（关联表完整性）
    ExecScript(AConn, 'PRAGMA foreign_keys = ON');

    // 以 UniAdmin_Users 为标志表判断是否首次初始化
    if not TableExists(AConn, 'UniAdmin_Users') then
    begin
      LogInfo('[DB-Init] 首次检测：表不存在，开始建表 + 灌入初始数据');
      CreateAllTables(AConn);
      SeedInitialData(AConn);
      LogInfo('[DB-Init] 数据库初始化完成（admin/admin123 已就绪）');
    end
    else
      LogInfo('[DB-Init] 表已存在，跳过初始化');

    // 声明式播种：每次启动都执行，从 TModelAdminRegistry 派生菜单/权限。
    // 幂等（INSERT OR IGNORE），新增声明的模块会自动补入已存在的库。
    SeedFromRegistry(AConn);
  except
    on E: Exception do
      LogError('[DB-Init] 初始化失败: ' + E.Message);
  end;
end;

class function TDatabaseInitializer.GetMenuIDByCode(const AConn: TFDConnection;
  const AMenuCode: string): Integer;
var
  LQuery: TFDQuery;
begin
  Result := 0;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := AConn;
    LQuery.Open('SELECT MenuID FROM UniAdmin_Menus WHERE MenuCode = :C', [AMenuCode]);
    if not LQuery.Eof then
      Result := LQuery.FieldByName('MenuID').AsInteger;
  finally
    LQuery.Free;
  end;
end;

class procedure TDatabaseInitializer.SeedFromRegistry(const AConn: TFDConnection);
const
  // 标准 CRUD 权限四件套后缀
  CRUD_ACTIONS: array[0..3] of string = ('view', 'add', 'edit', 'delete');
var
  LAdmins: TArray<TModelAdmin>;
  LAdmin: TModelAdmin;
  LAction: string;
  LQuery: TFDQuery;
  LParentID: Integer;
  LMenuCode: string;
  LPermCode: string;
  LRoutePath: string;
begin
  LAdmins := TModelAdminRegistry.CreateInstance.GetAll;
  if Length(LAdmins) = 0 then
    Exit;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := AConn;

    for LAdmin in LAdmins do
    begin
      // 1. 解析父菜单 MenuID（声明用 MenuCode，DB 用 MenuID）
      LParentID := 0;
      if LAdmin.ParentMenuCode <> '' then
        LParentID := GetMenuIDByCode(AConn, LAdmin.ParentMenuCode);
      // 未找到父菜单则挂到根（ParentID=0）
      if LParentID = 0 then
        LParentID := GetMenuIDByCode(AConn, 'system');
      // 连系统根都没有则挂根
      if LParentID = 0 then
        LParentID := 0;

      // 2. 幂等写入菜单（MenuCode 唯一约束 + INSERT OR IGNORE）
      LMenuCode := 'system:' + LAdmin.AdminID;
      if LAdmin.FrameClassName <> '' then
        LRoutePath := LAdmin.FrameClassName
      else
        LRoutePath := 'TAutoCrudFrame';

      LQuery.SQL.Text :=
        'INSERT OR IGNORE INTO UniAdmin_Menus ' +
        '(ParentID, MenuName, MenuCode, Icon, RoutePath, PermissionCode, SortOrder, IsVisible) ' +
        'VALUES (:ParentID, :MenuName, :MenuCode, :Icon, :RoutePath, :PermissionCode, :SortOrder, 1)';
      LQuery.ParamByName('ParentID').AsInteger := LParentID;
      LQuery.ParamByName('MenuName').AsString := LAdmin.DisplayName;
      LQuery.ParamByName('MenuCode').AsString := LMenuCode;
      LQuery.ParamByName('Icon').AsString := LAdmin.Icon;
      LQuery.ParamByName('RoutePath').AsString := LRoutePath;
      LQuery.ParamByName('PermissionCode').AsString := LAdmin.PermissionPrefix + ':view';
      LQuery.ParamByName('SortOrder').AsInteger := LAdmin.SortOrder;
      LQuery.ExecSQL;

      // 3. 幂等写入权限四件套（view/add/edit/delete）
      for LAction in CRUD_ACTIONS do
      begin
        LPermCode := LAdmin.PermissionPrefix + ':' + LAction;
        LQuery.SQL.Text :=
          'INSERT OR IGNORE INTO UniAdmin_Permissions ' +
          '(PermissionCode, PermissionName, ResourceType, ResourceCode, Action, Description) ' +
          'VALUES (:Code, :Name, :Res, :ResCode, :Act, :Desc)';
        LQuery.ParamByName('Code').AsString := LPermCode;
        LQuery.ParamByName('Name').AsString := LAdmin.DisplayName + ' ' + LAction;
        LQuery.ParamByName('Res').AsString := LAdmin.AdminID;
        LQuery.ParamByName('ResCode').AsString := LAdmin.TableName;
        LQuery.ParamByName('Act').AsString := LAction;
        LQuery.ParamByName('Desc').AsString := LAdmin.DisplayName + ' 的 ' + LAction + ' 权限';
        LQuery.ExecSQL;

        // 4. admin 角色（RoleID=1）自动获得该权限
        LQuery.SQL.Text :=
          'INSERT OR IGNORE INTO UniAdmin_RolePermissions (RoleID, PermissionID) ' +
          'SELECT 1, PermissionID FROM UniAdmin_Permissions WHERE PermissionCode = :C';
        LQuery.ParamByName('C').AsString := LPermCode;
        LQuery.ExecSQL;
      end;
    end;

    LogInfo(Format('[DB-Init] 声明式播种完成：%d 个 ModelAdmin 已同步菜单/权限', [Length(LAdmins)]));
  finally
    LQuery.Free;
  end;
end;

end.

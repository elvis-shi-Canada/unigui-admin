unit UniModuleRegistration;

interface

uses
  System.SysUtils, System.Classes,
  UniAdminModuleRegistry, UniAdminModuleRegistry.Intf,
  UniPlugin.Types,
  // User Module
  UserDataModule, UserService,
  UserListFrame, UserEditForm, UserPasswordDialog, UserProfileFrame,
  // Role Module
  RoleDataModule, RoleListFrame, RoleEditForm,
  RolePermissionDialog, RoleUserDialog,
  // Menu Module
  MenuDataModule, MenuTreeFrame, MenuEditForm,
  // Shared Component
  IconSelector,
  // Dictionary Module
  DictionaryDataModule, DictionaryService,
  DictTypeFrame, DictItemFrame,
  // Config Module
  ConfigDataModule, ConfigService,
  ConfigCategoryFrame, ConfigEditForm,
  // Log Module
  LogDataModule, LogService,
  LoginLogFrame, OperationLogFrame, DataChangeLogFrame,
  // Scheduler Module
  UniAdminScheduler, TaskManageFrame, TaskLogFrame;

type
  /// <summary>
  /// 系统模块注册器
  /// 负责注册所有 Phase 3 系统模块到插件系统
  /// </summary>
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

implementation

{ TSystemModuleRegistrar }

class procedure TSystemModuleRegistrar.RegisterAllModules;
begin
  // 按依赖顺序注册模块
  // 1. 基础模块（无依赖）
  RegisterUserModule;
  RegisterMenuModule;
  RegisterDictionaryModule;
  RegisterConfigModule;
  RegisterSchedulerModule;

  // 2. 依赖其他模块的模块
  RegisterRoleModule;      // 依赖 User
  RegisterLogModule;       // 依赖 User
end;

class procedure TSystemModuleRegistrar.RegisterUserModule;
var
  LInfo: TPluginClassInfo;
  LRegistry: IUniAdminModuleRegistry;
begin
  LRegistry := TUniAdminModuleRegistry.GetInstance;

  // 注册用户管理数据模块
  LInfo.PluginID := 'user-data-module';
  LInfo.ClassName := 'TUserDataModule';
  LInfo.DisplayName := '用户管理数据模块';
  LInfo.Version := '1.0.0';
  LInfo.Description := '提供用户数据的CRUD操作、查询和验证功能';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.Data';
  LInfo.AutoStart := True;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := nil;
  LInfo.Priority := 100;
  LRegistry.RegisterPluginClass(TUserDataModule, LInfo.PluginID, LInfo);

  // 注册用户管理服务
  LInfo.PluginID := 'user-service';
  LInfo.ClassName := 'TUserService';
  LInfo.DisplayName := '用户管理服务';
  LInfo.Version := '1.0.0';
  LInfo.Description := '提供用户业务逻辑封装和权限检查';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.Service';
  LInfo.AutoStart := True;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := TArray<string>.Create('user-data-module');
  LInfo.Priority := 101;
  LRegistry.RegisterPluginClass(TUserService, LInfo.PluginID, LInfo);

  // 注册用户列表窗体
  LInfo.PluginID := 'user-list-frame';
  LInfo.ClassName := 'TUserListFrame';
  LInfo.DisplayName := '用户列表';
  LInfo.Version := '1.0.0';
  LInfo.Description := '用户管理列表界面，提供搜索、筛选和CRUD操作';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.UI';
  LInfo.AutoStart := False;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := TArray<string>.Create('user-service');
  LInfo.Priority := 102;
  LRegistry.RegisterPluginClass(TUserListFrame, LInfo.PluginID, LInfo);

  // 注册用户编辑窗体
  LInfo.PluginID := 'user-edit-form';
  LInfo.ClassName := 'TUserEditForm';
  LInfo.DisplayName := '用户编辑';
  LInfo.Version := '1.0.0';
  LInfo.Description := '用户新增/编辑表单';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.UI';
  LInfo.AutoStart := False;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := nil;
  LInfo.Priority := 103;
  LRegistry.RegisterPluginClass(TUserEditForm, LInfo.PluginID, LInfo);

  // 注册密码管理对话框
  LInfo.PluginID := 'user-password-dialog';
  LInfo.ClassName := 'TUserPasswordDialog';
  LInfo.DisplayName := '密码管理';
  LInfo.Version := '1.0.0';
  LInfo.Description := '用户密码修改和重置对话框';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.UI';
  LInfo.AutoStart := False;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := nil;
  LInfo.Priority := 104;
  LRegistry.RegisterPluginClass(TUserPasswordDialog, LInfo.PluginID, LInfo);

  // 注册用户资料窗体
  LInfo.PluginID := 'user-profile-frame';
  LInfo.ClassName := 'TUserProfileFrame';
  LInfo.DisplayName := '个人资料';
  LInfo.Version := '1.0.0';
  LInfo.Description := '当前用户个人资料查看和编辑';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.UI';
  LInfo.AutoStart := False;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := nil;
  LInfo.Priority := 105;
  LRegistry.RegisterPluginClass(TUserProfileFrame, LInfo.PluginID, LInfo);
end;

class procedure TSystemModuleRegistrar.RegisterRoleModule;
var
  LInfo: TPluginClassInfo;
  LRegistry: IUniAdminModuleRegistry;
begin
  LRegistry := TUniAdminModuleRegistry.GetInstance;

  // 注册角色管理数据模块
  LInfo.PluginID := 'role-data-module';
  LInfo.ClassName := 'TRoleDataModule';
  LInfo.DisplayName := '角色管理数据模块';
  LInfo.Version := '1.0.0';
  LInfo.Description := '提供角色数据的CRUD操作、用户分配和权限分配功能';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.Data';
  LInfo.AutoStart := True;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := nil;
  LInfo.Priority := 200;
  LRegistry.RegisterPluginClass(TRoleDataModule, LInfo.PluginID, LInfo);

  // 注册角色列表窗体
  LInfo.PluginID := 'role-list-frame';
  LInfo.ClassName := 'TRoleListFrame';
  LInfo.DisplayName := '角色列表';
  LInfo.Version := '1.0.0';
  LInfo.Description := '角色管理列表界面，提供搜索、筛选和统计信息';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.UI';
  LInfo.AutoStart := False;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := nil;
  LInfo.Priority := 201;
  LRegistry.RegisterPluginClass(TRoleListFrame, LInfo.PluginID, LInfo);

  // 注册角色编辑窗体
  LInfo.PluginID := 'role-edit-form';
  LInfo.ClassName := 'TRoleEditForm';
  LInfo.DisplayName := '角色编辑';
  LInfo.Version := '1.0.0';
  LInfo.Description := '角色新增/编辑表单';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.UI';
  LInfo.AutoStart := False;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := nil;
  LInfo.Priority := 202;
  LRegistry.RegisterPluginClass(TRoleEditForm, LInfo.PluginID, LInfo);

  // 注册角色权限分配对话框
  LInfo.PluginID := 'role-permission-dialog';
  LInfo.ClassName := 'TRolePermissionDialog';
  LInfo.DisplayName := '角色权限分配';
  LInfo.Version := '1.0.0';
  LInfo.Description := '为角色分配权限的对话框';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.UI';
  LInfo.AutoStart := False;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := nil;
  LInfo.Priority := 203;
  LRegistry.RegisterPluginClass(TRolePermissionDialog, LInfo.PluginID, LInfo);

  // 注册角色用户分配对话框
  LInfo.PluginID := 'role-user-dialog';
  LInfo.ClassName := 'TRoleUserDialog';
  LInfo.DisplayName := '角色用户分配';
  LInfo.Version := '1.0.0';
  LInfo.Description := '为角色分配用户的对话框';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.UI';
  LInfo.AutoStart := False;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := nil;
  LInfo.Priority := 204;
  LRegistry.RegisterPluginClass(TRoleUserDialog, LInfo.PluginID, LInfo);
end;

class procedure TSystemModuleRegistrar.RegisterMenuModule;
var
  LInfo: TPluginClassInfo;
  LRegistry: IUniAdminModuleRegistry;
begin
  LRegistry := TUniAdminModuleRegistry.GetInstance;

  // 注册菜单数据模块
  LInfo.PluginID := 'menu-data-module';
  LInfo.ClassName := 'TMenuDataModule';
  LInfo.DisplayName := '菜单管理数据模块';
  LInfo.Version := '1.0.0';
  LInfo.Description := '提供菜单树的CRUD操作和排序功能';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.Data';
  LInfo.AutoStart := True;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := nil;
  LInfo.Priority := 300;
  LRegistry.RegisterPluginClass(TMenuDataModule, LInfo.PluginID, LInfo);

  // 注册菜单树编辑窗体
  LInfo.PluginID := 'menu-tree-frame';
  LInfo.ClassName := 'TMenuTreeFrame';
  LInfo.DisplayName := '菜单树';
  LInfo.Version := '1.0.0';
  LInfo.Description := '菜单树形编辑界面，支持拖拽排序';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.UI';
  LInfo.AutoStart := False;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := nil;
  LInfo.Priority := 301;
  LRegistry.RegisterPluginClass(TMenuTreeFrame, LInfo.PluginID, LInfo);

  // 注册菜单编辑窗体
  LInfo.PluginID := 'menu-edit-form';
  LInfo.ClassName := 'TMenuEditForm';
  LInfo.DisplayName := '菜单编辑';
  LInfo.Version := '1.0.0';
  LInfo.Description := '菜单新增/编辑表单';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.UI';
  LInfo.AutoStart := False;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := nil;
  LInfo.Priority := 302;
  LRegistry.RegisterPluginClass(TMenuEditForm, LInfo.PluginID, LInfo);

  // 注册图标选择器
  LInfo.PluginID := 'icon-selector';
  LInfo.ClassName := 'TIconSelector';
  LInfo.DisplayName := '图标选择器';
  LInfo.Version := '1.0.0';
  LInfo.Description := '图标选择和预览组件';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.UI';
  LInfo.AutoStart := False;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := nil;
  LInfo.Priority := 303;
  LRegistry.RegisterPluginClass(TIconSelector, LInfo.PluginID, LInfo);
end;

class procedure TSystemModuleRegistrar.RegisterDictionaryModule;
var
  LInfo: TPluginClassInfo;
  LRegistry: IUniAdminModuleRegistry;
begin
  LRegistry := TUniAdminModuleRegistry.GetInstance;

  // 注册数据字典数据模块
  LInfo.PluginID := 'dictionary-data-module';
  LInfo.ClassName := 'TDictionaryDataModule';
  LInfo.DisplayName := '数据字典数据模块';
  LInfo.Version := '1.0.0';
  LInfo.Description := '提供数据字典类型和字典项的CRUD操作及缓存';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.Data';
  LInfo.AutoStart := True;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := nil;
  LInfo.Priority := 400;
  LRegistry.RegisterPluginClass(TDictionaryDataModule, LInfo.PluginID, LInfo);

  // 注册字典服务
  LInfo.PluginID := 'dictionary-service';
  LInfo.ClassName := 'TDictionaryService';
  LInfo.DisplayName := '字典服务';
  LInfo.Version := '1.0.0';
  LInfo.Description := '数据字典业务逻辑封装';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.Service';
  LInfo.AutoStart := True;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := TArray<string>.Create('dictionary-data-module');
  LInfo.Priority := 401;
  LRegistry.RegisterPluginClass(TDictionaryService, LInfo.PluginID, LInfo);

  // 注册字典类型管理窗体
  LInfo.PluginID := 'dict-type-frame';
  LInfo.ClassName := 'TDictTypeFrame';
  LInfo.DisplayName := '字典类型';
  LInfo.Version := '1.0.0';
  LInfo.Description := '数据字典类型管理界面';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.UI';
  LInfo.AutoStart := False;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := nil;
  LInfo.Priority := 402;
  LRegistry.RegisterPluginClass(TDictTypeFrame, LInfo.PluginID, LInfo);

  // 注册字典项管理窗体
  LInfo.PluginID := 'dict-item-frame';
  LInfo.ClassName := 'TDictItemFrame';
  LInfo.DisplayName := '字典项';
  LInfo.Version := '1.0.0';
  LInfo.Description := '数据字典项管理界面';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.UI';
  LInfo.AutoStart := False;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := nil;
  LInfo.Priority := 403;
  LRegistry.RegisterPluginClass(TDictItemFrame, LInfo.PluginID, LInfo);
end;

class procedure TSystemModuleRegistrar.RegisterConfigModule;
var
  LInfo: TPluginClassInfo;
  LRegistry: IUniAdminModuleRegistry;
begin
  LRegistry := TUniAdminModuleRegistry.GetInstance;

  // 注册系统配置数据模块
  LInfo.PluginID := 'config-data-module';
  LInfo.ClassName := 'TConfigDataModule';
  LInfo.DisplayName := '系统配置数据模块';
  LInfo.Version := '1.0.0';
  LInfo.Description := '提供系统配置的CRUD操作，支持多种值类型';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.Data';
  LInfo.AutoStart := True;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := nil;
  LInfo.Priority := 500;
  LRegistry.RegisterPluginClass(TConfigDataModule, LInfo.PluginID, LInfo);

  // 注册配置服务
  LInfo.PluginID := 'config-service';
  LInfo.ClassName := 'TConfigService';
  LInfo.DisplayName := '配置服务';
  LInfo.Version := '1.0.0';
  LInfo.Description := '系统配置业务逻辑封装';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.Service';
  LInfo.AutoStart := True;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := TArray<string>.Create('config-data-module');
  LInfo.Priority := 501;
  LRegistry.RegisterPluginClass(TConfigService, LInfo.PluginID, LInfo);

  // 注册配置分类管理窗体
  LInfo.PluginID := 'config-category-frame';
  LInfo.ClassName := 'TConfigCategoryFrame';
  LInfo.DisplayName := '系统配置';
  LInfo.Version := '1.0.0';
  LInfo.Description := '系统配置分类管理界面';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.UI';
  LInfo.AutoStart := False;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := nil;
  LInfo.Priority := 502;
  LRegistry.RegisterPluginClass(TConfigCategoryFrame, LInfo.PluginID, LInfo);

  // 注册配置编辑窗体
  LInfo.PluginID := 'config-edit-form';
  LInfo.ClassName := 'TConfigEditForm';
  LInfo.DisplayName := '配置编辑';
  LInfo.Version := '1.0.0';
  LInfo.Description := '系统配置新增/编辑表单';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.UI';
  LInfo.AutoStart := False;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := nil;
  LInfo.Priority := 503;
  LRegistry.RegisterPluginClass(TConfigEditForm, LInfo.PluginID, LInfo);
end;

class procedure TSystemModuleRegistrar.RegisterLogModule;
var
  LInfo: TPluginClassInfo;
  LRegistry: IUniAdminModuleRegistry;
begin
  LRegistry := TUniAdminModuleRegistry.GetInstance;

  // 注册日志数据模块
  LInfo.PluginID := 'log-data-module';
  LInfo.ClassName := 'TLogDataModule';
  LInfo.DisplayName := '日志数据模块';
  LInfo.Version := '1.0.0';
  LInfo.Description := '提供登录日志、操作日志和数据变更日志的记录和查询';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.Data';
  LInfo.AutoStart := True;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := nil;
  LInfo.Priority := 600;
  LRegistry.RegisterPluginClass(TLogDataModule, LInfo.PluginID, LInfo);

  // 注册日志服务
  LInfo.PluginID := 'log-service';
  LInfo.ClassName := 'TLogService';
  LInfo.DisplayName := '日志服务';
  LInfo.Version := '1.0.0';
  LInfo.Description := '日志记录和查询服务';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.Service';
  LInfo.AutoStart := True;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := TArray<string>.Create('log-data-module');
  LInfo.Priority := 601;
  LRegistry.RegisterPluginClass(TLogService, LInfo.PluginID, LInfo);

  // 注册登录日志查询窗体
  LInfo.PluginID := 'login-log-frame';
  LInfo.ClassName := 'TLoginLogFrame';
  LInfo.DisplayName := '登录日志';
  LInfo.Version := '1.0.0';
  LInfo.Description := '用户登录日志查询界面';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.UI';
  LInfo.AutoStart := False;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := nil;
  LInfo.Priority := 602;
  LRegistry.RegisterPluginClass(TLoginLogFrame, LInfo.PluginID, LInfo);

  // 注册操作日志查询窗体
  LInfo.PluginID := 'operation-log-frame';
  LInfo.ClassName := 'TOperationLogFrame';
  LInfo.DisplayName := '操作日志';
  LInfo.Version := '1.0.0';
  LInfo.Description := '用户操作日志查询界面';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.UI';
  LInfo.AutoStart := False;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := nil;
  LInfo.Priority := 603;
  LRegistry.RegisterPluginClass(TOperationLogFrame, LInfo.PluginID, LInfo);

  // 注册数据变更日志查询窗体
  LInfo.PluginID := 'data-change-log-frame';
  LInfo.ClassName := 'TDataChangeLogFrame';
  LInfo.DisplayName := '数据变更日志';
  LInfo.Version := '1.0.0';
  LInfo.Description := '数据变更日志查询界面';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.UI';
  LInfo.AutoStart := False;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := nil;
  LInfo.Priority := 604;
  LRegistry.RegisterPluginClass(TDataChangeLogFrame, LInfo.PluginID, LInfo);
end;

class procedure TSystemModuleRegistrar.RegisterSchedulerModule;
var
  LInfo: TPluginClassInfo;
  LRegistry: IUniAdminModuleRegistry;
begin
  LRegistry := TUniAdminModuleRegistry.GetInstance;

  // 注册任务调度器
  LInfo.PluginID := 'uni-scheduler';
  LInfo.ClassName := 'TUniAdminScheduler';
  LInfo.DisplayName := '任务调度器';
  LInfo.Version := '1.0.0';
  LInfo.Description := '基于Cron表达式的定时任务调度服务';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.Service';
  LInfo.AutoStart := True;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := nil;
  LInfo.Priority := 700;
  LRegistry.RegisterPluginClass(TUniAdminScheduler, LInfo.PluginID, LInfo);

  // 注册任务管理窗体
  LInfo.PluginID := 'task-manage-frame';
  LInfo.ClassName := 'TTaskManageFrame';
  LInfo.DisplayName := '定时任务';
  LInfo.Version := '1.0.0';
  LInfo.Description := '定时任务管理界面';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.UI';
  LInfo.AutoStart := False;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := nil;
  LInfo.Priority := 701;
  LRegistry.RegisterPluginClass(TTaskManageFrame, LInfo.PluginID, LInfo);

  // 注册任务执行日志窗体
  LInfo.PluginID := 'task-log-frame';
  LInfo.ClassName := 'TTaskLogFrame';
  LInfo.DisplayName := '任务日志';
  LInfo.Version := '1.0.0';
  LInfo.Description := '任务执行日志查询界面';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System.UI';
  LInfo.AutoStart := False;
  LInfo.ConfigFile := '';
  LInfo.Dependencies := nil;
  LInfo.Priority := 703;
  LRegistry.RegisterPluginClass(TTaskLogFrame, LInfo.PluginID, LInfo);
end;

initialization
  // 自动注册所有系统模块
  // 注意：需要在应用程序启动时显式调用 RegisterAllModules

finalization
  // 清理工作由注册表完成

end.

program UniAdmin;

{
  UniAdmin - UniGUI 后台管理系统主程序

  基于 UniGUI 框架构建的 Web 管理应用
  端口: 8077 (可在配置文件中修改)
}

uses
  System.SysUtils,
  Winapi.Windows,
  UniGUIVars, uniGUIApplication, uniGUIClasses, uniGUIForm,
  IdGlobal,
  // 核心模块
  ServerModule in 'Core\Main\ServerModule.pas',
  MainModule in 'Core\Main\MainModule.pas',
  // 配置服务
  UniConfigService.Intf in 'Core\Config\UniConfigService.Intf.pas',
  UniConfigService in 'Core\Config\UniConfigService.pas',
  // 上下文
  UniContext in 'Core\Context\UniContext.pas',
  // 数据模块
  UniDataModule in 'Core\Data\UniDataModule.pas',
  UniConnectionManager.Intf in 'Core\Data\UniConnectionManager.Intf.pas',
  UniConnectionManager in 'Core\Data\UniConnectionManager.pas',
  // 认证服务
  UniAuthService.Intf in 'Core\Auth\UniAuthService.Intf.pas',
  UniAuthService in 'Core\Auth\UniAuthService.pas',
  // 权限管理
  UniPermissionManager.Intf in 'Core\Permission\UniPermissionManager.Intf.pas',
  UniPermissionManager in 'Core\Permission\UniPermissionManager.pas',
  // 菜单管理
  UniMenuManager.Intf in 'Core\Menu\UniMenuManager.Intf.pas',
  UniMenuManager in 'Core\Menu\UniMenuManager.pas',
  SystemMenuSetup in 'Core\Menu\SystemMenuSetup.pas',
  // 插件系统
  UniPlugin.Intf in 'Core\Plugin\UniPlugin.Intf.pas',
  UniPlugin.Types in 'Core\Plugin\UniPlugin.Types.pas',
  UniPlugin in 'Core\Plugin\UniPlugin.pas',
  UniModuleRegistry.Intf in 'Core\Plugin\UniModuleRegistry.Intf.pas',
  UniModuleRegistry in 'Core\Plugin\UniModuleRegistry.pas',
  UniModuleRegistration in 'Core\Plugin\UniModuleRegistration.pas',
  UniPluginLoader in 'Core\Plugin\UniPluginLoader.pas',
  // 会话管理
  UniSession in 'Core\Session\UniSession.pas',
  // 元数据
  UniMetadataCache.Intf in 'Core\Metadata\UniMetadataCache.Intf.pas',
  UniMetadataCache in 'Core\Metadata\UniMetadataCache.pas',
  UniFieldMetadata in 'Core\Metadata\UniFieldMetadata.pas',
  // 服务定位器
  UniServices in 'Core\Services\UniServices.pas',
  // 调度器
  UniScheduler in 'Core\Scheduler\UniScheduler.pas',
  UniTaskProcessor in 'Core\Scheduler\UniTaskProcessor.pas',
  // UI 组件
  LoginForm in 'Core\UI\LoginForm.pas',
  MainFrame in 'Core\UI\MainFrame.pas',
  UniLayout in 'Core\UI\UniLayout.pas',
  UniModelAdmin in 'Core\UI\UniModelAdmin.pas',
  UniPropertyEditor in 'Core\UI\UniPropertyEditor.pas',
  UniTheme in 'Core\UI\UniTheme.pas',
  BaseCrudFrame in 'Core\UI\BaseCrudFrame.pas',
  // UI 模板
  BaseFormTemplate in 'Core\UI\Templates\BaseFormTemplate.pas',
  DialogTemplate in 'Core\UI\Templates\DialogTemplate.pas',
  EditFormTemplate in 'Core\UI\Templates\EditFormTemplate.pas',
  GridTemplate in 'Core\UI\Templates\GridTemplate.pas',
  QueryPanelTemplate in 'Core\UI\Templates\QueryPanelTemplate.pas',
  SplitterTemplate in 'Core\UI\Templates\SplitterTemplate.pas',
  StatusBarTemplate in 'Core\UI\Templates\StatusBarTemplate.pas',
  TabSheetTemplate in 'Core\UI\Templates\TabSheetTemplate.pas',
  WizardTemplate in 'Core\UI\Templates\WizardTemplate.pas',
  // 业务模块 - 用户管理
  UserListFrame in 'Modules\User\UserListFrame.pas',
  UserEditForm in 'Modules\User\UserEditForm.pas',
  UserDataModule in 'Modules\User\UserDataModule.pas',
  UserPasswordDialog in 'Modules\User\UserPasswordDialog.pas',
  UserProfileFrame in 'Modules\User\UserProfileFrame.pas',
  UserService.Intf in 'Modules\User\UserService.Intf.pas',
  UserService in 'Modules\User\UserService.pas',
  // 业务模块 - 角色管理
  RoleListFrame in 'Modules\Role\RoleListFrame.pas',
  RoleEditForm in 'Modules\Role\RoleEditForm.pas',
  RoleDataModule in 'Modules\Role\RoleDataModule.pas',
  RolePermissionDialog in 'Modules\Role\RolePermissionDialog.pas',
  RoleUserDialog in 'Modules\Role\RoleUserDialog.pas',
  // 业务模块 - 菜单管理
  MenuTreeFrame in 'Modules\Menu\MenuTreeFrame.pas',
  MenuEditForm in 'Modules\Menu\MenuEditForm.pas',
  MenuDataModule in 'Modules\Menu\MenuDataModule.pas',
  // 业务模块 - 配置管理
  ConfigCategoryFrame in 'Modules\Config\ConfigCategoryFrame.pas',
  ConfigEditForm in 'Modules\Config\ConfigEditForm.pas',
  ConfigDataModule in 'Modules\Config\ConfigDataModule.pas',
  ConfigService.Intf in 'Modules\Config\ConfigService.Intf.pas',
  ConfigService in 'Modules\Config\ConfigService.pas',
  // 业务模块 - 日志管理
  DataChangeLogFrame in 'Modules\Log\DataChangeLogFrame.pas',
  LoginLogFrame in 'Modules\Log\LoginLogFrame.pas',
  OperationLogFrame in 'Modules\Log\OperationLogFrame.pas',
  LogDataModule in 'Modules\Log\LogDataModule.pas',
  LogExport in 'Modules\Log\LogExport.pas',
  LogService in 'Modules\Log\LogService.pas',
  // 业务模块 - 字典管理
  DictionaryListFrame in 'Plugins\Dictionary\DictionaryListFrame.pas',
  DictionaryDataModule in 'Plugins\Dictionary\DictionaryDataModule.pas',
  DictionaryPlugin in 'Plugins\Dictionary\DictionaryPlugin.pas',
  // 共享组件
  IconSelector in 'Modules\Shared\IconSelector.pas',
  // 框架页面
  ConfigManagerFrame in 'Frames\ConfigManagerFrame.pas',
  PluginManagerFrame in 'Frames\PluginManagerFrame.pas';

{$R *.res}

begin
  // 设置控制台输出编码为 UTF-8
  SetConsoleOutputCP(CP_UTF8);

  // 报告内存泄漏 (仅在调试模式下)
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}

  // 初始化应用程序
  Application.Initialize;

  // 创建服务器模块
  Application.ServerModuleClass := TServerModule;

  // 创建主模块
  Application.MainModuleClass := TMainModule;

  // 创建登录窗体
  Application.LoginFormClass := TLoginForm;

  // 创建主窗体
  Application.MainFormClass := TMainFrame;

  // 启动应用程序
  Application.Run;
end.

program UniAdmin;

{
  UniAdmin - UniGUI 后台管理系统主程序

  基于 UniGUI 框架构建的 Web 管理应用
  端口: 8077 (可在配置文件中修改)
}

uses
  System.SysUtils,
  Winapi.Windows,
  UniGUIVars,
  uniGUIApplication,
  uniGUIClasses,
  uniGUIForm,
  IdGlobal,
  ServerModule in 'Core\Main\ServerModule.pas' {TServerModule},
  MainModule in 'Core\Main\MainModule.pas' {TMainModule},
  UniConfigService.Intf in 'Core\Config\UniConfigService.Intf.pas',
  UniConfigService in 'Core\Config\UniConfigService.pas',
  UniContext in 'Core\Context\UniContext.pas',
  UniDataModule in 'Core\Data\UniDataModule.pas',
  UniConnectionManager.Intf in 'Core\Data\UniConnectionManager.Intf.pas',
  UniConnectionManager in 'Core\Data\UniConnectionManager.pas',
  UniAuthService.Intf in 'Core\Auth\UniAuthService.Intf.pas',
  UniAuthService in 'Core\Auth\UniAuthService.pas',
  UniPermissionManager.Intf in 'Core\Permission\UniPermissionManager.Intf.pas',
  UniPermissionManager in 'Core\Permission\UniPermissionManager.pas',
  UniMenuManager.Intf in 'Core\Menu\UniMenuManager.Intf.pas',
  UniMenuManager in 'Core\Menu\UniMenuManager.pas',
  SystemMenuSetup in 'Core\Menu\SystemMenuSetup.pas',
  UniPlugin.Intf in 'Core\Plugin\UniPlugin.Intf.pas',
  UniPlugin.Types in 'Core\Plugin\UniPlugin.Types.pas',
  UniPlugin in 'Core\Plugin\UniPlugin.pas',
  UniModuleRegistry.Intf in 'Core\Plugin\UniModuleRegistry.Intf.pas',
  UniModuleRegistry in 'Core\Plugin\UniModuleRegistry.pas',
  UniModuleRegistration in 'Core\Plugin\UniModuleRegistration.pas',
  UniPluginLoader in 'Core\Plugin\UniPluginLoader.pas',
  UniSession in 'Core\Session\UniSession.pas',
  UniMetadataCache.Intf in 'Core\Metadata\UniMetadataCache.Intf.pas',
  UniMetadataCache in 'Core\Metadata\UniMetadataCache.pas',
  UniFieldMetadata in 'Core\Metadata\UniFieldMetadata.pas',
  UniServices in 'Core\Services\UniServices.pas',
  UniScheduler in 'Core\Scheduler\UniScheduler.pas',
  UniTaskProcessor in 'Core\Scheduler\UniTaskProcessor.pas',
  LoginForm in 'Core\UI\LoginForm.pas',
  UniLayout in 'Core\UI\UniLayout.pas',
  UniModelAdmin in 'Core\UI\UniModelAdmin.pas',
  UniPropertyEditor in 'Core\UI\UniPropertyEditor.pas',
  UniTheme in 'Core\UI\UniTheme.pas',
  UserListFrame in 'Modules\User\UserListFrame.pas',
  UserEditForm in 'Modules\User\UserEditForm.pas',
  UserDataModule in 'Modules\User\UserDataModule.pas',
  UserPasswordDialog in 'Modules\User\UserPasswordDialog.pas',
  UserProfileFrame in 'Modules\User\UserProfileFrame.pas',
  UserService.Intf in 'Modules\User\UserService.Intf.pas',
  UserService in 'Modules\User\UserService.pas',
  RoleListFrame in 'Modules\Role\RoleListFrame.pas',
  RoleEditForm in 'Modules\Role\RoleEditForm.pas',
  RoleDataModule in 'Modules\Role\RoleDataModule.pas',
  RolePermissionDialog in 'Modules\Role\RolePermissionDialog.pas',
  RoleUserDialog in 'Modules\Role\RoleUserDialog.pas',
  MenuTreeFrame in 'Modules\Menu\MenuTreeFrame.pas',
  MenuEditForm in 'Modules\Menu\MenuEditForm.pas',
  MenuDataModule in 'Modules\Menu\MenuDataModule.pas',
  ConfigCategoryFrame in 'Modules\Config\ConfigCategoryFrame.pas',
  ConfigEditForm in 'Modules\Config\ConfigEditForm.pas',
  ConfigDataModule in 'Modules\Config\ConfigDataModule.pas',
  ConfigService.Intf in 'Modules\Config\ConfigService.Intf.pas',
  ConfigService in 'Modules\Config\ConfigService.pas',
  DataChangeLogFrame in 'Modules\Log\DataChangeLogFrame.pas',
  LoginLogFrame in 'Modules\Log\LoginLogFrame.pas',
  OperationLogFrame in 'Modules\Log\OperationLogFrame.pas',
  LogDataModule in 'Modules\Log\LogDataModule.pas',
  LogExport in 'Modules\Log\LogExport.pas',
  LogService in 'Modules\Log\LogService.pas',
  DictTypeFrame in 'Modules\Dictionary\DictTypeFrame.pas',
  DictItemFrame in 'Modules\Dictionary\DictItemFrame.pas',
  DictionaryDataModule in 'Modules\Dictionary\DictionaryDataModule.pas',
  DictionaryService.Intf in 'Modules\Dictionary\DictionaryService.Intf.pas',
  DictionaryService in 'Modules\Dictionary\DictionaryService.pas',
  IconSelector in 'Modules\Shared\IconSelector.pas',
  ConfigManagerFrame in 'Frames\ConfigManagerFrame.pas',
  PluginManagerFrame in 'Frames\PluginManagerFrame.pas',
  BaseFormTemplate in 'Core\UI\Templates\BaseFormTemplate.pas' {BaseFormTemplate: TUniForm},
  DialogTemplate in 'Core\UI\Templates\DialogTemplate.pas' {DialogTemplate: TUniForm},
  EditFormTemplate in 'Core\UI\Templates\EditFormTemplate.pas' {EditFormTemplate: TUniForm},
  WizardTemplate in 'Core\UI\Templates\WizardTemplate.pas' {WizardTemplate: TUniForm},
  GridTemplate in 'Core\UI\Templates\GridTemplate.pas' {GridTemplate: TUniForm},
  MainFrame in 'Core\UI\MainFrame.pas' {MainFrame: TUniForm},
  SampleTasks in 'Modules\Scheduler\SampleTasks.pas',
  TaskLogFrame in 'Modules\Scheduler\TaskLogFrame.pas',
  TaskManageFrame in 'Modules\Scheduler\TaskManageFrame.pas',
  BaseCrudFrame in 'Core\UI\BaseCrudFrame.pas';

{$R *.res}

begin
  // 设置控制台输出编码为 UTF-8
  SetConsoleOutputCP(CP_UTF8);

  // 报告内存泄漏 (仅在调试模式下)
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}

  // UniGUI 应用程序初始化
  // 注意: UniGUI 应用程序在 Web 服务器中运行，不需要传统的 Application.Run
  // 服务器模块会在首次请求时自动初始化
end.

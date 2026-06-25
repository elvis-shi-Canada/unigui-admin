unit DictionaryPlugin;

interface

uses
  System.SysUtils, System.Classes,
  UniContext, UniPlugin, UniPlugin.Intf, UniPlugin.Types,
  DictionaryDataModule, DictionaryListFrame;

type
  /// <summary>
  /// 数据字典插件类
  /// 提供数据字典管理功能
  /// </summary>
  TDictionaryPlugin = class(TPlugin)
  private
  protected
    procedure DoInitialize; override;
    procedure DoActivate; override;
    procedure DoDeactivate; override;
    procedure RegisterPermissions; override;
    procedure RegisterMenus; override;
  public
    constructor Create(const UserContext: IUserContext;
      const ExecutionContext: IExecutionContext); reintroduce;
    destructor Destroy; override;
  end;

implementation

{ TDictionaryPlugin }

constructor TDictionaryPlugin.Create(const UserContext: IUserContext;
  const ExecutionContext: IExecutionContext);
var
  LInfo: TPluginInfo;
begin
  // 设置插件信息
  LInfo.Name := 'Dictionary';
  LInfo.DisplayName := '数据字典管理';
  LInfo.Version := '1.0.0';
  LInfo.Description := '提供系统数据字典的管理功能，包括字典类型和字典项的增删改查。';
  LInfo.Author := 'UniAdmin Team';
  LInfo.Category := 'System';
  LInfo.AutoStart := True;
  LInfo.ConfigFile := '';

  // 调用父类构造函数
  inherited Create(LInfo, UserContext, ExecutionContext);
end;

destructor TDictionaryPlugin.Destroy;
begin
  inherited Destroy;
end;

procedure TDictionaryPlugin.DoInitialize;
var
  LDataModuleInfo: TDataModuleInfo;
  LFormInfo: TFormInfo;
begin
  inherited;

  // 注册数据模块
  LDataModuleInfo.DataModuleName := 'DictionaryDataModule';
  LDataModuleInfo.DataModuleClass := TDictionaryDataModule;
  LDataModuleInfo.Description := '数据字典数据访问模块';
  LDataModuleInfo.IsShared := True;
  RegisterDataModule(LDataModuleInfo);

  // 注册窗体
  LFormInfo.FormName := 'DictionaryListFrame';
  LFormInfo.FormClass := TDictionaryListFrame;
  LFormInfo.DisplayName := '数据字典';
  LFormInfo.Icon := 'dict.png';
  LFormInfo.RoutePath := '/system/dictionary';
  LFormInfo.SortOrder := 100;
  RegisterForm(LFormInfo);
end;

procedure TDictionaryPlugin.DoActivate;
begin
  inherited;
  // 插件激活时的处理
end;

procedure TDictionaryPlugin.DoDeactivate;
begin
  inherited;
  // 插件停用时的处理
end;

procedure TDictionaryPlugin.RegisterPermissions;
begin
  inherited;
  // 注册插件权限
  // dictionary.view - 查看数据字典
  // dictionary.add - 添加数据字典
  // dictionary.edit - 编辑数据字典
  // dictionary.delete - 删除数据字典
end;

procedure TDictionaryPlugin.RegisterMenus;
begin
  inherited;
  // 注册菜单项
  // 系统管理 -> 数据字典
end;

end.

unit UniPlugin.Intf;

interface

uses
  System.SysUtils, System.Classes,
  UniContext, UniPlugin.Types;

type
  // 插件状态枚举
  TPluginState = (psUninitialized, psInitializing, psInitialized, psActivated, psDeactivated, psError);

  // ��㨬?D??��
  TFormInfo = record
    FormName: string;
    FormClass: TFormClass;
    DisplayName: string;
    Icon: string;
    RoutePath: string;
    SortOrder: Integer;
  end;

  // DataModule D??��
  TDataModuleInfo = record
    DataModuleName: string;
    DataModuleClass: TDataModuleClass;
    Description: string;
    IsShared: Boolean;
  end;

  // 2??tD??��
  TPluginInfo = record
    Name: string;
    DisplayName: string;
    Version: string;
    Description: string;
    Author: string;
    Category: string;
    AutoStart: Boolean;
    ConfigFile: string;
  end;





  // 插件接口
  IPlugin = interface(IInterface)
    ['{B5A3C7F1-8D4A-2E6B-C1D8-8F3E5A7B9C2D}']
    function GetInfo: TPluginInfo;
    function GetState: TPluginState;
    procedure Initialize;
    procedure Activate;
    procedure Deactivate;
    function HasPermission(const Permission: string): Boolean;
  end;

implementation

end.
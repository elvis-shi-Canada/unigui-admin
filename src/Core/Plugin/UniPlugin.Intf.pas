unit UniPlugin.Intf;

interface

uses
  System.SysUtils, System.Classes,
  UniContext, UniPlugin.Types;

type
  // 2??t���䨬????��
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

  // 2??t?��?��
  IPlugin = interface(IInterface)
    ['{UNI-PLUGIN-001}']
    function GetInfo: TPluginInfo;
    function GetState: TPluginState;
    procedure Initialize;
    procedure Activate;
    procedure Deactivate;
    function HasPermission(const Permission: string): Boolean;
  end;

implementation

end.
unit UniPlugin.Intf;

interface

uses
  System.SysUtils, System.Classes,
  UniContext;

type
  // 2??t¡Á¡ä¨¬????¨´
  TPluginState = (psUninitialized, psInitializing, psInitialized, psActivated, psDeactivated, psError);

  // ¡ä¡ã¨¬?D??¡é
  TFormInfo = record
    FormName: string;
    FormClass: TFormClass;
    DisplayName: string;
    Icon: string;
    RoutePath: string;
    SortOrder: Integer;
  end;

  // DataModule D??¡é
  TDataModuleInfo = record
    DataModuleName: string;
    DataModuleClass: TDataModuleClass;
    Description: string;
    IsShared: Boolean;
  end;

  // 2??tD??¡é
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

  // 2??t?¨®?¨²
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
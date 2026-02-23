unit UniContext;

interface

uses
  System.SysUtils;

type
  // 那y?Y?a?????車?迆
  IDatabaseConfig = interface(IInterface)
    ['{UNI-DB-CONFIG-001}']
    function GetConnectionDefName: string;
    function GetConnectionString: string;
    function GetDatabaseName: string;
    function GetServerName: string;
  end;

  // 車??∫谷??????車?迆
  IUserContext = interface(IInterface)
    ['{UNI-USER-CONTEXT-001}']
    function GetUserID: Integer;
    function GetUserName: string;
    function GetRealName: string;
    function HasPermission(const PermissionCode: string): Boolean;
    function GetUserPermissions: TArray<string>;
    function GetDataScope(const Resource: string): string;
    function GetSessionID: string;
    function GetClientIP: string;
  end;

  // ?∩DD谷??????車?迆
  IExecutionContext = interface(IInterface)
    ['{UNI-EXECUTION-CONTEXT-001}']
    function GetUserContext: IUserContext;
    function GetCurrentUserID: Integer;
    function GetCurrentUserName: string;
    function GetCurrentTime: TDateTime;
    function GetDatabaseConfig: IDatabaseConfig;
  end;

implementation

end.
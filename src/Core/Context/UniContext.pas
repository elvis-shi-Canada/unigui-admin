unit UniContext;

interface

uses
  System.SysUtils;

type
  // ?据?配置接口
  IDatabaseConfig = interface(IInterface)
    ['{5D762A2D-F75D-481E-8696-22A1CBF147BD}']
    function GetConnectionDefName: string;
    function GetConnectionString: string;
    function GetDatabaseName: string;
    function GetServerName: string;
  end;

  // 用户上下文接口
  IUserContext = interface(IInterface)
    ['{A2C8E4B1-7F5A-3D4B-C2DA-8A7E9F1B4C6D}']
    function GetUserID: Integer;
    function GetUserName: string;
    function GetRealName: string;
    function HasPermission(const PermissionCode: string): Boolean;
    function GetUserPermissions: TArray<string>;
    function GetDataScope(const Resource: string): string;
    function GetSessionID: string;
    function GetClientIP: string;
  end;

  // ?行上下文接口
  IExecutionContext = interface(IInterface)
    ['{E3D9F5C2-B4A8-5C3D-D7EA-1B8C4E9A2F6B}']
    function GetUserContext: IUserContext;
    function GetCurrentUserID: Integer;
    function GetCurrentUserName: string;
    function GetCurrentTime: TDateTime;
    function GetDatabaseConfig: IDatabaseConfig;
  end;

implementation

end.
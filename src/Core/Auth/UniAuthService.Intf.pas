unit UniAuthService.Intf;

interface

uses
  System.SysUtils;

type
  /// <summary>
  /// 登录结果
  /// </summary>
  TLoginResult = record
    Success: Boolean;
    UserID: Integer;
    UserName: string;
    RealName: string;
    Message: string;
    Token: string;
  end;

  /// <summary>
  /// 认证服务接口
  /// </summary>
  IUniAuthService = interface(IInterface)
    ['{F7A8D9E1-5B3C-4E7D-A2F9-9C8B1E4D6F3A}']
    function Login(const UserName, Password: string): TLoginResult;
    procedure Logout(const SessionID: string);
    function ValidateToken(const Token: string): Boolean;
    function ChangePassword(const UserID: Integer; const OldPassword, NewPassword: string): Boolean;
    function ValidatePassword(const Password: string): Boolean;
  end;

implementation

end.

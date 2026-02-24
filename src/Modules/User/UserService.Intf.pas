unit UserService.Intf;

interface

uses
  System.SysUtils, System.Types;

type
  /// <summary>
  /// 用户信息记录
  /// </summary>
  TUserInfo = record
    UserID: Integer;
    UserName: string;
    RealName: string;
    Email: string;
    Phone: string;
    Avatar: string;
    Status: Integer;
    StatusText: string;
    LastLoginDate: TDateTime;
    LastLoginIP: string;
    CreatedDate: TDateTime;
    CreatedBy: Integer;
    ModifiedDate: TDateTime;
    ModifiedBy: Integer;
    
    // 辅助方法
    class function Create: TUserInfo; static;
    function IsActive: Boolean;
  end;

  /// <summary>
  /// 用户服务接口 - 提供用户业务逻辑
  /// </summary>
  IUniUserService = interface(IInterface)
    ['{UNI-USER-SERVICE-001}']
    
    /// <summary>
    /// 获取用户分页列表
    /// </summary>
    function GetUsers(const Filter: string; Status: Integer; Page, PageSize: Integer): TArray<TUserInfo>;
    
    /// <summary>
    /// 获取用户总数
    /// </summary>
    function GetUsersCount(const Filter: string; Status: Integer): Integer;
    
    /// <summary>
    /// 根据用户ID获取用户信息
    /// </summary>
    function GetUserByID(UserID: Integer): TUserInfo;
    
    /// <summary>
    /// 根据用户名获取用户信息
    /// </summary>
    function GetUserByName(const UserName: string): TUserInfo;
    
    /// <summary>
    /// 创建用户
    /// </summary>
    function CreateUser(const UserName, Password, RealName, Email, Phone: string): Integer;
    
    /// <summary>
    /// 更新用户信息
    /// </summary>
    procedure UpdateUser(UserID: Integer; const RealName, Email, Phone: string);
    
    /// <summary>
    /// 删除用户
    /// </summary>
    procedure DeleteUser(UserID: Integer);
    
    /// <summary>
    /// 设置用户状态
    /// </summary>
    procedure SetUserStatus(UserID, Status: Integer);
    
    /// <summary>
    /// 检查用户是否可用（启用状态）
    /// </summary>
    function IsUserAvailable(UserID: Integer): Boolean;
    
    /// <summary>
    /// 用户修改密码
    /// </summary>
    procedure ChangePassword(UserID: Integer; const OldPassword, NewPassword: string);
    
    /// <summary>
    /// 管理员重置用户密码
    /// </summary>
    procedure ResetPassword(UserID: Integer; const NewPassword: string);
    
    /// <summary>
    /// 验证用户密码
    /// </summary>
    function VerifyPassword(const UserName, Password: string): Boolean;
    
    /// <summary>
    /// 检查用户名是否存在
    /// </summary>
    function UserNameExists(const UserName: string): Boolean;
    
    /// <summary>
    /// 检查邮箱是否存在
    /// </summary>
    function EmailExists(const Email: string): Boolean;
  end;

implementation

{ TUserInfo }

class function TUserInfo.Create: TUserInfo;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.Status := 1;
  Result.StatusText := '启用';
end;

function TUserInfo.IsActive: Boolean;
begin
  Result := Status = 1;
end;

end.

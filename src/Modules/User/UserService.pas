unit UserService;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Generics.Collections,
  Data.DB,
  UniContext, UniPlugin.Types,
  UserService.Intf, UserDataModule;

type
  /// <summary>
  /// 用户服务类 - 用户业务逻辑实现
  /// </summary>
  TUniUserService = class(TInterfacedObject, IUniUserService)
  private
    FContext: IExecutionContext;
    FDataModule: TUserDataModule;
    
    procedure InitializeDataModule;
    procedure FinalizeDataModule;
    function DataSetToUserInfo(const DataSet: TDataSet): TUserInfo;
    function GetStatusText(Status: Integer): string;
  public
    constructor Create(const Context: IExecutionContext); reintroduce;
    destructor Destroy; override;
    
    // 用户查询
    function GetUsers(const Filter: string; Status: Integer; Page, PageSize: Integer): TArray<TUserInfo>;
    function GetUsersCount(const Filter: string; Status: Integer): Integer;
    function GetUserByID(UserID: Integer): TUserInfo;
    function GetUserByName(const UserName: string): TUserInfo;
    
    // 用户操作
    function CreateUser(const UserName, Password, RealName, Email, Phone: string): Integer;
    procedure UpdateUser(UserID: Integer; const RealName, Email, Phone: string);
    procedure DeleteUser(UserID: Integer);
    procedure SetUserStatus(UserID, Status: Integer);
    function IsUserAvailable(UserID: Integer): Boolean;
    
    // 密码管理
    procedure ChangePassword(UserID: Integer; const OldPassword, NewPassword: string);
    procedure ResetPassword(UserID: Integer; const NewPassword: string);
    function VerifyPassword(const UserName, Password: string): Boolean;
    
    // 验证方法
    function UserNameExists(const UserName: string): Boolean;
    function EmailExists(const Email: string): Boolean;
  end;

implementation

{ TUniUserService }

constructor TUniUserService.Create(const Context: IExecutionContext);
begin
  inherited Create;
  FContext := Context;
  InitializeDataModule;
end;

destructor TUniUserService.Destroy;
begin
  FinalizeDataModule;
  inherited;
end;

procedure TUniUserService.InitializeDataModule;
begin
  FDataModule := TUserDataModule.Create(nil);
  if Supports(FDataModule, IContextAware) then
    (FDataModule as IContextAware).SetContext(FContext);
  FDataModule.Open;
end;

procedure TUniUserService.FinalizeDataModule;
begin
  if Assigned(FDataModule) then
  begin
    FDataModule.Close;
    FDataModule.Free;
  end;
end;

function TUniUserService.DataSetToUserInfo(const DataSet: TDataSet): TUserInfo;
begin
  Result.UserID := DataSet.FieldByName('UserID').AsInteger;
  Result.UserName := DataSet.FieldByName('UserName').AsString;
  Result.RealName := DataSet.FieldByName('RealName').AsString;
  Result.Email := DataSet.FieldByName('Email').AsString;
  Result.Phone := DataSet.FieldByName('Phone').AsString;
  Result.Avatar := DataSet.FieldByName('Avatar').AsString;
  Result.Status := DataSet.FieldByName('Status').AsInteger;
  Result.StatusText := GetStatusText(Result.Status);
  
  if not DataSet.FieldByName('LastLoginDate').IsNull then
    Result.LastLoginDate := DataSet.FieldByName('LastLoginDate').AsDateTime
  else
    Result.LastLoginDate := 0;
    
  Result.LastLoginIP := DataSet.FieldByName('LastLoginIP').AsString;
  
  if not DataSet.FieldByName('CreatedDate').IsNull then
    Result.CreatedDate := DataSet.FieldByName('CreatedDate').AsDateTime
  else
    Result.CreatedDate := 0;
    
  Result.CreatedBy := DataSet.FieldByName('CreatedBy').AsInteger;
  
  if not DataSet.FieldByName('ModifiedDate').IsNull then
    Result.ModifiedDate := DataSet.FieldByName('ModifiedDate').AsDateTime
  else
    Result.ModifiedDate := 0;
    
  Result.ModifiedBy := DataSet.FieldByName('ModifiedBy').AsInteger;
end;

function TUniUserService.GetStatusText(Status: Integer): string;
begin
  case Status of
    0: Result := '禁用';
    1: Result := '启用';
    else
      Result := '未知';
  end;
end;

function TUniUserService.GetUsers(const Filter: string; Status: Integer; 
  Page, PageSize: Integer): TArray<TUserInfo>;
var
  LDataSet: TDataSet;
  LList: TList<TUserInfo>;
  I, LOffset: Integer;
begin
  LList := TList<TUserInfo>.Create;
  try
    LDataSet := FDataModule.GetUsers(Filter, Status);
    try
      LOffset := (Page - 1) * PageSize;
      LDataSet.RecNo := LOffset + 1;
      
      I := 0;
      while not LDataSet.Eof and (I < PageSize) do
      begin
        LList.Add(DataSetToUserInfo(LDataSet));
        LDataSet.Next;
        Inc(I);
      end;
      
      Result := LList.ToArray;
    finally
      LDataSet.Free;
    end;
  finally
    LList.Free;
  end;
end;

function TUniUserService.GetUsersCount(const Filter: string; Status: Integer): Integer;
var
  LDataSet: TDataSet;
begin
  LDataSet := FDataModule.GetUsers(Filter, Status);
  try
    Result := LDataSet.RecordCount;
  finally
    LDataSet.Free;
  end;
end;

function TUniUserService.GetUserByID(UserID: Integer): TUserInfo;
var
  LDataSet: TDataSet;
begin
  Result := Default(TUserInfo);

  LDataSet := FDataModule.GetUserByID(UserID);
  try
    if not LDataSet.Eof then
      Result := DataSetToUserInfo(LDataSet)
    else
      raise Exception.CreateFmt('用户 ID %d 不存在', [UserID]);
  finally
    LDataSet.Free;
  end;
end;

function TUniUserService.GetUserByName(const UserName: string): TUserInfo;
var
  LDataSet: TDataSet;
begin
  Result := Default(TUserInfo);

  LDataSet := FDataModule.GetUserByName(UserName);
  try
    if not LDataSet.Eof then
      Result := DataSetToUserInfo(LDataSet)
    else
      raise Exception.CreateFmt('用户 %s 不存在', [UserName]);
  finally
    LDataSet.Free;
  end;
end;

function TUniUserService.CreateUser(const UserName, Password, RealName, Email, Phone: string): Integer;
begin
  Result := FDataModule.CreateUser(UserName, Password, RealName, Email, Phone);
  // TODO: 记录操作日志
end;

procedure TUniUserService.UpdateUser(UserID: Integer; const RealName, Email, Phone: string);
begin
  FDataModule.UpdateUser(UserID, RealName, Email, Phone);
  // TODO: 记录操作日志
end;

procedure TUniUserService.DeleteUser(UserID: Integer);
begin
  FDataModule.DeleteUser(UserID);
  // TODO: 记录操作日志
end;

procedure TUniUserService.SetUserStatus(UserID, Status: Integer);
begin
  FDataModule.SetUserStatus(UserID, Status);
  // TODO: 记录操作日志
end;

function TUniUserService.IsUserAvailable(UserID: Integer): Boolean;
var
  LInfo: TUserInfo;
begin
  try
    LInfo := GetUserByID(UserID);
    Result := LInfo.IsActive;
  except
    Result := False;
  end;
end;

procedure TUniUserService.ChangePassword(UserID: Integer; const OldPassword, NewPassword: string);
begin
  FDataModule.ChangePassword(UserID, OldPassword, NewPassword);
  // TODO: 记录操作日志
end;

procedure TUniUserService.ResetPassword(UserID: Integer; const NewPassword: string);
begin
  FDataModule.ResetPassword(UserID, NewPassword);
  // TODO: 记录操作日志
end;

function TUniUserService.VerifyPassword(const UserName, Password: string): Boolean;
begin
  Result := FDataModule.VerifyPassword(UserName, Password);
end;

function TUniUserService.UserNameExists(const UserName: string): Boolean;
begin
  Result := FDataModule.UserNameExists(UserName);
end;

function TUniUserService.EmailExists(const Email: string): Boolean;
begin
  Result := FDataModule.EmailExists(Email);
end;

end.

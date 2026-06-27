unit UniAdminAuthService;

interface

uses
  System.SysUtils, System.Classes, System.Hash, System.Generics.Collections,
  System.Character,
  Data.DB, FireDAC.Comp.Client,
  UniAdminAuthService.Intf;

type
  TUniAdminAuthService = class(TInterfacedObject, IUniAdminAuthService)
  private
    FConnection: TFDConnection;
    FActiveSessions: TDictionary<string, TLoginResult>;

    function HashPassword(const Password: string): string;
    function VerifyPassword(const Password, Hash: string): Boolean;
    function GetUserPermissions(const UserID: Integer): TArray<string>;
  public
    constructor Create(const Connection: TFDConnection);
    destructor Destroy; override;

    function Login(const UserName, Password: string): TLoginResult;
    procedure Logout(const SessionID: string);
    function ValidateToken(const Token: string): Boolean;
    function ChangePassword(const UserID: Integer; const OldPassword, NewPassword: string): Boolean;
    function ValidatePassword(const Password: string): Boolean;
  end;

implementation

{ TUniAdminAuthService }

constructor TUniAdminAuthService.Create(const Connection: TFDConnection);
begin
  inherited Create;
  if not Assigned(Connection) then
    raise Exception.Create('Database connection cannot be nil');
  FConnection := Connection;
  FActiveSessions := TDictionary<string, TLoginResult>.Create;
end;

destructor TUniAdminAuthService.Destroy;
begin
  FActiveSessions.Free;
  inherited;
end;

function TUniAdminAuthService.HashPassword(const Password: string): string;
begin
  // 使用 SHA256 哈希密码（实际应使用更安全的哈希算法如 bcrypt）
  Result := THashSHA2.GetHashString(Password);
end;

function TUniAdminAuthService.VerifyPassword(const Password, Hash: string): Boolean;
begin
  Result := (HashPassword(Password) = Hash);
end;

function TUniAdminAuthService.Login(const UserName, Password: string): TLoginResult;
var
  LQuery: TFDQuery;
  LHashedPassword: string;
begin
  Result.Success := False;
  Result.UserID := 0;
  Result.UserName := '';
  Result.RealName := '';
  Result.Message := '';
  Result.Token := '';

  if not Assigned(FConnection) then
  begin
    Result.Message := '数据库连接未设置';
    Exit;
  end;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'SELECT UserID, UserName, RealName, Password, Status FROM UniAdmin_Users WHERE UserName = :UserName';
    LQuery.ParamByName('UserName').AsString := UserName;

    try
      LQuery.Open;
    except
      on E: Exception do
      begin
        Result.Message := '数据库查询失败: ' + E.Message;
        Exit;
      end;
    end;

    if LQuery.Eof then
    begin
      Result.Message := '用户不存在';
      Exit;
    end;

    // 检查用户状态
    if LQuery.FieldByName('Status').AsInteger <> 1 then
    begin
      Result.Message := '用户已被禁用';
      Exit;
    end;

    // 验证密码
    LHashedPassword := LQuery.FieldByName('Password').AsString;
    if not VerifyPassword(Password, LHashedPassword) then
    begin
      Result.Message := '密码错误';
      Exit;
    end;

    // 登录成功
    Result.Success := True;
    Result.UserID := LQuery.FieldByName('UserID').AsInteger;
    Result.UserName := LQuery.FieldByName('UserName').AsString;
    Result.RealName := LQuery.FieldByName('RealName').AsString;
    Result.Message := '登录成功';
    Result.Token := TGUID.NewGuid.ToString;

    // 记录登录信息
    FActiveSessions.Add(Result.Token, Result);

  finally
    LQuery.Free;
  end;
end;

procedure TUniAdminAuthService.Logout(const SessionID: string);
begin
  if FActiveSessions.ContainsKey(SessionID) then
    FActiveSessions.Remove(SessionID);
end;

function TUniAdminAuthService.ValidateToken(const Token: string): Boolean;
begin
  Result := FActiveSessions.ContainsKey(Token);
end;

function TUniAdminAuthService.ChangePassword(const UserID: Integer;
  const OldPassword, NewPassword: string): Boolean;
var
  LQuery: TFDQuery;
  LOldHash, LNewHash: string;
begin
  Result := False;

  // 验证新密码强度
  if not ValidatePassword(NewPassword) then
    Exit;

  if not Assigned(FConnection) then
    Exit;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'SELECT Password FROM UniAdmin_Users WHERE UserID = :UserID';
    LQuery.ParamByName('UserID').AsInteger := UserID;

    try
      LQuery.Open;
    except
      on E: Exception do
        Exit;
    end;

    if LQuery.Eof then
      Exit;

    LOldHash := LQuery.FieldByName('Password').AsString;
    if not VerifyPassword(OldPassword, LOldHash) then
      Exit;

    // 更新密码
    LNewHash := HashPassword(NewPassword);
    LQuery.Close;
    LQuery.SQL.Text := 'UPDATE UniAdmin_Users SET Password = :Password, ModifiedDate = CURRENT_TIMESTAMP WHERE UserID = :UserID';
    LQuery.ParamByName('Password').AsString := LNewHash;
    LQuery.ParamByName('UserID').AsInteger := UserID;

    try
      LQuery.ExecSQL;
      Result := True;
    except
      Result := False;
    end;
  finally
    LQuery.Free;
  end;
end;

function TUniAdminAuthService.ValidatePassword(const Password: string): Boolean;
var
  LHasUpper, LHasLower, LHasDigit: Boolean;
  I: Integer;
  LChar: Char;
begin
  // 最小长度检查
  if Length(Password) < 6 then
    Exit(False);

  // 复杂度检查
  LHasUpper := False;
  LHasLower := False;
  LHasDigit := False;

  for I := 1 to Length(Password) do
  begin
    LChar := Password[I];
    if CharInSet(LChar, ['A'..'Z']) then
      LHasUpper := True
    else if CharInSet(LChar, ['a'..'z']) then
      LHasLower := True
    else if CharInSet(LChar, ['0'..'9']) then
      LHasDigit := True;
  end;

  Result := LHasUpper and LHasLower and LHasDigit;
end;

function TUniAdminAuthService.GetUserPermissions(const UserID: Integer): TArray<string>;
var
  LQuery: TFDQuery;
  LList: TList<string>;
begin
  LList := TList<string>.Create;
  try
    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := FConnection;
      LQuery.SQL.Text :=
        'SELECT DISTINCT p.PermissionCode ' +
        'FROM UniAdmin_UserRoles ur ' +
        'JOIN UniAdmin_RolePermissions rp ON ur.RoleID = rp.RoleID ' +
        'JOIN UniAdmin_Permissions p ON rp.PermissionID = p.PermissionID ' +
        'WHERE ur.UserID = :UserID';
      LQuery.ParamByName('UserID').AsInteger := UserID;

      try
        LQuery.Open;
        while not LQuery.Eof do
        begin
          LList.Add(LQuery.FieldByName('PermissionCode').AsString);
          LQuery.Next;
        end;
      except
        on E: Exception do
          // 静默失败 - 返回空数组
      end;

      Result := LList.ToArray;
    finally
      LQuery.Free;
    end;
  finally
    LList.Free;
  end;
end;

end.

unit UserDataModule;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Hash,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Stan.Param,
  UniContext, UniPlugin.Types, UniDataModule,
  UserService.Intf;

type
  /// <summary>
  /// 用户数据模块 - 提供用户表的 CRUD 操作
  /// </summary>
  TUserDataModule = class(TUniDataModule)
  private
    function HashPassword(const Password: string): string;
    function ValidateEmail(const Email: string): Boolean;
    function ValidatePhone(const Phone: string): Boolean;
  public
    /// <summary>
    /// 根据用户 ID 获取用户信息
    /// </summary>
    function GetUserByID(UserID: Integer): TDataSet;
    
    /// <summary>
    /// 根据用户名获取用户信息
    /// </summary>
    function GetUserByName(const UserName: string): TDataSet;
    
    /// <summary>
    /// 获取用户列表（支持筛选）
    /// </summary>
    function GetUsers(const Filter: string; Status: Integer = -1): TDataSet;
    
    /// <summary>
    /// 创建新用户
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
    /// 验证用户密码
    /// </summary>
    function VerifyPassword(const UserName, Password: string): Boolean;
    
    /// <summary>
    /// 修改用户密码
    /// </summary>
    procedure ChangePassword(UserID: Integer; const OldPassword, NewPassword: string);
    
    /// <summary>
    /// 重置用户密码（管理员操作）
    /// </summary>
    procedure ResetPassword(UserID: Integer; const NewPassword: string);
    
    /// <summary>
    /// 设置用户状态
    /// </summary>
    procedure SetUserStatus(UserID: Integer; Status: Integer);
    
    /// <summary>
    /// 更新最后登录信息
    /// </summary>
    procedure UpdateLastLogin(UserID: Integer; const IP: string);
    
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

{ TUserDataModule }

function TUserDataModule.GetUserByID(UserID: Integer): TDataSet;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text := 
      'SELECT UserID, UserName, RealName, Email, Phone, Avatar, Status, ' +
      'LastLoginDate, LastLoginIP, CreatedDate, CreatedBy, ModifiedDate, ModifiedBy ' +
      'FROM UniAdmin_Users ' +
      'WHERE UserID = :UserID';
    LQuery.Params.ParamByName('UserID').AsInteger := UserID;
    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    raise;
  end;
end;

function TUserDataModule.GetUserByName(const UserName: string): TDataSet;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text := 
      'SELECT UserID, UserName, RealName, Email, Phone, Avatar, Status, ' +
      'LastLoginDate, LastLoginIP, CreatedDate, CreatedBy, ModifiedDate, ModifiedBy ' +
      'FROM UniAdmin_Users ' +
      'WHERE UserName = :UserName';
    LQuery.Params.ParamByName('UserName').AsString := UserName;
    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    raise;
  end;
end;

function TUserDataModule.GetUsers(const Filter: string; Status: Integer): TDataSet;
var
  LQuery: TFDQuery;
  LSQL: string;
  LWhere: string;
  LWhereList: TStringList;
begin
  LQuery := TFDQuery.Create(nil);
  LWhereList := TStringList.Create;
  try
    LQuery.Connection := Connection;
    
    // 构建 SQL
    LSQL := 'SELECT UserID, UserName, RealName, Email, Phone, Avatar, Status, ' +
            'LastLoginDate, LastLoginIP, CreatedDate, CreatedBy, ModifiedDate, ModifiedBy ' +
            'FROM UniAdmin_Users';
    
    // 构建条件
    if Filter <> '' then
      LWhereList.Add('(UserName LIKE :Filter OR RealName LIKE :Filter OR Email LIKE :Filter)');
    
    if Status >= 0 then
      LWhereList.Add('Status = :Status');
    
    if LWhereList.Count > 0 then
    begin
      LWhere := ' WHERE ' + LWhereList.Text.Replace(#13#10, ' AND ');
      LSQL := LSQL + LWhere;
    end;
    
    LSQL := LSQL + ' ORDER BY UserID DESC';
    
    LQuery.SQL.Text := LSQL;
    
    // 设置参数
    if Filter <> '' then
      LQuery.Params.ParamByName('Filter').AsString := '%' + Filter + '%';
      
    if Status >= 0 then
      LQuery.Params.ParamByName('Status').AsInteger := Status;
    
    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    LWhereList.Free;
    raise;
  end;
  LWhereList.Free;
end;

function TUserDataModule.CreateUser(const UserName, Password, RealName, Email, Phone: string): Integer;
var
  LQuery: TFDQuery;
begin
  // 验证输入
  if UserName.Trim.IsEmpty then
    raise Exception.Create('用户名不能为空');
    
  if Password.Trim.IsEmpty then
    raise Exception.Create('密码不能为空');
    
  if RealName.Trim.IsEmpty then
    raise Exception.Create('真实姓名不能为空');
    
  if not ValidateEmail(Email) then
    raise Exception.Create('邮箱格式不正确');
    
  if (Phone <> '') and not ValidatePhone(Phone) then
    raise Exception.Create('手机号码格式不正确');
    
  if UserNameExists(UserName) then
    raise Exception.Create('用户名已存在');
    
  if EmailExists(Email) then
    raise Exception.Create('邮箱已被使用');
  
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text := 
      'INSERT INTO UniAdmin_Users ' +
      '(UserName, Password, RealName, Email, Phone, Status, CreatedDate, CreatedBy) ' +
      'VALUES (:UserName, :Password, :RealName, :Email, :Phone, 1, CURRENT_TIMESTAMP, :CreatedBy)';
    
    LQuery.Params.ParamByName('UserName').AsString := UserName;
    LQuery.Params.ParamByName('Password').AsString := HashPassword(Password);
    LQuery.Params.ParamByName('RealName').AsString := RealName;
    LQuery.Params.ParamByName('Email').AsString := Email;
    LQuery.Params.ParamByName('Phone').AsString := Phone;
    LQuery.Params.ParamByName('CreatedBy').AsInteger := GetCurrentUserID;
    
    LQuery.ExecSQL;
    
    // 返回新插入的用户 ID
    LQuery.SQL.Text := 'SELECT last_insert_rowid() AS NewID';
    LQuery.Open;
    Result := LQuery.FieldByName('NewID').AsInteger;
  finally
    LQuery.Free;
  end;
end;

procedure TUserDataModule.UpdateUser(UserID: Integer; const RealName, Email, Phone: string);
var
  LQuery: TFDQuery;
  LOldEmail: string;
begin
  // 验证输入
  if RealName.Trim.IsEmpty then
    raise Exception.Create('真实姓名不能为空');
    
  if not ValidateEmail(Email) then
    raise Exception.Create('邮箱格式不正确');
    
  if (Phone <> '') and not ValidatePhone(Phone) then
    raise Exception.Create('手机号码格式不正确');
  
  // 检查邮箱唯一性（排除自己）
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text := 'SELECT Email FROM UniAdmin_Users WHERE UserID = :UserID';
    LQuery.Params.ParamByName('UserID').AsInteger := UserID;
    LQuery.Open;
    
    if not LQuery.Eof then
      LOldEmail := LQuery.FieldByName('Email').AsString
    else
      raise Exception.Create('用户不存在');
      
    LQuery.Close;
    
    if (LOldEmail <> Email) and EmailExists(Email) then
      raise Exception.Create('邮箱已被使用');
    
    // 更新用户信息
    LQuery.SQL.Text := 
      'UPDATE UniAdmin_Users ' +
      'SET RealName = :RealName, Email = :Email, Phone = :Phone, ' +
      'ModifiedDate = CURRENT_TIMESTAMP, ModifiedBy = :ModifiedBy ' +
      'WHERE UserID = :UserID';
    
    LQuery.Params.ParamByName('UserID').AsInteger := UserID;
    LQuery.Params.ParamByName('RealName').AsString := RealName;
    LQuery.Params.ParamByName('Email').AsString := Email;
    LQuery.Params.ParamByName('Phone').AsString := Phone;
    LQuery.Params.ParamByName('ModifiedBy').AsInteger := GetCurrentUserID;
    
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

procedure TUserDataModule.DeleteUser(UserID: Integer);
var
  LQuery: TFDQuery;
begin
  // 不允许删除 ID 为 1 的超级管理员
  if UserID = 1 then
    raise Exception.Create('不能删除超级管理员');
  
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text := 'DELETE FROM UniAdmin_Users WHERE UserID = :UserID';
    LQuery.Params.ParamByName('UserID').AsInteger := UserID;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

function TUserDataModule.VerifyPassword(const UserName, Password: string): Boolean;
var
  LQuery: TFDQuery;
  LHashedPassword: string;
begin
  Result := False;
  
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text := 'SELECT Password FROM UniAdmin_Users WHERE UserName = :UserName AND Status = 1';
    LQuery.Params.ParamByName('UserName').AsString := UserName;
    LQuery.Open;
    
    if not LQuery.Eof then
    begin
      LHashedPassword := LQuery.FieldByName('Password').AsString;
      Result := (LHashedPassword = HashPassword(Password));
    end;
  finally
    LQuery.Free;
  end;
end;

procedure TUserDataModule.ChangePassword(UserID: Integer; const OldPassword, NewPassword: string);
var
  LQuery: TFDQuery;
  LOldHash: string;
begin
  // 验证新密码强度
  if Length(NewPassword) < 8 then
    raise Exception.Create('新密码长度不能少于 8 位');
  
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    
    // 验证旧密码
    LQuery.SQL.Text := 'SELECT Password FROM UniAdmin_Users WHERE UserID = :UserID';
    LQuery.Params.ParamByName('UserID').AsInteger := UserID;
    LQuery.Open;
    
    if LQuery.Eof then
      raise Exception.Create('用户不存在')
    else
    begin
      LOldHash := LQuery.FieldByName('Password').AsString;
      if LOldHash <> HashPassword(OldPassword) then
        raise Exception.Create('旧密码不正确');
    end;
    
    LQuery.Close;
    
    // 更新密码
    LQuery.SQL.Text := 
      'UPDATE UniAdmin_Users ' +
      'SET Password = :Password, ModifiedDate = CURRENT_TIMESTAMP, ModifiedBy = :ModifiedBy ' +
      'WHERE UserID = :UserID';
    
    LQuery.Params.ParamByName('UserID').AsInteger := UserID;
    LQuery.Params.ParamByName('Password').AsString := HashPassword(NewPassword);
    LQuery.Params.ParamByName('ModifiedBy').AsInteger := GetCurrentUserID;
    
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

procedure TUserDataModule.ResetPassword(UserID: Integer; const NewPassword: string);
var
  LQuery: TFDQuery;
begin
  // 验证新密码强度
  if Length(NewPassword) < 8 then
    raise Exception.Create('密码长度不能少于 8 位');
  
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text := 
      'UPDATE UniAdmin_Users ' +
      'SET Password = :Password, ModifiedDate = CURRENT_TIMESTAMP, ModifiedBy = :ModifiedBy ' +
      'WHERE UserID = :UserID';
    
    LQuery.Params.ParamByName('UserID').AsInteger := UserID;
    LQuery.Params.ParamByName('Password').AsString := HashPassword(NewPassword);
    LQuery.Params.ParamByName('ModifiedBy').AsInteger := GetCurrentUserID;
    
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

procedure TUserDataModule.SetUserStatus(UserID: Integer; Status: Integer);
var
  LQuery: TFDQuery;
begin
  // 不允许禁用 ID 为 1 的超级管理员
  if (UserID = 1) and (Status = 0) then
    raise Exception.Create('不能禁用超级管理员');
  
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text := 
      'UPDATE UniAdmin_Users ' +
      'SET Status = :Status, ModifiedDate = CURRENT_TIMESTAMP, ModifiedBy = :ModifiedBy ' +
      'WHERE UserID = :UserID';
    
    LQuery.Params.ParamByName('UserID').AsInteger := UserID;
    LQuery.Params.ParamByName('Status').AsInteger := Status;
    LQuery.Params.ParamByName('ModifiedBy').AsInteger := GetCurrentUserID;
    
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

procedure TUserDataModule.UpdateLastLogin(UserID: Integer; const IP: string);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text := 
      'UPDATE UniAdmin_Users ' +
      'SET LastLoginDate = CURRENT_TIMESTAMP, LastLoginIP = :IP ' +
      'WHERE UserID = :UserID';
    
    LQuery.Params.ParamByName('UserID').AsInteger := UserID;
    LQuery.Params.ParamByName('IP').AsString := IP;
    
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

function TUserDataModule.UserNameExists(const UserName: string): Boolean;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text := 'SELECT COUNT(*) AS Cnt FROM UniAdmin_Users WHERE UserName = :UserName';
    LQuery.Params.ParamByName('UserName').AsString := UserName;
    LQuery.Open;
    Result := LQuery.FieldByName('Cnt').AsInteger > 0;
  finally
    LQuery.Free;
  end;
end;

function TUserDataModule.EmailExists(const Email: string): Boolean;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text := 'SELECT COUNT(*) AS Cnt FROM UniAdmin_Users WHERE Email = :Email';
    LQuery.Params.ParamByName('Email').AsString := Email;
    LQuery.Open;
    Result := LQuery.FieldByName('Cnt').AsInteger > 0;
  finally
    LQuery.Free;
  end;
end;

function TUserDataModule.HashPassword(const Password: string): string;
var
  LHash: THashSHA2;
begin
  LHash := THashSHA2.Create;
  Result := LHash.GetHashString(Password);
end;

function TUserDataModule.ValidateEmail(const Email: string): Boolean;
begin
  // 简单的邮箱格式验证
  Result := (Pos('@', Email) > 1) and (Pos('.', Email) > Pos('@', Email) + 1);
end;

function TUserDataModule.ValidatePhone(const Phone: string): Boolean;
var
  I: Integer;
begin
  // 简单的手机号验证（11位数字）
  Result := (Length(Phone) = 11);
  if Result then
  begin
    for I := 1 to 11 do
    begin
      if not CharInSet(Phone[I], ['0'..'9']) then
      begin
        Result := False;
        Break;
      end;
    end;
  end;
end;

end.

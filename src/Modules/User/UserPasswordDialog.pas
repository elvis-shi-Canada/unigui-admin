unit UserPasswordDialog;

interface

uses
  System.SysUtils, System.Classes, System.Math,
  uniGUIBaseClasses, uniGUIClasses, uniEdit, uniButton, uniLabel, uniPanel, uniProgressBar,
  UniContext, Vcl.Forms, Vcl.Graphics, Vcl.Dialogs, Vcl.Controls, uniGUIForm, UserService.Intf;

type
  /// <summary>
  /// 密码修改对话框 - 支持管理员重置和用户修改
  /// </summary>
  TUserPasswordDialog = class(TUniForm)
    pnlMain: TUniPanel;
    lblUser: TUniLabel;
    lblUserName: TUniLabel;
    lblOldPassword: TUniLabel;
    edtOldPassword: TUniEdit;
    lblNewPassword: TUniLabel;
    edtNewPassword: TUniEdit;
    lblConfirmPassword: TUniLabel;
    edtConfirmPassword: TUniEdit;
    lblStrength: TUniLabel;
    pbStrength: TUniProgressBar;
    pnlBottom: TUniPanel;
    btnOK: TUniButton;
    btnCancel: TUniButton;
    
    procedure edtNewPasswordChange(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FUserID: Integer;
    FUserName: string;
    FIsAdmin: Boolean;
    FContext: IExecutionContext;
    
    procedure UpdatePasswordStrength;
    function CalculatePasswordStrength(const Password: string): Integer;
    procedure ValidateInputs;
    procedure InitForm;
  public
    constructor Create(AOwner: TComponent); override;
    
    procedure SetContext(const Context: IExecutionContext);
    procedure SetAsAdminMode(UserID: Integer; const UserName: string);
    procedure SetAsUserMode(UserID: Integer; const UserName: string);
  end;

implementation

{$R *.dfm}

uses
  UserService, UniAdminFormStyler;

constructor TUserPasswordDialog.Create(AOwner: TComponent);
begin
  inherited;
  FUserID := 0;
  FUserName := '';
  FIsAdmin := False;
end;

procedure TUserPasswordDialog.SetContext(const Context: IExecutionContext);
begin
  FContext := Context;
end;

procedure TUserPasswordDialog.SetAsAdminMode(UserID: Integer; const UserName: string);
begin
  FIsAdmin := True;
  FUserID := UserID;
  FUserName := UserName;
  
  Caption := '重置用户密码 - ' + UserName;
  lblUserName.Caption := UserName;
  
  // 管理员模式不需要旧密码
  lblOldPassword.Visible := False;
  edtOldPassword.Visible := False;
end;

procedure TUserPasswordDialog.SetAsUserMode(UserID: Integer; const UserName: string);
begin
  FIsAdmin := False;
  FUserID := UserID;
  FUserName := UserName;
  
  Caption := '修改密码';
  lblUserName.Caption := UserName;
  
  // 用户模式需要验证旧密码
  lblOldPassword.Visible := True;
  edtOldPassword.Visible := True;
end;

procedure TUserPasswordDialog.FormCreate(Sender: TObject);
begin
  TUniAdminFormStyler.AutoStylePanels(Self);
  TUniAdminFormStyler.AutoStyleButtons(Self);
  InitForm;
end;

procedure TUserPasswordDialog.InitForm;
begin
  // 初始化密码强度条
  pbStrength.Max := 100;
  pbStrength.Position := 0;
  pbStrength.Color := $00C0C0C0;
  lblStrength.Caption := '强度: 未评级';
  
  edtOldPassword.Text := '';
  edtNewPassword.Text := '';
  edtConfirmPassword.Text := '';
end;

procedure TUserPasswordDialog.edtNewPasswordChange(Sender: TObject);
begin
  UpdatePasswordStrength;
end;

procedure TUserPasswordDialog.UpdatePasswordStrength;
var
  LStrength: Integer;
  LColor: TColor;
  LText: string;
begin
  LStrength := CalculatePasswordStrength(edtNewPassword.Text);
  pbStrength.Position := LStrength;
  
  if LStrength < 30 then
  begin
    LColor := clRed;
    LText := '弱';
  end
  else if LStrength < 60 then
  begin
    LColor := $000080FF; // Orange
    LText := '中';
  end
  else if LStrength < 80 then
  begin
    LColor := clYellow;
    LText := '强';
  end
  else
  begin
    LColor := clLime;
    LText := '非常强';
  end;
  
  pbStrength.Color := LColor;
  lblStrength.Caption := '强度: ' + LText;
end;

function TUserPasswordDialog.CalculatePasswordStrength(const Password: string): Integer;
var
  LScore: Integer;
  LHasLower, LHasUpper, LHasDigit, LHasSpecial: Boolean;
  I: Integer;
begin
  LScore := 0;
  
  if Password = '' then
    Exit(0);
  
  // 长度评分
  LScore := LScore + Min(Length(Password) * 4, 40);
  
  // 字符类型检查
  LHasLower := False;
  LHasUpper := False;
  LHasDigit := False;
  LHasSpecial := False;
  
  for I := 1 to Length(Password) do
  begin
    if CharInSet(Password[I], ['a'..'z']) then
      LHasLower := True
    else if CharInSet(Password[I], ['A'..'Z']) then
      LHasUpper := True
    else if CharInSet(Password[I], ['0'..'9']) then
      LHasDigit := True
    else
      LHasSpecial := True;
  end;
  
  // 字符多样性评分
  if LHasLower then
    LScore := LScore + 10;
  if LHasUpper then
    LScore := LScore + 10;
  if LHasDigit then
    LScore := LScore + 15;
  if LHasSpecial then
    LScore := LScore + 15;
  
  // 奖励分
  if LHasLower and LHasUpper and LHasDigit and LHasSpecial then
    LScore := LScore + 10;
  
  Result := Min(LScore, 100);
end;

procedure TUserPasswordDialog.ValidateInputs;
var
  LOldPassword, LNewPassword, LConfirmPassword: string;
  LService: IUserService;
begin
  LOldPassword := Trim(edtOldPassword.Text);
  LNewPassword := Trim(edtNewPassword.Text);
  LConfirmPassword := Trim(edtConfirmPassword.Text);
  
  // 用户模式需要验证旧密码
  if not FIsAdmin then
  begin
    if LOldPassword = '' then
      raise Exception.Create('请输入旧密码');
  end;
  
  // 新密码验证
  if LNewPassword = '' then
    raise Exception.Create('请输入新密码');
    
  if Length(LNewPassword) < 8 then
    raise Exception.Create('新密码长度不能少于 8 位');
  
  // 确认密码验证
  if LConfirmPassword = '' then
    raise Exception.Create('请确认新密码');
    
  if LNewPassword <> LConfirmPassword then
    raise Exception.Create('两次输入的密码不一致');
  
  // 用户模式下验证旧密码
  if not FIsAdmin then
  begin
    LService := TUserService.Create(FContext);
    if not LService.VerifyPassword(FUserName, LOldPassword) then
      raise Exception.Create('旧密码不正确');
  end;
end;

procedure TUserPasswordDialog.btnOKClick(Sender: TObject);
var
  LNewPassword: string;
  LService: IUserService;
begin
  try
    // 验证输入
    ValidateInputs;
    
    LNewPassword := Trim(edtNewPassword.Text);
    LService := TUserService.Create(FContext);
    
    // 执行密码修改
    if FIsAdmin then
    begin
      LService.ResetPassword(FUserID, LNewPassword);
      ShowMessage('密码重置成功');
    end
    else
    begin
      LService.ChangePassword(FUserID, Trim(edtOldPassword.Text), LNewPassword);
      ShowMessage('密码修改成功');
    end;
    
    ModalResult := mrOK;
  except
    on E: Exception do
    begin
      ShowMessage('操作失败: ' + E.Message);
    end;
  end;
end;

procedure TUserPasswordDialog.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

initialization
  // Register for FindClass-driven MDI routing (UniAdmin_Menus.RoutePath)
  RegisterClass(TUserPasswordDialog);

end.

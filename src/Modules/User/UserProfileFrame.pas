unit UserProfileFrame;

interface

uses
  System.SysUtils, System.Classes, System.UITypes,
  uniGUIBaseClasses, uniGUIClasses, uniEdit, uniButton, uniLabel, uniPanel, uniImage,
  UniContext, uniGUIForm, uniGUIFrame, Vcl.Dialogs,
  UserService.Intf, Vcl.Controls, Vcl.Forms;

type
  /// <summary>
  /// 用户个人资料页面 - 查看和编辑个人信息
  /// </summary>
  TUserProfileFrame = class(TUniFrame)
    pnlMain: TUniPanel;
    pnlAvatar: TUniPanel;
    imgAvatar: TUniImage;
    btnChangeAvatar: TUniButton;
    pnlInfo: TUniPanel;
    lblUserName: TUniLabel;
    edtUserName: TUniEdit;
    lblRealName: TUniLabel;
    edtRealName: TUniEdit;
    lblEmail: TUniLabel;
    edtEmail: TUniEdit;
    lblPhone: TUniLabel;
    edtPhone: TUniEdit;
    lblLastLogin: TUniLabel;
    edtLastLogin: TUniLabel;
    lblLastLoginIP: TUniLabel;
    edtLastLoginIP: TUniLabel;
    pnlBottom: TUniPanel;
    btnChangePassword: TUniButton;
    btnSave: TUniButton;
    
    procedure btnSaveClick(Sender: TObject);
    procedure btnChangePasswordClick(Sender: TObject);
    procedure btnChangeAvatarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FUserID: Integer;
    FContext: IExecutionContext;
    
    procedure ValidateInputs;
    procedure InitForm;
  public
    constructor Create(AOwner: TComponent); override;
    
    procedure SetContext(const Context: IExecutionContext);
    procedure LoadUser(UserID: Integer);
  end;

implementation

{$R *.dfm}

uses
  UserService, UserPasswordDialog, uniGUIApplication;

constructor TUserProfileFrame.Create(AOwner: TComponent);
begin
  inherited;
  FUserID := 0;
end;

procedure TUserProfileFrame.SetContext(const Context: IExecutionContext);
begin
  FContext := Context;
  FUserID := Context.GetCurrentUserID;
  LoadUser(FUserID);
end;

procedure TUserProfileFrame.FormCreate(Sender: TObject);
begin
  InitForm;
end;

procedure TUserProfileFrame.InitForm;
begin
  // 用户名只读
  edtUserName.Enabled := False;
  
  // 最后登录信息只读
  edtLastLogin.Height := edtUserName.Height;
  edtLastLoginIP.Height := edtUserName.Height;
  
  // 初始头像占位（Phase 4 实现）
  // imgAvatar.Picture.LoadFromFile(...)
end;

procedure TUserProfileFrame.LoadUser(UserID: Integer);
var
  LInfo: TUserInfo;
begin
  FUserID := UserID;
  
  try
    var LService := TUserService.Create(FContext);
    LInfo := LService.GetUserByID(UserID);
    
    edtUserName.Text := LInfo.UserName;
    edtRealName.Text := LInfo.RealName;
    edtEmail.Text := LInfo.Email;
    edtPhone.Text := LInfo.Phone;
    
    if LInfo.LastLoginDate <> 0 then
      edtLastLogin.Caption := FormatDateTime('yyyy-mm-dd hh:nn:ss', LInfo.LastLoginDate)
    else
      edtLastLogin.Caption := '从未登录';
      
    edtLastLoginIP.Caption := LInfo.LastLoginIP;
    if edtLastLoginIP.Caption = '' then
      edtLastLoginIP.Caption := '-';
  except
    on E: Exception do
    begin
      ShowMessage('加载用户资料失败: ' + E.Message);
    end;
  end;
end;

procedure TUserProfileFrame.ValidateInputs;
var
  LRealName, LEmail, LPhone: string;
begin
  LRealName := Trim(edtRealName.Text);
  LEmail := Trim(edtEmail.Text);
  LPhone := Trim(edtPhone.Text);
  
  // 真实姓名验证
  if LRealName = '' then
    raise Exception.Create('真实姓名不能为空');
    
  if Length(LRealName) > 100 then
    raise Exception.Create('真实姓名长度不能超过 100 位');
  
  // 邮箱验证
  if LEmail = '' then
    raise Exception.Create('邮箱不能为空');
    
  if (Pos('@', LEmail) <= 1) or (Pos('.', LEmail) <= Pos('@', LEmail) + 1) then
    raise Exception.Create('邮箱格式不正确');
  
  // 手机验证
  if (LPhone <> '') and (Length(LPhone) <> 11) then
    raise Exception.Create('手机号码必须是 11 位');
end;

procedure TUserProfileFrame.btnSaveClick(Sender: TObject);
begin
  try
    // 验证输入
    ValidateInputs;
    
    // 更新用户信息
    var LService := TUserService.Create(FContext);
    LService.UpdateUser(FUserID, 
      Trim(edtRealName.Text),
      Trim(edtEmail.Text),
      Trim(edtPhone.Text));
    
    ShowMessage('个人资料更新成功');
    
    // 重新加载数据
    LoadUser(FUserID);
  except
    on E: Exception do
    begin
      ShowMessage('更新失败: ' + E.Message);
    end;
  end;
end;

procedure TUserProfileFrame.btnChangePasswordClick(Sender: TObject);
var
  LDialog: TUserPasswordDialog;
begin
  LDialog := TUserPasswordDialog.Create(Self);
  try
    LDialog.SetContext(FContext);
    LDialog.SetAsUserMode(FUserID, edtUserName.Text);
    
    if LDialog.ShowModal = mrOK then
    begin
      ShowMessage('密码修改成功，请重新登录');
      // 关闭当前会话，要求用户重新登录
      if Assigned(FContext) then
      begin
        // 在 UniGUI 中通过结束会话触发重新登录
        UniSession.Terminate('密码已修改，请重新登录');
      end;
    end;
  finally
    LDialog.Free;
  end;
end;

procedure TUserProfileFrame.btnChangeAvatarClick(Sender: TObject);
begin
  // Phase 4 实现
  ShowMessage('头像上传功能将在 Phase 4 中实现');
end;

initialization
  // Register for FindClass-driven MDI routing (UniAdmin_Menus.RoutePath)
  RegisterClass(TUserProfileFrame);

end.

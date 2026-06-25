unit UserEditForm;

interface

uses
  System.SysUtils, System.Classes, System.Variants,
  uniGUIBaseClasses, uniGUIClasses, uniGUImClasses, uniEdit, uniButton, uniLabel, uniMultiItem, uniComboBox, uniPanel, uniGUIForm,
  UniContext, UniPlugin.Types, UserService.Intf, Vcl.Dialogs, Vcl.Controls, Vcl.Forms,
  uniMemo, uniCheckBox;

type
  /// <summary>
  /// 用户编辑窗体 - 新增和编辑用户
  /// </summary>
  TUserEditForm = class(TUniForm)
    pnlMain: TUniPanel;
    lblUserName: TUniLabel;
    edtUserName: TUniEdit;
    lblRealName: TUniLabel;
    edtRealName: TUniEdit;
    lblEmail: TUniLabel;
    edtEmail: TUniEdit;
    lblPhone: TUniLabel;
    edtPhone: TUniEdit;
    lblPassword: TUniLabel;
    edtPassword: TUniEdit;
    lblConfirmPassword: TUniLabel;
    edtConfirmPassword: TUniEdit;
    lblRole: TUniLabel;
    cmbRole: TUniComboBox;
    lblStatus: TUniLabel;
    chkStatus: TUniCheckBox;
    lblRemark: TUniLabel;
    memRemark: TUniMemo;
    pnlBottom: TUniPanel;
    btnSave: TUniButton;
    btnCancel: TUniButton;
    
    procedure btnSaveClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FUserID: Integer;
    FMode: string; // 'add' 或 'edit'
    FContext: IExecutionContext;
    
    procedure ValidateInputs;
    procedure InitForm;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    
    procedure SetContext(const Context: IExecutionContext);
    procedure LoadUser(UserID: Integer);
    procedure SetAsAddMode;
    procedure SetAsEditMode(UserID: Integer);
  end;

implementation

{$R *.dfm}

uses
  UserService, UniFormStyler;

var
  UserService: IUniUserService;

constructor TUserEditForm.Create(AOwner: TComponent);
begin
  inherited;
  FUserID := 0;
  FMode := 'add';
end;

destructor TUserEditForm.Destroy;
begin
  inherited;
end;

procedure TUserEditForm.SetContext(const Context: IExecutionContext);
begin
  FContext := Context;
  UserService := TUniUserService.Create(Context);
end;

procedure TUserEditForm.FormCreate(Sender: TObject);
begin
  TUniFormStyler.AutoStylePanels(Self);
  TUniFormStyler.AutoStyleButtons(Self);
  InitForm;
end;

procedure TUserEditForm.InitForm;
begin
  // 初始化状态复选框
  chkStatus.Checked := True;

  // 设置默认模式
  SetAsAddMode;
end;

procedure TUserEditForm.SetAsAddMode;
begin
  FMode := 'add';
  FUserID := 0;
  
  Caption := '新增用户';
  edtUserName.Enabled := True;
  edtUserName.Text := '';
  edtRealName.Text := '';
  edtEmail.Text := '';
  edtPhone.Text := '';
  edtPassword.Text := '';
  edtPassword.Visible := True;
  edtConfirmPassword.Visible := True;
  lblPassword.Visible := True;
  lblConfirmPassword.Visible := True;
  chkStatus.Checked := True;
end;

procedure TUserEditForm.SetAsEditMode(UserID: Integer);
begin
  FMode := 'edit';
  FUserID := UserID;
  
  Caption := '编辑用户';
  
  // 加载用户数据
  LoadUser(UserID);
  
  // 编辑模式下不需要密码
  edtPassword.Visible := False;
  edtConfirmPassword.Visible := False;
  lblPassword.Visible := False;
  lblConfirmPassword.Visible := False;
end;

procedure TUserEditForm.LoadUser(UserID: Integer);
var
  LInfo: TUserInfo;
begin
  try
    LInfo := UserService.GetUserByID(UserID);
    
    edtUserName.Text := LInfo.UserName;
    edtUserName.Enabled := False; // 用户名不允许修改
    edtRealName.Text := LInfo.RealName;
    edtEmail.Text := LInfo.Email;
    edtPhone.Text := LInfo.Phone;
    
    chkStatus.Checked := LInfo.Status = 1;
  except
    on E: Exception do
    begin
      ShowMessage('加载用户数据失败: ' + E.Message);
      ModalResult := mrCancel;
    end;
  end;
end;

procedure TUserEditForm.ValidateInputs;
var
  LUserName, LRealName, LEmail, LPhone, LPassword, LConfirmPassword: string;
begin
  LUserName := Trim(edtUserName.Text);
  LRealName := Trim(edtRealName.Text);
  LEmail := Trim(edtEmail.Text);
  LPhone := Trim(edtPhone.Text);
  LPassword := Trim(edtPassword.Text);
  LConfirmPassword := Trim(edtConfirmPassword.Text);
  
  // 用户名验证
  if LUserName = '' then
    raise Exception.Create('用户名不能为空');
    
  if Length(LUserName) < 3 then
    raise Exception.Create('用户名长度不能少于 3 位');
    
  if Length(LUserName) > 50 then
    raise Exception.Create('用户名长度不能超过 50 位');
  
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
  
  // 密码验证（仅新增模式）
  if FMode = 'add' then
  begin
    if LPassword = '' then
      raise Exception.Create('密码不能为空');
      
    if Length(LPassword) < 8 then
      raise Exception.Create('密码长度不能少于 8 位');
      
    if LPassword <> LConfirmPassword then
      raise Exception.Create('两次输入的密码不一致');
  end;
  
  // 用户名唯一性检查
  if (FMode = 'add') and UserService.UserNameExists(LUserName) then
    raise Exception.Create('用户名已存在');
    
  // 邮箱唯一性检查
  if UserService.EmailExists(LEmail) then
  begin
    if FMode = 'add' then
      raise Exception.Create('邮箱已被使用')
    else
    begin
      var LInfo := UserService.GetUserByID(FUserID);
      if LInfo.Email <> LEmail then
        raise Exception.Create('邮箱已被使用');
    end;
  end;
end;

procedure TUserEditForm.btnSaveClick(Sender: TObject);
var
  LUserName, LRealName, LEmail, LPhone, LPassword: string;
  LStatus: Integer;
begin
  try
    // 验证输入
    ValidateInputs;
    
    // 获取输入值
    LUserName := Trim(edtUserName.Text);
    LRealName := Trim(edtRealName.Text);
    LEmail := Trim(edtEmail.Text);
    LPhone := Trim(edtPhone.Text);
    LPassword := Trim(edtPassword.Text);
    
    if chkStatus.Checked then
      LStatus := 1
    else
      LStatus := 0;
    
    // 执行操作
    if FMode = 'add' then
    begin
      UserService.CreateUser(LUserName, LPassword, LRealName, LEmail, LPhone);
      ShowMessage('用户创建成功');
    end
    else
    begin
      UserService.UpdateUser(FUserID, LRealName, LEmail, LPhone);
      ShowMessage('用户更新成功');
    end;
    
    ModalResult := mrOK;
  except
    on E: Exception do
    begin
      ShowMessage('操作失败: ' + E.Message);
    end;
  end;
end;

procedure TUserEditForm.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.

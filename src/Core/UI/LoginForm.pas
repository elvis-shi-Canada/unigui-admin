unit LoginForm;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.UITypes,
  uniGUIApplication, uniGUIForm, uniLabel, uniEdit,
  uniButton, uniCheckBox, uniPanel, uniGUIBaseClasses, uniGUIClasses,
  UniAuthService.Intf, Vcl.Controls, Vcl.Forms;

type
  /// <summary>
  /// 登录窗体 - 提供用户认证界面
  /// 集成 IUniAuthService 实现登录功能
  /// </summary>
  TLoginForm = class(TUniLoginForm)
    UniContainerPanel: TUniContainerPanel;
    UniPanel: TUniPanel;
    LblTitle: TUniLabel;
    LblSubtitle: TUniLabel;
    LblUserName: TUniLabel;
    LblPassword: TUniLabel;
    EdtUserName: TUniEdit;
    EdtPassword: TUniEdit;
    ChkRememberMe: TUniCheckBox;
    BtnLogin: TUniButton;
    BtnCancel: TUniButton;
    LblCopyright: TUniLabel;
    procedure BtnLoginClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure UniFormAfterShow(Sender: TObject);
  private
    FAuthService: IUniAuthService;
    FLoginResult: TLoginResult;
    class var FLastLoginResult: TLoginResult;
    procedure SetLoginResult(const Value: TLoginResult);
    function ValidateInput: Boolean;
    /// <summary>Apply modern CSS classes to components for custom styling</summary>
    procedure ApplyStyling;
  public
    /// <summary>最近一次登录结果（供 MainFrame 创建执行上下文）</summary>
    class property LastLoginResult: TLoginResult read FLastLoginResult;
    /// <summary>
    /// 静态方法 - 显示登录窗体并执行登录
    /// </summary>
    /// <param name="LoginResult">返回登录结果</param>
    /// <returns>登录是否成功</returns>
    class function Execute(var LoginResult: TLoginResult): Boolean; static;

    property LoginResult: TLoginResult read FLoginResult write SetLoginResult;
  end;

implementation

{$R *.dfm}

uses
  UniServices, uniGUIVars;

{ TLoginForm }

procedure TLoginForm.FormCreate(Sender: TObject);
begin
  // 从服务定位器获取认证服务
  try
    FAuthService := TUniServices.AuthService;
  except
    on E: Exception do
    begin
      ShowMessage('无法初始化认证服务: ' + E.Message);
      ModalResult := mrCancel;
    end;
  end;

  // 设置默认值
  EdtUserName.Text := '';
  EdtPassword.Text := '';
  ChkRememberMe.Checked := False;

  FLoginResult.Success := False;
  FLoginResult.Message := '';

  // 样式应用移至 UniFormAfterShow（确保客户端组件已完全初始化）
end;

procedure TLoginForm.ApplyStyling;
begin
  // 背景面板 - 渐变背景
  UniContainerPanel.JSInterface.JSAssign('addCls', ['login-form-bg']);
  // 登录卡片 - 白底 + 圆角 + 阴影
  UniPanel.JSInterface.JSAssign('addCls', ['login-card']);
  // 标题 + 副标题
  LblTitle.JSInterface.JSAssign('addCls', ['login-title']);
  LblSubtitle.JSInterface.JSAssign('addCls', ['login-subtitle']);
  // 输入框 - 圆角 + 聚焦高亮
  EdtUserName.JSInterface.JSAssign('addCls', ['login-input']);
  EdtPassword.JSInterface.JSAssign('addCls', ['login-input']);
  // 按钮 - 渐变主按钮 + 幽灵次按钮
  BtnLogin.JSInterface.JSAssign('addCls', ['login-btn-primary']);
  BtnCancel.JSInterface.JSAssign('addCls', ['login-btn-secondary']);
  // 页脚版权
  LblCopyright.JSInterface.JSAssign('addCls', ['login-footer']);
end;

procedure TLoginForm.UniFormAfterShow(Sender: TObject);
begin
  // 窗体显示后应用样式（此时客户端组件已完全初始化）
  ApplyStyling;
  // 设置焦点到用户名输入框
  EdtUserName.SetFocus;
end;

function TLoginForm.ValidateInput: Boolean;
begin
  Result := False;

  if Trim(EdtUserName.Text) = '' then
  begin
    ShowMessage('请输入用户名');
    EdtUserName.SetFocus;
    Exit;
  end;

  if Trim(EdtPassword.Text) = '' then
  begin
    ShowMessage('请输入密码');
    EdtPassword.SetFocus;
    Exit;
  end;

  Result := True;
end;

procedure TLoginForm.BtnLoginClick(Sender: TObject);
begin
  if not ValidateInput then
    Exit;

  try
    // Screen.Cursor := crHourGlass;  // UniGUI 不支持 VCL Screen 对象
    try
      // 调用认证服务进行登录
      FLoginResult := FAuthService.Login(
        Trim(EdtUserName.Text),
        Trim(EdtPassword.Text)
      );

      if FLoginResult.Success then
      begin
        // 保存登录结果供 MainFrame 创建执行上下文
        FLastLoginResult := FLoginResult;
        ModalResult := mrOk;
        // 登录成功，可以选择显示欢迎消息
        // ShowMessage('登录成功！欢迎, ' + FLoginResult.RealName);
      end
      else
      begin
        ShowMessage('登录失败：' + FLoginResult.Message);
        EdtPassword.Text := '';
        EdtPassword.SetFocus;
      end;
    finally
      // Screen.Cursor := crDefault;  // UniGUI 不支持 VCL Screen 对象
    end;
  except
    on E: Exception do
    begin
      ShowMessage('登录过程中发生错误：' + E.Message);
      EdtPassword.SetFocus;
    end;
  end;
end;

procedure TLoginForm.BtnCancelClick(Sender: TObject);
begin
  FLoginResult.Success := False;
  FLoginResult.Message := '用户取消登录';
  ModalResult := mrCancel;
end;

procedure TLoginForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then // Enter key
  begin
    Key := #0; // 阻止默认处理
    BtnLoginClick(nil);
  end
  else if Key = #27 then // ESC key
  begin
    Key := #0; // 阻止默认处理
    BtnCancelClick(nil);
  end;
end;

procedure TLoginForm.SetLoginResult(const Value: TLoginResult);
begin
  FLoginResult := Value;
end;

class function TLoginForm.Execute(var LoginResult: TLoginResult): Boolean;
var
  LForm: TLoginForm;
begin
  LForm := TLoginForm.Create(nil);
  try
    Result := LForm.ShowModal = mrOk;
    if Result then
      LoginResult := LForm.LoginResult
    else
    begin
      LoginResult.Success := False;
      LoginResult.Message := '用户取消登录';
    end;
  finally
    LForm.Free;
  end;
end;

initialization
  // 注册为登录窗体：因继承 TUniLoginForm，IsLoginForm 类方法返回 True，
  // RegisterAppFormClass 据此将其归入 FLoginFormClass
  RegisterAppFormClass(TLoginForm);
end.

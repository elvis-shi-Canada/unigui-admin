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
  TLoginForm = class(TUniForm)
    UniContainerPanel: TUniContainerPanel;
    UniPanel: TUniPanel;
    LblTitle: TUniLabel;
    LblUserName: TUniLabel;
    LblPassword: TUniLabel;
    EdtUserName: TUniEdit;
    EdtPassword: TUniEdit;
    ChkRememberMe: TUniCheckBox;
    BtnLogin: TUniButton;
    BtnCancel: TUniButton;
    procedure BtnLoginClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure UniFormAfterShow(Sender: TObject);
  private
    FAuthService: IUniAuthService;
    FLoginResult: TLoginResult;
    procedure SetLoginResult(const Value: TLoginResult);
    function ValidateInput: Boolean;
  public
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
  UniServices;

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

  // 设置窗体属性
  Caption := '用户登录';
  Width := 400;
  Height := 300;
  // BorderStyle := bsDialog;    // UniGUI 不支持 VCL 属性
  // Position := poScreenCenter;  // UniGUI 使用 CSS 布局

  // 设置默认值
  EdtUserName.Text := '';
  EdtPassword.Text := '';
  ChkRememberMe.Checked := False;

  FLoginResult.Success := False;
  FLoginResult.Message := '';
end;

procedure TLoginForm.UniFormAfterShow(Sender: TObject);
begin
  // 窗体显示后设置焦点到用户名输入框
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

end.

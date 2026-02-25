unit BaseFormTemplate;

interface

uses
  System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls,
  UniGUIBaseModule, UniGUIClasses, UniGUIForm, UniGUIButton,
  UniTheme;

type
  /// <summary>
  /// 基础窗体模板
  /// 提供标准的窗体布局和常用按钮
  /// </summary>
  TBaseFormTemplate = class(TUniForm)
    UniThemeManager1: TUniThemeManager;
    pnlHeader: TUniPanel;
    pnlBody: TUniPanel;
    pnlFooter: TUniPanel;
    pnlButtons: TUniPanel;
    btnSave: TUniButton;
    btnCancel: TUniButton;
    btnOK: TUniButton;
    procedure FormCreate(Sender: TObject);
    procedure UniThemeManager1ThemeChange(Sender: TObject);
  private
  protected
    procedure DoInitialize; virtual;
    procedure DoSave; virtual;
    procedure DoCancel; virtual;
  public
  end;

implementation

{$R *.dfm}

procedure TBaseFormTemplate.FormCreate(Sender: TObject);
begin
  DoInitialize;
end;

procedure TBaseFormTemplate.UniThemeManager1ThemeChange(Sender: TObject);
begin
  // 主题切换时更新界面样式
  Self.Update;
end;

procedure TBaseFormTemplate.DoInitialize;
begin
  // 子类重写此方法进行初始化
end;

procedure TBaseFormTemplate.DoSave;
begin
  // 子类重写此方法实现保存逻辑
  ModalResult := mrOk;
end;

procedure TBaseFormTemplate.DoCancel;
begin
  ModalResult := mrCancel;
end;

initialization
  RegisterClass(TBaseFormTemplate);

end.

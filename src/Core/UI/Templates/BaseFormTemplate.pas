unit BaseFormTemplate;

interface

uses
  System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms,
  UniGUIClasses, UniGUIForm, uniButton, uniPanel,
  UniAdminTheme, uniLabel, uniGUIBaseClasses;

type
  /// <summary>
  /// 基础窗体模板
  /// 提供标准的窗体布局和常用按钮
  /// </summary>
  TBaseFormTemplate = class(TUniForm)
    pnlHeader: TUniPanel;
    pnlBody: TUniPanel;
    pnlFooter: TUniPanel;
    pnlButtons: TUniPanel;
    btnCancel: TUniButton;
    btnOK: TUniButton;
    procedure FormCreate(Sender: TObject);
  private
  protected
    procedure DoInitialize; virtual;
    procedure DoSave; virtual;
    procedure DoCancel; virtual;
  public
  end;

implementation

{$R *.dfm}

uses
  UniAdminFormStyler;

procedure TBaseFormTemplate.FormCreate(Sender: TObject);
begin
  // 应用统一设计系统样式
  TUniAdminFormStyler.AutoStylePanels(Self);
  TUniAdminFormStyler.AutoStyleButtons(Self);

  DoInitialize;
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

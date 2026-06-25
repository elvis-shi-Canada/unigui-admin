unit DialogTemplate;

interface

uses
  System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms,
  UniGUIBaseClasses, UniGUIClasses, UniGUIForm, UniLabel, uniPanel, UniButton;

type
  TDialogTemplate = class(TUniForm)
    pnlContent: TUniPanel;
    lblMessage: TUniLabel;
    pnlButtons: TUniPanel;
    btnYes: TUniButton;
    btnNo: TUniButton;
    btnCancel: TUniButton;
  private
    { Private declarations }
  public
    { Public declarations }
    class function ShowDialog(const Message: string): Integer;
  end;

implementation

{$R *.dfm}

uses
  UniFormStyler;

class function TDialogTemplate.ShowDialog(const Message: string): Integer;
begin
  with TDialogTemplate.Create(nil) do
  try
    lblMessage.Caption := Message;
    // 应用统一设计系统样式
    TUniFormStyler.StyleAsCard(pnlContent);
    TUniFormStyler.StylePrimaryButton(btnYes);
    TUniFormStyler.StyleDangerButton(btnNo);
    Result := ShowModal;
  finally
    Free;
  end;
end;

end.

unit DialogTemplate;

interface

uses
  System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms,
  UniGUIBaseClasses, UniGUIClasses, UniThemeManager, UniGUIForm, UniLabel, UniPanel, UniButton;

type
  TDialogTemplate = class(TUniForm)
    pnlContent: TUniPanel;
    lblMessage: TUniLabel;
    pnlButtons: TUniPanel;
    btnYes: TUniButton;
    btnNo: TUniButton;
    btnCancel: TUniButton;
    UniThemeManager1: TUniThemeManager;
  private
    { Private declarations }
  public
    { Public declarations }
    class function ShowDialog(const Message: string): Integer;
  end;

implementation

{$R *.dfm}

class function TDialogTemplate.ShowDialog(const Message: string): Integer;
begin
  with TDialogTemplate.Create(nil) do
  try
    lblMessage.Caption := Message;
    Result := ShowModal;
  finally
    Free;
  end;
end;

end.

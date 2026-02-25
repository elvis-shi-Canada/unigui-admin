unit TabSheetTemplate;

interface

uses
  System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.ComCtrls,
  UniGUIBaseClasses, UniGUIClasses, UniPanel, UniLabel, UniMemo, UniStringGrid,
  UniPageControl, UniTabSheet, UniGroupBox, UniCheckBox;

type
  TTabSheetTemplate = class(TUniPanel)
    UniPageControl1: TUniPageControl;
    tabSheet1: TUniTabSheet;
    lblTab1Title: TUniLabel;
    memoTab1: TUniMemo;
    tabSheet2: TUniTabSheet;
    lblTab2Title: TUniLabel;
    grdTab2: TUniStringGrid;
    tabSheet3: TUniTabSheet;
    lblTab3Title: TUniLabel;
    grpTab3: TUniGroupBox;
    chkTab3Option1: TUniCheckBox;
    chkTab3Option2: TUniCheckBox;
    chkTab3Option3: TUniCheckBox;
  private
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.dfm}

constructor TTabSheetTemplate.Create(AOwner: TComponent);
begin
  inherited;
  UniPageControl1.ActivePageIndex := 0;
end;

end.

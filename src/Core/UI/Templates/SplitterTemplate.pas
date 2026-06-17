unit SplitterTemplate;

interface

uses
  System.SysUtils, System.Classes,
  Vcl.Controls,
  UniGUIBaseClasses, UniGUIClasses, uniGUIFrame, uniPanel, UniLabel, UniTreeView, UniMemo, UniSplitter;

type
  TSplitterTemplate = class(TUniFrame)
    pnlLeft: TUniPanel;
    lblLeftTitle: TUniLabel;
    treeLeft: TUniTreeView;
    splitterVertical: TUniSplitter;
    pnlRight: TUniPanel;
    lblRightTitle: TUniLabel;
    memoRight: TUniMemo;
  private
    { Private declarations }
    FSplitterPos: Integer;
    procedure SetSplitterPos(const Value: Integer);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    property SplitterPos: Integer read FSplitterPos write SetSplitterPos;
  end;

implementation

{$R *.dfm}

constructor TSplitterTemplate.Create(AOwner: TComponent);
begin
  inherited;
  FSplitterPos := 250;
end;

procedure TSplitterTemplate.SetSplitterPos(const Value: Integer);
begin
  FSplitterPos := Value;
  pnlLeft.Width := Value;
end;

end.

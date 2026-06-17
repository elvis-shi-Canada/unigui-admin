unit QueryPanelTemplate;

interface

uses
  System.SysUtils, System.Classes,
  Vcl.Controls,
  UniGUIBaseClasses, UniGUIClasses, uniGUIFrame, uniPanel, UniLabel, UniEdit,
  UniDateTimePicker, UniComboBox, UniButton, UniGroupBox, uniMultiItem,
  Vcl.Forms;

type
  TQueryPanelTemplate = class(TUniFrame)
    grpQuery: TUniGroupBox;
    lblKeyword: TUniLabel;
    edtKeyword: TUniEdit;
    lblDateFrom: TUniLabel;
    dtpDateFrom: TUniDateTimePicker;
    lblDateTo: TUniLabel;
    dtpDateTo: TUniDateTimePicker;
    lblStatus: TUniLabel;
    cboStatus: TUniComboBox;
    btnQuery: TUniButton;
    btnReset: TUniButton;
    btnAdvanced: TUniButton;
  private
    { Private declarations }
    FOnQuery: TNotifyEvent;
    FOnReset: TNotifyEvent;
    FOnAdvanced: TNotifyEvent;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    function GetQueryParams: string;
    procedure SetQueryParams(const Params: string);
    procedure ClearQuery;
    property OnQuery: TNotifyEvent read FOnQuery write FOnQuery;
    property OnReset: TNotifyEvent read FOnReset write FOnReset;
    property OnAdvanced: TNotifyEvent read FOnAdvanced write FOnAdvanced;
  end;

implementation

{$R *.dfm}

constructor TQueryPanelTemplate.Create(AOwner: TComponent);
begin
  inherited;
  cboStatus.ItemIndex := 0; // 默认选择"全部"
end;

function TQueryPanelTemplate.GetQueryParams: string;
var
  Params: TStringList;
begin
  Params := TStringList.Create;
  try
    if Trim(edtKeyword.Text) <> '' then
      Params.Values['Keyword'] := edtKeyword.Text;

    if dtpDateFrom.DateTime > 0 then
      Params.Values['DateFrom'] := DateTimeToStr(dtpDateFrom.DateTime);

    if dtpDateTo.DateTime > 0 then
      Params.Values['DateTo'] := DateTimeToStr(dtpDateTo.DateTime);

    if (cboStatus.ItemIndex > 0) then
      Params.Values['Status'] := IntToStr(cboStatus.ItemIndex);

    Result := Params.Text;
  finally
    Params.Free;
  end;
end;

procedure TQueryPanelTemplate.SetQueryParams(const Params: string);
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    SL.Text := Params;

    if SL.Values['Keyword'] <> '' then
      edtKeyword.Text := SL.Values['Keyword'];

    if SL.Values['DateFrom'] <> '' then
      dtpDateFrom.DateTime := StrToDateTime(SL.Values['DateFrom']);

    if SL.Values['DateTo'] <> '' then
      dtpDateTo.DateTime := StrToDateTime(SL.Values['DateTo']);

    if SL.Values['Status'] <> '' then
      cboStatus.ItemIndex := StrToInt(SL.Values['Status']);
  finally
    SL.Free;
  end;
end;

procedure TQueryPanelTemplate.ClearQuery;
begin
  edtKeyword.Text := '';
  dtpDateFrom.DateTime := 0;
  dtpDateTo.DateTime := 0;
  cboStatus.ItemIndex := 0;
end;

end.

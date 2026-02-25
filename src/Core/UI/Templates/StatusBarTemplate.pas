unit StatusBarTemplate;

interface

uses
  System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.ComCtrls;

type
  TStatusBarTemplate = class(TStatusBar)
  private
    { Private declarations }
    function GetStatusText: string;
    procedure SetStatusText(const Value: string);
    function GetRecordCount: string;
    procedure SetRecordCount(const Value: string);
    function GetUserInfo: string;
    procedure SetUserInfo(const Value: string);
    function GetDateTime: string;
    procedure SetDateTime(const Value: string);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;

    // 状态信息
    property StatusText: string read GetStatusText write SetStatusText;

    // 记录数量
    property RecordCount: string read GetRecordCount write SetRecordCount;

    // 用户信息
    property UserInfo: string read GetUserInfo write SetUserInfo;

    // 日期时间
    property DateTimeStr: string read GetDateTime write SetDateTime;

    procedure UpdateStatus(const AStatus, ARecords, AUser, ADateTime: string);
  end;

implementation

constructor TStatusBarTemplate.Create(AOwner: TComponent);
begin
  inherited;
  SimplePanel := False;
  UpdateStatus('就绪', '0 条记录', '当前用户: ', FormatDateTime('yyyy-mm-dd hh:nn:ss', Now));
end;

function TStatusBarTemplate.GetStatusText: string;
begin
  Result := Panels[0].Text;
end;

procedure TStatusBarTemplate.SetStatusText(const Value: string);
begin
  Panels[0].Text := Value;
end;

function TStatusBarTemplate.GetRecordCount: string;
begin
  Result := Panels[1].Text;
end;

procedure TStatusBarTemplate.SetRecordCount(const Value: string);
begin
  Panels[1].Text := Value;
end;

function TStatusBarTemplate.GetUserInfo: string;
begin
  Result := Panels[2].Text;
end;

procedure TStatusBarTemplate.SetUserInfo(const Value: string);
begin
  Panels[2].Text := Value;
end;

function TStatusBarTemplate.GetDateTime: string;
begin
  Result := Panels[3].Text;
end;

procedure TStatusBarTemplate.SetDateTime(const Value: string);
begin
  Panels[3].Text := Value;
end;

procedure TStatusBarTemplate.UpdateStatus(const AStatus, ARecords, AUser, ADateTime: string);
begin
  StatusText := AStatus;
  RecordCount := ARecords;
  UserInfo := AUser;
  DateTimeStr := ADateTime;
end;

end.

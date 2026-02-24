unit LoginLogFrame;

interface

uses
  System.SysUtils, System.Classes, System.Variants,
  Data.DB, FireDAC.Comp.Client,
  uniGUIControls, uniGUIBaseClasses, uniGUIClasses, uniGUImClasses, uniEdit, uniButton,
  uniGrid, uniToolBar, uniLabel, uniComboBox, uniPanel, uniDateTimePicker,
  UniContext, UniPlugin.Types, BaseCrudFrame, LogDataModule;

type
  /// <summary>
  /// 登录日志查询窗体
  /// </summary>
  TLoginLogFrame = class(TBaseCrudFrame)
    UniPanelFilter: TUniPanel;
    UniLabelUserName: TUniLabel;
    UniEditUserName: TUniEdit;
    UniLabelIP: TUniLabel;
    UniEditIP: TUniEdit;
    UniLabelStartTime: TUniLabel;
    UniDateTimePickerStart: TUniDateTimePicker;
    UniLabelEndTime: TUniLabel;
    UniDateTimePickerEnd: TUniDateTimePicker;
    UniLabelStatus: TUniLabel;
    UniComboBoxStatus: TUniComboBox;
    UniButtonSearch: TUniButton;
    UniButtonExport: TUniButton;
    UniDBGrid: TUniDBGrid;
    UniDataSource: TDataSource;
    qryLoginLogs: TFDQuery;

    procedure UniButtonSearchClick(Sender: TObject);
    procedure UniButtonExportClick(Sender: TObject);
  protected
    procedure DoInitialize; override;
    procedure DoRefresh; override;
  public
    procedure Initialize; override;
  end;

implementation

{$R *.dfm}

{ TLoginLogFrame }

procedure TLoginLogFrame.DoInitialize;
begin
  inherited;
  FPermissionPrefix := 'log_login';

  // 初始化状态下拉框
  UniComboBoxStatus.Items.Clear;
  UniComboBoxStatus.Items.Add('全部');
  UniComboBoxStatus.Items.Add('成功');
  UniComboBoxStatus.Items.Add('失败');
  UniComboBoxStatus.ItemIndex := 0;
end;

procedure TLoginLogFrame.DoRefresh;
var
  LUserName, LIP: string;
  LStartTime, LEndTime: TDateTime;
  LStatus: Integer;
  LDataModule: TLogDataModule;
  LDataSet: TDataSet;
begin
  LUserName := Trim(UniEditUserName.Text);
  LIP := Trim(UniEditIP.Text);
  LStartTime := UniDateTimePickerStart.DateTime;
  LEndTime := UniDateTimePickerEnd.DateTime;
  LStatus := -1;

  case UniComboBoxStatus.ItemIndex of
    1: LStatus := 1; // 成功
    2: LStatus := 0; // 失败
  end;

  LDataModule := TLogDataModule.Create(nil);
  try
    if Supports(LDataModule, IContextAware) then
      (LDataModule as IContextAware).SetContext(FContext);

    LDataSet := LDataModule.GetLoginLogs(LUserName, LIP, LStartTime, LEndTime, LStatus, 1, 100);
    try
      qryLoginLogs.Close;
      // TODO: 复制数据到 qryLoginLogs
      qryLoginLogs.Open;
    finally
      LDataSet.Free;
    end;
  finally
    LDataModule.Free;
  end;
end;

procedure TLoginLogFrame.Initialize;
begin
  inherited;
  // 设置默认时间范围为最近7天
  UniDateTimePickerStart.DateTime := Now - 7;
  UniDateTimePickerEnd.DateTime := Now;
  Refresh;
end;

procedure TLoginLogFrame.UniButtonSearchClick(Sender: TObject);
begin
  Refresh;
end;

procedure TLoginLogFrame.UniButtonExportClick(Sender: TObject);
begin
  // 导出登录日志
  ShowMessage('导出功能待实现');
end;

end.

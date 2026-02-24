unit OperationLogFrame;

interface

uses
  System.SysUtils, System.Classes, System.Variants,
  Data.DB, FireDAC.Comp.Client,
  uniGUIControls, uniGUIBaseClasses, uniGUIClasses, uniGUImClasses, uniEdit, uniButton,
  uniGrid, uniToolBar, uniLabel, uniComboBox, uniPanel, uniDateTimePicker,
  UniContext, UniPlugin.Types, BaseCrudFrame, LogDataModule;

type
  /// <summary>
  /// 操作日志查询窗体
  /// </summary>
  TOperationLogFrame = class(TBaseCrudFrame)
    UniPanelFilter: TUniPanel;
    UniLabelUserName: TUniLabel;
    UniEditUserName: TUniEdit;
    UniLabelModule: TUniLabel;
    UniEditModule: TUniEdit;
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
    qryOperationLogs: TFDQuery;

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

{ TOperationLogFrame }

procedure TOperationLogFrame.DoInitialize;
begin
  inherited;
  FPermissionPrefix := 'log_operation';

  // 初始化状态下拉框
  UniComboBoxStatus.Items.Clear;
  UniComboBoxStatus.Items.Add('全部');
  UniComboBoxStatus.Items.Add('成功');
  UniComboBoxStatus.Items.Add('失败');
  UniComboBoxStatus.ItemIndex := 0;
end;

procedure TOperationLogFrame.DoRefresh;
var
  LUserName, LModule: string;
  LStartTime, LEndTime: TDateTime;
  LStatus: Integer;
  LDataModule: TLogDataModule;
  LDataSet: TDataSet;
begin
  LUserName := Trim(UniEditUserName.Text);
  LModule := Trim(UniEditModule.Text);
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

    LDataSet := LDataModule.GetOperationLogs(LUserName, LModule, LStartTime, LEndTime, LStatus, 1, 100);
    try
      qryOperationLogs.Close;
      // TODO: 复制数据到 qryOperationLogs
      qryOperationLogs.Open;
    finally
      LDataSet.Free;
    end;
  finally
    LDataModule.Free;
  end;
end;

procedure TOperationLogFrame.Initialize;
begin
  inherited;
  // 设置默认时间范围为最近7天
  UniDateTimePickerStart.DateTime := Now - 7;
  UniDateTimePickerEnd.DateTime := Now;
  Refresh;
end;

procedure TOperationLogFrame.UniButtonSearchClick(Sender: TObject);
begin
  Refresh;
end;

procedure TOperationLogFrame.UniButtonExportClick(Sender: TObject);
begin
  // 导出操作日志
  ShowMessage('导出功能待实现');
end;

end.

unit DataChangeLogFrame;

interface

uses
  System.SysUtils, System.Classes, System.Variants,
  Data.DB, FireDAC.Comp.Client,
  uniGUIControls, uniGUIBaseClasses, uniGUIClasses, uniGUImClasses, uniEdit, uniButton,
  uniGrid, uniToolBar, uniLabel, uniComboBox, uniPanel, uniDateTimePicker,
  UniContext, UniPlugin.Types, BaseCrudFrame, LogDataModule;

type
  /// <summary>
  /// 数据变更日志查询窗体
  /// </summary>
  TDataChangeLogFrame = class(TBaseCrudFrame)
    UniPanelFilter: TUniPanel;
    UniLabelUserName: TUniLabel;
    UniEditUserName: TUniEdit;
    UniLabelTableName: TUniLabel;
    UniEditTableName: TUniEdit;
    UniLabelStartTime: TUniLabel;
    UniDateTimePickerStart: TUniDateTimePicker;
    UniLabelEndTime: TUniLabel;
    UniDateTimePickerEnd: TUniDateTimePicker;
    UniButtonSearch: TUniButton;
    UniButtonExport: TUniButton;
    UniDBGrid: TUniDBGrid;
    UniDataSource: TDataSource;
    qryDataChangeLogs: TFDQuery;

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

{ TDataChangeLogFrame }

procedure TDataChangeLogFrame.DoInitialize;
begin
  inherited;
  FPermissionPrefix := 'log_datachange';
end;

procedure TDataChangeLogFrame.DoRefresh;
var
  LUserName, LTableName: string;
  LStartTime, LEndTime: TDateTime;
  LDataModule: TLogDataModule;
  LDataSet: TDataSet;
begin
  LUserName := Trim(UniEditUserName.Text);
  LTableName := Trim(UniEditTableName.Text);
  LStartTime := UniDateTimePickerStart.DateTime;
  LEndTime := UniDateTimePickerEnd.DateTime;

  LDataModule := TLogDataModule.Create(nil);
  try
    if Supports(LDataModule, IContextAware) then
      (LDataModule as IContextAware).SetContext(FContext);

    LDataSet := LDataModule.GetDataChangeLogs(LUserName, LTableName, LStartTime, LEndTime, 1, 100);
    try
      qryDataChangeLogs.Close;
      // TODO: 复制数据到 qryDataChangeLogs
      qryDataChangeLogs.Open;
    finally
      LDataSet.Free;
    end;
  finally
    LDataModule.Free;
  end;
end;

procedure TDataChangeLogFrame.Initialize;
begin
  inherited;
  // 设置默认时间范围为最近7天
  UniDateTimePickerStart.DateTime := Now - 7;
  UniDateTimePickerEnd.DateTime := Now;
  Refresh;
end;

procedure TDataChangeLogFrame.UniButtonSearchClick(Sender: TObject);
begin
  Refresh;
end;

procedure TDataChangeLogFrame.UniButtonExportClick(Sender: TObject);
begin
  // 导出数据变更日志
  ShowMessage('导出功能待实现');
end;

end.

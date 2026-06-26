unit DataChangeLogFrame;

interface

uses
  System.SysUtils, System.Classes, System.Variants,
  Data.DB, FireDAC.Comp.Client,
  uniGUIBaseClasses, uniGUIClasses, uniGUImClasses, uniEdit, uniButton,
  uniBasicGrid, uniDBGrid, uniToolBar, uniLabel, uniMultiItem, uniComboBox, uniPanel, uniDateTimePicker,
  UniContext, UniPlugin.Types, BaseCrudFrame, LogDataModule, MainModule;

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
  private
    FLastDataSet: TDataSet;
    procedure FreeLastDataSet;
  protected
    procedure DoInitialize; override;
    procedure DoRefresh; override;
  public
    procedure Initialize; override;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

{ TDataChangeLogFrame }

destructor TDataChangeLogFrame.Destroy;
begin
  FreeLastDataSet;
  inherited;
end;

procedure TDataChangeLogFrame.FreeLastDataSet;
begin
  if Assigned(FLastDataSet) then
  begin
    UniDataSource.DataSet := nil;
    FreeAndNil(FLastDataSet);
  end;
end;

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

  LDataModule := TLogDataModule.CreateWithConnection(nil, GetMainModule.Connection);
  try
    if Supports(LDataModule, IContextAware) then
      (LDataModule as IContextAware).SetContext(Context);

    LDataSet := LDataModule.GetDataChangeLogs(LUserName, LTableName, LStartTime, LEndTime, 1, 100);
    FreeLastDataSet;
    UniDataSource.DataSet := LDataSet;
    FLastDataSet := LDataSet;
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

initialization
  // Register for FindClass-driven MDI routing (UniAdmin_Menus.RoutePath)
  RegisterClass(TDataChangeLogFrame);

end.

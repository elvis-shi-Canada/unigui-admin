unit TaskLogFrame;

interface

uses
  System.SysUtils, System.Classes, System.Variants,
  Data.DB, FireDAC.Comp.Client,
  uniGUIControls, uniGUIBaseClasses, uniGUIClasses, uniGUImClasses, uniEdit, uniButton,
  uniGrid, uniToolBar, uniLabel, uniPanel, uniMemo,
  UniContext, UniPlugin.Types, BaseCrudFrame, UniScheduler;

type
  /// <summary>
  /// 任务执行日志窗体
  /// </summary>
  TTaskLogFrame = class(TBaseCrudFrame)
    UniPanelTop: TUniPanel;
    UniLabelTask: TUniLabel;
    UniComboBoxTask: TUniComboBox;
    UniButtonSearch: TUniButton;
    UniDBGrid: TUniDBGrid;
    UniDataSource: TDataSource;
    qryLogs: TFDQuery;
    UniPanelDetail: TUniPanel;
    UniLabelDetail: TUniLabel;
    UniMemoDetail: TUniMemo;
    FTaskID: Integer;

    procedure UniButtonSearchClick(Sender: TObject);
    procedure UniDBGridAfterScroll(DataSet: TDataSet);
  protected
    procedure DoInitialize; override;
    procedure DoRefresh; override;
  public
    procedure Initialize; override;
    procedure SetTaskID(TaskID: Integer);
  end;

implementation

{$R *.dfm}

{ TTaskLogFrame }

procedure TTaskLogFrame.DoInitialize;
begin
  inherited;
  FPermissionPrefix := 'scheduler_log';
  FTaskID := 0;

  // 加载任务列表到下拉框
  // TODO: 从数据库加载任务列表
end;

procedure TTaskLogFrame.DoRefresh;
var
  LLogs: TArray<TTaskExecutionLogInfo>;
begin
  if FTaskID <= 0 then
    Exit;

  // TODO: 获取任务执行日志
  // LLogs := FScheduler.GetTaskExecutionLogs(FTaskID, 100);

  qryLogs.Close;
  // TODO: 填充 qryLogs
  qryLogs.Open;
end;

procedure TTaskLogFrame.Initialize;
begin
  inherited;
  // TODO: 加载任务列表
end;

procedure TTaskLogFrame.SetTaskID(TaskID: Integer);
begin
  FTaskID := TaskID;
  Refresh;
end;

procedure TTaskLogFrame.UniButtonSearchClick(Sender: TObject);
begin
  // 从下拉框获取选择的任务ID
  FTaskID := UniComboBoxTask.ItemIndex;
  Refresh;
end;

procedure TTaskLogFrame.UniDBGridAfterScroll(DataSet: TDataSet);
var
  LDetail: string;
begin
  if not qryLogs.Eof then
  begin
    LDetail := '开始时间: ' + FormatDateTime('yyyy-mm-dd hh:nn:ss',
      qryLogs.FieldByName('StartTime').AsDateTime) + #13#10;
    LDetail := LDetail + '结束时间: ' + FormatDateTime('yyyy-mm-dd hh:nn:ss',
      qryLogs.FieldByName('EndTime').AsDateTime) + #13#10;
    LDetail := LDetail + '执行状态: ' + Ifthen(qryLogs.FieldByName('Status').AsInteger = 1, '成功', '失败') + #13#10;
    LDetail := LDetail + '执行时长: ' + IntToStr(qryLogs.FieldByName('Duration').AsInteger) + ' ms' + #13#10;

    if qryLogs.FieldByName('Status').AsInteger = 0 then
      LDetail := LDetail + '错误信息: ' + qryLogs.FieldByName('ErrorMessage').AsString + #13#10;

    LDetail := LDetail + '执行结果: ' + qryLogs.FieldByName('Result').AsString;

    UniMemoDetail.Text := LDetail;
  end;
end;

end.

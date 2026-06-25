unit TaskManageFrame;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.StrUtils,
  Data.DB, FireDAC.Comp.Client,
  uniGUIBaseClasses, uniGUIClasses, uniGUImClasses, uniEdit, uniButton,
  uniBasicGrid, uniDBGrid, uniToolBar, uniLabel, uniMultiItem, uniComboBox, uniPanel,
  UniContext, UniPlugin.Types, BaseCrudFrame, UniAdminScheduler;

type
  /// <summary>
  /// 定时任务管理窗体
  /// </summary>
  TTaskManageFrame = class(TBaseCrudFrame)
    UniPanelTop: TUniPanel;
    UniLabelFilter: TUniLabel;
    UniEditFilter: TUniEdit;
    UniLabelStatus: TUniLabel;
    UniComboBoxStatus: TUniComboBox;
    UniButtonSearch: TUniButton;
    UniButtonRefresh: TUniButton;
    UniDBGrid: TUniDBGrid;
    UniDataSource: TDataSource;
    qryTasks: TFDQuery;
    FScheduler: TUniAdminScheduler;

    procedure UniButtonSearchClick(Sender: TObject);
    procedure UniButtonRefreshClick(Sender: TObject);
    procedure UniDBGridDblClick(Sender: TObject);
  private
    FLastDataSet: TDataSet;
    procedure FreeLastDataSet;
  protected
    procedure DoInitialize; override;
    procedure DoRefresh; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialize; override;
  end;

implementation

{$R *.dfm}

{ TTaskManageFrame }

constructor TTaskManageFrame.Create(AOwner: TComponent);
begin
  inherited;
  FScheduler := nil;
  FLastDataSet := nil;
end;

destructor TTaskManageFrame.Destroy;
begin
  FreeLastDataSet;
  if Assigned(FScheduler) then
    FScheduler.Free;
  inherited;
end;

procedure TTaskManageFrame.FreeLastDataSet;
begin
  if Assigned(FLastDataSet) then
  begin
    UniDataSource.DataSet := nil;
    FreeAndNil(FLastDataSet);
  end;
end;

procedure TTaskManageFrame.DoInitialize;
begin
  inherited;
  FPermissionPrefix := 'scheduler_task';

  // 初始化状态下拉框
  UniComboBoxStatus.Items.Clear;
  UniComboBoxStatus.Items.Add('全部');
  UniComboBoxStatus.Items.Add('运行中');
  UniComboBoxStatus.Items.Add('已停止');
  UniComboBoxStatus.Items.Add('已暂停');
  UniComboBoxStatus.Items.Add('错误');
  UniComboBoxStatus.ItemIndex := 0;

  // 创建调度器实例
  if Assigned(Context) then
  begin
    try
      FScheduler := TUniAdminScheduler.Create(Context, nil);
    except
      on E: Exception do
        FScheduler := nil;
    end;
  end;
end;

procedure TTaskManageFrame.DoRefresh;
var
  LFilter: string;
  LStatusIdx: Integer;
  LTasks: TArray<TScheduledTaskInfo>;
  LTask: TScheduledTaskInfo;
  LMemTable: TFDMemTable;
begin
  FreeLastDataSet;

  LFilter := Trim(UniEditFilter.Text);
  LStatusIdx := UniComboBoxStatus.ItemIndex;

  if Assigned(FScheduler) then
    LTasks := FScheduler.GetTasks
  else
    LTasks := nil;

  // 使用内存表展示数据
  LMemTable := TFDMemTable.Create(nil);
  try
    LMemTable.FieldDefs.Add('TaskID', ftInteger);
    LMemTable.FieldDefs.Add('TaskName', ftString, 100);
    LMemTable.FieldDefs.Add('TaskCode', ftString, 50);
    LMemTable.FieldDefs.Add('CronExpression', ftString, 50);
    LMemTable.FieldDefs.Add('HandlerClass', ftString, 100);
    LMemTable.FieldDefs.Add('StatusText', ftString, 20);
    LMemTable.FieldDefs.Add('LastRunTime', ftDateTime);
    LMemTable.FieldDefs.Add('NextRunTime', ftDateTime);
    LMemTable.FieldDefs.Add('LastRunMessage', ftString, 200);
    LMemTable.CreateDataSet;

    for LTask in LTasks do
    begin
      // 按筛选条件过滤
      if (LFilter <> '') and
         (not LFilter.Contains(LTask.TaskName)) and
         (not LFilter.Contains(LTask.TaskCode)) then
        Continue;

      // 按状态过滤
      case LStatusIdx of
        1: if LTask.Status <> tsRunning then Continue;
        2: if LTask.Status <> tsStopped then Continue;
        3: if LTask.Status <> tsPaused then Continue;
        4: if LTask.Status <> tsError then Continue;
      end;

      LMemTable.Append;
      LMemTable.FieldByName('TaskID').AsInteger := LTask.TaskID;
      LMemTable.FieldByName('TaskName').AsString := LTask.TaskName;
      LMemTable.FieldByName('TaskCode').AsString := LTask.TaskCode;
      LMemTable.FieldByName('CronExpression').AsString := LTask.CronExpression;
      LMemTable.FieldByName('HandlerClass').AsString := LTask.HandlerClass;

      case LTask.Status of
        tsStopped: LMemTable.FieldByName('StatusText').AsString := '已停止';
        tsRunning: LMemTable.FieldByName('StatusText').AsString := '运行中';
        tsPaused:  LMemTable.FieldByName('StatusText').AsString := '已暂停';
        tsError:   LMemTable.FieldByName('StatusText').AsString := '错误';
      end;

      if LTask.LastRunTime > 0 then
        LMemTable.FieldByName('LastRunTime').AsDateTime := LTask.LastRunTime;
      if LTask.NextRunTime > 0 then
        LMemTable.FieldByName('NextRunTime').AsDateTime := LTask.NextRunTime;
      LMemTable.FieldByName('LastRunMessage').AsString := LTask.LastRunMessage;
      LMemTable.Post;
    end;

    FLastDataSet := LMemTable;
    UniDataSource.DataSet := FLastDataSet;
  except
    LMemTable.Free;
    raise;
  end;
end;

procedure TTaskManageFrame.Initialize;
begin
  inherited;
  Refresh;
end;

procedure TTaskManageFrame.UniButtonSearchClick(Sender: TObject);
begin
  Refresh;
end;

procedure TTaskManageFrame.UniButtonRefreshClick(Sender: TObject);
begin
  if Assigned(FScheduler) then
    FScheduler.ReloadTasks;
  Refresh;
end;

procedure TTaskManageFrame.UniDBGridDblClick(Sender: TObject);
begin
  // 双击编辑
  if Assigned(BtnEdit) and BtnEdit.Enabled then
    BtnEditClick(nil);
end;

end.

unit TaskLogFrame;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.StrUtils,
  Data.DB, FireDAC.Comp.Client,
  uniGUIBaseClasses, uniGUIClasses, uniGUImClasses, uniEdit, uniButton,
  uniBasicGrid, uniDBGrid, uniToolBar, uniLabel, uniPanel, uniMemo, uniComboBox,
  UniContext, UniPlugin.Types, BaseCrudFrame, UniAdminScheduler,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, uniMultiItem,
  Vcl.Controls, Vcl.Forms;

type
  /// <summary>
  /// 任务执行日志窗体
  /// </summary>
  TTaskLogFrame = class(TBaseCrudFrame)
    UniPanelTop: TUniPanel;
    UniLabelTask: TUniLabel;
    UniComboBoxTask: TUniComboBox;
    UniButtonSearch: TUniButton;
    qryLogs: TFDQuery;
    UniPanelDetail: TUniPanel;
    UniLabelDetail: TUniLabel;
    UniMemoDetail: TUniMemo;

    procedure UniButtonSearchClick(Sender: TObject);
    procedure UniDBGridAfterScroll(DataSet: TDataSet);
  private
    FTaskID: Integer;
    FLastDataSet: TDataSet;
    procedure FreeLastDataSet;
    procedure LoadTaskList;
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

procedure TTaskLogFrame.FreeLastDataSet;
begin
  if Assigned(FLastDataSet) then
  begin
    UniDataSource.DataSet := nil;
    FreeAndNil(FLastDataSet);
  end;
end;

procedure TTaskLogFrame.LoadTaskList;
var
  LQuery: TFDQuery;
begin
  UniComboBoxTask.Items.Clear;
  UniComboBoxTask.Items.Add('全部任务');

  LQuery := TFDQuery.Create(nil);
  try
    if Assigned(Context) and Assigned(Context.GetDatabaseConfig) then
    begin
      // 使用上下文获取连接信息
      LQuery.SQL.Text :=
        'SELECT TaskID, TaskName FROM UniAdmin_ScheduledTasks ORDER BY TaskID';
      try
        LQuery.Open;
        while not LQuery.Eof do
        begin
          UniComboBoxTask.Items.AddObject(
            LQuery.FieldByName('TaskName').AsString,
            TObject(LQuery.FieldByName('TaskID').AsInteger));
          LQuery.Next;
        end;
      except
        // 数据库不可用时忽略
      end;
    end;
  finally
    LQuery.Free;
  end;

  UniComboBoxTask.ItemIndex := 0;
end;

procedure TTaskLogFrame.DoInitialize;
begin
  inherited;
  FPermissionPrefix := 'scheduler_log';
  FTaskID := 0;
  FLastDataSet := nil;

  LoadTaskList;
end;

procedure TTaskLogFrame.DoRefresh;
var
  LLogs: TArray<TTaskExecutionLogInfo>;
  LLog: TTaskExecutionLogInfo;
  LMemTable: TFDMemTable;
begin
  FreeLastDataSet;

  LMemTable := TFDMemTable.Create(nil);
  try
    LMemTable.FieldDefs.Add('LogID', ftInteger);
    LMemTable.FieldDefs.Add('TaskID', ftInteger);
    LMemTable.FieldDefs.Add('StartTime', ftDateTime);
    LMemTable.FieldDefs.Add('EndTime', ftDateTime);
    LMemTable.FieldDefs.Add('Status', ftInteger);
    LMemTable.FieldDefs.Add('StatusText', ftString, 20);
    LMemTable.FieldDefs.Add('ErrorMessage', ftString, 500);
    LMemTable.FieldDefs.Add('Result', ftString, 200);
    LMemTable.FieldDefs.Add('Duration', ftInteger);
    LMemTable.CreateDataSet;

    // 从调度器获取日志（如果可用）
    // 否则尝试直接查询数据库
    if FTaskID > 0 then
    begin
      LLogs := nil;
      // 尝试通过数据库查询
      if Assigned(Context) then
      begin
        var LQuery := TFDQuery.Create(nil);
        try
          LQuery.SQL.Text :=
            'SELECT LogID, TaskID, StartTime, EndTime, Status, ' +
            'ErrorMessage, Result, Duration ' +
            'FROM UniAdmin_TaskExecutionLogs ' +
            'WHERE TaskID = :TaskID ' +
            'ORDER BY StartTime DESC LIMIT 100';
          LQuery.Params.ParamByName('TaskID').AsInteger := FTaskID;
          try
            LQuery.Open;
            while not LQuery.Eof do
            begin
              LMemTable.Append;
              LMemTable.FieldByName('LogID').AsInteger := LQuery.FieldByName('LogID').AsInteger;
              LMemTable.FieldByName('TaskID').AsInteger := LQuery.FieldByName('TaskID').AsInteger;
              LMemTable.FieldByName('StartTime').AsDateTime := LQuery.FieldByName('StartTime').AsDateTime;
              LMemTable.FieldByName('EndTime').AsDateTime := LQuery.FieldByName('EndTime').AsDateTime;
              LMemTable.FieldByName('Status').AsInteger := LQuery.FieldByName('Status').AsInteger;
              LMemTable.FieldByName('StatusText').AsString :=
                IfThen(LQuery.FieldByName('Status').AsInteger = 1, '成功', '失败');
              LMemTable.FieldByName('ErrorMessage').AsString := LQuery.FieldByName('ErrorMessage').AsString;
              LMemTable.FieldByName('Result').AsString := LQuery.FieldByName('Result').AsString;
              LMemTable.FieldByName('Duration').AsInteger := LQuery.FieldByName('Duration').AsInteger;
              LMemTable.Post;
              LQuery.Next;
            end;
          except
            // 数据库不可用时返回空数据
          end;
        finally
          LQuery.Free;
        end;
      end;
    end;

    FLastDataSet := LMemTable;
    UniDataSource.DataSet := FLastDataSet;
  except
    LMemTable.Free;
    raise;
  end;
end;

procedure TTaskLogFrame.Initialize;
begin
  inherited;
  Refresh;
end;

procedure TTaskLogFrame.SetTaskID(TaskID: Integer);
begin
  FTaskID := TaskID;
  Refresh;
end;

procedure TTaskLogFrame.UniButtonSearchClick(Sender: TObject);
var
  LIdx: Integer;
begin
  // 从下拉框获取选择的任务ID
  LIdx := UniComboBoxTask.ItemIndex;
  if LIdx <= 0 then
    FTaskID := 0
  else if UniComboBoxTask.Items.Objects[LIdx] <> nil then
    FTaskID := Integer(UniComboBoxTask.Items.Objects[LIdx])
  else
    FTaskID := 0;

  Refresh;
end;

procedure TTaskLogFrame.UniDBGridAfterScroll(DataSet: TDataSet);
var
  LDetail: string;
begin
  if Assigned(FLastDataSet) and not FLastDataSet.Eof then
  begin
    LDetail := '开始时间: ' + FormatDateTime('yyyy-mm-dd hh:nn:ss',
      FLastDataSet.FieldByName('StartTime').AsDateTime) + #13#10;
    LDetail := LDetail + '结束时间: ' + FormatDateTime('yyyy-mm-dd hh:nn:ss',
      FLastDataSet.FieldByName('EndTime').AsDateTime) + #13#10;
    LDetail := LDetail + '执行状态: ' +
      FLastDataSet.FieldByName('StatusText').AsString + #13#10;
    LDetail := LDetail + '执行时长: ' +
      IntToStr(FLastDataSet.FieldByName('Duration').AsInteger) + ' ms' + #13#10;

    if FLastDataSet.FieldByName('Status').AsInteger = 0 then
      LDetail := LDetail + '错误信息: ' +
        FLastDataSet.FieldByName('ErrorMessage').AsString + #13#10;

    LDetail := LDetail + '执行结果: ' +
      FLastDataSet.FieldByName('Result').AsString;

    UniMemoDetail.Text := LDetail;
  end;
end;

initialization
  // Register for FindClass-driven MDI routing (UniAdmin_Menus.RoutePath)
  RegisterClass(TTaskLogFrame);

end.

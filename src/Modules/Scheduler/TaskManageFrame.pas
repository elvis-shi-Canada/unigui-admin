unit TaskManageFrame;

interface

uses
  System.SysUtils, System.Classes, System.Variants,
  Data.DB, FireDAC.Comp.Client,
  uniGUIControls, uniGUIBaseClasses, uniGUIClasses, uniGUImClasses, uniEdit, uniButton,
  uniGrid, uniToolBar, uniLabel, uniComboBox, uniPanel,
  UniContext, UniPlugin.Types, BaseCrudFrame, UniScheduler;

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
    FScheduler: TUniScheduler;

    procedure UniButtonSearchClick(Sender: TObject);
    procedure UniButtonRefreshClick(Sender: TObject);
    procedure UniDBGridDblClick(Sender: TObject);
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
  // TODO: 初始化调度器
  FScheduler := nil;
end;

destructor TTaskManageFrame.Destroy;
begin
  if Assigned(FScheduler) then
    FScheduler.Free;
  inherited;
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
end;

procedure TTaskManageFrame.DoRefresh;
var
  LFilter: string;
  LTasks: TArray<TScheduledTaskInfo>;
  LTask: TScheduledTaskInfo;
begin
  LFilter := Trim(UniEditFilter.Text);

  // TODO: 根据筛选条件加载任务
  // LTasks := FScheduler.GetTasks;

  qryTasks.Close;
  // TODO: 填充 qryTasks
  qryTasks.Open;
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

unit OperationLogFrame;

interface

uses
  System.SysUtils, System.Classes, System.Variants,
  Data.DB, FireDAC.Comp.Client,
  uniGUIBaseClasses, uniGUIClasses, uniGUImClasses, uniEdit, uniButton,
  uniBasicGrid, uniDBGrid, uniToolBar, uniLabel, uniMultiItem, uniComboBox, uniPanel, uniDateTimePicker,
  UniContext, UniPlugin.Types, BaseCrudFrame, LogDataModule, MainModule,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, Vcl.Controls,
  Vcl.Forms;

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
    qryOperationLogs: TFDQuery;

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

{ TOperationLogFrame }

destructor TOperationLogFrame.Destroy;
begin
  FreeLastDataSet;
  inherited;
end;

procedure TOperationLogFrame.FreeLastDataSet;
begin
  if Assigned(FLastDataSet) then
  begin
    UniDataSource.DataSet := nil;
    FreeAndNil(FLastDataSet);
  end;
end;

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

  LDataModule := TLogDataModule.CreateWithConnection(nil, GetMainModule.Connection);
  try
    if Supports(LDataModule, IContextAware) then
      (LDataModule as IContextAware).SetContext(Context);

    LDataSet := LDataModule.GetOperationLogs(LUserName, LModule, LStartTime, LEndTime, LStatus, 1, 100);
    FreeLastDataSet;
    UniDataSource.DataSet := LDataSet;
    FLastDataSet := LDataSet;
  finally
    LDataModule.Free;
  end;
end;

procedure TOperationLogFrame.Initialize;
begin
  inherited;
  // 操作日志为纯只读，隐藏无意义的新增/编辑/删除按钮
  if Assigned(BtnAdd) then BtnAdd.Visible := False;
  if Assigned(BtnEdit) then BtnEdit.Visible := False;
  if Assigned(BtnDelete) then BtnDelete.Visible := False;
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

initialization
  // Register for FindClass-driven MDI routing (UniAdmin_Menus.RoutePath)
  RegisterClass(TOperationLogFrame);

end.

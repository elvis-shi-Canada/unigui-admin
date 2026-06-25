unit BaseCrudFrame;

interface

uses
  System.SysUtils, System.Classes, System.Variants,
  Data.DB, FireDAC.Comp.Client,
  uniGUIBaseClasses, uniGUIClasses, uniGUImClasses, uniEdit, uniButton, uniBasicGrid, uniDBGrid,
  uniToolBar, uniGUIForm, uniGUIFrame,
  UniContext, UniPlugin.Types, UniAdminModel, Vcl.Controls, Vcl.Forms;

type
  /// <summary>
  /// CRUD 基类窗体 - 提供标准 CRUD 操作界面
  /// 子类继承此窗体可获得标准的 CRUD 功能
  /// </summary>
  TBaseCrudFrame = class(TUniFrame)
  private
    FModelAdmin: TUniAdminModel;
    FContext: IExecutionContext;

    procedure UpdateButtonStates;
    procedure CheckPermissions;

    // 工具栏按钮事件
    procedure BtnAddClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnRefreshClick(Sender: TObject);

    procedure DoStateChange(Sender: TObject);
  protected
    FPermissionPrefix: string;

    // 工具栏组件
    UniToolBar: TUniToolBar;
    BtnAdd: TUniButton;
    BtnEdit: TUniButton;
    BtnDelete: TUniButton;
    BtnSave: TUniButton;
    BtnCancel: TUniButton;
    BtnRefresh: TUniButton;

    // 数据组件
    UniDBGrid: TUniDBGrid;
    UniDataSource: TDataSource;

    // 子类可重写的方法
    /// <summary>
    /// 绑定编辑控件到数据源
    /// </summary>
    procedure DoBindControls; virtual;

    /// <summary>
    /// 解绑编辑控件
    /// </summary>
    procedure DoUnbindControls; virtual;

    /// <summary>
    /// 初始化组件
    /// </summary>
    procedure DoInitialize; virtual;

    /// <summary>
    /// 清理资源
    /// </summary>
    procedure DoFinalize; virtual;

    /// <summary>
    /// 刷新数据
    /// </summary>
    procedure DoRefresh; virtual;

    // 工具栏按钮事件（protected，子类可调用）
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDeleteClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    /// <summary>
    /// 设置执行上下文
    /// </summary>
    procedure SetContext(const Context: IExecutionContext);

    /// <summary>
    /// 初始化窗体
    /// </summary>
    procedure Initialize; virtual;

    /// <summary>
    /// 清理窗体
    /// </summary>
    procedure Finalize; virtual;

    /// <summary>
    /// 刷新数据显示
    /// </summary>
    procedure Refresh; virtual;

    property ModelAdmin: TUniAdminModel read FModelAdmin;
    property Context: IExecutionContext read FContext;
    property PermissionPrefix: string read FPermissionPrefix write FPermissionPrefix;
  end;

implementation

{$R *.dfm}

{ TBaseCrudFrame }

constructor TBaseCrudFrame.Create(AOwner: TComponent);
begin
  inherited;
  FModelAdmin := TUniAdminModel.Create(Self);
  FModelAdmin.OnStateChange := DoStateChange;
  FPermissionPrefix := ''; // 子类设置
end;

destructor TBaseCrudFrame.Destroy;
begin
  FModelAdmin.Free;
  inherited;
end;

procedure TBaseCrudFrame.SetContext(const Context: IExecutionContext);
begin
  FContext := Context;
  FModelAdmin.SetContext(Context);
end;

procedure TBaseCrudFrame.Initialize;
begin
  DoInitialize;
  CheckPermissions;
  UpdateButtonStates;
  Refresh;
end;

procedure TBaseCrudFrame.Finalize;
begin
  DoFinalize;
end;

procedure TBaseCrudFrame.DoInitialize;
begin
  // 子类重写 - 初始化自定义组件
end;

procedure TBaseCrudFrame.DoFinalize;
begin
  // 子类重写 - 清理自定义资源
end;

procedure TBaseCrudFrame.DoBindControls;
begin
  // 子类重写 - 绑定编辑控件到数据源
end;

procedure TBaseCrudFrame.DoUnbindControls;
begin
  // 子类重写 - 解绑编辑控件
end;

procedure TBaseCrudFrame.DoRefresh;
begin
  // 子类重写 - 自定义刷新逻辑
end;

procedure TBaseCrudFrame.Refresh;
var
  LQuery: TFDQuery;
begin
  DoRefresh;

  if Assigned(UniDataSource) and Assigned(UniDataSource.DataSet) then
  begin
    if UniDataSource.DataSet is TFDQuery then
    begin
      LQuery := TFDQuery(UniDataSource.DataSet);
      if LQuery.Active then
        LQuery.Refresh
      else
        LQuery.Open;
    end
    else
      UniDataSource.DataSet.Refresh;
  end;
end;

procedure TBaseCrudFrame.CheckPermissions;
var
  LHasPermission: Boolean;
begin
  if not Assigned(FContext) then
    Exit;

  if FPermissionPrefix = '' then
  begin
    // 无权限前缀，显示所有按钮
    if Assigned(BtnAdd) then
      BtnAdd.Visible := True;
    if Assigned(BtnEdit) then
      BtnEdit.Visible := True;
    if Assigned(BtnDelete) then
      BtnDelete.Visible := True;
    Exit;
  end;

  // 检查权限
  LHasPermission := FContext.GetUserContext.HasPermission(FPermissionPrefix + ':view');

  if Assigned(BtnAdd) then
    BtnAdd.Visible := LHasPermission and FContext.GetUserContext.HasPermission(FPermissionPrefix + ':add');

  if Assigned(BtnEdit) then
    BtnEdit.Visible := LHasPermission and FContext.GetUserContext.HasPermission(FPermissionPrefix + ':edit');

  if Assigned(BtnDelete) then
    BtnDelete.Visible := LHasPermission and FContext.GetUserContext.HasPermission(FPermissionPrefix + ':delete');
end;

procedure TBaseCrudFrame.UpdateButtonStates;
begin
  if not Assigned(FModelAdmin) then
    Exit;

  if Assigned(BtnAdd) then
    BtnAdd.Enabled := FModelAdmin.CanInsert;

  if Assigned(BtnEdit) then
    BtnEdit.Enabled := FModelAdmin.CanEdit;

  if Assigned(BtnDelete) then
    BtnDelete.Enabled := FModelAdmin.CanDelete;

  if Assigned(BtnSave) then
    BtnSave.Enabled := FModelAdmin.CanSave;

  if Assigned(BtnCancel) then
    BtnCancel.Enabled := FModelAdmin.CanCancel;

  if Assigned(BtnRefresh) then
    BtnRefresh.Enabled := FModelAdmin.State = csBrowse;
end;

procedure TBaseCrudFrame.DoStateChange(Sender: TObject);
begin
  UpdateButtonStates;
end;

procedure TBaseCrudFrame.BtnAddClick(Sender: TObject);
begin
  try
    FModelAdmin.Insert;
    DoBindControls;
    UpdateButtonStates;
  except
    on E: Exception do
    begin
      UpdateButtonStates;
      raise;
    end;
  end;
end;

procedure TBaseCrudFrame.BtnEditClick(Sender: TObject);
begin
  try
    FModelAdmin.Edit;
    DoBindControls;
    UpdateButtonStates;
  except
    on E: Exception do
    begin
      UpdateButtonStates;
      raise;
    end;
  end;
end;

procedure TBaseCrudFrame.BtnDeleteClick(Sender: TObject);
begin
  try
    FModelAdmin.Delete;
    UpdateButtonStates;
  except
    on E: Exception do
    begin
      UpdateButtonStates;
      raise;
    end;
  end;
end;

procedure TBaseCrudFrame.BtnSaveClick(Sender: TObject);
begin
  try
    DoUnbindControls;
    FModelAdmin.Save;
    UpdateButtonStates;
  except
    on E: Exception do
    begin
      DoBindControls; // 重新绑定以便用户可以继续编辑
      UpdateButtonStates;
      raise;
    end;
  end;
end;

procedure TBaseCrudFrame.BtnCancelClick(Sender: TObject);
begin
  try
    DoUnbindControls;
    FModelAdmin.Cancel;
    UpdateButtonStates;
  except
    on E: Exception do
    begin
      UpdateButtonStates;
      raise;
    end;
  end;
end;

procedure TBaseCrudFrame.BtnRefreshClick(Sender: TObject);
begin
  Refresh;
end;

end.

unit BaseCrudFrame;

interface

uses
  System.SysUtils, System.Classes, System.Variants,
  Data.DB, FireDAC.Comp.Client,
  uniGUIBaseClasses, uniGUIClasses, uniGUImClasses, uniEdit, uniButton, uniBasicGrid, uniDBGrid,
  uniToolBar, uniGUIForm, uniGUIFrame,
  UniContext, UniPlugin.Types, UniAdminModel, Vcl.Controls, Vcl.Forms,
  UniFieldMetadata, UniAdminMetadataCache.Intf;

type
  /// <summary>
  /// CRUD 基类窗体 - 提供标准 CRUD 操作界面
  /// 子类继承此窗体可获得标准的 CRUD 功能
  /// </summary>
  TBaseCrudFrame = class(TUniFrame)
    // 工具栏与数据组件：必须在 published 区，DFM 流读取器才能通过 RTTI
    // 绑定到这些字段（protected/private 字段对 DFM 不可见，会导致组件创建后
    // 无法绑定、字段悬空，引发 Access Violation）。
    UniToolBar: TUniToolBar;
    BtnAdd: TUniButton;
    BtnEdit: TUniButton;
    BtnDelete: TUniButton;
    BtnSave: TUniButton;
    BtnCancel: TUniButton;
    BtnRefresh: TUniButton;
    UniDBGrid: TUniDBGrid;
    UniDataSource: TDataSource;
  private
    FModelAdmin: TUniAdminModel;
    FContext: IExecutionContext;
    FAutoGridFromMeta: Boolean;
    FModelTableName: string;
    FMetadataCache: IUniAdminMetadataCache;

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

    /// <summary>
    /// 从元数据缓存自动构建网格列
    /// 仅当 AutoGridFromMeta=True 且 UniDBGrid.Columns 为空时生效。
    /// 子类已手写列则尊重之，不覆盖。
    /// </summary>
    procedure BuildGridFromMetadata; virtual;

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
    // 声明式网格派生开关
    property AutoGridFromMeta: Boolean read FAutoGridFromMeta write FAutoGridFromMeta;
    property ModelTableName: string read FModelTableName write FModelTableName;
    property MetadataCache: IUniAdminMetadataCache read FMetadataCache write FMetadataCache;
  end;

implementation

uses
  uniGUIApplication, MainModule;

{$R *.dfm}

{ TBaseCrudFrame }

constructor TBaseCrudFrame.Create(AOwner: TComponent);
begin
  inherited;
  FModelAdmin := TUniAdminModel.Create(Self);
  FModelAdmin.OnStateChange := DoStateChange;
  FPermissionPrefix := '';
  FAutoGridFromMeta := False;
  FModelTableName := '';
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
  // 自动从元数据派生网格列（若启用且未手写）。子类 override 时若需开启，
  // 应在调用 inherited 之前设置 AutoGridFromMeta := True 和 ModelTableName。
  BuildGridFromMetadata;
  // 子类可在 override 后继续追加自定义初始化
end;

procedure TBaseCrudFrame.BuildGridFromMetadata;
var
  LMeta: TTableMetadata;
  LField: TFieldMetadata;
begin
  if (not FAutoGridFromMeta) or (FModelTableName = '') then
    Exit;
  if not Assigned(UniDBGrid) then
    Exit;
  if UniDBGrid.Columns.Count > 0 then
    Exit; // 尊重子类已手写的列

  // 惰性注入 MetadataCache：若外部未显式赋值，尝试从当前会话 MainModule 取
  if (not Assigned(FMetadataCache)) and Assigned(UniApplication) and
     Assigned(UniApplication.UniMainModule) and
     (UniApplication.UniMainModule is TMainModule) then
    FMetadataCache := TMainModule(UniApplication.UniMainModule).Services.MetadataCache;

  if not Assigned(FMetadataCache) then
    Exit; // 无元数据源则放弃派生（不阻断 UI）

  try
    LMeta := FMetadataCache.GetTableMetadata(FModelTableName);
  except
    // 元数据查询失败（如 SQLite 不支持 INFORMATION_SCHEMA）：降级为空网格，不阻断
    Exit;
  end;

  for LField in LMeta.Fields do
  begin
    // 跳过敏感/审计字段（通常不在列表展示）
    if SameText(LField.FieldName, 'Password') or
       SameText(LField.FieldName, 'CreatedBy') or
       SameText(LField.FieldName, 'ModifiedBy') then
      Continue;

    with UniDBGrid.Columns.Add do
    begin
      FieldName := LField.FieldName;
      if LField.DisplayName <> '' then
        Title.Caption := LField.DisplayName
      else
        Title.Caption := LField.FieldName;
      Width := 100;
    end;
  end;

  // 注意：不要调用 LMeta.Clear —— Fields 指向缓存内部的 TList<>,
  // 由 TUniAdminMetadataCache.Destroy/Clear 负责释放。此处释放会导致缓存悬空。
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

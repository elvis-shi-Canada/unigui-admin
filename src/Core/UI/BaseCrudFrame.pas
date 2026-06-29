unit BaseCrudFrame;

interface

uses
  System.SysUtils, System.Classes, System.Variants,
  Data.DB, FireDAC.Comp.Client,
  uniGUIBaseClasses, uniGUIClasses, uniGUImClasses, uniEdit, uniButton, uniBasicGrid, uniDBGrid,
  uniToolBar, uniGUIForm, uniGUIFrame,
  UniContext, UniPlugin.Types, UniAdminModel, Vcl.Controls, Vcl.Forms,
  UniFieldMetadata, UniAdminMetadataCache.Intf, UniAdminMdiRouter.Intf;

type
  /// <summary>
  /// CRUD 基类窗体 - 提供标准 CRUD 操作界面
  /// 子类继承此窗体可获得标准的 CRUD 功能
  /// </summary>
  TBaseCrudFrame = class(TUniFrame, IMdiInitializable)
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

    // 工具栏按钮事件：DFM 通过 OnXxx 绑定，必须在 published 区（RTTI 可见）
    // 否则 DFM 找不到方法，报 "Invalid property value" 或静默不执行。
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDeleteClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnRefreshClick(Sender: TObject);
  private
    FModelAdmin: TUniAdminModel;
    FContext: IExecutionContext;
    FAutoGridFromMeta: Boolean;
    FModelTableName: string;
    FMetadataCache: IUniAdminMetadataCache;

    procedure UpdateButtonStates;
    procedure CheckPermissions;

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

    // —— CRUD 业务钩子 ——
    // BtnAdd/BtnEdit/BtnDelete 点击后调用这些钩子。子类重写以打开各自的编辑窗体
    // 或执行删除。基类默认实现为"什么都不做"（返回 False），让只读模块（日志/调度
    // 等）的按钮即使被点击也无副作用。
    // 绕过 FModelAdmin 的 Insert/Edit/Delete 状态机——该状态机依赖 FDataSet，
    // 而子类普遍只赋 UniDataSource.DataSet，FModelAdmin.DataSet 长期为 nil，
    // 走状态机会 AV。改为钩子直接处理业务，更直接也更安全。

    /// <summary>新增记录。返回 True 表示已处理且需要刷新列表（如新增成功）。</summary>
    function DoAdd: Boolean; virtual;

    /// <summary>编辑指定记录。AID 为主键值（由 GetSelectedID 提供）。</summary>
    function DoEdit(const AID: Variant): Boolean; virtual;

    /// <summary>删除指定记录。基类已做 MessageDlg 确认，子类只需执行删除。</summary>
    function DoDelete(const AID: Variant): Boolean; virtual;

    /// <summary>
    /// 获取当前选中记录的主键值。基类默认从 UniDataSource.DataSet 取
    /// 字段名 'ID'；子类按各自主键名（RoleID/MenuID/UserID...）重写。
    /// 无选中时返回 Null/Unassigned。
    /// </summary>
    function GetSelectedID: Variant; virtual;
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
  System.UITypes,
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

{ CRUD 业务钩子默认实现 —— 只读模块（日志/调度等）无需重写，按钮无副作用 }

function TBaseCrudFrame.DoAdd: Boolean;
begin
  // 默认：无新增能力（如只读模块）。子类重写以打开编辑窗体。
  Result := False;
end;

function TBaseCrudFrame.DoEdit(const AID: Variant): Boolean;
begin
  // 默认：无编辑能力。子类重写以打开编辑窗体。
  Result := False;
end;

function TBaseCrudFrame.DoDelete(const AID: Variant): Boolean;
begin
  // 默认：无删除能力。子类重写以调用 DataModule.DeleteXxx。
  Result := False;
end;

function TBaseCrudFrame.GetSelectedID: Variant;
begin
  // 默认：返回 Null。各模块主键字段名不统一（RoleID/MenuID/UserID...），
  // 子类必须重写以返回正确主键；不重写则 BtnEdit/BtnDelete 会提示"请先选择"。
  Result := Null;
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

  // 数据加载后刷新按钮状态（编辑/删除按钮依赖"有选中记录"）
  UpdateButtonStates;
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
var
  LHasRecord: Boolean;
begin
  // 新增/编辑/删除已改为 DoAdd/DoEdit/DoDelete 钩子模式（模态窗体），
  // 不再依赖 FModelAdmin 的 Insert/Edit/Delete 状态机。因此按钮的 Enabled
  // 不应再由 FModelAdmin.CanXxx 控制（那些方法依赖 FModelAdmin.DataSet，
  // 而子类普遍只赋 UniDataSource.DataSet，FModelAdmin.DataSet 长期为 nil，
  // 会导致 CanInsert/CanEdit/CanDelete 返回 False，按钮被禁用、点击无响应）。
  //
  // 新规则：
  //   - 新增：永远可用（不依赖当前数据）
  //   - 编辑/删除：仅当列表有选中记录时可用
  //   - 刷新：永远可用
  //   - 保存/取消：行内编辑场景保留原 FModelAdmin 状态机逻辑（模态窗体不用这两个按钮）

  LHasRecord := Assigned(UniDataSource) and Assigned(UniDataSource.DataSet) and
                UniDataSource.DataSet.Active and not UniDataSource.DataSet.IsEmpty;

  if Assigned(BtnAdd) then
    BtnAdd.Enabled := True;

  if Assigned(BtnEdit) then
    BtnEdit.Enabled := LHasRecord;

  if Assigned(BtnDelete) then
    BtnDelete.Enabled := LHasRecord;

  if Assigned(BtnRefresh) then
    BtnRefresh.Enabled := True;

  // Save/Cancel 属于行内编辑状态机，保留 FModelAdmin 判定（与模态窗体互不干扰）
  if Assigned(FModelAdmin) then
  begin
    if Assigned(BtnSave) then
      BtnSave.Enabled := FModelAdmin.CanSave;

    if Assigned(BtnCancel) then
      BtnCancel.Enabled := FModelAdmin.CanCancel;
  end;
end;

procedure TBaseCrudFrame.DoStateChange(Sender: TObject);
begin
  UpdateButtonStates;
end;

procedure TBaseCrudFrame.BtnAddClick(Sender: TObject);
begin
  if DoAdd then
    Refresh;
end;

procedure TBaseCrudFrame.BtnEditClick(Sender: TObject);
var
  LID: Variant;
begin
  LID := GetSelectedID;
  if VarIsEmpty(LID) or VarIsNull(LID) or (LID = 0) then
  begin
    ShowMessage('请先选择一条记录');
    Exit;
  end;
  if DoEdit(LID) then
    Refresh;
end;

procedure TBaseCrudFrame.BtnDeleteClick(Sender: TObject);
var
  LID: Variant;
begin
  LID := GetSelectedID;
  if VarIsEmpty(LID) or VarIsNull(LID) or (LID = 0) then
  begin
    ShowMessage('请先选择一条记录');
    Exit;
  end;
  // UniGUI 的 MessageDlg 是异步回调，无法在同步流程里等待用户确认。
  // 因此删除确认由子类的 DoDelete 内部用 MessageDlg + 回调完成，
  // 回调成功后再调用 Refresh 刷新。基类此处只触发 DoDelete。
  DoDelete(LID);
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

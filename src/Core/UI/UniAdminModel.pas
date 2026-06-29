unit UniAdminModel;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Types,
  System.Generics.Collections,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Stan.Intf,
  UniContext, UniPlugin.Types;

type
  /// <summary>
  /// CRUD 状态枚举
  /// </summary>
  TCrudState = (csBrowse, csEdit, csInsert, csPendingEdit);

  /// <summary>
  /// 数据模型管理员 - 提供标准 CRUD 操作
  /// 负责管理 DataSet 的 CRUD 状态，提供标准的数据操作接口
  /// </summary>
  TUniAdminModel = class(TComponent)
  private
    FDataSet: TDataSet;
    FContext: IExecutionContext;
    FState: TCrudState;
    FOriginalValues: TDictionary<string, Variant>;
    FOnBeforePost: TNotifyEvent;
    FOnAfterPost: TNotifyEvent;
    FOnBeforeDelete: TNotifyEvent;
    FOnAfterDelete: TNotifyEvent;
    FOnStateChange: TNotifyEvent;

    procedure SetDataSet(const Value: TDataSet);
    procedure SetState(const Value: TCrudState);
    procedure SaveOriginalValues;
    procedure RestoreOriginalValues;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    /// <summary>
    /// 设置执行上下文，用于审计字段填充
    /// </summary>
    procedure SetContext(const Context: IExecutionContext);

    /// <summary>
    /// 插入新记录
    /// </summary>
    procedure Insert; virtual;

    /// <summary>
    /// 编辑当前记录
    /// </summary>
    procedure Edit; virtual;

    /// <summary>
    /// 删除当前记录
    /// </summary>
    procedure Delete; virtual;

    /// <summary>
    /// 保存当前更改
    /// </summary>
    procedure Save; virtual;

    /// <summary>
    /// 取消当前更改
    /// </summary>
    procedure Cancel; virtual;

    // 状态检查方法
    function CanEdit: Boolean;
    function CanInsert: Boolean;
    function CanDelete: Boolean;
    function CanSave: Boolean;
    function CanCancel: Boolean;
    function IsModified: Boolean;

    /// <summary>
    /// 填充审计字段（CreatedDate, CreatedBy, ModifiedDate, ModifiedBy）
    /// </summary>
    procedure FillAuditFields(const IsInsert: Boolean);

    /// <summary>
    /// 获取数据库连接
    /// </summary>
    function GetConnection: TFDCustomConnection;

    property DataSet: TDataSet read FDataSet write SetDataSet;
    property State: TCrudState read FState;
    property Context: IExecutionContext read FContext;
    property Connection: TFDCustomConnection read GetConnection;

    // 事件
    property OnBeforePost: TNotifyEvent read FOnBeforePost write FOnBeforePost;
    property OnAfterPost: TNotifyEvent read FOnAfterPost write FOnAfterPost;
    property OnBeforeDelete: TNotifyEvent read FOnBeforeDelete write FOnBeforeDelete;
    property OnAfterDelete: TNotifyEvent read FOnAfterDelete write FOnAfterDelete;
    property OnStateChange: TNotifyEvent read FOnStateChange write FOnStateChange;
  end;

implementation

uses
  uniGUIApplication, MainModule;

{ TUniAdminModel }

constructor TUniAdminModel.Create(AOwner: TComponent);
begin
  inherited;
  FState := csBrowse;
  FOriginalValues := TDictionary<string, Variant>.Create;
end;

destructor TUniAdminModel.Destroy;
begin
  FOriginalValues.Free;
  inherited;
end;

procedure TUniAdminModel.SetContext(const Context: IExecutionContext);
begin
  FContext := Context;
end;

procedure TUniAdminModel.SetDataSet(const Value: TDataSet);
begin
  FDataSet := Value;
end;

procedure TUniAdminModel.SetState(const Value: TCrudState);
begin
  if FState <> Value then
  begin
    FState := Value;
    if Assigned(FOnStateChange) then
      FOnStateChange(Self);
  end;
end;

procedure TUniAdminModel.Insert;
begin
  if not CanInsert then
    Exit;

  SaveOriginalValues;
  FDataSet.Append;
  SetState(csInsert);

  // 填充审计字段
  FillAuditFields(True);
end;

procedure TUniAdminModel.Edit;
begin
  if not CanEdit then
    Exit;

  SaveOriginalValues;
  FDataSet.Edit;
  SetState(csEdit);
end;

procedure TUniAdminModel.Delete;
begin
  if not CanDelete then
    Exit;

  if Assigned(FOnBeforeDelete) then
    FOnBeforeDelete(Self);

  FDataSet.Delete;

  if Assigned(FOnAfterDelete) then
    FOnAfterDelete(Self);
end;

procedure TUniAdminModel.Save;
begin
  if not CanSave then
    Exit;

  if Assigned(FOnBeforePost) then
    FOnBeforePost(Self);

  // 更新审计字段
  FillAuditFields(FState = csInsert);

  try
    FDataSet.Post;

    if Assigned(FOnAfterPost) then
      FOnAfterPost(Self);

    SetState(csBrowse);
    FOriginalValues.Clear;
  except
    on E: Exception do
    begin
      SetState(csBrowse);
      FOriginalValues.Clear;
      raise;
    end;
  end;
end;

procedure TUniAdminModel.Cancel;
begin
  if not CanCancel then
    Exit;

  RestoreOriginalValues;
  FDataSet.Cancel;
  SetState(csBrowse);
  FOriginalValues.Clear;
end;

function TUniAdminModel.CanEdit: Boolean;
begin
  Result := (FState = csBrowse) and Assigned(FDataSet) and not FDataSet.IsEmpty;
end;

function TUniAdminModel.CanInsert: Boolean;
begin
  Result := (FState = csBrowse) and Assigned(FDataSet);
end;

function TUniAdminModel.CanDelete: Boolean;
begin
  Result := (FState = csBrowse) and Assigned(FDataSet) and not FDataSet.IsEmpty;
end;

function TUniAdminModel.CanSave: Boolean;
begin
  Result := (FState in [csEdit, csInsert]) and Assigned(FDataSet);
end;

function TUniAdminModel.CanCancel: Boolean;
begin
  Result := (FState in [csEdit, csInsert]) and Assigned(FDataSet);
end;

function TUniAdminModel.IsModified: Boolean;
begin
  Result := (FState in [csEdit, csInsert]);
end;

procedure TUniAdminModel.SaveOriginalValues;
var
  I: Integer;
begin
  FOriginalValues.Clear;
  if not Assigned(FDataSet) then
    Exit;

  for I := 0 to FDataSet.FieldCount - 1 do
  begin
    if not FDataSet.Fields[I].ReadOnly then
      FOriginalValues.Add(FDataSet.Fields[I].FieldName, FDataSet.Fields[I].AsVariant);
  end;
end;

procedure TUniAdminModel.RestoreOriginalValues;
var
  LPair: TPair<string, Variant>;
begin
  if not Assigned(FDataSet) then
    Exit;

  for LPair in FOriginalValues do
  begin
    if FDataSet.FindField(LPair.Key) <> nil then
      FDataSet.FieldByName(LPair.Key).AsVariant := LPair.Value;
  end;
end;

procedure TUniAdminModel.FillAuditFields(const IsInsert: Boolean);
var
  LCurrentUserID: Integer;
  LCurrentTime: TDateTime;
begin
  if not Assigned(FContext) then
    Exit;

  LCurrentUserID := FContext.GetCurrentUserID;
  LCurrentTime := FContext.GetCurrentTime;

  if IsInsert then
  begin
    if FDataSet.FindField('CreatedDate') <> nil then
      FDataSet.FieldByName('CreatedDate').AsDateTime := LCurrentTime;

    if FDataSet.FindField('CreatedBy') <> nil then
      FDataSet.FieldByName('CreatedBy').AsInteger := LCurrentUserID;
  end;

  if FDataSet.FindField('ModifiedDate') <> nil then
    FDataSet.FieldByName('ModifiedDate').AsDateTime := LCurrentTime;

  if FDataSet.FindField('ModifiedBy') <> nil then
    FDataSet.FieldByName('ModifiedBy').AsInteger := LCurrentUserID;
end;

function TUniAdminModel.GetConnection: TFDCustomConnection;
var
  LMain: TMainModule;
begin
  Result := nil;

  // 优先从已绑定 DataSet 取连接（显式绑定的子类）
  if (FDataSet <> nil) and (FDataSet is TFDQuery) then
    Result := TFDQuery(FDataSet).Connection;

  // 兜底：从当前会话 MainModule 取每会话连接。
  // 多数 CRUD 子类在构造期即调用 ModelAdmin.Connection 绑定自己的 FQuery，
  // 而此时 FDataSet 尚未赋值（DoInitialize 里才赋）。若不兜底，会返回 nil，
  // 导致子类 FQuery.Connection 为 nil，Open 时抛
  // [FireDAC][Comp][Clnt]-512. Connection is not defined for [].
  // 参见 AGENTS.md 连接管理：每会话连接由 TMainModule 持有。
  if Result = nil then
  begin
    LMain := GetMainModule;
    if LMain <> nil then
      Result := LMain.Connection;
  end;
end;

end.

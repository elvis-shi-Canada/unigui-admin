unit UniModelAdmin;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Types,
  System.Generics.Collections,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet,
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
  TUniModelAdmin = class(TComponent)
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

    property DataSet: TDataSet read FDataSet write SetDataSet;
    property State: TCrudState read FState;
    property Context: IExecutionContext read FContext;

    // 事件
    property OnBeforePost: TNotifyEvent read FOnBeforePost write FOnBeforePost;
    property OnAfterPost: TNotifyEvent read FOnAfterPost write FOnAfterPost;
    property OnBeforeDelete: TNotifyEvent read FOnBeforeDelete write FOnBeforeDelete;
    property OnAfterDelete: TNotifyEvent read FOnAfterDelete write FOnAfterDelete;
    property OnStateChange: TNotifyEvent read FOnStateChange write FOnStateChange;
  end;

implementation

{ TUniModelAdmin }

constructor TUniModelAdmin.Create(AOwner: TComponent);
begin
  inherited;
  FState := csBrowse;
  FOriginalValues := TDictionary<string, Variant>.Create;
end;

destructor TUniModelAdmin.Destroy;
begin
  FOriginalValues.Free;
  inherited;
end;

procedure TUniModelAdmin.SetContext(const Context: IExecutionContext);
begin
  FContext := Context;
end;

procedure TUniModelAdmin.SetDataSet(const Value: TDataSet);
begin
  FDataSet := Value;
end;

procedure TUniModelAdmin.SetState(const Value: TCrudState);
begin
  if FState <> Value then
  begin
    FState := Value;
    if Assigned(FOnStateChange) then
      FOnStateChange(Self);
  end;
end;

procedure TUniModelAdmin.Insert;
begin
  if not CanInsert then
    Exit;

  SaveOriginalValues;
  FDataSet.Append;
  SetState(csInsert);

  // 填充审计字段
  FillAuditFields(True);
end;

procedure TUniModelAdmin.Edit;
begin
  if not CanEdit then
    Exit;

  SaveOriginalValues;
  FDataSet.Edit;
  SetState(csEdit);
end;

procedure TUniModelAdmin.Delete;
begin
  if not CanDelete then
    Exit;

  if Assigned(FOnBeforeDelete) then
    FOnBeforeDelete(Self);

  FDataSet.Delete;

  if Assigned(FOnAfterDelete) then
    FOnAfterDelete(Self);
end;

procedure TUniModelAdmin.Save;
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

procedure TUniModelAdmin.Cancel;
begin
  if not CanCancel then
    Exit;

  RestoreOriginalValues;
  FDataSet.Cancel;
  SetState(csBrowse);
  FOriginalValues.Clear;
end;

function TUniModelAdmin.CanEdit: Boolean;
begin
  Result := (FState = csBrowse) and Assigned(FDataSet) and not FDataSet.IsEmpty;
end;

function TUniModelAdmin.CanInsert: Boolean;
begin
  Result := (FState = csBrowse) and Assigned(FDataSet);
end;

function TUniModelAdmin.CanDelete: Boolean;
begin
  Result := (FState = csBrowse) and Assigned(FDataSet) and not FDataSet.IsEmpty;
end;

function TUniModelAdmin.CanSave: Boolean;
begin
  Result := (FState in [csEdit, csInsert]) and Assigned(FDataSet);
end;

function TUniModelAdmin.CanCancel: Boolean;
begin
  Result := (FState in [csEdit, csInsert]) and Assigned(FDataSet);
end;

function TUniModelAdmin.IsModified: Boolean;
begin
  Result := (FState in [csEdit, csInsert]);
end;

procedure TUniModelAdmin.SaveOriginalValues;
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

procedure TUniModelAdmin.RestoreOriginalValues;
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

procedure TUniModelAdmin.FillAuditFields(const IsInsert: Boolean);
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

end.

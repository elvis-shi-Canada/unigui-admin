unit UniDataModule;

interface

uses
  System.SysUtils, System.Classes, System.Variants,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Stan.Def,
  UniContext, UniPlugin.Types;

type
  /// <summary>
  /// 数据模块基类 - 支持上下文注入和审计字段
  /// </summary>
  TUniDataModule = class(TDataModule, IContextAware)
  private
    FContext: IExecutionContext;
    FConnection: TFDConnection;
    FOwnsConnection: Boolean;
  protected
    function GetCurrentUserID: Integer;
    function GetCurrentUserName: string;
    function GetCurrentTime: TDateTime;
    /// <summary>
    /// 设置审计字段（创建时间、创建人、修改时间、修改人）
    /// </summary>
    procedure SetAuditFields(const Query: TFDQuery; const IsInsert: Boolean); virtual;
    /// <summary>
    /// 应用数据权限范围过滤
    /// </summary>
    procedure ApplyDataScope(const Query: TFDQuery; const Resource: string); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    constructor CreateWithConnection(AOwner: TComponent; const AConnection: TFDConnection); virtual;
    destructor Destroy; override;

    /// <summary>
    /// 设置执行上下文
    /// </summary>
    procedure SetContext(const Context: IExecutionContext); virtual;
    /// <summary>
    /// 设置数据库连接
    /// </summary>
    /// <param name="Value">要设置的连接对象。如果为 nil，将创建新的空连接对象</param>
    procedure SetConnection(const Value: TFDConnection); virtual;
    /// <summary>
    /// 打开数据库连接
    /// </summary>
    procedure Open; virtual;
    /// <summary>
    /// 关闭数据库连接
    /// </summary>
    procedure Close; virtual;

    property Context: IExecutionContext read FContext;
    property Connection: TFDConnection read FConnection;
  end;

implementation

{$R *.dfm}

constructor TUniDataModule.Create(AOwner: TComponent);
begin
  inherited;
  // 创建连接组件（默认拥有所有权）
  FOwnsConnection := True;
  FConnection := TFDConnection.Create(nil);
end;

constructor TUniDataModule.CreateWithConnection(AOwner: TComponent; const AConnection: TFDConnection);
begin
  inherited Create(AOwner);
  if Assigned(AConnection) then
  begin
    // 共享外部连接，不拥有所有权
    FOwnsConnection := False;
    FConnection := AConnection;
  end
  else
  begin
    // 未提供连接时，创建自己的连接
    FOwnsConnection := True;
    FConnection := TFDConnection.Create(nil);
  end;
end;

destructor TUniDataModule.Destroy;
begin
  if FOwnsConnection and Assigned(FConnection) then
  begin
    if FConnection.Connected then
      FConnection.Connected := False;
    FreeAndNil(FConnection);
  end;
  FConnection := nil;
  inherited;
end;

procedure TUniDataModule.SetContext(const Context: IExecutionContext);
begin
  FContext := Context;
end;

function TUniDataModule.GetCurrentUserID: Integer;
begin
  if Assigned(FContext) then
    Result := FContext.GetCurrentUserID
  else
    Result := 0;
end;

function TUniDataModule.GetCurrentUserName: string;
begin
  if Assigned(FContext) then
    Result := FContext.GetCurrentUserName
  else
    Result := '';
end;

function TUniDataModule.GetCurrentTime: TDateTime;
begin
  if Assigned(FContext) then
    Result := FContext.GetCurrentTime
  else
    Result := Now;
end;

procedure TUniDataModule.SetConnection(const Value: TFDConnection);
begin
  if Assigned(FConnection) and (FConnection <> Value) then
  begin
    if FConnection.Connected then
      FConnection.Connected := False;
    FreeAndNil(FConnection);
  end;

  if Assigned(Value) then
    FConnection := Value
  else
    FConnection := TFDConnection.Create(nil);
end;

procedure TUniDataModule.SetAuditFields(const Query: TFDQuery; const IsInsert: Boolean);
begin
  if not Assigned(Query) then
    Exit;

  // 自动填充审计字段
  if Query.FindField('CreatedDate') <> nil then
    Query.FieldByName('CreatedDate').AsDateTime := GetCurrentTime;

  if Query.FindField('CreatedBy') <> nil then
    Query.FieldByName('CreatedBy').AsInteger := GetCurrentUserID;

  if not IsInsert then
  begin
    if Query.FindField('ModifiedDate') <> nil then
      Query.FieldByName('ModifiedDate').AsDateTime := GetCurrentTime;

    if Query.FindField('ModifiedBy') <> nil then
      Query.FieldByName('ModifiedBy').AsInteger := GetCurrentUserID;
  end;
end;

procedure TUniDataModule.ApplyDataScope(const Query: TFDQuery; const Resource: string);
begin
  if not Assigned(Query) then
    Exit;
  // 应用数据权限过滤
  // TODO: 实现数据范围过滤逻辑
end;

procedure TUniDataModule.Open;
begin
  if not FConnection.Connected then
  try
    FConnection.Connected := True;
  except
    on E: Exception do
      raise Exception.CreateFmt('无法连接到数据库: %s', [E.Message]);
  end;
end;

procedure TUniDataModule.Close;
begin
  if Assigned(FConnection) and FConnection.Connected then
    FConnection.Connected := False;
end;

end.

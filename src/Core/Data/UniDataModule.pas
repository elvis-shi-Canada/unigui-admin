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
    function GetCurrentUserID: Integer;
    function GetCurrentUserName: string;
    function GetCurrentTime: TDateTime;
  protected
    /// <summary>
    /// 设置数据库连接
    /// </summary>
    procedure SetConnection(const Value: TFDConnection); virtual;
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
    destructor Destroy; override;

    /// <summary>
    /// 设置执行上下文
    /// </summary>
    procedure SetContext(const Context: IExecutionContext); virtual;
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
  // 创建连接组件
  FConnection := TFDConnection.Create(nil);
end;

destructor TUniDataModule.Destroy;
begin
  Close;
  FConnection.Free;
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
  FConnection := Value;
end;

procedure TUniDataModule.SetAuditFields(const Query: TFDQuery; const IsInsert: Boolean);
begin
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
  // 应用数据权限过滤
  // TODO: 实现数据范围过滤逻辑
end;

procedure TUniDataModule.Open;
begin
  if not FConnection.Connected then
    FConnection.Connected := True;
end;

procedure TUniDataModule.Close;
begin
  FConnection.Connected := False;
end;

end.

unit AutoCrudFrame;

interface

uses
  System.SysUtils, System.Classes,
  Data.DB, FireDAC.Comp.Client,
  uniGUIBaseClasses, uniGUIClasses, uniEdit, uniButton, uniBasicGrid, uniDBGrid,
  uniPanel, uniGUIFrame,
  UniContext, UniPlugin.Types,
  BaseCrudFrame, UniAdminModel,
  UniModelAdmin.Intf, UniModelAdmin, UniQueryBuilder;

type
  /// <summary>
  /// 零样板的声明式 CRUD Frame
  /// 子类（或路由器）只需调用 BindAdmin(AdminID)，引擎自动：
  ///   1. 从 IModelAdminRegistry 读取声明
  ///   2. 开启 AutoGridFromMeta，从元数据派生网格列
  ///   3. 用 TQueryClauseBuilder 生成参数化列表查询
  ///   4. 继承 TBaseCrudFrame 的权限/按钮状态/审计能力
  /// </summary>
  TAutoCrudFrame = class(TBaseCrudFrame)
    pnlToolbar: TUniPanel;
    btnAdd: TUniButton;
    btnEdit: TUniButton;
    btnDelete: TUniButton;
    btnRefresh: TUniButton;
    edtSearch: TUniEdit;
    // 注意：不重新声明 UniDBGrid / UniDataSource —— 它们已在 TBaseCrudFrame
    // 中作为 protected 字段存在。子类若重新声明会"隐藏"基类字段，
    // 导致 BuildGridFromMetadata/Refresh 等基类方法引用基类 nil 字段（而非
    // DFM 实例化的子类字段），AutoGridFromMeta 会静默失效。
    // DFM 事件处理方法必须在 published 区（默认可见性），否则 DFM 流读取器经 RTTI 找不到
    procedure btnRefreshClick(Sender: TObject);
    procedure edtSearchKeyPress(Sender: TObject; var Key: Char);
  private
    FAdminID: string;
    FAdminConfig: TModelAdmin;
    FQuery: TFDQuery;

    procedure ApplyAdminConfig(const AAdminID: string);
  protected
    procedure DoInitialize; override;
    procedure DoRefresh; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    /// <summary>绑定声明配置：读取 IModelAdminRegistry 中的声明并开启派生</summary>
    procedure BindAdmin(const AAdminID: string);

    property AdminID: string read FAdminID;
    property AdminConfig: TModelAdmin read FAdminConfig;
  end;

implementation

{$R *.dfm}

{ TAutoCrudFrame }

constructor TAutoCrudFrame.Create(AOwner: TComponent);
begin
  inherited;
  // FModelAdmin 已在基类构造中创建
  FQuery := TFDQuery.Create(Self);
  // 与 UserListFrame 一致：共享 MainModule 的会话连接
  FQuery.Connection := ModelAdmin.Connection;
end;

destructor TAutoCrudFrame.Destroy;
begin
  // 与 UserListFrame 一致的释放顺序：先断连接引用，避免悬空
  // （FQuery.Connection 引用 MainModule.Connection，若先释放 MainModule 会触发 EInvalidPointer）
  FQuery.Connection := nil;
  FQuery.Free;
  inherited;
end;

procedure TAutoCrudFrame.ApplyAdminConfig(const AAdminID: string);
var
  LRegistry: IModelAdminRegistry;
begin
  FAdminID := AAdminID;
  LRegistry := TModelAdminRegistry.CreateInstance;
  if not LRegistry.Find(AAdminID, FAdminConfig) then
    raise Exception.CreateFmt('AdminID "%s" 未在注册中心声明', [AAdminID]);

  // 开启声明式派生
  AutoGridFromMeta := True;
  ModelTableName := FAdminConfig.TableName;
  PermissionPrefix := FAdminConfig.PermissionPrefix;
end;

procedure TAutoCrudFrame.BindAdmin(const AAdminID: string);
begin
  ApplyAdminConfig(AAdminID);
end;

procedure TAutoCrudFrame.DoInitialize;
begin
  // 先让基类从元数据派生网格列（需要 MetadataCache 已就绪）
  inherited;  // 触发 BuildGridFromMetadata

  // 绑定数据源（UniDBGrid/UniDataSource 是继承自基类的字段）
  UniDataSource.DataSet := FQuery;
  UniDBGrid.DataSource := UniDataSource;

  // 把工具栏按钮挂到基类字段，使 CheckPermissions/UpdateButtonStates 生效
  Self.BtnAdd := btnAdd;
  Self.BtnEdit := btnEdit;
  Self.BtnDelete := btnDelete;
  Self.BtnRefresh := btnRefresh;
end;

procedure TAutoCrudFrame.DoRefresh;
var
  LBuilder: TQueryClauseBuilder;
  LSQL: string;
  LParamName: string;
  I: Integer;
begin
  if FAdminConfig.TableName = '' then
    Exit; // 未 BindAdmin，无数据可刷新

  if FQuery.Active then
    FQuery.Close;

  LBuilder := TQueryClauseBuilder.Create;
  try
    if (Length(FAdminConfig.SearchFields) > 0) and (Trim(edtSearch.Text) <> '') then
      LBuilder.AddLikeAny(FAdminConfig.SearchFields, 'Filter');

    LSQL := LBuilder.SelectFrom(FAdminConfig.TableName);
    // 追加排序：若声明有主键则用之，否则按第一列倒序
    LSQL := LSQL + ' ORDER BY 1 DESC';
    FQuery.SQL.Text := LSQL;

    for I := 0 to LBuilder.ParamCount - 1 do
    begin
      LParamName := LBuilder.ParamName(I);
      FQuery.ParamByName(LParamName).AsString := '%' + Trim(edtSearch.Text) + '%';
    end;

    FQuery.Open;
  finally
    LBuilder.Free;
  end;
end;

procedure TAutoCrudFrame.btnRefreshClick(Sender: TObject);
begin
  Refresh;
end;

procedure TAutoCrudFrame.edtSearchKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    Refresh;
end;

initialization
  // 数据驱动路由必需：RoutePath 中的类名经 GetClass 解析
  RegisterClass(TAutoCrudFrame);

end.

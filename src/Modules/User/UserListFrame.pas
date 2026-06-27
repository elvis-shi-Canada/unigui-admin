unit UserListFrame;

interface

uses
  System.SysUtils, System.Classes, System.Variants,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param,
  uniGUIBaseClasses, uniGUIClasses, uniGUImClasses, uniEdit, uniButton,
  uniBasicGrid, uniDBGrid, uniToolBar,
  UniContext, UniPlugin.Types,
  BaseCrudFrame, Vcl.Controls, Vcl.Forms;

type
  /// <summary>
  /// 用户列表窗体 - 声明式重构示例
  /// 网格列由元数据自动派生，查询由 TQueryClauseBuilder 生成，
  /// 菜单/权限由 TModelAdminRegistry 声明驱动（见本单元 initialization 段）。
  /// </summary>
  TUserListFrame = class(TBaseCrudFrame)
    // 注意：不再重新声明 UniDBGrid / UniDataSource —— 它们继承自基类
    // （重新声明会隐藏基类字段，使 BuildGridFromMetadata 引用基类 nil 字段而失效）
    edtSearch: TUniEdit;
    cmbStatus: TUniEdit;
    btnSearch: TUniButton;

    procedure DoInitialize; override;
    procedure DoFinalize; override;
    procedure DoRefresh; override;

    procedure btnSearchClick(Sender: TObject);
    procedure edtSearchKeyPress(Sender: TObject; var Key: Char);
  private
    FQuery: TFDQuery;
    procedure LoadUsers;
    procedure ApplyFilter;
    function ParseStatusFilter(const AText: string): Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

uses
  UniModelAdmin.Intf, UniModelAdmin, UniQueryBuilder;

{$R *.dfm}

constructor TUserListFrame.Create(AOwner: TComponent);
begin
  inherited;
  FPermissionPrefix := 'user';

  FQuery := TFDQuery.Create(Self);
  FQuery.Connection := ModelAdmin.Connection;
end;

destructor TUserListFrame.Destroy;
begin
  // Disconnect first: FQuery.Connection references MainModule.Connection.
  // If MainModule is destroyed before this frame, FQuery.Free would touch
  // a dangling pointer and raise EInvalidPointer on shutdown.
  FQuery.Connection := nil;
  FQuery.Free;
  inherited;
end;

procedure TUserListFrame.DoInitialize;
begin
  // 开启声明式网格派生：从 UniAdmin_Users 元数据自动建列。
  // 必须在 inherited 之前设置开关，这样 inherited 触发的
  // BuildGridFromMetadata 才能看到 AutoGridFromMeta=True。
  AutoGridFromMeta := True;
  ModelTableName := 'UniAdmin_Users';

  inherited;

  // 设置数据源
  UniDataSource.DataSet := FQuery;

  // 初始化状态筛选
  cmbStatus.Text := '全部';
end;

procedure TUserListFrame.DoFinalize;
begin
  if FQuery.Active then
    FQuery.Close;
  inherited;
end;

procedure TUserListFrame.DoRefresh;
begin
  inherited;
  LoadUsers;
end;

function TUserListFrame.ParseStatusFilter(const AText: string): Integer;
begin
  if AText = '启用' then
    Result := 1
  else if AText = '禁用' then
    Result := 0
  else
    Result := -1;  // 全部
end;

procedure TUserListFrame.LoadUsers;
var
  LBuilder: TQueryClauseBuilder;
  LSQL: string;
  LFilter: string;
  LStatus: Integer;
  I: Integer;
begin
  LFilter := Trim(edtSearch.Text);
  LStatus := ParseStatusFilter(cmbStatus.Text);

  LBuilder := TQueryClauseBuilder.Create;
  try
    if LFilter <> '' then
      LBuilder.AddLikeAny(['UserName', 'RealName', 'Email'], 'Filter');
    if LStatus >= 0 then
      LBuilder.AddEqual('Status', 'Status');

    LSQL := LBuilder.SelectFrom('UniAdmin_Users') + ' ORDER BY UserID DESC';

    if FQuery.Active then
      FQuery.Close;
    FQuery.SQL.Text := LSQL;

    for I := 0 to LBuilder.ParamCount - 1 do
    begin
      if SameText(LBuilder.ParamName(I), 'Filter0') then
        FQuery.ParamByName('Filter0').AsString := '%' + LFilter + '%'
      else if SameText(LBuilder.ParamName(I), 'Status') then
        FQuery.ParamByName('Status').AsInteger := LStatus;
    end;

    FQuery.Open;
  finally
    LBuilder.Free;
  end;
end;

procedure TUserListFrame.ApplyFilter;
begin
  LoadUsers;
end;

procedure TUserListFrame.btnSearchClick(Sender: TObject);
begin
  ApplyFilter;
end;

procedure TUserListFrame.edtSearchKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    ApplyFilter;
end;

initialization
  // 声明式注册：UserListFrame 的菜单/权限由 ModelAdminRegistry 驱动
  // （SystemMenuSetup.BuildMenusFromRegistry 会读取此声明）
  TModelAdminRegistry.CreateInstance.Register(
    TModelAdmin.Create('user', 'UniAdmin_Users', '用户管理')
      .WithFrame('TUserListFrame')
      .WithListDisplay([
        TAdminFieldConfig.Create('UserID', 'ID', 50),
        TAdminFieldConfig.Create('UserName', '用户名', 100),
        TAdminFieldConfig.Create('RealName', '真实姓名', 100),
        TAdminFieldConfig.Create('Email', '邮箱', 150),
        TAdminFieldConfig.Create('Phone', '手机', 100),
        TAdminFieldConfig.Create('Status', '状态', 60),
        TAdminFieldConfig.Create('LastLoginDate', '最后登录', 120)
      ])
      .WithSearchFields(['UserName', 'RealName', 'Email'])
      .WithFilterFields(['Status'])
      .WithPermissionPrefix('user')
      .WithSortOrder(110)
      .WithParentMenuCode('system')
  );

  // Register for FindClass-driven MDI routing (UniAdmin_Menus.RoutePath -> frame)
  RegisterClass(TUserListFrame);

end.

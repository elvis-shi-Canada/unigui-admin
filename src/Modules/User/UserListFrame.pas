unit UserListFrame;

interface

uses
  System.SysUtils, System.Classes, System.Variants,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param,
  uniGUIBaseClasses, uniGUIClasses, uniGUImClasses, uniEdit, uniButton,  uniBasicGrid, uniDBGrid, uniToolBar,
  UniContext, UniPlugin.Types,
  BaseCrudFrame, Vcl.Controls, Vcl.Forms;

type
  /// <summary>
  /// 用户列表窗体 - 继承自 TBaseCrudFrame
  /// </summary>
  TUserListFrame = class(TBaseCrudFrame)
    UniDBGrid: TUniDBGrid;
    UniDataSource: TDataSource;
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
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

constructor TUserListFrame.Create(AOwner: TComponent);
begin
  inherited;
  FPermissionPrefix := 'user';
  
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := ModelAdmin.Connection;
end;

destructor TUserListFrame.Destroy;
begin
  FQuery.Free;
  inherited;
end;

procedure TUserListFrame.DoInitialize;
begin
  inherited;
  
  // 设置数据源
  UniDataSource.DataSet := FQuery;
  
  // 初始化状态筛选
  cmbStatus.Text := '全部';
  
  // 设置网格列
  if UniDBGrid.Columns.Count = 0 then
  begin
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'UserID';
      Title.Caption := 'ID';
      Width := 50;
    end;
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'UserName';
      Title.Caption := '用户名';
      Width := 100;
    end;
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'RealName';
      Title.Caption := '真实姓名';
      Width := 100;
    end;
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'Email';
      Title.Caption := '邮箱';
      Width := 150;
    end;
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'Phone';
      Title.Caption := '手机';
      Width := 100;
    end;
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'Status';
      Title.Caption := '状态';
      Width := 60;
    end;
    with UniDBGrid.Columns.Add do
    begin
      FieldName := 'LastLoginDate';
      Title.Caption := '最后登录';
      Width := 120;
    end;
  end;
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

procedure TUserListFrame.LoadUsers;
var
  LSQL: string;
  LFilter: string;
  LStatus: Integer;
  LWhereParts: TStringList;
begin
  LSQL := 'SELECT UserID, UserName, RealName, Email, Phone, Status, LastLoginDate ' +
          'FROM UniAdmin_Users';
  
  LFilter := Trim(edtSearch.Text);
  LWhereParts := TStringList.Create;
  try
    // 搜索条件
    if LFilter <> '' then
      LWhereParts.Add('(UserName LIKE :Filter OR RealName LIKE :Filter OR Email LIKE :Filter)');
    
    // 状态筛选
    if cmbStatus.Text = '启用' then
      LStatus := 1
    else if cmbStatus.Text = '禁用' then
      LStatus := 0
    else
      LStatus := -1;
      
    if LStatus >= 0 then
      LWhereParts.Add('Status = :Status');
    
    // 构建 WHERE 子句
    if LWhereParts.Count > 0 then
      LSQL := LSQL + ' WHERE ' + LWhereParts.Text.Replace(#13#10, ' AND ');
    
    LSQL := LSQL + ' ORDER BY UserID DESC';
    
    // 执行查询
    if FQuery.Active then
      FQuery.Close;
      
    FQuery.SQL.Text := LSQL;
    
    if LFilter <> '' then
      FQuery.ParamByName('Filter').AsString := '%' + LFilter + '%';
      
    if LStatus >= 0 then
      FQuery.ParamByName('Status').AsInteger := LStatus;
    
    FQuery.Open;
  finally
    LWhereParts.Free;
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

end.

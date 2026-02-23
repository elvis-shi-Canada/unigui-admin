unit PluginManagerFrame;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Grids,
  UniModuleRegistry.Intf, UniConfigService.Intf;

type
  /// <summary>
  /// 插件管理框架
  /// 提供插件的可视化管理界面
  /// </summary>
  TPluginManagerFrame = class(TFrame)
    pnlToolBar: TPanel;
    btnLoad: TButton;
    btnUnload: TButton;
    btnRefresh: TButton;
    pnlMain: TPanel;
    pnlLeft: TPanel;
    pnlRight: TPanel;
    lbPlugins: TListBox;
    splVertical: TSplitter;
    grpPluginInfo: TPanel;
    lblPluginID: TLabel;
    lblPluginIDValue: TLabel;
    lblDisplayName: TLabel;
    lblDisplayNameValue: TLabel;
    lblVersion: TLabel;
    lblVersionValue: TLabel;
    lblAuthor: TLabel;
    lblAuthorValue: TLabel;
    lblCategory: TLabel;
    lblCategoryValue: TLabel;
    lblDescription: TLabel;
    memDescription: TMemo;
    grpDependencies: TPanel;
    grdDependencies: TStringGrid;
    grpDependents: TPanel;
    grdDependents: TStringGrid;
    StatusBar: TStatusBar;
    procedure btnLoadClick(Sender: TObject);
    procedure btnUnloadClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure lbPluginsClick(Sender: TObject);
  private
    FRegistry: IUniModuleRegistry;
    FConfigService: IUniConfigService;
    FPluginIDs: TArray<string>;
    FCurrentPluginID: string;
    FLoadedPlugins: TList<string>;

    procedure InitializeUI;
    procedure LoadPluginsList;
    procedure DisplayPluginDetails(const PluginID: string);
    procedure DisplayDependencies(const PluginID: string);
    procedure DisplayDependents(const PluginID: string);
    function GetSelectedPluginID: string;
    function IsPluginLoaded(const PluginID: string): Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetRegistry(const ARegistry: IUniModuleRegistry);
    procedure SetConfigService(const AConfigService: IUniConfigService);
    procedure RefreshUI;
  end;

implementation

{$R *.dfm}

{ TPluginManagerFrame }

constructor TPluginManagerFrame.Create(AOwner: TComponent);
begin
  inherited;
  FLoadedPlugins := TList<string>.Create;
  InitializeUI;
end;

destructor TPluginManagerFrame.Destroy;
begin
  FLoadedPlugins.Free;
  inherited;
end;

procedure TPluginManagerFrame.SetRegistry(const ARegistry: IUniModuleRegistry);
begin
  FRegistry := ARegistry;
  RefreshUI;
end;

procedure TPluginManagerFrame.SetConfigService(const AConfigService: IUniConfigService);
begin
  FConfigService := AConfigService;
end;

procedure TPluginManagerFrame.InitializeUI;
begin
  // 初始化插件列表
  lbPlugins.Clear;

  // 初始化依赖关系网格
  with grdDependencies do
  begin
    ColCount := 4;
    RowCount := 2;
    FixedRows := 1;
    Cells[0, 0] := '依赖插件ID';
    Cells[1, 0] := '依赖类型';
    Cells[2, 0] := '最小版本';
    Cells[3, 0] := '状态';

    ColWidths[0] := 150;
    ColWidths[1] := 100;
    ColWidths[2] := 100;
    ColWidths[3] := 80;
  end;

  // 初始化反向依赖网格
  with grdDependents do
  begin
    ColCount := 2;
    RowCount := 2;
    FixedRows := 1;
    Cells[0, 0] := '被依赖插件ID';
    Cells[1, 0] := '状态';

    ColWidths[0] := 200;
    ColWidths[1] := 80;
  end;

  StatusBar.SimplePanel := True;
  StatusBar.SimpleText := '就绪';
end;

procedure TPluginManagerFrame.LoadPluginsList;
var
  I: Integer;
begin
  if not Assigned(FRegistry) then
    Exit;

  lbPlugins.Clear;
  FPluginIDs := FRegistry.GetAllPluginIDs;

  for I := 0 to High(FPluginIDs) do
  begin
    if IsPluginLoaded(FPluginIDs[I]) then
      lbPlugins.Items.Add('[已加载] ' + FPluginIDs[I])
    else
      lbPlugins.Items.Add(FPluginIDs[I]);
  end;

  StatusBar.SimpleText := Format('共 %d 个插件', [Length(FPluginIDs)]);
end;

function TPluginManagerFrame.GetSelectedPluginID: string;
var
  LSelectedText: string;
begin
  Result := '';

  if lbPlugins.ItemIndex < 0 then
    Exit;

  LSelectedText := lbPlugins.Items[lbPlugins.ItemIndex];

  // 移除 [已加载] 前缀
  if StartsText('[已加载] ', LSelectedText) then
    Result := Copy(LSelectedText, 7, Length(LSelectedText))
  else
    Result := LSelectedText;
end;

function TPluginManagerFrame.IsPluginLoaded(const PluginID: string): Boolean;
begin
  Result := FLoadedPlugins.Contains(PluginID);
end;

procedure TPluginManagerFrame.DisplayPluginDetails(const PluginID: string);
var
  LInfo: TPluginClassInfo;
begin
  if not FRegistry.IsPluginRegistered(PluginID) then
  begin
    lblPluginIDValue.Caption := '-';
    lblDisplayNameValue.Caption := '-';
    lblVersionValue.Caption := '-';
    lblAuthorValue.Caption := '-';
    lblCategoryValue.Caption := '-';
    memDescription.Lines.Clear;
    Exit;
  end;

  LInfo := FRegistry.GetPluginClassInfo(PluginID);

  lblPluginIDValue.Caption := LInfo.PluginID;
  lblDisplayNameValue.Caption := LInfo.DisplayName;
  lblVersionValue.Caption := LInfo.Version;
  lblAuthorValue.Caption := LInfo.Author;
  lblCategoryValue.Caption := LInfo.Category;
  memDescription.Lines.Text := LInfo.Description;
end;

procedure TPluginManagerFrame.DisplayDependencies(const PluginID: string);
var
  LDependencies: TArray<string>;
  I, Row: Integer;
  LIsRegistered: Boolean;
begin
  if not FRegistry.IsPluginRegistered(PluginID) then
  begin
    grdDependencies.RowCount := 2;
    Exit;
  end;

  LDependencies := FRegistry.GetDependencies(PluginID);

  with grdDependencies do
  begin
    if Length(LDependencies) = 0 then
    begin
      RowCount := 2;
      Cells[0, 1] := '(无依赖)';
      Cells[1, 1] := '';
      Cells[2, 1] := '';
      Cells[3, 1] := '';
    end
    else
    begin
      RowCount := Length(LDependencies) + 2;

      for I := 0 to High(LDependencies) do
      begin
        Row := I + 1;
        LIsRegistered := FRegistry.IsPluginRegistered(LDependencies[I]);

        Cells[0, Row] := LDependencies[I];
        Cells[1, Row] := '强依赖';
        Cells[2, Row] := '-';

        if LIsRegistered then
          Cells[3, Row] := '已注册'
        else
          Cells[3, Row] := '未注册';
      end;
    end;
  end;
end;

procedure TPluginManagerFrame.DisplayDependents(const PluginID: string);
var
  LDependents: TArray<string>;
  I, Row: Integer;
  LIsRegistered: Boolean;
begin
  if not FRegistry.IsPluginRegistered(PluginID) then
  begin
    grdDependents.RowCount := 2;
    Exit;
  end;

  LDependents := FRegistry.GetDependents(PluginID);

  with grdDependents do
  begin
    if Length(LDependents) = 0 then
    begin
      RowCount := 2;
      Cells[0, 1] := '(无被依赖插件)';
      Cells[1, 1] := '';
    end
    else
    begin
      RowCount := Length(LDependents) + 2;

      for I := 0 to High(LDependents) do
      begin
        Row := I + 1;
        LIsRegistered := FRegistry.IsPluginRegistered(LDependents[I]);

        Cells[0, Row] := LDependents[I];

        if LIsRegistered then
          Cells[1, Row] := '已注册'
        else
          Cells[1, Row] := '未注册';
      end;
    end;
  end;
end;

procedure TPluginManagerFrame.RefreshUI;
begin
  LoadPluginsList;

  if FCurrentPluginID <> '' then
  begin
    DisplayPluginDetails(FCurrentPluginID);
    DisplayDependencies(FCurrentPluginID);
    DisplayDependents(FCurrentPluginID);
  end;

  StatusBar.SimpleText := '刷新完成 - ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);
end;

procedure TPluginManagerFrame.lbPluginsClick(Sender: TObject);
begin
  FCurrentPluginID := GetSelectedPluginID;

  if FCurrentPluginID <> '' then
  begin
    DisplayPluginDetails(FCurrentPluginID);
    DisplayDependencies(FCurrentPluginID);
    DisplayDependents(FCurrentPluginID);
  end;
end;

procedure TPluginManagerFrame.btnLoadClick(Sender: TObject);
var
  LPluginID: string;
  LInfo: TPluginClassInfo;
  LMissingPlugins: TArray<string>;
begin
  LPluginID := GetSelectedPluginID;

  if LPluginID = '' then
  begin
    ShowMessage('请先选择要加载的插件');
    Exit;
  end;

  if IsPluginLoaded(LPluginID) then
  begin
    ShowMessage('插件已加载');
    Exit;
  end;

  // 验证依赖
  if not FRegistry.ValidateDependencies(LMissingPlugins) then
  begin
    ShowMessage(Format('无法加载插件：缺少依赖插件 %s', [String.Join(', ', LMissingPlugins)]));
    Exit;
  end;

  // 模拟加载插件（实际需要与插件加载器集成）
  FLoadedPlugins.Add(LPluginID);

  // 更新插件状态
  LInfo := FRegistry.GetPluginClassInfo(LPluginID);
  LInfo.IsLoaded := True;

  RefreshUI;
  StatusBar.SimpleText := Format('插件 %s 已加载', [LPluginID]);
end;

procedure TPluginManagerFrame.btnUnloadClick(Sender: TObject);
var
  LPluginID: string;
  LDependents: TArray<string>;
begin
  LPluginID := GetSelectedPluginID;

  if LPluginID = '' then
  begin
    ShowMessage('请先选择要卸载的插件');
    Exit;
  end;

  if not IsPluginLoaded(LPluginID) then
  begin
    ShowMessage('插件未加载');
    Exit;
  end;

  // 检查是否有其他插件依赖此插件
  LDependents := FRegistry.GetDependents(LPluginID);
  if Length(LDependents) > 0 then
  begin
    ShowMessage(Format('无法卸载插件：以下插件依赖于此插件 %s', [String.Join(', ', LDependents)]));
    Exit;
  end;

  if MessageDlg(Format('确定要卸载插件 %s 吗？', [LPluginID]),
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  // 模拟卸载插件
  FLoadedPlugins.Remove(LPluginID);

  RefreshUI;
  StatusBar.SimpleText := Format('插件 %s 已卸载', [LPluginID]);
end;

procedure TPluginManagerFrame.btnRefreshClick(Sender: TObject);
begin
  RefreshUI;
end;

end.

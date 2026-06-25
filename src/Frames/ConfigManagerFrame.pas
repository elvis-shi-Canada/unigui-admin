unit ConfigManagerFrame;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Grids,
  UniAdminConfigService.Intf;

type
  /// <summary>
  /// 配置管理框架
  /// 提供配置的可视化管理界面
  /// </summary>
  TConfigManagerFrame = class(TFrame)
    pnlToolBar: TPanel;
    cboModules: TComboBox;
    lblModule: TLabel;
    btnLoad: TButton;
    btnSave: TButton;
    btnRefresh: TButton;
    pnlMain: TPanel;
    pnlConfig: TPanel;
    grdConfig: TStringGrid;
    pnlEdit: TPanel;
    lblKey: TLabel;
    edtKey: TEdit;
    lblValue: TLabel;
    edtValue: TEdit;
    lblType: TLabel;
    cboType: TComboBox;
    btnAdd: TButton;
    btnUpdate: TButton;
    btnDelete: TButton;
    StatusBar: TStatusBar;
    procedure cboModulesChange(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure grdConfigSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
  private
    FConfigService: IUniAdminConfigService;
    FCurrentModuleConfig: IModuleConfig;
    FCurrentModuleName: string;
    FConfigKeys: TArray<string>;
    FConfigTypes: TDictionary<string, TConfigValueType>;

    procedure InitializeUI;
    procedure LoadModules;
    procedure LoadConfig(const ModuleName: string);
    procedure DisplayConfig;
    procedure ClearEditPanel;
    function GetSelectedKey: string;
    procedure EnableEditPanel(const Enable: Boolean);
    function ValueTypeToString(const ValueType: TConfigValueType): string;
    function StringToValueType(const Value: string): TConfigValueType;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetConfigService(const AConfigService: IUniAdminConfigService);
    procedure RefreshUI;
  end;

implementation

{$R *.dfm}

{ TConfigManagerFrame }

constructor TConfigManagerFrame.Create(AOwner: TComponent);
begin
  inherited;
  FConfigTypes := TDictionary<string, TConfigValueType>.Create;
  InitializeUI;
end;

destructor TConfigManagerFrame.Destroy;
begin
  FConfigTypes.Free;
  inherited;
end;

procedure TConfigManagerFrame.SetConfigService(const AConfigService: IUniAdminConfigService);
begin
  FConfigService := AConfigService;
  LoadModules;
end;

procedure TConfigManagerFrame.InitializeUI;
begin
  // 初始化模块选择器
  cboModules.Clear;

  // 初始化配置类型选择器
  cboType.Clear;
  cboType.Items.Add('字符串');
  cboType.Items.Add('整数');
  cboType.Items.Add('布尔');
  cboType.Items.Add('浮点数');
  cboType.Items.Add('日期时间');
  cboType.Items.Add('字符串列表');
  cboType.ItemIndex := 0;

  // 初始化配置网格
  with grdConfig do
  begin
    ColCount := 3;
    RowCount := 2;
    FixedRows := 1;
    Cells[0, 0] := '配置键';
    Cells[1, 0] := '配置值';
    Cells[2, 0] := '类型';

    ColWidths[0] := 200;
    ColWidths[1] := 250;
    ColWidths[2] := 100;
  end;

  ClearEditPanel;
  EnableEditPanel(False);

  StatusBar.SimplePanel := True;
  StatusBar.SimpleText := '就绪';
end;

procedure TConfigManagerFrame.LoadModules;
var
  LModules: TArray<string>;
  I: Integer;
begin
  if not Assigned(FConfigService) then
    Exit;

  cboModules.Clear;
  cboModules.Items.Add('(全局配置)');

  LModules := FConfigService.GetAllModuleNames;
  for I := 0 to High(LModules) do
    cboModules.Items.Add(LModules[I]);

  if cboModules.Items.Count > 0 then
    cboModules.ItemIndex := 0;
end;

procedure TConfigManagerFrame.LoadConfig(const ModuleName: string);
begin
  if not Assigned(FConfigService) then
    Exit;

  FCurrentModuleName := ModuleName;

  if ModuleName = '(全局配置)' then
  begin
    // 全局配置通过 FConfigService 直接访问
    FCurrentModuleConfig := nil;
    StatusBar.SimpleText := '已选择全局配置';
  end
  else
  begin
    FCurrentModuleConfig := FConfigService.GetModuleConfig(ModuleName);
    StatusBar.SimpleText := Format('已选择模块配置: %s', [ModuleName]);
  end;

  DisplayConfig;
end;

procedure TConfigManagerFrame.DisplayConfig;
var
  LKeys: TArray<string>;
  I, Row: Integer;
  LValueType: TConfigValueType;
  LValue: Variant;
  LTypeStr: string;
begin
  FConfigTypes.Clear;

  if FCurrentModuleName = '(全局配置)' then
  begin
    // 显示全局配置占位
    grdConfig.RowCount := 2;
    grdConfig.Cells[0, 1] := '(请使用全局配置服务访问)';
    grdConfig.Cells[1, 1] := '';
    grdConfig.Cells[2, 1] := '';
    Exit;
  end;

  if not Assigned(FCurrentModuleConfig) then
  begin
    grdConfig.RowCount := 2;
    grdConfig.Cells[0, 1] := '(未加载配置)';
    grdConfig.Cells[1, 1] := '';
    grdConfig.Cells[2, 1] := '';
    Exit;
  end;

  LKeys := FCurrentModuleConfig.GetAllKeys;
  FConfigKeys := LKeys;

  if Length(LKeys) = 0 then
  begin
    grdConfig.RowCount := 2;
    grdConfig.Cells[0, 1] := '(配置为空)';
    grdConfig.Cells[1, 1] := '';
    grdConfig.Cells[2, 1] := '';
    Exit;
  end;

  grdConfig.RowCount := Length(LKeys) + 2;

  for I := 0 to High(LKeys) do
  begin
    Row := I + 1;
    grdConfig.Cells[0, Row] := LKeys[I];

    // 获取值和类型
    case FConfigService.GetGlobalInteger('debug.' + LKeys[I], 0) of
      0: begin
           LValue := FCurrentModuleConfig.GetString(LKeys[I]);
           LValueType := cvtString;
         end;
      1: begin
           LValue := FCurrentModuleConfig.GetInteger(LKeys[I]);
           LValueType := cvtInteger;
         end;
      2: begin
           LValue := FCurrentModuleConfig.GetBoolean(LKeys[I]);
           LValueType := cvtBoolean;
           if LValue then
             LValue := 'True'
           else
             LValue := 'False';
         end;
      3: begin
           LValue := FCurrentModuleConfig.GetFloat(LKeys[I]);
           LValueType := cvtFloat;
         end;
      4: begin
           LValue := FCurrentModuleConfig.GetDateTime(LKeys[I]);
           LValueType := cvtDateTime;
           if LValue <> 0 then
             LValue := FormatDateTime('yyyy-mm-dd hh:nn:ss', TDateTime(LValue))
           else
             LValue := '';
         end;
      else
        begin
          LValue := FCurrentModuleConfig.GetString(LKeys[I]);
          LValueType := cvtString;
        end;
    end;

    grdConfig.Cells[1, Row] := VarToStr(LValue);
    LTypeStr := ValueTypeToString(LValueType);
    grdConfig.Cells[2, Row] := LTypeStr;

    FConfigTypes.AddOrSetValue(LKeys[I], LValueType);
  end;

  StatusBar.SimpleText := Format('共 %d 个配置项', [Length(LKeys)]);
end;

function TConfigManagerFrame.ValueTypeToString(const ValueType: TConfigValueType): string;
begin
  case ValueType of
    cvtString: Result := '字符串';
    cvtInteger: Result := '整数';
    cvtBoolean: Result := '布尔';
    cvtFloat: Result := '浮点数';
    cvtDateTime: Result := '日期时间';
    cvtStringList: Result := '字符串列表';
    cvtObject: Result := '对象';
    else Result := '字符串';
  end;
end;

function TConfigManagerFrame.StringToValueType(const Value: string): TConfigValueType;
begin
  if Value = '字符串' then Result := cvtString
  else if Value = '整数' then Result := cvtInteger
  else if Value = '布尔' then Result := cvtBoolean
  else if Value = '浮点数' then Result := cvtFloat
  else if Value = '日期时间' then Result := cvtDateTime
  else if Value = '字符串列表' then Result := cvtStringList
  else if Value = '对象' then Result := cvtObject
  else Result := cvtString;
end;

procedure TConfigManagerFrame.ClearEditPanel;
begin
  edtKey.Text := '';
  edtValue.Text := '';
  cboType.ItemIndex := 0;
end;

procedure TConfigManagerFrame.EnableEditPanel(const Enable: Boolean);
begin
  edtKey.Enabled := Enable;
  edtValue.Enabled := Enable;
  cboType.Enabled := Enable;
  btnAdd.Enabled := Enable;
  btnUpdate.Enabled := Enable;
  btnDelete.Enabled := Enable;
end;

function TConfigManagerFrame.GetSelectedKey: string;
var
  Row: Integer;
begin
  Result := '';

  if grdConfig.Row <= grdConfig.FixedRows then
    Exit;

  if Length(FConfigKeys) = 0 then
    Exit;

  Row := grdConfig.Row;

  if (Row > grdConfig.FixedRows) and (Row - 1 < Length(FConfigKeys)) then
    Result := FConfigKeys[Row - 1];
end;

procedure TConfigManagerFrame.RefreshUI;
begin
  LoadModules;

  if (cboModules.ItemIndex >= 0) and (cboModules.ItemIndex < cboModules.Items.Count) then
    LoadConfig(cboModules.Text);

  StatusBar.SimpleText := '刷新完成 - ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);
end;

procedure TConfigManagerFrame.cboModulesChange(Sender: TObject);
begin
  if (cboModules.ItemIndex >= 0) and (cboModules.ItemIndex < cboModules.Items.Count) then
    LoadConfig(cboModules.Text);
end;

procedure TConfigManagerFrame.btnLoadClick(Sender: TObject);
begin
  if FCurrentModuleName = '(全局配置)' then
  begin
    if FConfigService.LoadGlobalConfig then
      ShowMessage('全局配置加载成功')
    else
      ShowMessage('全局配置加载失败');
  end
  else if Assigned(FCurrentModuleConfig) then
  begin
    if FCurrentModuleConfig.LoadFromFile then
    begin
      DisplayConfig;
      ShowMessage('配置加载成功');
    end
    else
      ShowMessage('配置加载失败');
  end;
end;

procedure TConfigManagerFrame.btnSaveClick(Sender: TObject);
begin
  if FCurrentModuleName = '(全局配置)' then
  begin
    if FConfigService.SaveGlobalConfig then
      ShowMessage('全局配置保存成功')
    else
      ShowMessage('全局配置保存失败');
  end
  else if Assigned(FCurrentModuleConfig) then
  begin
    if FCurrentModuleConfig.SaveToFile then
      ShowMessage('配置保存成功')
    else
      ShowMessage('配置保存失败');
  end;
end;

procedure TConfigManagerFrame.btnRefreshClick(Sender: TObject);
begin
  RefreshUI;
end;

procedure TConfigManagerFrame.grdConfigSelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
var
  LKey: string;
begin
  LKey := GetSelectedKey;

  if LKey <> '' then
  begin
    edtKey.Text := LKey;
    edtValue.Text := grdConfig.Cells[1, ARow];
    cboType.ItemIndex := cboType.Items.IndexOf(grdConfig.Cells[2, ARow]);
    if cboType.ItemIndex < 0 then
      cboType.ItemIndex := 0;
    EnableEditPanel(True);
  end
  else
  begin
    ClearEditPanel;
    EnableEditPanel(False);
  end;
end;

procedure TConfigManagerFrame.btnAddClick(Sender: TObject);
var
  LKey, LValue, LTypeStr: string;
  LValueType: TConfigValueType;
  LTempDateTime: TDateTime;
  LTempFloat: Double;
begin
  if not Assigned(FCurrentModuleConfig) then
  begin
    ShowMessage('请先选择一个模块');
    Exit;
  end;

  LKey := Trim(edtKey.Text);
  LValue := edtValue.Text;
  LTypeStr := cboType.Text;
  LValueType := StringToValueType(LTypeStr);

  if LKey.IsEmpty then
  begin
    ShowMessage('请输入配置键');
    Exit;
  end;

  if FCurrentModuleConfig.KeyExists(LKey) then
  begin
    if MessageDlg('配置键已存在，是否覆盖？', mtConfirmation,
      [mbYes, mbNo], 0) <> mrYes then
      Exit;
  end;

  // 根据类型设置值
  case LValueType of
    cvtString:
      FCurrentModuleConfig.SetValue(LKey, LValue);
    cvtInteger:
      FCurrentModuleConfig.SetValue(LKey, StrToIntDef(LValue, 0));
    cvtBoolean:
      FCurrentModuleConfig.SetValue(LKey, StrToBoolDef(LValue, False));
    cvtFloat:
      begin
        LTempFloat := StrToFloatDef(LValue, 0.0);
        FCurrentModuleConfig.SetValue(LKey, LTempFloat);
      end;
    cvtDateTime:
      begin
        if TryStrToDateTime(LValue, LTempDateTime) then
          FCurrentModuleConfig.SetValue(LKey, LTempDateTime)
        else
          FCurrentModuleConfig.SetValue(LKey, LValue);
      end;
    else
      FCurrentModuleConfig.SetValue(LKey, LValue);
  end;

  DisplayConfig;
  StatusBar.SimpleText := Format('配置项 %s 已添加', [LKey]);
end;

procedure TConfigManagerFrame.btnUpdateClick(Sender: TObject);
var
  LKey, LValue, LTypeStr: string;
  LValueType: TConfigValueType;
  LTempDateTime: TDateTime;
  LTempFloat: Double;
begin
  if not Assigned(FCurrentModuleConfig) then
  begin
    ShowMessage('请先选择一个模块');
    Exit;
  end;

  LKey := Trim(edtKey.Text);
  LValue := edtValue.Text;
  LTypeStr := cboType.Text;
  LValueType := StringToValueType(LTypeStr);

  if LKey.IsEmpty then
  begin
    ShowMessage('请输入配置键');
    Exit;
  end;

  if not FCurrentModuleConfig.KeyExists(LKey) then
  begin
    ShowMessage('配置键不存在');
    Exit;
  end;

  // 根据类型更新值
  case LValueType of
    cvtString:
      FCurrentModuleConfig.SetValue(LKey, LValue);
    cvtInteger:
      FCurrentModuleConfig.SetValue(LKey, StrToIntDef(LValue, 0));
    cvtBoolean:
      FCurrentModuleConfig.SetValue(LKey, StrToBoolDef(LValue, False));
    cvtFloat:
      begin
        LTempFloat := StrToFloatDef(LValue, 0.0);
        FCurrentModuleConfig.SetValue(LKey, LTempFloat);
      end;
    cvtDateTime:
      begin
        if TryStrToDateTime(LValue, LTempDateTime) then
          FCurrentModuleConfig.SetValue(LKey, LTempDateTime)
        else
          FCurrentModuleConfig.SetValue(LKey, LValue);
      end;
    else
      FCurrentModuleConfig.SetValue(LKey, LValue);
  end;

  DisplayConfig;
  StatusBar.SimpleText := Format('配置项 %s 已更新', [LKey]);
end;

procedure TConfigManagerFrame.btnDeleteClick(Sender: TObject);
var
  LKey: string;
begin
  if not Assigned(FCurrentModuleConfig) then
  begin
    ShowMessage('请先选择一个模块');
    Exit;
  end;

  LKey := Trim(edtKey.Text);

  if LKey.IsEmpty then
  begin
    ShowMessage('请输入配置键');
    Exit;
  end;

  if not FCurrentModuleConfig.KeyExists(LKey) then
  begin
    ShowMessage('配置键不存在');
    Exit;
  end;

  if MessageDlg(Format('确定要删除配置项 %s 吗？', [LKey]),
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  FCurrentModuleConfig.DeleteKey(LKey);
  DisplayConfig;
  ClearEditPanel;
  StatusBar.SimpleText := Format('配置项 %s 已删除', [LKey]);
end;

end.

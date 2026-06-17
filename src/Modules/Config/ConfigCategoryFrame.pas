unit ConfigCategoryFrame;

interface

uses
  System.SysUtils, System.Classes, System.Variants, Data.DB, FireDAC.Comp.Client,
  uniGUIBaseClasses, uniGUIClasses, uniGUImClasses, uniEdit, uniButton,
  uniBasicGrid, uniDBGrid, uniStringGrid, uniToolBar, uniLabel, uniMultiItem,
  uniComboBox, uniPanel, uniPageControl, UniContext, UniPlugin.Types,
  BaseCrudFrame, ConfigDataModule, ConfigService.Intf;

type
  /// <summary>
  /// 配置分类管理窗体 - 按分类管理系统配置
  /// </summary>
  TConfigCategoryFrame = class(TBaseCrudFrame)
    UniPanelTop: TUniPanel;
    UniLabelFilter: TUniLabel;
    UniEditFilter: TUniEdit;
    UniLabelStatus: TUniLabel;
    UniComboBoxStatus: TUniComboBox;
    UniButtonSearch: TUniButton;
    UniPageControl: TUniPageControl;
    UniTabSheetCategories: TUniTabSheet;
    UniGridCategories: TUniStringGrid;
    UniTabSheetConfigs: TUniTabSheet;
    UniDBGridConfigs: TUniDBGrid;
    UniDataSourceConfigs: TDataSource;
    qryConfigs: TFDQuery;

    procedure UniButtonSearchClick(Sender: TObject);
    procedure UniComboBoxStatusChange(Sender: TObject);
    procedure UniGridCategoriesCellClick(Sender: TObject; ACol, ARow: Integer);
    procedure UniDBGridConfigsDblClick(Sender: TObject);
  private
    FSelectedCategory: string;
    FLastDataSet: TDataSet;
    procedure FreeLastDataSet;
  protected
    procedure DoInitialize; override;
    procedure DoBindControls; override;
    procedure DoUnbindControls; override;
    procedure DoRefresh; override;
  public
    procedure Initialize; override;
    procedure RefreshCategories;
    procedure RefreshConfigs;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

{ TConfigCategoryFrame }

destructor TConfigCategoryFrame.Destroy;
begin
  FreeLastDataSet;
  inherited;
end;

procedure TConfigCategoryFrame.FreeLastDataSet;
begin
  if Assigned(FLastDataSet) then
  begin
    UniDataSourceConfigs.DataSet := nil;
    FreeAndNil(FLastDataSet);
  end;
end;

procedure TConfigCategoryFrame.DoInitialize;
begin
  inherited;
  FPermissionPrefix := 'config';
  FSelectedCategory := '';

  // 初始化状态下拉框
  UniComboBoxStatus.Items.Clear;
  UniComboBoxStatus.Items.Add('全部');
  UniComboBoxStatus.Items.Add('启用');
  UniComboBoxStatus.Items.Add('禁用');
  UniComboBoxStatus.ItemIndex := 0;

  // 初始化分类网格
  UniGridCategories.ColCount := 2;
  UniGridCategories.RowCount := 1;
  UniGridCategories.Cells[0, 0] := '分类';
  UniGridCategories.Cells[1, 0] := '配置数';
  UniGridCategories.FixedCols := 0;
  UniGridCategories.FixedRows := 1;
end;

procedure TConfigCategoryFrame.DoBindControls;
begin
  // 绑定编辑控件
end;

procedure TConfigCategoryFrame.DoUnbindControls;
begin
  // 解绑编辑控件
end;

procedure TConfigCategoryFrame.DoRefresh;
begin
  RefreshCategories;
  if FSelectedCategory <> '' then
    RefreshConfigs;
end;

procedure TConfigCategoryFrame.Initialize;
begin
  inherited;
  RefreshCategories;
end;

procedure TConfigCategoryFrame.RefreshCategories;
var
  LDataModule: TConfigDataModule;
  LCategories: TArray<TConfigCategoryInfo>;
  LCategory: TConfigCategoryInfo;
  I: Integer;
begin
  LDataModule := TConfigDataModule.Create(nil);
  try
    if Supports(LDataModule, IContextAware) then
      (LDataModule as IContextAware).SetContext(Context);

    LCategories := LDataModule.GetCategories;

    // 清空并重新填充分类网格
    UniGridCategories.RowCount := Length(LCategories) + 1;

    for I := 0 to Length(LCategories) - 1 do
    begin
      LCategory := LCategories[I];
      UniGridCategories.Cells[0, I + 1] := LCategory.CategoryName;
      UniGridCategories.Cells[1, I + 1] := IntToStr(LCategory.ConfigCount);
    end;
  finally
    LDataModule.Free;
  end;
end;

procedure TConfigCategoryFrame.RefreshConfigs;
var
  LFilter: string;
  LStatus: Integer;
  LDataModule: TConfigDataModule;
  LDataSet: TDataSet;
begin
  LFilter := Trim(UniEditFilter.Text);
  LStatus := -1;

  case UniComboBoxStatus.ItemIndex of
    1:
      LStatus := 1;
    2:
      LStatus := 0;
  end;

  LDataModule := TConfigDataModule.Create(nil);
  try
    if Supports(LDataModule, IContextAware) then
      (LDataModule as IContextAware).SetContext(Context);

    if FSelectedCategory <> '' then
      LDataSet := LDataModule.GetConfigsByCategory(FSelectedCategory, LStatus)
    else
      LDataSet := LDataModule.GetConfigs(LFilter, '', LStatus);

    FreeLastDataSet;
    UniDataSourceConfigs.DataSet := LDataSet;
    FLastDataSet := LDataSet;
  finally
    LDataModule.Free;
  end;
end;

procedure TConfigCategoryFrame.UniButtonSearchClick(Sender: TObject);
begin
  RefreshConfigs;
end;

procedure TConfigCategoryFrame.UniComboBoxStatusChange(Sender: TObject);
begin
  RefreshConfigs;
end;

procedure TConfigCategoryFrame.UniGridCategoriesCellClick(Sender: TObject; ACol, ARow: Integer);
begin
  if ARow > 0 then
  begin
    // 获取选中的分类（简化处理）
    FSelectedCategory := UniGridCategories.Cells[0, ARow];
    RefreshConfigs;
    UniPageControl.ActivePage := UniTabSheetConfigs;
  end;
end;

procedure TConfigCategoryFrame.UniDBGridConfigsDblClick(Sender: TObject);
begin
  // 双击编辑
  if Assigned(BtnEdit) and BtnEdit.Enabled then
    BtnEditClick(nil);
end;

end.


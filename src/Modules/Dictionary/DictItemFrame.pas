unit DictItemFrame;

interface

uses
  System.SysUtils, System.Classes, System.Variants,
  Data.DB, FireDAC.Comp.Client,
  uniGUIBaseClasses, uniGUIClasses, uniGUImClasses, uniEdit, uniButton,
  uniBasicGrid, uniDBGrid, uniToolBar, uniLabel, uniMultiItem, uniComboBox, uniPanel, uniPageControl,
  UniContext, UniPlugin.Types, BaseCrudFrame, DictionaryDataModule, uniTabControl, MainModule,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, Vcl.Controls,
  Vcl.Forms;

type
  /// <summary>
  /// 字典项管理窗体 - 管理数据字典项
  /// </summary>
  TDictItemFrame = class(TBaseCrudFrame)
    UniPanelTop: TUniPanel;
    UniLabelFilter: TUniLabel;
    UniEditFilter: TUniEdit;
    UniLabelStatus: TUniLabel;
    UniComboBoxStatus: TUniComboBox;
    UniButtonSearch: TUniButton;
    UniPageControl: TUniPageControl;
    UniTabItemList: TUniTabSheet;
    UniDBGridItems: TUniDBGrid;
    UniDataSourceItems: TDataSource;
    qryDictItems: TFDQuery;
    UniTabSheetTypes: TUniTabSheet;
    UniDBGridTypes: TUniDBGrid;
    UniDataSourceTypes: TDataSource;
    qryDictTypes: TFDQuery;

    procedure UniButtonSearchClick(Sender: TObject);
    procedure UniComboBoxStatusChange(Sender: TObject);
    procedure UniDBGridTypesDblClick(Sender: TObject);
    procedure UniDBGridItemsDblClick(Sender: TObject);
  private
    FSelectedTypeID: Integer;
    FLastTypesDataSet: TDataSet;
    FLastItemsDataSet: TDataSet;
    procedure FreeLastTypesDataSet;
    procedure FreeLastItemsDataSet;
  protected
    procedure DoInitialize; override;
    procedure DoBindControls; override;
    procedure DoUnbindControls; override;
    procedure DoRefresh; override;
  public
    procedure Initialize; override;
    procedure RefreshTypes;
    procedure RefreshItems;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

{ TDictItemFrame }

destructor TDictItemFrame.Destroy;
begin
  FreeLastTypesDataSet;
  FreeLastItemsDataSet;
  inherited;
end;

procedure TDictItemFrame.FreeLastTypesDataSet;
begin
  if Assigned(FLastTypesDataSet) then
  begin
    UniDataSourceTypes.DataSet := nil;
    FreeAndNil(FLastTypesDataSet);
  end;
end;

procedure TDictItemFrame.FreeLastItemsDataSet;
begin
  if Assigned(FLastItemsDataSet) then
  begin
    UniDataSourceItems.DataSet := nil;
    FreeAndNil(FLastItemsDataSet);
  end;
end;

procedure TDictItemFrame.DoInitialize;
begin
  inherited;
  FPermissionPrefix := 'dict_item';
  FSelectedTypeID := 0;

  // 初始化状态下拉框
  UniComboBoxStatus.Items.Clear;
  UniComboBoxStatus.Items.Add('全部');
  UniComboBoxStatus.Items.Add('启用');
  UniComboBoxStatus.Items.Add('禁用');
  UniComboBoxStatus.ItemIndex := 0;
end;

procedure TDictItemFrame.DoBindControls;
begin
  // 绑定编辑控件
end;

procedure TDictItemFrame.DoUnbindControls;
begin
  // 解绑编辑控件
end;

procedure TDictItemFrame.DoRefresh;
begin
  RefreshTypes;
  RefreshItems;
end;

procedure TDictItemFrame.Initialize;
begin
  inherited;
  RefreshTypes;
  RefreshItems;
end;

procedure TDictItemFrame.RefreshTypes;
var
  LDataModule: TDictionaryDataModule;
  LDataSet: TDataSet;
begin
  LDataModule := TDictionaryDataModule.CreateWithConnection(nil, GetMainModule.Connection);
  try
    if Supports(LDataModule, IContextAware) then
      (LDataModule as IContextAware).SetContext(Context);

    LDataSet := LDataModule.GetDictTypes('', 1);
    FreeLastTypesDataSet;
    UniDataSourceTypes.DataSet := LDataSet;
    FLastTypesDataSet := LDataSet;
  finally
    LDataModule.Free;
  end;
end;

procedure TDictItemFrame.RefreshItems;
var
  LFilter: string;
  LStatus: Integer;
  LDataModule: TDictionaryDataModule;
  LDataSet: TDataSet;
begin
  LFilter := Trim(UniEditFilter.Text);
  LStatus := -1;

  case UniComboBoxStatus.ItemIndex of
    1: LStatus := 1;
    2: LStatus := 0;
  end;

  LDataModule := TDictionaryDataModule.CreateWithConnection(nil, GetMainModule.Connection);
  try
    if Supports(LDataModule, IContextAware) then
      (LDataModule as IContextAware).SetContext(Context);

    if FSelectedTypeID > 0 then
      LDataSet := LDataModule.GetDictItemsByType(FSelectedTypeID, LStatus)
    else
      LDataSet := LDataModule.GetAllDictItems(LFilter, LStatus);

    FreeLastItemsDataSet;
    UniDataSourceItems.DataSet := LDataSet;
    FLastItemsDataSet := LDataSet;
  finally
    LDataModule.Free;
  end;
end;

procedure TDictItemFrame.UniButtonSearchClick(Sender: TObject);
begin
  RefreshItems;
end;

procedure TDictItemFrame.UniComboBoxStatusChange(Sender: TObject);
begin
  RefreshItems;
end;

procedure TDictItemFrame.UniDBGridTypesDblClick(Sender: TObject);
begin
  // 选择字典类型
  if Assigned(FLastTypesDataSet) and not FLastTypesDataSet.Eof then
  begin
    FSelectedTypeID := FLastTypesDataSet.FieldByName('TypeID').AsInteger;
    RefreshItems;
    UniPageControl.ActivePage := UniTabItemList;
  end;
end;

procedure TDictItemFrame.UniDBGridItemsDblClick(Sender: TObject);
begin
  // 双击编辑
  if Assigned(BtnEdit) and BtnEdit.Enabled then
    BtnEditClick(nil);
end;

initialization
  // Register for FindClass-driven MDI routing (UniAdmin_Menus.RoutePath)
  RegisterClass(TDictItemFrame);

end.

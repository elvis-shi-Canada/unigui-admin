unit DictItemFrame;

interface

uses
  System.SysUtils, System.Classes, System.Variants,
  Data.DB, FireDAC.Comp.Client,
  uniGUIControls, uniGUIBaseClasses, uniGUIClasses, uniGUImClasses, uniEdit, uniButton,
  uniGrid, uniToolBar, uniLabel, uniComboBox, uniPanel, uniPageControl, uniTabSheet,
  UniContext, UniPlugin.Types, BaseCrudFrame, DictionaryDataModule;

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
    FSelectedTypeID: Integer;

    procedure UniButtonSearchClick(Sender: TObject);
    procedure UniComboBoxStatusChange(Sender: TObject);
    procedure UniDBGridTypesDblClick(Sender: TObject);
    procedure UniDBGridItemsDblClick(Sender: TObject);
  protected
    procedure DoInitialize; override;
    procedure DoBindControls; override;
    procedure DoUnbindControls; override;
    procedure DoRefresh; override;
  public
    procedure Initialize; override;
    procedure RefreshTypes;
    procedure RefreshItems;
  end;

implementation

{$R *.dfm}

{ TDictItemFrame }

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

  // TODO: 初始化查询连接
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
  LDataModule := TDictionaryDataModule.Create(nil);
  try
    if Supports(LDataModule, IContextAware) then
      (LDataModule as IContextAware).SetContext(FContext);

    LDataSet := LDataModule.GetDictTypes('', 1);
    try
      qryDictTypes.Close;
      // TODO: 复制数据到 qryDictTypes
      qryDictTypes.Open;
    finally
      LDataSet.Free;
    end;
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

  LDataModule := TDictionaryDataModule.Create(nil);
  try
    if Supports(LDataModule, IContextAware) then
      (LDataModule as IContextAware).SetContext(FContext);

    if FSelectedTypeID > 0 then
      LDataSet := LDataModule.GetDictItemsByType(FSelectedTypeID, LStatus)
    else
      LDataSet := LDataModule.GetAllDictItems(LFilter, LStatus);

    try
      qryDictItems.Close;
      // TODO: 复制数据到 qryDictItems
      qryDictItems.Open;
    finally
      LDataSet.Free;
    end;
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
  if not qryDictTypes.Eof then
  begin
    FSelectedTypeID := qryDictTypes.FieldByName('TypeID').AsInteger;
    RefreshItems;
    UniPageControl.ActivePage := UniTabSheetItems;
  end;
end;

procedure TDictItemFrame.UniDBGridItemsDblClick(Sender: TObject);
begin
  // 双击编辑
  if Assigned(BtnEdit) and BtnEdit.Enabled then
    BtnEditClick(nil);
end;

end.

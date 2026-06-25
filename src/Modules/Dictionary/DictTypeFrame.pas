unit DictTypeFrame;

interface

uses
  System.SysUtils, System.Classes, System.Variants,
  Data.DB, FireDAC.Comp.Client,
  uniGUIBaseClasses, uniGUIClasses, uniGUImClasses, uniEdit, uniButton,
  uniBasicGrid, uniDBGrid, uniToolBar, uniLabel, uniMultiItem, uniComboBox, uniPanel,
  UniContext, UniPlugin.Types, BaseCrudFrame, DictionaryDataModule, MainModule;

type
  /// <summary>
  /// 字典类型管理窗体 - 管理数据字典类型
  /// </summary>
  TDictTypeFrame = class(TBaseCrudFrame)
    UniPanelTop: TUniPanel;
    UniLabelFilter: TUniLabel;
    UniEditFilter: TUniEdit;
    UniLabelStatus: TUniLabel;
    UniComboBoxStatus: TUniComboBox;
    UniButtonSearch: TUniButton;
    UniDBGrid: TUniDBGrid;
    UniDataSource: TDataSource;
    qryDictTypes: TFDQuery;

    procedure UniButtonSearchClick(Sender: TObject);
    procedure UniComboBoxStatusChange(Sender: TObject);
    procedure UniDBGridDblClick(Sender: TObject);
  protected
    procedure DoInitialize; override;
    procedure DoBindControls; override;
    procedure DoUnbindControls; override;
    procedure DoRefresh; override;
  public
    procedure Initialize; override;
  end;

implementation

{$R *.dfm}

{ TDictTypeFrame }

procedure TDictTypeFrame.DoInitialize;
begin
  inherited;
  FPermissionPrefix := 'dict_type';

  // 初始化状态下拉框
  UniComboBoxStatus.Items.Clear;
  UniComboBoxStatus.Items.Add('全部');
  UniComboBoxStatus.Items.Add('启用');
  UniComboBoxStatus.Items.Add('禁用');
  UniComboBoxStatus.ItemIndex := 0;

  // 初始化查询
  qryDictTypes.Connection := (Self.Owner as TComponent).FindComponent('FDConnection') as TFDConnection;
end;

procedure TDictTypeFrame.DoBindControls;
begin
  // 绑定编辑控件（如果有编辑表单）
end;

procedure TDictTypeFrame.DoUnbindControls;
begin
  // 解绑编辑控件
end;

procedure TDictTypeFrame.DoRefresh;
var
  LFilter: string;
  LStatus: Integer;
  LDataModule: TDictionaryDataModule;
begin
  LFilter := Trim(UniEditFilter.Text);
  LStatus := -1;

  case UniComboBoxStatus.ItemIndex of
    1: LStatus := 1; // 启用
    2: LStatus := 0; // 禁用
  end;

  LDataModule := TDictionaryDataModule.CreateWithConnection(nil, GetMainModule.Connection);
  try
    if Supports(LDataModule, IContextAware) then
      (LDataModule as IContextAware).SetContext(Context);

    UniDataSource.DataSet := LDataModule.GetDictTypes(LFilter, LStatus);
  finally
    LDataModule.Free;
  end;
end;

procedure TDictTypeFrame.Initialize;
begin
  inherited;
  DoRefresh;
end;

procedure TDictTypeFrame.UniButtonSearchClick(Sender: TObject);
begin
  Refresh;
end;

procedure TDictTypeFrame.UniComboBoxStatusChange(Sender: TObject);
begin
  Refresh;
end;

procedure TDictTypeFrame.UniDBGridDblClick(Sender: TObject);
begin
  // 双击编辑
  if Assigned(BtnEdit) and BtnEdit.Enabled then
    BtnEditClick(nil);
end;

end.

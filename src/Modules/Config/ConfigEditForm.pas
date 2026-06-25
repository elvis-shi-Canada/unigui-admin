unit ConfigEditForm;

interface

uses
  System.SysUtils, System.Classes, System.Variants,
  Data.DB, System.UITypes, System.Math,
  uniGUIBaseClasses, uniGUIClasses, uniGUImClasses, uniEdit, uniButton,
  uniLabel, uniMultiItem, uniComboBox, uniPanel, uniGUIForm, uniMemo, uniCheckBox,
  UniContext, UniPlugin.Types, ConfigDataModule, ConfigService.Intf,
  Vcl.Controls, Vcl.Forms, MainModule;

type
  /// <summary>
  /// 配置编辑窗体 - 新增或编辑系统配置
  /// </summary>
  TConfigEditForm = class(TUniForm)
    UniPanelMain: TUniPanel;
    UniLabelKey: TUniLabel;
    UniEditKey: TUniEdit;
    UniLabelValue: TUniLabel;
    UniMemoValue: TUniMemo;
    UniLabelCategory: TUniLabel;
    UniComboBoxCategory: TUniComboBox;
    UniLabelDescription: TUniLabel;
    UniMemoDescription: TUniMemo;
    UniLabelValueType: TUniLabel;
    UniComboBoxValueType: TUniComboBox;
    UniLabelSortOrder: TUniLabel;
    UniEditSortOrder: TUniEdit;
    UniLabelStatus: TUniLabel;
    UniCheckBoxStatus: TUniCheckBox;
    UniButtonOK: TUniButton;
    UniButtonCancel: TUniButton;

    procedure UniButtonOKClick(Sender: TObject);
    procedure UniButtonCancelClick(Sender: TObject);
  private
    FDataModule: TConfigDataModule;
    FConfigID: Integer;
    FIsEditMode: Boolean;
    procedure ValidateInput;
    procedure SaveConfig;
    procedure LoadConfigData;
  public
    constructor Create(AOwner: TComponent; const Context: IExecutionContext;
      ConfigID: Integer = -1); reintroduce;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

{ TConfigEditForm }

constructor TConfigEditForm.Create(AOwner: TComponent; const Context: IExecutionContext;
  ConfigID: Integer);
begin
  inherited Create(AOwner);

  FConfigID := ConfigID;
  FIsEditMode := (ConfigID > 0);

  FDataModule := TConfigDataModule.CreateWithConnection(nil, GetMainModule.Connection);
  if Supports(FDataModule, IContextAware) then
    (FDataModule as IContextAware).SetContext(Context);
  FDataModule.Open;

  // 初始化分类下拉框
  UniComboBoxCategory.Items.Clear;
  UniComboBoxCategory.Items.Add('System');
  UniComboBoxCategory.Items.Add('Security');
  UniComboBoxCategory.Items.Add('Email');
  UniComboBoxCategory.Items.Add('SMS');
  UniComboBoxCategory.Items.Add('Storage');
  UniComboBoxCategory.ItemIndex := 0;

  // 初始化值类型下拉框
  UniComboBoxValueType.Items.Clear;
  UniComboBoxValueType.Items.Add('string');
  UniComboBoxValueType.Items.Add('integer');
  UniComboBoxValueType.Items.Add('boolean');
  UniComboBoxValueType.Items.Add('float');
  UniComboBoxValueType.Items.Add('json');
  UniComboBoxValueType.Items.Add('xml');
  UniComboBoxValueType.ItemIndex := 0;

  if FIsEditMode then
  begin
    Caption := '编辑配置';
    LoadConfigData;
  end
  else
  begin
    Caption := '新增配置';
    UniEditSortOrder.Text := '0';
    UniCheckBoxStatus.Checked := True;
  end;
end;

destructor TConfigEditForm.Destroy;
begin
  if Assigned(FDataModule) then
  begin
    FDataModule.Close;
    FDataModule.Free;
  end;
  inherited;
end;

procedure TConfigEditForm.LoadConfigData;
var
  LDataSet: TDataSet;
begin
  LDataSet := FDataModule.GetConfigByID(FConfigID);
  try
    if not LDataSet.Eof then
    begin
      UniEditKey.Text := LDataSet.FieldByName('ConfigKey').AsString;
      UniMemoValue.Text := LDataSet.FieldByName('ConfigValue').AsString;
      UniComboBoxCategory.Text := LDataSet.FieldByName('Category').AsString;
      UniMemoDescription.Text := LDataSet.FieldByName('Description').AsString;
      UniComboBoxValueType.Text := LDataSet.FieldByName('ValueType').AsString;
      UniEditSortOrder.Text := LDataSet.FieldByName('SortOrder').AsString;
      UniCheckBoxStatus.Checked := LDataSet.FieldByName('Status').AsInteger = 1;

      // 编辑模式下，配置键不可修改
      UniEditKey.Enabled := False;
      UniComboBoxCategory.Enabled := False;
      UniComboBoxValueType.Enabled := False;
    end;
  finally
    LDataSet.Free;
  end;
end;

procedure TConfigEditForm.ValidateInput;
begin
  if Trim(UniEditKey.Text) = '' then
    raise Exception.Create('配置键不能为空');

  if Trim(UniMemoValue.Text) = '' then
    raise Exception.Create('配置值不能为空');

  if Trim(UniComboBoxCategory.Text) = '' then
    raise Exception.Create('请选择配置分类');

  if Trim(UniComboBoxValueType.Text) = '' then
    raise Exception.Create('请选择值类型');
end;

procedure TConfigEditForm.SaveConfig;
var
  LConfigKey, LConfigValue, LCategory, LDescription: string;
  LValueType: TConfigValueType;
  LSortOrder: Integer;
  LStatus: Integer;
begin
  ValidateInput;

  LConfigKey := Trim(UniEditKey.Text);
  LConfigValue := Trim(UniMemoValue.Text);
  LCategory := Trim(UniComboBoxCategory.Text);
  LDescription := Trim(UniMemoDescription.Text);

  if UniComboBoxValueType.Text = 'integer' then
    LValueType := cvtInteger
  else if UniComboBoxValueType.Text = 'boolean' then
    LValueType := cvtBoolean
  else if UniComboBoxValueType.Text = 'float' then
    LValueType := cvtFloat
  else if UniComboBoxValueType.Text = 'json' then
    LValueType := cvtJson
  else if UniComboBoxValueType.Text = 'xml' then
    LValueType := cvtXml
  else
    LValueType := cvtString;

  LSortOrder := StrToIntDef(UniEditSortOrder.Text, 0);
  LStatus := Ifthen(UniCheckBoxStatus.Checked, 1, 0);

  if FIsEditMode then
  begin
    FDataModule.UpdateConfig(FConfigID, LConfigValue, LDescription, LSortOrder);
    FDataModule.SetConfigStatus(FConfigID, LStatus);
  end
  else
  begin
    FConfigID := FDataModule.CreateConfig(LConfigKey, LConfigValue, LCategory,
      LDescription, LValueType, LSortOrder);
  end;
end;

procedure TConfigEditForm.UniButtonOKClick(Sender: TObject);
begin
  try
    SaveConfig;
    ModalResult := mrOk;
  except
    on E: Exception do
    begin
      ShowMessage(E.Message);
    end;
  end;
end;

procedure TConfigEditForm.UniButtonCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.

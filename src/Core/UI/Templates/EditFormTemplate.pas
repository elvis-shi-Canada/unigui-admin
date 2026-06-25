unit EditFormTemplate;

interface

uses
  System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms,
  UniGUIBaseClasses, UniGUIClasses, UniGUIForm, UniSession, uniGUIApplication,
  UniLabel, uniPanel, UniButton, UniEdit, UniMemo, UniCheckBox, UniComboBox, UniGroupBox,
  uniMultiItem;

type
  TEditFormTemplate = class(TUniForm)
    pnlHeader: TUniPanel;
    lblTitle: TUniLabel;
    pnlBody: TUniPanel;
    pnlFooter: TUniPanel;
    pnlButtons: TUniPanel;
    btnOK: TUniButton;
    btnCancel: TUniButton;
    grpFields: TUniGroupBox;
    lblField1: TUniLabel;
    edtField1: TUniEdit;
    lblField2: TUniLabel;
    edtField2: TUniEdit;
    lblField3: TUniLabel;
    memField3: TUniMemo;
    lblField4: TUniLabel;
    chkField4: TUniCheckBox;
    lblField5: TUniLabel;
    cboField5: TUniComboBox;
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
    FEditMode: Boolean;
  protected
    procedure LoadData; virtual;
    procedure SaveData; virtual;
    procedure ValidateData; virtual;
  public
    { Public declarations }
    class procedure ShowEditForm(const AID: Integer = 0);
    property EditMode: Boolean read FEditMode;
  end;

implementation

{$R *.dfm}

uses
  UniFormStyler;

procedure TEditFormTemplate.FormCreate(Sender: TObject);
begin
  // 应用统一设计系统样式
  TUniFormStyler.AutoStylePanels(Self);
  TUniFormStyler.AutoStyleButtons(Self);

  FEditMode := (Tag <> 0);
  if FEditMode then
    lblTitle.Caption := '编辑信息'
  else
    lblTitle.Caption := '新增信息';

  LoadData;
end;

procedure TEditFormTemplate.LoadData;
begin
  // 子类覆盖实现加载数据
  if FEditMode then
  begin
    // 示例：根据Tag字段ID加载数据
    edtField1.Text := '示例数据';
  end;
end;

procedure TEditFormTemplate.SaveData;
begin
  // 子类覆盖实现保存数据
  // 示例：
  // Field1 := edtField1.Text;
  // Field2 := edtField2.Text;
  // ...
end;

procedure TEditFormTemplate.ValidateData;
begin
  // 子类覆盖实现数据验证
  if Trim(edtField1.Text) = '' then
    raise Exception.Create('字段名称1不能为空');

  if Trim(edtField2.Text) = '' then
    raise Exception.Create('字段名称2不能为空');
end;

procedure TEditFormTemplate.btnOKClick(Sender: TObject);
begin
  try
    ValidateData;
    SaveData;
    ModalResult := mrOk;
  except
    on E: Exception do
    begin
      // UniSession.ShowMessage(E.Message);  // ShowMessage 需要在 UniGUI 会话上下文中调用
      ModalResult := mrNone;
    end;
  end;
end;

class procedure TEditFormTemplate.ShowEditForm(const AID: Integer = 0);
var
  Form: TEditFormTemplate;
begin
  Form := TEditFormTemplate.Create(nil);  // UniGUI 在类方法中不能访问 UniApplication
  try
    Form.Tag := AID;
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

end.

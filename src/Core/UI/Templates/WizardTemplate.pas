unit WizardTemplate;

interface

uses
  System.SysUtils, System.Classes, System.UITypes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  UniGUIBaseClasses, UniGUIClasses, UniGUIForm,
  UniLabel, uniPanel, UniButton, UniMemo;

type
  TWizardTemplate = class(TUniForm)
    pnlHeader: TUniPanel;
    lblWizardTitle: TUniLabel;
    pnlSteps: TUniPanel;
    lblStep1: TUniLabel;
    lblArrow1: TUniLabel;
    lblStep2: TUniLabel;
    lblArrow2: TUniLabel;
    lblStep3: TUniLabel;
    pnlBody: TUniPanel;
    lblStepDescription: TUniLabel;
    memContent: TUniMemo;
    pnlFooter: TUniPanel;
    pnlButtons: TUniPanel;
    btnBack: TUniButton;
    btnNext: TUniButton;
    btnCancel: TUniButton;
    procedure FormCreate(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
    FCurrentStep: Integer;
    FTotalSteps: Integer;
    procedure UpdateStepUI;
    procedure SetStep(Index: Integer);
  protected
    // 子类覆盖这些方法实现具体步骤逻辑
    procedure OnStepEnter(const StepIndex: Integer); virtual;
    procedure OnStepLeave(const StepIndex: Integer); virtual;
    function CanMoveNext: Boolean; virtual;
    function CanMoveBack: Boolean; virtual;
    function CanFinish: Boolean; virtual;
    procedure DoFinish; virtual;
  public
    { Public declarations }
    class function ExecuteWizard(const Title: string): Boolean;
    procedure AddStep(const StepName, Description, Content: string);
  end;

implementation

{$R *.dfm}

procedure TWizardTemplate.FormCreate(Sender: TObject);
begin
  FCurrentStep := 0;
  FTotalSteps := 3;
  UpdateStepUI;
  OnStepEnter(0);
end;

procedure TWizardTemplate.AddStep(const StepName, Description, Content: string);
begin
  // 子类可以覆盖此方法动态添加步骤
end;

procedure TWizardTemplate.SetStep(Index: Integer);
begin
  if (Index < 0) or (Index >= FTotalSteps) then Exit;

  OnStepLeave(FCurrentStep);
  FCurrentStep := Index;
  OnStepEnter(FCurrentStep);
  UpdateStepUI;
end;

procedure TWizardTemplate.UpdateStepUI;
var
  I: Integer;
  Labels: array[0..2] of TUniLabel;
begin
  Labels[0] := lblStep1;
  Labels[1] := lblStep2;
  Labels[2] := lblStep3;

  // 更新步骤标题
  for I := 0 to FTotalSteps - 1 do
  begin
    if I <= FCurrentStep then
    begin
      Labels[I].Font.Color := clHighlight;
      Labels[I].Font.Style := [fsBold];
    end
    else
    begin
      Labels[I].Font.Color := clGrayText;
      Labels[I].Font.Style := [];
    end;
  end;

  // 更新按钮状态
  btnBack.Enabled := CanMoveBack;
  btnNext.Enabled := CanMoveNext;
  // btnFinish 在最后一步时用作 Next
  if FCurrentStep = FTotalSteps - 1 then
    btnNext.Caption := #23436#25104(*'完成'*)
  else
    btnNext.Caption := #19979#19968#19968(*'下一步'*);

  // 更新内容
  lblStepDescription.Caption := Format('步骤 %d 说明', [FCurrentStep + 1]);
  memContent.Lines.Text := Format('步骤 %d 内容', [FCurrentStep + 1]);
end;

procedure TWizardTemplate.btnBackClick(Sender: TObject);
begin
  if CanMoveBack then
    SetStep(FCurrentStep - 1);
end;

procedure TWizardTemplate.btnNextClick(Sender: TObject);
begin
  // 如果在最后一步，则完成向导
  if FCurrentStep = FTotalSteps - 1 then
  begin
    if CanFinish then
      DoFinish;
  end
  else if CanMoveNext then
    SetStep(FCurrentStep + 1);
end;

procedure TWizardTemplate.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

// 虚方法 - 子类覆盖
procedure TWizardTemplate.OnStepEnter(const StepIndex: Integer);
begin
  // 子类覆盖
end;

procedure TWizardTemplate.OnStepLeave(const StepIndex: Integer);
begin
  // 子类覆盖
end;

function TWizardTemplate.CanMoveNext: Boolean;
begin
  Result := (FCurrentStep < FTotalSteps - 1);
end;

function TWizardTemplate.CanMoveBack: Boolean;
begin
  Result := (FCurrentStep > 0);
end;

function TWizardTemplate.CanFinish: Boolean;
begin
  Result := (FCurrentStep = FTotalSteps - 1);
end;

procedure TWizardTemplate.DoFinish;
begin
  ModalResult := mrOk;
end;

class function TWizardTemplate.ExecuteWizard(const Title: string): Boolean;
var
  Wizard: TWizardTemplate;
begin
  Wizard := TWizardTemplate.Create(nil);
  try
    Wizard.lblWizardTitle.Caption := Title;
    Result := (Wizard.ShowModal = mrOk);
  finally
    Wizard.Free;
  end;
end;

end.

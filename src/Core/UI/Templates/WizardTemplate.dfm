object WizardTemplate: TWizardTemplate
  Left = 0
  Top = 0
  Width = 600
  Height = 450
  Caption = 'Wizard'
  ClientHeight = 450
  ClientWidth = 600
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlHeader: TUniPanel
    Left = 0
    Top = 0
    Width = 600
    Height = 60
    Align = alTop
    ParentColor = False
    TabOrder = 0
    object lblWizardTitle: TUniLabel
      Left = 16
      Top = 16
      Width = 200
      Height = 24
      Caption = 'Wizard Title'
      ParentFont = False
      Font.Color = clHighlight
      Font.Height = -19
      Font.Style = [fsBold]
    end
  end
  object pnlSteps: TUniPanel
    Left = 0
    Top = 60
    Width = 600
    Height = 50
    Align = alTop
    ParentColor = False
    TabOrder = 1
  end
  object pnlBody: TUniPanel
    Left = 0
    Top = 110
    Width = 600
    Height = 280
    Align = alClient
    ParentColor = False
    TabOrder = 2
  end
  object pnlFooter: TUniPanel
    Left = 0
    Top = 390
    Width = 600
    Height = 60
    Align = alBottom
    ParentColor = False
    TabOrder = 3
    object btnBack: TUniButton
      Left = 10
      Top = 15
      Width = 75
      Height = 30
      Caption = 'Back'
      Enabled = False
      ModalResult = 2
      TabOrder = 0
    end
    object btnNext: TUniButton
      Left = 91
      Top = 15
      Width = 75
      Height = 30
      Caption = 'Next'
      ModalResult = 1
      TabOrder = 1
    end
    object btnCancel: TUniButton
      Left = 172
      Top = 15
      Width = 75
      Height = 30
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 2
    end
  end
end

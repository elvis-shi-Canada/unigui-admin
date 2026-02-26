object WizardTemplate: TWizardTemplate
  Left = 0
  Top = 0
  Width = 600
  Height = 450
  Caption = #21521#23548
  ClientHeight = 450
  ClientWidth = 600
  OnCreate = FormCreate
  UniThemeManager = UniThemeManager1
  PixelsPerInch = 96
  TextHeight = 13
  object pnlHeader: TUniPanel
    Left = 0
    Top = 0
    Width = 600
    Height = 60
    Align = alTop
    Color = clWindow
    ParentColor = False
    TabOrder = 0
    object lblWizardTitle: TUniLabel
      Left = 16
      Top = 16
      Width = 200
      Height = 24
      Caption = #21521#23548#26631#39064
      ParentFont = False
      Font.Color = clHighlight
      Font.Height = -19
      Font.Name = Segoe UI'
      Font.Style = [fsBold]
    end
  end
  object pnlSteps: TUniPanel
    Left = 0
    Top = 60
    Width = 600
    Height = 50
    Align = alTop
    Color = clWindow
    ParentColor = False
    TabOrder = 1
    object lblStep1: TUniLabel
      Left = 16
      Top = 16
      Width = 100
      Height = 13
      Caption = #27493#39588 1
      Font.Color = clHighlight
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblArrow1: TUniLabel
      Left = 120
      Top = 16
      Width = 20
      Height = 13
      Caption = '>'
      Font.Color = clGrayText
      ParentFont = False
    end
    object lblStep2: TUniLabel
      Left = 140
      Top = 16
      Width = 100
      Height = 13
      Caption = #27493#39588 2
      Font.Color = clGrayText
      ParentFont = False
    end
    object lblArrow2: TUniLabel
      Left = 244
      Top = 16
      Width = 20
      Height = 13
      Caption = '>'
      Font.Color = clGrayText
      ParentFont = False
    end
    object lblStep3: TUniLabel
      Left = 264
      Top = 16
      Width = 100
      Height = 13
      Caption = #27493#39588 3
      Font.Color = clGrayText
      ParentFont = False
    end
  end
  object pnlBody: TUniPanel
    Left = 0
    Top = 110
    Width = 600
    Height = 280
    Align = alClient
    Color = clWindow
    ParentColor = False
    TabOrder = 2
    object lblStepDescription: TUniLabel
      Left = 16
      Top = 16
      Width = 568
      Height = 24
      AutoSize = False
      Caption = #27493#39588 1 #35828#26126
      ParentFont = False
      Font.Color = clHighlight
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
    end
    object memContent: TUniMemo
      Left = 16
      Top = 48
      Width = 568
      Height = 216
      TabOrder = 0
      Lines.Strings = (
        #27493#39588 1 #20869#23481)
    end
  end
  object pnlFooter: TUniPanel
    Left = 0
    Top = 390
    Width = 600
    Height = 60
    Align = alBottom
    Color = 15856113
    ParentColor = False
    TabOrder = 3
    object pnlButtons: TUniPanel
      Left = 390
      Top = 10
      Width = 200
      Height = 40
      Anchors = [akTop, akRight]
      ParentColor = False
      Color = clBtnFace
      TabOrder = 0
      object btnBack: TUniButton
        Left = 10
        Top = 5
        Width = 75
        Height = 30
        Caption = #19978#19968#27493(&B)
        Enabled = False
        TabOrder = 0
        OnClick = btnBackClick
      end
      object btnNext: TUniButton
        Left = 85
        Top = 5
        Width = 75
        Height = 30
        Caption = #19979#19968#27493(&N)
        TabOrder = 1
        OnClick = btnNextClick
      end
      object btnFinish: TUniButton
        Left = 160
        Top = 5
        Width = 75
        Height = 30
        Caption = #23436#25104(&F)
        Enabled = False
        TabOrder = 2
        OnClick = btnFinishClick
      end
    end
    object btnCancel: TUniButton
      Left = 16
      Top = 15
      Width = 75
      Height = 30
      Caption = '#21462#28040(&C)
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
  object UniThemeManager1: TUniThemeManager
    Left = 544
    Top = 16
  end
end

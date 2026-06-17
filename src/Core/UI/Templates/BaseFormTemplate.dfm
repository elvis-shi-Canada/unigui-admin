object BaseFormTemplate: TBaseFormTemplate
  Left = 0
  Top = 0
  ClientHeight = 400
  ClientWidth = 600
  Caption = #22522#30784#31383#20307#27169#26495
  OldCreateOrder = False
  MonitoredKeys.Keys = <>
  OnCreate = FormCreate
  TextHeight = 15
  object pnlHeader: TUniPanel
    Left = 0
    Top = 0
    Width = 600
    Height = 60
    Hint = ''
    Align = alTop
    TabOrder = 0
    Caption = ''
    Color = clWindow
    object lblTitle: TUniLabel
      Left = 16
      Top = 16
      Width = 84
      Height = 25
      Hint = ''
      Caption = #31383#20307#26631#39064
      ParentFont = False
      Font.Color = clHighlight
      Font.Height = -19
      Font.Style = [fsBold]
      TabOrder = 1
    end
  end
  object pnlBody: TUniPanel
    Left = 0
    Top = 60
    Width = 600
    Height = 280
    Hint = ''
    Align = alClient
    TabOrder = 1
    Caption = ''
    Color = clWindow
  end
  object pnlFooter: TUniPanel
    Left = 0
    Top = 340
    Width = 600
    Height = 60
    Hint = ''
    Align = alBottom
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    Caption = ''
    Color = 15856113
    ExplicitTop = 346
    DesignSize = (
      600
      60)
    object pnlButtons: TUniPanel
      Left = 420
      Top = 10
      Width = 170
      Height = 40
      Hint = ''
      Anchors = [akTop, akRight]
      TabOrder = 1
      Caption = ''
      object btnOK: TUniButton
        Left = 10
        Top = 5
        Width = 75
        Height = 30
        Hint = ''
        Caption = #30830#23450
        ModalResult = 1
        TabOrder = 1
      end
      object btnCancel: TUniButton
        Left = 89
        Top = 5
        Width = 75
        Height = 30
        Hint = ''
        Caption = #21462#28040
        ModalResult = 2
        TabOrder = 2
      end
    end
  end
end

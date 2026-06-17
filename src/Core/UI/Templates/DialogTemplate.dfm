object DialogTemplate: TDialogTemplate
  Left = 0
  Top = 0
  ClientHeight = 300
  ClientWidth = 500
  Caption = #23545#35805#26694
  BorderStyle = bsDialog
  OldCreateOrder = False
  MonitoredKeys.Keys = <>
  Font.Name = 'Tahoma'
  TextHeight = 14
  object pnlContent: TUniPanel
    Left = 0
    Top = 0
    Width = 500
    Height = 240
    Hint = ''
    Align = alClient
    TabOrder = 0
    Caption = ''
    Color = clWindow
    object lblMessage: TUniLabel
      Left = 20
      Top = 20
      Width = 460
      Height = 180
      Hint = ''
      AutoSize = False
      Caption = #23545#35805#26694#20869#23481
      TabOrder = 1
    end
  end
  object pnlButtons: TUniPanel
    Left = 0
    Top = 240
    Width = 500
    Height = 60
    Hint = ''
    Align = alBottom
    TabOrder = 1
    Caption = ''
    object btnYes: TUniButton
      Left = 120
      Top = 15
      Width = 75
      Height = 30
      Hint = ''
      Caption = #26159'(&Y)'
      ModalResult = 6
      TabOrder = 1
    end
    object btnNo: TUniButton
      Left = 210
      Top = 15
      Width = 75
      Height = 30
      Hint = ''
      Caption = #21542'(&N)'
      ModalResult = 7
      TabOrder = 2
    end
    object btnCancel: TUniButton
      Left = 300
      Top = 15
      Width = 75
      Height = 30
      Hint = ''
      Caption = #21462#28040'(&C)'
      ModalResult = 2
      TabOrder = 3
    end
  end
end

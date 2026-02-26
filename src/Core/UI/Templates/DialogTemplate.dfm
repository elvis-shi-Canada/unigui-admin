object DialogTemplate: TDialogTemplate
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #23545#35805#26694
  ClientHeight = 300
  ClientWidth = 500
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object pnlContent: TUniPanel
    Left = 0
    Top = 0
    Width = 500
    Height = 240
    Align = alClient
    Color = clWindow
    ParentColor = False
    TabOrder = 0
    object lblMessage: TUniLabel
      Left = 20
      Top = 20
      Width = 460
      Height = 180
      AutoSize = False
      Caption = #23545#35805#26694#20869#23481
      WordWrap = True
    end
  end
  object pnlButtons: TUniPanel
    Left = 0
    Top = 240
    Width = 500
    Height = 60
    Align = alBottom
    Color = clBtnFace
    ParentColor = False
    TabOrder = 1
    object btnYes: TUniButton
      Left = 120
      Top = 15
      Width = 75
      Height = 30
      Caption = #26159(&Y)'
      ModalResult = 6
      TabOrder = 0
    end
    object btnNo: TUniButton
      Left = 210
      Top = 15
      Width = 75
      Height = 30
      Caption = #21542(&N)
      ModalResult = 7
      TabOrder = 1
    end
    object btnCancel: TUniButton
      Left = 300
      Top = 15
      Width = 75
      Height = 30
      Caption = '#21462#28040(&C)
      ModalResult = 2
      TabOrder = 2
    end
  end
  object UniThemeManager1: TUniThemeManager
    Left = 456
    Top = 16
  end
end

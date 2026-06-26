object EditFormTemplate: TEditFormTemplate
  Left = 0
  Top = 0
  ClientHeight = 500
  ClientWidth = 600
  Caption = #32534#36753#34920#21333
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
      Caption = #32534#36753#20449#24687
      ParentFont = False
      Font.Color = clHighlight
      Font.Height = -19
      Font.Style = [fsBold]
    end
  end
  object pnlBody: TUniPanel
    Left = 0
    Top = 60
    Width = 600
    Height = 380
    Hint = ''
    Align = alClient
    TabOrder = 1
    Caption = ''
    Color = clWindow
    object grpFields: TUniGroupBox
      Left = 16
      Top = 16
      Width = 568
      Height = 348
      Hint = ''
      Caption = #22522#26412#20449#24687
      TabOrder = 1
      object lblField1: TUniLabel
        Left = 16
        Top = 32
        Width = 157
        Height = 13
        Hint = ''
        Caption = #23383#27573#21517#312161':'
        TabOrder = 2
      end
      object edtField1: TUniEdit
        Left = 102
        Top = 29
        Width = 450
        Height = 21
        Hint = ''
        Text = ''
        TabOrder = 1
      end
      object lblField2: TUniLabel
        Left = 16
        Top = 72
        Width = 157
        Height = 13
        Hint = ''
        Caption = #23383#27573#21517#312162':'
        TabOrder = 4
      end
      object edtField2: TUniEdit
        Left = 102
        Top = 69
        Width = 450
        Height = 21
        Hint = ''
        Text = ''
        TabOrder = 3
      end
      object lblField3: TUniLabel
        Left = 16
        Top = 112
        Width = 157
        Height = 13
        Hint = ''
        Caption = #23383#27573#21517#312163':'
        TabOrder = 6
      end
      object memField3: TUniMemo
        Left = 102
        Top = 109
        Width = 450
        Height = 89
        Hint = ''
        TabOrder = 5
      end
      object lblField4: TUniLabel
        Left = 16
        Top = 216
        Width = 157
        Height = 13
        Hint = ''
        Caption = #23383#27573#21517#312164':'
        TabOrder = 8
      end
      object chkField4: TUniCheckBox
        Left = 102
        Top = 213
        Width = 97
        Height = 17
        Hint = ''
        Caption = #21551#29992
        TabOrder = 7
      end
      object lblField5: TUniLabel
        Left = 16
        Top = 256
        Width = 157
        Height = 13
        Hint = ''
        Caption = #23383#27573#21517#312165':'
        TabOrder = 10
      end
      object cboField5: TUniComboBox
        Left = 102
        Top = 253
        Width = 450
        Height = 21
        Hint = ''
        Text = ''
        Items.Strings = (
          #36873#62651
          #36873#62652
          #36873#62653)
        TabOrder = 9
        IconItems = <>
      end
    end
  end
  object pnlFooter: TUniPanel
    Left = 0
    Top = 440
    Width = 600
    Height = 60
    Hint = ''
    Align = alBottom
    TabOrder = 2
    Caption = ''
    Color = 15856113
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
        Caption = #20445#23384'(&S)'
        TabOrder = 1
        OnClick = btnOKClick
      end
      object btnCancel: TUniButton
        Left = 85
        Top = 5
        Width = 75
        Height = 30
        Hint = ''
        Caption = #21462#28040'(&C)'
        ModalResult = 2
        TabOrder = 2
      end
    end
  end
end

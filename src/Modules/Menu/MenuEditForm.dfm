object MenuEditForm: TMenuEditForm
  Left = 0
  Top = 0
  ClientHeight = 441
  ClientWidth = 624
  Caption = ''
  OldCreateOrder = False
  MonitoredKeys.Keys = <>
  TextHeight = 15
  object pnlMain: TUniPanel
    Left = 0
    Top = 0
    Width = 624
    Height = 441
    Hint = ''
    Align = alClient
    TabOrder = 0
    Caption = ''
    object lblMenuCode: TUniLabel
      Left = 16
      Top = 16
      Width = 57
      Height = 13
      Hint = ''
      Caption = #33756#21333#32534#30721'*'
      TabOrder = 4
    end
    object edtMenuCode: TUniEdit
      Left = 90
      Top = 13
      Width = 200
      Hint = ''
      Text = ''
      TabOrder = 1
    end
    object lblMenuName: TUniLabel
      Left = 16
      Top = 48
      Width = 57
      Height = 13
      Hint = ''
      Caption = #33756#21333#21517#31216'*'
      TabOrder = 8
    end
    object edtMenuName: TUniEdit
      Left = 90
      Top = 45
      Width = 200
      Hint = ''
      Text = ''
      TabOrder = 6
    end
    object lblParent: TUniLabel
      Left = 16
      Top = 80
      Width = 39
      Height = 13
      Hint = ''
      Caption = #29238#33756#21333
      TabOrder = 12
    end
    object cmbParent: TUniComboBox
      Left = 90
      Top = 77
      Width = 200
      Height = 21
      Hint = ''
      Text = ''
      TabOrder = 10
      IconItems = <>
    end
    object lblMenuType: TUniLabel
      Left = 16
      Top = 112
      Width = 57
      Height = 13
      Hint = ''
      Caption = #33756#21333#31867#22411'*'
      TabOrder = 16
    end
    object cmbMenuType: TUniComboBox
      Left = 90
      Top = 109
      Width = 200
      Height = 21
      Hint = ''
      Text = ''
      Items.Strings = (
        'directory'
        'menu'
        'button')
      TabOrder = 14
      IconItems = <>
      OnChange = cmbMenuTypeChange
    end
    object lblIcon: TUniLabel
      Left = 310
      Top = 16
      Width = 26
      Height = 13
      Hint = ''
      Caption = #22270#26631
      TabOrder = 5
    end
    object edtIcon: TUniEdit
      Left = 380
      Top = 13
      Width = 150
      Hint = ''
      Text = ''
      TabOrder = 2
    end
    object btnSelectIcon: TUniButton
      Left = 480
      Top = 13
      Width = 50
      Height = 22
      Hint = ''
      Caption = '...'
      TabOrder = 3
      OnClick = btnSelectIconClick
    end
    object lblPath: TUniLabel
      Left = 310
      Top = 48
      Width = 26
      Height = 13
      Hint = ''
      Caption = #36335#24452
      TabOrder = 9
    end
    object edtPath: TUniEdit
      Left = 380
      Top = 45
      Width = 150
      Hint = ''
      Text = ''
      TabOrder = 7
    end
    object lblComponent: TUniLabel
      Left = 310
      Top = 80
      Width = 26
      Height = 13
      Hint = ''
      Caption = #32452#20214
      TabOrder = 13
    end
    object edtComponent: TUniEdit
      Left = 380
      Top = 77
      Width = 150
      Hint = ''
      Text = ''
      TabOrder = 11
    end
    object lblPermission: TUniLabel
      Left = 310
      Top = 112
      Width = 52
      Height = 13
      Hint = ''
      Caption = #26435#38480#26631#35782
      TabOrder = 17
    end
    object edtPermission: TUniEdit
      Left = 380
      Top = 109
      Width = 150
      Hint = ''
      Text = ''
      TabOrder = 15
    end
    object lblSortOrder: TUniLabel
      Left = 16
      Top = 144
      Width = 26
      Height = 13
      Hint = ''
      Caption = #25490#24207
      TabOrder = 19
    end
    object lblDescription: TUniLabel
      Left = 16
      Top = 176
      Width = 57
      Height = 13
      Hint = ''
      Caption = #25551#36848#36848#36844
      TabOrder = 19
    end
    object memDescription: TUniMemo
      Left = 90
      Top = 173
      Width = 200
      Height = 60
      Hint = ''
      Lines.Strings = (
        '')
      TabOrder = 20
    end
    object lblVisible: TUniLabel
      Left = 310
      Top = 144
      Width = 26
      Height = 13
      Hint = ''
      Caption = #21487#31034
      TabOrder = 21
    end
    object chkVisible: TUniCheckBox
      Left = 380
      Top = 141
      Width = 80
      Height = 17
      Hint = ''
      Caption = #21487#31034
      TabOrder = 22
    end
    object lblStatus: TUniLabel
      Left = 310
      Top = 176
      Width = 26
      Height = 13
      Hint = ''
      Caption = #29366#24577
      TabOrder = 21
    end
    object chkStatus: TUniCheckBox
      Left = 380
      Top = 173
      Width = 80
      Height = 17
      Hint = ''
      Caption = #21551#29992
      TabOrder = 22
    end
    object spnSortOrder: TUniSpinEdit
      Left = 90
      Top = 141
      Width = 100
      Hint = ''
      TabOrder = 18
    end
  end
end

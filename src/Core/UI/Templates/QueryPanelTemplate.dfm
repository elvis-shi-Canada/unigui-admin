object QueryPanelTemplate: TQueryPanelTemplate
  Left = 0
  Top = 0
  Width = 800
  Height = 120
  Align = alTop
  Color = clWindow
  ParentColor = False
  TabOrder = 0
  object grpQuery: TUniGroupBox
    Left = 8
    Top = 8
    Width = 784
    Height = 104
    Caption = #26597#35810#26465#20214
    TabOrder = 0
    object lblKeyword: TUniLabel
      Left = 16
      Top = 24
      Width = 60
      Height = 13
      Caption = #20851#38190#35789:
      FocusControl = edtKeyword
    end
    object edtKeyword: TUniEdit
      Left = 82
      Top = 21
      Width = 200
      Height = 21
      TabOrder = 0
      TextHint = #35831#36755#20837#26597#35810#20851#38190#35789
    end
    object lblDateFrom: TUniLabel
      Left = 300
      Top = 24
      Width = 60
      Height = 13
      Caption = #36215#22987#26085#26399:
      FocusControl = dtpDateFrom
    end
    object dtpDateFrom: TUniDateTimePicker
      Left = 366
      Top = 21
      Width = 120
      Height = 21
      TabOrder = 1
    end
    object lblDateTo: TUniLabel
      Left = 492
      Top = 24
      Width = 60
      Height = 13
      Caption = #32467#26463#26085#26399:
      FocusControl = dtpDateTo
    end
    object dtpDateTo: TUniDateTimePicker
      Left = 558
      Top = 21
      Width = 120
      Height = 21
      TabOrder = 2
    end
    object lblStatus: TUniLabel
      Left = 16
      Top = 64
      Width = 60
      Height = 13
      Caption = #29366#24577:
      FocusControl = cboStatus
    end
    object cboStatus: TUniComboBox
      Left = 82
      Top = 61
      Width = 200
      Height = 21
      TabOrder = 3
      Items.Strings = (
        #20840#37096
        #21551#29992
        #31105#29992
        #24453#23457#26680)
    end
    object btnQuery: TUniButton
      Left = 300
      Top = 59
      Width = 75
      Height = 25
      Caption = #26597#35810(&Q)
      TabOrder = 4
      OnClick = btnQueryClick
    end
    object btnReset: TUniButton
      Left = 381
      Top = 59
      Width = 75
      Height = 25
      Caption = #37325#32622(&R)
      TabOrder = 5
      OnClick = btnResetClick
    end
    object btnAdvanced: TUniButton
      Left = 462
      Top = 59
      Width = 75
      Height = 25
      Caption = '#39640#32423(&A)...
      TabOrder = 6
      OnClick = btnAdvancedClick
    end
  end
end

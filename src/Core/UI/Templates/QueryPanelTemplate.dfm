object QueryPanelTemplate: TQueryPanelTemplate
  Left = 0
  Top = 0
  Width = 800
  Height = 120
  Color = clWindow
  Align = alTop
  Anchors = [akLeft, akTop, akRight]
  TabOrder = 0
  ParentColor = False
  object grpQuery: TUniGroupBox
    Left = 8
    Top = 8
    Width = 784
    Height = 104
    Hint = ''
    Caption = #26597#35810#26465#20214
    TabOrder = 0
    object lblKeyword: TUniLabel
      Left = 16
      Top = 24
      Width = 42
      Height = 13
      Hint = ''
      Caption = #20851#38190#35789':'
      TabOrder = 4
    end
    object edtKeyword: TUniEdit
      Left = 82
      Top = 21
      Width = 200
      Height = 21
      Hint = ''
      Text = ''
      TabOrder = 1
    end
    object lblDateFrom: TUniLabel
      Left = 300
      Top = 24
      Width = 55
      Height = 13
      Hint = ''
      Caption = #36215#22987#26085#26399':'
      TabOrder = 5
    end
    object dtpDateFrom: TUniDateTimePicker
      Left = 366
      Top = 21
      Width = 120
      Height = 21
      Hint = ''
      DateTime = 46084.000000000000000000
      DateFormat = 'dd/MM/yyyy'
      TimeFormat = 'HH:mm:ss'
      TabOrder = 2
      DisabledDates = <>
    end
    object lblDateTo: TUniLabel
      Left = 492
      Top = 24
      Width = 55
      Height = 13
      Hint = ''
      Caption = #32467#26463#26085#26399':'
      TabOrder = 6
    end
    object dtpDateTo: TUniDateTimePicker
      Left = 558
      Top = 21
      Width = 120
      Height = 21
      Hint = ''
      DateTime = 46084.000000000000000000
      DateFormat = 'dd/MM/yyyy'
      TimeFormat = 'HH:mm:ss'
      TabOrder = 3
      DisabledDates = <>
    end
    object lblStatus: TUniLabel
      Left = 16
      Top = 64
      Width = 29
      Height = 13
      Hint = ''
      Caption = #29366#24577':'
      TabOrder = 11
    end
    object cboStatus: TUniComboBox
      Left = 82
      Top = 61
      Width = 200
      Height = 21
      Hint = ''
      Text = ''
      Items.Strings = (
        #20840#37096
        #21551#29992
        #31105#29992
        #24453#23457#26680)
      TabOrder = 10
      IconItems = <>
    end
    object btnQuery: TUniButton
      Left = 300
      Top = 59
      Width = 75
      Height = 25
      Hint = ''
      Caption = #26597#35810'(&Q)'
      TabOrder = 7
      OnClick = btnQueryClick
    end
    object btnReset: TUniButton
      Left = 381
      Top = 59
      Width = 75
      Height = 25
      Hint = ''
      Caption = #37325#32622'(&R)'
      TabOrder = 8
      OnClick = btnResetClick
    end
    object btnAdvanced: TUniButton
      Left = 462
      Top = 59
      Width = 75
      Height = 25
      Hint = ''
      Caption = #39640#32423'(&A)...'
      TabOrder = 9
      OnClick = btnAdvancedClick
    end
  end
end

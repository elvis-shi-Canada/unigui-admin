inherited LoginLogFrame: TLoginLogFrame
  object UniPanelFilter: TUniPanel
    Left = 0
    Top = 40
    Width = 640
    Height = 80
    Hint = ''
    Align = alTop
    TabOrder = 1
    Caption = ''
    object UniLabelUserName: TUniLabel
      Left = 8
      Top = 12
      Width = 39
      Height = 13
      Hint = ''
      Caption = #29992#25143#21517
    end
    object UniEditUserName: TUniEdit
      Left = 80
      Top = 8
      Width = 120
      Hint = ''
      Text = ''
      TabOrder = 1
    end
    object UniLabelIP: TUniLabel
      Left = 210
      Top = 12
      Width = 35
      Height = 13
      Hint = ''
      Caption = 'IP'#22320#22336
    end
    object UniEditIP: TUniEdit
      Left = 280
      Top = 8
      Width = 120
      Hint = ''
      Text = ''
      TabOrder = 2
    end
    object UniLabelStartTime: TUniLabel
      Left = 8
      Top = 44
      Width = 52
      Height = 13
      Hint = ''
      Caption = #24320#22987#26102#38388
    end
    object UniDateTimePickerStart: TUniDateTimePicker
      Left = 80
      Top = 40
      Width = 120
      Hint = ''
      DateTime = 46197.000000000000000000
      DateFormat = 'dd/MM/yyyy'
      TimeFormat = 'HH:mm:ss'
      TabOrder = 8
      DisabledDates = <>
    end
    object UniLabelEndTime: TUniLabel
      Left = 210
      Top = 44
      Width = 52
      Height = 13
      Hint = ''
      Caption = #32467#26463#26102#38388
    end
    object UniDateTimePickerEnd: TUniDateTimePicker
      Left = 280
      Top = 40
      Width = 120
      Hint = ''
      DateTime = 46197.000000000000000000
      DateFormat = 'dd/MM/yyyy'
      TimeFormat = 'HH:mm:ss'
      TabOrder = 9
      DisabledDates = <>
    end
    object UniLabelStatus: TUniLabel
      Left = 410
      Top = 12
      Width = 26
      Height = 13
      Hint = ''
      Caption = #29366#24577
    end
    object UniComboBoxStatus: TUniComboBox
      Left = 480
      Top = 8
      Width = 80
      Height = 21
      Hint = ''
      Text = ''
      Items.Strings = (
        #37711#12585#20788
        #37812#24876#23003
        #28598#36779#35302)
      TabOrder = 3
      IconItems = <>
    end
    object UniButtonSearch: TUniButton
      Left = 570
      Top = 8
      Width = 75
      Height = 25
      Hint = ''
      Caption = #26597#35810
      TabOrder = 4
      OnClick = UniButtonSearchClick
    end
    object UniButtonExport: TUniButton
      Left = 570
      Top = 40
      Width = 75
      Height = 25
      Hint = ''
      Caption = #23548#20986
      TabOrder = 10
      OnClick = UniButtonExportClick
    end
  end
  object UniDBGrid: TUniDBGrid
    Left = 0
    Top = 120
    Width = 640
    Height = 360
    Hint = ''
    DataSource = UniDataSource
    LoadMask.Message = #21152#36733#25968#25454'...'
    Align = alClient
    TabOrder = 2
  end
  object UniDataSource: TDataSource
    Left = 8
    Top = 8
  end
  object qryLoginLogs: TFDQuery
    Left = 40
    Top = 8
  end
end

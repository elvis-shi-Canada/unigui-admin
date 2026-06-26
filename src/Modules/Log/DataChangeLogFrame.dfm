inherited DataChangeLogFrame: TDataChangeLogFrame
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
    object UniLabelTableName: TUniLabel
      Left = 210
      Top = 12
      Width = 26
      Height = 13
      Hint = ''
      Caption = #34920#21517
    end
    object UniEditTableName: TUniEdit
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
      DateTime = 46199.000000000000000000
      DateFormat = 'dd/MM/yyyy'
      TimeFormat = 'HH:mm:ss'
      TabOrder = 6
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
      DateTime = 46199.000000000000000000
      DateFormat = 'dd/MM/yyyy'
      TimeFormat = 'HH:mm:ss'
      TabOrder = 7
      DisabledDates = <>
    end
    object UniButtonSearch: TUniButton
      Left = 410
      Top = 8
      Width = 75
      Height = 25
      Hint = ''
      Caption = #26597#35810
      TabOrder = 3
      OnClick = UniButtonSearchClick
    end
    object UniButtonExport: TUniButton
      Left = 410
      Top = 40
      Width = 75
      Height = 25
      Hint = ''
      Caption = #23548#20986
      TabOrder = 8
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
  object qryDataChangeLogs: TFDQuery
    Left = 40
    Top = 8
  end
end

inherited DataChangeLogFrame: TDataChangeLogFrame
  PixelsPerInch = 96
  TextHeight = 13
  object UniPanelFilter: TUniPanel
    Left = 0
    Top = 40
    Width = 800
    Height = 80
    Hint = ''
    Align = alTop
    TabOrder = 0
    object UniLabelUserName: TUniLabel
      Left = 8
      Top = 12
      Width = 60
      Height = 13
      Hint = ''
      Caption = #29992#25143#21517
      TabOrder = 1
    end
    object UniEditUserName: TUniEdit
      Left = 80
      Top = 8
      Width = 120
      Height = 22
      Hint = ''
      TextHint = #36755#20837#29992#25143#21517
      TabOrder = 2
    end
    object UniLabelTableName: TUniLabel
      Left = 210
      Top = 12
      Width = 60
      Height = 13
      Hint = ''
      Caption = #34920#21517
      TabOrder = 3
    end
    object UniEditTableName: TUniEdit
      Left = 280
      Top = 8
      Width = 120
      Height = 22
      Hint = ''
      TextHint = #36755#20837#34920#21517
      TabOrder = 4
    end
    object UniLabelStartTime: TUniLabel
      Left = 8
      Top = 44
      Width = 60
      Height = 13
      Hint = ''
      Caption = #24320#22987#26102#38388
      TabOrder = 5
    end
    object UniDateTimePickerStart: TUniDateTimePicker
      Left = 80
      Top = 40
      Width = 120
      Height = 22
      Hint = ''
      TabOrder = 6
    end
    object UniLabelEndTime: TUniLabel
      Left = 210
      Top = 44
      Width = 60
      Height = 13
      Hint = ''
      Caption = #32467#26463#26102#38388
      TabOrder = 7
    end
    object UniDateTimePickerEnd: TUniDateTimePicker
      Left = 280
      Top = 40
      Width = 120
      Height = 22
      Hint = ''
      TabOrder = 8
    end
    object UniButtonSearch: TUniButton
      Left = 410
      Top = 8
      Width = 75
      Height = 25
      Hint = ''
      Caption = #26597#35810
      TabOrder = 9
      OnClick = UniButtonSearchClick
    end
    object UniButtonExport: TUniButton
      Left = 410
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
    Width = 800
    Height = 480
    Hint = ''
    Align = alClient
    TabOrder = 1
    DataSource = UniDataSource
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

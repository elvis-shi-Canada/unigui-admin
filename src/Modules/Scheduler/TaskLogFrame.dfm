inherited TaskLogFrame: TTaskLogFrame
  object UniPanelTop: TUniPanel
    Left = 0
    Top = 40
    Width = 640
    Height = 40
    Hint = ''
    Align = alTop
    TabOrder = 1
    Caption = ''
    object UniLabelTask: TUniLabel
      Left = 8
      Top = 12
      Width = 26
      Height = 13
      Hint = ''
      Caption = #20219#21153
    end
    object UniComboBoxTask: TUniComboBox
      Left = 80
      Top = 8
      Width = 200
      Height = 21
      Hint = ''
      Text = ''
      TabOrder = 1
      IconItems = <>
    end
    object UniButtonSearch: TUniButton
      Left = 290
      Top = 8
      Width = 75
      Height = 25
      Hint = ''
      Caption = #26597#35810
      TabOrder = 2
      OnClick = UniButtonSearchClick
    end
  end
  object UniDBGrid: TUniDBGrid
    Left = 0
    Top = 80
    Width = 640
    Height = 180
    Hint = ''
    DataSource = UniDataSource
    LoadMask.Message = #21152#36733#25968#25454'...'
    Align = alClient
    TabOrder = 2
  end
  object UniPanelDetail: TUniPanel
    Left = 0
    Top = 260
    Width = 640
    Height = 220
    Hint = ''
    Align = alBottom
    TabOrder = 3
    Caption = ''
    object UniLabelDetail: TUniLabel
      Left = 8
      Top = 8
      Width = 52
      Height = 13
      Hint = ''
      Caption = #25191#34892#35814#24773
    end
    object UniMemoDetail: TUniMemo
      Left = 8
      Top = 27
      Width = 784
      Height = 185
      Hint = ''
      Lines.Strings = (
        '')
      TabOrder = 2
    end
  end
  object UniDataSource: TDataSource
    Left = 8
    Top = 8
  end
  object qryLogs: TFDQuery
    Left = 40
    Top = 8
  end
end

inherited TaskLogFrame: TTaskLogFrame
  PixelsPerInch = 96
  TextHeight = 13
  object UniPanelTop: TUniPanel
    Left = 0
    Top = 40
    Width = 800
    Height = 40
    Hint = '
    Align = alTop
    TabOrder = 0
    object UniLabelTask: TUniLabel
      Left = 8
      Top = 12
      Width = 60
      Height = 13
      Hint = '
      Caption = #20219#21153
      TabOrder = 1
    end
    object UniComboBoxTask: TUniComboBox
      Left = 80
      Top = 8
      Width = 200
      Height = 21
      Hint = '
      Style = csDropDown
      ItemIndex = -1
      TabOrder = 2
    end
    object UniButtonSearch: TUniButton
      Left = 290
      Top = 8
      Width = 75
      Height = 25
      Hint = '
      Caption = #26597#35810
      TabOrder = 3
      OnClick = UniButtonSearchClick
    end
  end
  object UniDBGrid: TUniDBGrid
    Left = 0
    Top = 80
    Width = 800
    Height = 300
    Hint = '
    Align = alClient
    TabOrder = 1
    DataSource = UniDataSource
    OnAfterScroll = UniDBGridAfterScroll
  end
  object UniPanelDetail: TUniPanel
    Left = 0
    Top = 380
    Width = 800
    Height = 220
    Hint = ''
    Align = alBottom
    TabOrder = 2
    object UniLabelDetail: TUniLabel
      Left = 8
      Top = 8
      Width = 60
      Height = 13
      Hint = '
      Caption = #25191#34892#35814#24773
      TabOrder = 1
    end
    object UniMemoDetail: TUniMemo
      Left = 8
      Top = 27
      Width = 784
      Height = 185
      Hint = '
      Lines.Strings = (
        ')
      TabOrder = 0
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

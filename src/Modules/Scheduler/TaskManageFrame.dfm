inherited TaskManageFrame: TTaskManageFrame
  PixelsPerInch = 96
  TextHeight = 13
  object UniPanelTop: TUniPanel
    Left = 0
    Top = 40
    Width = 800
    Height = 40
    Hint = ''
    Align = alTop
    TabOrder = 0
    object UniLabelFilter: TUniLabel
      Left = 8
      Top = 12
      Width = 60
      Height = 13
      Hint = ''
      Caption = #20219#21153#21517#31216
      TabOrder = 1
    end
    object UniEditFilter: TUniEdit
      Left = 80
      Top = 8
      Width = 150
      Height = 22
      Hint = ''
      TextHint = #36755#20837#20219#21153#21517#31216
      TabOrder = 2
    end
    object UniLabelStatus: TUniLabel
      Left = 240
      Top = 12
      Width = 60
      Height = 13
      Hint = ''
      Caption = #29366#24577
      TabOrder = 3
    end
    object UniComboBoxStatus: TUniComboBox
      Left = 310
      Top = 8
      Width = 100
      Height = 21
      Hint = ''
      Style = csDropDown
      ItemIndex = 0
      TabOrder = 4
      Items.Strings = (
        #20840#37096
        #36816#34892#20013
        #24050#20572#27490
        #24050#26242#20572
        #38169#35823)
    end
    object UniButtonSearch: TUniButton
      Left = 420
      Top = 8
      Width = 75
      Height = 25
      Hint = ''
      Caption = #26597#35810
      TabOrder = 5
      OnClick = UniButtonSearchClick
    end
    object UniButtonRefresh: TUniButton
      Left = 500
      Top = 8
      Width = 75
      Height = 25
      Hint = ''
      Caption = #21047#26032
      TabOrder = 6
      OnClick = UniButtonRefreshClick
    end
  end
  object UniDBGrid: TUniDBGrid
    Left = 0
    Top = 80
    Width = 800
    Height = 520
    Hint = ''
    Align = alClient
    TabOrder = 1
    DataSource = UniDataSource
    OnDblClick = UniDBGridDblClick
  end
  object UniDataSource: TDataSource
    Left = 8
    Top = 8
  end
  object qryTasks: TFDQuery
    Left = 40
    Top = 8
  end
end

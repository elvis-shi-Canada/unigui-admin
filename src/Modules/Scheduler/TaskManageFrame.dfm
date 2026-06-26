inherited TaskManageFrame: TTaskManageFrame
  object UniPanelTop: TUniPanel
    Left = 0
    Top = 40
    Width = 640
    Height = 40
    Hint = ''
    Align = alTop
    TabOrder = 1
    Caption = ''
    object UniLabelFilter: TUniLabel
      Left = 8
      Top = 12
      Width = 52
      Height = 13
      Hint = ''
      Caption = #20219#21153#21517#31216
    end
    object UniEditFilter: TUniEdit
      Left = 80
      Top = 8
      Width = 150
      Hint = ''
      Text = ''
      TabOrder = 1
    end
    object UniLabelStatus: TUniLabel
      Left = 240
      Top = 12
      Width = 26
      Height = 13
      Hint = ''
      Caption = #29366#24577
    end
    object UniComboBoxStatus: TUniComboBox
      Left = 310
      Top = 8
      Width = 100
      Height = 21
      Hint = ''
      Text = ''
      Items.Strings = (
        #20840#37096
        #36816#34892#20013
        #24050#20572#27490
        #24050#26242#20572
        #38169#35823)
      TabOrder = 2
      IconItems = <>
    end
    object UniButtonSearch: TUniButton
      Left = 420
      Top = 8
      Width = 75
      Height = 25
      Hint = ''
      Caption = #26597#35810
      TabOrder = 3
      OnClick = UniButtonSearchClick
    end
    object UniButtonRefresh: TUniButton
      Left = 500
      Top = 8
      Width = 75
      Height = 25
      Hint = ''
      Caption = #21047#26032
      TabOrder = 4
      OnClick = UniButtonRefreshClick
    end
  end
  object UniDBGrid: TUniDBGrid
    Left = 0
    Top = 80
    Width = 640
    Height = 400
    Hint = ''
    DataSource = UniDataSource
    LoadMask.Message = #21152#36733#25968#25454'...'
    Align = alClient
    TabOrder = 2
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

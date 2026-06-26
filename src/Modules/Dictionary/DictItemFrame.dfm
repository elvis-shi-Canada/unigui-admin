inherited DictItemFrame: TDictItemFrame
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
      Width = 39
      Height = 13
      Hint = ''
      Caption = #23383#20856#39033
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
        #21551#29992
        #31105#29992)
      TabOrder = 2
      IconItems = <>
      OnChange = UniComboBoxStatusChange
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
  end
  object UniPageControl: TUniPageControl
    Left = 0
    Top = 80
    Width = 640
    Height = 400
    Hint = ''
    ActivePage = UniTabItemList
    Align = alClient
    TabOrder = 2
    object UniTabItemList: TUniTabSheet
      Hint = ''
      Caption = #23383#20856#39033
      object UniDBGridItems: TUniDBGrid
        Left = 0
        Top = 0
        Width = 632
        Height = 372
        Hint = ''
        DataSource = UniDataSourceItems
        LoadMask.Message = #21152#36733#25968#25454'...'
        Align = alClient
        TabOrder = 0
        OnDblClick = UniDBGridItemsDblClick
      end
    end
    object UniTabSheetTypes: TUniTabSheet
      Hint = ''
      Caption = #23383#20856#31867#22411
      object UniDBGridTypes: TUniDBGrid
        Left = 0
        Top = 0
        Width = 632
        Height = 372
        Hint = ''
        DataSource = UniDataSourceTypes
        LoadMask.Message = #21152#36733#25968#25454'...'
        Align = alClient
        TabOrder = 0
        OnDblClick = UniDBGridTypesDblClick
      end
    end
  end
  object UniDataSourceItems: TDataSource
    Left = 8
    Top = 8
  end
  object UniDataSourceTypes: TDataSource
    Left = 40
    Top = 8
  end
  object qryDictItems: TFDQuery
    Left = 72
    Top = 8
  end
  object qryDictTypes: TFDQuery
    Left = 104
    Top = 8
  end
end

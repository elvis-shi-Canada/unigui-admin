inherited ConfigCategoryFrame: TConfigCategoryFrame
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
      Caption = #37197#32622#38190
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
    ActivePage = UniTabSheetCategories
    Align = alClient
    TabOrder = 2
    object UniTabSheetCategories: TUniTabSheet
      Hint = ''
      Caption = #20998#31867
      object UniGridCategories: TUniStringGrid
        Left = 0
        Top = 0
        Width = 632
        Height = 372
        Hint = ''
        Columns = <>
        Align = alClient
        TabOrder = 0
      end
    end
    object UniTabSheetConfigs: TUniTabSheet
      Hint = ''
      Caption = #37197#32622
      object UniDBGridConfigs: TUniDBGrid
        Left = 0
        Top = 0
        Width = 632
        Height = 372
        Hint = ''
        DataSource = UniDataSourceConfigs
        LoadMask.Message = #21152#36733#25968#25454'...'
        Align = alClient
        TabOrder = 0
        OnDblClick = UniDBGridConfigsDblClick
      end
    end
  end
  object UniDataSourceConfigs: TDataSource
    Left = 8
    Top = 8
  end
  object qryConfigs: TFDQuery
    Left = 40
    Top = 8
  end
end

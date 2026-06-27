object AutoCrudFrame: TAutoCrudFrame
  Left = 0
  Top = 0
  Width = 800
  Height = 600
  TabOrder = 0
  object pnlToolbar: TUniPanel
    Left = 0
    Top = 0
    Width = 800
    Height = 41
    Align = alTop
    TabOrder = 0
    object btnAdd: TUniButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = #26032#22679
      TabOrder = 1
    end
    object btnEdit: TUniButton
      Left = 89
      Top = 8
      Width = 75
      Height = 25
      Caption = #32534#36753
      TabOrder = 2
    end
    object btnDelete: TUniButton
      Left = 170
      Top = 8
      Width = 75
      Height = 25
      Caption = #21024#38500
      TabOrder = 3
    end
    object btnRefresh: TUniButton
      Left = 251
      Top = 8
      Width = 75
      Height = 25
      Caption = #21047#26032
      TabOrder = 4
      OnClick = btnRefreshClick
    end
    object edtSearch: TUniEdit
      Left = 340
      Top = 10
      Width = 200
      Height = 22
      TabOrder = 5
      OnKeyPress = edtSearchKeyPress
    end
  end
  object UniDBGrid: TUniDBGrid
    Left = 0
    Top = 41
    Width = 800
    Height = 559
    Align = alClient
    TabOrder = 1
  end
  object UniDataSource: TDataSource
    Left = 24
    Top = 72
  end
end

inherited UserListFrame: TUserListFrame
  PixelsPerInch = 96
  TextHeight = 13
  object UniDBGrid: TUniDBGrid
    Left = 0
    Top = 80
    Width = 800
    Height = 520
    Hint = '
    Align = alClient
    TabOrder = 0
    DataSource = UniDataSource
  end
  object UniDataSource: TDataSource
    Left = 8
    Top = 8
  end
  object edtSearch: TUniEdit
    Left = 8
    Top = 48
    Width = 150
    Height = 22
    Hint = '
    TextHint = #29992#25143#21517#25110#30495#23454#22995#21517
    TabOrder = 1
    OnKeyPress = edtSearchKeyPress
  end
  object cmbStatus: TUniEdit
    Left = 170
    Top = 48
    Width = 100
    Height = 22
    Hint = 
    TextHint = #20840#37096
    TabOrder = 2
  end
  object btnSearch: TUniButton
    Left = 280
    Top = 48
    Width = 75
    Height = 25
    Hint = ''
    Caption = #26597#35810
    TabOrder = 3
    OnClick = btnSearchClick
  end
end

inherited UserListFrame: TUserListFrame
  inherited UniToolBar: TUniToolBar
    ExplicitTop = 2
  end
  object UniDBGrid: TUniDBGrid
    Left = 0
    Top = 40
    Width = 640
    Height = 440
    Hint = ''
    DataSource = UniDataSource
    LoadMask.Message = #21152#36733#25968#25454'...'
    Align = alClient
    TabOrder = 1
  end
  object edtSearch: TUniEdit
    Left = 8
    Top = 48
    Width = 150
    Hint = ''
    Text = ''
    TabOrder = 3
    OnKeyPress = edtSearchKeyPress
  end
  object cmbStatus: TUniEdit
    Left = 170
    Top = 48
    Width = 100
    Hint = ''
    Text = ''
    TabOrder = 4
  end
  object btnSearch: TUniButton
    Left = 276
    Top = 46
    Width = 75
    Height = 25
    Hint = ''
    Caption = #26597#35810
    TabOrder = 2
    OnClick = btnSearchClick
  end
  object UniDataSource: TDataSource
    Left = 8
    Top = 8
  end
end

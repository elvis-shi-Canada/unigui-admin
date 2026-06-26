inherited RoleListFrame: TRoleListFrame
  object pnlSearch: TUniPanel
    Left = 0
    Top = 40
    Width = 640
    Height = 40
    Hint = ''
    Align = alTop
    TabOrder = 1
    Caption = ''
    object lblSearch: TUniLabel
      Left = 8
      Top = 12
      Width = 26
      Height = 13
      Hint = ''
      Caption = #25628#32034
      TabOrder = 4
    end
    object edtSearch: TUniEdit
      Left = 80
      Top = 8
      Width = 150
      Hint = ''
      Text = ''
      TabOrder = 1
      OnKeyPress = edtSearchKeyPress
    end
    object cmbStatus: TUniComboBox
      Left = 240
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
      OnChange = cmbStatusChange
    end
    object btnSearch: TUniButton
      Left = 350
      Top = 8
      Width = 75
      Height = 25
      Hint = ''
      Caption = #26597#35810
      TabOrder = 3
      OnClick = btnSearchClick
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
end

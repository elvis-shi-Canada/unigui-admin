inherited RoleListFrame: TRoleListFrame
  PixelsPerInch = 96
  TextHeight = 13
  object pnlSearch: TUniPanel
    Left = 0
    Top = 40
    Width = 800
    Height = 40
    Hint = ''
    Align = alTop
    TabOrder = 0
    object lblSearch: TUniLabel
      Left = 8
      Top = 12
      Width = 60
      Height = 13
      Hint = ''
      Caption = #25628#32034
      TabOrder = 1
    end
    object edtSearch: TUniEdit
      Left = 80
      Top = 8
      Width = 150
      Height = 22
      Hint = ''
      TextHint = #35282#33394#32534#30721#25110#21517#31216
      TabOrder = 2
      OnKeyPress = edtSearchKeyPress
    end
    object cmbStatus: TUniComboBox
      Left = 240
      Top = 8
      Width = 100
      Height = 21
      Hint = ''
      Style = csDropDown
      ItemIndex = 0
      TabOrder = 3
      Items.Strings = (
        #20840#37096
        #21551#29992
        #31105#29992)
      OnChange = cmbStatusChange
    end
    object btnSearch: TUniButton
      Left = 350
      Top = 8
      Width = 75
      Height = 25
      Hint = ''
      Caption = #26597#35810
      TabOrder = 4
      OnClick = btnSearchClick
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
end

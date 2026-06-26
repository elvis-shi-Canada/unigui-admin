inherited MenuTreeFrame: TMenuTreeFrame
  Width = 788
  ExplicitWidth = 788
  inherited UniToolBar: TUniToolBar
    Width = 788
    ExplicitWidth = 788
  end
  object pnlContainer: TUniPanel
    Left = 0
    Top = 40
    Width = 788
    Height = 440
    Hint = ''
    Align = alClient
    TabOrder = 1
    Caption = ''
    ExplicitWidth = 640
    object pnlLeft: TUniPanel
      Left = 1
      Top = 1
      Width = 350
      Height = 438
      Hint = ''
      Align = alLeft
      TabOrder = 1
      Caption = ''
      object pnlTree: TUniPanel
        Left = 1
        Top = 1
        Width = 348
        Height = 398
        Hint = ''
        Align = alClient
        TabOrder = 1
        Caption = ''
        object lblTree: TUniLabel
          Left = 8
          Top = 8
          Width = 39
          Height = 13
          Hint = ''
          Caption = #33756#21333#26641
          TabOrder = 1
        end
        object treeMenus: TUniTreeMenu
          Left = 8
          Top = 27
          Width = 332
          Height = 523
          Hint = ''
          Align = alCustom
          Anchors = [akLeft, akTop, akRight, akBottom]
          Items.FontData = {0100000000}
          OnClick = treeMenusClick
        end
      end
      object pnlTreeToolbar: TUniPanel
        Left = 1
        Top = 399
        Width = 348
        Height = 38
        Hint = ''
        Align = alBottom
        TabOrder = 2
        Caption = ''
        object btnExpandAll: TUniButton
          Left = 8
          Top = 6
          Width = 80
          Height = 25
          Hint = ''
          Caption = #20840#37096#23637#24320
          TabOrder = 1
          OnClick = btnExpandAllClick
        end
        object btnCollapseAll: TUniButton
          Left = 94
          Top = 6
          Width = 80
          Height = 25
          Hint = ''
          Caption = #20840#37096#25240#21472
          TabOrder = 2
          OnClick = btnCollapseAllClick
        end
      end
    end
    object splitter: TUniSplitter
      Left = 351
      Top = 1
      Width = 4
      Height = 438
      Hint = ''
      Align = alLeft
      ParentColor = False
      Color = clBtnFace
    end
    object pnlRight: TUniPanel
      Left = 355
      Top = 1
      Width = 432
      Height = 438
      Hint = ''
      Align = alClient
      TabOrder = 3
      Caption = ''
      ExplicitWidth = 284
      object pnlSearch: TUniPanel
        Left = 1
        Top = 1
        Width = 430
        Height = 40
        Hint = ''
        Align = alTop
        TabOrder = 1
        Caption = ''
        ExplicitWidth = 282
        object lblSearch: TUniLabel
          Left = 8
          Top = 12
          Width = 29
          Height = 13
          Hint = ''
          Caption = #25628#32034':'
          TabOrder = 4
        end
        object edtSearch: TUniEdit
          Left = 70
          Top = 8
          Width = 150
          Hint = ''
          Text = ''
          TabOrder = 1
          OnKeyPress = edtSearchKeyPress
        end
        object cmbStatus: TUniComboBox
          Left = 230
          Top = 8
          Width = 80
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
          Left = 320
          Top = 8
          Width = 60
          Height = 25
          Hint = ''
          Caption = #25628#32034
          TabOrder = 3
          OnClick = btnSearchClick
        end
      end
      object UniDBGrid: TUniDBGrid
        Left = 1
        Top = 41
        Width = 430
        Height = 396
        Hint = ''
        LoadMask.Message = #21152#36733#25968#25454'...'
        Align = alClient
        TabOrder = 2
        OnDblClick = UniDBGridDblClick
      end
    end
  end
end

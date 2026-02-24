inherited MenuTreeFrame: TMenuTreeFrame
  PixelsPerInch = 96
  TextHeight = 13
  object pnlContainer: TUniPanel
    Left = 0
    Top = 0
    Width = 900
    Height = 600
    Hint = ''
    Align = alClient
    TabOrder = 0
    object pnlLeft: TUniPanel
      Left = 1
      Top = 1
      Width = 350
      Height = 598
      Hint = ''
      Align = alLeft
      TabOrder = 1
      object pnlTree: TUniPanel
        Left = 1
        Top = 1
        Width = 348
        Height = 558
        Hint = ''
        Align = alClient
        TabOrder = 1
        object lblTree: TUniLabel
          Left = 8
          Top = 8
          Width = 60
          Height = 13
          Hint = ''
          Caption = '菜单树'
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
          TabOrder = 0
          OnClick = treeMenusClick
          OnDragDrop = treeMenusDragDrop
          OnDragOver = treeMenusDragOver
        end
      end
      object pnlTreeToolbar: TUniPanel
        Left = 1
        Top = 559
        Width = 348
        Height = 38
        Hint = ''
        Align = alBottom
        TabOrder = 2
        object btnExpandAll: TUniButton
          Left = 8
          Top = 6
          Width = 80
          Height = 25
          Hint = ''
          Caption = '全部展开'
          TabOrder = 0
          OnClick = btnExpandAllClick
        end
        object btnCollapseAll: TUniButton
          Left = 94
          Top = 6
          Width = 80
          Height = 25
          Hint = ''
          Caption = '全部折叠'
          TabOrder = 1
          OnClick = btnCollapseAllClick
        end
      end
    end
    object splitter: TUniSplitter
      Left = 351
      Top = 1
      Width = 4
      Height = 598
      Hint = ''
      Align = alLeft
    end
    object pnlRight: TUniPanel
      Left = 355
      Top = 1
      Width = 544
      Height = 598
      Hint = ''
      Align = alClient
      TabOrder = 3
      object pnlSearch: TUniPanel
        Left = 1
        Top = 1
        Width = 542
        Height = 40
        Hint = ''
        Align = alTop
        TabOrder = 1
        object lblSearch: TUniLabel
          Left = 8
          Top = 12
          Width = 60
          Height = 13
          Hint = ''
          Caption = '搜索:'
          TabOrder = 1
        end
        object edtSearch: TUniEdit
          Left = 70
          Top = 8
          Width = 150
          Height = 22
          Hint = ''
          TextHint = '菜单编码或名称'
          TabOrder = 2
          OnKeyPress = edtSearchKeyPress
        end
        object cmbStatus: TUniComboBox
          Left = 230
          Top = 8
          Width = 80
          Height = 21
          Hint = ''
          Style = csDropDown
          ItemIndex = 0
          TabOrder = 3
          Items.Strings = (
            '全部'
            '启用'
            '禁用')
          OnChange = cmbStatusChange
        end
        object btnSearch: TUniButton
          Left = 320
          Top = 8
          Width = 60
          Height = 25
          Hint = ''
          Caption = '搜索'
          TabOrder = 4
          OnClick = btnSearchClick
        end
      end
      object UniDBGrid: TUniDBGrid
        Left = 1
        Top = 41
        Width = 542
        Height = 556
        Hint = ''
        Align = alClient
        TabOrder = 0
        DataSource = UniDataSource
        OnDblClick = UniDBGridDblClick
      end
    end
  end
end

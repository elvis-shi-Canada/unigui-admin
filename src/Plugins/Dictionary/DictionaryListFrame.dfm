object DictionaryListFrame: TDictionaryListFrame
  Left = 0
  Top = 0
  Width = 800
  Height = 600
  TabOrder = 0
  object pnlToolBar: TPanel
    Left = 0
    Top = 0
    Width = 800
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object btnAdd: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = #28155#21152
      TabOrder = 0
      OnClick = btnAddClick
    end
    object btnEdit: TButton
      Left = 89
      Top = 8
      Width = 75
      Height = 25
      Caption = #32534#36753
      TabOrder = 1
      OnClick = btnEditClick
    end
    object btnDelete: TButton
      Left = 170
      Top = 8
      Width = 75
      Height = 25
      Caption = #21024#38500
      TabOrder = 2
      OnClick = btnDeleteClick
    end
    object btnRefresh: TButton
      Left = 251
      Top = 8
      Width = 75
      Height = 25
      Caption = #21047#26032
      TabOrder = 3
      OnClick = btnRefreshClick
    end
    object pnlSearch: TPanel
      Left = 500
      Top = 0
      Width = 300
      Height = 41
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 4
      object edtSearch: TEdit
        Left = 0
        Top = 8
        Width = 185
        Height = 21
        TabOrder = 0
        TextHint = #35831#36755#20837#25628#32034#20851#38190#23383
      end
      object btnSearch: TButton
        Left = 191
        Top = 6
        Width = 75
        Height = 25
        Caption = #25628#32034
        TabOrder = 1
        OnClick = btnSearchClick
      end
    end
  end
  object pcMain: TPageControl
    Left = 0
    Top = 41
    Width = 800
    Height = 538
    ActivePage = tsDictionaries
    Align = alClient
    TabOrder = 1
    object tsDictionaries: TTabSheet
      Caption = #25968#25463#23383#20856
      object grdDictionaries: TStringGrid
        Left = 0
        Top = 0
        Width = 792
        Height = 510
        Align = alClient
        ColCount = 6
        FixedCols = 0
        RowCount = 2
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
        TabOrder = 0
        OnSelectCell = grdDictionariesSelectCell
      end
    end
    object tsDictionaryItems: TTabSheet
      Caption = #23383#20856#39033
      ImageIndex = 1
      object grdDictionaryItems: TStringGrid
        Left = 0
        Top = 0
        Width = 792
        Height = 510
        Align = alClient
        ColCount = 6
        FixedCols = 0
        RowCount = 2
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
        TabOrder = 0
      end
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 579
    Width = 800
    Height = 21
    Panels = <>
    SimplePanel = True
  end
  object splMain: TSplitter
    Left = 0
    Top = 41
    Width = 800
    Height = 3
    Cursor = crVSplit
    Align = alTop
    ExplicitTop = 145
  end
end

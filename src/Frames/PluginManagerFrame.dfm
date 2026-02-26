object PluginManagerFrame: TPluginManagerFrame
  Left = 0
  Top = 0
  Width = 900
  Height = 650
  TabOrder = 0
  object pnlToolBar: TPanel
    Left = 0
    Top = 0
    Width = 900
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object btnLoad: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = #21152#36733
      TabOrder = 0
      OnClick = btnLoadClick
    end
    object btnUnload: TButton
      Left = 89
      Top = 8
      Width = 75
      Height = 25
      Caption = #21368#36733
      TabOrder = 1
      OnClick = btnUnloadClick
    end
    object btnRefresh: TButton
      Left = 170
      Top = 8
      Width = 75
      Height = 25
      Caption = #21047#26032
      TabOrder = 2
      OnClick = btnRefreshClick
    end
  end
  object pnlMain: TPanel
    Left = 0
    Top = 41
    Width = 900
    Height = 569
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object pnlLeft: TPanel
      Left = 0
      Top = 0
      Width = 300
      Height = 569
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object lbPlugins: TListBox
        Left = 0
        Top = 0
        Width = 300
        Height = 569
        Align = alClient
        ItemHeight = 13
        TabOrder = 0
        OnClick = lbPluginsClick
      end
    end
    object splVertical: TSplitter
      Left = 300
      Top = 0
      Width = 4
      Height = 569
      ExplicitLeft = 305
    end
    object pnlRight: TPanel
      Left = 304
      Top = 0
      Width = 596
      Height = 569
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 2
      object grpPluginInfo: TPanel
        Left = 0
        Top = 0
        Width = 596
        Height = 200
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object lblPluginID: TLabel
          Left = 8
          Top = 8
          Width = 48
          Height = 13
          Caption = #25551#20214#65306
        end
        object lblPluginIDValue: TLabel
          Left = 80
          Top = 8
          Width = 508
          Height = 13
          AutoSize = False
          Caption = -
        end
        object lblDisplayName: TLabel
          Left = 8
          Top = 30
          Width = 60
          Height = 13
          Caption = #26174#31034#21517#31216#65306
        end
        object lblDisplayNameValue: TLabel
          Left = 80
          Top = 30
          Width = 508
          Height = 13
          AutoSize = False
          Caption = -
        end
        object lblVersion: TLabel
          Left = 8
          Top = 52
          Width = 36
          Height = 13
          Caption = #29256#26412#65306
        end
        object lblVersionValue: TLabel
          Left = 80
          Top = 52
          Width = 508
          Height = 13
          AutoSize = False
          Caption = -
        end
        object lblAuthor: TLabel
          Left = 8
          Top = 74
          Width = 36
          Height = 13
          Caption = #20316#32773#65306
        end
        object lblAuthorValue: TLabel
          Left = 80
          Top = 74
          Width = 508
          Height = 13
          AutoSize = False
          Caption = -
        end
        object lblCategory: TLabel
          Left = 8
          Top = 96
          Width = 48
          Height = 13
          Caption = #20998#31867#65306
        end
        object lblCategoryValue: TLabel
          Left = 80
          Top = 96
          Width = 508
          Height = 13
          AutoSize = False
          Caption = -
        end
        object lblDescription: TLabel
          Left = 8
          Top = 118
          Width = 48
          Height = 13
          Caption = #25551#36848#65306
        end
        object memDescription: TMemo
          Left = 8
          Top = 137
          Width = 580
          Height = 56
          Align = alCustom
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 0
        end
      end
      object grpDependencies: TPanel
        Left = 0
        Top = 200
        Width = 596
        Height = 180
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object grdDependencies: TStringGrid
          Left = 0
          Top = 0
          Width = 596
          Height = 180
          Align = alClient
          ColCount = 4
          FixedCols = 0
          RowCount = 2
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
          TabOrder = 0
        end
      end
      object grpDependents: TPanel
        Left = 0
        Top = 380
        Width = 596
        Height = 189
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 2
        object grdDependents: TStringGrid
          Left = 0
          Top = 0
          Width = 596
          Height = 189
          Align = alClient
          ColCount = 2
          FixedCols = 0
          RowCount = 2
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
          TabOrder = 0
        end
      end
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 610
    Width = 900
    Height = 40
    Panels = <>
    SimplePanel = True
  end
end

object PluginManagerFrame: TPluginManagerFrame
  Left = 0
  Top = 0
  Width = 900
  Height = 650
  TabOrder = 0
  object pnlToolBar: TUniPanel
    Left = 0
    Top = 0
    Width = 900
    Height = 41
    Align = alTop
    TabOrder = 0
    object btnLoad: TUniButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = #21152#36733
      TabOrder = 0
      OnClick = btnLoadClick
    end
    object btnUnload: TUniButton
      Left = 89
      Top = 8
      Width = 75
      Height = 25
      Caption = #21368#36733
      TabOrder = 1
      OnClick = btnUnloadClick
    end
    object btnRefresh: TUniButton
      Left = 170
      Top = 8
      Width = 75
      Height = 25
      Caption = #21047#26032
      TabOrder = 2
      OnClick = btnRefreshClick
    end
  end
  object pnlInfo: TUniPanel
    Left = 0
    Top = 41
    Width = 900
    Height = 100
    Align = alTop
    TabOrder = 1
    object memInfo: TUniMemo
      Left = 1
      Top = 1
      Width = 898
      Height = 98
      Align = alClient
      TabOrder = 0
      ReadOnly = True
    end
  end
  object pnlList: TUniPanel
    Left = 0
    Top = 141
    Width = 900
    Height = 509
    Align = alClient
    TabOrder = 2
    object grdPlugins: TUniStringGrid
      Left = 1
      Top = 1
      Width = 898
      Height = 507
      Align = alClient
      TabOrder = 0
      FixedColor = clWindow
      Options = [goEditing, goAlwaysShowEditor]
    end
  end
end

inherited SplitterTemplate: TSplitterTemplate
  Left = 0
  Top = 0
  Width = 800
  Height = 400
  TabOrder = 0
  object pnlLeft: TUniPanel
    Left = 0
    Top = 0
    Width = 250
    Height = 400
    Align = alLeft
    Color = clWindow
    ParentColor = False
    TabOrder = 0
    object lblLeftTitle: TUniLabel
      Left = 16
      Top = 16
      Width = 200
      Height = 24
      Caption = #24037#20391#38754#26495
      ParentFont = False
      Font.Color = clHighlight
      Font.Height = -19
      Font.Style = [fsBold]
    end
    object treeLeft: TUniTreeView
      Left = 16
      Top = 48
      Width = 218
      Height = 336
      TabOrder = 0
    end
  end
  object splitterVertical: TUniSplitter
    Left = 250
    Top = 0
    Width = 5
    Height = 400
    ResizeStyle = rsUpdate
  end
  object pnlRight: TUniPanel
    Left = 255
    Top = 0
    Width = 545
    Height = 400
    Align = alClient
    Color = clWindow
    ParentColor = False
    TabOrder = 2
    object lblRightTitle: TUniLabel
      Left = 16
      Top = 16
      Width = 200
      Height = 24
      Caption = #21491#20391#38754#26495
      ParentFont = False
      Font.Color = clHighlight
      Font.Height = -19
      Font.Style = [fsBold]
    end
    object memoRight: TUniMemo
      Left = 16
      Top = 48
      Width = 513
      Height = 336
      TabOrder = 0
      Lines.Strings = (
        #21491#20391#20869#23481#21306#22495)
    end
  end
end

object TabSheetTemplate: TTabSheetTemplate
  Left = 0
  Top = 0
  Width = 800
  Height = 400
  Caption = TabSheetTemplate'
  TabOrder = 0
  object UniPageControl1: TUniPageControl
    Left = 16
    Top = 16
    Width = 768
    Height = 368
    ActivePage = tabSheet1
    TabOrder = 0
    object tabSheet1: TUniTabSheet
      Caption = #36873#39033#21345 1
      object lblTab1Title: TUniLabel
        Left = 16
        Top = 16
        Width = 200
        Height = 24
        Caption = #36873#39033#21345 1 #20869#23481
        ParentFont = False
        Font.Color = clHighlight
        Font.Height = -19
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
      end
      object memoTab1: TUniMemo
        Left = 16
        Top = 48
        Width = 736
        Height = 304
        TabOrder = 0
        Lines.Strings = (
          #36825#26159#36873#39033#21345 1 #30340#20869#23481#21306#22495)
      end
    end
    object tabSheet2: TUniTabSheet
      Caption = #36873#39033#21345 2
      object lblTab2Title: TUniLabel
        Left = 16
        Top = 16
        Width = 200
        Height = 24
        Caption = #36873#39033#21345 2 #20869#23481
        ParentFont = False
        Font.Color = clHighlight
        Font.Height = -19
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
      end
      object grdTab2: TUniStringGrid
        Left = 16
        Top = 48
        Width = 736
        Height = 304
        ColCount = 4
        RowCount = 10
        TabOrder = 0
      end
    end
    object tabSheet3: TUniTabSheet
      Caption = #36873#39033#21345 3
      object lblTab3Title: TUniLabel
        Left = 16
        Top = 16
        Width = 200
        Height = 24
        Caption = #36873#39033#21345 3 #20869#23481
        ParentFont = False
        Font.Color = clHighlight
        Font.Height = -19
        Font.Name = 'Segoe UI
        Font.Style = [fsBold]
      end
      object grpTab3: TUniGroupBox
        Left = 16
        Top = 48
        Width = 736
        Height = 304
        Caption = #35774#32622
        TabOrder = 0
        object chkTab3Option1: TUniCheckBox
          Left = 16
          Top = 24
          Width = 97
          Height = 17
          Caption = #36873#39033 1'
          TabOrder = 0
        end
        object chkTab3Option2: TUniCheckBox
          Left = 16
          Top = 56
          Width = 97
          Height = 17
          Caption = #36873#39033 2
          TabOrder = 1
        end
        object chkTab3Option3: TUniCheckBox
          Left = 16
          Top = 88
          Width = 97
          Height = 17
          Caption = '#36873#39033 3
          TabOrder = 2
        end
      end
    end
  end
end

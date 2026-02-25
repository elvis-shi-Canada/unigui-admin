object TabSheetTemplate: TTabSheetTemplate
  Left = 0
  Top = 0
  Width = 800
  Height = 400
  Caption = 'TabSheetTemplate'
  TabOrder = 0
  object UniPageControl1: TUniPageControl
    Left = 16
    Top = 16
    Width = 768
    Height = 368
    ActivePage = tabSheet1
    TabOrder = 0
    object tabSheet1: TUniTabSheet
      Caption = '选项卡 1'
      object lblTab1Title: TUniLabel
        Left = 16
        Top = 16
        Width = 200
        Height = 24
        Caption = '选项卡 1 内容'
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
          '这是选项卡 1 的内容区域')
      end
    end
    object tabSheet2: TUniTabSheet
      Caption = '选项卡 2'
      object lblTab2Title: TUniLabel
        Left = 16
        Top = 16
        Width = 200
        Height = 24
        Caption = '选项卡 2 内容'
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
      Caption = '选项卡 3'
      object lblTab3Title: TUniLabel
        Left = 16
        Top = 16
        Width = 200
        Height = 24
        Caption = '选项卡 3 内容'
        ParentFont = False
        Font.Color = clHighlight
        Font.Height = -19
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
      end
      object grpTab3: TUniGroupBox
        Left = 16
        Top = 48
        Width = 736
        Height = 304
        Caption = '设置'
        TabOrder = 0
        object chkTab3Option1: TUniCheckBox
          Left = 16
          Top = 24
          Width = 97
          Height = 17
          Caption = '选项 1'
          TabOrder = 0
        end
        object chkTab3Option2: TUniCheckBox
          Left = 16
          Top = 56
          Width = 97
          Height = 17
          Caption = '选项 2'
          TabOrder = 1
        end
        object chkTab3Option3: TUniCheckBox
          Left = 16
          Top = 88
          Width = 97
          Height = 17
          Caption = '选项 3'
          TabOrder = 2
        end
      end
    end
  end
end

inherited IconSelector: TIconSelector
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TUniPanel
    Left = 0
    Top = 0
    Width = 692
    Height = 500
    Hint = ''
    Align = alClient
    TabOrder = 0
    object pnlSearch: TUniPanel
      Left = 1
      Top = 1
      Width = 690
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
        Caption = '搜索图标:'
        TabOrder = 1
      end
      object edtSearch: TUniEdit
        Left = 70
        Top = 8
        Width = 150
        Height = 22
        Hint = ''
        TextHint = '输入图标名称或类名'
        TabOrder = 2
        OnKeyPress = edtSearchKeyPress
      end
      object btnSearch: TUniButton
        Left = 226
        Top = 8
        Width = 60
        Height = 25
        Hint = ''
        Caption = '搜索'
        TabOrder = 3
        OnClick = btnSearchClick
      end
      object pnlCategories: TUniPanel
        Left = 300
        Top = 1
        Width = 200
        Height = 38
        Hint = ''
        TabOrder = 4
        object lblCategories: TUniLabel
          Left = 8
          Top = 12
          Width = 60
          Height = 13
          Hint = ''
          Caption = '类别:'
          TabOrder = 1
        end
        object cmbCategories: TUniComboBox
          Left = 70
          Top = 8
          Width = 120
          Height = 21
          Hint = ''
          Style = csDropDown
          ItemIndex = 0
          TabOrder = 2
          Items.Strings = (
            '全部'
            '导航'
            '操作'
            '文件'
            '数据'
            '图表'
            '媒体'
            '其他')
          OnChange = cmbCategoriesChange
        end
      end
      object chkLarge: TUniCheckBox
        Left = 520
        Top = 12
        Width = 80
        Height = 17
        Hint = ''
        Caption = '大图标'
        TabOrder = 5
        OnClick = chkLargeClick
      end
    end
    object pnlIcons: TUniPanel
      Left = 1
      Top = 41
      Width = 690
      Height = 418
      Hint = ''
      Align = alClient
      TabOrder = 2
      object scrollIcons: TUniScrollBox
        Left = 1
        Top = 1
        Width = 688
        Height = 416
        Hint = ''
        Align = alClient
        TabOrder = 1
        object pnlIconGrid: TUniPanel
          Left = 0
          Top = 0
          Width = 666
          Height = 394
          Hint = ''
          Align = alClient
          TabOrder = 0
        end
      end
    end
    object pnlPreview: TUniPanel
      Left = 1
      Top = 459
      Width = 690
      Height = 40
      Hint = ''
      Align = alBottom
      TabOrder = 3
      object lblPreview: TUniLabel
        Left = 8
        Top = 12
        Width = 60
        Height = 13
        Hint = ''
        Caption = '已选择:'
        TabOrder = 1
      end
      object lblIconName: TUniLabel
        Left = 70
        Top = 12
        Width = 400
        Height = 13
        Hint = ''
        Caption = '未选择'
        TabOrder = 2
      end
    end
    object pnlBottom: TUniPanel
      Left = 1
      Top = 489
      Width = 690
      Height = 10
      Hint = ''
      Align = alBottom
      TabOrder = 4
      Visible = False
      object btnOK: TUniButton
        Left = 540
        Top = 8
        Width = 75
        Height = 25
        Hint = ''
        Caption = '确定'
        ModalResult = 1
        TabOrder = 0
        OnClick = btnOKClick
      end
      object btnCancel: TUniButton
        Left = 620
        Top = 8
        Width = 75
        Height = 25
        Hint = ''
        Caption = '取消'
        ModalResult = 2
        TabOrder = 1
        OnClick = btnCancelClick
      end
    end
  end
end

inherited IconSelector: TIconSelector
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TUniPanel
    Left = 0
    Top = 0
    Width = 692
    Height = 500
    Hint = '
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
        Caption = #25628#32034#22270#26631:
        TabOrder = 1
      end
      object edtSearch: TUniEdit
        Left = 70
        Top = 8
        Width = 150
        Height = 22
        Hint = '
        TextHint = #36755#20837#22270#26631#21517#31216#25110#31867#21517
        TabOrder = 2
        OnKeyPress = edtSearchKeyPress
      end
      object btnSearch: TUniButton
        Left = 226
        Top = 8
        Width = 60
        Height = 25
        Hint = 
        Caption = #25628#32034
        TabOrder = 3
        OnClick = btnSearchClick
      end
      object pnlCategories: TUniPanel
        Left = 300
        Top = 1
        Width = 200
        Height = 38
        Hint = '
        TabOrder = 4
        object lblCategories: TUniLabel
          Left = 8
          Top = 12
          Width = 60
          Height = 13
          Hint = ''
          Caption = #31867#21035:
          TabOrder = 1
        end
        object cmbCategories: TUniComboBox
          Left = 70
          Top = 8
          Width = 120
          Height = 21
          Hint = '
          Style = csDropDown
          ItemIndex = 0
          TabOrder = 2
          Items.Strings = (
            #20840#37096
            #23548#33322
            #25805#20316
            #25991#20214
            #25968#25454
            #22270#34920
            #23186#20307
            #20854#20182)
          OnChange = cmbCategoriesChange
        end
      end
      object chkLarge: TUniCheckBox
        Left = 520
        Top = 12
        Width = 80
        Height = 17
        Hint = 
        Caption = #22823#22270#26631
        TabOrder = 5
        OnClick = chkLargeClick
      end
    end
    object pnlIcons: TUniPanel
      Left = 1
      Top = 41
      Width = 690
      Height = 418
      Hint = '
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
        Caption = #24050#36873#25321:
        TabOrder = 1
      end
      object lblIconName: TUniLabel
        Left = 70
        Top = 12
        Width = 400
        Height = 13
        Hint = '
        Caption = #26410#36873#25321
        TabOrder = 2
      end
    end
    object pnlBottom: TUniPanel
      Left = 1
      Top = 489
      Width = 690
      Height = 10
      Hint = '
      Align = alBottom
      TabOrder = 4
      Visible = False
      object btnOK: TUniButton
        Left = 540
        Top = 8
        Width = 75
        Height = 25
        Hint = '
        Caption = #30830#23450
        ModalResult = 1
        TabOrder = 0
        OnClick = btnOKClick
      end
      object btnCancel: TUniButton
        Left = 620
        Top = 8
        Width = 75
        Height = 25
        Hint = '
        Caption = '#21462#28040
        ModalResult = 2
        TabOrder = 1
        OnClick = btnCancelClick
      end
    end
  end
end

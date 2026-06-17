object IconSelector: TIconSelector
  Left = 0
  Top = 0
  ClientHeight = 441
  ClientWidth = 624
  Caption = ''
  OldCreateOrder = False
  MonitoredKeys.Keys = <>
  TextHeight = 15
  object pnlMain: TUniPanel
    Left = 0
    Top = 0
    Width = 624
    Height = 441
    Hint = ''
    Align = alClient
    TabOrder = 0
    Caption = ''
    object pnlSearch: TUniPanel
      Left = 1
      Top = 1
      Width = 622
      Height = 40
      Hint = ''
      Align = alTop
      TabOrder = 1
      Caption = ''
      object lblSearch: TUniLabel
        Left = 8
        Top = 12
        Width = 55
        Height = 13
        Hint = ''
        Caption = #25628#32034#22270#26631':'
        TabOrder = 4
      end
      object edtSearch: TUniEdit
        Left = 70
        Top = 8
        Width = 150
        Hint = ''
        Text = ''
        TabOrder = 2
        OnKeyPress = edtSearchKeyPress
      end
      object btnSearch: TUniButton
        Left = 226
        Top = 8
        Width = 60
        Height = 25
        Hint = ''
        Caption = #25628#32034
        TabOrder = 3
        OnClick = btnSearchClick
      end
      object pnlCategories: TUniPanel
        Left = 300
        Top = 1
        Width = 200
        Height = 38
        Hint = ''
        TabOrder = 1
        Caption = ''
        object lblCategories: TUniLabel
          Left = 8
          Top = 12
          Width = 29
          Height = 13
          Hint = ''
          Caption = #31867#21035':'
          TabOrder = 2
        end
        object cmbCategories: TUniComboBox
          Left = 70
          Top = 8
          Width = 120
          Height = 21
          Hint = ''
          Text = ''
          Items.Strings = (
            #37711#12585#20788
            #28725#33392#22469
            #37823#23940#32148
            #37826#22246#27426
            #37825#29256#23873
            #37733#25424#12291
            #28655#25485#32139
            #37711#26421#31916)
          TabOrder = 1
          IconItems = <>
          OnChange = cmbCategoriesChange
        end
      end
      object chkLarge: TUniCheckBox
        Left = 520
        Top = 12
        Width = 80
        Height = 17
        Hint = ''
        Caption = #22823#22270#26631
        TabOrder = 5
        OnClick = chkLargeClick
      end
    end
    object pnlIcons: TUniPanel
      Left = 1
      Top = 41
      Width = 622
      Height = 349
      Hint = ''
      Align = alClient
      TabOrder = 2
      Caption = ''
      object scrollIcons: TUniScrollBox
        Left = 1
        Top = 1
        Width = 620
        Height = 347
        Hint = ''
        Align = alClient
        TabOrder = 1
        object pnlIconGrid: TUniPanel
          Left = 0
          Top = 0
          Width = 618
          Height = 345
          Hint = ''
          Align = alClient
          TabOrder = 0
          Caption = ''
        end
      end
    end
    object pnlPreview: TUniPanel
      Left = 1
      Top = 390
      Width = 622
      Height = 40
      Hint = ''
      Align = alBottom
      TabOrder = 3
      Caption = ''
      object lblPreview: TUniLabel
        Left = 8
        Top = 12
        Width = 42
        Height = 13
        Hint = ''
        Caption = #24050#36873#25321':'
        TabOrder = 1
      end
      object lblIconName: TUniLabel
        Left = 70
        Top = 12
        Width = 39
        Height = 13
        Hint = ''
        Caption = #26410#36873#25321
        TabOrder = 2
      end
    end
    object pnlBottom: TUniPanel
      Left = 1
      Top = 430
      Width = 622
      Height = 10
      Hint = ''
      Visible = False
      Align = alBottom
      TabOrder = 4
      Caption = ''
      object btnOK: TUniButton
        Left = 540
        Top = 8
        Width = 75
        Height = 25
        Hint = ''
        Caption = #30830#23450
        ModalResult = 1
        TabOrder = 1
        OnClick = btnOKClick
      end
      object btnCancel: TUniButton
        Left = 620
        Top = 8
        Width = 75
        Height = 25
        Hint = ''
        Caption = #21462#28040
        ModalResult = 2
        TabOrder = 2
        OnClick = btnCancelClick
      end
    end
  end
end

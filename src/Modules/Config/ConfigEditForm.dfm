inherited ConfigEditForm: TConfigEditForm
  Caption = #37197#32622#32534#36753
  ClientHeight = 480
  ClientWidth = 550
  PixelsPerInch = 96
  TextHeight = 13
  object UniPanelMain: TUniPanel
    Left = 0
    Top = 0
    Width = 550
    Height = 440
    Hint = ''
    Align = alClient
    TabOrder = 0
    object UniLabelKey: TUniLabel
      Left = 16
      Top = 16
      Width = 60
      Height = 13
      Hint = ''
      Caption = #37197#32622#38190*
      TabOrder = 1
    end
    object UniEditKey: TUniEdit
      Left = 90
      Top = 13
      Width = 200
      Height = 22
      Hint = ''
      TextHint = #22914: system.title
      TabOrder = 2
    end
    object UniLabelValue: TUniLabel
      Left = 16
      Top = 48
      Width = 60
      Height = 13
      Hint = ''
      Caption = #37197#32622#20540*
      TabOrder = 3
    end
    object UniMemoValue: TUniMemo
      Left = 90
      Top = 45
      Width = 440
      Height = 80
      Hint = ''
      Lines.Strings = (
        '')
      TabOrder = 4
    end
    object UniLabelCategory: TUniLabel
      Left = 16
      Top = 136
      Width = 60
      Height = 13
      Hint = ''
      Caption = #20998#31867
      TabOrder = 5
    end
    object UniComboBoxCategory: TUniComboBox
      Left = 90
      Top = 133
      Width = 150
      Height = 21
      Hint = ''
      Style = csDropDown
      ItemIndex = 0
      TabOrder = 6
      Items.Strings = (
        'System'
        'Security'
        'Email'
        'SMS'
        'Storage')
    end
    object UniLabelDescription: TUniLabel
      Left = 16
      Top = 168
      Width = 60
      Height = 13
      Hint = ''
      Caption = #25551#36848
      TabOrder = 7
    end
    object UniMemoDescription: TUniMemo
      Left = 90
      Top = 165
      Width = 440
      Height = 60
      Hint = ''
      Lines.Strings = (
        '')
      TabOrder = 8
    end
    object UniLabelValueType: TUniLabel
      Left = 16
      Top = 232
      Width = 60
      Height = 13
      Hint = ''
      Caption = #20540#31867#22411
      TabOrder = 9
    end
    object UniComboBoxValueType: TUniComboBox
      Left = 90
      Top = 229
      Width = 150
      Height = 21
      Hint = ''
      Style = csDropDown
      ItemIndex = 0
      TabOrder = 10
      Items.Strings = (
        'string'
        'integer'
        'boolean'
        'float'
        'json'
        'xml')
    end
    object UniLabelSortOrder: TUniLabel
      Left = 16
      Top = 264
      Width = 60
      Height = 13
      Hint = ''
      Caption = #25490#24207
      TabOrder = 11
    end
    object UniEditSortOrder: TUniEdit
      Left = 90
      Top = 261
      Width = 100
      Height = 22
      Hint = ''
      TextHint = '0'
      TabOrder = 12
    end
    object UniLabelStatus: TUniLabel
      Left = 16
      Top = 296
      Width = 60
      Height = 13
      Hint = ''
      Caption = #29366#24577
      TabOrder = 13
    end
    object UniCheckBoxStatus: TUniCheckBox
      Left = 90
      Top = 296
      Width = 60
      Height = 17
      Hint = ''
      Caption = #21551#29992
      Checked = True
      TabOrder = 14
    end
  end
  object UniButtonOK: TUniButton
    Left = 380
    Top = 448
    Width = 75
    Height = 25
    Hint = ''
    Caption = #30830#23450
    ModalResult = 1
    TabOrder = 1
    OnClick = UniButtonOKClick
  end
  object UniButtonCancel: TUniButton
    Left = 460
    Top = 448
    Width = 75
    Height = 25
    Hint = ''
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 2
    OnClick = UniButtonCancelClick
  end
end

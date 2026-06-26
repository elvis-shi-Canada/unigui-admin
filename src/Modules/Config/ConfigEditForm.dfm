object ConfigEditForm: TConfigEditForm
  Left = 0
  Top = 0
  ClientHeight = 480
  ClientWidth = 550
  Caption = #37197#32622#32534#36753
  OldCreateOrder = False
  MonitoredKeys.Keys = <>
  TextHeight = 15
  object UniPanelMain: TUniPanel
    Left = 0
    Top = 0
    Width = 550
    Height = 480
    Hint = ''
    Align = alClient
    TabOrder = 0
    Caption = ''
    object UniLabelKey: TUniLabel
      Left = 16
      Top = 16
      Width = 44
      Height = 13
      Hint = ''
      Caption = #37197#32622#38190'*'
    end
    object UniEditKey: TUniEdit
      Left = 90
      Top = 13
      Width = 200
      Hint = ''
      Text = ''
      TabOrder = 1
    end
    object UniLabelValue: TUniLabel
      Left = 16
      Top = 48
      Width = 44
      Height = 13
      Hint = ''
      Caption = #37197#32622#20540'*'
    end
    object UniMemoValue: TUniMemo
      Left = 90
      Top = 45
      Width = 440
      Height = 80
      Hint = ''
      Lines.Strings = (
        '')
      TabOrder = 3
    end
    object UniLabelCategory: TUniLabel
      Left = 16
      Top = 136
      Width = 26
      Height = 13
      Hint = ''
      Caption = #20998#31867
    end
    object UniComboBoxCategory: TUniComboBox
      Left = 90
      Top = 133
      Width = 150
      Height = 21
      Hint = ''
      Text = ''
      Items.Strings = (
        'System'
        'Security'
        'Email'
        'SMS'
        'Storage')
      TabOrder = 5
      IconItems = <>
    end
    object UniLabelDescription: TUniLabel
      Left = 16
      Top = 168
      Width = 26
      Height = 13
      Hint = ''
      Caption = #25551#36848
    end
    object UniMemoDescription: TUniMemo
      Left = 90
      Top = 165
      Width = 440
      Height = 60
      Hint = ''
      Lines.Strings = (
        '')
      TabOrder = 7
    end
    object UniLabelValueType: TUniLabel
      Left = 16
      Top = 232
      Width = 39
      Height = 13
      Hint = ''
      Caption = #20540#31867#22411
    end
    object UniComboBoxValueType: TUniComboBox
      Left = 90
      Top = 229
      Width = 150
      Height = 21
      Hint = ''
      Text = ''
      Items.Strings = (
        'string'
        'integer'
        'boolean'
        'float'
        'json'
        'xml')
      TabOrder = 9
      IconItems = <>
    end
    object UniLabelSortOrder: TUniLabel
      Left = 16
      Top = 264
      Width = 26
      Height = 13
      Hint = ''
      Caption = #25490#24207
    end
    object UniEditSortOrder: TUniEdit
      Left = 90
      Top = 261
      Width = 100
      Hint = ''
      Text = ''
      TabOrder = 11
    end
    object UniLabelStatus: TUniLabel
      Left = 16
      Top = 296
      Width = 26
      Height = 13
      Hint = ''
      Caption = #29366#24577
    end
    object UniCheckBoxStatus: TUniCheckBox
      Left = 90
      Top = 296
      Width = 60
      Height = 17
      Hint = ''
      Checked = True
      Caption = #21551#29992
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

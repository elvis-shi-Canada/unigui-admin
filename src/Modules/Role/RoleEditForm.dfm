object RoleEditForm: TRoleEditForm
  Left = 0
  Top = 0
  ClientHeight = 400
  ClientWidth = 500
  Caption = #35282#33394#32534#36753
  OldCreateOrder = False
  MonitoredKeys.Keys = <>
  TextHeight = 15
  object pnlMain: TUniPanel
    Left = 0
    Top = 0
    Width = 500
    Height = 360
    Hint = ''
    Align = alClient
    TabOrder = 0
    Caption = ''
    object lblRoleCode: TUniLabel
      Left = 16
      Top = 16
      Width = 57
      Height = 13
      Hint = ''
      Caption = #35282#33394#32534#30721'*'
    end
    object edtRoleCode: TUniEdit
      Left = 90
      Top = 13
      Width = 200
      Hint = ''
      Text = ''
      TabOrder = 1
    end
    object lblRoleName: TUniLabel
      Left = 16
      Top = 48
      Width = 57
      Height = 13
      Hint = ''
      Caption = #35282#33394#21517#31216'*'
    end
    object edtRoleName: TUniEdit
      Left = 90
      Top = 45
      Width = 200
      Hint = ''
      Text = ''
      TabOrder = 3
    end
    object lblDescription: TUniLabel
      Left = 16
      Top = 80
      Width = 26
      Height = 13
      Hint = ''
      Caption = #25551#36848
    end
    object memDescription: TUniMemo
      Left = 90
      Top = 77
      Width = 380
      Height = 80
      Hint = ''
      Lines.Strings = (
        '')
      TabOrder = 5
    end
    object lblDataScope: TUniLabel
      Left = 16
      Top = 168
      Width = 52
      Height = 13
      Hint = ''
      Caption = #25968#25454#33539#22260
    end
    object cmbDataScope: TUniComboBox
      Left = 90
      Top = 165
      Width = 150
      Height = 21
      Hint = ''
      Text = ''
      Items.Strings = (
        #37711#12585#20788
        #37832#57604#20788#38338'?'
        #37832#57604#20788#38338#12581#24375#28051#23340#39559
        #28000#21614#28272#27996'?')
      TabOrder = 7
      IconItems = <>
    end
    object lblSortOrder: TUniLabel
      Left = 16
      Top = 200
      Width = 26
      Height = 13
      Hint = ''
      Caption = #25490#24207
    end
    object spnSortOrder: TUniSpinEdit
      Left = 90
      Top = 197
      Width = 100
      Hint = ''
      TabOrder = 9
    end
    object lblStatus: TUniLabel
      Left = 16
      Top = 232
      Width = 26
      Height = 13
      Hint = ''
      Caption = #29366#24577
    end
    object chkStatus: TUniCheckBox
      Left = 90
      Top = 232
      Width = 60
      Height = 17
      Hint = ''
      Checked = True
      Caption = #21551#29992
      TabOrder = 12
    end
  end
  object pnlBottom: TUniPanel
    Left = 0
    Top = 360
    Width = 500
    Height = 40
    Hint = ''
    Align = alBottom
    TabOrder = 1
    Caption = ''
    object btnSave: TUniButton
      Left = 340
      Top = 8
      Width = 75
      Height = 25
      Hint = ''
      Caption = #20445#23384
      ModalResult = 1
      TabOrder = 1
    end
    object btnCancel: TUniButton
      Left = 420
      Top = 8
      Width = 75
      Height = 25
      Hint = ''
      Caption = #21462#28040
      ModalResult = 2
      TabOrder = 2
    end
  end
end

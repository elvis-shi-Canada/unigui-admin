object UserEditForm: TUserEditForm
  Left = 0
  Top = 0
  ClientHeight = 480
  ClientWidth = 500
  Caption = #29992#25143#32534#36753
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
    object lblUserName: TUniLabel
      Left = 16
      Top = 16
      Width = 44
      Height = 13
      Hint = ''
      Caption = #29992#25143#21517'*'
      TabOrder = 2
    end
    object edtUserName: TUniEdit
      Left = 90
      Top = 13
      Width = 200
      Hint = ''
      Text = ''
      TabOrder = 1
    end
    object lblRealName: TUniLabel
      Left = 16
      Top = 48
      Width = 57
      Height = 13
      Hint = ''
      Caption = #30495#23454#22995#21517'*'
      TabOrder = 4
    end
    object edtRealName: TUniEdit
      Left = 90
      Top = 45
      Width = 200
      Hint = ''
      Text = ''
      TabOrder = 3
    end
    object lblEmail: TUniLabel
      Left = 16
      Top = 80
      Width = 31
      Height = 13
      Hint = ''
      Caption = #37038#31665'*'
      TabOrder = 6
    end
    object edtEmail: TUniEdit
      Left = 90
      Top = 77
      Width = 200
      Hint = ''
      Text = ''
      TabOrder = 5
    end
    object lblPhone: TUniLabel
      Left = 16
      Top = 112
      Width = 26
      Height = 13
      Hint = ''
      Caption = #25163#26426
      TabOrder = 8
    end
    object edtPhone: TUniEdit
      Left = 90
      Top = 109
      Width = 200
      Hint = ''
      Text = ''
      TabOrder = 7
    end
    object lblPassword: TUniLabel
      Left = 16
      Top = 144
      Width = 26
      Height = 13
      Hint = ''
      Caption = #23494#30721
      TabOrder = 14
    end
    object edtPassword: TUniEdit
      Left = 90
      Top = 141
      Width = 200
      Hint = ''
      Text = ''
      PasswordChar = '*'
      TabOrder = 8
    end
    object lblConfirmPassword: TUniLabel
      Left = 16
      Top = 176
      Width = 52
      Height = 13
      Hint = ''
      Caption = #30830#35748#23494#30721
      TabOrder = 15
    end
    object edtConfirmPassword: TUniEdit
      Left = 90
      Top = 173
      Width = 200
      Hint = ''
      Text = ''
      PasswordChar = '*'
      TabOrder = 9
    end
    object lblRole: TUniLabel
      Left = 16
      Top = 208
      Width = 26
      Height = 13
      Hint = ''
      Caption = #35282#33394
      TabOrder = 10
    end
    object cmbRole: TUniComboBox
      Left = 90
      Top = 205
      Width = 200
      Height = 21
      Hint = ''
      Text = ''
      TabOrder = 10
      IconItems = <>
    end
    object lblStatus: TUniLabel
      Left = 16
      Top = 240
      Width = 26
      Height = 13
      Hint = ''
      Caption = #29366#24577
      TabOrder = 11
    end
    object chkStatus: TUniCheckBox
      Left = 90
      Top = 240
      Width = 60
      Height = 17
      Hint = ''
      Checked = True
      Caption = #21551#29992
      TabOrder = 12
    end
    object lblRemark: TUniLabel
      Left = 16
      Top = 272
      Width = 26
      Height = 13
      Hint = ''
      Caption = #22791#27880
      TabOrder = 14
    end
    object memRemark: TUniMemo
      Left = 90
      Top = 269
      Width = 380
      Height = 80
      Hint = ''
      Lines.Strings = (
        '')
      TabOrder = 13
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

inherited UserEditForm: TUserEditForm
  Caption = #29992#25143#32534#36753
  ClientHeight = 400
  ClientWidth = 500
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TUniPanel
    Left = 0
    Top = 0
    Width = 500
    Height = 360
    Hint = ''
    Align = alClient
    TabOrder = 0
    object lblUserName: TUniLabel
      Left = 16
      Top = 16
      Width = 60
      Height = 13
      Hint = ''
      Caption = #29992#25143#21517*
      TabOrder = 1
    end
    object edtUserName: TUniEdit
      Left = 90
      Top = 13
      Width = 200
      Height = 22
      Hint = ''
      TextHint = #22914: admin
      TabOrder = 2
    end
    object lblRealName: TUniLabel
      Left = 16
      Top = 48
      Width = 60
      Height = 13
      Hint = ''
      Caption = #30495#23454#22995#21517*
      TabOrder = 3
    end
    object edtRealName: TUniEdit
      Left = 90
      Top = 45
      Width = 200
      Height = 22
      Hint = ''
      TextHint = #22914: #24352#19977
      TabOrder = 4
    end
    object lblEmail: TUniLabel
      Left = 16
      Top = 80
      Width = 60
      Height = 13
      Hint = ''
      Caption = #37038#31665*
      TabOrder = 5
    end
    object edtEmail: TUniEdit
      Left = 90
      Top = 77
      Width = 200
      Height = 22
      Hint = ''
      TextHint = #22914: admin@example.com
      TabOrder = 6
    end
    object lblPhone: TUniLabel
      Left = 16
      Top = 112
      Width = 60
      Height = 13
      Hint = '
      Caption = #25163#26426
      TabOrder = 7
    end
    object edtPhone: TUniEdit
      Left = 90
      Top = 109
      Width = 200
      Height = 22
      Hint = '
      TextHint = #22914: 13800138000
      TabOrder = 8
    end
    object lblRole: TUniLabel
      Left = 16
      Top = 144
      Width = 60
      Height = 13
      Hint = '
      Caption = #35282#33394
      TabOrder = 9
    end
    object cmbRole: TUniComboBox
      Left = 90
      Top = 141
      Width = 200
      Height = 21
      Hint = '
      Style = csDropDown
      ItemIndex = -1
      TabOrder = 10
    end
    object lblStatus: TUniLabel
      Left = 16
      Top = 176
      Width = 60
      Height = 13
      Hint = '
      Caption = #29366#24577
      TabOrder = 11
    end
    object chkStatus: TUniCheckBox
      Left = 90
      Top = 176
      Width = 60
      Height = 17
      Hint = 
      Caption = #21551#29992
      Checked = True
      TabOrder = 12
    end
    object lblRemark: TUniLabel
      Left = 16
      Top = 208
      Width = 60
      Height = 13
      Hint = 
      Caption = #22791#27880
      TabOrder = 13
    end
    object memRemark: TUniMemo
      Left = 90
      Top = 205
      Width = 380
      Height = 80
      Hint = '
      Lines.Strings = (
        '')
      TabOrder = 14
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
    object btnSave: TUniButton
      Left = 340
      Top = 8
      Width = 75
      Height = 25
      Hint = '
      Caption = #20445#23384
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TUniButton
      Left = 420
      Top = 8
      Width = 75
      Height = 25
      Hint = '
      Caption = '#21462#28040
      ModalResult = 2
      TabOrder = 1
    end
  end
end

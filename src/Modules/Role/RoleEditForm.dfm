inherited RoleEditForm: TRoleEditForm
  Caption = #35282#33394#32534#36753
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
    object lblRoleCode: TUniLabel
      Left = 16
      Top = 16
      Width = 60
      Height = 13
      Hint = ''
      Caption = #35282#33394#32534#30721*
      TabOrder = 1
    end
    object edtRoleCode: TUniEdit
      Left = 90
      Top = 13
      Width = 200
      Height = 22
      Hint = ''
      TextHint = #22914: admin
      TabOrder = 2
    end
    object lblRoleName: TUniLabel
      Left = 16
      Top = 48
      Width = 60
      Height = 13
      Hint = ''
      Caption = #35282#33394#21517#31216*
      TabOrder = 3
    end
    object edtRoleName: TUniEdit
      Left = 90
      Top = 45
      Width = 200
      Height = 22
      Hint = ''
      TextHint = #22914: #31995#32479#31649#29702#21592
      TabOrder = 4
    end
    object lblDescription: TUniLabel
      Left = 16
      Top = 80
      Width = 60
      Height = 13
      Hint = '
      Caption = #25551#36848
      TabOrder = 5
    end
    object memDescription: TUniMemo
      Left = 90
      Top = 77
      Width = 380
      Height = 80
      Hint = '
      Lines.Strings = (
        '')
      TabOrder = 6
    end
    object lblDataScope: TUniLabel
      Left = 16
      Top = 168
      Width = 60
      Height = 13
      Hint = '
      Caption = #25968#25454#33539#22260
      TabOrder = 7
    end
    object cmbDataScope: TUniComboBox
      Left = 90
      Top = 165
      Width = 150
      Height = 21
      Hint = 
      Style = csDropDown
      ItemIndex = 0
      TabOrder = 8
      Items.Strings = (
        #20840#37096
        #26412#37096#38376
        #26412#37096#38376#21450#19979#32423
        #20165#26412#20154)
    end
    object lblSortOrder: TUniLabel
      Left = 16
      Top = 200
      Width = 60
      Height = 13
      Hint = 
      Caption = #25490#24207
      TabOrder = 9
    end
    object edtSortOrder: TUniEdit
      Left = 90
      Top = 197
      Width = 100
      Height = 22
      Hint = ''
      TextHint = '0'
      TabOrder = 10
    end
    object lblStatus: TUniLabel
      Left = 16
      Top = 232
      Width = 60
      Height = 13
      Hint = ''
      Caption = #29366#24577
      TabOrder = 11
    end
    object chkStatus: TUniCheckBox
      Left = 90
      Top = 232
      Width = 60
      Height = 17
      Hint = '' 
      Caption = #21551#29992
      Checked = True
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
    object btnSave: TUniButton
      Left = 340
      Top = 8
      Width = 75
      Height = 25
      Hint = ''
      Caption = #20445#23384
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TUniButton
      Left = 420
      Top = 8
      Width = 75
      Height = 25
      Hint = ''
      Caption = #21462#28040
      ModalResult = 2
      TabOrder = 1
    end
  end
end

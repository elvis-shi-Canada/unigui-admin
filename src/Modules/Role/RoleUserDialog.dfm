inherited RoleUserDialog: TRoleUserDialog
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
    ExplicitWidth = 692
    ExplicitHeight = 400
    object pnlLeft: TUniPanel
      Left = 1
      Top = 1
      Width = 280
      Height = 358
      Hint = ''
      Align = alLeft
      TabOrder = 1
      Caption = ''
      object lblAvailable: TUniLabel
        Left = 8
        Top = 8
        Width = 52
        Height = 13
        Hint = ''
        Caption = #21487#29992#29992#25143
        TabOrder = 2
      end
      object lstAvailable: TUniListBox
        Left = 8
        Top = 27
        Width = 264
        Height = 280
        Hint = ''
        Align = alCustom
        Anchors = [akLeft, akTop, akRight, akBottom]
        TabOrder = 0
        MultiSelect = True
      end
    end
    object pnlRight: TUniPanel
      Left = 408
      Top = 1
      Width = 283
      Height = 358
      Hint = ''
      Align = alRight
      TabOrder = 2
      Caption = ''
      object lblAssigned: TUniLabel
        Left = 8
        Top = 8
        Width = 39
        Height = 13
        Hint = ''
        Caption = #24050#20998#37197
        TabOrder = 2
      end
      object lstAssigned: TUniListBox
        Left = 8
        Top = 27
        Width = 267
        Height = 280
        Hint = ''
        Align = alCustom
        Anchors = [akLeft, akTop, akRight, akBottom]
        TabOrder = 0
        MultiSelect = True
      end
    end
    object pnlCenter: TUniPanel
      Left = 281
      Top = 1
      Width = 127
      Height = 358
      Hint = ''
      Align = alClient
      TabOrder = 3
      Caption = ''
      object btnAdd: TUniButton
        Left = 24
        Top = 60
        Width = 80
        Height = 30
        Hint = ''
        Caption = '>'
        TabOrder = 0
        OnClick = btnAddClick
      end
      object btnAddAll: TUniButton
        Left = 24
        Top = 96
        Width = 80
        Height = 30
        Hint = ''
        Caption = '>>'
        TabOrder = 1
        OnClick = btnAddAllClick
      end
      object btnRemove: TUniButton
        Left = 24
        Top = 160
        Width = 80
        Height = 30
        Hint = ''
        Caption = '<'
        TabOrder = 2
        OnClick = btnRemoveClick
      end
      object btnRemoveAll: TUniButton
        Left = 24
        Top = 196
        Width = 80
        Height = 30
        Hint = ''
        Caption = '<<'
        TabOrder = 3
        OnClick = btnRemoveAllClick
      end
    end
    object pnlBottom: TUniPanel
      Left = 1
      Top = 359
      Width = 690
      Height = 40
      Hint = ''
      Align = alBottom
      TabOrder = 4
      Caption = ''
      object btnSave: TUniButton
        Left = 530
        Top = 8
        Width = 75
        Height = 25
        Hint = ''
        Caption = #20445#23384
        ModalResult = 1
        TabOrder = 0
        OnClick = btnSaveClick
      end
      object btnCancel: TUniButton
        Left = 610
        Top = 8
        Width = 75
        Height = 25
        Hint = ''
        Caption = #21462#28040
        ModalResult = 2
        TabOrder = 1
        OnClick = btnCancelClick
      end
      object lblRoleName: TUniLabel
        Left = 8
        Top = 12
        Width = 29
        Height = 13
        Hint = ''
        Caption = #35282#33394':'
        TabOrder = 5
      end
      object edtSearch: TUniEdit
        Left = 250
        Top = 8
        Width = 120
        Hint = ''
        TextHint = #25628#32034#29992#25143
        TabOrder = 3
        OnKeyPress = edtSearchKeyPress
      end
      object btnSearch: TUniButton
        Left = 376
        Top = 8
        Width = 60
        Height = 25
        Hint = ''
        Caption = #25628#32034
        TabOrder = 4
        OnClick = btnSearchClick
      end
    end
  end
end

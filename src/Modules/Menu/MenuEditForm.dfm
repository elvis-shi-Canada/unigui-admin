inherited MenuEditForm: TMenuEditForm
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TUniPanel
    Left = 0
    Top = 0
    Width = 550
    Height = 480
    Hint = ''
    Align = alClient
    TabOrder = 0
    object lblMenuCode: TUniLabel
      Left = 16
      Top = 16
      Width = 60
      Height = 13
      Hint = ''
      Caption = '菜单编码*'
      TabOrder = 1
    end
    object edtMenuCode: TUniEdit
      Left = 90
      Top = 13
      Width = 200
      Height = 22
      Hint = ''
      TextHint = '唯一标识，如 system:user'
      TabOrder = 2
    end
    object lblMenuName: TUniLabel
      Left = 16
      Top = 48
      Width = 60
      Height = 13
      Hint = ''
      Caption = '菜单名称*'
      TabOrder = 3
    end
    object edtMenuName: TUniEdit
      Left = 90
      Top = 45
      Width = 200
      Height = 22
      Hint = ''
      TextHint = '显示名称'
      TabOrder = 4
    end
    object lblParent: TUniLabel
      Left = 16
      Top = 80
      Width = 60
      Height = 13
      Hint = ''
      Caption = '父菜单'
      TabOrder = 5
    end
    object cmbParent: TUniComboBox
      Left = 90
      Top = 77
      Width = 200
      Height = 21
      Hint = ''
      Style = csDropDown
      ItemIndex = -1
      TabOrder = 6
    end
    object lblMenuType: TUniLabel
      Left = 16
      Top = 112
      Width = 60
      Height = 13
      Hint = ''
      Caption = '菜单类型*'
      TabOrder = 7
    end
    object cmbMenuType: TUniComboBox
      Left = 90
      Top = 109
      Width = 200
      Height = 21
      Hint = ''
      Style = csDropDown
      ItemIndex = 0
      TabOrder = 8
      Items.Strings = (
        'directory'
        'menu'
        'button')
      OnChange = cmbMenuTypeChange
    end
    object lblIcon: TUniLabel
      Left = 310
      Top = 16
      Width = 60
      Height = 13
      Hint = ''
      Caption = '图标'
      TabOrder = 9
    end
    object edtIcon: TUniEdit
      Left = 380
      Top = 13
      Width = 150
      Height = 22
      Hint = ''
      TextHint = 'fa fa-home'
      TabOrder = 10
    end
    object btnSelectIcon: TUniButton
      Left = 480
      Top = 13
      Width = 50
      Height = 22
      Hint = ''
      Caption = '...'
      TabOrder = 11
      OnClick = btnSelectIconClick
    end
    object lblPath: TUniLabel
      Left = 310
      Top = 48
      Width = 60
      Height = 13
      Hint = ''
      Caption = '路径'
      TabOrder = 12
    end
    object edtPath: TUniEdit
      Left = 380
      Top = 45
      Width = 150
      Height = 22
      Hint = ''
      TextHint = '/system/user'
      TabOrder = 13
    end
    object lblComponent: TUniLabel
      Left = 310
      Top = 80
      Width = 60
      Height = 13
      Hint = ''
      Caption = '组件'
      TabOrder = 14
    end
    object edtComponent: TUniEdit
      Left = 380
      Top = 77
      Width = 150
      Height = 22
      Hint = ''
      TextHint = 'UserList'
      TabOrder = 15
    end
    object lblPermission: TUniLabel
      Left = 310
      Top = 112
      Width = 60
      Height = 13
      Hint = ''
      Caption = '权限标识'
      TabOrder = 16
    end
    object edtPermission: TUniEdit
      Left = 380
      Top = 109
      Width = 150
      Height = 22
      Hint = ''
      TextHint = 'user:view'
      TabOrder = 17
    end
    object lblSortOrder: TUniLabel
      Left = 16
      Top = 144
      Width = 60
      Height = 13
      Hint = ''
      Caption = '排序'
      TabOrder = 18
    end
    object spnSortOrder: TUniSpinEdit
      Left = 90
      Top = 141
      Width = 100
      Height = 22
      Hint = ''
      TabOrder = 19
      MinValue = 0.000000000000000000
      MaxValue = 9999.000000000000000000
    end
    object chkVisible: TUniCheckBox
      Left = 200
      Top = 144
      Width = 60
      Height = 17
      Hint = ''
      Caption = '可见'
      TabOrder = 20
    end
    object chkStatus: TUniCheckBox
      Left = 270
      Top = 144
      Width = 60
      Height = 17
      Hint = ''
      Caption = '启用'
      Checked = True
      TabOrder = 21
    end
    object lblDescription: TUniLabel
      Left = 16
      Top = 176
      Width = 60
      Height = 13
      Hint = ''
      Caption = '描述'
      TabOrder = 22
    end
    object memDescription: TUniMemo
      Left = 90
      Top = 176
      Width = 440
      Height = 80
      Hint = ''
      Lines.Strings = (
        '')
      TabOrder = 23
    end
    object pnlBottom: TUniPanel
      Left = 1
      Top = 439
      Width = 548
      Height = 40
      Hint = ''
      Align = alBottom
      TabOrder = 0
      object btnSave: TUniButton
        Left = 380
        Top = 8
        Width = 75
        Height = 25
        Hint = ''
        Caption = '保存'
        ModalResult = 1
        TabOrder = 0
        OnClick = btnSaveClick
      end
      object btnCancel: TUniButton
        Left = 460
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

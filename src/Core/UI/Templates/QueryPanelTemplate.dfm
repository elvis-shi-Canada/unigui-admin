object QueryPanelTemplate: TQueryPanelTemplate
  Left = 0
  Top = 0
  Width = 800
  Height = 120
  Align = alTop
  Color = clWindow
  ParentColor = False
  TabOrder = 0
  object grpQuery: TUniGroupBox
    Left = 8
    Top = 8
    Width = 784
    Height = 104
    Caption = '查询条件'
    TabOrder = 0
    object lblKeyword: TUniLabel
      Left = 16
      Top = 24
      Width = 60
      Height = 13
      Caption = '关键词:'
      FocusControl = edtKeyword
    end
    object edtKeyword: TUniEdit
      Left = 82
      Top = 21
      Width = 200
      Height = 21
      TabOrder = 0
      TextHint = '请输入查询关键词'
    end
    object lblDateFrom: TUniLabel
      Left = 300
      Top = 24
      Width = 60
      Height = 13
      Caption = '起始日期:'
      FocusControl = dtpDateFrom
    end
    object dtpDateFrom: TUniDateTimePicker
      Left = 366
      Top = 21
      Width = 120
      Height = 21
      TabOrder = 1
    end
    object lblDateTo: TUniLabel
      Left = 492
      Top = 24
      Width = 60
      Height = 13
      Caption = '结束日期:'
      FocusControl = dtpDateTo
    end
    object dtpDateTo: TUniDateTimePicker
      Left = 558
      Top = 21
      Width = 120
      Height = 21
      TabOrder = 2
    end
    object lblStatus: TUniLabel
      Left = 16
      Top = 64
      Width = 60
      Height = 13
      Caption = '状态:'
      FocusControl = cboStatus
    end
    object cboStatus: TUniComboBox
      Left = 82
      Top = 61
      Width = 200
      Height = 21
      TabOrder = 3
      Items.Strings = (
        '全部'
        '启用'
        '禁用'
        '待审核')
    end
    object btnQuery: TUniButton
      Left = 300
      Top = 59
      Width = 75
      Height = 25
      Caption = '查询(&Q)'
      TabOrder = 4
      OnClick = btnQueryClick
    end
    object btnReset: TUniButton
      Left = 381
      Top = 59
      Width = 75
      Height = 25
      Caption = '重置(&R)'
      TabOrder = 5
      OnClick = btnResetClick
    end
    object btnAdvanced: TUniButton
      Left = 462
      Top = 59
      Width = 75
      Height = 25
      Caption = '高级(&A)...'
      TabOrder = 6
      OnClick = btnAdvancedClick
    end
  end
end

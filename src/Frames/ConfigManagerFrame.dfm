object ConfigManagerFrame: TConfigManagerFrame
  Left = 0
  Top = 0
  Width = 800
  Height = 600
  TabOrder = 0
  object pnlToolBar: TPanel
    Left = 0
    Top = 0
    Width = 800
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblModule: TLabel
      Left = 8
      Top = 12
      Width = 48
      Height = 13
      Caption = #27169#22359#65306
    end
    object cboModules: TComboBox
      Left = 62
      Top = 8
      Width = 200
      Height = 21
      TabOrder = 0
      OnChange = cboModulesChange
    end
    object btnLoad: TButton
      Left = 275
      Top = 6
      Width = 75
      Height = 25
      Caption = #21152#36733
      TabOrder = 1
      OnClick = btnLoadClick
    end
    object btnSave: TButton
      Left = 356
      Top = 6
      Width = 75
      Height = 25
      Caption = #20445#23384
      TabOrder = 2
      OnClick = btnSaveClick
    end
    object btnRefresh: TButton
      Left = 437
      Top = 6
      Width = 75
      Height = 25
      Caption = #21047#26032
      TabOrder = 3
      OnClick = btnRefreshClick
    end
  end
  object pnlMain: TPanel
    Left = 0
    Top = 41
    Width = 800
    Height = 518
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object pnlConfig: TPanel
      Left = 0
      Top = 0
      Width = 800
      Height = 350
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object grdConfig: TStringGrid
        Left = 0
        Top = 0
        Width = 800
        Height = 350
        Align = alClient
        ColCount = 3
        FixedCols = 0
        RowCount = 2
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
        TabOrder = 0
        OnSelectCell = grdConfigSelectCell
      end
    end
    object pnlEdit: TPanel
      Left = 0
      Top = 350
      Width = 800
      Height = 168
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object lblKey: TLabel
        Left = 8
        Top = 8
        Width = 48
        Height = 13
        Caption = #37197#32622#38190#65306
      end
      object edtKey: TEdit
        Left = 8
        Top = 27
        Width = 200
        Height = 21
        Enabled = False
        TabOrder = 0
      end
      object lblValue: TLabel
        Left = 220
        Top = 8
        Width = 48
        Height = 13
        Caption = #37197#32622#20540#65306
      end
      object edtValue: TEdit
        Left = 220
        Top = 27
        Width = 300
        Height = 21
        Enabled = False
        TabOrder = 1
      end
      object lblType: TLabel
        Left = 530
        Top = 8
        Width = 36
        Height = 13
        Caption = #31867#22411#65306
      end
      object cboType: TComboBox
        Left = 530
        Top = 27
        Width = 120
        Height = 21
        Style = csDropDownList
        Enabled = False
        TabOrder = 2
      end
      object btnAdd: TButton
        Left = 8
        Top = 70
        Width = 75
        Height = 25
        Caption = #28155#21152
        Enabled = False
        TabOrder = 3
        OnClick = btnAddClick
      end
      object btnUpdate: TButton
        Left = 89
        Top = 70
        Width = 75
        Height = 25
        Caption = #26356#26032
        Enabled = False
        TabOrder = 4
        OnClick = btnUpdateClick
      end
      object btnDelete: TButton
        Left = 170
        Top = 70
        Width = 75
        Height = 25
        Caption = #21024#38500
        Enabled = False
        TabOrder = 5
        OnClick = btnDeleteClick
      end
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 559
    Width = 800
    Height = 41
    Panels = <>
    SimplePanel = True
  end
end

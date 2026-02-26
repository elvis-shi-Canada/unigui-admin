object EditFormTemplate: TEditFormTemplate
  Left = 0
  Top = 0
  Width = 600
  Height = 500
  Caption = #32534#36753#34920#21333
  ClientHeight = 500
  ClientWidth = 600
  OnCreate = FormCreate
  UniThemeManager = UniThemeManager1
  PixelsPerInch = 96
  TextHeight = 13
  object pnlHeader: TUniPanel
    Left = 0
    Top = 0
    Width = 600
    Height = 60
    Align = alTop
    Color = clWindow
    ParentColor = False
    TabOrder = 0
    object lblTitle: TUniLabel
      Left = 16
      Top = 16
      Width = 200
      Height = 24
      Caption = #32534#36753#20449#24687
      ParentFont = False
      Font.Color = clHighlight
      Font.Height = -19
      Font.Name = Segoe UI
      Font.Style = [fsBold]
    end
  end
  object pnlBody: TUniPanel
    Left = 0
    Top = 60
    Width = 600
    Height = 380
    Align = alClient
    Color = clWindow
    ParentColor = False
    TabOrder = 1
    object grpFields: TUniGroupBox
      Left = 16
      Top = 16
      Width = 568
      Height = 348
      Caption = #22522#26412#20449#24687
      TabOrder = 0
      object lblField1: TUniLabel
        Left = 16
        Top = 32
        Width = 80
        Height = 13
        Caption = #23383#27573#21517#312161:'
        FocusControl = edtField1
      end
      object edtField1: TUniEdit
        Left = 102
        Top = 29
        Width = 450
        Height = 21
        TabOrder = 0
      end
      object lblField2: TUniLabel
        Left = 16
        Top = 72
        Width = 80
        Height = 13
        Caption = #23383#27573#21517#312162:
        FocusControl = edtField2
      end
      object edtField2: TUniEdit
        Left = 102
        Top = 69
        Width = 450
        Height = 21
        TabOrder = 1
      end
      object lblField3: TUniLabel
        Left = 16
        Top = 112
        Width = 80
        Height = 13
        Caption = #23383#27573#21517#312163:
        FocusControl = memField3
      end
      object memField3: TUniMemo
        Left = 102
        Top = 109
        Width = 450
        Height = 89
        TabOrder = 2
      end
      object lblField4: TUniLabel
        Left = 16
        Top = 216
        Width = 80
        Height = 13
        Caption = #23383#27573#21517#312164:
        FocusControl = chkField4
      end
      object chkField4: TUniCheckBox
        Left = 102
        Top = 213
        Width = 97
        Height = 17
        Caption = #21551#29992
        TabOrder = 3
      end
      object lblField5: TUniLabel
        Left = 16
        Top = 256
        Width = 80
        Height = 13
        Caption = #23383#27573#21517#312165:
        FocusControl = cboField5
      end
      object cboField5: TUniComboBox
        Left = 102
        Top = 253
        Width = 450
        Height = 21
        TabOrder = 4
        Items.Strings = (
          #36873#390331
          #36873#390332
          #36873#390333)
      end
    end
  end
  object pnlFooter: TUniPanel
    Left = 0
    Top = 440
    Width = 600
    Height = 60
    Align = alBottom
    Color = 15856113
    ParentColor = False
    TabOrder = 2
    object pnlButtons: TUniPanel
      Left = 420
      Top = 10
      Width = 170
      Height = 40
      Anchors = [akTop, akRight]
      ParentColor = False
      Color = clBtnFace
      TabOrder = 0
      object btnOK: TUniButton
        Left = 10
        Top = 5
        Width = 75
        Height = 30
        Caption = #20445#23384(&S)
        TabOrder = 0
        OnClick = btnOKClick
      end
      object btnCancel: TUniButton
        Left = 85
        Top = 5
        Width = 75
        Height = 30
        Caption = '#21462#28040(&C)
        ModalResult = 2
        TabOrder = 1
      end
    end
  end
  object UniThemeManager1: TUniThemeManager
    Left = 544
    Top = 16
  end
end

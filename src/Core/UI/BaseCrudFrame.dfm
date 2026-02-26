inherited BaseCrudFrame: TBaseCrudFrame
  PixelsPerInch = 96
  TextHeight = 13
  object UniToolBar: TUniToolBar
    Left = 0
    Top = 0
    Width = 800
    Height = 40
    Hint = ''
    Align = alTop
    TabOrder = 0
    object BtnAdd: TUniButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Hint = ''
      Caption = #26032#22686
      TabOrder = 0
    end
    object BtnEdit: TUniButton
      Left = 88
      Top = 8
      Width = 75
      Height = 25
      Hint = ''
      Caption = #32534#36753
      TabOrder = 1
    end
    object BtnDelete: TUniButton
      Left = 168
      Top = 8
      Width = 75
      Height = 25
      Hint = ''
      Caption = #21024#38500
      TabOrder = 2
    end
    object BtnRefresh: TUniButton
      Left = 248
      Top = 8
      Width = 75
      Height = 25
      Hint = ''
      Caption = #21047#26032
      TabOrder = 3
    end
  end
end

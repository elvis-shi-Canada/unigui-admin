object BaseCrudFrame: TBaseCrudFrame
  Left = 0
  Top = 0
  Width = 640
  Height = 480
  TabOrder = 0
  object UniToolBar: TUniToolBar
    Left = 0
    Top = 0
    Width = 640
    Height = 40
    Hint = ''
    TabOrder = 0
    ParentColor = False
    Color = clBtnFace
    object BtnAdd: TUniButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Hint = ''
      Caption = #26032#22686
      TabOrder = 1
      OnClick = BtnAddClick
    end
    object BtnEdit: TUniButton
      Left = 88
      Top = 8
      Width = 75
      Height = 25
      Hint = ''
      Caption = #32534#36753
      TabOrder = 2
      OnClick = BtnEditClick
    end
    object BtnDelete: TUniButton
      Left = 168
      Top = 8
      Width = 75
      Height = 25
      Hint = ''
      Caption = #21024#38500
      TabOrder = 3
      OnClick = BtnDeleteClick
    end
    object BtnRefresh: TUniButton
      Left = 248
      Top = 8
      Width = 75
      Height = 25
      Hint = ''
      Caption = #21047#26032
      TabOrder = 4
      OnClick = BtnRefreshClick
    end
  end
end

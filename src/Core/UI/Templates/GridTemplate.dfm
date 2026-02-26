object GridTemplate: TGridTemplate
  Left = 0
  Top = 0
  Width = 800
  Height = 600
  Caption = #25968#25454#32593#26684#27169#26495
  ClientHeight = 600
  ClientWidth = 800
  PixelsPerInch = 96
  TextHeight = 13
  object UniToolBar1: TUniToolBar
    Left = 0
    Top = 0
    Width = 800
    Height = 40
    ButtonHeight = 36
    ButtonWidth = 36
    Caption = 'UniToolBar1
    TabOrder = 0
    object btnAdd: TUniToolButton
      Left = 0
      Top = 2
      Width = 36
      Height = 36
      Hint = #26032#22686
      ShowHint = True
      Caption = btnAdd
      ImageIndex = 0
      OnClick = DoAdd
    end
    object btnEdit: TUniToolButton
      Left = 36
      Top = 2
      Width = 36
      Height = 36
      Hint = #32534#36753
      ShowHint = True
      Caption = btnEdit
      ImageIndex = 1
      OnClick = DoEdit
    end
    object btnDelete: TUniToolButton
      Left = 72
      Top = 2
      Width = 36
      Height = 36
      Hint = #21024#38500
      ShowHint = True
      Caption = btnDelete
      ImageIndex = 2
      OnClick = DoDelete
    end
    object btnRefresh: TUniToolButton
      Left = 108
      Top = 2
      Width = 36
      Height = 36
      Hint = #21047#26032
      ShowHint = True
      Caption = btnRefresh'
      ImageIndex = 3
      OnClick = DoRefresh
    end
    object UniEdit1: TUniEdit
      Left = 160
      Top = 8
      Width = 200
      Height = 24
      Hint = #25628#32034...
      TextHint = '#25628#32034...
      ParentFont = False
      TabOrder = 0
      OnChange = DoSearch
    end
  end
  object UniDBGrid1: TUniDBGrid
    Left = 0
    Top = 40
    Width = 800
    Height = 560
    Align = alClient
    TabOrder = 1
    Columns = <>
  end
end

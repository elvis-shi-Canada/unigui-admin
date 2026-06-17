object GridTemplate: TGridTemplate
  Left = 0
  Top = 0
  ClientHeight = 422
  ClientWidth = 800
  Caption = #25968#25454#32593#26684#27169#26495
  OldCreateOrder = False
  MonitoredKeys.Keys = <>
  TextHeight = 15
  object UniToolBar1: TUniToolBar
    Left = 0
    Top = 0
    Width = 800
    Height = 40
    Hint = ''
    ButtonHeight = 36
    ButtonWidth = 36
    TabOrder = 0
    ParentColor = False
    Color = clBtnFace
    object btnAdd: TUniToolButton
      Left = 0
      Top = 0
      Hint = #26032#22686
      ShowHint = True
      ParentShowHint = False
      ImageIndex = 0
      Caption = 'btnAdd'
      TabOrder = 1
      OnClick = DoAdd
    end
    object btnEdit: TUniToolButton
      Left = 36
      Top = 0
      Hint = #32534#36753
      ShowHint = True
      ParentShowHint = False
      ImageIndex = 1
      Caption = 'btnEdit'
      TabOrder = 2
      OnClick = DoEdit
    end
    object btnDelete: TUniToolButton
      Left = 72
      Top = 0
      Hint = #21024#38500
      ShowHint = True
      ParentShowHint = False
      ImageIndex = 2
      Caption = 'btnDelete'
      TabOrder = 3
      OnClick = DoDelete
    end
    object btnRefresh: TUniToolButton
      Left = 108
      Top = 0
      Hint = #21047#26032
      ShowHint = True
      ParentShowHint = False
      ImageIndex = 3
      Caption = 'btnRefresh'
      TabOrder = 4
      OnClick = DoRefresh
    end
    object UniEdit1: TUniEdit
      Left = 160
      Top = 8
      Width = 200
      Height = 24
      Hint = #25628#32034'...'
      Text = ''
      ParentFont = False
      TabOrder = 5
      OnChange = DoSearch
    end
  end
  object UniDBGrid1: TUniDBGrid
    Left = 0
    Top = 40
    Width = 800
    Height = 382
    Hint = ''
    LoadMask.Message = #21152#36733#25968#25454'...'
    Align = alClient
    TabOrder = 1
  end
end

object BaseFormTemplate: TBaseFormTemplate
  Left = 0
  Top = 0
  Width = 600
  Height = 400
  Caption = '基础窗体模板'
  ClientHeight = 400
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
    Anchors = [akLeft, akTop, akRight]
    Color = clWindow
    ParentColor = False
    TabOrder = 0
    object lblTitle: TUniLabel
      Left = 16
      Top = 16
      Width = 200
      Height = 24
      Caption = '窗体标题'
      ParentFont = False
      Font.Color = clHighlight
      Font.Height = -19
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
    end
  end
  object pnlBody: TUniPanel
    Left = 0
    Top = 60
    Width = 600
    Height = 280
    Align = alClient
    Color = clWindow
    ParentColor = False
    TabOrder = 1
    ExplicitTop = 66
  end
  object pnlFooter: TUniPanel
    Left = 0
    Top = 340
    Width = 600
    Height = 60
    Align = alBottom
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = 15856113
    ParentColor = False
    TabOrder = 2
    ExplicitTop = 346
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
        Caption = '确定'
        ModalResult = 1
        TabOrder = 0
      end
      object btnCancel: TUniButton
        Left = 85
        Top = 5
        Width = 75
        Height = 30
        Caption = '取消'
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

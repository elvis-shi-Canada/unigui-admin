object LoginForm: TLoginForm
  Left = 0
  Top = 0
  ClientHeight = 300
  ClientWidth = 400
  Caption = #29992#25143#30331#24405
  OldCreateOrder = False
  MonitoredKeys.Keys = <>
  TextHeight = 15
  object UniContainerPanel: TUniContainerPanel
    Left = 0
    Top = 0
    Width = 400
    Height = 300
    Hint = ''
    ParentColor = False
    Align = alClient
    TabOrder = 0
    object UniPanel: TUniPanel
      Left = 50
      Top = 30
      Width = 300
      Height = 240
      Hint = ''
      TabOrder = 0
      Caption = ''
      object LblTitle: TUniLabel
        Left = 80
        Top = 16
        Width = 359
        Height = 25
        Hint = ''
        Caption = 'UniAdmin #31649#29702#31995#32479'
        ParentFont = False
        Font.Height = -19
        Font.Style = [fsBold]
        TabOrder = 1
      end
      object LblUserName: TUniLabel
        Left = 16
        Top = 64
        Width = 39
        Height = 13
        Hint = ''
        Caption = #29992#25143#21517
        TabOrder = 2
      end
      object EdtUserName: TUniEdit
        Left = 16
        Top = 83
        Width = 268
        Hint = ''
        Text = ''
        TabOrder = 3
      end
      object LblPassword: TUniLabel
        Left = 16
        Top = 112
        Width = 26
        Height = 13
        Hint = ''
        Caption = #23494#30721
        TabOrder = 4
      end
      object EdtPassword: TUniEdit
        Left = 16
        Top = 131
        Width = 268
        Hint = ''
        PasswordChar = '*'
        Text = ''
        TabOrder = 5
      end
      object ChkRememberMe: TUniCheckBox
        Left = 16
        Top = 160
        Width = 100
        Height = 17
        Hint = ''
        Caption = #35760#20303#25105
        TabOrder = 6
      end
      object BtnLogin: TUniButton
        Left = 80
        Top = 192
        Width = 80
        Height = 25
        Hint = ''
        Caption = #30331#24405
        TabOrder = 7
        OnClick = BtnLoginClick
      end
      object BtnCancel: TUniButton
        Left = 170
        Top = 192
        Width = 80
        Height = 25
        Hint = ''
        Caption = #21462#28040
        TabOrder = 8
        OnClick = BtnCancelClick
      end
    end
  end
end

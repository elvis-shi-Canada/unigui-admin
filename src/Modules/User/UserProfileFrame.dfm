inherited UserProfileFrame: TUserProfileFrame
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TUniPanel
    Left = 0
    Top = 0
    Width = 600
    Height = 400
    Hint = '
    Align = alClient
    TabOrder = 0
    object pnlAvatar: TUniPanel
      Left = 16
      Top = 16
      Width = 120
      Height = 140
      Hint = ''
      TabOrder = 1
      object imgAvatar: TUniImage
        Left = 8
        Top = 8
        Width = 104
        Height = 104
        Hint = ''
        Stretch = True
      end
      object btnChangeAvatar: TUniButton
        Left = 8
        Top = 112
        Width = 104
        Height = 25
        Hint = '
        Caption = #26356#25442#22836#20687
        TabOrder = 0
        OnClick = btnChangeAvatarClick
      end
    end
    object pnlInfo: TUniPanel
      Left = 144
      Top = 16
      Width = 440
      Height = 240
      Hint = ''
      TabOrder = 2
      object lblUserName: TUniLabel
        Left = 8
          Top = 8
          Width = 60
          Height = 13
          Hint = '
          Caption = #29992#25143#21517
          TabOrder = 1
      end
      object edtUserName: TUniEdit
        Left = 80
          Top = 5
          Width = 200
          Height = 22
          Hint = '
          TabOrder = 2
      end
      object lblRealName: TUniLabel
        Left = 8
          Top = 40
          Width = 60
          Height = 13
          Hint = ''
          Caption = #30495#23454#22995#21517
          TabOrder = 3
      end
      object edtRealName: TUniEdit
        Left = 80
          Top = 37
          Width = 200
          Height = 22
          Hint = ''
          TabOrder = 4
      end
      object lblEmail: TUniLabel
        Left = 8
          Top = 72
          Width = 60
          Height = 13
          Hint = ''
          Caption = #37038#31665
          TabOrder = 5
      end
      object edtEmail: TUniEdit
        Left = 80
          Top = 69
          Width = 200
          Height = 22
          Hint = ''
          TabOrder = 6
      end
      object lblPhone: TUniLabel
        Left = 8
          Top = 104
          Width = 60
          Height = 13
          Hint = ''
          Caption = #25163#26426
          TabOrder = 7
      end
      object edtPhone: TUniEdit
        Left = 80
          Top = 101
          Width = 200
          Height = 22
          Hint = ''
          TabOrder = 8
      end
      object lblLastLogin: TUniLabel
        Left = 8
          Top = 136
          Width = 60
          Height = 13
          Hint = ''
          Caption = #26368#21518#30331#24405
          TabOrder = 9
      end
      object edtLastLogin: TUniLabel
        Left = 80
          Top = 136
          Width = 200
          Height = 13
          Hint = ''
          Caption = #20174#26410#30331#24405
          TabOrder = 10
      end
      object lblLastLoginIP: TUniLabel
        Left = 8
          Top = 160
          Width = 60
          Height = 13
          Hint = ''
          Caption = #30331#24405IP
          TabOrder = 11
      end
      object edtLastLoginIP: TUniLabel
        Left = 80
          Top = 160
          Width = 200
          Height = 13
          Hint = ''
          Caption = '-'
          TabOrder = 12
      end
    end
    object pnlBottom: TUniPanel
      Left = 144
      Top = 264
      Width = 440
      Height = 40
      Hint = ''
      TabOrder = 3
      object btnChangePassword: TUniButton
        Left = 8
          Top = 8
          Width = 100
          Height = 25
          Hint = '''
          Caption = #20462#25913#23494#30721
          TabOrder = 0
          OnClick = btnChangePasswordClick
      end
      object btnSave: TUniButton
        Left = 120
          Top = 8
          Width = 75
          Height = 25
          Hint = ''
          Caption = #20445#23384
          TabOrder = 1
          OnClick = btnSaveClick
      end
    end
  end
end

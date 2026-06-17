object UserPasswordDialog: TUserPasswordDialog
  Left = 0
  Top = 0
  Width = 400
  Height = 250
  Caption = #20462#25913#23494#30784
  ClientHeight = 250
  ClientWidth = 400
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lblCurrentPassword: TUniLabel
    Left = 24
    Top = 24
    Width = 100
    Height = 13
    Caption = #21407#21069#23494#30784
  end
  object lblNewPassword: TUniLabel
    Left = 24
    Top = 72
    Width = 100
    Height = 13
    Caption = #26032#23494#30784
  end
  object lblConfirmPassword: TUniLabel
    Left = 24
    Top = 120
    Width = 100
    Height = 13
    Caption = #30830#35748#26032#23494#30784
  end
  object edtCurrentPassword: TUniEdit
    Left = 130
    Top = 21
    Width = 200
    Height = 22
    PasswordChar = '*'
  end
  object edtNewPassword: TUniEdit
    Left = 130
    Top = 69
    Width = 200
    Height = 22
    PasswordChar = '*'
  end
  object edtConfirmPassword: TUniEdit
    Left = 130
    Top = 117
    Width = 200
    Height = 22
    PasswordChar = '*'
  end
  object btnOK: TUniButton
    Left = 130
    Top = 168
    Width = 75
    Height = 25
    Caption = #30830#23450
  end
  object btnCancel: TUniButton
    Left = 220
    Top = 168
    Width = 75
    Height = 25
    Caption = #21462#28040
  end
end

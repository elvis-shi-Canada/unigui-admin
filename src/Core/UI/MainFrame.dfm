object MainFrame: TMainFrame
  Left = 0
  Top = 0
  ClientHeight = 550
  ClientWidth = 1074
  Caption = 'UniAdmin '#31649#29702#31995#32479
  OnShow = FormShow
  OldCreateOrder = False
  OnClose = FormClose
  MonitoredKeys.Keys = <>
  OnCreate = FormCreate
  TextHeight = 15
  object pnlTopBar: TUniPanel
    Left = 0
    Top = 0
    Width = 1074
    Height = 46
    Hint = ''
    Align = alTop
    TabOrder = 0
    BorderStyle = ubsNone
    Caption = ''
    Color = 4144957
    ExplicitWidth = 1040
    object btnToggleMenu: TUniButton
      Left = 8
      Top = 7
      Width = 34
      Height = 32
      Hint = ''
      Caption = #9776
      ParentFont = False
      Font.Color = clWhite
      Font.Height = -19
      TabOrder = 1
      OnClick = btnToggleMenuClick
    end
    object lblAppTitle: TUniLabel
      Left = 57
      Top = 8
      Width = 84
      Height = 25
      Hint = ''
      Caption = 'UniAdmin'
      ParentFont = False
      Font.Color = clWhite
      Font.Height = -19
      TabOrder = 2
    end
    object lblCurrentUser: TUniLabel
      Left = 640
      Top = 17
      Width = 180
      Height = 16
      Hint = ''
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = #29992#25143
      ParentFont = False
      Font.Color = clWhite
      TabOrder = 4
    end
    object btnLogout: TUniButton
      Left = 876
      Top = 8
      Width = 60
      Height = 32
      Hint = ''
      Caption = #36864#20986
      ParentFont = False
      Font.Color = clWhite
      TabOrder = 3
      OnClick = btnLogoutClick
    end
  end
  object pnlSidebar: TUniPanel
    Left = 0
    Top = 46
    Width = 220
    Height = 464
    Hint = ''
    Align = alLeft
    TabOrder = 1
    BorderStyle = ubsNone
    Caption = ''
    Color = 15921906
    ExplicitHeight = 505
    object trmMenu: TUniTreeMenu
      Left = 0
      Top = 0
      Width = 220
      Height = 464
      Hint = ''
      Align = alClient
      Items.FontData = {0100000000}
      ExpanderOnly = False
      OnSelectionChange = trmMenuSelectionChange
      ExplicitLeft = -6
      ExplicitTop = -1
      ExplicitHeight = 484
    end
  end
  object pgcContent: TUniPageControl
    Left = 220
    Top = 46
    Width = 854
    Height = 464
    Hint = ''
    Align = alClient
    TabOrder = 2
    ExplicitLeft = 226
    ExplicitHeight = 484
  end
  object UniStatusBar: TUniStatusBar
    Left = 0
    Top = 510
    Width = 1074
    Height = 40
    Hint = ''
    Panels = <>
    SizeGrip = False
    Align = alBottom
    ParentColor = False
    SimpleText = #23601#32490
    ExplicitTop = 530
  end
end

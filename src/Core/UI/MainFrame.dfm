object MainFrame: TMainFrame
  Left = 0
  Top = 0
  ClientHeight = 600
  ClientWidth = 900
  Caption = 'UniAdmin '#31649#29702#31995#32479
  OnShow = FormShow
  OldCreateOrder = False
  OnClose = FormClose
  MonitoredKeys.Keys = <>
  OnCreate = FormCreate
  TextHeight = 15
  object UniContainerPanel: TUniContainerPanel
    Left = 0
    Top = 0
    Width = 900
    Height = 580
    Hint = ''
    ParentColor = False
    Align = alClient
    TabOrder = 0
    object pgcContent: TUniPageControl
      Left = 0
      Top = 0
      Width = 900
      Height = 580
      Hint = ''
      Align = alClient
      TabHeight = 25
      TabOrder = 0
    end
  end
  object UniStatusBar: TUniStatusBar
    Left = 0
    Top = 580
    Width = 900
    Height = 20
    Hint = ''
    Panels = <>
    SizeGrip = False
    Align = alBottom
    ParentColor = False
    SimpleText = #23601#32490
  end
  object UniMainMenu: TUniMainMenu
    Left = 112
    Top = 32
  end
end

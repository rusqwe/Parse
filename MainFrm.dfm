object Main: TMain
  Left = 0
  Top = 0
  Caption = 'Main'
  ClientHeight = 589
  ClientWidth = 799
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object TLabel
    Left = 32
    Top = 533
    Width = 57
    Height = 13
  end
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 799
    Height = 548
    Align = alClient
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 548
    Width = 799
    Height = 41
    Align = alBottom
    TabOrder = 1
    object Label1: TLabel
      Left = 160
      Top = 6
      Width = 49
      Height = 13
    end
    object Button2: TButton
      Left = 280
      Top = 6
      Width = 88
      Height = 25
      Caption = #1055#1091#1089#1082' '#1074' '#1087#1086#1090#1086#1082#1077
      TabOrder = 0
      OnClick = Button2Click
    end
    object Button1: TButton
      Left = 374
      Top = 6
      Width = 75
      Height = 25
      Caption = #1055#1091#1089#1082
      TabOrder = 1
      OnClick = Button1Click
    end
    object Button3: TButton
      Left = 703
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Button3'
      TabOrder = 2
      OnClick = Button3Click
    end
    object Edit1: TEdit
      Left = 24
      Top = 6
      Width = 121
      Height = 21
      TabOrder = 3
      Text = '100'
    end
    object Button4: TButton
      Left = 622
      Top = 6
      Width = 75
      Height = 25
      Caption = #1054#1095#1080#1089#1090#1080#1090#1100
      TabOrder = 4
      OnClick = Button4Click
    end
  end
  object IdAntiFreeze1: TIdAntiFreeze
    Left = 824
    Top = 32
  end
  object NetHTTPClient1: TNetHTTPClient
    Asynchronous = False
    ConnectionTimeout = 60000
    ResponseTimeout = 60000
    HandleRedirects = True
    AllowCookies = True
    UserAgent = 'Embarcadero URI Client/1.0'
    Left = 824
    Top = 88
  end
end

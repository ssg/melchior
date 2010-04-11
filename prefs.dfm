object PrefsFrm: TPrefsFrm
  Left = 384
  Top = 228
  BorderStyle = bsDialog
  Caption = 'Preferences'
  ClientHeight = 281
  ClientWidth = 365
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pcPrefs: TPageControl
    Left = 8
    Top = 8
    Width = 353
    Height = 233
    ActivePage = TabSheet2
    TabOrder = 0
    object TabSheet3: TTabSheet
      Caption = 'General'
      ImageIndex = 2
      object GroupBox1: TGroupBox
        Left = 16
        Top = 104
        Width = 241
        Height = 81
        Caption = 'Status LEDs'
        TabOrder = 3
        object cbShowLatency: TCheckBox
          Left = 16
          Top = 24
          Width = 145
          Height = 17
          Caption = 'Show latency times'
          TabOrder = 0
        end
        object cbInterpolate: TCheckBox
          Left = 16
          Top = 48
          Width = 145
          Height = 17
          Caption = 'Reflect average latency'
          TabOrder = 1
        end
      end
      object cbSysTray: TCheckBox
        Left = 32
        Top = 16
        Width = 177
        Height = 17
        Caption = 'Minimize to system tray'
        TabOrder = 0
      end
      object cbPromptOnExit: TCheckBox
        Left = 32
        Top = 64
        Width = 97
        Height = 17
        Caption = 'Prompt on exit'
        TabOrder = 2
      end
      object cbStartMinimized: TCheckBox
        Left = 32
        Top = 40
        Width = 97
        Height = 17
        Caption = 'Start minimized'
        TabOrder = 1
      end
    end
    object TabSheet1: TTabSheet
      Caption = 'Monitoring'
      object Label1: TLabel
        Left = 16
        Top = 48
        Width = 70
        Height = 13
        Caption = 'Check Interval'
      end
      object Label2: TLabel
        Left = 184
        Top = 48
        Width = 21
        Height = 13
        Caption = 'secs'
      end
      object Label3: TLabel
        Left = 16
        Top = 80
        Width = 95
        Height = 13
        Caption = 'Connection Timeout'
      end
      object Label4: TLabel
        Left = 184
        Top = 80
        Width = 21
        Height = 13
        Caption = 'secs'
      end
      object UpDown1: TUpDown
        Left = 160
        Top = 45
        Width = 17
        Height = 21
        Min = 1
        Position = 1
        TabOrder = 0
      end
      object eInterval: TEdit
        Left = 120
        Top = 45
        Width = 41
        Height = 21
        TabOrder = 1
        Text = '5'
      end
      object UpDown2: TUpDown
        Left = 160
        Top = 77
        Width = 17
        Height = 21
        Min = 1
        Position = 1
        TabOrder = 2
      end
      object eTimeout: TEdit
        Left = 120
        Top = 77
        Width = 41
        Height = 21
        TabOrder = 3
        Text = '5'
      end
      object cbAutoStartMonitoring: TCheckBox
        Left = 32
        Top = 16
        Width = 177
        Height = 17
        Caption = 'Start monitoring automatically'
        TabOrder = 4
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Log'
      ImageIndex = 2
      object pDump: TPanel
        Left = 16
        Top = 16
        Width = 305
        Height = 169
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 0
        object Label5: TLabel
          Left = 24
          Top = 16
          Width = 45
          Height = 13
          Caption = '&File name'
          FocusControl = eDumpXmlFilename
        end
        object Label6: TLabel
          Left = 24
          Top = 72
          Width = 116
          Height = 13
          Caption = '&Dump interval (seconds)'
        end
        object eDumpXmlFilename: TEdit
          Left = 24
          Top = 32
          Width = 185
          Height = 21
          TabOrder = 0
          Text = 'updown.xml'
        end
        object bXmlFileLookup: TButton
          Left = 208
          Top = 32
          Width = 25
          Height = 22
          Caption = '...'
          TabOrder = 1
          OnClick = bXmlFileLookupClick
        end
        object udInterval: TUpDown
          Left = 217
          Top = 69
          Width = 16
          Height = 21
          Associate = eDumpInterval
          Min = 1
          Max = 3600
          Position = 1
          TabOrder = 2
        end
        object eDumpInterval: TEdit
          Left = 160
          Top = 69
          Width = 57
          Height = 21
          TabOrder = 3
          Text = '1'
        end
      end
      object cbDumpXml: TCheckBox
        Left = 32
        Top = 8
        Width = 161
        Height = 17
        Caption = '&Dump status to an XML file'
        TabOrder = 1
        OnClick = cbDumpXmlClick
      end
    end
  end
  object bOk: TButton
    Left = 8
    Top = 248
    Width = 65
    Height = 25
    Caption = '&Ok'
    Default = True
    TabOrder = 1
    OnClick = bOkClick
  end
  object bCancel: TButton
    Left = 80
    Top = 248
    Width = 65
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object sdXml: TSaveDialog
    DefaultExt = 'xml'
    Options = [ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Left = 292
    Top = 80
  end
end

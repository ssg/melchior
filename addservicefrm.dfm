object AddServiceForm: TAddServiceForm
  Left = 391
  Top = 326
  BorderStyle = bsDialog
  Caption = 'Service'
  ClientHeight = 210
  ClientWidth = 339
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 39
    Height = 13
    Caption = 'Protocol'
  end
  object Label2: TLabel
    Left = 120
    Top = 8
    Width = 20
    Height = 13
    Caption = 'Port'
  end
  object ComboBox1: TComboBox
    Left = 8
    Top = 24
    Width = 105
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 0
    Text = 'TCP Connect'
    Items.Strings = (
      'TCP Connect'
      'ICMP Ping')
  end
  object ComboBox2: TComboBox
    Left = 120
    Top = 24
    Width = 65
    Height = 21
    ItemHeight = 13
    TabOrder = 1
  end
end

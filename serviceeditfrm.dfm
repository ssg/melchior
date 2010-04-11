object ServiceEditForm: TServiceEditForm
  Left = 412
  Top = 241
  BorderStyle = bsDialog
  Caption = 'Service'
  ClientHeight = 101
  ClientWidth = 342
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 65
    Height = 13
    Caption = 'Service Name'
  end
  object Label2: TLabel
    Left = 136
    Top = 8
    Width = 39
    Height = 13
    Caption = 'Protocol'
  end
  object Bevel1: TBevel
    Left = 8
    Top = 56
    Width = 273
    Height = 9
    Shape = bsTopLine
  end
  object lPort: TLabel
    Left = 224
    Top = 8
    Width = 20
    Height = 13
    Caption = '&Port'
    FocusControl = ePort
  end
  object eServiceName: TEdit
    Left = 8
    Top = 24
    Width = 121
    Height = 21
    TabOrder = 0
  end
  object cbProtocol: TComboBox
    Left = 136
    Top = 24
    Width = 81
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 1
    OnChange = cbProtocolChange
    Items.Strings = (
      'TCP'
      'ICMP')
  end
  object bOk: TButton
    Left = 8
    Top = 64
    Width = 65
    Height = 25
    Caption = '&Ok'
    Default = True
    TabOrder = 3
    OnClick = bOkClick
  end
  object bCancel: TButton
    Left = 80
    Top = 64
    Width = 65
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object ePort: TEdit
    Left = 224
    Top = 24
    Width = 57
    Height = 21
    TabOrder = 2
  end
end

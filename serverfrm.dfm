object ServerForm: TServerForm
  Left = 326
  Top = 216
  BorderStyle = bsDialog
  Caption = 'Server Properties'
  ClientHeight = 248
  ClientWidth = 339
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
  object Label2: TLabel
    Left = 8
    Top = 8
    Width = 27
    Height = 13
    Caption = 'Name'
  end
  object Label3: TLabel
    Left = 8
    Top = 48
    Width = 39
    Height = 13
    Caption = 'Address'
  end
  object GroupBox1: TGroupBox
    Left = 168
    Top = 8
    Width = 161
    Height = 199
    Caption = 'Monitored Services'
    TabOrder = 0
    object clbServices: TCheckListBox
      Left = 8
      Top = 16
      Width = 145
      Height = 175
      ItemHeight = 13
      TabOrder = 0
    end
  end
  object bOk: TButton
    Left = 8
    Top = 216
    Width = 65
    Height = 25
    Caption = '&Ok'
    Default = True
    TabOrder = 1
    OnClick = bOkClick
  end
  object bCancel: TButton
    Left = 80
    Top = 216
    Width = 73
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object bConfigure: TButton
    Left = 205
    Top = 216
    Width = 123
    Height = 25
    Caption = '&Configure Services...'
    TabOrder = 3
    OnClick = bConfigureClick
  end
  object eName: TEdit
    Left = 8
    Top = 24
    Width = 145
    Height = 21
    TabOrder = 4
  end
  object eAddress: TEdit
    Left = 8
    Top = 64
    Width = 145
    Height = 21
    TabOrder = 5
  end
  object rgPriority: TRadioGroup
    Left = 8
    Top = 96
    Width = 145
    Height = 111
    Caption = 'Priority'
    ItemIndex = 0
    Items.Strings = (
      'Default'
      'Low'
      'Medium'
      'High')
    TabOrder = 6
  end
end

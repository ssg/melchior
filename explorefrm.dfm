object ExploreForm: TExploreForm
  Left = 338
  Top = 197
  BorderStyle = bsDialog
  Caption = 'Explore Network'
  ClientHeight = 359
  ClientWidth = 328
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object eStartIP: TLabeledEdit
    Left = 8
    Top = 24
    Width = 97
    Height = 21
    EditLabel.Width = 66
    EditLabel.Height = 13
    EditLabel.Caption = 'S&tart Address'
    TabOrder = 0
  end
  object eEndIP: TLabeledEdit
    Left = 112
    Top = 24
    Width = 97
    Height = 21
    EditLabel.Width = 60
    EditLabel.Height = 13
    EditLabel.Caption = '&End Address'
    TabOrder = 1
  end
  object bScan: TButton
    Left = 216
    Top = 24
    Width = 49
    Height = 21
    Caption = '&Scan'
    Default = True
    TabOrder = 2
  end
  object lvHosts: TListView
    Left = 8
    Top = 64
    Width = 313
    Height = 257
    Columns = <
      item
        Caption = 'IP'
        Width = 100
      end
      item
        Caption = 'Name'
        Width = 190
      end>
    ColumnClick = False
    MultiSelect = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 3
    ViewStyle = vsReport
  end
  object bAddSelected: TButton
    Left = 80
    Top = 328
    Width = 73
    Height = 25
    Caption = '&Add Selected'
    TabOrder = 5
  end
  object bClose: TButton
    Left = 160
    Top = 328
    Width = 65
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 6
  end
  object pbScan: TProgressBar
    Left = 8
    Top = 48
    Width = 313
    Height = 13
    TabOrder = 7
  end
  object bSelectAll: TButton
    Left = 8
    Top = 328
    Width = 65
    Height = 25
    Caption = '&Select All'
    TabOrder = 4
  end
  object bStop: TButton
    Left = 272
    Top = 24
    Width = 49
    Height = 21
    Caption = '&Stop'
    Enabled = False
    TabOrder = 8
  end
end

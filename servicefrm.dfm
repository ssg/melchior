object ServiceForm: TServiceForm
  Left = 325
  Top = 281
  BorderStyle = bsDialog
  Caption = 'Monitored Services'
  ClientHeight = 250
  ClientWidth = 361
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
  object lvServices: TListView
    Left = 8
    Top = 8
    Width = 345
    Height = 201
    Columns = <
      item
        Caption = 'Service Name'
        Width = 100
      end
      item
        Caption = 'Protocol'
        Width = 75
      end
      item
        Alignment = taRightJustify
        Caption = 'Port'
      end
      item
        Caption = 'Service'
        Width = 100
      end>
    ColumnClick = False
    HideSelection = False
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnEdited = lvServicesEdited
    OnSelectItem = lvServicesSelectItem
  end
  object bAdd: TButton
    Left = 8
    Top = 216
    Width = 57
    Height = 25
    Caption = '&Add'
    TabOrder = 1
    OnClick = bAddClick
  end
  object bRemove: TButton
    Left = 152
    Top = 216
    Width = 57
    Height = 25
    Caption = '&Remove'
    TabOrder = 3
    OnClick = bRemoveClick
  end
  object bConfigure: TButton
    Left = 72
    Top = 216
    Width = 73
    Height = 25
    Caption = '&Configure'
    Default = True
    TabOrder = 2
    OnClick = bConfigureClick
  end
  object bClose: TButton
    Left = 288
    Top = 216
    Width = 67
    Height = 25
    Cancel = True
    Caption = '&Close'
    ModalResult = 1
    TabOrder = 4
  end
end

unit addservicefrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TAddServiceForm = class(TForm)
    Label1: TLabel;
    ComboBox1: TComboBox;
    Label2: TLabel;
    ComboBox2: TComboBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AddServiceForm: TAddServiceForm;

implementation

{$R *.dfm}

end.

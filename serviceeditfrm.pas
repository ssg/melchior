unit serviceeditfrm;

interface

uses
  Servers,

  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TServiceEditForm = class(TForm)
    Label1: TLabel;
    eServiceName: TEdit;
    Label2: TLabel;
    cbProtocol: TComboBox;
    bOk: TButton;
    bCancel: TButton;
    Bevel1: TBevel;
    lPort: TLabel;
    ePort: TEdit;
    procedure bOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbProtocolChange(Sender: TObject);
  public
    function GetService:TService;
  end;

var
  ServiceEditForm: TServiceEditForm;

implementation

{$R *.dfm}

procedure TServiceEditForm.bOkClick(Sender: TObject);
begin
  if not ValidServiceName(eServiceName.Text) then begin
    ShowMessage('Please type a valid service name');
    exit;
  end;

  if cbProtocol.ItemIndex < 0 then begin
    ShowMessage('Please choose a protocol for service');
    exit;
  end;

  ModalResult := mrOK;
end;

function TServiceEditForm.GetService: TService;
begin
  Result := TServiceType(RegisteredServices.Objects[cbProtocol.ItemIndex]).Create;
  Result.Name := eServiceName.Text;
  Result.Port := StrToIntDef(ePort.Text,0);
end;

procedure TServiceEditForm.FormCreate(Sender: TObject);
begin
  cbProtocol.Items.Assign(RegisteredServices);
end;

procedure TServiceEditForm.cbProtocolChange(Sender: TObject);
begin
  ePort.Enabled := true;
  lPort.Enabled := ePort.Enabled;
  if not ePort.Enabled then ePort.Text := '';
end;

end.

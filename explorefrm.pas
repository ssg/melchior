unit explorefrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls;

type
  TExploreForm = class(TForm)
    eStartIP: TLabeledEdit;
    eEndIP: TLabeledEdit;
    bScan: TButton;
    lvHosts: TListView;
    bAddSelected: TButton;
    bClose: TButton;
    pbScan: TProgressBar;
    bSelectAll: TButton;
    bStop: TButton;
    procedure FormShow(Sender: TObject);
  end;

var
  ExploreForm: TExploreForm;

implementation

uses

  WinSock;

{$R *.dfm}

procedure TExploreForm.FormShow(Sender: TObject);
var
  ar:array[0..255] of char;
  P:PHostEnt;
  sa,ea:DWORD;
begin
  if gethostname(@ar,SizeOf(ar)) = 0 then begin
    P := gethostbyname(@ar);
    if P <> NIL then begin
      sa := PInteger(P.h_addr^)^ and $ffffff;
      ea := sa or $fe000000;

      eStartIP.Text := inet_ntoa(in_addr(sa));
      eEndIP.Text := inet_ntoa(in_addr(ea));
    end else RaiseLastOSError;
  end else RaiseLastOSError;
end;

end.

unit serverfrm;

interface

uses
  servers,

  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, CheckLst;

type
  TServerForm = class(TForm)
    GroupBox1: TGroupBox;
    clbServices: TCheckListBox;
    bOk: TButton;
    bCancel: TButton;
    bConfigure: TButton;
    Label2: TLabel;
    Label3: TLabel;
    eName: TEdit;
    eAddress: TEdit;
    rgPriority: TRadioGroup;
    procedure bOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure bConfigureClick(Sender: TObject);
  public
    procedure SetData(server:TServer);
    procedure GetData(server:TServer);
    procedure BuildServiceList;
  end;

var
  ServerForm: TServerForm;

implementation

uses

  mainfrm, WinSock, ipfuncs;

{$R *.dfm}

procedure TServerForm.bOkClick(Sender: TObject);
var
  ip:integer;
begin
  // check valid address
  if Trim(eAddress.Text) = '' then begin
    MessageDlg('Please enter a valid address',mtWarning,[mbOK],0);
    exit;
  end;

  Screen.Cursor := crHourGlass;
  try
    ip := LookupName(eAddress.Text);
    if ip = INADDR_NONE then begin
      MessageDlg('Couldn''t resolve address "'+eAddress.Text+'"',mtWarning,[mbOK],0);
      exit;
    end;
    ModalResult := mrOK;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TServerForm.SetData(server: TServer);
var
  n,i:integer;
  list:TList;
  m:servers.TMonitor;
begin
  eName.Text := server.Name;
  eAddress.Text := server.IP;
  rgPriority.ItemIndex := byte(server.Severity);

  list := server.Monitors.LockList;
  for n:=0 to list.Count-1 do begin
    m := servers.TMonitor(list[n]);
    with clbServices do begin
      i := Items.IndexOfObject(m.Service);
      Checked[i] := true;
    end;
  end;
  server.Monitors.UnlockList;
end;

procedure TServerForm.BuildServiceList;
var
  n:integer;
  svc:TService;
  list:TList;
begin
  clbServices.Items.BeginUpdate;
  clbServices.Items.Clear;
  list := MonitoredServices.LockList;
  for n := 0 to list.Count-1 do begin
    svc := TService(list[n]);
    clbServices.Items.AddObject(svc.Name,svc);
  end;
  MonitoredServices.UnlockList;
  clbServices.Items.EndUpdate;
end;

procedure TServerForm.FormCreate(Sender: TObject);
begin
  BuildServiceList;
end;

procedure TServerForm.GetData(server: TServer);
var
  n,subn:integer;
  s:string;
  svc:TService;
  list:TList;
  m:servers.TMonitor;
  found:boolean;
begin
  s := Trim(eName.Text);
  if s ='' then
    server.Name := eAddress.Text
  else
    server.Name := s;

  with server do begin
    IPint := LookupName(eAddress.Text);
    IP := IpToStr(IPint);

    byte(Severity) := rgPriority.ItemIndex;
    list := Monitors.LockList;
    for n:=0 to clbServices.Items.Count-1 do begin
      svc := TService(clbServices.Items.Objects[n]);
      if clbServices.Checked[n] then begin
        // add if not exists 
        found := false;
        for subn := 0 to list.Count-1 do begin
          m := servers.TMonitor(list[subn]);
          if m.Service = svc then begin
            found := true;
            break;
          end;
        end;

        if not found then begin
          m := servers.TMonitor.Create(server,svc,ssDefault);
          list.Add(m);
        end;
      end else begin
        // remove if exists
        for subn := 0 to list.Count-1 do begin
          m := servers.TMonitor(list[subn]);
          if m.Service = svc then begin
            list.Delete(subn);
            m.Free;
            break;
          end;
        end;
      end;
    end;
    Monitors.UnlockList;
  end;
end;

procedure TServerForm.bConfigureClick(Sender: TObject);
begin
  Main.ConfigureServices;
  BuildServiceList;
end;

end.

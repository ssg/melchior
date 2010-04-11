unit servicefrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls;

type
  TServiceForm = class(TForm)
    lvServices: TListView;
    bAdd: TButton;
    bRemove: TButton;
    bConfigure: TButton;
    bClose: TButton;
    procedure FormCreate(Sender: TObject);
    procedure bAddClick(Sender: TObject);
    procedure bRemoveClick(Sender: TObject);
    procedure bConfigureClick(Sender: TObject);
    procedure lvServicesEdited(Sender: TObject; Item: TListItem;
      var S: String);
    procedure lvServicesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  public
    procedure BuildList;
  end;

var
  ServiceForm: TServiceForm;

implementation

uses

  mainfrm, servers, serviceeditfrm,

  WinSock;

{$R *.dfm}

{ TServiceForm }

procedure TServiceForm.BuildList;
var
  list:TList;
  n:integer;
  svc:TService;
  item:TListItem;
begin
  lvServices.Items.BeginUpdate;
  lvServices.Items.Clear;
  list := MonitoredServices.LockList;
  for n:=0 to list.Count-1 do begin
    svc := TService(list[n]);
    item := lvServices.Items.Add;
    item.Caption := svc.Name;
    item.SubItems.Add(svc.ProtocolName);
    item.SubItems.Add(PortToStr(svc.Port));
    item.SubItems.Add(svc.GetServiceName);
    item.Data := svc;
  end;
  lvServices.Items.EndUpdate;
end;

procedure TServiceForm.FormCreate(Sender: TObject);
begin
  BuildList;
end;

procedure TServiceForm.bAddClick(Sender: TObject);
var
  svc:TService;
begin
  Application.CreateForm(TServiceEditForm,ServiceEditForm);
  if ServiceEditForm.ShowModal = mrOK then begin
    svc := ServiceEditForm.GetService;
    if svc.Configure then begin
      Main.SuspendHeartbeat;
      MonitoredServices.Add(svc);
      BuildList;
      Main.BuildColumns;
      Main.ResumeHeartbeat;
    end;
  end;
  ServiceEditForm.Free;
end;

procedure TServiceForm.bRemoveClick(Sender: TObject);
var
  item:TListItem;
begin
  item := lvServices.Selected;
  if item = NIL then exit;
  if MessageDlg('Do you want to remove service "'+item.Caption+'"?',mtConfirmation,
    [mbYes,mbNo],0) = mrYes then begin
    Main.SuspendHeartbeat;
    MonitoredServices.Remove(item.Data);
    BuildList;
    Main.BuildColumns;
    Main.ResumeHeartbeat;
  end;
end;

procedure TServiceForm.bConfigureClick(Sender: TObject);
var
  item:TListItem;
begin
  item := lvServices.Selected;
  if item = NIL then exit;
  TService(item.Data).Configure;
end;

procedure TServiceForm.lvServicesEdited(Sender: TObject; Item: TListItem;
  var S: String);
begin
  if ValidServiceName(S) then TService(Item.Data).Name := S
    else S := TService(Item.Data).Name;
end;

procedure TServiceForm.lvServicesSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  svc:TService;
begin
  svc := TService(item.Data);
  bConfigure.Enabled := svc.SupportsConfigure;
end;

end.

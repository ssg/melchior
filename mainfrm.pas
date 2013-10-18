{
Melchior
Coded by SSG / Feb 2003

To do's:
--------
- Histogram
- Status in systray
- Plugins
- Do not allow multiple instances
}

unit mainfrm;

interface

uses
  ipfuncs,

  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, ComCtrls, Menus, ToolWin, ExtCtrls, ShellApi, ImgList,
  StdCtrls, AppEvnts, XPMan;

type
  TMonitorThread = class(TThread)
  public
    Monitoring : boolean;
    LastRefresh : longword;
    LastStatus : string;
    LetGo : boolean;
    procedure DoMessages;
  protected
    procedure Execute;override;
  end;

  TDumpThread = class(TThread)
  public
    DumpNow : boolean;
  protected
    procedure Execute;override;
  end;

  TRefreshThread = class(TThread)
  private
    procedure DoRefresh;
  protected
    procedure Execute;override;
  end;

  TMain = class(TForm)
    sbMain: TStatusBar;
    lvServers: TListView;
    pmServer: TPopupMenu;
    AddServer1: TMenuItem;
    EditServer1: TMenuItem;
    DeleteServer1: TMenuItem;
    pmMonitor: TPopupMenu;
    StopMonitoring1: TMenuItem;
    mmMain: TMainMenu;
    File1: TMenuItem;
    Add1: TMenuItem;
    Edit1: TMenuItem;
    Remove1: TMenuItem;
    Exit1: TMenuItem;
    N2: TMenuItem;
    Help1: TMenuItem;
    AboutMelchior1: TMenuItem;
    ilMain: TImageList;
    Configure1: TMenuItem;
    Preferences2: TMenuItem;
    Services1: TMenuItem;
    AppEvents: TApplicationEvents;
    XPManifest: TXPManifest;
    pmTray: TPopupMenu;
    Restore1: TMenuItem;
    N1: TMenuItem;
    N5: TMenuItem;
    mStartMonitoring: TMenuItem;
    mStopMonitoring: TMenuItem;
    Exit2: TMenuItem;
    N6: TMenuItem;
    AboutMelchior2: TMenuItem;
    MainCoolBar: TCoolBar;
    tbMain: TToolBar;
    tbStartMonitoring: TToolButton;
    tbStopMonitoring: TToolButton;
    tbServer: TToolBar;
    eAddress: TEdit;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    hcServers: THeaderControl;
    Start1: TMenuItem;
    Stop1: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    ExploreNetwork1: TMenuItem;
    pmService: TPopupMenu;
    oggleMonitoringforAllServers1: TMenuItem;
    Enable1: TMenuItem;
    Disable1: TMenuItem;
    dumpTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure lvServersData(Sender: TObject; Item: TListItem);
    procedure tbStartMonitoringClick(Sender: TObject);
    procedure tbStopMonitoringClick(Sender: TObject);
    procedure lvServersCustomDrawSubItem(Sender: TCustomListView;
      Item: TListItem; SubItem: Integer; State: TCustomDrawState;
      var DefaultDraw: Boolean);
    procedure AboutMelchior1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tbAddClick(Sender: TObject);
    procedure lvServersEdited(Sender: TObject; Item: TListItem;
      var S: String);
    procedure DeleteServer1Click(Sender: TObject);
    procedure Remove1Click(Sender: TObject);
    procedure Preferences2Click(Sender: TObject);
    procedure tbRemoveClick(Sender: TObject);
    procedure eAddressKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AppEventsMinimize(Sender: TObject);
    procedure AppEventsRestore(Sender: TObject);
    procedure Exit2Click(Sender: TObject);
    procedure mStartMonitoringClick(Sender: TObject);
    procedure mStopMonitoringClick(Sender: TObject);
    procedure Restore1Click(Sender: TObject);
    procedure pmTrayPopup(Sender: TObject);
    procedure lvServersDblClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Edit1Click(Sender: TObject);
    procedure Add1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure hcServersSectionResize(HeaderControl: THeaderControl;
      Section: THeaderSection);
    procedure EditServer1Click(Sender: TObject);
    procedure AddServer1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Services1Click(Sender: TObject);
    procedure Start1Click(Sender: TObject);
    procedure Stop1Click(Sender: TObject);
    procedure ExploreNetwork1Click(Sender: TObject);
    procedure hcServersContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Enable1Click(Sender: TObject);
    procedure Disable1Click(Sender: TObject);
    procedure lvServersKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvServersMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure dumpTimerTimer(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
  private
    MonitorThread : TMonitorThread;
    RefreshThread : TRefreshThread;
    DumpThread : TDumpThread;
    data : TNotifyIconData;

    procedure HandleTray(var msg:TMessage);message CM_TRAY;
  public
    procedure LoadConfiguration;
    procedure SaveConfiguration;

    procedure LoadPrefs;
    procedure SavePrefs;

    procedure BuildColumns;
    procedure RefreshList;
    procedure RefreshStatus;

    procedure status(s:string);

    procedure StartMonitoring;
    procedure StopMonitoring;

    procedure QuickAdd;
    procedure RemoveSelected;
    procedure ShowPrefs;
    procedure ServerProperties;
    procedure ConfigureServices;
    procedure AddNewServer;

    procedure UpdateHeaders;

    function GetTip:string;

    procedure InitTray;

    procedure ServiceToggle(yeah:boolean);

    procedure SuspendHeartbeat;
    procedure ResumeHeartbeat;
  end;

var
  Main: TMain;

implementation

uses

  prefs, servers, tools, svcicmp, svctcp, serverfrm, servicefrm, explorefrm,

  UITypes,Types, ActiveX, DateUtils, MMSystem, CommCtrl, Winsock, MSXML;

{$R *.dfm}

procedure TMonitorThread.DoMessages;
begin
  Application.HandleMessage;
end;

procedure TMonitorThread.Execute;

  procedure SendPacket(m:TMonitor);
  begin
    m.Service.AsyncMonitor(m);
  end;

var
  sl,sublist:TList;
  currentServer,currentMonitor:integer;
  server:TServer;
  m:TMonitor;
begin
  InitWinsock;
  currentServer := 0;
  currentMonitor := 0;
  while not LetGo do begin
    Sleep(1);
    if Monitoring then begin
      // iterate each server
      sl := MonitoredServers.LockList;
      if currentServer < sl.Count then begin
        server := TServer(sl[currentServer]);
        with server.Monitors do begin
          sublist := LockList;
          if currentMonitor < sublist.Count then begin
            m := TMonitor(sublist[currentMonitor]);
            with m do begin
              if InternalStatus = isRequestSent then
              begin
                if timeGetTime-LastSent > MonitoringTimeout then begin
                  // timeout

                  KillSocket(Socket);
                  Status := stDown;
                  inc(AckTotal,MonitoringTimeout);
                  inc(AckCount);
                  inc(DownCount);
                  InternalStatus := isReady;
                end;
              end;

              if (InternalStatus = isReady) and (
                  timeGetTime-LastSent > MonitoringInterval) then
              begin
                // send a new packet

                SendPacket(m);
                InternalStatus := isRequestSent;
                LastSent := timeGetTime;
                inc(MonitorCount);
                inc(server.MonitorCount);
              end;
            end;

            inc(currentMonitor);
          end else begin
            currentServer := (currentServer+1) mod sl.Count;
            currentMonitor := 0;
          end;
          UnlockList;
        end;
      end else currentServer := (currentServer+1) mod sl.Count;
      MonitoredServers.UnlockList;
    end;
  end;
end;

procedure TMain.BuildColumns;
var
  col:TListColumn;
  n:integer;
  svc:TService;
  list:TList;
begin
  // clear pre-built columns

  with lvServers do begin
    Columns.BeginUpdate;
    while Columns.Count > 2 do Columns.Delete(Columns.Count-1);

    // rebuild listview columns

    list := MonitoredServices.LockList;
    for n:=0 to list.Count-1 do begin
      svc := list[n];

      col := Columns.Add;
      col.Caption := svc.Name;
      col.Width := GetCfgInt('ListColumnWidth'+IntToStr(n+2),col.Width);
    end;
    MonitoredServices.UnlockList;

    UpdateHeaders;
  end;
end;

procedure TMain.RefreshList;
var
  list:TList;
begin
  list := MonitoredServers.LockList;
  with lvServers.Items do
    if Count <> list.Count then Count := list.Count;
  MonitoredServers.UnlockList;
  lvServers.Repaint;
  RefreshStatus;
  Application.ProcessMessages;
end;

procedure TMain.LoadConfiguration;
var
  doc:IXMLDOMDocument;
  nodeList, subNodeList:IXMLDOMNodeList;
  node, subNode:IXMLDOMNode;
  elem:IXMLDOMElement;
  service:TService;
  server:TServer;
  proto:string;
  i:integer;

begin
  Screen.Cursor := crHourGlass;
  try
    doc := CoDOMDocument.Create;
  except
    Screen.Cursor := crDefault;
    MessageDlg('MSXML 3.0 not found - Program will suck',mtError,[mbOK],0);
    exit;
  end;
  try
    if doc.Load(ExpandFileName(ConfigurationFileName)) then begin
      // load services

      MonitoredServers.Clear;
      MonitoredServices.Clear;

      // load service data

      nodeList := doc.documentElement.selectNodes('services/service');
      node := nodeList.nextNode;
      while node <> NIL do begin
        elem := node as IXMLDOMElement;
        proto := GetAtt(elem,'protocol');
        i := RegisteredServices.IndexOf(proto);
        if i >= 0 then begin
          // known protocol

          service := TServiceType(RegisteredServices.Objects[i]).Create;
          try
            service.LoadFromElement(elem);
            MonitoredServices.Add(service);
          except
            // failed loading service data

            service.Free;
          end;
        end;
        node := nodeList.nextNode;
      end;

      // load server data

      nodeList := doc.documentElement.selectNodes('servers/server');
      node := nodeList.nextNode;
      while node <> NIL do begin
        elem := node as IXMLDOMElement;
        server := TServer.Create(GetAtt(elem,'name'),GetAtt(elem,'ip'),StrToSeverity(GetAtt(elem,'severity')));
        server.IsMonitoring := GetAtt(elem,'enabled') <> 'no';
        subNodeList := elem.selectNodes('monitor');
        subNode := subNodeList.nextNode;
        while subNode <> NIL do begin
          elem := subNode as IXMLDOMElement;
          service := GetServiceByName(GetAtt(elem, 'service'));
          if service <> NIL then server.Monitors.Add(TMonitor.Create(server,service,StrToSeverity(GetAtt(elem,'severity'))));
          subNode := subNodeList.nextNode;
        end;

        MonitoredServers.Add(server);

        node := nodeList.nextNode;
      end;

      BuildColumns;
      RefreshList;
    end;
  finally
    doc := NIL;
    Screen.Cursor := crDefault;
  end;
end;

procedure TMain.SaveConfiguration;
var
  doc:DOMDocument;
  elem,parent,subelem:IXMLDOMElement;
  list,sublist:TList;
  svc:TService;
  srv:TServer;
  m:TMonitor;
  n,subn:integer;
begin
  Screen.Cursor := crHourGlass;
  doc := CoDOMDocument.Create;
  doc.loadXML('<!-- generated file - preferably do not edit -->'#13#10'<melchior/>');
  elem := doc.createElement('monitoring');
  doc.documentElement.appendChild(elem);

  // services

  parent := doc.createElement('services');
  doc.documentElement.appendChild(parent);
  list := MonitoredServices.LockList;
  for n:=0 to list.Count-1 do begin
    svc := TService(list[n]);
    elem := doc.createElement('service');
    svc.SaveToElement(elem);
    parent.appendChild(elem);
  end;
  MonitoredServices.UnlockList;

  parent := doc.createElement('servers');
  doc.documentElement.appendChild(parent);
  list := MonitoredServers.LockList;
  for n:=0 to list.Count-1 do begin
    srv := TServer(list[n]);
    elem := doc.createElement('server');
    elem.setAttribute('name',srv.Name);
    elem.setAttribute('ip',srv.IP);

    sublist := srv.Monitors.LockList;
    for subn := 0 to sublist.Count-1 do begin
      m := TMonitor(sublist[subn]);
      subelem := doc.createElement('monitor');
      subelem.setAttribute('service',m.Service.Name);
      if m.Severity <> ssDefault then
        subelem.setAttribute('severity',SeverityToStr(m.Severity));

      elem.appendChild(subelem);
    end;
    srv.Monitors.UnlockList;
    parent.appendChild(elem);
  end;
  MonitoredServers.UnlockList;

  doc.save('Melchior.xml');
  doc := NIL;
  Screen.Cursor := crDefault;
end;

procedure TMain.FormCreate(Sender: TObject);
begin
  InitTray;
  InitWinsock;
  lvServers.DoubleBuffered := true;
  hcServers.DoubleBuffered := true;
  MainCoolBar.DoubleBuffered := true;
  LoadPrefs;
  LoadConfiguration;
  ReadFormState(Self);

  // paint refresh daemon

  RefreshThread := TRefreshThread.Create(true);
  RefreshThread.Priority := tpIdle;
  RefreshThread.Resume;

  // monitoring manager

  MonitorThread := TMonitorThread.Create(false);
  RefreshStatus;

  // dump thread

  DumpThread := TDumpThread.Create(true);
  DumpThread.Priority := tpIdle;
  DumpThread.Resume;

  // dump timer

  dumpTimer.Interval := DumpXmlInterval;
  dumpTimer.Enabled := DumpXml;
end;

procedure TMain.lvServersData(Sender: TObject; Item: TListItem);
var
  server:TServer;
  list,sublist,svclist:TList;
  m:TMonitor;
  n,subn:integer;
  found:boolean;
  svc:TService;
  s:string;
begin
  list := MonitoredServers.LockList;
  svclist := MonitoredServices.LockList;
  server := list[Item.Index];
  Item.Caption := server.Name;
  Item.SubItems.Add(server.IP);
  for n:=2 to lvServers.Columns.Count-1 do begin
    svc := TService(svclist[n-2]);
    found := false;
    sublist := server.Monitors.LockList;
    for subn := 0 to sublist.Count-1 do begin
      m := TMonitor(sublist[subn]);
      if m.Service = svc then begin
        s := m.StatusText;
        item.SubItems.Add(s);
        found := true;
        break;
      end;
    end;
    server.Monitors.UnlockList;
    if not found then item.SubItems.Add('');
  end;
  MonitoredServices.UnlockList;
  MonitoredServers.UnlockList;
end;

procedure TMain.tbStartMonitoringClick(Sender: TObject);
begin
  StartMonitoring;
end;

procedure TMain.status(s: string);
begin
  sbMain.Panels[4].Text := s;
end;

procedure TMain.tbStopMonitoringClick(Sender: TObject);
begin
  StopMonitoring;
end;

procedure TMain.StartMonitoring;
begin
  MonitorThread.Monitoring := true;
  sbMain.Panels[0].Text := 'Monitoring';
  tbStopMonitoring.Enabled := true;
  tbStartMonitoring.Enabled := false;
end;

procedure TMain.StopMonitoring;
var
  n,subn:integer;
  list,sublist:TList;
  server:TServer;
  m:TMonitor;
begin
  MonitorThread.Monitoring := false;
  list := MonitoredServers.LockList;
  for n:=0 to list.Count-1 do begin
    server := TServer(list[n]);
    with server.Monitors do begin
      sublist := LockList;
      for subn := 0 to sublist.Count-1 do begin
        m := TMonitor(sublist[subn]);
        with m do begin
          KillSocket(Socket);
          Socket := 0;
          LastSent := 0;
          Seq := 0;
          AckLatency := 0;
          AckCount := 0;
          AckTotal := 0;
          Status := stUnknown;
          InternalStatus := isReady;
        end;
      end;
      UnlockList;
    end;
  end;
  MonitoredServers.UnlockList;
  RefreshList;
  tbStartMonitoring.Enabled := true;
  tbStopMonitoring.Enabled := false;
  sbMain.Panels[0].Text := 'Stopped';
end;

procedure TMain.lvServersCustomDrawSubItem(Sender: TCustomListView;
  Item: TListItem; SubItem: Integer; State: TCustomDrawState;
  var DefaultDraw: Boolean);
type
  TRGB = packed record
    R,G,B:integer;
  end;
var
  server:TServer;
  s:string;
  m:TMonitor;
  list:TList;
  n:integer;
  found:boolean;
  color:TColor;
  col:TListColumn;
  Rect:TRect;
  ratio:integer;
const  
  sc : TRGB = (R:0;G:127;B:0);
  ec : TRGB = (R:0;G:255;B:0);
begin
  DefaultDraw := true;
  if SubItem = 0 then exit;

  list := MonitoredServers.LockList;
  server := TServer(list[Item.Index]);
  MonitoredServers.UnlockList;

  col := lvServers.Columns[SubItem];
  s := col.Caption;
  m := NIL;
  found := false;
  list := server.Monitors.LockList;
  for n:=0 to list.Count-1 do begin
    m := TMonitor(list[n]);
    if s = m.Service.Name then begin
      found := true;
      break;
    end;
  end;
  server.Monitors.UnlockList;

  if not found then exit;

  with m do
    case Status of
      stUp : begin
        ratio := ((MonitoringTimeout-(AckTotal div AckCount)) shl 8) div MonitoringTimeout;
        color :=
          ((((ec.R-sc.R)*ratio shr 8)+sc.R) and $FF) or
          (((((ec.G-sc.G)*ratio shr 8)+sc.G) and $FF) shl 8) or
          (((((ec.B-sc.B)*ratio shr 8)+sc.B) and $FF) shl 16);
      end;
      stDown : if (DownCount > 1) then color := clRed else color := clYellow;
      stFailure : color := clRed;
      stUnknown : color := clYellow;
      else exit;
    end; {case}

  DefaultDraw := false;

  with lvServers.Canvas do begin
    Brush.Color := color;
    Font.Color := clBlack;

    ListView_GetSubItemRect(lvServers.Handle, Item.Index, SubItem, LVIR_BOUNDS, @Rect);

    FillRect(Rect);
    TextRect(Rect, Rect.Left+2, Rect.Top, m.StatusText);
  end;
end;

procedure TMain.RefreshStatus;
var
  dwFlags:DWORD;
  list,sublist:TList;
  server:TServer;
  m:TMonitor;
  n,cnt,subn,up,down:integer;
  upfound,downfound:boolean;
  b:boolean;
begin
  b := InternetGetConnectedState(dwFlags,0);
  if b <> IsOnline then begin
    IsOnline := b;
    if b then sbMain.Panels[1].Text := 'Online' else sbMain.Panels[1].Text := 'Offline';
  end;

  list := MonitoredServers.LockList;
  cnt := list.Count;
  up := 0;
  down := 0;
  for n:=0 to cnt-1 do begin
    server := TServer(list[n]);
    upfound := false;
    downfound := false;
    with server.Monitors do begin
      sublist := LockList;
      for subn := 0 to sublist.Count-1 do begin
        m := TMonitor(sublist[subn]);
        case m.Status of
          stUp : upfound := true;
          stDown : downfound := true;
        end; {case}
      end;
      UnlockList;
    end;
    if upfound then inc(up) else if downfound then inc(down);
    // if (not upfound) and (not downfound) then inc(unknown);
  end;
  MonitoredServers.UnlockList;

  sbMain.Panels[2].Text := 'Up: '+IntToStr(up);
  sbMain.Panels[3].Text := 'Down: '+IntToStr(down);
end;

const

  lic : PWideChar = 'MAINICON';

procedure TMain.AboutMelchior1Click(Sender: TObject);
var
  params:TMsgBoxParamsW;
begin
  with params do begin
    cbSize := SizeOf(params);
    hInstance := SysInit.HInstance;
    hwndOwner := Self.Handle;
    lpszText := 'Melchior'#13'Version '+appVer+
          #13#13'Coded by'#13'Sedat "SSG" Kapanoglu'#13#13'ssg@sourtimes.org'#13+
          'http://ssg.sourtimes.org';
    lpszCaption := 'About Melchior';
    dwStyle := MB_USERICON or MB_OK;
    lpszIcon := lic;
    dwLanguageId := LANG_NEUTRAL;
    dwContextHelpId := 0;
    lpfnMsgBoxCallback := NIL;
  end;
  MessageBoxIndirectW(params);
end;

procedure TMain.FormDestroy(Sender: TObject);
begin
  StopMonitoring;
  MonitorThread.Terminate;
  TerminateThread(MonitorThread.Handle,0);
  WSACleanup;

  SaveFormState(Self);
  SavePrefs;
  SaveConfiguration;
end;

procedure TMain.tbAddClick(Sender: TObject);
begin
  QuickAdd;
end;

procedure TMain.QuickAdd;
var
  server:TServer;
  name,ipstr:string;
  ip:Cardinal;
begin
  Screen.Cursor := crHourGlass;
  try
    name := Trim(eAddress.Text);
    if name = '' then exit;
    ip := LookupName(name);
    if ip = INADDR_NONE then begin
      status('Couldn''t resolve '+name);
      exit;
    end;
    ipstr := IpToStr(ip);

    server := TServer.Create(name,ipstr,ssDefault);
    MonitoredServers.Add(server);

    eAddress.Text := '';

    RefreshList;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMain.lvServersEdited(Sender: TObject; Item: TListItem;
  var S: String);
var
  server:TServer;
  list:TList;
begin
  list := MonitoredServers.LockList;
  server := TServer(list[Item.Index]);
  if S = '' then S := server.Name else server.Name := s;
  MonitoredServers.UnlockList;
end;

procedure TMain.RemoveSelected;
var
  item:TListItem;
  list:TList;
  server:TServer;
begin
  item := lvServers.ItemFocused;
  if item = NIL then begin
    status('No server selected');
    exit;
  end;

  list := MonitoredServers.LockList;
  server := TServer(list[item.Index]);
  MonitoredServers.UnlockList;

  if MessageDlg('Are you sure you want to remove server "'+server.Name+'"?',
    mtConfirmation,[mbYes,mbNo],0) = mrYes then begin
    Screen.Cursor := crHourGlass;
    MonitoredServers.Remove(server);
    server.Free;
    RefreshList;
    SaveConfiguration;
    Screen.Cursor := crDefault;
  end;
end;

procedure TMain.DeleteServer1Click(Sender: TObject);
begin
  RemoveSelected;
end;

procedure TMain.Remove1Click(Sender: TObject);
begin
  RemoveSelected;
end;

procedure TMain.Preferences2Click(Sender: TObject);
begin
  ShowPrefs;
end;

procedure TMain.ShowPrefs;
begin
  Application.CreateForm(TPrefsFrm,PrefsFrm);
  if PrefsFrm.ShowModal = mrOK then begin
    SavePrefs;
  end;
  PrefsFrm.Free;
end;

procedure TMain.LoadPrefs;
var
  n:integer;
  col:TListColumn;
begin
  MonitoringTimeout := GetCfgInt('MonitoringTimeout',DefaultTimeout);
  MonitoringInterval := GetCfgInt('MonitoringInterval',DefaultInterval);
  ListRefreshInterval := GetCfgInt('ListRefreshInterval',DefaultRefreshInterval);
  ShowLatency := GetCfgBool('ShowLatency',false);
  ShowInterpolated := GetCfgBool('ShowInterpolated',true);
  PromptOnExit := GetCfgBool('PromptOnExit',true);
  StartMinimized := GetCfgBool('StartMinimized',false);
  AutoStartMonitoring := GetCfgBool('AutoStartMonitoring',false);

  DumpXml := GetCfgBool('DumpXml',false);
  DumpXmlFilename := GetCfgStr('DumpXmlFilename','updown.xml');
  DumpXmlInterval := GetCfgInt('DumpXmlInterval',1);

  with lvServers do begin
    for n:=0 to Columns.Count-1 do begin
      col := Columns[n];
      col.Width := GetCfgInt('ListColumnWidth'+IntToStr(n),col.Width);
    end;
  end;
end;

procedure TMain.SavePrefs;
var
  n:integer;
begin
  PutCfgInt('MonitoringTimeout',MonitoringTimeout);
  PutCfgInt('MonitoringInterval',MonitoringInterval);
  PutCfgInt('ListRefreshInterval',ListRefreshInterval);
  PutCfgBool('ShowLatency',ShowLatency);
  PutCfgBool('ShowInterpolated',ShowInterpolated);
  PutCfgBool('PromptOnExit',PromptOnExit);
  PutCfgBool('StartMinimized',StartMinimized);
  PutCfgBool('AutoStartMonitoring',AutoStartMonitoring);

  PutCfgBool('DumpXml',DumpXml);
  PutCfgStr('DumpXmlFilename',DumpXmlFilename);
  PutCfgInt('DumpXmlInterval',DumpXmlInterval);

  with lvServers do begin
    for n:=0 to Columns.Count-1 do begin
      PutCfgInt('ListColumnWidth'+IntToStr(n),Columns[n].Width);
    end;
  end;
end;

procedure TMain.tbRemoveClick(Sender: TObject);
begin
  RemoveSelected;
end;

procedure TMain.eAddressKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then begin
    Key := 0;
    QuickAdd;
  end;
end;

procedure TMain.AppEventsMinimize(Sender: TObject);
begin
  if MinimizeToTray then begin

    ShowWindow(Application.Handle,SW_HIDE);
    with data do begin
      uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
      uCallbackMessage := CM_TRAY;
      hIcon := Application.Icon.Handle;
      StrPCopy(szTip,GetTip);
    end;

    Shell_NotifyIcon(NIM_ADD, @data);
  end;
end;

function TMain.GetTip: string;
begin
  with sbMain do
    Result := Panels[0].Text + ' | ' +
      Panels[1].Text + ' | ' +
      Panels[2].Text + ' | ' +
      Panels[3].Text;
end;

procedure TMain.AppEventsRestore(Sender: TObject);
begin
  if MinimizeToTray then begin
    ShowWindow(Handle,SW_SHOWNORMAL);

    Shell_NotifyIcon(NIM_DELETE, @data);

    SetForegroundWindow(Application.Handle);
  end;
end;

procedure TMain.HandleTray(var msg: TMessage);
begin
  case msg.LParam of
    WM_LBUTTONDBLCLK : Application.Restore;
    WM_MOUSEMOVE : begin
      // update tip

      with data do begin
        uFlags := NIF_TIP;
        StrPCopy(szTip,GetTip);
      end;

      Shell_NotifyIcon(NIM_MODIFY, @data);
    end;
    WM_CONTEXTMENU, WM_RBUTTONDOWN: begin
      // tray menu

      with Mouse.CursorPos do pmTray.Popup(X,Y);
    end;
  end; {case}
end;

procedure TMain.InitTray;
begin
  with data do begin
    cbSize := SizeOf;
    Wnd := Handle;
    uID := 0;
  end;
end;

procedure TMain.Exit2Click(Sender: TObject);
begin
  Self.Close;
end;

procedure TMain.mStartMonitoringClick(Sender: TObject);
begin
  StartMonitoring;
end;

procedure TMain.mStopMonitoringClick(Sender: TObject);
begin
  StopMonitoring;
end;

procedure TMain.Restore1Click(Sender: TObject);
begin
  Application.Restore;
end;

procedure TMain.pmTrayPopup(Sender: TObject);
var
  b:boolean;
begin
  b := MonitorThread.Monitoring;
  mStartMonitoring.Enabled := not b;
  mStopMonitoring.Enabled := b;
end;

procedure TMain.lvServersDblClick(Sender: TObject);
begin
  ServerProperties;
end;

procedure TMain.ServerProperties;
var
  item:TListItem;
  server:TServer;
  list:TList;
begin
  item := lvServers.ItemFocused;
  if item = NIL then exit;
  list := MonitoredServers.LockList;
  server := list[item.Index];
  MonitoredServers.UnlockList;
  Application.CreateForm(TServerForm,ServerForm);
  ServerForm.SetData(server);
  if ServerForm.ShowModal = mrOK then begin
    ServerForm.GetData(server);
    RefreshList;
  end;
  ServerForm.Free;
end;

procedure TMain.Exit1Click(Sender: TObject);
begin
  Self.Close;
end;

procedure TMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not PromptOnExit;
  if not CanClose then
    CanClose := MessageDlg('Exit Melchior?',mtConfirmation,[mbYes,mbNo],0) = mrYes;
end;

procedure TMain.Edit1Click(Sender: TObject);
begin
  ServerProperties;
end;

procedure TMain.Add1Click(Sender: TObject);
begin
  AddNewServer;
end;

procedure TMain.AddNewServer;
var
  server:TServer;
begin
  Application.CreateForm(TServerForm,ServerForm);
  ServerForm.Caption := 'Add a new server';
  if ServerForm.ShowModal = mrOK then begin
    server := TServer.Create('','',ssDefault);
    ServerForm.GetData(server);
    MonitoredServers.Add(server);
    RefreshList;
  end;
  ServerForm.Free;
end;

procedure TMain.ToolButton2Click(Sender: TObject);
begin
  RemoveSelected;
end;

// Update section headers according to listview column widths 
procedure TMain.UpdateHeaders;
var
  n:integer;
  sec:THeaderSection;
  i:integer;
begin
  with hcServers.Sections do begin
    BeginUpdate;
    Clear;

    with lvServers do begin
      for n:=0 to Columns.Count-1 do begin
        sec := Add;
        sec.Text := Columns[n].Caption;
        i := Columns[n].Width;
        if n = 0 then inc(i,4);
        hcServers.Sections[n].Width := i;
      end;
    end;

    EndUpdate;
  end;
end;

procedure TMain.hcServersSectionResize(HeaderControl: THeaderControl;
  Section: THeaderSection);
var
  n,i,w:integer;
begin
  w := Section.Width;
  i := Section.Index;
  if i = 0 then dec(w,4);
  lvServers.Columns[i].Width := w;
  CommCtrl.ListView_SetColumnWidth(lvServers.Handle,i,w);
  if i > 1 then begin
    for n:=i+1 to HeaderControl.Sections.Count-1 do begin
      if n <> i then begin
        HeaderControl.Sections[n].Width := w;
        lvServers.Columns[n].Width := w;
        CommCtrl.ListView_SetColumnWidth(lvServers.Handle,n,w);
      end;
    end;
  end;
end;

procedure TMain.EditServer1Click(Sender: TObject);
begin
  ServerProperties;
end;

procedure TMain.AddServer1Click(Sender: TObject);
begin
  AddNewServer;
end;

const

  InitComplete : boolean = false;

procedure TMain.FormShow(Sender: TObject);
begin
  if not InitComplete then begin
    if StartMinimized then Application.Minimize;
    if AutoStartMonitoring then StartMonitoring;
    InitComplete := true;
  end;
end;

procedure TMain.Services1Click(Sender: TObject);
begin
  ConfigureServices;
end;

procedure TMain.ConfigureServices;
begin
  Application.CreateForm(TServiceForm,ServiceForm);
  ServiceForm.ShowModal;
  ServiceForm.Free;
end;

procedure TMain.Start1Click(Sender: TObject);
begin
  StartMonitoring;
end;

procedure TMain.Stop1Click(Sender: TObject);
begin
  StopMonitoring;
end;

procedure TMain.ExploreNetwork1Click(Sender: TObject);
begin
  Application.CreateForm(TExploreForm,ExploreForm);
  ExploreForm.ShowModal;
  ExploreForm.Free;
end;

{ TRefreshThread }

procedure TRefreshThread.DoRefresh;
begin
  Main.RefreshList;
end;

procedure TRefreshThread.Execute;
begin
  while not Terminated do begin
    Sleep(1000);
{    if RefreshNeeded then begin}
      Synchronize(DoRefresh);
{      RefreshNeeded := false;
    end;}
  end;
end;

procedure TMain.hcServersContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  n,ix,found:integer;
  sec:THeaderSection;
begin
  ix := 0;
  found := -1;
  for n:=0 to hcServers.Sections.Count-1 do begin
    sec := hcServers.Sections[n];
    inc(ix,sec.Width);
    if MousePos.X < ix then begin
      found := n;
      break;
    end;
  end;

  if found > 1 then begin
    Handled := true;
    pmService.Tag := found-2;
    with ClientToScreen(MousePos) do pmService.Popup(X,Y);
  end;
end;

procedure TMain.ServiceToggle(yeah:boolean);
var
  list:TList;
  svc:TService;
  srv:TServer;
  n,subn:integer;
  sublist:TList;
  m:TMonitor;
  found:integer;
begin
  list := MonitoredServices.LockList;
  svc := TService(list[pmService.Tag]);

  list := MonitoredServers.LockList;
  for n:=0 to list.Count-1 do begin
    srv := TServer(list[n]);
    sublist := srv.Monitors.LockList;
    found := -1;
    m := NIL;
    for subn := 0 to sublist.Count-1 do begin
      m := TMonitor(sublist[subn]);
      if m.Service = svc then begin
        found := subn;
        break;
      end;
    end;
    case yeah of
      true:
        if found=-1 then begin
          m := TMonitor.Create(srv,svc,ssDefault);
          sublist.Add(m);
        end;
      false:
        if found >= 0 then begin
          sublist.Delete(found);
          m.Free;
        end;
    end; {case}
    srv.Monitors.UnlockList;
  end;

  MonitoredServices.UnlockList;
  MonitoredServers.UnlockList;

  RefreshNeeded := true;
end;


procedure TMain.Enable1Click(Sender: TObject);
begin
  ServiceToggle(true);
end;

procedure TMain.Disable1Click(Sender: TObject);
begin
  ServiceToggle(false);
end;

procedure TMain.ResumeHeartbeat;
begin
  RefreshThread.Resume;
  MonitorThread.Resume;
end;

procedure TMain.SuspendHeartbeat;
begin
  MonitorThread.Suspend;
  RefreshThread.Suspend;
end;

procedure TMain.lvServersKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_DELETE) and (Shift=[]) then begin
    Key := 0;
    RemoveSelected;
  end;
end;

procedure TMain.lvServersMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Rect:TRect;
  P:TPoint;
  item:TListItem;
  list:TList;
  n,subn:integer;
  srv:TServer;
  svc:TService;
  m:TMonitor;
  found:boolean;
begin
  item := lvServers.GetItemAt(X,Y);
  if item <> NIL then begin
    P.X := X;
    P.Y := Y;
    for n:=1 to item.SubItems.Count-1 do begin
      ListView_GetSubItemRect(lvServers.Handle,item.Index,n+1, LVIR_BOUNDS, @Rect);
      if PtInRect(Rect, P) then begin
        list := MonitoredServices.LockList;
        svc := TService(list[n-1]);

        list := MonitoredServers.LockList;
        srv := list[item.Index];

        list := srv.Monitors.LockList;
        found := false;
        m := NIL;
        for subn := 0 to list.Count-1 do begin
          m := TMonitor(list[subn]);
          if m.Service = svc then begin
            found := true;
            break;
          end;
        end;
        if found then list.Remove(m) else begin
          m := TMonitor.Create(srv,svc,ssDefault);
          list.Add(m);
        end;
        srv.Monitors.UnlockList;
        MonitoredServers.UnlockList;
        MonitoredServices.UnlockList;
        RefreshNeeded := true;
        exit;
      end;
    end;
  end;
end;

procedure TMain.dumpTimerTimer(Sender: TObject);
begin
  if MonitorThread.Monitoring then DumpThread.DumpNow := true;
end;

{ TDumpThread }

procedure TDumpThread.Execute;
  procedure DumpXmlStatus;
  var
    list,sublist:TList;
    n,subn:integer;
    F:TextFile;
    logtime:TDateTime;
    srv:TServer;
    m:TMonitor;
    upstr:string;
  begin
    // dump up/down status to timer
    logtime := Now;
    AssignFile(F,DumpXmlFilename);
    Rewrite(F);
    writeln(F,'<?xml version="1.0"?>');
    writeln(F,'<melchior-status date="'+DateToStr(logtime)+'" time="'+TimeToStr(logtime)+'">');
    list := MonitoredServers.LockList;
    try
      for n:=0 to list.Count-1 do begin
        srv := list[n];
        writeln(F,#9'<server name="'+xmlencode(srv.Name)+'" ip="'+srv.IP+'">');

        sublist := srv.Monitors.LockList;
        try
          for subn := 0 to sublist.Count-1 do begin
            m := sublist[subn];
            case m.Status of
              stUnknown : upstr := 'unknown';
              stUp : upstr := 'up';
              stDown : if m.DownCount = 1 then upstr := 'timeout' else upstr := 'down';
              else upstr := '???';
            end;
            write(F,#9#9'<service name="'+xmlencode(m.Service.Name)+'" status="'+upstr+'"');
            if m.Status=stUp then write(F,' latency="'+IntToStr(m.AckLatency)+'"');
            writeln(F,'/>');
          end;
        finally
          srv.Monitors.UnlockList;
          writeln(F,#9'</server>');
        end;
      end;
    finally
      MonitoredServers.UnlockList;
    end;
    writeln(F,'</melchior-status>');
    CloseFile(F);
  end;

begin
  CoInitialize(NIL);
  while true do begin
    if DumpNow then begin
      try
        DumpXmlStatus;
      finally
        DumpNow := false;
      end;
    end;
    Sleep(1000);
  end;
end;

procedure TMain.ToolButton1Click(Sender: TObject);
begin
  QuickAdd;
end;

end.

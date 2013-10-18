{
generic server data structures
}
unit servers;

interface

uses

  MSXML, Classes, Winsock, Contnrs;

type

  TMonitor = class;

  TService = class(TObject)
    Name : string;
    ProtocolName : string;
    BytesSent : Int64;
    BytesReceived : Int64;
    CreatedOn : TDateTime;
    Port : word;
    Params : TStringList;

    constructor Create;virtual;
    destructor Destroy;override;

    function GetParam(const name,default:string):string;
    procedure SetParam(const name:string; value:string);

    class function SupportsPort : boolean;virtual;
    class function SupportsConfigure : boolean;virtual;

    function Configure:boolean;virtual;
    function GetServiceName:string;virtual;
    procedure AsyncMonitor(m:TMonitor);virtual;abstract;

    procedure LoadFromElement(elem:IXMLDOMElement);
    procedure SaveToElement(elem:IXMLDOMElement);
  end;

  TServiceType = class of TService;

  TSeverity = (ssDefault, ssLow, ssMedium, ssHigh);

  TStatus = (stUnknown, stUp, stDown, stFailure);
  TInternalStatus = (isReady, isRequestSent);

  TServer = class(TObject)
    Name : string;
    IP : string;
    IPint : longword;
    Severity : TSeverity;
    Monitors : TThreadList;
    MonitorCount : longword; // stat
    IsMonitoring : boolean;

    constructor Create(const AName, AIP:string; ASeverity:TSeverity);
    destructor Destroy;override;
  end;

  TMonitor = class(TObject)
    Service : TService;
    Severity : TSeverity;
    Status : TStatus;
    InternalStatus : TInternalStatus;

    MonitorCount : longword; // stat
    LastSent : longword;
    AckLatency : longword;
    AckTotal : longword;
    AckCount : longword;
    DownCount : longword;
    ErrCode : integer;
    Socket : TSocket;
    Owner : TServer;

    Seq : word; // icmp only

    constructor Create(aowner:TServer; svc:TService; sev:TSeverity);
    destructor Destroy;override;
    function StatusText:string;
  end;

var

  MonitoredServices : TThreadList;
  MonitoredServers : TThreadList;

  RegisteredServices : TStringList;

function StrToSeverity(const s:string):TSeverity;
function GetServiceByName(const name:string):TService;
function PortToStr(port:word):string;
function SeverityToStr(s:TSeverity):string;

function ValidServiceName(const s:string):boolean;

function FindMonitor(socket:integer; svctype:TServiceType; addr:longword):TMonitor;overload;
function FindMonitor(socket:integer; svctype:TServiceType):TMonitor;overload;
function GetMonitor(serverIndex, serviceIndex:integer):TMonitor;

procedure InitLists;
procedure DoneLists;

procedure RegisterService(const name:string; T:TServiceType);

implementation

uses

  ipfuncs, tools,

  SysUtils;

procedure RegisterService;
begin
  RegisteredServices.AddObject(name,TObject(T));
end;

// check for dupe service names  

function ValidServiceName;
var
  n:integer;
  list:TList;
begin
  if s = '' then begin
    Result := false;
    exit;
  end;
  list := MonitoredServices.LockList;
  for n:=0 to list.Count-1 do begin
    if TService(list[n]).Name = s then begin
      MonitoredServices.UnlockList;
      Result := false;
      exit;
    end;
  end;
  MonitoredServices.UnlockList;
  Result := true;
end;

const

{  ProtocolStrArray : array[spPing..spTCP] of string =
        ('ICMP', 'TCP');}
  SeverityStrArray : array[ssDefault..ssHigh] of string =
        ('Default','Low','Medium','High');

function PortToStr(port:word):string;
begin
  if port = 0 then Result := 'N/A' else Result := IntToStr(port);
end;

function SeverityToStr(s:TSeverity):string;
begin
  Result := SeverityStrArray[s];
end;

{function ProtocolToStr;
begin
  Result := ProtocolStrArray[p];
end;}

function GetMonitor;
var
  n:integer;
  list,sublist:TList;
  svc:TService;
  server:TServer;
  m:TMonitor;
begin
  Result := NIL;

  list := MonitoredServices.LockList;
  svc := TService(list[serviceIndex]);
  MonitoredServices.UnlockList;

  list := MonitoredServers.LockList;
  server := TServer(list[serverIndex]);
  sublist := server.Monitors.LockList;
  for n:=0 to sublist.Count-1 do begin
    m := TMonitor(sublist[n]);
    if m.Service = svc then begin
      Result := m;
      break;
    end;
  end;
  server.Monitors.UnlockList;
  MonitoredServers.UnlockList;
end;

function FindMonitor(socket:integer; svctype:TServiceType):TMonitor;
begin
  Result := FindMonitor(socket,svctype,0);
end;

function FindMonitor(socket:integer; svctype:TServiceType; addr:longword):TMonitor;
var
  n, subn:integer;
  list,sublist:TList;
  server:TServer;
  m:TMonitor;
  found:boolean;
begin
  // find which monitor that socket belongs
  found := false;
  m := NIL;
  list := MonitoredServers.LockList;
  for n:=0 to list.Count-1 do begin
    server := list[n];
    if (addr = 0) or (addr = server.IPint) then begin
      sublist := server.Monitors.LockList;
      for subn := 0 to sublist.Count-1 do begin
        m := TMonitor(sublist[subn]);
        if m.Service is svctype then begin
          if m.Socket = socket then begin
            found := true;
            break;
          end;
        end;
      end;
      server.Monitors.UnlockList;
      if found then break;
    end;
  end;
  MonitoredServers.UnlockList;

  if found then Result := m else Result := NIL;
end;

function GetServiceByName;
var
  n:integer;
  list:TList;
begin
  list := MonitoredServices.LockList;
  for n:=0 to list.Count-1 do begin
    Result := list[n];
    if Result.Name = name then begin
      MonitoredServices.UnlockList;
      exit;
    end;
  end;
  MonitoredServices.UnlockList;
  Result := NIL;
end;

function StrToSeverity;
begin
  if s = 'high' then Result := ssHigh
  else if s = 'medium' then Result := ssMedium
  else if s = 'low' then Result := ssLow
  else Result := ssDefault;
end;

procedure InitLists;
begin
  RegisteredServices := TStringList.Create;
  MonitoredServices := TThreadList.Create;
  MonitoredServers := TThreadList.Create;
end;

procedure DoneLists;
begin
  MonitoredServices.Free;
  MonitoredServers.Free;
  RegisteredServices.Free;
end;

{ TServer }

constructor TServer.Create;
begin
  inherited Create;
  Name := AName;
  IP := AIP;
  IPint := inet_addr(PAnsiChar(AnsiString(IP)));
  Monitors := TThreadList.Create;
end;

destructor TServer.Destroy;
var
  list:TList;
  m:TMonitor;
  n:integer;
begin
  list := Monitors.LockList;
  for n:=0 to list.Count-1 do begin
    m := TMonitor(list[n]);
    m.Free;
  end;
  Monitors.UnlockList;
  Monitors.Free;
  inherited;
end;

{ TMonitor }

constructor TMonitor.Create;
begin
  inherited Create;
  Owner := aowner;
  Service := svc;
  Severity := sev;
  Status := stUnknown;
end;

destructor TMonitor.Destroy;
begin
  if Socket <> 0 then KillSocket(Socket);
  inherited;
end;

function TMonitor.StatusText: string;
begin
  case Status of
    stUnknown : Result := 'Unknown';
    stUp : if ShowLatency then
        Result := 'Up ('+IntToStr(AckLatency)+' ms)'
      else
        Result := 'Up';

    stDown : case DownCount of
      1 : Result := 'Timeout';
      else Result := 'Down';
    end;
    stFailure : Result := 'Failure';
  end; {case}
end;

{ TService }

function TService.Configure: boolean;
begin
  Result := true;
end;

constructor TService.Create;
begin
  inherited;
  CreatedOn := Now;
  Params := TStringList.Create;
  Params.Duplicates := dupIgnore;
end;

destructor TService.Destroy;
var
  n,subn:integer;
  list,sublist:TList;
  srv:TServer;
  m:TMonitor;
begin
  list := MonitoredServers.LockList;
  for n:=0 to list.Count-1 do begin
    srv := TServer(list[n]);
    sublist := srv.Monitors.LockList;
    subn := 0;
    while subn < sublist.Count do begin
      m := TMonitor(sublist[subn]);
      if m.Service = Self then begin
        sublist.Delete(subn);
        m.Free;
        continue;
      end;
      inc(subn);
    end;
    srv.Monitors.UnlockList;
  end;
  MonitoredServers.UnlockList;
  Params.Free;
  inherited;
end;

function TService.GetParam(const name, default: string): string;
begin
  Result := Params.Values[name];
  if Result = '' then Result := default;
end;

function TService.GetServiceName: string;
begin
  Result := '';
end;

procedure TService.LoadFromElement(elem: IXMLDOMElement);
var
  nodeList:IXMLDOMNodeList;
  node:IXMLDOMNode;
  tmp:IXMLDOMElement;
  i:integer;
begin
  Name := elem.getAttribute('name');
  if not ValidServiceName(Name) then raise Exception.Create('Invalid service name: '+Name);
  Port := StrToIntDef(GetAtt(elem,'port'),0);
  nodeList := elem.selectNodes('param');
  for i := 0 to nodeList.length - 1 do begin
    node := nodeList[i];
    tmp := node as IXMLDOMElement;
    Params.Values[tmp.getAttribute('name')] := tmp.nodeValue;
  end;
end;

procedure TService.SaveToElement(elem: IXMLDOMElement);
var
  n:integer;
  tmp:IXMLDOMElement;
  pn:string;
begin
  elem.setAttribute('name',Name);
  elem.setAttribute('protocol',ProtocolName);
  if Port <> 0 then elem.setAttribute('port', IntToStr(Port));

  for n:=0 to Params.Count-1 do begin
    tmp := elem.ownerDocument.createElement('param');
    pn := Params.Names[n];
    tmp.setAttribute('name',pn);
    tmp.nodeValue := Params.Values[pn];
    elem.appendChild(tmp);
  end;
end;

procedure TService.SetParam(const name: string; value: string);
begin
  Params.Values[name] := value;
end;

class function TService.SupportsConfigure: boolean;
begin
  Result := false;
end;

class function TService.SupportsPort: boolean;
begin
  Result := true;
end;

initialization
begin
  InitLists;
end;

finalization
begin
  DoneLists;
end;

end.

{
TCP Service
}
unit svctcp;

interface

uses

  servers,

  Messages;

type

  TTCPService = class(TService)
    Handle : THandle;
    constructor Create;override;
    destructor Destroy;override;

    function GetServiceName:string;override;
    procedure AsyncMonitor(m:TMonitor);override;

    procedure HandleMessage(var Msg:TMessage);
  end;

implementation

uses

  ipfuncs, tools,

  MMSystem, Windows, Classes, SysUtils, WinSock;

{ TTCPService }

procedure TTCPService.AsyncMonitor(m: TMonitor);
var
  sa:TSockAddrIn;
begin
  // close existing sockets

  if m.Socket <> 0 then KillSocket(m.Socket);

  // create a valid socket first

  FillChar(sa,SizeOf(sa),0);
  sa.sin_family := AF_INET;
  sa.sin_addr := in_addr(m.Owner.IPint);

  m.Socket := socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  sa.sin_port := htons(m.Service.Port);

  if WSAAsyncSelect(m.Socket,Handle,CM_TCP,FD_CONNECT) = SOCKET_ERROR then
    RaiseLastOSError;

  connect(m.Socket, sa, SizeOf(sa));
  inc(BytesSent,TotalTCPOverhead);
end;

constructor TTCPService.Create;
begin
  inherited;
  ProtocolName := 'TCP';
  Handle := AllocateHwnd(HandleMessage);
end;

destructor TTCPService.Destroy;
begin
  DeallocateHwnd(Handle);
  inherited;
end;

function TTCPService.GetServiceName: string;
var
  P:PServEnt;
begin
  P := getservbyport(htons(Port),'tcp');
  if P <> NIL then Result := P.s_name else Result := '';
end;

procedure TTCPService.HandleMessage(var Msg: TMessage);
var
  m:TMonitor;
begin
  if msg.LParamLo <> FD_CONNECT then exit;

  m := FindMonitor(msg.WParam,TTCPService);

  if m = NIL then exit;

  with m do begin
    AckLatency := timeGetTime-LastSent;
    if msg.LParamHi = 0 then begin
      Status := stUp;
      inc(AckTotal,AckLatency);
      inc(AckCount);
      m.DownCount := 0;
    end else begin
      Status := stDown;
      inc(m.DownCount);
      ErrCode := msg.LParamHi;
    end;
    inc(BytesReceived,TotalTCPOverhead);
    InternalStatus := isReady;
    KillSocket(m.Socket);
    Socket := 0;
    RefreshNeeded := true;
  end;
end;

begin
  RegisterService('TCP',TTCPService);
end.

{
ICMP Service
}
unit svcicmp;

interface

uses

  servers, ipfuncs,

  Messages, Windows, Classes;

type

  TICMPService = class(TService)
    Handle : THandle;
    constructor Create;override;
    destructor Destroy;override;

    class function SupportsPort:boolean;override;

    function GetServiceName:string;override;
    procedure AsyncMonitor(m:TMonitor);override;

    procedure HandleMessage(var Msg:TMessage);
  end;

implementation

uses

  tools,

  MMSystem, SysUtils, WinSock;

{ TICMPService }

class function TICMPService.SupportsPort;
begin
  Result := false;
end;

constructor TICMPService.Create;
begin
  inherited;
  ProtocolName := 'ICMP';
  Handle := AllocateHwnd(HandleMessage);
end;

destructor TICMPService.Destroy;
begin
  DeallocateHwnd(Handle);
  inherited;
end;

function TICMPService.GetServiceName: string;
begin
  Result := 'Ping';
end;

procedure TICMPService.HandleMessage(var Msg: TMessage);
var
  buf:TEchoReply;
  size,namelen:integer;
  sa:TSockAddrIn;
  m:TMonitor;
begin
  if msg.LParamLo <> FD_READ then exit;

  FillChar(buf,SizeOf(buf),0);
  namelen := SizeOf(sa);
  size := recvfrom(msg.WParam, buf, SizeOf(buf), 0, sa, namelen);
  if size = SOCKET_ERROR then
    if GetLastError <> WSAEWOULDBLOCK then exit;

  inc(BytesReceived,size + ICMPOverhead);

  m := FindMonitor(msg.WParam,TICMPService,Cardinal(buf.ipHdr.iaSrc));

  if m = NIL then exit;

  with m, buf.echoRequest do begin
    if icmpHdr.Seq = Seq then begin
      if (icmpHdr.Type_ = ICMP_ECHOREPLY) and (icmpHdr.Code = ICMP_ECHOREPLY) then begin
        Status := stUp;
        inc(AckTotal,AckLatency);
        inc(AckCount);
        AckLatency := timeGetTime-LastSent;
        DownCount := 0;
      end else begin
        Status := stDown;
        inc(DownCount);
      end;
      InternalStatus := isReady;
      KillSocket(Socket);
      Socket := 0;
      RefreshNeeded := true;
    end;
  end;
end;

procedure TICMPService.AsyncMonitor(m: TMonitor);
var
  sa:TSockAddrIn;
  req:TEchoRequest;
begin
  // close existing sockets

  if m.Socket <> 0 then KillSocket(m.Socket);

  // create a valid socket first

  FillChar(sa,SizeOf(sa),0);
  sa.sin_family := AF_INET;
  sa.sin_addr := in_addr(m.Owner.IPint);

  m.Socket := socket(AF_INET, SOCK_RAW, IPPROTO_ICMP);

  FillChar(req,SizeOf(req),0);

  with req,req.icmpHdr do begin
    Type_ := ICMP_ECHOREQ;
    Seq := icmpSeq;
    m.Seq := icmpSeq;
    inc(icmpSeq);

    Move(IcmpRequestData^,cData,ReqDataSize);
    dwTime := timeGetTime;

    Checksum := in_cksum(PWordArray(@req),SizeOf(req));
  end;

  if WSAAsyncSelect(m.Socket, Handle, CM_ICMP, FD_READ) = SOCKET_ERROR
    then RaiseLastOSError;

  sendto(m.Socket,req,SizeOf(req),0,sa,SizeOf(sa));
  inc(BytesSent,ICMPOverhead + SizeOf(req));
  
  RefreshNeeded := true;
end;

begin
  RegisterService('ICMP',TICMPService);
end.

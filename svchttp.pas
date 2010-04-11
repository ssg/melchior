{
TCP Service
}
unit svchttp;

interface

uses

  servers, ipfuncs,

  Messages;

const

  httpMinBufLength = 12;
  httpBufferSize = 4096;

type

  THTTPService = class(TService)
    Handle : THandle;
    constructor Create;override;
    destructor Destroy;override;

    function Configure:boolean;override;

    function GetServiceName:string;override;
    procedure AsyncMonitor(m:TMonitor);override;

    procedure HandleMessage(var Msg:TMessage);
  end;

implementation

uses

  tools,

  MMSystem, Windows, Classes, SysUtils, WinSock;

{ THTTPService }

function THTTPService.Configure:boolean;
begin

end;

procedure THTTPService.AsyncMonitor(m: TMonitor);
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

  if WSAAsyncSelect(m.Socket,Handle,CM_HTTP,FD_CONNECT or FD_READ or FD_CLOSE) = SOCKET_ERROR then
    RaiseLastOSError;

  connect(m.Socket, sa, SizeOf(sa));
  inc(BytesSent,TotalTCPOverhead);
end;

constructor THTTPService.Create;
begin
  inherited;
  ProtocolName := 'HTTP';
  Handle := AllocateHwnd(HandleMessage);
end;

destructor THTTPService.Destroy;
begin
  DeallocateHwnd(Handle);
  inherited;
end;

function THTTPService.GetServiceName: string;
begin
  Result := 'http';
end;

procedure THTTPService.HandleMessage(var Msg: TMessage);
var
  m:TMonitor;
  host,path,req:string;
  bufstr:string;
  buflen:integer;

  procedure finalizeMonitor;
  begin
    with m do begin
      inc(BytesReceived,TotalTCPOverhead);
      InternalStatus := isReady;
      KillSocket(m.Socket);
      Socket := 0;
      RefreshNeeded := true;
    end;
  end;

  procedure getDown;
  begin
    with m do begin
      AckLatency := timeGetTime-LastSent;
      Status := stDown;
      inc(m.DownCount);
      ErrCode := msg.LParamHi;
      finalizeMonitor;
    end;
  end;

  procedure getUp;
  begin
    with m do begin
      AckLatency := timeGetTime-LastSent;
      Status := stUp;
      inc(AckTotal,AckLatency);
      inc(AckCount);
      m.DownCount := 0;
      finalizeMonitor;
    end;
  end;

begin
  if msg.Msg <> CM_HTTP then exit;
  case msg.LParamLo of
    FD_CONNECT, FD_READ, FD_CLOSE : ;
    else exit;
  end; {case}

  m := FindMonitor(msg.WParam,THTTPService);

  if m = NIL then exit;

  if msg.LParamHi <> 0 then begin
    // error occured
    getDown;
    exit;
  end;

  case msg.LParamLo of
    FD_CONNECT : begin
      if m.Seq > 0 then raise Exception.Create('Invalid FD_CONNECT event');

      inc(m.Seq);

      host := getParam('host','');
      path := getParam('path','/');

      // Mozilla/4.0 (compatible; MSIE 5.01; Windows 95)

      req := 'GET '+path+' HTTP/1.1'#10+
             'Host: '+host+#10+
             'User-Agent: Mozilla/5.0 (Melchior)'#10+
             'Connection: close'+#10#10;

      send(m.Socket,req[1],length(req),0);
      inc(BytesSent,TotalTCPOverhead+length(req));
    end;
    FD_READ : begin
      if m.Seq = 0 then raise Exception.Create('FD_READ before FD_CONNECT');

      buflen := httpBufferSize;
      SetLength(bufstr,buflen);
      buflen := recv(m.Socket,bufstr[1],buflen,0);

      if buflen = SOCKET_ERROR then begin
        // error reading data

        getDown;
        exit;
      end;

      inc(BytesReceived,TotalTCPOverhead+buflen);

      if m.Seq = 1 then begin
        if buflen > httpMinBufLength then begin
          inc(m.Seq);
          SetLength(bufstr,12);

          if bufstr <> 'HTTP/1.1 200' then begin
            // response error
            
            getDown;
          end;
        end else raise Exception.Create('HTTP response didn''t satisfy');
      end;
    end;
    FD_CLOSE : begin
      if m.Seq < 2 then raise Exception.Create('FD_CLOSE before FD_READ');

      GetUp;
    end;
  end; {case}

end;

begin
  RegisterService('HTTP',THTTPService);
end.

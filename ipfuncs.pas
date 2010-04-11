{
IP functions
}
unit ipfuncs;

interface

uses

  SysUtils, Messages, Windows, WinSock;

const

  IPHeaderSize   = 20;
  TCPHeaderSize  = 24;
  ICMPHeaderSize = 8;

  TotalTCPOverhead = TCPHeaderSize + IPHeaderSize;
  ICMPOverhead = IPHeaderSize + ICMPHeaderSize;

  RequiredWinSock = $101;

  ReqDataSize = 32;

  ICMP_ECHOREPLY = 0;
  ICMP_ECHOREQ = 8;

  CM_TCP   = WM_USER + 1500;
  CM_ICMP  = WM_USER + 1501;
  CM_HTTP  = WM_USER + 1502;
  
  CM_TRAY  = WM_USER + 1600;

  icmpSeq : word = 1;

  IcmpRequestData : PChar = 'abcdefghijklmnopqrstuvwabcdefghi';

  IPHelperAvailable : boolean = false;

  MAXLEN_PHYSADDR = 8;

type

  TIPHeader = packed record
    VIHL : byte;
    TOS : byte;
    TotLen : word;
    ID : word;
    FlagOff : word;
    TTL : byte;
    Protocol : byte;
    Checksum : word;
    iaSrc : TInAddr;
    iaDst : TInAddr;
  end;

  TICMPHeader = packed record
    Type_ : byte;
    Code : byte;
    Checksum : word;
    ID : word;
    Seq : word;
//    Data : char;
  end;

  TEchoRequest = packed record
    icmpHdr : TICMPHeader;
    dwTime : longword;
    cData : array[0..ReqDataSize-1] of char;
  end;

  TEchoReply = packed record
    ipHdr : TIPHeader;
    echoRequest : TEchoRequest;
    cFiller : array[0..255] of char;
  end;

  PIPOptionInformation = ^TIPOptionInformation;
  TIPOptionInformation = packed record
    TTL : byte;
    TOS: byte;
    Flags : byte;
    OptionsSize : byte;
    OptionsData : PByteArray;
  end;

  MIB_IPNETROW = packed record
    dwIndex : DWORD;
    dwPhysAddrLen : DWORD;
    bPhysAddr : array[0..MAXLEN_PHYSADDR-1] of byte;
    dwAddr : DWORD;
    dwType : DWORD;
  end;

  PMIB_IPNETTABLE = ^MIB_IPNETTABLE;
  MIB_IPNETTABLE = packed record
    dwNumEntries : DWORD;
    table : array[0..0] of MIB_IPNETROW;
  end;

var

  JunkBuffer : array[0..4096] of byte;

procedure InitWinsock;
function in_cksum(addr:PWordArray; len:integer):word;
procedure KillSocket(s:TSocket);

function InternetGetConnectedState(out dwFlags:DWORD; dwReserved:DWORD):boolean;stdcall;

function LookupName(name:string):integer;
function IpToStr(ip:integer):string;

function GetIPMacAddress(ip:DWORD):string;

function GetIpNetTable(pIpNetTable:PMIB_IPNETTABLE;pdwSize:PULONG;bOrder:boolean):DWORD;stdcall;

implementation

function GetIPMacAddress;
var
  n:integer;
  buf:PMIB_IPNETTABLE;
  P:^MIB_IPNETROW;
  res,bufsize:DWORD;
begin
  Result := '';
  bufsize := 65536;
  GetMem(buf,bufsize);

  res := GetIpNetTable(buf,@bufsize,false);
  if res = ERROR_INSUFFICIENT_BUFFER then begin
    ReallocMem(buf,bufsize);
    res := GetIpNetTable(buf,@bufsize,false);
  end;
  if res <> NO_ERROR then begin
    Result := '';
    FreeMem(buf);
    exit;
  end;

  P := @buf.table;
  for n:=1 to buf.dwNumEntries do begin
    if P.dwAddr = ip then begin
      for res := 1 to P.dwPhysAddrLen do begin
        Result := Result + IntToHex(P.bPhysAddr[res],2);
        if res < P.dwPhysAddrLen then Result := Result + '-';
      end;
      break;
    end;
  end;

  FreeMem(buf);
end;

const

  iphlpapi = 'iphlpapi.dll';

function GetIpNetTable(pIpNetTable:PMIB_IPNETTABLE;pdwSize:PULONG;bOrder:boolean):DWORD;external iphlpapi;

function IpToStr;
begin
  Result := StrPas(inet_ntoa(in_addr(ip)));
end;

function LookupName;
var
  P:PHostEnt;
  Pc:PChar;
begin
  Pc := PChar(name);
  Result := inet_addr(Pc);
  if Result <> INADDR_NONE then exit;

  P := gethostbyname(Pc);
  if P <> NIL then Result := PInteger(P^.h_addr^)^;
end;

procedure KillSocket;
begin
  closesocket(s);
end;

const

  wininet = 'wininet.dll';

function InternetGetConnectedState(out dwFlags:DWORD; dwReserved:DWORD):boolean;
  external wininet;

function in_cksum(addr:PWordArray; len:integer):word;
var
  nleft:integer;
  w:PWordArray;
  sum:integer;
begin
  w := addr;
  sum := 0;

  nleft := len;
  while nleft > 1 do begin
    inc(sum,PWord(w)^);
    inc(integer(w),2);
    dec(nleft,2);
  end;

  if nleft = 1 then inc(sum,PByte(w)^);

  sum := (sum shr 16) + (sum and $ffff);
  inc(sum,(sum shr 16));

  Result := not sum;
end;

procedure InitWinsock;
var
  wsa:TWSAData;
begin
  if WSAStartup(RequiredWinSock,wsa) = SOCKET_ERROR then
    RaiseLastOSError;
end;

end.
 
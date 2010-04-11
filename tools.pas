{
misc functions
}

unit tools;

interface

uses

  MSXML2_TLB,

  Forms;

const

  appVer = '1.00 beta 6';

  ConfigurationFileName = 'Melchior.xml';

  DefaultInterval = 5000;
  DefaultTimeout = 4000;
  DefaultRefreshInterval = 1000;
  
  MonitoringInterval : longword = DefaultInterval;
  MonitoringTimeout : longword = DefaultTimeout;
  ListRefreshInterval : longword = 1000;

  ShowLatency         : boolean = false;
  ShowInterpolated    : boolean = true;
  MinimizeToTray      : boolean = true;
  PromptOnExit        : boolean = true;
  StartMinimized      : boolean = false;
  AutoStartMonitoring : boolean = false;

  IsOnline : boolean = false;

  RefreshNeeded : boolean = false;

  DumpXml : boolean = false;
  DumpXmlFileName : string = 'updown.xml';
  DumpXmlInterval : integer = 1;

  regPath = 'Software\Melchior';
  iniFilename = 'Melchior.ini';
  iniSection = 'Melchior';

function getCfgStr(const key,default:string):string;
procedure putCfgStr(const key:string; value:string);

function getCfgInt(const key:string; default:integer):integer;
procedure putCfgInt(const key:string; value:integer);

function getCfgBool(const key:string; default:boolean):boolean;
procedure putCfgBool(const key:string; value:boolean);

procedure CloseReg;

procedure readFormState(form:TForm);
procedure saveFormState(form:TForm);

function GetAtt(elem:IXMLDOMElement; const attname:string):string;

function xmlencode(s:string):string;

implementation

uses

  SysUtils, Variants, IniFiles;

function xmlencode;
begin
  Result := StringReplace(StringReplace(s,'&','&amp;',[rfReplaceAll]),'"','&quot;',[rfReplaceAll]);
end;

function GetAtt(elem:IXMLDOMElement; const attname:string):string;
var
  olev:OleVariant;
begin
  olev := elem.getAttribute(attname);
  if VarType(olev) <> varNull then Result := olev else Result := '';
end;

procedure saveFormState;
var
  s:string;
begin
  with form do begin
    s := Name+'_';
    putCfgBool(s+'Maximized',WindowState=wsMaximized);
    putCfgInt(s+'Left',Left);
    putCfgInt(s+'Top',Top);
    putCfgInt(s+'Width',Width);
    putCfgInt(s+'Height',Height);
  end;
end;

procedure readFormState;
var
  s:string;
begin
  with form do begin
    s := Name+'_';
    Left := getCfgInt(s+'Left',Left);
    Top := getCfgInt(s+'Top',Top);
    Width := getCfgInt(s+'Width',Width);
    Height := getCfgInt(s+'Height',Height);
    if getCfgBool(s+'Maximized',false) then WindowState := wsMaximized;

    if Left > Screen.WorkAreaWidth then Left := 0;
    if Top > Screen.WorkAreaHeight then Top := 0;
  end;
end;

function OpenReg:TIniFile;
var
  curdir:string;
begin
  GetDir(0,curdir);
  Result := TIniFile.Create(curdir+'\'+iniFilename);
end;

var
  reg:TIniFile;

procedure CloseReg;
begin
  reg.Free;
end;

procedure putCfgStr;
begin
  reg.WriteString(iniSection, key,value);
end;

function getCfgStr;
begin
  Result := reg.ReadString(iniSection, key, default);
end;

procedure putCfgInt;
begin
  reg.WriteInteger(iniSection, key,value);
end;

function getCfgInt;
begin
  Result := reg.ReadInteger(iniSection, key, default);
end;

procedure putCfgBool;
begin
  reg.WriteBool(iniSection, key,value);
end;

function getCfgBool;
begin
  Result := reg.ReadBool(iniSection, key, default);
end;

initialization
begin
  reg := OpenReg;
end;

finalization
begin
  CloseReg;
end;

end.


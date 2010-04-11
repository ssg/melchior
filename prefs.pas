unit prefs;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls;

type
  TPrefsFrm = class(TForm)
    pcPrefs: TPageControl;
    bOk: TButton;
    bCancel: TButton;
    TabSheet1: TTabSheet;
    Label1: TLabel;
    UpDown1: TUpDown;
    eInterval: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    UpDown2: TUpDown;
    eTimeout: TEdit;
    Label4: TLabel;
    TabSheet3: TTabSheet;
    GroupBox1: TGroupBox;
    cbShowLatency: TCheckBox;
    cbInterpolate: TCheckBox;
    cbSysTray: TCheckBox;
    cbPromptOnExit: TCheckBox;
    cbStartMinimized: TCheckBox;
    cbAutoStartMonitoring: TCheckBox;
    TabSheet2: TTabSheet;
    pDump: TPanel;
    cbDumpXml: TCheckBox;
    Label5: TLabel;
    eDumpXmlFilename: TEdit;
    bXmlFileLookup: TButton;
    sdXml: TSaveDialog;
    Label6: TLabel;
    udInterval: TUpDown;
    eDumpInterval: TEdit;
    procedure FormShow(Sender: TObject);
    procedure bOkClick(Sender: TObject);
    procedure bXmlFileLookupClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbDumpXmlClick(Sender: TObject);
  public
    procedure ReadConfig;
    procedure ApplyConfig;   
  end;

var
  PrefsFrm: TPrefsFrm;

implementation

uses

  mainfrm, tools;

{$R *.dfm}

procedure TPrefsFrm.FormShow(Sender: TObject);
begin
  ReadConfig;
end;

procedure TPrefsFrm.ReadConfig;
begin
  cbSysTray.Checked := MinimizeToTray;
  cbShowLatency.Checked := ShowLatency;
  cbInterpolate.Checked := ShowInterpolated;
  cbPromptOnExit.Checked := PromptOnExit;
  cbStartMinimized.Checked := StartMinimized;
  cbAutoStartMonitoring.Checked := AutoStartMonitoring;

  eInterval.Text := IntToStr(MonitoringInterval div 1000);
  eTimeout.Text := IntToStr(MonitoringTimeout div 1000);

  cbDumpXml.Checked := DumpXml;
  pDump.Enabled := cbDumpXml.Checked;  
  eDumpXmlFilename.Text := DumpXmlFilename;
  udInterval.Position := DumpXmlInterval;
//  eDumpInterval.Text := IntToStr(DumpXmlInterval);
end;

procedure TPrefsFrm.bOkClick(Sender: TObject);
begin
  ApplyConfig;
  ModalResult := mrOK;
end;

procedure TPrefsFrm.ApplyConfig;
begin
  MinimizeToTray := cbSysTray.Checked;
  ShowLatency := cbShowLatency.Checked;
  ShowInterpolated := cbInterpolate.Checked;
  PromptOnExit := cbPromptOnExit.Checked;
  StartMinimized := cbStartMinimized.Checked;
  AutoStartMonitoring := cbAutoStartMonitoring.Checked;

  MonitoringInterval := StrToIntDef(eInterval.Text,0)*1000;
  MonitoringTimeout := StrToIntDef(eTimeout.Text,0)*1000;

  if MonitoringInterval < 1000 then MonitoringInterval := DefaultInterval;
  if MonitoringTimeout < 1000 then MonitoringTimeout := DefaultTimeout;

  Main.RefreshList;

  // timer stuff

  DumpXml := cbDumpXml.Checked;
  DumpXmlFilename := eDumpXmlFilename.Text;
  DumpXmlInterval := udInterval.Position;
  Main.dumpTimer.Interval := DumpXmlInterval;
  Main.dumpTimer.Enabled := DumpXml;
end;

procedure TPrefsFrm.bXmlFileLookupClick(Sender: TObject);
begin
  if sdXml.Execute then begin
    eDumpXmlFilename.Text := sdXml.FileName;
  end;
end;

procedure TPrefsFrm.FormCreate(Sender: TObject);
begin
  pcPrefs.ActivePageIndex := 0;
end;

procedure TPrefsFrm.cbDumpXmlClick(Sender: TObject);
begin
  pDump.Enabled := cbDumpXml.Checked;
end;

end.

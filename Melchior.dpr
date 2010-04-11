program Melchior;

uses
  Forms,
  mainfrm in 'mainfrm.pas' {Main},
  servers in 'servers.pas',
  ipfuncs in 'ipfuncs.pas',
  prefs in 'prefs.pas' {PrefsFrm},
  tools in 'tools.pas',
  serverfrm in 'serverfrm.pas' {ServerForm},
  servicefrm in 'servicefrm.pas' {ServiceForm},
  serviceeditfrm in 'serviceeditfrm.pas' {ServiceEditForm},
  explorefrm in 'explorefrm.pas' {ExploreForm},
  svcicmp in 'svcicmp.pas',
  svctcp in 'svctcp.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Melchior';
  Application.CreateForm(TMain, Main);
  Application.Run;
end.

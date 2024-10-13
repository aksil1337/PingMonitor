program PingMonitor;

uses
  Windows, Forms,
  Main in 'Main.pas' {MainForm},
  Auxiliary in 'Auxiliary.pas' {AuxiliaryForm},
  Ping in 'Ping.pas',
  Settings in 'Settings.pas';

{$R *.res}
{$R Icon.res}

begin
  Application.Initialize;
  Application.Title := 'PingMonitor';
  Application.Icon.Handle := LoadIcon(hInstance, 'BASEICON');
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAuxiliaryForm, AuxiliaryForm);
  Application.Run;
end.

program PingMonitor;

uses
  Windows, Forms,
  Main in 'Main.pas' {MainForm},
  Ping in 'Ping.pas';

{$R *.res}
{$R Icon.res}

begin
  Application.Initialize;
  Application.Title := 'PingMonitor';
  Application.Icon.Handle := LoadIcon(hInstance, 'BASEICON');
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

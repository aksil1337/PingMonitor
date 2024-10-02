program PingMonitor;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  Ping in 'Ping.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'PingMonitor';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

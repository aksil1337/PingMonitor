program PingMonitor;

uses
  Windows,
  Forms,
  SysUtils,
  Main in 'Main.pas' {MainForm},
  Auxiliary in 'Auxiliary.pas' {AuxiliaryForm},
  Ping in 'Ping.pas',
  Settings in 'Settings.pas',
  Tray in 'Tray.pas';

{$R *.res}
{$R Icon.res}

const
  Warning = 'The application is already open. ' + #13 +
            'To launch another instance, use a differently named executable file.';

var
  Mutex: THandle;

begin
  Application.Initialize;
  Application.Title := 'PingMonitor';
  Application.Icon.Handle := LoadIcon(hInstance, 'BASEICON');

  Mutex := CreateMutex(nil, False, PChar(ExtractFileName(GetCommandLine)));

  if (GetLastError = ERROR_ALREADY_EXISTS) or (Mutex = 0) then
  begin
    MessageBox(Application.Handle, Warning, 'PingMonitor', MB_OK or MB_ICONWARNING);
    Halt;
  end;

  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAuxiliaryForm, AuxiliaryForm);
  Application.Run;
end.

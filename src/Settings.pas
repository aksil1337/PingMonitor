unit Settings;

interface

uses
  Classes, Windows, Forms, SysUtils, Graphics, Registry, Inifiles, Ping;

type
  TQualitySection = packed record
    ExcellentColor: TColor;
    GoodColor: TColor;
    FairColor: TColor;
    PoorColor: TColor;
    BadColor: TColor;
    TerribleColor: TColor;
    ErrorColor: TColor;
  end;

  TPingSection = packed record
    HostName: String;
    Timeout: Word;
    RefreshInterval: Word;
    PollingInterval: Word;
  end;

  TApplicationSection = packed record
    RunInTray: Boolean;
    RunAtStartup: Boolean;
  end;

  TWindowSection = packed record
    Left: Word;
    Top: Word;
  end;

  TDetailsSection = packed record
    DisplayLog: Boolean;
  end;

  TConfig = packed record
    Quality: TQualitySection;
    Ping: TPingSection;
    Application: TApplicationSection;
    Window: TWindowSection;
    Details: TDetailsSection;
  end;

  TSettings = class
  private
    Registry: TRegistry;
    ReadIni: TMemIniFile;
    WriteIni: TIniFile;
    procedure LoadWord(const Section, Ident: String; var Variable: Word);
    procedure SaveWord(const Section, Ident: String; var Variable: Word; Value: Word);
    procedure LoadColor(const Section, Ident: String; var Variable: TColor);
    procedure LoadString(const Section, Ident: String; var Variable: String);
    procedure LoadBoolean(const Section, Ident: String; var Variable: Boolean);
    procedure SaveBoolean(const Section, Ident: String; var Variable: Boolean; Value: Boolean);
    function ColorToHex(Color: TColor): String;
    function HexToColor(Hex: String): TColor;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SaveWindowLocation(Left, Top: Word);
    procedure SaveDisplayPreferences(DisplayLog: Boolean);
    procedure SaveTrayPreferences(RunInTray: Boolean);
    function SaveStartupPreferences(RunAtStartup: Boolean): Boolean;
    function GetPingColor(PingReply: TPingReply; PingTime: TPingTime = ptMedian): TColor;
    function GetCellWidth(PingReply: TPingReply): Byte;
  end;

const
  StartupRegistryKey = 'Software\Microsoft\Windows\CurrentVersion\Run';

  ExcellentPing = 0;
  GoodPing      = 20;
  FairPing      = 50;
  PoorPing      = 100;
  BadPing       = 200;
  TerriblePing  = 1000;

  DefaultConfig: TConfig = (
    Quality: (
      ExcellentColor: TColor($28F8A8);
      GoodColor:      TColor($F8F8F8);
      FairColor:      TColor($18D8F8);
      PoorColor:      TColor($1898F8);
      BadColor:       TColor($1868F8);
      TerribleColor:  TColor($1818E8);
      ErrorColor:     TColor($0808A8);
    );
    Ping: (
      HostName: 'dns.google';
      Timeout: 4000;
      RefreshInterval: 1000;
      PollingInterval: 250;
    );
    Application: (
      RunInTray: True;
      RunAtStartup: False;
    );
    Details: (
      DisplayLog: True;
    );
  );

implementation

uses
  Main, Auxiliary;

{ Structors }

constructor TSettings.Create;
var
  IniPath: String;
begin
  Config := DefaultConfig;
  Config.Window.Left := Trunc(Screen.Width / 2 - MainForm.Width / 2);
  Config.Window.Top := Trunc(Screen.Height / 2 - MainForm.Height / 2);

  Registry := TRegistry.Create;
  Registry.RootKey := HKEY_CURRENT_USER;

  IniPath := ChangeFileExt(Application.ExeName, '.ini');

  ReadIni := TMemIniFile.Create(IniPath);
  WriteIni := TIniFile.Create(IniPath);
  TStringList.Create.SaveToFile(IniPath);

  LoadColor('Quality', 'ExcellentColor', Config.Quality.ExcellentColor);
  LoadColor('Quality', 'GoodColor', Config.Quality.GoodColor);
  LoadColor('Quality', 'FairColor', Config.Quality.FairColor);
  LoadColor('Quality', 'PoorColor', Config.Quality.PoorColor);
  LoadColor('Quality', 'BadColor', Config.Quality.BadColor);
  LoadColor('Quality', 'TerribleColor', Config.Quality.TerribleColor);
  LoadColor('Quality', 'ErrorColor', Config.Quality.ErrorColor);

  LoadString('Ping', 'HostName', Config.Ping.HostName);
  LoadWord('Ping', 'Timeout', Config.Ping.Timeout);
  LoadWord('Ping', 'RefreshInterval', Config.Ping.RefreshInterval);
  LoadWord('Ping', 'PollingInterval', Config.Ping.PollingInterval);

  LoadBoolean('Application', 'RunInTray', Config.Application.RunInTray);
  LoadBoolean('Application', 'RunAtStartup', Config.Application.RunAtStartup);

  LoadWord('Window', 'Left', Config.Window.Left);
  LoadWord('Window', 'Top', Config.Window.Top);

  LoadBoolean('Details', 'DisplayLog', Config.Details.DisplayLog);

  SaveStartupPreferences(Config.Application.RunAtStartup);

  ReadIni.Free;
end;

destructor TSettings.Destroy;
begin
  WriteIni.Free;
  Registry.Free;
end;

{ Methods }

procedure TSettings.LoadWord(const Section, Ident: String; var Variable: Word);
begin
  Variable := ReadIni.ReadInteger(Section, Ident, Variable);
  WriteIni.WriteInteger(Section, Ident, Variable);
end;

procedure TSettings.SaveWord(const Section, Ident: String; var Variable: Word; Value: Word);
begin
  Variable := Value;
  WriteIni.WriteInteger(Section, Ident, Variable);
end;

procedure TSettings.LoadColor(const Section, Ident: String; var Variable: TColor);
var
  Default: TColor;
begin
  Default := Variable;

  try
    Variable := HexToColor(ReadIni.ReadString(Section, Ident, ColorToHex(Variable)));
  except
    Variable := Default;
  end;

  WriteIni.WriteString(Section, Ident, ColorToHex(Variable));
end;

procedure TSettings.LoadString(const Section, Ident: String; var Variable: String);
var
  Default: String;
begin
  Default := Variable;
  Variable := ReadIni.ReadString(Section, Ident, Variable);

  if (Variable = '') then
    Variable := Default;

  WriteIni.WriteString(Section, Ident, Variable);
end;

procedure TSettings.LoadBoolean(const Section, Ident: String; var Variable: Boolean);
begin
  Variable := ReadIni.ReadBool(Section, Ident, Variable);
  WriteIni.WriteBool(Section, Ident, Variable);
end;

procedure TSettings.SaveBoolean(const Section, Ident: String; var Variable: Boolean; Value: Boolean);
begin
  Variable := Value;
  WriteIni.WriteBool(Section, Ident, Variable);
end;

function TSettings.ColorToHex(Color: TColor): String;
begin
  Result := '#' + IntToHex(GetRValue(Color), 2)
                + IntToHex(GetGValue(Color), 2)
                + IntToHex(GetBValue(Color), 2);
end;

function TSettings.HexToColor(Hex: String): TColor;
begin
  Result := RGB(StrToInt('$' + Copy(Hex, 2, 2)),
                StrToInt('$' + Copy(Hex, 4, 2)),
                StrToInt('$' + Copy(Hex, 6, 2)));
end;

procedure TSettings.SaveWindowLocation(Left, Top: Word);
begin
  SaveWord('Window', 'Left', Config.Window.Left, Left);
  SaveWord('Window', 'Top', Config.Window.Top, Top);
end;

procedure TSettings.SaveDisplayPreferences(DisplayLog: Boolean);
begin
  SaveBoolean('Details', 'DisplayLog', Config.Details.DisplayLog, DisplayLog);
end;

procedure TSettings.SaveTrayPreferences(RunInTray: Boolean);
begin
  SaveBoolean('Application', 'RunInTray', Config.Application.RunInTray, RunInTray);
end;

function TSettings.SaveStartupPreferences(RunAtStartup: Boolean): Boolean;
var
  ApplicationPath: String;

  function RegistryRunAtStartup: Boolean;
  begin
    Result := (Registry.ReadString(Application.Title) = ApplicationPath);
  end;
begin
  ApplicationPath := Format('"%s"', [Application.ExeName]);

  if Registry.OpenKey(StartupRegistryKey, False) then
  begin
    Result := RegistryRunAtStartup;

    if (Result <> RunAtStartup) then
    begin
      if (RunAtStartup) then
        Registry.WriteString(Application.Title, ApplicationPath)
      else
        Registry.DeleteValue(Application.Title);

      Result := RegistryRunAtStartup;
    end;

    Registry.CloseKey;
  end
  else
    Result := False;

  if (Config.Application.RunAtStartup <> Result) then
    SaveBoolean('Application', 'RunAtStartup', Config.Application.RunAtStartup, Result);
end;

function TSettings.GetPingColor(PingReply: TPingReply; PingTime: TPingTime): TColor;
var
  Time: Word;
begin
  case (PingTime) of
    ptMin: Time := PingReply.Min;
    ptMax: Time := PingReply.Max;
    else   Time := PingReply.Time;
  end;

  if (PingReply.Failure) then
    Result := Config.Quality.ErrorColor
  else
    case (Time) of
      ExcellentPing..GoodPing-1: Result := Config.Quality.ExcellentColor;
      GoodPing..FairPing-1:      Result := Config.Quality.GoodColor;
      FairPing..PoorPing-1:      Result := Config.Quality.FairColor;
      PoorPing..BadPing-1:       Result := Config.Quality.PoorColor;
      BadPing..TerriblePing-1:   Result := Config.Quality.BadColor;
      else                       Result := Config.Quality.TerribleColor;
    end;
end;

function TSettings.GetCellWidth(PingReply: TPingReply): Byte;
begin
  if (PingReply.Failure) then
    Result := 7
  else if (PingReply.Result <> '') then
    case (PingReply.Time) of
      ExcellentPing..GoodPing-1: Result := 2;
      GoodPing..FairPing-1:      Result := 3;
      FairPing..PoorPing-1:      Result := 4;
      PoorPing..BadPing-1:       Result := 5;
      BadPing..TerriblePing-1:   Result := 6;
      else                       Result := 7;
    end
  else
    Result := 0;
end;

end.

unit Settings;

interface

uses
  Classes, Windows, Forms, SysUtils, Graphics, Inifiles, Ping;

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

  TWindowSection = packed record
    Left: Word;
    Top: Word;
  end;

  TConfig = packed record
    Quality: TQualitySection;
    Ping: TPingSection;
    Window: TWindowSection;
  end;

  TSettings = class
  private
    ReadIni: TMemIniFile;
    WriteIni: TIniFile;
    procedure LoadWord(const Section, Ident: String; var Variable: Word);
    procedure LoadColor(const Section, Ident: String; var Variable: TColor);
    procedure LoadString(const Section, Ident: String; var Variable: String);
    procedure SaveWord(const Section, Ident: String; var Variable: Word; Value: Word);
    function ColorToHex(Color: TColor): String;
    function HexToColor(Hex: String): TColor;
  public
    constructor Create(const FileName: String);
    destructor Destroy; override;
    procedure SaveWindowLocation(Left, Top: Word);
    function GetPingColor(PingReply: TPingReply): TColor;
    function GetPingWidth(PingReply: TPingReply): Byte;
  end;

const
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
  );

var
  Config: TConfig;

implementation

uses
  Main;

{ Structors }

constructor TSettings.Create(const FileName: String);
begin
  Config := DefaultConfig;
  Config.Window.Left := Trunc(Screen.Width / 2 - MainForm.Width / 2);
  Config.Window.Top := Trunc(Screen.Height / 2 - MainForm.Height / 2);

  ReadIni := TMemIniFile.Create(FileName);
  WriteIni := TIniFile.Create(FileName);
  TStringList.Create.SaveToFile(FileName);

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

  LoadWord('Window', 'Left', Config.Window.Left);
  LoadWord('Window', 'Top', Config.Window.Top);

  ReadIni.Free;
end;

destructor TSettings.Destroy;
begin
  WriteIni.Free;
end;

{ Methods }

procedure TSettings.LoadWord(const Section, Ident: String; var Variable: Word);
begin
  Variable := ReadIni.ReadInteger(Section, Ident, Variable);
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

procedure TSettings.SaveWord(const Section, Ident: String; var Variable: Word; Value: Word);
begin
  Variable := Value;
  WriteIni.WriteInteger(Section, Ident, Variable);
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

function TSettings.GetPingColor(PingReply: TPingReply): TColor;
begin
  if (PingReply.Failure) then
    Result := Config.Quality.ErrorColor
  else
    case (PingReply.Time) of
      ExcellentPing..GoodPing-1: Result := Config.Quality.ExcellentColor;
      GoodPing..FairPing-1:      Result := Config.Quality.GoodColor;
      FairPing..PoorPing-1:      Result := Config.Quality.FairColor;
      PoorPing..BadPing-1:       Result := Config.Quality.PoorColor;
      BadPing..TerriblePing-1:   Result := Config.Quality.BadColor;
      else                       Result := Config.Quality.TerribleColor;
    end;
end;

function TSettings.GetPingWidth(PingReply: TPingReply): Byte;
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

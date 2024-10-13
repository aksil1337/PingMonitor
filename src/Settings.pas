unit Settings;

interface

uses
  Classes, Windows, SysUtils, Graphics, Inifiles, Ping;

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

  TConfig = packed record
    Quality: TQualitySection;
    Ping: TPingSection;
  end;

  TSettings = class
  private
    ReadIni: TMemIniFile;
    WriteIni: TIniFile;
    procedure IniWord(const Section: String; const Ident: String; var Value: Word);
    procedure IniColor(const Section: String; const Ident: String; var Value: TColor);
    procedure IniString(const Section: String; const Ident: String; var Value: String);
    function ColorToHex(Color: TColor): String;
    function HexToColor(Hex: String): TColor;
  public
    constructor Create(const FileName: String);
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

{ Structors }

constructor TSettings.Create(const FileName: String);
begin
  Config := DefaultConfig;

  ReadIni := TMemIniFile.Create(FileName);
  WriteIni := TIniFile.Create(FileName);
  TStringList.Create.SaveToFile(FileName);

  IniColor('Quality', 'ExcellentColor', Config.Quality.ExcellentColor);
  IniColor('Quality', 'GoodColor', Config.Quality.GoodColor);
  IniColor('Quality', 'FairColor', Config.Quality.FairColor);
  IniColor('Quality', 'PoorColor', Config.Quality.PoorColor);
  IniColor('Quality', 'BadColor', Config.Quality.BadColor);
  IniColor('Quality', 'TerribleColor', Config.Quality.TerribleColor);
  IniColor('Quality', 'ErrorColor', Config.Quality.ErrorColor);

  IniString('Ping', 'HostName', Config.Ping.HostName);
  IniWord('Ping', 'Timeout', Config.Ping.Timeout);
  IniWord('Ping', 'RefreshInterval', Config.Ping.RefreshInterval);
  IniWord('Ping', 'PollingInterval', Config.Ping.PollingInterval);

  ReadIni.Free;
  WriteIni.Free;
end;

{ Methods }

procedure TSettings.IniWord(const Section: String; const Ident: String; var Value: Word);
begin
  Value := ReadIni.ReadInteger(Section, Ident, Value);
  WriteIni.WriteInteger(Section, Ident, Value);
end;

procedure TSettings.IniColor(const Section: String; const Ident: String; var Value: TColor);
var
  Default: TColor;
begin
  Default := Value;

  try
    Value := HexToColor(ReadIni.ReadString(Section, Ident, ColorToHex(Value)));
  except
    Value := Default;
  end;

  WriteIni.WriteString(Section, Ident, ColorToHex(Value));
end;

procedure TSettings.IniString(const Section: String; const Ident: String; var Value: String);
var
  Default: String;
begin
  Default := Value;
  Value := ReadIni.ReadString(Section, Ident, Value);

  if (Value = '') then
    Value := Default;

  WriteIni.WriteString(Section, Ident, Value);
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

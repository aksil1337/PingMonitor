unit Ping;

interface

uses
  Windows, SysUtils, Math, WinSock;

function IcmpCreateFile: THandle;
         stdcall; external 'iphlpapi.dll';
function IcmpCloseHandle(IcmpHandle: THandle): Boolean;
         stdcall; external 'iphlpapi.dll';
function IcmpSendEcho(IcmpHandle: THandle; DestinationAddress: TInAddr;
                      RequestData: Pointer; RequestSize: Word;
                      RequestOptions: Pointer; ReplyBuffer: Pointer;
                      ReplySize: Cardinal; Timeout: Cardinal): Cardinal;
         stdcall; external 'iphlpapi.dll';

type
  TIpOptionInformation = packed record
    TTL: Byte;
    TOS: Byte;
    Flags: Byte;
    OptionsSize: Byte;
    OptionsData: PChar;
  end;

  TIcmpEchoRequest = packed record
    Address: PInAddr;
    Data: String;
    DataSize: Word;
  end;

  PIcmpEchoReply = ^TIcmpEchoReply;
  TIcmpEchoReply = packed record
    Address: TInAddr;
    Status: Cardinal;
    RoundTripTime: Cardinal;
    DataSize: Word;
    Reserved: Word;
    Data: Pointer;
    Options: TIpOptionInformation;
  end;

  TPingReply = packed record
    Failure: Boolean;
    Result: String;
    Time: Word;
    Min: Word;
    Max: Word;
  end;

  TPing = class
  private
    HostName: String;
    Timeout: Cardinal;
    WSAData: TWSAData;
    PingReplies: Array of TPingReply;
    function GetHostAddress: PInAddr;
    function Send: TPingReply;
  public
    Initialized: Boolean;
    constructor Create(const HostName: String; Timeout: Cardinal);
    destructor Destroy; override;
    function Determine: TPingReply;
  end;

implementation

uses
  Settings;

{ Structors }

constructor TPing.Create(const HostName: String; Timeout: Cardinal);
var
  WSAError: Integer;
begin
  Self.HostName := HostName;
  Self.Timeout := Timeout;

  SetLength(PingReplies, Ceil(Config.Ping.RefreshInterval / Config.Ping.PollingInterval));

  WSAError := WSAStartup(MakeWord(2, 2), WSAData);
  Initialized := (WSAError = 0);
end;

destructor TPing.Destroy;
begin
  if (Initialized) then
    WSACleanup;
end;

{ Methods }

function TPing.GetHostAddress: PInAddr;
var
  HostEntity: PHostEnt;
begin
  HostEntity := GetHostByName(PChar(HostName));

  if (Assigned(HostEntity)) and (HostEntity.H_AddrType = AF_INET) then
    Result := PInAddr(HostEntity.H_Addr^)
  else
    Result := nil;
end;

function TPing.Send: TPingReply;
var
  IcmpHandle: THandle;
  EchoRequest: TIcmpEchoRequest;
  EchoReply: PIcmpEchoReply;
  EchoReplySize: Cardinal;
  PingReply: TPingReply;
begin
  PingReply.Failure := True;
  PingReply.Time := 0;

  IcmpHandle := IcmpCreateFile;

  if (IcmpHandle = INVALID_HANDLE_VALUE) then
    PingReply.Result := 'Invalid ICMP handle'
  else
  begin
    EchoRequest.Address := GetHostAddress;
    EchoRequest.Data := IntToHex(Random(Cardinal($FFFFFFFF)), 32);
    EchoRequest.DataSize := Length(EchoRequest.Data);

    if (EchoRequest.Address = nil) then
      PingReply.Result := 'Host not found'
    else
    begin
      EchoReplySize := SizeOf(TIcmpEchoReply) + EchoRequest.DataSize;
      GetMem(EchoReply, EchoReplySize);

      IcmpSendEcho(IcmpHandle, EchoRequest.Address^, PChar(EchoRequest.Data),
                   EchoRequest.DataSize, nil, EchoReply, EchoReplySize, Timeout);

      case (EchoReply.Status) of
        0:
        begin
          PingReply.Time := EchoReply.RoundTripTime;

          PingReply.Result := Format('IP=%s Bytes=%d TTL=%d', [
            Inet_ntoa(TInAddr(EchoReply.Address)),
            EchoReply.DataSize,
            EchoReply.Options.TTL
          ]);

          PingReply.Failure := False;
        end;
        11002:
          PingReply.Result := 'Destination network unreachable';
        11010:
        begin
          PingReply.Time := Config.Ping.Timeout;
          PingReply.Result := 'Request timed out';
        end;
        else
          PingReply.Result := 'General failure: IPStatus=' + IntToStr(EchoReply.Status);
      end;

      FreeMem(EchoReply);
    end;

    IcmpCloseHandle(IcmpHandle);
  end;

  Result := PingReply;
end;

function TPing.Determine: TPingReply;
var
  PingReply: TPingReply;
  ElapsedTime: Cardinal;
  Count: Byte;
  I, J: Byte;
begin
  ElapsedTime := 0;
  Count := 0;

  while True do
  begin
    I := 0;

    PingReply := Send;

    if (PingReply.Failure) then
      Count := 0
    else if (Count < Length(PingReplies)) then
    begin
      while I < Count do
      begin
        if (PingReply.Time < PingReplies[I].Time) then
        begin
          for J := Count downto I + 1 do
            PingReplies[J] := PingReplies[J - 1];

          Break;
        end;

        Inc(I);
      end;
    end;

    PingReplies[I] := PingReply;

    Inc(Count);
    Inc(ElapsedTime, Max(PingReply.Time, Config.Ping.PollingInterval));

    if (PingReply.Time < Config.Ping.PollingInterval) then
      if (PingReply.Failure) then
        Sleep(Config.Ping.RefreshInterval)
      else
        Sleep(Config.Ping.PollingInterval - PingReply.Time);

    if (PingReply.Failure) or (ElapsedTime >= Config.Ping.RefreshInterval) then
      Break;
  end;

  Result := PingReplies[Count div 2];
  Result.Min := PingReplies[0].Time;
  Result.Max := PingReplies[Count - 1].Time;
end;

end.

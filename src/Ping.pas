unit Ping;

interface

uses
  Windows, SysUtils, WinSock;

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
    Result: String;
    Time: Cardinal;
  end;

  TPing = class
  private
    WSAData: TWSAData;
  public
    Initialized: Boolean;
    constructor Create;
    destructor Destroy; override;
    function GetHostAddress(const HostName: String): PInAddr;
    function Send(const HostName: String; Timeout: Cardinal = 4000): TPingReply;
  end;

implementation

constructor TPing.Create;
var
  WSAError: Integer;
begin
  WSAError := WSAStartup(MakeWord(2, 2), WSAData);
  Initialized := (WSAError = 0);
end;

destructor TPing.Destroy;
begin
  if (Initialized) then
    WSACleanup;
end;

function TPing.GetHostAddress(const HostName: String): PInAddr;
var
  HostEntity: PHostEnt;
begin
  HostEntity := GetHostByName(PChar(HostName));

  if (HostEntity <> nil) and (HostEntity.H_AddrType = AF_INET) then
    Result := PInAddr(HostEntity.H_Addr^)
  else
    Result := nil;
end;

function TPing.Send(const HostName: String; Timeout: Cardinal): TPingReply;
var
  IcmpHandle: THandle;
  Request: TIcmpEchoRequest;
  Reply: PIcmpEchoReply;
  ReplySize: Cardinal;
  PingReply: TPingReply;
begin
  PingReply.Time := High(Cardinal);

  IcmpHandle := IcmpCreateFile;

  if (IcmpHandle = INVALID_HANDLE_VALUE) then
    PingReply.Result := 'Invalid ICMP handle'
  else
  begin
    Request.Address := GetHostAddress(HostName);
    Request.Data := IntToHex(Random(Cardinal($FFFFFFFF)), 32);
    Request.DataSize := Length(Request.Data);

    if (Request.Address = nil) then
      PingReply.Result := 'Host not found'
    else
    begin
      ReplySize := SizeOf(TIcmpEchoReply) + Request.DataSize;
      GetMem(Reply, ReplySize);

      IcmpSendEcho(IcmpHandle, Request.Address^, PChar(Request.Data),
                   Request.DataSize, nil, Reply, ReplySize, Timeout);

      case (Reply.Status) of
        0:
        begin
          PingReply.Time := Reply.RoundTripTime;

          PingReply.Result := Format('IP=%s Bytes=%d TTL=%d Time=%dms', [
            Inet_ntoa(TInAddr(Reply.Address)),
            Reply.DataSize,
            Reply.Options.TTL,
            Reply.RoundTripTime
          ]);
        end;
        11002:
          PingReply.Result := 'Destination network unreachable';
        11010:
          PingReply.Result := 'Request timed out';
        else
          PingReply.Result := 'General failure: IPStatus=' + IntToStr(Reply.Status);
      end;

      FreeMem(Reply);
    end;

    IcmpCloseHandle(IcmpHandle);
  end;

  Result := PingReply;
end;

end.

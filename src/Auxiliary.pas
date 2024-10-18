unit Auxiliary;

interface

uses
  StdCtrls, ExtCtrls, ComCtrls, Controls, Classes, Forms, SysUtils, Menus,
  Clipbrd, Ping;

type
  TAuxiliaryForm = class(TForm)
    LogPanel: TPanel;
    LogMemo: TMemo;
    PopupMenu: TPopupMenu;
    LogOption: TMenuItem;
    CopyOption: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure LogMemoEnter(Sender: TObject);
    procedure LogOptionClick(Sender: TObject);
    procedure CopyOptionClick(Sender: TObject);
  public
    procedure AppendLogEntry(PingReply: TPingReply);
  end;

var
  AuxiliaryForm: TAuxiliaryForm;
  LogEntries: TStringList;

implementation

uses
  Main;

{$R *.dfm}

{ Events }

procedure TAuxiliaryForm.FormCreate(Sender: TObject);
begin
  LogEntries := TStringList.Create;
end;

procedure TAuxiliaryForm.LogMemoEnter(Sender: TObject);
begin
  LogPanel.SetFocus;
end;

procedure TAuxiliaryForm.LogOptionClick(Sender: TObject);
begin
  MainForm.ToggleAuxiliaryForm;
end;

procedure TAuxiliaryForm.CopyOptionClick(Sender: TObject);
begin
  Clipboard.AsText := LogEntries.Text;
end;

{ Methods }

procedure TAuxiliaryForm.AppendLogEntry(PingReply: TPingReply);
var
  DateTimeNow: String;
  LogEntry: String;
begin
  DateTimeNow := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now);

  LogEntry := Format('%s %s', [DateTimeNow, PingReply.Result]);

  if not (PingReply.Failure) then
    LogEntry := Format('%s Jitter=%dms Time=%dms', [
      LogEntry,
      PingReply.Max - PingReply.Min,
      PingReply.Time
    ]);

  LogEntries.Add(LogEntry);

  if (LogEntries.Count > 20) then
    LogEntries.Delete(0);

  LogMemo.Text := LogEntries.Text;
end;

end.

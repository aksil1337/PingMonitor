unit Auxiliary;

interface

uses
  StdCtrls, ExtCtrls, ComCtrls, Controls, Classes, Forms, SysUtils, Menus,
  Clipbrd;

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
  private
    LogEntries: TStringList;
  public
    procedure AppendLogEntry(Text: String);
  end;

var
  AuxiliaryForm: TAuxiliaryForm;

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

procedure TAuxiliaryForm.AppendLogEntry(Text: String);
var
  DateTimeNow: String;
begin
  DateTimeNow := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now);

  LogEntries.Add(DateTimeNow + ' ' + Text);

  if (LogEntries.Count > 20) then
    LogEntries.Delete(0);

  LogMemo.Text := LogEntries.Text;
end;

end.

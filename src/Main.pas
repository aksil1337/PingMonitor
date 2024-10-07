unit Main;

interface

uses
  StdCtrls, ExtCtrls, Controls, Classes, Windows, Forms, Dialogs, Messages,
  SysUtils, StrUtils, Graphics, Menus, Ping;

type
  TPingThread = class(TThread)
  public
    procedure Execute; override;
  end;

  TMainForm = class(TForm)
    PingPanel: TPanel;
    PingFrame: TShape;
    PingLabel: TLabel;
    PingTimer: TTimer;
    PopupMenu: TPopupMenu;
    ExitOption: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure PingTimerTimer(Sender: TObject);
    procedure PingLabelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ExitOptionClick(Sender: TObject);
  private
    procedure SendPing;
    procedure DragMove;
    procedure FixFormLocation;
  end;

const
  Green  = TColor($B8F8D8); { #d8f8b8 }
  White  = TColor($F8F8F8); { #f8f8f8 }
  Yellow = TColor($38E8F8); { #f8e838 }
  Amber  = TColor($48B8F8); { #f8b848 }
  Orange = TColor($0888F8); { #f88808 }
  Red    = TColor($2828D8); { #d82828 }
  Ruby   = TColor($0808A8); { #a80808 }

var
  MainForm: TMainForm;
  Ping: TPing;

implementation

{$R *.dfm}

{ Events }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  MainForm.ClientHeight := 24;
  MainForm.ClientWidth := 49;

  Ping := TPing.Create('dns.google');

  if (Ping.Initialized) then
    PingTimer.Enabled := True;
end;

procedure TMainForm.PingTimerTimer(Sender: TObject);
begin
  TPingThread.Create(false);
end;

procedure TMainForm.PingLabelMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MainForm.ActiveControl := nil;

  if (Button = mbLeft) then
    DragMove;
end;

procedure TMainForm.ExitOptionClick(Sender: TObject);
begin
  Application.Terminate;
end;

{ Methods }

procedure TPingThread.Execute;
begin
  MainForm.SendPing;
end;

procedure TMainForm.SendPing;
var
  PingReply: TPingReply;
  PingColor: TColor;
begin
  PingReply := Ping.Send;

  case (PingReply.Time) of
    0..19:                  PingColor := Green;
    20..49:                 PingColor := White;
    50..99:                 PingColor := Yellow;
    100..199:               PingColor := Amber;
    200..999:               PingColor := Orange;
    1000..High(Cardinal)-1: PingColor := Red;
    else                    PingColor := Ruby;
  end;

  case (PingReply.Time) of
    High(Cardinal): PingLabel.Caption := '!';
    else            PingLabel.Caption := Format('%d', [PingReply.Time]);
  end;

  PingLabel.Font.Color := PingColor;
  PingFrame.Pen.Color := PingColor;
end;

procedure TMainForm.DragMove;
begin
  ReleaseCapture;
  Perform(WM_SYSCOMMAND, $F012, 0);

  FixFormLocation;
end;

procedure TMainForm.FixFormLocation;
begin
  if (MainForm.Left < 0) then
    MainForm.Left := 0
  else if (MainForm.Left + MainForm.Width > Screen.Width) then
    MainForm.Left := Screen.Width - MainForm.Width;

  if (MainForm.Top < 0) then
    MainForm.Top := 0
  else if (MainForm.Top + MainForm.Height > Screen.Height) then
    MainForm.Top := Screen.Height - MainForm.Height;
end;

end.

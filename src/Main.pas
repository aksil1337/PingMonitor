unit Main;

interface

uses
  StdCtrls, ExtCtrls, Controls, Classes, Windows, Forms, Dialogs, Messages,
  SysUtils, StrUtils, Graphics, Ping;

type
  TMainForm = class(TForm)
    PingPanel: TPanel;
    PingFrame: TShape;
    PingLabel: TLabel;
    PingTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure PingTimerTimer(Sender: TObject);
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

implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  MainForm.ClientHeight := 24;
  MainForm.ClientWidth := 49;
end;

procedure TMainForm.PingTimerTimer(Sender: TObject);
var
  PingReply: TPingReply;
  PingColor: TColor;
begin
  PingReply := TPing.Send('google.com');

  if (PingReply.Time > 999) then
    PingTimer.Interval := 1000
  else
    PingTimer.Interval := 1000 - PingReply.Time;

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

end.

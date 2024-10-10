unit Main;

interface

uses
  StdCtrls, ExtCtrls, Controls, Classes, Windows, Forms, Dialogs, Messages,
  SysUtils, StrUtils, Math, Graphics, Menus, Ping;

type
  TPingThread = class(TThread)
  public
    procedure Execute; override;
  end;

  TMainForm = class(TForm)
    PingPanel: TPanel;
    PingFrame: TShape;
    PingLabel: TLabel;
    PopupMenu: TPopupMenu;
    ExitOption: TMenuItem;
    InspectGrid: TPaintBox;
    procedure FormCreate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ExitOptionClick(Sender: TObject);
    procedure InspectGridPaint(Sender: TObject);
  private
    GridColors: Array[1..16] of TColor;
    procedure UpdatePing(Time: Word; Failure: Boolean);
    procedure UpdateInspectGrid(Color: TColor = clNone);
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

  PingInterval = 250;

var
  MainForm: TMainForm;
  Ping: TPing;

implementation

{$R *.dfm}

{ Events }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  MainForm.ClientHeight := 27;
  MainForm.ClientWidth := 49;

  Ping := TPing.Create('dns.google');

  if (Ping.Initialized) then
    TPingThread.Create(false);
end;

procedure TMainForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MainForm.ActiveControl := nil;

  if (Button = mbLeft) then
    DragMove;
end;

procedure TMainForm.ExitOptionClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TMainForm.InspectGridPaint(Sender: TObject);
var
  I, P, W: Byte;
begin
  P := 0;
  W := 0;

  for I := 1 to 16 do
  begin
    case (GridColors[I]) of
      Green:  W := 2;
      White:  W := 3;
      Yellow: W := 4;
      Amber:  W := 5;
      Orange: W := 6;
      Red:    W := 7;
      Ruby:   W := 7;
    end;

    InspectGrid.Canvas.Pen.Color := GridColors[I];
    InspectGrid.Canvas.Brush.Color := GridColors[I];
    InspectGrid.Canvas.Rectangle(P, 0, P + W, 2);

    P := P + W + 1;

    if (P >= InspectGrid.Width) then
    begin
      InspectGrid.Canvas.Rectangle(P - 1, 0, P + 1, 2);
      Break;
    end;
  end;
end;

{ Methods }

procedure TPingThread.Execute;
var
  PingReply: TPingReply;
  PingTotal: Cardinal;
  PingMax: Word;
begin
  while True do
  begin
    PingTotal := 0;
    PingMax := 0;

    while True do
    begin
      PingReply := Ping.Send;

      PingMax := Max(PingReply.Time, PingMax);

      Inc(PingTotal, Max(PingReply.Time, PingInterval));

      if (PingReply.Time < PingInterval) then
        Sleep(IfThen(PingReply.Failure, 1000, PingInterval - PingReply.Time));

      if (PingReply.Failure) or (PingTotal >= 1000) then
        Break;
    end;

    MainForm.UpdatePing(PingMax, PingReply.Failure);
  end;
end;

procedure TMainForm.UpdatePing(Time: Word; Failure: Boolean);
var
  Color: TColor;
begin
  case (Time) of
    0..19:    Color := IfThen(Failure, Ruby, Green);
    20..49:   Color := White;
    50..99:   Color := Yellow;
    100..199: Color := Amber;
    200..999: Color := Orange;
    else      Color := Red;
  end;

  PingLabel.Caption := IfThen(Failure, '!', Format('%d', [Time]));

  PingLabel.Font.Color := Color;
  PingFrame.Pen.Color := Color;

  UpdateInspectGrid(Color);
end;

procedure TMainForm.UpdateInspectGrid(Color: TColor);
var
  I: Byte;
begin
  if (Color <> clNone) then
  begin
    for I := 16 downto 2 do
      GridColors[I] := GridColors[I - 1];

    GridColors[1] := Color;
  end;

  InspectGrid.Invalidate;
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

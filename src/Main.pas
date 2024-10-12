unit Main;

interface

uses
  StdCtrls, ExtCtrls, Controls, Classes, Windows, Forms, Dialogs, Messages,
  SysUtils, StrUtils, Math, Graphics, Menus, Auxiliary, Ping;

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
    LogOption: TMenuItem;
    ExitOption: TMenuItem;
    InspectGrid: TPaintBox;
    procedure FormCreate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LogOptionClick(Sender: TObject);
    procedure ExitOptionClick(Sender: TObject);
    procedure InspectGridPaint(Sender: TObject);
  private
    GridColors: Array[1..16] of TColor;
    procedure UpdatePing(PingReply: TPingReply);
    procedure UpdateInspectGrid(Color: TColor = clNone);
    procedure DragMove;
    procedure FixFormLocation;
  protected
    procedure WindowPositionChanged(var Msg: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
  public
    procedure ToggleAuxiliaryForm;
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
  ClientHeight := 27;
  ClientWidth := 49;

  Ping := TPing.Create('dns.google');

  if (Ping.Initialized) then
    TPingThread.Create(false);
end;

procedure TMainForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ActiveControl := nil;

  if (Button = mbLeft) then
    DragMove;
end;

procedure TMainForm.LogOptionClick(Sender: TObject);
begin
  ToggleAuxiliaryForm;
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

{ Messages }

procedure TMainForm.WindowPositionChanged(var Msg: TWMWindowPosChanged);
begin
  inherited;

  if not (Assigned(AuxiliaryForm)) then
    Exit;

  if (Top + Height div 2 < Screen.Height div 2) then
  begin
    PingPanel.Top := 0;
    InspectGrid.Top := 24;
    AuxiliaryForm.Top := Top - 1 + Height;
  end
  else
  begin
    PingPanel.Top := 3;
    InspectGrid.Top := 1;
    AuxiliaryForm.Top := Top + 1 - AuxiliaryForm.Height;
  end;

  if (Left + Width div 2 < Screen.Width div 2) then
    AuxiliaryForm.Left := Left
  else
    AuxiliaryForm.Left := Left + Width - AuxiliaryForm.Width;
end;

{ Methods }

procedure TPingThread.Execute;
var
  PingReply: TPingReply;
  PingTotal: Cardinal;
  PingMax: TPingReply;
begin
  while True do
  begin
    PingTotal := 0;
    PingMax.Time := 0;

    while True do
    begin
      PingReply := Ping.Send;

      if (PingReply.Failure) or (PingReply.Time > PingMax.Time) then
        PingMax := PingReply;

      Inc(PingTotal, Max(PingReply.Time, PingInterval));

      if (PingReply.Time < PingInterval) then
        Sleep(IfThen(PingReply.Failure, 1000, PingInterval - PingReply.Time));

      if (PingReply.Failure) or (PingTotal >= 1000) then
        Break;
    end;

    MainForm.UpdatePing(PingMax);
  end;
end;

procedure TMainForm.UpdatePing(PingReply: TPingReply);
var
  Color: TColor;
begin
  case (PingReply.Time) of
    0..19:    Color := IfThen(PingReply.Failure, Ruby, Green);
    20..49:   Color := White;
    50..99:   Color := Yellow;
    100..199: Color := Amber;
    200..999: Color := Orange;
    else      Color := Red;
  end;

  PingLabel.Caption := IfThen(PingReply.Failure, '!', Format('%d', [PingReply.Time]));

  PingLabel.Font.Color := Color;
  PingFrame.Pen.Color := Color;

  AuxiliaryForm.AppendLogEntry(PingReply.Result);

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
  if (Left < 0) then
    Left := 0
  else if (Left + Width > Screen.Width) then
    Left := Screen.Width - Width;

  if (Top < 0) then
    Top := 0
  else if (Top + Height > Screen.Height) then
    Top := Screen.Height - Height;
end;

procedure TMainForm.ToggleAuxiliaryForm;
begin
  AuxiliaryForm.Visible := not AuxiliaryForm.Visible;
  MainForm.BringToFront;

  AuxiliaryForm.LogOption.Checked := AuxiliaryForm.Visible;
  LogOption.Checked := AuxiliaryForm.Visible;
end;

end.

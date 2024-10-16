unit Main;

interface

uses
  StdCtrls, ExtCtrls, Controls, Classes, Windows, Forms, Dialogs, Messages,
  SysUtils, StrUtils, Math, Graphics, Menus, Auxiliary, Ping, Settings;

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
    PingReplies: Array[1..16] of TPingReply;
    procedure UpdatePing(PingReply: TPingReply);
    procedure UpdateInspectGrid(PingReply: TPingReply);
    procedure DragMove;
    procedure AdjustAndSaveWindowLocation;
  protected
    procedure WindowPositionChanged(var Msg: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
  public
    procedure ToggleAuxiliaryForm;
  end;

var
  MainForm: TMainForm;
  Ping: TPing;
  Settings: TSettings;

implementation

{$R *.dfm}

{ Events }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  ClientWidth := 49;

  Settings := TSettings.Create(ChangeFileExt(Application.ExeName, '.ini'));

  Left := Config.Window.Left;
  Top := Config.Window.Top;

  AdjustAndSaveWindowLocation; 

  Ping := TPing.Create(Config.Ping.HostName, Config.Ping.Timeout);

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
  I: Byte;
  Position, Width: Byte;
  Color: TColor;
begin
  Position := 0;

  for I := 1 to 16 do
  begin
    Width := Settings.GetPingWidth(PingReplies[I]);
    Color := Settings.GetPingColor(PingReplies[I]);

    InspectGrid.Canvas.Pen.Color := Color;
    InspectGrid.Canvas.Brush.Color := Color;
    InspectGrid.Canvas.Rectangle(Position, 0, Position + Width, 2);

    Position := Position + Width + 1;

    if (Position >= InspectGrid.Width) then
    begin
      InspectGrid.Canvas.Rectangle(Position - 1, 0, Position + 1, 2);
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

      Inc(PingTotal, Max(PingReply.Time, Config.Ping.PollingInterval));

      if (PingReply.Time < Config.Ping.PollingInterval) then
        if (PingReply.Failure) then
          Sleep(Config.Ping.RefreshInterval)
        else
          Sleep(Config.Ping.PollingInterval - PingReply.Time);

      if (PingReply.Failure) or (PingTotal >= Config.Ping.RefreshInterval) then
        Break;
    end;

    MainForm.UpdatePing(PingMax);
  end;
end;

procedure TMainForm.UpdatePing(PingReply: TPingReply);
var
  Color: TColor;
begin
  Color := Settings.GetPingColor(PingReply);

  PingLabel.Caption := IfThen(PingReply.Failure, '!', IntToStr(PingReply.Time));

  PingLabel.Font.Color := Color;
  PingFrame.Pen.Color := Color;

  AuxiliaryForm.AppendLogEntry(PingReply.Result);

  UpdateInspectGrid(PingReply);
end;

procedure TMainForm.UpdateInspectGrid(PingReply: TPingReply);
var
  I: Byte;
begin
  for I := 16 downto 2 do
    PingReplies[I] := PingReplies[I - 1];

  PingReplies[1] := PingReply;

  InspectGrid.Invalidate;
end;

procedure TMainForm.DragMove;
begin
  ReleaseCapture;
  Perform(WM_SYSCOMMAND, $F012, 0);

  AdjustAndSaveWindowLocation;
end;

procedure TMainForm.AdjustAndSaveWindowLocation;
begin
  if (Left < 0) then
    Left := 0
  else if (Left + Width > Screen.Width) then
    Left := Screen.Width - Width;

  if (Top < 0) then
    Top := 0
  else if (Top + Height > Screen.Height) then
    Top := Screen.Height - Height;

  Settings.SaveWindowLocation(Left, Top);
end;

procedure TMainForm.ToggleAuxiliaryForm;
begin
  AuxiliaryForm.Visible := not AuxiliaryForm.Visible;
  MainForm.BringToFront;

  AuxiliaryForm.LogOption.Checked := AuxiliaryForm.Visible;
  LogOption.Checked := AuxiliaryForm.Visible;
end;

end.

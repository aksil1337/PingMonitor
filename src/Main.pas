unit Main;

interface

uses
  StdCtrls, ExtCtrls, Controls, Classes, Windows, Forms, Dialogs, Messages,
  SysUtils, StrUtils, Graphics, Menus, Ping, Settings, Tray;

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
    AuxiliaryOption: TMenuItem;
    TrayOption: TMenuItem;
    StartupOption: TMenuItem;
    ExitOption: TMenuItem;
    InspectGrid: TPaintBox;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ExitOptionClick(Sender: TObject);
    procedure InspectGridPaint(Sender: TObject);
    procedure ToggleAuxiliaryForm(Sender: TObject);
    procedure ToggleTrayIcon(Sender: TObject = nil);
    procedure ToggleAutomaticStartup(Sender: TObject = nil);
  private
    procedure UpdatePing(PingReply: TPingReply);
    procedure DragMove;
    procedure AdjustAndSaveWindowLocation;
  protected
    procedure WindowPositionChanged(var Msg: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
  end;

var
  MainForm: TMainForm;
  Ping: TPing;
  Settings: TSettings;
  Config: TConfig;
  TrayIcon: TTrayIcon;

implementation

uses
  Auxiliary;

{$R *.dfm}

{ Events }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  ClientWidth := 49;

  Settings := TSettings.Create;

  Left := Config.Window.Left;
  Top := Config.Window.Top;

  AdjustAndSaveWindowLocation;

  TrayIcon := TTrayIcon.Create(PopupMenu);

  Ping := TPing.Create(Config.Ping.HostName, Config.Ping.Timeout);

  if (Ping.Initialized) then
    TPingThread.Create(false);

  ToggleAutomaticStartup;
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
  if (Config.Application.RunInTray <> TrayIcon.Visible) then
    ToggleTrayIcon;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  TrayIcon.Destroy;
end;

procedure TMainForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ActiveControl := nil;

  if (Button = mbLeft) then
    DragMove;
end;

procedure TMainForm.ExitOptionClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TMainForm.InspectGridPaint(Sender: TObject);
var
  I: Byte;
  PingColor: TColor;
  CellLeft, CellWidth: Byte;
begin
  if (LogEntries.Count < 1) then
    Exit;

  CellLeft := 0;

  for I := 0 to LogEntries.Count - 1 do
  begin
    PingColor := Settings.GetPingColor(PingHistory[I]);
    CellWidth := Settings.GetCellWidth(PingHistory[I]);

    InspectGrid.Canvas.Pen.Color := PingColor;
    InspectGrid.Canvas.Brush.Color := PingColor;
    InspectGrid.Canvas.Rectangle(CellLeft, 0, CellLeft + CellWidth, 2);

    CellLeft := CellLeft + CellWidth + 1;

    if (CellLeft >= InspectGrid.Width) then
    begin
      InspectGrid.Canvas.Rectangle(CellLeft - 1, 0, CellLeft, 2);
      Break;
    end;
  end;
end;

procedure TMainForm.ToggleAuxiliaryForm(Sender: TObject);
begin
  AuxiliaryForm.Visible := not AuxiliaryForm.Visible;
  AuxiliaryOption.Checked := AuxiliaryForm.Visible;

  AuxiliaryForm.RedirectFormFocus;
end;

procedure TMainForm.ToggleTrayIcon(Sender: TObject);
begin
  TrayIcon.Visible := not TrayIcon.Visible;
  TrayOption.Checked := TrayIcon.Visible;

  Settings.SaveTrayPreferences(TrayIcon.Visible);
end;

procedure TMainForm.ToggleAutomaticStartup(Sender: TObject);
var
  RunAtStartup: Boolean;
begin
  if (Sender = StartupOption) then
    RunAtStartup := not StartupOption.Checked
  else
    RunAtStartup := Config.Application.RunAtStartup;

  StartupOption.Checked := Settings.SaveStartupPreferences(RunAtStartup);
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
begin
  while True do
  begin
    PingReply := Ping.Determine;

    MainForm.UpdatePing(PingReply);
  end;
end;

procedure TMainForm.UpdatePing(PingReply: TPingReply);
var
  Color: TColor;
begin
  Color := Settings.GetPingColor(PingReply);

  case (PingReply.Failure) of
    False: PingLabel.Caption := IntToStr(PingReply.Time);
    else   PingLabel.Caption := '!';
  end;

  PingLabel.Font.Color := Color;
  PingFrame.Pen.Color := Color;

  AuxiliaryForm.AppendLogEntry(PingReply);

  Ping.UpdateHistory(PingReply);

  InspectGrid.Invalidate;
  AuxiliaryForm.ChartArea.Invalidate;
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

end.

unit Auxiliary;

interface

uses
  StdCtrls, ExtCtrls, ComCtrls, Controls, Classes, Forms, SysUtils, StrUtils,
  Graphics, Menus, Clipbrd, Ping;

type
  TAuxiliaryForm = class(TForm)
    LogPanel: TPanel;
    LogMemo: TMemo;
    ChartPanel: TPanel;
    ChartArea: TPaintBox;
    PopupMenu: TPopupMenu;
    ChartOption: TMenuItem;
    LogOption: TMenuItem;
    CopyOption: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure LogMemoEnter(Sender: TObject);
    procedure CopyOptionClick(Sender: TObject);
    procedure ChartAreaPaint(Sender: TObject);
    procedure SwapToChartOrLog(Sender: TObject);
    procedure SwapBetweenChartAndLog(Sender: TObject);
  public
    procedure AppendLogEntry(PingReply: TPingReply);
  end;

var
  AuxiliaryForm: TAuxiliaryForm;
  LogEntries: TStringList;

const
  BarWidth = 28;
  JitterWidth = 8;
  BarGap = 2;

implementation

uses
  Main;

{$R *.dfm}

{ Events }

procedure TAuxiliaryForm.FormCreate(Sender: TObject);
begin
  LogEntries := TStringList.Create;

  if (Config.Details.DisplayLog) then
    SwapToChartOrLog(LogOption)
  else
    SwapToChartOrLog(ChartOption);
end;

procedure TAuxiliaryForm.LogMemoEnter(Sender: TObject);
begin
  LogPanel.SetFocus;
end;

procedure TAuxiliaryForm.CopyOptionClick(Sender: TObject);
begin
  Clipboard.AsText := LogEntries.Text;
end;

procedure TAuxiliaryForm.ChartAreaPaint(Sender: TObject);
var
  I: Byte;
  PingColor, JitterColor: TColor;
  Text: String;
  BarHeight, JitterMaxHeight, JitterMinHeight: SmallInt;
  TextAreaHeight, TextWidth: Byte;
  BarLeft, BarRight, BarTop, BarBottom: SmallInt;
  JitterLeft, JitterRight, JitterMaxTop, JitterMinBottom: SmallInt;
  TextLeft, TextTop: SmallInt;
begin
  if (LogEntries.Count < 1) then
    Exit;

  for I := 0 to LogEntries.Count - 1 do
  begin
    PingColor := Settings.GetPingColor(PingHistory[I]);
    JitterColor := Settings.GetPingColor(PingHistory[I], ptMax);

    case (PingHistory[I].Failure) of
      False:
      begin
        Text := IntToStr(PingHistory[I].Time);
        BarHeight := PingHistory[I].Time div 4 + 1;
        JitterMaxHeight := (PingHistory[I].Max - PingHistory[I].Time) div 4;
        JitterMinHeight := (PingHistory[I].Time - PingHistory[I].Min) div 4;

        if (JitterMaxHeight > 0) and (JitterMinHeight = 0) then
          JitterMinHeight := 1
        else if (JitterMinHeight > 0) and (JitterMaxHeight = 0) then
          JitterMaxHeight := 1;
      end;
      else
      begin
        Text := '!';
        BarHeight := ChartArea.Height;
        JitterMaxHeight := 0;
        JitterMinHeight := 0;
      end;
    end;

    TextAreaHeight := ChartArea.Font.Size * 2;
    TextWidth := ChartArea.Canvas.TextWidth(Text);

    BarLeft := I * (BarWidth + BarGap);
    BarRight := BarLeft + BarWidth;
    BarBottom := ChartArea.Height - TextAreaHeight;
    BarTop := BarBottom - BarHeight;

    JitterLeft := BarLeft + BarWidth div 2 - JitterWidth div 2;
    JitterRight := BarLeft + BarWidth div 2 + JitterWidth div 2;
    JitterMaxTop := BarTop - JitterMaxHeight;
    JitterMinBottom := BarTop + JitterMinHeight;

    TextLeft := BarLeft + BarWidth div 2 - TextWidth div 2;
    TextTop := BarBottom + 1;

    ChartArea.Canvas.Pen.Color := PingColor;
    ChartArea.Canvas.Brush.Color := PingColor;
    ChartArea.Canvas.Rectangle(BarLeft, BarTop, BarRight, BarBottom);

    ChartArea.Canvas.Pen.Color := JitterColor;
    ChartArea.Canvas.Brush.Color := JitterColor;
    ChartArea.Canvas.Rectangle(JitterLeft, JitterMaxTop, JitterRight, BarTop);

    ChartArea.Canvas.Pen.Color := ChartArea.Color;
    ChartArea.Canvas.Brush.Color := ChartArea.Color;
    ChartArea.Canvas.Rectangle(JitterLeft, BarTop, JitterRight, JitterMinBottom);

    ChartArea.Canvas.Font.Color := PingColor;
    ChartArea.Canvas.TextOut(TextLeft, TextTop, Text);
  end;
end;

procedure TAuxiliaryForm.SwapToChartOrLog(Sender: TObject);
begin
  ChartPanel.Visible := Sender = ChartOption;
  LogPanel.Visible := not ChartPanel.Visible;

  ChartOption.Checked := ChartPanel.Visible;
  ChartOption.Default := not ChartPanel.Visible;

  LogOption.Checked := LogPanel.Visible;
  LogOption.Default := not LogPanel.Visible;

  Settings.SaveDisplayPreferences(Sender);
end;

procedure TAuxiliaryForm.SwapBetweenChartAndLog(Sender: TObject);
begin
  if (ChartPanel.Visible) then
    SwapToChartOrLog(LogOption)
  else
    SwapToChartOrLog(ChartOption);
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

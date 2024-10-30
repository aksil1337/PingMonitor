unit Tray;

interface

uses
  Controls, Classes, Windows, Forms, Messages, SysUtils, Graphics, Menus,
  ShellApi;

type
  TTrayIcon = class
  private
    Handle: HWND;
    IsVisible: Boolean;
    PopupMenu: TPopupMenu;
    IconData: TNotifyIconData;
    procedure SetVisible(Value: Boolean);
  protected
    procedure MessageReceived(var Msg: TMessage);
  public
    constructor Create(PopupMenu: TPopupMenu);
    destructor Destroy; override;
    property Visible: Boolean read IsVisible write SetVisible default False;
  end;

const
  WM_NOTIFYICON = WM_USER + 1337;

implementation

{ Structors }

constructor TTrayIcon.Create(PopupMenu: TPopupMenu);
begin
  Self.PopupMenu := PopupMenu;

  Handle := Classes.AllocateHWnd(MessageReceived);

  with (IconData) do
  begin
    cbSize := SizeOf(IconData);
    Wnd := Handle;
    uID := 0;
    uFlags := NIF_MESSAGE or NIF_ICON or NIF_TIP;
    uCallbackMessage := WM_NOTIFYICON;
    hIcon := Application.Icon.Handle;
    StrPCopy(szTip, Application.Title);
  end;
end;

destructor TTrayIcon.Destroy;
begin
  Shell_NotifyIcon(NIM_DELETE, @IconData);
  Classes.DeallocateHWnd(Handle);
end;

{ Messages }

procedure TTrayIcon.MessageReceived(var Msg: TMessage);
var
  I: Integer;
begin
  case (Msg.Msg) of
    WM_NOTIFYICON:
      case (Msg.LParam) of
        WM_LBUTTONDBLCLK:
          for I := 0 to PopupMenu.Items.Count - 1 do
            if (PopupMenu.Items[I].Default) then
              PopupMenu.Items[I].Click;
        WM_RBUTTONDOWN:
        begin
          SetForegroundWindow(Application.MainForm.Handle);
          PopupMenu.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
        end;
      end;
    WM_QUERYENDSESSION:
      Msg.Result := 1;
    WM_ENDSESSION:
      Destroy;
  end;
end;

{ Methods }

procedure TTrayIcon.SetVisible(Value: Boolean);
begin
  if (Value) then
  begin
    ShowWindow(Application.Handle, SW_HIDE);
    Shell_NotifyIcon(NIM_ADD, @IconData);
  end
  else
  begin
    ShowWindow(Application.Handle, SW_SHOW);
    Shell_NotifyIcon(NIM_DELETE, @IconData);
  end;

  IsVisible := Value;
end;

end.

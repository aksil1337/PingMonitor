object MainForm: TMainForm
  Left = 200
  Top = 160
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'PingMonitor'
  ClientHeight = 27
  ClientWidth = 115
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Verdana'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  PopupMenu = PopupMenu
  Position = poScreenCenter
  OnCreate = FormCreate
  OnMouseDown = FormMouseDown
  PixelsPerInch = 96
  TextHeight = 13
  object InspectGrid: TPaintBox
    Left = 1
    Top = 24
    Width = 47
    Height = 2
    OnMouseDown = FormMouseDown
    OnPaint = InspectGridPaint
  end
  object PingPanel: TPanel
    Left = 0
    Top = 0
    Width = 49
    Height = 24
    BevelOuter = bvNone
    Caption = 'PingPanel'
    Color = clBlack
    TabOrder = 0
    object PingFrame: TShape
      Left = 1
      Top = 1
      Width = 47
      Height = 22
      Brush.Color = clBlack
      Pen.Color = clWhite
      Pen.Width = 2
    end
    object PingLabel: TLabel
      Left = 0
      Top = 0
      Width = 49
      Height = 24
      Align = alClient
      Alignment = taCenter
      AutoSize = False
      Caption = #8226
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
      Layout = tlCenter
      OnMouseDown = FormMouseDown
    end
  end
  object PopupMenu: TPopupMenu
    Left = 56
    object ExitOption: TMenuItem
      Caption = 'Exit'
      OnClick = ExitOptionClick
    end
  end
end

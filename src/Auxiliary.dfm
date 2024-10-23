object AuxiliaryForm: TAuxiliaryForm
  Left = 200
  Top = 220
  BorderStyle = bsNone
  Caption = 'AuxiliaryForm'
  ClientHeight = 285
  ClientWidth = 600
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  PopupMenu = PopupMenu
  Position = poScreenCenter
  OnClick = RedirectFormFocus
  OnCreate = FormCreate
  OnDblClick = SwapBetweenChartAndLog
  PixelsPerInch = 96
  TextHeight = 13
  object LogPanel: TPanel
    Left = 1
    Top = 1
    Width = 598
    Height = 283
    BevelOuter = bvNone
    Color = 2631720
    TabOrder = 0
    object LogMemo: TMemo
      Left = 0
      Top = 0
      Width = 602
      Height = 283
      Cursor = crArrow
      Align = alLeft
      BorderStyle = bsNone
      Color = 2631720
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Consolas'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 0
      WordWrap = False
      OnClick = RedirectFormFocus
      OnDblClick = SwapBetweenChartAndLog
      OnEnter = LogMemoEnter
    end
  end
  object ChartPanel: TPanel
    Left = 1
    Top = 1
    Width = 598
    Height = 283
    BevelOuter = bvNone
    Color = 2631720
    TabOrder = 1
    object ChartArea: TPaintBox
      Left = 0
      Top = 0
      Width = 598
      Height = 283
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = RedirectFormFocus
      OnDblClick = SwapBetweenChartAndLog
      OnPaint = ChartAreaPaint
    end
  end
  object PopupMenu: TPopupMenu
    Alignment = paCenter
    OnPopup = RedirectFormFocus
    Left = 9
    Top = 9
    object ChartOption: TMenuItem
      Caption = 'Display Chart'
      OnClick = SwapToChartOrLog
    end
    object LogOption: TMenuItem
      Caption = 'Display Log'
      OnClick = SwapToChartOrLog
    end
    object CopyOption: TMenuItem
      Caption = 'Copy Text'
      OnClick = CopyOptionClick
    end
  end
end

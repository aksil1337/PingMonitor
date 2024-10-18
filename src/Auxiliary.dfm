object AuxiliaryForm: TAuxiliaryForm
  Left = 200
  Top = 220
  BorderStyle = bsNone
  Caption = 'AuxiliaryForm'
  ClientHeight = 285
  ClientWidth = 599
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
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object LogPanel: TPanel
    Left = 1
    Top = 1
    Width = 597
    Height = 283
    BevelOuter = bvNone
    Color = clBlack
    TabOrder = 0
    object LogMemo: TMemo
      Left = 0
      Top = 0
      Width = 600
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
      OnEnter = LogMemoEnter
    end
  end
  object PopupMenu: TPopupMenu
    Alignment = paCenter
    Left = 9
    Top = 9
    object LogOption: TMenuItem
      Caption = 'Show Log'
      Default = True
      OnClick = LogOptionClick
    end
    object CopyOption: TMenuItem
      Caption = 'Copy Text'
      OnClick = CopyOptionClick
    end
  end
end

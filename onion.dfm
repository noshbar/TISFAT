object frmOnion: TfrmOnion
  Left = 334
  Top = 324
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'Onion Skinning'
  ClientHeight = 105
  ClientWidth = 181
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 43
    Width = 125
    Height = 13
    Caption = 'Number of Frames to Skin:'
    Transparent = True
  end
  object lblTitle: TLabel
    Left = 8
    Top = 8
    Width = 165
    Height = 13
    Cursor = crSizeAll
    Caption = 'Onion Skinning for KeyFrame'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    OnMouseDown = lblTitleMouseDown
    OnMouseMove = lblTitleMouseMove
    OnMouseUp = lblTitleMouseUp
  end
  object Button1: TButton
    Left = 16
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Apply'
    Default = True
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 96
    Top = 72
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = Button2Click
  end
  object m_strFrames: TEdit
    Left = 136
    Top = 40
    Width = 33
    Height = 21
    TabOrder = 0
    Text = '0'
  end
end

object frmRectProps: TfrmRectProps
  Left = 211
  Top = 224
  BorderStyle = bsNone
  Caption = 'Rect,um, properties'
  ClientHeight = 240
  ClientWidth = 272
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnPaint = FormPaint
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblTitle: TLabel
    Left = 2
    Top = 2
    Width = 241
    Height = 17
    Cursor = crSizeAll
    AutoSize = False
    Caption = 'Rectangle Rectifier'
    Color = clBlue
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    OnMouseDown = lblTitleMouseDown
    OnMouseMove = lblTitleMouseMove
    OnMouseUp = lblTitleMouseUp
  end
  object Label1: TLabel
    Left = 8
    Top = 99
    Width = 54
    Height = 13
    Caption = 'Line Width:'
  end
  object Label2: TLabel
    Left = 8
    Top = 118
    Width = 30
    Height = 13
    Caption = 'Alpha:'
  end
  object cmdOK: TButton
    Left = 8
    Top = 160
    Width = 105
    Height = 25
    Caption = 'Apply To &KeyFrame'
    Default = True
    TabOrder = 5
    OnClick = cmdOKClick
  end
  object cmdOutercolour: TButton
    Left = 8
    Top = 40
    Width = 65
    Height = 25
    Caption = '&Outer Colour'
    TabOrder = 0
    OnClick = cmdOutercolourClick
  end
  object cmdInnerColour: TButton
    Left = 8
    Top = 64
    Width = 65
    Height = 25
    Caption = '&Inner Colour'
    TabOrder = 2
    OnClick = cmdInnerColourClick
  end
  object m_strLineWidth: TEdit
    Left = 80
    Top = 96
    Width = 33
    Height = 21
    TabOrder = 4
    OnChange = m_strLineWidthChange
  end
  object Button1: TButton
    Left = 8
    Top = 184
    Width = 105
    Height = 25
    Caption = 'Apply to &Layer'
    TabOrder = 6
    OnClick = Button1Click
  end
  object cmdCancel: TButton
    Left = 8
    Top = 208
    Width = 105
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 7
    OnClick = cmdCancelClick
  end
  object Button2: TButton
    Left = 72
    Top = 40
    Width = 41
    Height = 25
    Caption = '&Clear'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 72
    Top = 64
    Width = 41
    Height = 25
    Caption = 'Cl&ear'
    TabOrder = 3
    OnClick = Button3Click
  end
  object alphaBar: TTrackBar
    Left = 8
    Top = 136
    Width = 105
    Height = 18
    Max = 255
    Position = 255
    TabOrder = 8
    OnChange = alphaBarChange
  end
  object m_strAlpha: TEdit
    Left = 80
    Top = 115
    Width = 33
    Height = 21
    TabOrder = 9
    OnChange = m_strAlphaChange
  end
  object cd: TColorDialog
    Left = 120
    Top = 40
  end
end

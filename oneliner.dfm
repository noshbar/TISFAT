object frmLiner: TfrmLiner
  Left = 358
  Top = 309
  BorderStyle = bsNone
  Caption = 'One Liner'
  ClientHeight = 169
  ClientWidth = 320
  Color = clWhite
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
    Top = 68
    Width = 54
    Height = 13
    Caption = 'Line Width:'
    Transparent = True
  end
  object lblHeading: TLabel
    Left = 0
    Top = 0
    Width = 32
    Height = 25
    Cursor = crSizeAll
    AutoSize = False
    Caption = 'One Liner'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    OnMouseDown = lblHeadingMouseDown
    OnMouseMove = lblHeadingMouseMove
    OnMouseUp = lblHeadingMouseUp
  end
  object Label3: TLabel
    Left = 8
    Top = 36
    Width = 56
    Height = 13
    Caption = 'Line Colour:'
    Transparent = True
  end
  object Label2: TLabel
    Left = 8
    Top = 94
    Width = 30
    Height = 13
    Caption = 'Alpha:'
  end
  object cmdOK: TButton
    Left = 5
    Top = 136
    Width = 99
    Height = 25
    Caption = 'Apply to &KeyFrame'
    Default = True
    TabOrder = 2
    OnClick = cmdOKClick
  end
  object cmdCancel: TButton
    Left = 213
    Top = 136
    Width = 99
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    TabOrder = 4
    OnClick = cmdCancelClick
  end
  object m_strLineWidth: TEdit
    Left = 80
    Top = 64
    Width = 25
    Height = 21
    TabOrder = 1
    Text = '2'
    OnChange = m_strLineWidthChange
  end
  object cmdColour: TButton
    Left = 104
    Top = 32
    Width = 25
    Height = 25
    Caption = '...'
    TabOrder = 0
    OnClick = cmdColourClick
  end
  object cmdApplyAll: TButton
    Left = 109
    Top = 136
    Width = 99
    Height = 25
    Caption = 'Apply to &Layer'
    TabOrder = 3
    OnClick = cmdApplyAllClick
  end
  object m_strAlpha: TEdit
    Left = 80
    Top = 91
    Width = 25
    Height = 21
    TabOrder = 5
    OnChange = m_strAlphaChange
  end
  object alphaBar: TTrackBar
    Left = 8
    Top = 112
    Width = 105
    Height = 18
    Max = 255
    Position = 255
    TabOrder = 6
    OnChange = alphaBarChange
  end
  object cd: TColorDialog
    Left = 160
    Top = 48
  end
end

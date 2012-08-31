object frmMovieProps: TfrmMovieProps
  Left = 283
  Top = 207
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'Muuuvee Proporteees'
  ClientHeight = 240
  ClientWidth = 227
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
  object lblTitle: TLabel
    Left = 8
    Top = 8
    Width = 96
    Height = 13
    Cursor = crSizeAll
    Caption = 'Movie Properties'
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
  object Width: TLabel
    Left = 8
    Top = 40
    Width = 28
    Height = 13
    Caption = 'Width'
    Transparent = True
  end
  object Label1: TLabel
    Left = 128
    Top = 40
    Width = 31
    Height = 13
    Caption = 'Height'
    Transparent = True
  end
  object Label2: TLabel
    Left = 8
    Top = 72
    Width = 189
    Height = 13
    Caption = 'Description (Author, Content, Whatever)'
    Transparent = True
  end
  object cmdOK: TButton
    Left = 56
    Top = 208
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 3
    OnClick = cmdOKClick
  end
  object cmdCancel: TButton
    Left = 144
    Top = 208
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 4
    OnClick = cmdCancelClick
  end
  object memDescription: TMemo
    Left = 8
    Top = 88
    Width = 209
    Height = 113
    MaxLength = 256
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object m_strWidth: TEdit
    Left = 48
    Top = 36
    Width = 41
    Height = 21
    TabOrder = 0
  end
  object m_strHeight: TEdit
    Left = 176
    Top = 36
    Width = 41
    Height = 21
    TabOrder = 1
  end
end

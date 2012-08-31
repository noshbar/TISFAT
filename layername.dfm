object frmLayerName: TfrmLayerName
  Left = 195
  Top = 248
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'frmLayerName'
  ClientHeight = 88
  ClientWidth = 330
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnMouseDown = FormMouseDown
  OnMouseMove = FormMouseMove
  OnMouseUp = FormMouseUp
  OnPaint = FormPaint
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 34
    Width = 60
    Height = 13
    Caption = 'Layer Name:'
    Transparent = True
  end
  object lblTitle: TLabel
    Left = 8
    Top = 8
    Width = 93
    Height = 13
    Cursor = crSizeAll
    Caption = 'Layer Properties'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object m_strTitle: TEdit
    Left = 72
    Top = 32
    Width = 249
    Height = 21
    MaxLength = 255
    TabOrder = 0
  end
  object cmdOK: TButton
    Left = 168
    Top = 56
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 1
    OnClick = cmdOKClick
  end
  object cmdCancel: TButton
    Left = 248
    Top = 56
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = cmdCancelClick
  end
end

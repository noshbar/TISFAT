object frmAction: TfrmAction
  Left = 239
  Top = 213
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'Action'
  ClientHeight = 200
  ClientWidth = 283
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
    Top = 0
    Width = 96
    Height = 13
    Cursor = crSizeAll
    Caption = 'KeyFrame Action'
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
  object lblCaption: TLabel
    Left = 8
    Top = 120
    Width = 46
    Height = 13
    Caption = 'lblCaption'
    Transparent = True
  end
  object lblCaption2: TLabel
    Left = 24
    Top = 136
    Width = 52
    Height = 13
    Caption = 'lblCaption2'
    Transparent = True
  end
  object cmdOK: TButton
    Left = 40
    Top = 168
    Width = 75
    Height = 25
    Caption = '&Apply'
    Default = True
    TabOrder = 4
    OnClick = cmdOKClick
  end
  object cmdCancel: TButton
    Left = 200
    Top = 168
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 5
    OnClick = cmdCancelClick
  end
  object rg: TRadioGroup
    Left = 8
    Top = 24
    Width = 265
    Height = 89
    Caption = ' Choose Action to Perform '
    Items.Strings = (
      'Jump to Frame'
      'Load other Movie'
      'FX - Shake Movie'
      'FX - Old Skool')
    TabOrder = 0
    OnClick = rgClick
  end
  object strInfo: TEdit
    Left = 64
    Top = 117
    Width = 121
    Height = 21
    TabOrder = 1
    Text = 'strInfo'
  end
  object cmdBrowse: TButton
    Left = 192
    Top = 117
    Width = 25
    Height = 21
    Caption = '...'
    TabOrder = 2
    OnClick = cmdBrowseClick
  end
  object strInfo2: TEdit
    Left = 8
    Top = 168
    Width = 97
    Height = 21
    TabOrder = 3
    Text = 'strInfo2'
  end
  object chk1: TCheckBox
    Left = 8
    Top = 144
    Width = 97
    Height = 17
    Caption = 'I hate resource haxor boyees'
    TabOrder = 6
  end
  object chk2: TCheckBox
    Left = 144
    Top = 144
    Width = 97
    Height = 17
    Caption = 'chk2'
    TabOrder = 7
  end
  object cmdNothing: TButton
    Left = 120
    Top = 168
    Width = 75
    Height = 25
    Caption = '&Nothing'
    TabOrder = 8
    OnClick = cmdNothingClick
  end
  object od: TOpenDialog
    Left = 192
    Top = 40
  end
end

object frmExport: TfrmExport
  Left = 285
  Top = 260
  BorderStyle = bsNone
  Caption = 'Export Settings'
  ClientHeight = 97
  ClientWidth = 290
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
    Top = 34
    Width = 50
    Height = 13
    Caption = 'File Name:'
    Transparent = True
  end
  object lblTitle: TLabel
    Left = 0
    Top = 8
    Width = 87
    Height = 13
    Cursor = crSizeAll
    Caption = 'Export Settings'
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
  object cmdExport: TButton
    Left = 128
    Top = 64
    Width = 75
    Height = 25
    Caption = '&Export'
    Default = True
    TabOrder = 2
    OnClick = cmdExportClick
  end
  object cmdCancel: TButton
    Left = 208
    Top = 64
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = cmdCancelClick
  end
  object m_strFileName: TEdit
    Left = 64
    Top = 32
    Width = 185
    Height = 21
    TabOrder = 0
  end
  object cmdBrowse: TButton
    Left = 256
    Top = 32
    Width = 21
    Height = 21
    Caption = '...'
    TabOrder = 1
    OnClick = cmdBrowseClick
  end
  object sd: TSaveDialog
    Filter = 'EXE Files|*.exe'
    Left = 32
    Top = 64
  end
end

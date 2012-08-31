object frmTextProps: TfrmTextProps
  Left = 260
  Top = 264
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'Textifier'
  ClientHeight = 254
  ClientWidth = 321
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
  object Label1: TLabel
    Left = 8
    Top = 40
    Width = 99
    Height = 13
    Caption = 'Change Outer Colour'
    Transparent = True
  end
  object lblColour: TLabel
    Left = 160
    Top = 32
    Width = 25
    Height = 25
    AutoSize = False
  end
  object lblTitle: TLabel
    Left = 0
    Top = 0
    Width = 73
    Height = 13
    Cursor = crSizeAll
    AutoSize = False
    Caption = 'The Textifier'
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
  object Label2: TLabel
    Left = 8
    Top = 72
    Width = 97
    Height = 13
    Caption = 'Change Inner Colour'
    Transparent = True
  end
  object lblFontColour: TLabel
    Left = 160
    Top = 64
    Width = 25
    Height = 25
    AutoSize = False
  end
  object Label3: TLabel
    Left = 8
    Top = 124
    Width = 39
    Height = 13
    Caption = 'Caption:'
    Transparent = True
  end
  object Label4: TLabel
    Left = 8
    Top = 99
    Width = 55
    Height = 13
    Caption = 'Font Name:'
    Transparent = True
  end
  object cmdOuterColour: TButton
    Left = 128
    Top = 32
    Width = 27
    Height = 25
    Caption = '...'
    TabOrder = 0
    OnClick = cmdOuterColourClick
  end
  object cmdClearColour: TButton
    Left = 200
    Top = 32
    Width = 75
    Height = 25
    Caption = '&Clear'
    TabOrder = 1
    OnClick = cmdClearColourClick
  end
  object cmdApply: TButton
    Left = 8
    Top = 224
    Width = 99
    Height = 25
    Caption = 'Apply to &KeyFrame'
    TabOrder = 5
    OnClick = cmdApplyClick
  end
  object cmdApplyAll: TButton
    Left = 112
    Top = 224
    Width = 99
    Height = 25
    Caption = 'Apply to &Layer'
    TabOrder = 6
    OnClick = cmdApplyAllClick
  end
  object cmdCancel: TButton
    Left = 216
    Top = 224
    Width = 99
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 7
    OnClick = cmdCancelClick
  end
  object cboFontNames: TComboBox
    Left = 72
    Top = 96
    Width = 241
    Height = 21
    ItemHeight = 13
    TabOrder = 3
    Text = 'cboFontNames'
    OnChange = cboFontNamesChange
  end
  object cmdChangeInnerColour: TButton
    Left = 128
    Top = 64
    Width = 27
    Height = 25
    Caption = '...'
    TabOrder = 2
    OnClick = cmdChangeInnerColourClick
  end
  object m_strCaption: TEdit
    Left = 72
    Top = 120
    Width = 241
    Height = 21
    TabOrder = 4
    OnChange = m_strCaptionChange
  end
  object chkBold: TCheckBox
    Left = 8
    Top = 192
    Width = 49
    Height = 17
    Caption = 'Bold'
    TabOrder = 8
    OnClick = chkItalicClick
  end
  object chkUnderlined: TCheckBox
    Left = 120
    Top = 192
    Width = 81
    Height = 17
    Caption = 'Underlined'
    TabOrder = 9
    OnClick = chkItalicClick
  end
  object chkItalic: TCheckBox
    Left = 256
    Top = 192
    Width = 57
    Height = 17
    Caption = 'Italic'
    TabOrder = 10
    OnClick = chkItalicClick
  end
  object cd: TColorDialog
    Ctl3D = True
    Left = 96
    Top = 32
  end
end

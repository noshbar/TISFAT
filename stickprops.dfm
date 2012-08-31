object frmStickProps: TfrmStickProps
  Left = 181
  Top = 145
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'Womanizer'
  ClientHeight = 367
  ClientWidth = 561
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnPaint = FormPaint
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblTitle: TLabel
    Left = 0
    Top = 0
    Width = 241
    Height = 17
    Cursor = crSizeAll
    AutoSize = False
    Caption = 'Man Manipulator (aka Woman)'
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
    Top = 275
    Width = 77
    Height = 13
    Caption = 'Set all widths to:'
  end
  object Label2: TLabel
    Left = 8
    Top = 76
    Width = 36
    Height = 13
    Caption = 'Length:'
    Transparent = True
  end
  object Label3: TLabel
    Left = 13
    Top = 95
    Width = 31
    Height = 13
    Caption = 'Width:'
    Transparent = True
  end
  object Label4: TLabel
    Left = 8
    Top = 124
    Width = 36
    Height = 13
    Caption = 'Length:'
    Transparent = True
  end
  object Label5: TLabel
    Left = 13
    Top = 143
    Width = 31
    Height = 13
    Caption = 'Width:'
    Transparent = True
  end
  object Label6: TLabel
    Left = 8
    Top = 172
    Width = 36
    Height = 13
    Caption = 'Length:'
    Transparent = True
  end
  object Label7: TLabel
    Left = 13
    Top = 191
    Width = 31
    Height = 13
    Caption = 'Width:'
    Transparent = True
  end
  object Label8: TLabel
    Left = 8
    Top = 220
    Width = 36
    Height = 13
    Caption = 'Length:'
    Transparent = True
  end
  object Label9: TLabel
    Left = 13
    Top = 239
    Width = 31
    Height = 13
    Caption = 'Width:'
    Transparent = True
  end
  object Label10: TLabel
    Left = 13
    Top = 47
    Width = 31
    Height = 13
    Caption = 'Width:'
    Transparent = True
  end
  object Label11: TLabel
    Left = 20
    Top = 28
    Width = 23
    Height = 13
    Caption = 'Size:'
    Transparent = True
  end
  object Label12: TLabel
    Left = 352
    Top = 36
    Width = 36
    Height = 13
    Caption = ':Length'
    Transparent = True
  end
  object Label13: TLabel
    Left = 352
    Top = 55
    Width = 31
    Height = 13
    Caption = ':Width'
    Transparent = True
  end
  object Label14: TLabel
    Left = 352
    Top = 84
    Width = 36
    Height = 13
    Caption = ':Length'
    Transparent = True
  end
  object Label15: TLabel
    Left = 352
    Top = 103
    Width = 31
    Height = 13
    Caption = ':Width'
    Transparent = True
  end
  object Label16: TLabel
    Left = 352
    Top = 132
    Width = 36
    Height = 13
    Caption = ':Length'
    Transparent = True
  end
  object Label17: TLabel
    Left = 352
    Top = 151
    Width = 31
    Height = 13
    Caption = ':Width'
    Transparent = True
  end
  object Label18: TLabel
    Left = 352
    Top = 180
    Width = 36
    Height = 13
    Caption = ':Length'
    Transparent = True
  end
  object Label19: TLabel
    Left = 352
    Top = 199
    Width = 31
    Height = 13
    Caption = ':Width'
    Transparent = True
  end
  object Label20: TLabel
    Left = 352
    Top = 228
    Width = 36
    Height = 13
    Caption = ':Length'
    Transparent = True
  end
  object Label21: TLabel
    Left = 352
    Top = 247
    Width = 31
    Height = 13
    Caption = ':Width'
    Transparent = True
  end
  object lblColour1: TLabel
    Left = 88
    Top = 304
    Width = 25
    Height = 25
    AutoSize = False
    OnMouseUp = lblColour1MouseUp
  end
  object lblColour2: TLabel
    Left = 88
    Top = 336
    Width = 25
    Height = 25
    AutoSize = False
    OnMouseUp = lblColour2MouseUp
  end
  object Label22: TLabel
    Left = 8
    Top = 312
    Width = 77
    Height = 13
    Caption = 'Change colours:'
  end
  object Label23: TLabel
    Left = 284
    Top = 306
    Width = 30
    Height = 16
    Caption = 'Alpha:'
  end
  object m_strHeadDiam: TEdit
    Left = 48
    Top = 24
    Width = 30
    Height = 21
    TabOrder = 0
    OnChange = m_strHeadDiamChange
  end
  object m_strLeftArmTop: TEdit
    Left = 48
    Top = 72
    Width = 30
    Height = 21
    TabOrder = 1
    OnChange = m_strLeftArmTopChange
  end
  object m_strLeftArmBot: TEdit
    Left = 48
    Top = 120
    Width = 30
    Height = 21
    TabOrder = 2
  end
  object m_strLeftLegTop: TEdit
    Left = 48
    Top = 168
    Width = 30
    Height = 21
    TabOrder = 3
  end
  object m_strLeftLegBot: TEdit
    Left = 48
    Top = 216
    Width = 30
    Height = 21
    TabOrder = 4
  end
  object m_strRightArmTop: TEdit
    Left = 320
    Top = 32
    Width = 30
    Height = 21
    TabOrder = 5
  end
  object m_strRightArmBot: TEdit
    Left = 320
    Top = 80
    Width = 30
    Height = 21
    TabOrder = 6
  end
  object m_strBodyLength: TEdit
    Left = 320
    Top = 128
    Width = 30
    Height = 21
    TabOrder = 7
  end
  object m_strRightLegTop: TEdit
    Left = 320
    Top = 176
    Width = 30
    Height = 21
    TabOrder = 8
  end
  object m_strRightLegBot: TEdit
    Left = 320
    Top = 224
    Width = 30
    Height = 21
    TabOrder = 9
  end
  object cmdDone: TButton
    Left = 448
    Top = 272
    Width = 105
    Height = 25
    Caption = 'Apply to &KeyFrame'
    TabOrder = 10
    OnClick = cmdDoneClick
  end
  object cmdCancel: TButton
    Left = 448
    Top = 336
    Width = 105
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 11
    OnClick = cmdCancelClick
  end
  object cmdPreview: TButton
    Left = 280
    Top = 272
    Width = 75
    Height = 25
    Caption = '&Preview'
    TabOrder = 12
    OnClick = cmdPreviewClick
  end
  object Edit1: TEdit
    Left = 48
    Top = 44
    Width = 30
    Height = 21
    TabOrder = 13
    OnChange = Edit1Change
  end
  object Edit2: TEdit
    Left = 48
    Top = 92
    Width = 30
    Height = 21
    TabOrder = 14
    OnChange = Edit2Change
  end
  object Edit3: TEdit
    Left = 48
    Top = 140
    Width = 30
    Height = 21
    TabOrder = 15
    OnChange = Edit3Change
  end
  object Edit4: TEdit
    Left = 48
    Top = 188
    Width = 30
    Height = 21
    TabOrder = 16
    OnChange = Edit4Change
  end
  object Edit5: TEdit
    Left = 48
    Top = 236
    Width = 30
    Height = 21
    TabOrder = 17
    OnChange = Edit5Change
  end
  object Edit6: TEdit
    Left = 320
    Top = 52
    Width = 30
    Height = 21
    TabOrder = 18
    OnChange = Edit6Change
  end
  object Edit7: TEdit
    Left = 320
    Top = 100
    Width = 30
    Height = 21
    TabOrder = 19
    OnChange = Edit7Change
  end
  object Edit8: TEdit
    Left = 320
    Top = 148
    Width = 30
    Height = 21
    TabOrder = 20
    OnChange = Edit8Change
  end
  object Edit9: TEdit
    Left = 320
    Top = 196
    Width = 30
    Height = 21
    TabOrder = 21
    OnChange = Edit9Change
  end
  object Edit10: TEdit
    Left = 320
    Top = 244
    Width = 30
    Height = 21
    TabOrder = 22
    OnChange = Edit10Change
  end
  object cmdDefaults: TButton
    Left = 200
    Top = 272
    Width = 75
    Height = 25
    Caption = 'D&efaults'
    TabOrder = 23
  end
  object cmdSetAll: TButton
    Left = 120
    Top = 272
    Width = 75
    Height = 25
    Caption = '&Set'
    TabOrder = 24
    OnClick = cmdSetAllClick
  end
  object m_strWidths: TEdit
    Left = 88
    Top = 272
    Width = 25
    Height = 21
    TabOrder = 25
    Text = '1'
  end
  object cmdInnerColour: TButton
    Left = 120
    Top = 304
    Width = 75
    Height = 25
    Caption = 'Change &Inner'
    TabOrder = 26
    OnClick = cmdInnerColourClick
  end
  object cmdOuterColour: TButton
    Left = 120
    Top = 336
    Width = 75
    Height = 25
    Caption = 'Change &Outer'
    TabOrder = 27
    OnClick = cmdOuterColourClick
  end
  object Button1: TButton
    Left = 448
    Top = 304
    Width = 105
    Height = 25
    Caption = 'Apply to &Layer'
    TabOrder = 28
    OnClick = Button1Click
  end
  object m_strAlpha: TEdit
    Left = 320
    Top = 303
    Width = 30
    Height = 21
    TabOrder = 29
    OnChange = m_strAlphaChange
  end
  object alphaBar: TTrackBar
    Left = 266
    Top = 328
    Width = 92
    Height = 23
    Max = 255
    TabOrder = 30
    TickStyle = tsNone
    OnChange = alphaBarChange
  end
  object cd: TColorDialog
    Left = 400
    Top = 56
  end
end

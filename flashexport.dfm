object frmFlashExport: TfrmFlashExport
  Left = 239
  Top = 208
  BorderIcons = []
  BorderStyle = bsToolWindow
  Caption = 'Flash Export options'
  ClientHeight = 115
  ClientWidth = 370
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 45
    Height = 13
    Caption = 'Filename:'
  end
  object Label2: TLabel
    Left = 8
    Top = 40
    Width = 58
    Height = 13
    Caption = 'Soundtrack:'
  end
  object Label3: TLabel
    Left = 16
    Top = 67
    Width = 57
    Height = 13
    Caption = 'Move Type:'
    Visible = False
  end
  object Button1: TButton
    Left = 208
    Top = 80
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Export'
    Default = True
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 288
    Top = 80
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = Button2Click
  end
  object m_strFileNAme: TEdit
    Left = 72
    Top = 5
    Width = 265
    Height = 21
    TabOrder = 2
  end
  object cmdBrosw: TButton
    Left = 344
    Top = 5
    Width = 22
    Height = 21
    Caption = '...'
    TabOrder = 3
    OnClick = cmdBroswClick
  end
  object m_strSoundtrack: TEdit
    Left = 72
    Top = 37
    Width = 265
    Height = 21
    TabOrder = 4
  end
  object Button3: TButton
    Left = 344
    Top = 37
    Width = 22
    Height = 21
    Caption = '...'
    TabOrder = 5
    OnClick = Button3Click
  end
  object m_rbMovie: TRadioButton
    Left = 32
    Top = 88
    Width = 257
    Height = 17
    Caption = 'Flash Movie (vector format: smaller, scales well)'
    Checked = True
    TabOrder = 6
    TabStop = True
    Visible = False
  end
  object m_rbVideo: TRadioButton
    Left = 32
    Top = 112
    Width = 169
    Height = 17
    Caption = 'Flash Video (frame by frame)'
    TabOrder = 7
    Visible = False
  end
  object sd: TSaveDialog
    DefaultExt = 'swf'
    Filter = 'Flash (*.swf)|*.swf'
    Left = 304
  end
  object od: TOpenDialog
    DefaultExt = 'mp3'
    Filter = 'MP3 files (*.mp3)|*.mp3'
    Left = 248
    Top = 24
  end
end

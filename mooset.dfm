object frmMovieSettings: TfrmMovieSettings
  Left = 229
  Top = 250
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Noo Moovie Settings'
  ClientHeight = 76
  ClientWidth = 222
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 10
    Width = 89
    Height = 13
    Caption = 'Movie Dimensions:'
  end
  object Label2: TLabel
    Left = 160
    Top = 10
    Width = 11
    Height = 13
    Caption = 'by'
  end
  object cmdOK: TButton
    Left = 64
    Top = 48
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 2
    OnClick = cmdOKClick
  end
  object cmdCancel: TButton
    Left = 144
    Top = 48
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = cmdCancelClick
  end
  object m_strWidth: TEdit
    Left = 112
    Top = 8
    Width = 41
    Height = 21
    TabOrder = 0
    Text = '320'
  end
  object m_strHeight: TEdit
    Left = 176
    Top = 8
    Width = 41
    Height = 21
    TabOrder = 1
    Text = '240'
  end
end

object frmSubEdit: TfrmSubEdit
  Left = 238
  Top = 188
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Subtitle Properties'
  ClientHeight = 139
  ClientWidth = 252
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 0
    Top = 0
    Width = 82
    Height = 13
    Caption = 'Subtitle contents:'
    Transparent = True
  end
  object cmdOK: TButton
    Left = 96
    Top = 112
    Width = 75
    Height = 25
    Caption = '&OK'
    Default = True
    TabOrder = 1
    OnClick = cmdOKClick
  end
  object cmdCancel: TButton
    Left = 176
    Top = 112
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = cmdCancelClick
  end
  object memContent: TMemo
    Left = 0
    Top = 16
    Width = 249
    Height = 89
    ScrollBars = ssVertical
    TabOrder = 0
  end
end

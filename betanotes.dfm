object frmReadMe: TfrmReadMe
  Left = 217
  Top = 207
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Beta Notes:'
  ClientHeight = 195
  ClientWidth = 279
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object memContent: TMemo
    Left = 0
    Top = 0
    Width = 281
    Height = 161
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object cmdClose: TButton
    Left = 200
    Top = 168
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Close'
    TabOrder = 1
    OnClick = cmdCloseClick
  end
  object chkNoShow: TCheckBox
    Left = 8
    Top = 172
    Width = 177
    Height = 17
    Caption = 'Do not show this again'
    TabOrder = 2
  end
end

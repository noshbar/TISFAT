object frmNewPoly: TfrmNewPoly
  Left = 192
  Top = 260
  Width = 238
  Height = 95
  BorderIcons = []
  Caption = 'New polygon ...'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 11
    Width = 173
    Height = 13
    Caption = 'How many points (min:3 to max:100):'
  end
  object cmdOK: TButton
    Left = 72
    Top = 40
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 1
    OnClick = cmdOKClick
  end
  object cmdCancel: TButton
    Left = 152
    Top = 40
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = cmdCancelClick
  end
  object m_strPoints: TEdit
    Left = 192
    Top = 8
    Width = 33
    Height = 21
    TabOrder = 0
    Text = '4'
  end
end

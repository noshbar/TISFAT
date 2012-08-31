object frmGoto: TfrmGoto
  Left = 396
  Top = 318
  BorderIcons = []
  BorderStyle = bsToolWindow
  Caption = 'Go to...'
  ClientHeight = 61
  ClientWidth = 169
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 10
    Width = 96
    Height = 13
    Caption = 'Go to frame number:'
  end
  object m_strFrameNo: TEdit
    Left = 112
    Top = 8
    Width = 49
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 0
  end
  object cmdOK: TButton
    Left = 8
    Top = 32
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 1
    OnClick = cmdOKClick
  end
  object cmdCancel: TButton
    Left = 88
    Top = 32
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = cmdCancelClick
  end
end

object frmCAS: TfrmCAS
  Left = 230
  Top = 167
  BorderIcons = []
  BorderStyle = bsToolWindow
  Caption = 'Create A Scene'
  ClientHeight = 526
  ClientWidth = 165
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnMouseDown = FormMouseDown
  OnMouseMove = FormMouseMove
  OnMouseUp = FormMouseUp
  OnPaint = FormPaint
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 151
    Width = 24
    Height = 13
    Caption = 'Mass'
  end
  object Label2: TLabel
    Left = 8
    Top = 178
    Width = 26
    Height = 13
    Caption = 'State'
  end
  object Label3: TLabel
    Left = 8
    Top = 205
    Width = 35
    Height = 13
    Caption = 'Bouncy'
  end
  object Label4: TLabel
    Left = 8
    Top = 429
    Width = 35
    Height = 13
    Caption = 'Frames'
  end
  object Label5: TLabel
    Left = 8
    Top = 235
    Width = 75
    Height = 13
    Caption = 'Force on object'
  end
  object Label6: TLabel
    Left = 8
    Top = 448
    Width = 87
    Height = 13
    Caption = 'Preview animation'
  end
  object Label7: TLabel
    Left = 8
    Top = 373
    Width = 76
    Height = 13
    Caption = 'Collision options'
  end
  object progress: TProgressBar
    Left = 3
    Top = 427
    Width = 161
    Height = 17
    Step = 1
    TabOrder = 5
    Visible = False
  end
  object cmdClose: TButton
    Left = 3
    Top = 497
    Width = 75
    Height = 25
    Caption = '&Accept'
    Enabled = False
    ModalResult = 1
    TabOrder = 0
    OnClick = cmdCloseClick
  end
  object cmdCreate: TButton
    Left = 86
    Top = 423
    Width = 75
    Height = 25
    Caption = 'Create!'
    TabOrder = 1
    OnClick = cmdCreateClick
  end
  object m_lstObjects: TListView
    Left = 3
    Top = 8
    Width = 158
    Height = 137
    Columns = <>
    ReadOnly = True
    TabOrder = 2
    ViewStyle = vsList
    OnSelectItem = m_lstObjectsSelectItem
  end
  object m_strMass: TEdit
    Left = 48
    Top = 148
    Width = 51
    Height = 21
    TabOrder = 3
    Text = '1'
    OnChange = m_strMassChange
  end
  object cboState: TComboBox
    Left = 49
    Top = 175
    Width = 108
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 2
    TabOrder = 4
    Text = 'Moving'
    OnSelect = cboStateSelect
    Items.Strings = (
      'Static'
      'Sleeping'
      'Moving'
      'Static-ghost')
  end
  object trkBouncy: TTrackBar
    Left = 49
    Top = 202
    Width = 108
    Height = 28
    Max = 100
    TabOrder = 6
    TickStyle = tsNone
    OnChange = trkBouncyChange
  end
  object m_strFrameCount: TEdit
    Left = 48
    Top = 426
    Width = 35
    Height = 21
    TabOrder = 7
    Text = '500'
  end
  object cmdCancel: TButton
    Left = 86
    Top = 496
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 8
    OnClick = cmdCancelClick
  end
  object trkPreview: TTrackBar
    Left = 7
    Top = 466
    Width = 150
    Height = 26
    Enabled = False
    Max = 100
    PageSize = 10
    TabOrder = 9
    TickStyle = tsNone
    OnChange = trkPreviewChange
  end
  object lstCollisions: TComboBox
    Left = 3
    Top = 392
    Width = 134
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 10
    Text = 'Left wall'
    OnChange = lstCollisionsChange
    Items.Strings = (
      'Left wall'
      'Right wall'
      'Top wall'
      'Bottom wall'
      'Stick self-collisions')
  end
  object chkCollision: TCheckBox
    Left = 143
    Top = 394
    Width = 17
    Height = 17
    TabOrder = 11
    OnClick = chkCollisionClick
  end
end

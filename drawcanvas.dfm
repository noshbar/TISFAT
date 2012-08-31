object frmCanvas: TfrmCanvas
  Left = 239
  Top = 208
  AutoScroll = False
  BorderIcons = []
  Caption = 'Stage'
  ClientHeight = 239
  ClientWidth = 431
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnMouseDown = FormMouseDown
  OnMouseMove = FormMouseMove
  OnMouseUp = FormMouseUp
  OnMouseWheelDown = FormMouseWheelDown
  OnMouseWheelUp = FormMouseWheelUp
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object mnuActions: TPopupMenu
    Left = 48
    Top = 40
    object Move1: TMenuItem
      Caption = '&Move'
      OnClick = Move1Click
    end
    object SavePose1: TMenuItem
      Caption = 'Copy Pose'
      OnClick = SavePose1Click
    end
    object RestorePose1: TMenuItem
      Caption = 'Apply Pose'
      OnClick = RestorePose1Click
    end
    object Setposetopreviousframe1: TMenuItem
      Caption = 'Set pose to previous keyframe'
      OnClick = Setposetopreviousframe1Click
    end
    object Setposetonextkeyframe1: TMenuItem
      Caption = 'Set pose to next keyframe'
      OnClick = Setposetonextkeyframe1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object OpenMouth1: TMenuItem
      Caption = 'Change Mouth State'
      OnClick = OpenMouth1Click
    end
    object ChangeFaceDirection1: TMenuItem
      Caption = 'Change Face Direction'
      OnClick = ChangeFaceDirection1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object FlipHorizontally1: TMenuItem
      Caption = 'Flip Horizontally'
      OnClick = FlipHorizontally1Click
    end
    object FlipVertically1: TMenuItem
      Caption = 'Flip Vertically'
      OnClick = FlipVertically1Click
    end
    object FlipLegs1: TMenuItem
      Caption = 'Flip Legs'
      OnClick = FlipLegs1Click
    end
    object FlipArms1: TMenuItem
      Caption = 'Flip Arms'
      OnClick = FlipArms1Click
    end
  end
end

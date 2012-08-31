unit sticked;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, stickstuff,stickjoint, ExtCtrls, ComCtrls, ToolWin, ActnList,
  Menus,  jointprops, ImgList, StdCtrls, GDIPAPI, GDIPOBJ, stickrenderer;

{$i constants.inc}

type
  TfrmStickED = class(TForm)
    imgArrow: TImage;
    tbMain: TToolBar;
    ToolButton2: TToolButton;
    tbDummy: TToolButton;
    tbOpen: TToolButton;
    ToolButton1: TToolButton;
    tbIK: TToolButton;
    ToolButton3: TToolButton;
    tbSelectJoint: TToolButton;
    tbMoveJoint: TToolButton;
    tbAddJoint: TToolButton;
    tbDeleteJoint: TToolButton;
    ToolButton4: TToolButton;
    tbLockJoint: TToolButton;
    tbUnLockJoint: TToolButton;
    tbLockJointToParent: TToolButton;
    actors: TActionList;
    actUseIK: TAction;
    actNew: TAction;
    actSelectJoint: TAction;
    actMoveJoint: TAction;
    actAddJoint: TAction;
    actDeleteJoint: TAction;
    actLockJoint: TAction;
    actUnLockJoint: TAction;
    actLockJointToParent: TAction;
    actDisableJoint: TAction;
    actOpen: TAction;
    actSave: TAction;
    od: TOpenDialog;
    sd: TSaveDialog;
    tbOK: TToolButton;
    tbCancel: TToolButton;
    Timer1: TTimer;
    ToolButton6: TToolButton;
    ilMain: TImageList;
    tbSave: TToolButton;
    actDrawStraight: TAction;
    actDrawCurvy: TAction;
    m_status: TStatusBar;
    ToolButton5: TToolButton;
    btnStraight: TToolButton;
    btnCurvey: TToolButton;
    strAlpha: TEdit;
    alphaBar: TTrackBar;
    cboAdjust: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actUseIKExecute(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
    procedure actSelectJointExecute(Sender: TObject);
    procedure actMoveJointExecute(Sender: TObject);
    procedure actAddJointExecute(Sender: TObject);
    procedure actDeleteJointExecute(Sender: TObject);
    procedure actLockJointExecute(Sender: TObject);
    procedure actUnLockJointExecute(Sender: TObject);
    procedure actLockJointToParentExecute(Sender: TObject);
    procedure actDisableJointExecute(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure tbOKClick(Sender: TObject);
    procedure tbCancelClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure actDrawStraightExecute(Sender: TObject);
    procedure actDrawCurvyExecute(Sender: TObject);
    procedure btnStraightClick(Sender: TObject);
    procedure btnCurveyClick(Sender: TObject);
    procedure alphaBarChange(Sender: TObject);
    procedure strAlphaChange(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cboAdjustChange(Sender: TObject);
  private
    { Private declarations }
    m_bUseIK : boolean;
    m_nLastX, m_nLastY : integer;
    m_nBackupState : integer;
    m_nMode : integer;
    m_man : TLimbList;
    m_pTempObject : TLimbList;
    m_nDown : integer;
    m_pJoint : TJoint;
    m_pMainJoint : TJoint;
    m_pSelectedLimb, m_pSelectedLimbParent : TJoint;
    m_bJointEdit : boolean;
    m_bFirstTimer : boolean;
    m_lClearColour : longword;
    m_strForceSaveName : string;
    m_sAlpha : single;
    m_sTense : single;
    m_pBitmap : TGPBitmap;
    m_pCanvas : TGPGraphics;
    m_pRenderer : TStickRenderer;
    m_nMoveX, m_nMoveY : integer;

    procedure AllUp;
    procedure Draw;
    procedure StopFlicker(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
  public
    { Public declarations }
    AddStick : boolean;
    frmJointProps: TfrmJointProps;

    procedure Clear;
    procedure New;
    procedure SaveStick(strFileName : string);
    procedure LoadStick(strFileName : string);
    procedure ShowJointDetail(pJoint : TJoint);
    procedure RecalcAll();
    procedure UpdateJointButtons;
    procedure UpdateMe;

    property Mode : integer read m_nMode write m_nMode;
    property IK : boolean read m_bUseIK write m_bUseIK;
    property ActiveJoint : TJoint read m_pJoint;
    property Stick : TLimbList read m_man;
    property AllowJointEditing : boolean read m_bJointEdit write m_bJointEdit;
    property ForceSaveName : string read m_strForceSaveName write m_strForceSaveName;
    property TempObject : TLimbList read m_pTempObject write m_pTempObject;
    property MoveX : integer read m_nMoveX;
    property MoveY : integer read m_nMoveY;
  end;

implementation

uses main, math;

{$R *.dfm}

procedure TfrmStickED.RecalcAll();
begin
   m_pMainJoint.CalcLength();
end;

procedure TfrmStickED.New();
begin
   m_man := TLimbList.Create;
   m_pTempObject := nil;
   m_man.CalculateIK := FALSE;
   m_pJoint := m_man.AddJoint(0,0);
   m_pMainJoint := m_pJoint;
   m_pMainJoint.Name := 'Main Joint';
   m_man.Move(ClientWidth div 2, ClientHeight div 2);

   m_nDown := 0;
   m_nBackupState := C_STATE_NORMAL;
   m_bUseIK := FALSE;
   AllUp();
   m_nMode := C_MODE_ADD_JOINT;
   m_pSelectedLimb := nil;
   m_pSelectedLimbParent := nil;
   m_nMoveX := 0;
   m_nMoveY := 0;

   Resize;
end;

procedure TfrmStickED.FormCreate(Sender: TObject);
begin

   m_bJointEdit := TRUE;
   Width := screen.Width div 2;
   Height := screen.Height div 2;
   Top := 10;
   Left := 10;
   m_bFirstTimer := true;

   inherited;

   m_lClearColour := RGB(175,175,255);
   New();
   AddStick := FALSE;

   imgArrow.Visible := FALSE;

   frmJointProps := TfrmJointProps.Create(self);
   frmJointProps.Hide;
end;

procedure TfrmStickED.Clear;
begin
   frmJointProps.Free;
   m_man.Destroy;
   m_man := nil;
end;

procedure TfrmStickED.FormDestroy(Sender: TObject);
begin
   if (m_strForceSaveName <> '') then
   begin
      SaveStick(m_strForceSaveName);
   end;
   Clear();
   m_pRenderer.Free;
   m_pCanvas.Free;
   m_pBitmap.Free;
   inherited;
end;

procedure TfrmStickED.StopFlicker(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

procedure TfrmStickED.ShowJointDetail(pJoint : TJoint);
var
   f : integer;
   slNames : TStringList;
begin
   frmJointProps.m_pMan := m_man;
   frmJointProps.m_pTempObject := m_pTempObject;
   
   if (pJoint = nil) then
   begin
      frmJointProps.Hide;
      exit;
   end;

   slNAmes := TStringList.Create;
   slNAmes.Add('Line');
   slNAmes.Add('Rectangle');
   slNAmes.Add('Circle');
   m_man.GetBitmapNames(slNames);
   frmJointProps.cboDrawAs.Items.Clear;
   for f := 0 to slNames.Count-1 do
      frmJointProps.cboDrawAs.Items.Add(slNames[f]);
   slNames.Destroy;
      

   frmJointProps.SelectedJoint := pJoint;
   frmJointProps.lblColour.Color := pJoint.Colour;
   frmJointProps.lblFillColour.Color := pJoint.FillColour;
   frmJointProps.chkClear.Checked := not pJoint.Fill;
   frmJointProps.chkDrawLine.Checked := not pJoint.ShowStick;

   if (pJoint.CurrentBitmap = -1) then
   begin
      frmJointProps.cboDrawAs.ItemIndex := pJoint.DrawAs;
   end else
   begin
      frmJointProps.cboDrawAs.ItemIndex := 3 + pJoint.CurrentBitmap;
   end;

   if (pJoint.DrawAs <> C_DRAW_AS_LINE) then
      frmJointProps.m_strDrawWidth.Text := inttostr(pJoint.DrawWidth);

   if (m_man.DrawMode = C_STICK_DRAWMODE_STRAIGHT) then
      frmJointProps.m_strWidth.Text := inttostr(pJoint.Width)
   else
      frmJointProps.m_strWidth.Text := inttostr(m_man.CurveWidth);

   frmJointProps.Show;
end;

procedure TfrmStickED.strAlphaChange(Sender: TObject);
begin
   if (strAlpha.Text = '') then
      exit;

   if (cboAdjust.ItemIndex = 0) then
   begin
      m_sAlpha := strtofloat(strAlpha.Text);
      m_man.Alpha := m_sAlpha / 100;
   end;
   if (cboAdjust.ItemIndex = 1) then
   begin
      m_sTense := strtofloat(strAlpha.Text);
      m_man.Tension := m_sTense / 100;
   end;
end;

procedure TfrmStickED.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   pJoint : TJoint;
begin
   SetCapture(HANDLE);

   pJoint := m_man.GetJointAt(x,y, 6);
   m_pSelectedLimb := nil;
   m_pSelectedLimbParent := nil;

   m_nDown := 0;
   if (m_nMode = C_MODE_DELETE_JOINT) then
   begin
      if (nil = pJoint) then exit;
      pJoint.Destroy;
      repaint;
      exit;
   end;

   if (Button = mbRight) then     // move the stick around
   begin
      m_nLastX := x;
      m_nLastY := Y;
      m_nDown := 2;
      exit;
   end;

   // find an existing limb
   if (pJoint = nil) then
   begin
      if (m_nMode = C_MODE_SELECT_JOINT) or (m_nMode = C_MODE_MOVE_JOINT) then
      begin
         m_pSelectedLimb := m_man.GetJointCovering(x,y, 6, m_pSelectedLimbParent);
         ShowJointDetail(m_pSelectedLimb);
         paint;
         exit;  //EXIT
      end;
   end;

   //create a new joint
   if (pJoint = nil) then
   begin
      if (m_pJoint <> nil) and (m_nMode = C_MODE_ADD_JOINT) and (Button = mbLeft) then
      begin
         m_nBackupState := C_STATE_NORMAL;
         pJoint := m_pJoint.AddChild(X,Y);
         m_pJoint := pJoint;
         m_pJoint.State := C_STATE_SELECTED;
         m_nDown := 1;
         m_man.JointCount := m_man.JointCount+1;
         ShowJointDetail(pJoint);
         paint;
         exit;  //EXIT
      end;
   end else
   begin
      //select an existing joint
      m_pJoint := pJoint;
      ShowJointDetail(pJoint);
      if (ssCtrl in Shift) then
      begin
         if (m_pJoint.State <> C_STATE_LOCKED)
            then m_pJoint.State := C_STATE_LOCKED
            else m_pJoint.State := C_STATE_NORMAL;
      end else
      if (m_nMode = C_MODE_LOCK_JOINT) then
      begin
         m_pJoint.State := C_STATE_LOCKED;
      end else
      if (m_nMode = C_MODE_UNLOCK_JOINT) then
      begin
         m_pJoint.State := C_STATE_NORMAL;
      end else
      if (m_nMode = C_MODE_LOCK_JOINT_TO_PARENT) then
      begin
         m_pJoint.State := C_STATE_ADJUST_TO_PARENT;
      end else
      if (m_nMode = C_MODE_DISABLE_JOINT) then
      begin
         m_pJoint.State := C_STATE_ADJUST_TO_PARENT_LOCKED;
      end else
      if (ssShift in Shift) then
      begin
         if (m_pJoint.State <> C_STATE_ADJUST_TO_PARENT)
            then m_pJoint.State := C_STATE_ADJUST_TO_PARENT
            else m_pJoint.State := C_STATE_NORMAL;
      end else
      begin
         if (Button = mbLeft) then m_nDown := 1;
         if (Button = mbRight) then m_nDown := 2;
         m_nLastX := X;
         m_nLastY := Y;
      end;
      ///ATTN! HERE MIGHT BE MESSUP
      m_nBackupState := m_pJoint.State;
      m_pJoint.State := C_STATE_SELECTED;
   end;

   Paint;
end;

procedure TfrmStickED.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
   xDiff,yDiff : integer;
begin
   if (m_nDown = 1) then
   begin
      if (m_nMode <> C_MODE_SELECT_JOINT) then  //any other command except selection can move a point
      begin
         if (m_pJoint <> nil) then
         begin
            if (m_bUseIK) then
            begin
               m_pJoint.SetPos(x,y);
            end else
            begin
               m_pJoint.SetPosAbs(x,y);
               m_pJoint.CalcLength();
            end;
            Paint;
         end;
      end;
   end else
   if (m_nDown = 2) then
   begin
      xDiff := X - m_nLastX;
      yDiff := Y - m_nLastY;
      m_nMoveX := m_nMoveX + xDiff;
      m_nMoveY := m_nMoveY + yDiff;
      m_nLastX := X;
      m_nLastY := Y;
      m_man.Move(xDiff,yDiff);
      Paint;
   end else
   begin
      {if (m_nMode <> C_MODE_SELECT_JOINT) and (m_nMode <> C_MODE_MOVE_JOINT) then exit;

      pJoint := m_man.GetJointAt(x,y, 6);
      if (pJoint <> nil) then
      begin
         ShowJointDetail(pJoint);
         nTempState := pJoint.State;
         pJoint.State := C_STATE_SELECTED;
         Paint;
         pJoint.State := nTempState;
      end else
      begin
         pParent := nil;
         pJoint := m_man.GetJointCovering(x,y, 6, pParent);
         if (pJoint <> nil) then
         begin
            nTempState := pJoint.State;
            ShowJointDetail(pJoint);
            if (pParent <> nil) then
            begin
               pTempParent := m_pSelectedLimbParent;
               pTemp := m_pSelectedLimb;
               m_pSelectedLimbParent := pParent;
               m_pSelectedLimb := pJoint;
               Paint;
               m_pSelectedLimbParent := pTempParent;
               m_pSelectedLimb := pTemp;
            end else
            begin
               pJoint.State := C_STATE_SELECTED;
               Paint;
            end;
            pJoint.State := nTempState;
         end else
         begin
            if (m_pJoint <> nil) then
            begin
               nTempState := m_pJoint.State;
               m_pJoint.State := C_STATE_SELECTED;
               ShowJointDetail(m_pJoint);
               Paint;
               m_pJoint.State := nTempState;
            end else
            if (m_pSelectedLimb <> nil) then
            begin
               ShowJointDetail(m_pSelectedLimb);
               Paint;
            end else
            begin
               ShowJointDetail(nil);
               Paint;
            end;
         end;
      end; }
   end;
end;

procedure TfrmStickED.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if (m_pJoint <> nil) then
   begin
      m_pJoint.State := m_nBackupState;
      m_nBackupState := m_pJoint.State;
   end;
   UpdateJointButtons();
   m_nDown := 0;
   ReleaseCapture;
end;

procedure TfrmStickED.SaveStick(strFileName : string);
var
   fil : TFileStream;
begin
   fil := TFileStream.Create(strFileName, fmOpenWrite or fmCreate);
   m_man.Write(fil);
   fil.Destroy;
end;

procedure TfrmStickED.LoadStick(strFileName : string);
var
   fil : TFileStream;
begin
   New();
   fil := TFileStream.Create(strFileName, fmOpenRead);
   m_man.Read(fil);
   fil.Destroy;
end;

procedure TfrmStickED.UpdateJointButtons;
begin
   tbDummy.Enabled := m_bJointEdit;
   tbOpen.Enabled := m_bJointEdit;
   tbSave.Enabled := m_bJointEdit;

   if (m_pJoint <> nil) then
   begin
      tbLockJoint.Enabled := m_bJointEdit;
      tbUnLockJoint.Enabled := m_bJointEdit;
      tbLockJointToParent.Enabled := m_bJointEdit;
      //tbDisableJoint.Enabled := m_bJointEdit;
      tbDeleteJoint.Enabled := m_bJointEdit;
   end else
   begin
      tbLockJoint.Enabled := FALSE;
      tbUnLockJoint.Enabled := FALSE;
      tbLockJointToParent.Enabled := FALSE;
      //tbDisableJoint.Enabled := FALSE;
   end;
end;

procedure TfrmStickED.FormActivate(Sender: TObject);
begin
   tbAddJoint.Enabled := m_bJointEdit;
   tbDeleteJoint.Enabled := m_bJointEdit;
   tbSelectJoint.Enabled := TRUE;
   tbIK.Enabled := TRUE;
   tbSave.Enabled := TRUE;
   tbMoveJoint.Enabled := TRUE;
   tbIK.Down := m_bUseIK;
   UpdateJointButtons();

   if m_nMode = C_MODE_SELECT_JOINT then tbSelectJoint.Click;
   if m_nMode = C_MODE_MOVE_JOINT then actMoveJoint.Execute;
   if m_nMode = C_MODE_ADD_JOINT then tbAddJoint.Click;
   if m_nMode = C_MODE_DELETE_JOINT then tbDeleteJoint.Click;
   if m_nMode = C_MODE_LOCK_JOINT then tbLockJoint.Click;
//   if m_nMode = C_MODE_DISABLE_JOINT then tbDisableJoint.Click;
   if m_nMode = C_MODE_UNLOCK_JOINT then tbUnLockJoint.Click;
   if m_nMode = C_MODE_LOCK_JOINT_TO_PARENT then tbLockJointToParent.Click;
end;

procedure TfrmStickED.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   m_pJoint := nil;
   UpdateJointButtons;
   Action := caFree;
end;

procedure TfrmStickED.AllUp;
begin
   tbSelectJoint.Down := FALSE;
   tbAddJoint.Down := FALSE;
   tbDeleteJoint.Down := FALSE;
   tbLockJoint.Down := FALSE;
   tbUnLockJoint.Down := FALSE;
   tbLockJointToParent.Down := FALSE;
//   tbDisableJoint.Down := FALSE;
   tbIK.Down := IK;
   tbMoveJoint.Down := FALSE;
end;

procedure TfrmStickED.alphaBarChange(Sender: TObject);
begin
   strAlpha.Text := inttostr(alphaBar.Position);
   if (cboAdjust.ItemIndex = 0) then
   begin
      m_sAlpha := alphaBAr.Position / 100;
      m_man.Alpha := alphaBAr.Position / 100;
   end;
   if (cboAdjust.ItemIndex = 1) then
   begin
      m_sTense := alphaBAr.Position / 100;
      m_man.Tension := alphaBAr.Position / 100;
   end;
end;

procedure TfrmStickED.btnCurveyClick(Sender: TObject);
begin
   m_man.DrawMode := C_STICK_DRAWMODE_CURVY;
   alphaBar.Enabled := true;
end;

procedure TfrmStickED.btnStraightClick(Sender: TObject);
begin
   m_man.DrawMode := C_STICK_DRAWMODE_STRAIGHT;
   if (cboAdjust.ItemIndex = 1) then
      alphaBar.Enabled := false;
end;

procedure TfrmStickED.cboAdjustChange(Sender: TObject);
begin
   alphaBar.Enabled := true;
   if (cboAdjust.ItemIndex = 0) then
   begin
      strAlpha.Text := floattostr(100 * m_man.Alpha);
      alphaBar.Position := round(100 * m_man.Alpha);
   end;
   if (cboAdjust.ItemIndex = 1) then
   begin
      strAlpha.Text := floattostr(100 * m_man.Tension);
      alphaBar.Position := round(100 * m_man.Tension);
      alphaBar.Enabled := m_man.DrawMode = C_STICK_DRAWMODE_CURVY;
   end;
end;

procedure TfrmStickED.actUseIKExecute(Sender: TObject);
begin
   IK := not IK;
   if (IK) then
   begin
      RecalcAll();
   end;
   tbIK.Down := IK;
end;

procedure TfrmStickED.actNewExecute(Sender: TObject);
begin
   {Clear();
   New();
   RePaint();} //TODO! FIXME
end;

procedure TfrmStickED.actSelectJointExecute(Sender: TObject);
begin
   m_nMode := C_MODE_SELECT_JOINT;
   AllUp;
   tbSelectJoint.Down := TRUE;
end;

procedure TfrmStickED.actMoveJointExecute(Sender: TObject);
begin
   m_nMode := C_MODE_MOVE_JOINT;
   AllUp;
   tbMoveJoint.Down := TRUE;
end;

procedure TfrmStickED.actAddJointExecute(Sender: TObject);
begin
   m_nMode := C_MODE_ADD_JOINT;
   AllUp;
   tbAddJoint.Down := TRUE;
end;

procedure TfrmStickED.actDeleteJointExecute(Sender: TObject);
begin
   m_nMode := C_MODE_DELETE_JOINT;
   AllUp;
   tbDeleteJoint.Down := TRUE;
end;

procedure TfrmStickED.actLockJointExecute(Sender: TObject);
begin
   m_nMode := C_MODE_LOCK_JOINT;
   AllUp;
   tbLockJoint.Down := TRUE;
end;

procedure TfrmStickED.actUnLockJointExecute(Sender: TObject);
begin
   m_nMode := C_MODE_UNLOCK_JOINT;
   AllUp;
   tbUnLockJoint.Down := TRUE;
end;

procedure TfrmStickED.actLockJointToParentExecute(Sender: TObject);
begin
   m_nMode := C_MODE_LOCK_JOINT_TO_PARENT;
   AllUp;
   tbLockJointToParent.Down := TRUE;
end;

procedure TfrmStickED.actDisableJointExecute(Sender: TObject);
begin
   m_nMode := C_MODE_DISABLE_JOINT;
   AllUp;
//   tbDisableJoint.Down := TRUE;
end;

procedure TfrmStickED.actOpenExecute(Sender: TObject);
begin
   od.Filter := 'Stick Figure Files (*.sff)|*.sff';
   if (od.Execute) then
   begin
      New();
      LoadStick(od.FileName);
      AllUp();
      tbIK.Down := TRUE;
      tbMoveJoint.Down := TRUE;
      Mode := C_MODE_MOVE_JOINT;
      IK := TRUE;
      paint;
   end;
end;

procedure TfrmStickED.actSaveExecute(Sender: TObject);
begin
   if (sd.Execute) then
   begin
      SaveStick(sd.FileName);
   end;
end;

procedure TfrmStickED.FormKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
   if (key = VK_DELETE) then
   begin
      actDeleteJoint.Execute;   
   end;
end;

procedure TfrmStickED.tbOKClick(Sender: TObject);
begin
   AddStick := TRUE;
   Close;
end;

procedure TfrmStickED.tbCancelClick(Sender: TObject);
begin
   AddStick := FALSE;
   Close;
end;

procedure TfrmStickED.Draw();
var
   dAngle : double;
   x,y : integer;
begin
   m_pRenderer.DrawRect(clientwidth div 2,clientheight div 2,clientwidth,clientheight,175,175,255,175,175,255, 0, 1, 0);

   if (m_man = nil) then exit;

   m_pRenderer.DrawControlPoints := true;
   m_pRenderer.DrawStick(m_man, 0, round(m_man.Alpha * 255));

   if (m_pSelectedLimb <> nil) and (m_pSelectedLimbParent <> nil) then
   begin
      dAngle := 180 * (1 + ArcTan2(m_pSelectedLimbParent.y-m_pSelectedLimb.Y, m_pSelectedLimbParent.x-m_pSelectedLimb.x) / PI);
      if m_pSelectedLimb.x < m_pSelectedLimbParent.X then
      begin
         x := m_pSelectedLimb.x + ((m_pSelectedLimbParent.x - m_pSelectedLimb.x) div 2);
         y := m_pSelectedLimb.y + ((m_pSelectedLimbParent.y - m_pSelectedLimb.y) div 2);
         //DrawImage(x, y, m_pArrow.GetWidth(), m_pArrow.GetHeight(), 0.5, (dAngle+270), m_pArrow);
         m_pRenderer.DrawLine(x,y,10,0, 0,0,0, 1, 1.0, (dAngle+270));
      end else
      begin
         x := m_pSelectedLimbParent.x + ((m_pSelectedLimb.x - m_pSelectedLimbParent.x) div 2);
         y := m_pSelectedLimbParent.y + ((m_pSelectedLimb.y - m_pSelectedLimbParent.y) div 2);
         //DrawImage(x, y, m_pArrow.GetWidth(), m_pArrow.GetHeight(), 0.5, (dAngle+90), m_pArrow);
         m_pRenderer.DrawLine(x,y,10,0, 0,0,0, 1, 1.0, (dAngle+90));
      end;
   end;
end;

procedure TfrmStickED.FormPaint(Sender: TObject);
var
   pScreen : TGPGraphics;
begin
   if m_pBitmap = nil then exit;

   Draw();
   pScreen := TGPGraphics.Create(canvas.handle);
   pScreen.DrawImage(m_pBitmap, 0,0, clientwidth, clientheight);
   pScreen.Free;
end;

procedure TfrmStickED.FormResize(Sender: TObject);
begin
   m_pRenderer.Free;
   m_pBitmap.Free;
   m_pCanvas.Free;
   m_pBitmap := TGPBitmap.Create(clientwidth, clientheight);
   m_pCanvas := TGPGraphics.Create(m_pBitmap);
   m_pCanvas.SetSmoothingMode(SmoothingModeAntiAlias);
   m_pRenderer := TStickRenderer.Create(m_pCanvas);
   //Paint;
end;

procedure TfrmStickED.FormShow(Sender: TObject);
begin
   Paint;
end;

procedure TfrmStickED.Timer1Timer(Sender: TObject);
begin
   if (m_bFirstTimer) then
   begin
      //timer1.enabled := false;
      frmJointProps.Left := Left + Width - frmJointProps.Width - 10;
      frmJointProps.Top  := Top + 50;
      m_bFirstTimer := false;
   end else
   begin
      RePaint;
   end;
end;

procedure TfrmStickED.UpdateMe;
begin
  repaint;
end;


procedure TfrmStickED.actDrawStraightExecute(Sender: TObject);
begin
   m_man.DrawMode := C_STICK_DRAWMODE_STRAIGHT;
   repaint;
end;

procedure TfrmStickED.actDrawCurvyExecute(Sender: TObject);
begin
   m_man.DrawMode := C_STICK_DRAWMODE_CURVY;
   repaint;
end;

end.

unit sticked2;

interface

uses
  {$IFDEF FPC} LCLIntf, LResources, {$ENDIF} Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, stickstuff,stickjoint, ExtCtrls, ComCtrls, ToolWin, ActnList,
  Menus,  jointprops, ImgList, StdCtrls, GDIPAPI, GDIPOBJ, stickrenderer;

{$i constants.inc}

type
  TfrmStickED2 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    m_bUseIK : boolean;
    m_nLastX, m_nLastY : integer;
    m_nBackupState : integer;
    m_nMode : integer;
    m_man : TLimbList;
    m_nDown : integer;
    m_pJoint : TJoint;
    m_pMainJoint : TJoint;
    m_pSelectedLimb, m_pSelectedLimbParent : TJoint;
    m_bJointEdit : boolean;
    m_bFirstTimer : boolean;
    m_lClearColour : longword;
    m_strForceSaveName : string;
    m_nAlpha : integer;
    m_pBitmap : TGPBitmap;
    m_pCanvas : TGPGraphics;
    m_pRenderer : TStickRenderer;

    procedure AllUp;
    procedure Draw;
    procedure StopFlicker(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
  public
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
  end;

implementation

{$R *.dfm}

uses main, math;

{$IFDEF FPC}
{$ELSE}
   {$R *.dfm}
{$ENDIF}

procedure TfrmStickED2.RecalcAll();
begin
   m_pMainJoint.CalcLength();
end;

procedure TfrmStickED2.New();
begin
   m_man := TLimbList.Create;
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

   Resize;
end;

procedure TfrmStickED2.Clear;
begin
   frmJointProps.Free;
   m_man.Destroy;
   m_man := nil;
end;

procedure TfrmStickED2.StopFlicker(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

procedure TfrmStickED2.ShowJointDetail(pJoint : TJoint);
var
   f : integer;
   slNames : TStringList;
begin
   frmJointProps.m_pMan := m_man;

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
      

   frmJointProps.Show;

   frmJointProps.SelectedJoint := pJoint;
   frmJointProps.lblColour.Color := pJoint.Colour;
   frmJointProps.lblFillColour.Color := pJoint.FillColour;
   frmJointProps.chkClear.Checked := not pJoint.Fill;

   if (pJoint.DrawAs <> C_DRAW_AS_BITMAP) then
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

end;

{procedure TfrmStickED2.strAlphaChange(Sender: TObject);
begin
   if (strAlpha.Text <> '') then
   begin
      m_nAlpha := strtoint(strAlpha.Text);
      m_man.Alpha := m_nAlpha / 255;
   end;
end; }

procedure TfrmStickED2.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
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

procedure TfrmStickED2.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
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
      m_nLastX := X;
      m_nLastY := Y;
      m_man.Move(xDiff,yDiff);
      Paint;
   end;
end;

procedure TfrmStickED2.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
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

procedure TfrmStickED2.SaveStick(strFileName : string);
var
   fil : TFileStream;
begin
   fil := TFileStream.Create(strFileName, fmOpenWrite or fmCreate);
   m_man.Write(fil);
   fil.Destroy;
end;

procedure TfrmStickED2.LoadStick(strFileName : string);
var
   fil : TFileStream;
begin
   New();
   fil := TFileStream.Create(strFileName, fmOpenRead);
   m_man.Read(fil);
   fil.Destroy;
end;

procedure TfrmStickED2.UpdateJointButtons;
begin
   {tbDummy.Enabled := m_bJointEdit;
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
   end; }
end;

procedure TfrmStickED2.FormActivate(Sender: TObject);
begin
   {tbAddJoint.Enabled := m_bJointEdit;
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
   if m_nMode = C_MODE_LOCK_JOINT_TO_PARENT then tbLockJointToParent.Click;}
end;

procedure TfrmStickED2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   m_pJoint := nil;
   UpdateJointButtons;
   Action := caFree;
end;

procedure TfrmStickED2.AllUp;
begin
   {tbSelectJoint.Down := FALSE;
   tbAddJoint.Down := FALSE;
   tbDeleteJoint.Down := FALSE;
   tbLockJoint.Down := FALSE;
   tbUnLockJoint.Down := FALSE;
   tbLockJointToParent.Down := FALSE;
//   tbDisableJoint.Down := FALSE;
   tbIK.Down := IK;
   tbMoveJoint.Down := FALSE;}
end;

{procedure TfrmStickED2.alphaBarChange(Sender: TObject);
begin
   m_nAlpha := alphaBAr.Position;
   strAlpha.Text := inttostr(m_nAlpha);
   m_man.Alpha := m_nAlpha / 255;
end;

procedure TfrmStickED2.btnCurveyClick(Sender: TObject);
begin
   m_man.DrawMode := C_STICK_DRAWMODE_CURVY;
end;

procedure TfrmStickED2.btnStraightClick(Sender: TObject);
begin
   //d/ make preview render or something
   m_man.DrawMode := C_STICK_DRAWMODE_STRAIGHT;
end;

procedure TfrmStickED2.actUseIKExecute(Sender: TObject);
begin
   IK := not IK;
   if (IK) then
   begin
      RecalcAll();
   end;
   tbIK.Down := IK;
end;  }

(*procedure TfrmStickED2.actNewExecute(Sender: TObject);
begin
   {Clear();
   New();
   RePaint();} //TODO! FIXME
end;

procedure TfrmStickED2.actSelectJointExecute(Sender: TObject);
begin
   m_nMode := C_MODE_SELECT_JOINT;
   AllUp;
   tbSelectJoint.Down := TRUE;
end;

procedure TfrmStickED2.actMoveJointExecute(Sender: TObject);
begin
   m_nMode := C_MODE_MOVE_JOINT;
   AllUp;
   tbMoveJoint.Down := TRUE;
end;

procedure TfrmStickED2.actAddJointExecute(Sender: TObject);
begin
   m_nMode := C_MODE_ADD_JOINT;
   AllUp;
   tbAddJoint.Down := TRUE;
end;

procedure TfrmStickED2.actDeleteJointExecute(Sender: TObject);
begin
   m_nMode := C_MODE_DELETE_JOINT;
   AllUp;
   tbDeleteJoint.Down := TRUE;
end;

procedure TfrmStickED2.actLockJointExecute(Sender: TObject);
begin
   m_nMode := C_MODE_LOCK_JOINT;
   AllUp;
   tbLockJoint.Down := TRUE;
end;

procedure TfrmStickED2.actUnLockJointExecute(Sender: TObject);
begin
   m_nMode := C_MODE_UNLOCK_JOINT;
   AllUp;
   tbUnLockJoint.Down := TRUE;
end;

procedure TfrmStickED2.actLockJointToParentExecute(Sender: TObject);
begin
   m_nMode := C_MODE_LOCK_JOINT_TO_PARENT;
   AllUp;
   tbLockJointToParent.Down := TRUE;
end;

procedure TfrmStickED2.actDisableJointExecute(Sender: TObject);
begin
   m_nMode := C_MODE_DISABLE_JOINT;
   AllUp;
//   tbDisableJoint.Down := TRUE;
end;

procedure TfrmStickED2.actOpenExecute(Sender: TObject);
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

procedure TfrmStickED2.actSaveExecute(Sender: TObject);
begin
   if (sd.Execute) then
   begin
      SaveStick(sd.FileName);
   end;
end;

procedure TfrmStickED2.tbOKClick(Sender: TObject);
begin
   AddStick := TRUE;
   Close;
end;

procedure TfrmStickED2.tbCancelClick(Sender: TObject);
begin
   AddStick := FALSE;
   Close;
end;

*)

procedure TfrmStickED2.FormKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
   if (key = VK_DELETE) then
   begin
      actDeleteJoint.Execute;
   end;
end;

procedure TfrmStickED2.Draw();
var
   dAngle : double;
   x,y : integer;
begin
   m_pCanvas.Clear(clWhite);
   
   if (m_man = nil) then exit;

   m_pRenderer.DrawStick(0,0, m_man, 0, 255);

   if (m_pSelectedLimb <> nil) and (m_pSelectedLimbParent <> nil) then
   begin
      dAngle := 180 * (1 + ArcTan2(m_pSelectedLimbParent.y-m_pSelectedLimb.Y, m_pSelectedLimbParent.x-m_pSelectedLimb.x) / PI);
      if m_pSelectedLimb.x < m_pSelectedLimbParent.X then
      begin
         x := m_pSelectedLimb.x + ((m_pSelectedLimbParent.x - m_pSelectedLimb.x) div 2);
         y := m_pSelectedLimb.y + ((m_pSelectedLimbParent.y - m_pSelectedLimb.y) div 2);
         //DrawImage(x, y, m_pArrow.GetWidth(), m_pArrow.GetHeight(), 0.5, (dAngle+270), m_pArrow);
         //m_man.Canvas.MoveTo(x,y);
         //m_man.Canvas.LineTo();
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

procedure TfrmStickED2.FormCreate(Sender: TObject);
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

   frmJointProps := TfrmJointProps.Create(self);
   frmJointProps.Hide;
end;

procedure TfrmStickED2.FormDestroy(Sender: TObject);
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

procedure TfrmStickED2.FormPaint(Sender: TObject);
var
   pScreen : TGPGraphics;
begin
   if m_pBitmap = nil then exit;

   Draw();
   pScreen := TGPGraphics.Create(canvas.handle);
   pScreen.DrawImage(m_pBitmap, 0,0, clientwidth, clientheight);
   pScreen.Free;
end;

procedure TfrmStickED2.FormResize(Sender: TObject);
begin
   m_pRenderer.Free;
   m_pBitmap.Free;
   m_pCanvas.Free;
   m_pBitmap := TGPBitmap.Create(clientwidth, clientheight);
   m_pCanvas := TGPGraphics.Create(m_pBitmap);
   m_pRenderer := TStickRenderer.Create(m_pCanvas);
   //Paint;
end;

procedure TfrmStickED2.UpdateMe;
begin
  repaint;
end;

end.

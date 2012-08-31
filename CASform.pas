unit CASform;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, math,
  chipmunkimport, physics, movieobject,
  ExtCtrls, ComCtrls,
  GDIPAPI, GDIPOBJ, GDIPUTIL;

const
   C_STATE_STATIC = 0;
   C_STATE_SLEEPING = 1;
   C_STATE_MOVING = 2;
   C_STATE_PASSTHROUGH = 3;
   C_FORCE_MULTIPLIER = 2;

type
   TForceLabel = class(TObject)
      m_nCenterX, m_nCenterY : integer;
      m_nX, m_nY : integer;
   end;

type
  TfrmCAS = class(TForm)
    cmdClose: TButton;
    cmdCreate: TButton;
    m_lstObjects: TListView;
    m_strMass: TEdit;
    Label1: TLabel;
    cboState: TComboBox;
    Label2: TLabel;
    progress: TProgressBar;
    trkBouncy: TTrackBar;
    Label3: TLabel;
    m_strFrameCount: TEdit;
    Label4: TLabel;
    cmdCancel: TButton;
    trkPreview: TTrackBar;
    Label5: TLabel;
    Label6: TLabel;
    lstCollisions: TComboBox;
    Label7: TLabel;
    chkCollision: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure cmdCloseClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cmdCreateClick(Sender: TObject);
    procedure m_lstObjectsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure cboStateSelect(Sender: TObject);
    procedure m_strMassChange(Sender: TObject);
    procedure trkBouncyChange(Sender: TObject);
    procedure cmdCancelClick(Sender: TObject);
    procedure trkPreviewChange(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure lstCollisionsChange(Sender: TObject);
    procedure chkCollisionClick(Sender: TObject);
  private
    { Private declarations }
    m_Physics    : TPhysics;
    m_nStartFrame : integer;
    m_nCurrentFrame : integer;
    m_bCreated : boolean;
    m_nFrameCount : integer;

    m_forceLabel : TForceLabel;
    m_bMouseDown : boolean;

    m_collisions : array[0..4] of boolean;

    m_olLayers : TList; //not owned here, simply reference to add to
    m_olObjects : TList;
    procedure clearTweenedObjects;

    procedure createPhysicsObjects();

    procedure _physicsInitialise();
    procedure _physicsFinalise();
    procedure _physicsUpdate();
    procedure _physicsReset();

    procedure initWalls;
  public
    { Public declarations }
    procedure AssignLayers(olLayers : TList; nFrame : integer);
  end;

implementation

uses main, tools, stickstuff, stickjoint, stickrenderer;

{$R *.dfm}

function ANG(inAngle : single) : single;
begin
   while (inAngle < 0) do
      inAngle := inAngle + 360;
   while (inAngle > 360) do
      inAngle := inAngle - 360;

   ANG := inAngle;
end;

procedure TfrmCAS.clearTweenedObjects;
var
  f : integer;
  pObject : TMovieObject;
begin
  for f := 0 to m_olObjects.Count - 1 do
  begin
    pObject := m_olObjects.Items[f];
    pObject.Destroy;
  end;
  m_olObjects.Clear;
end;

procedure TfrmCAS._physicsInitialise();
begin
  m_Physics.Free;
	m_Physics := TPhysics.Create(frmMain.m_nMovieWidth, frmMain.m_nMovieHeight, m_collisions);
end;

procedure TfrmCAS._physicsFinalise();
begin
	m_Physics.Free;
	m_Physics := nil;
end;

procedure TfrmCAS._physicsUpdate();
var
  f : integer;
  pMovieObject : TMovieObject;
  pObject : pointer;
  body : PcpBody;
  wide,high : single;
  pNewObject : pointer;

  g : integer;

  l : single;
  a : single;
  xx,yy : single;

  //temp debug
   renderer : TStickRenderer;
   pScreen : TGPGraphics;
   procedure adjustJoint(joint : TJoint);
   var
     x1,y1,x2,y2 : integer;
     angle : single;
     length : single;
     cx,cy : single;
     h : integer;
   begin
      body := joint.Data;
      if (body <> nil) then
      begin
        angle := cpvtoangle(body^.rot) + (pi/2){ / pi * 180};
        if (joint.DrawAs <> 0) then
          angle := angle + body.drawRotInc;
        length := joint.Length / 2;
        cx := cos(angle) * length;
        cy := sin(angle) * length;

        x1 := round(body^.p.x + cx);
        y1 := round(body^.p.y + cy);
        x2 := round(body^.p.x - cx);
        y2 := round(body^.p.y - cy);

        if (joint.Parent <> nil) then
          joint.Parent.SetPosAbs(x2,y2);
        joint.SetPosAbs(x1,y1);
      end;

      for h := 0 to joint.m_olChildren.Count - 1 do
      begin
        adjustJoint(joint.m_olChildren.Items[h]);
      end;
   end;
begin
  frmMain.m_Canvas.Clear(MakeColor(255,255,255));
  renderer := TStickRenderer.Create(frmMain.m_Canvas);
  renderer.XOffset := frmMain.m_nXOffset;
  renderer.YOffset := frmMain.m_nYOffset;

	m_Physics.Step;
	m_Physics.Step;
  for f := 0 to m_olObjects.Count - 1 do
  begin
    pMovieObject := m_olObjects.Items[f];
    pObject := pMovieObject.m_pObject;
    if (pMovieObject.m_nState = C_STATE_PASSTHROUGH) then
    begin
      if (m_nCurrentFrame = m_nStartFrame) then
      begin
        pMovieObject.AddKeyFrame(pObject, m_nCurrentFrame);
        pMovieObject.AddKeyFrame(pObject, m_nFrameCount);
        continue;
      end else
      begin
        continue;
      end;
    end;
    
    pNewObject := pMovieObject.AddKeyFrame(pObject, m_nCurrentFrame);

    case pMovieObject.m_nType of
      O_LINE:
        begin
          body := TLineObj(pObject).m_body;
          wide := (TLineObjPtr(pNewObject)^.Pnt(2)^.Left - TLineObjPtr(pNewObject)^.Pnt(1)^.Left);
          high := (TLineObjPtr(pNewObject)^.Pnt(2)^.Top - TLineObjPtr(pNewObject)^.Pnt(1)^.Top);
          l := sqrt( sqr(wide) + sqr(high)) / 2;
          a := cpvtoangle(body^.rot) - (pi/2){ / pi * 180};
            xx := cos(a) * l;
            yy := sin(a) * l;
          TLineObjPtr(pNewObject)^.Pnt(1)^.Left := round(body^.p.x + xx);
          TLineObjPtr(pNewObject)^.Pnt(1)^.Top := round(body^.p.y + yy);
          TLineObjPtr(pNewObject)^.Pnt(2)^.Left := round(body^.p.x - xx);
          TLineObjPtr(pNewObject)^.Pnt(2)^.Top := round(body^.p.y - yy);
          TLineObjPtr(pNewObject)^.Draw(frmMain.m_nXoffset, frmMain.m_nYoffset, false);
        end;
      O_RECTANGLE:
        begin
          body := TSquareObj(pObject).m_body;
          wide := (TSquareObjPtr(pNewObject)^.Pnt(3)^.Left - TSquareObjPtr(pNewObject)^.Pnt(1)^.Left) / 2;
          high := (TSquareObjPtr(pNewObject)^.Pnt(3)^.Top - TSquareObjPtr(pNewObject)^.Pnt(1)^.Top) / 2;
          TSquareObjPtr(pNewObject)^.Pnt(1)^.Left := round(body^.p.x - wide);
          TSquareObjPtr(pNewObject)^.Pnt(1)^.Top := round(body^.p.y - high);
          TSquareObjPtr(pNewObject)^.Pnt(3)^.Left := round(body^.p.x + wide);
          TSquareObjPtr(pNewObject)^.Pnt(3)^.Top := round(body^.p.y + high);
          TSquareObjPtr(pNewObject)^.m_angle := cpvtoangle(body^.rot) / pi * 180;
          TSquareObjPtr(pNewObject)^.Draw(frmMain.m_nXoffset, frmMain.m_nYoffset, false);
        end;
      O_BITMAP:
        begin
          body := TBitman(pObject).m_body;
          wide := (TBitmanPtr(pNewObject)^.Pnt(3)^.Left - TBitmanPtr(pNewObject)^.Pnt(1)^.Left) / 2;
          high := (TBitmanPtr(pNewObject)^.Pnt(3)^.Top - TBitmanPtr(pNewObject)^.Pnt(1)^.Top) / 2;
          TBitmanPtr(pNewObject)^.Pnt(1)^.Left := round(body^.p.x - wide);
          TBitmanPtr(pNewObject)^.Pnt(1)^.Top := round(body^.p.y - high);
          TBitmanPtr(pNewObject)^.Pnt(3)^.Left := round(body^.p.x + wide);
          TBitmanPtr(pNewObject)^.Pnt(3)^.Top := round(body^.p.y + high);
          TBitmanPtr(pNewObject)^.m_angle := cpvtoangle(body^.rot) / pi * 180;
          TBitmanPtr(pMovieObject.m_pTempObject)^.Assign(pNewObject);
          TBitmanPtr(pMovieObject.m_pTempObject)^.Draw(frmMain.m_nXoffset, frmMain.m_nYoffset, 255, false);
        end;
      O_OVAL:
        begin
          body := TOvalObj(pObject).m_body;
          wide := (TOvalObjPtr(pNewObject)^.Pnt(3)^.Left - TOvalObjPtr(pNewObject)^.Pnt(1)^.Left) / 2;
          high := (TOvalObjPtr(pNewObject)^.Pnt(3)^.Top - TOvalObjPtr(pNewObject)^.Pnt(1)^.Top) / 2;
          if (wide < 0) then
            wide := wide * -1;
          if (high < 0) then
            high := high * -1;
          TOvalObjPtr(pNewObject)^.Pnt(1)^.Left := round(body^.p.x - wide);
          TOvalObjPtr(pNewObject)^.Pnt(1)^.Top := round(body^.p.y - high);
          TOvalObjPtr(pNewObject)^.Pnt(3)^.Left := round(body^.p.x + wide);
          TOvalObjPtr(pNewObject)^.Pnt(3)^.Top := round(body^.p.y + high);
          TOvalObjPtr(pNewObject)^.m_angle := cpvtoangle(body^.rot) / pi * 180;

          TOvalObjPtr(pNewObject)^.Draw(frmMain.m_nXoffset, frmMain.m_nYoffset, false);
        end;
      O_TEXT:
        begin
          body := TTextObj(pObject).m_body;
          wide := (TTextObjPtr(pNewObject)^.Pnt(3)^.Left - TTextObjPtr(pNewObject)^.Pnt(1)^.Left) / 2;
          high := (TTextObjPtr(pNewObject)^.Pnt(3)^.Top - TTextObjPtr(pNewObject)^.Pnt(1)^.Top) / 2;
          TTextObjPtr(pNewObject)^.Pnt(1)^.Left := round(body^.p.x - wide);
          TTextObjPtr(pNewObject)^.Pnt(1)^.Top := round(body^.p.y - high);
          TTextObjPtr(pNewObject)^.Pnt(3)^.Left := round(body^.p.x + wide);
          TTextObjPtr(pNewObject)^.Pnt(3)^.Top := round(body^.p.y + high);
          TTextObjPtr(pNewObject)^.m_angle := cpvtoangle(body^.rot) / pi * 180;
          TTextObjPtr(pNewObject)^.Draw(frmMain.m_nXoffset, frmMain.m_nYoffset, false);
        end;
      O_T2STICK:
        begin
          for g := 0 to TLimbListPtr(pNewObject)^.GetJointCount() - 1 do
          begin
            adjustJoint(TLimbListPtr(pNewObject)^.Joint[g]);
          end;
          renderer.DrawStick(TLimbListPtr(pNewObject)^, 0, 255);
        end;
    end;
    //O_T2STICK: m_Physics.AddT2Stick(pObject);
    {if (m_nType = O_STICKMAN) then
    if (m_nType = O_LINE) then
    if (m_nType = O_POLY) then}
  end;

//DEBUG!
   pScreen := TGPGraphics.Create(frmMain.frmCanvas.canvas.handle);
   pScreen.DrawImage(frmMain.m_Bitmap, 0,0, frmMain.frmCanvas.clientwidth, frmMain.frmCanvas.clientheight);
   pScreen.Free;
   renderer.Free;

   m_nCurrentFrame := m_nCurrentFrame + 1;
end;

procedure TfrmCAS._physicsReset();
begin
   _physicsFinalise();
   _physicsInitialise();
end;

procedure TfrmCAS.m_lstObjectsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  pMovieObject : TMovieObject;
begin
   if (m_lstObjects.Selected = nil) then
   begin
      m_strMass.Enabled := FALSE;
      cboState.Enabled := FALSE;
      trkBouncy.Enabled := FALSE;
      //m_pSourceMovie.Render(m_nStartFrame, false, false);
      paint;
      exit;
   end;
   m_strMass.Enabled := TRUE;
   cboState.Enabled := TRUE;
   trkBouncy.Enabled := TRUE;

   pMovieObject := item.Data;
   m_strMass.Text := floattostr(pMovieObject.m_fMass);
   trkBouncy.Position := round(pMovieObject.m_fBouncy * 100);
   cboState.ItemIndex := pMovieObject.m_nState;

   m_forceLabel.m_nX := m_forceLabel.m_nCenterX - round(pMovieObject.m_fForce[0]);
   m_forceLabel.m_nY := m_forceLabel.m_nCenterY - round(pMovieObject.m_fForce[1]);
   paint;

  // m_pSourceMovie.Render(m_nStartFrame, true, pTisfat.m_pSrcFrmSet, false);
end;

procedure TfrmCAS.cmdCancelClick(Sender: TObject);
begin
   frmMain.grdFrames.Enabled := TRUE;;
   frmToolBar.Show;
   Close;
   frmMain.ReRender;
end;

procedure TfrmCAS.cmdCloseClick(Sender: TObject);
var
  layer : integer;
  index : integer;
  pObject : TMovieObject;
  pLayer : TLayerObjPtr;
begin
  for index := 0 to m_olObjects.Count - 1 do
  begin
    pObject := m_olObjects.Items[index];
    pLayer := frmMain.m_olLayers.Items[pObject.m_nOriginalLayer];
    pLayer^.m_olFrames.Add(pObject.FrameSet);
  end;

   frmMain.grdFrames.Enabled := TRUE;
   frmMain.grdFrames.Repaint;
   Hide;
   frmToolBar.Show;
end;

procedure TfrmCAS.FormCreate(Sender: TObject);
begin
   _physicsInitialise();
   m_bCreated := FALSE;
   m_nFrameCount := 0;

   m_forceLabel := TForceLabel.Create;
   m_forceLabel.m_nCenterX := 83;
   m_forceLabel.m_nCenterY := 310;
   m_forceLabel.m_nX := m_forceLabel.m_nCenterX;
   m_forceLabel.m_nY := m_forceLabel.m_nCenterY;
   m_bMouseDown := FALSE;
   m_olObjects := TList.Create;
end;

procedure TfrmCAS.FormDestroy(Sender: TObject);
begin
  clearTweenedObjects();
  m_olObjects.Free;

   _physicsFinalise();
   m_forceLabel.Free();
end;

procedure TfrmCAS.initWalls;
begin
  m_collisions[0] := true;
  m_collisions[1] := true;
  m_collisions[2] := true;
  m_collisions[3] := true;
  m_collisions[4] := true;
   lstCollisions.ItemIndex := 0;
   chkCollision.Checked := true;
end;

procedure TfrmCAS.FormShow(Sender: TObject);
begin
   frmMain.grdFrames.Enabled := FALSE;
   frmToolBar.Hide;
   if (m_olObjects.Count > 0) then
      m_lstObjects.ItemIndex := 0;
end;

procedure TfrmCAS.lstCollisionsChange(Sender: TObject);
begin
  chkCollision.Checked := m_collisions[lstCollisions.ItemIndex];
end;

procedure TfrmCAS.AssignLayers(olLayers : TList; nFrame : integer);
var
  layer : integer;
  pLayer : TLayerObj;
  frameset : integer;
  pFrameSet : TSingleFrame;
  frame : integer;
  pUseFrame, pFrame, pNextFrame : TIFrame;
  pObject : TMovieObject;
  pItem : TListItem;
  percent : single;
begin
  initWalls;
  m_olLayers := olLayers;
  m_nStartFrame := nFrame;
  m_lstObjects.Clear;
  trkPreview.Position := 0;
  trkPreview.Enabled := false;
  clearTweenedObjects();
  for layer := 0 to olLayers.Count-1 do
  begin
    pLayer := TLayerObjPtr(olLayers.Items[layer])^;
    if (pLayer.m_nType = O_STICKMAN) or (pLayer.m_nType = O_POLY) or (pLayer.m_nType = O_EXPLODE) or (pLayer.m_nType = O_SPECIALSTICK) or (pLayer.m_nType = O_STICKMANBMP) then
      continue;

    frameset := 0;
//    for frameset := 0 to pLayer.m_olFrames.Count - 1 do
    while (frameset < pLayer.m_olFrames.Count) do
    begin
      pFrameSet := TSingleFramePtr(pLayer.m_olFrames.Items[frameset])^;
      for frame := 0 to pFrameSet.m_Frames.Count - 2 do
      begin
        pUseFrame := nil;
        pFrame := TIFramePtr(pFrameSet.m_Frames.Items[frame])^;
        pNextFrame := TIFramePtr(pFrameSet.m_Frames.Items[frame+1])^;
        if (pFrame.m_FrameNo = nFrame) then
          pUseFrame := pFrame
        else if ((pNextFrame.m_FrameNo > nFrame) and (pFrame.m_FrameNo < nFrame)) then
          pUseFrame := pFrame;

        if (pUseFrame <> nil) then
        begin
          percent := (nFrame - pFrame.m_FrameNo) / (pNextFrame.m_FrameNo - pFrame.m_FrameNo);

          pObject := TMovieObject.Create(layer,frameset,frame, pLayer.m_nType, pFrame.m_pObject,pNextFrame.m_pObject,pLayer.m_pTempObject, percent);
          if (pObject <> nil) then
          begin
            m_olObjects.Add(pObject);
            pItem := m_lstObjects.Items.Add;
            pItem.Caption := pLayer.m_strName;
            pItem.Data := pObject;
            frameSet :=  pLayer.m_olFrames.Count;
            break;
          end;
        end;
      end;
      frameset := frameSet + 1;
    end;
  end;
end;

procedure TfrmCAS.createPhysicsObjects();
var
  f : integer;
  pMovieObject : TMovieObject;
  pObject : pointer;
begin
  for f := 0 to m_olObjects.Count - 1 do
  begin
    pMovieObject := m_olObjects.Items[f];
    pMovieObject.ResetFrameset;
    pObject := pMovieObject.m_pObject;
    case pMovieObject.m_nType of
      O_RECTANGLE: m_Physics.AddRectangle(TSquareObj(pObject), pMovieObject.m_nState, pMovieObject.m_fForce, pMovieObject.m_fBouncy, pMovieObject.m_fMass);
      O_BITMAP: m_Physics.AddBitmap(TBitman(pObject), pMovieObject.m_nState, pMovieObject.m_fForce, pMovieObject.m_fBouncy, pMovieObject.m_fMass);
      O_LINE: m_Physics.AddLine(TLineObj(pObject), pMovieObject.m_nState, pMovieObject.m_fBouncy, pMovieObject.m_fMass);
      O_OVAL: m_Physics.AddOval(TOvalObj(pObject), pMovieObject.m_nState, pMovieObject.m_fForce, pMovieObject.m_fBouncy, pMovieObject.m_fMass);
      O_TEXT: m_Physics.AddText(TTextObj(pObject), pMovieObject.m_nState, pMovieObject.m_fForce, pMovieObject.m_fBouncy, pMovieObject.m_fMass);
      O_T2STICK: m_Physics.AddT2Stick(pObject, pMovieObject.m_nState, pMovieObject.m_fBouncy, pMovieObject.m_fMass);
//      O_POLY : m_Physics.AddPolygon(pObject, pMovieObject.m_nState, pMovieObject.m_fForce);
    end;
    {if (m_nType = O_STICKMAN) then
    }
  end;
end;


procedure TfrmCAS.cmdCreateClick(Sender: TObject);
var
  f : integer;
begin
   m_nFrameCount := strtoint(m_strFrameCount.Text);
   trkPreview.Position := 0;
   m_nCurrentFrame := m_nStartFrame;

   progress.Visible := TRUE;
   cmdCreate.Visible := FALSE;
   m_strFrameCount.Visible := FALSE;

   m_bCreated := TRUE;
   cmdCreate.Enabled := FALSE;
   cmdCancel.Enabled := FALSE;
   cmdClose.Enabled := FALSE;
   m_lstObjects.Enabled := FALSE;
   m_strMass.Enabled := FALSE;
   cboState.Enabled := FALSE;
   trkBouncy.Enabled := FALSE;

   _physicsReset();
   createPhysicsObjects();

   for f := 0 to m_nFrameCount - 1 do
   begin
     _physicsUpdate();
   end;

   cmdCreate.Enabled := TRUE;
   cmdClose.Enabled := TRUE;
   m_lstObjects.Enabled := TRUE;
   m_strMass.Enabled := TRUE;
   cboState.Enabled := TRUE;
   trkBouncy.Enabled := TRUE;
   cmdCancel.Enabled := TRUE;
   trkPreview.Enabled := TRUE;

   progress.Visible := FALSE;
   cmdCreate.Visible := TRUE;
   m_strFrameCount.Visible := TRUE;

end;

procedure TfrmCAS.cboStateSelect(Sender: TObject);
begin
   if (m_lstObjects.Selected = nil) then
      exit;

   TMovieObject(m_lstObjects.Selected.Data).m_nState := cboState.ItemIndex;
   if (TMovieObject(m_lstObjects.Selected.Data).m_nState = C_STATE_SLEEPING) then
    if (TMovieObject(m_lstObjects.Selected.Data).m_nType = O_T2STICK) then
    begin
      lstCollisions.ItemIndex := 4;
      chkCollision.Checked := false;
      m_collisions[4] := false;
    end;
    
end;

procedure TfrmCAS.chkCollisionClick(Sender: TObject);
begin
  m_collisions[lstCollisions.ItemIndex] := chkCollision.Checked;
end;

procedure TfrmCAS.m_strMassChange(Sender: TObject);
begin
   if (m_strMass.Text = '') then
      exit;

   if (m_lstObjects.Selected = nil) then
      exit;

   TMovieObject(m_lstObjects.Selected.Data).m_fMass := strtofloat(m_strMass.Text);

end;

procedure TfrmCAS.trkBouncyChange(Sender: TObject);
begin
   if (m_lstObjects.Selected = nil) then
      exit;

   TMovieObject(m_lstObjects.Selected.Data).m_fBouncy := trkBouncy.Position / 100;
end;

procedure TfrmCAS.trkPreviewChange(Sender: TObject);
var
   nFrame : integer;

   procedure renderFrame;
   var
     renderer : TStickRenderer;
     pScreen : TGPGraphics;
     f : integer;
     frameSet : TSingleFramePtr;
     frame : TIFramePtr;
     pMovieObject : TMovieObject;
     pObject : pointer;
   begin
      frmMain.m_Canvas.Clear(MakeColor(255,255,255));
      renderer := TStickRenderer.Create(frmMain.m_Canvas);
      renderer.XOffset := frmMain.m_nXoffset;
      renderer.YOffset := frmMain.m_nYoffset;

      for f := 0 to m_olObjects.Count - 1 do
      begin
        pMovieObject := m_olObjects.Items[f];
        pObject := pMovieObject.m_pObject;
        frameSet := pMovieObject.FrameSet;
        if (pMovieObject.m_nState = C_STATE_PASSTHROUGH) then
        begin
          if (nFrame = m_nStartFrame) then
            frame := frameSet^.m_Frames[0]
          else
            frame := frameSet^.m_Frames[1];
        end else
        begin
          frame := frameSet^.m_Frames[nFrame];
        end;

        case pMovieObject.m_nType of
          O_LINE:     TLineObjPtr(frame^.m_pObject)^.Draw(frmMain.m_nXoffset, frmMain.m_nYoffset, false);
          O_RECTANGLE:TSquareObjPtr(frame^.m_pObject)^.Draw(frmMain.m_nXoffset, frmMain.m_nYoffset, false);
          O_BITMAP:
          begin
            TBitmanPtr(pMovieObject.m_pTempObject)^.Assign(frame^.m_pObject);
            TBitmanPtr(pMovieObject.m_pTempObject)^.Draw(frmMain.m_nXoffset, frmMain.m_nYoffset, 255, false);
          end;
          O_OVAL:     TOvalObjPtr(frame^.m_pObject)^.Draw(frmMain.m_nXoffset, frmMain.m_nYoffset, false);
          O_TEXT:     TTextObjPtr(frame^.m_pObject)^.Draw(frmMain.m_nXoffset, frmMain.m_nYoffset, false);
          O_T2STICK:
          begin
            renderer.DrawStick(TLimbListPtr(frame^.m_pObject)^, 0, 255);
          end;
        end;
      end;

      if (m_collisions[0]) then
        renderer.DrawLine(0,0, 1, frmMain.m_nMovieHeight, 0,0,0, 1,1, 0);
      if (m_collisions[1]) then
        renderer.DrawLine(frmMain.m_nMovieWidth,0, 1,frmMain.m_nMovieHeight,  0,0,0, 1,1, 0);
      if (m_collisions[2]) then
        renderer.DrawLine(0,0, frmMain.m_nMovieWidth,1, 0,0,0, 1,1, 0);
      if (m_collisions[3]) then
        renderer.DrawLine(0,frmMain.m_nMovieHeight, frmMain.m_nMovieWidth,1, 0,0,0, 1,1, 0);

      pScreen := TGPGraphics.Create(frmMain.frmCanvas.canvas.handle);
      pScreen.DrawImage(frmMain.m_Bitmap, 0,0, frmMain.frmCanvas.clientwidth, frmMain.frmCanvas.clientheight);
      pScreen.Free;
      renderer.Free;

    end;
begin
   if (m_nFrameCount = 0) or (m_lstObjects.Items.Count = 0) then
      exit;

   nFrame := {m_nStartFrame + }round((trkPreview.Position / 100) * m_nFrameCount);
   if (nFrame >= m_nFrameCount) then
    nFrame := m_nFrameCount-1;

   //if (nFrame <> 0) then
   //  m_strFrameCount.Text := inttostr(nFrame);

  renderFRame;
   //frmMain.RenderLayers(m_olLayers, nFrame, false);
end;

procedure TfrmCAS.FormPaint(Sender: TObject);
var
   angle : single;
   yDiff,xDiff : integer;
begin
   Canvas.Pen.Color := clBlack;
   Canvas.Brush.Color := clWhite;
   Canvas.Rectangle(m_forceLabel.m_nCenterX - 55,
                    m_forceLabel.m_nCenterY - 55,
                    m_forceLabel.m_nCenterX + 55,
                    m_forceLabel.m_nCenterY + 55);

   //draw the line
   Canvas.MoveTo(m_forceLabel.m_nCenterX, m_forceLabel.m_nCenterY);
   Canvas.LineTo(m_forceLabel.m_nX, m_forceLabel.m_nY);

   //draw the arrow
   xDiff := m_forceLabel.m_nX - m_forceLabel.m_nCenterX;
   yDiff := m_forceLabel.m_nY - m_forceLabel.m_nCenterY;
   angle := 180 * (1 + ArcTan2(yDiff, xDiff) / PI);
   angle := angle - 180;
   if (xDiff <> 0) or (yDiff <> 0) then
   begin
      Canvas.MoveTo(m_forceLabel.m_nCenterX, m_forceLabel.m_nCenterY);
      Canvas.LineTo(m_forceLabel.m_nCenterX + round( cos((angle+25)*pi/180) * 10 ),
                    m_forceLabel.m_nCenterY + round( sin((angle+25)*pi/180) * 10 ));
      Canvas.MoveTo(m_forceLabel.m_nCenterX, m_forceLabel.m_nCenterY);
      Canvas.LineTo(m_forceLabel.m_nCenterX + round( cos((angle-25)*pi/180) * 10 ),
                    m_forceLabel.m_nCenterY + round( sin((angle-25)*pi/180) * 10 ));
   end;

   //draw the select box
   Canvas.Rectangle(m_forceLabel.m_nX-2,
                    m_forceLabel.m_nY-2,
                    m_forceLabel.m_nX+2,
                    m_forceLabel.m_nY+2);
end;

procedure TfrmCAS.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if (m_lstObjects.Selected = nil) then
      exit;

   if (abs(x-m_forceLabel.m_nX) < 3) and (abs(y-m_forceLabel.m_nY) < 3) then
      m_bMouseDown := TRUE;
end;

procedure TfrmCAS.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
   angle : single;
   yDiff,xDiff : integer;
   length : integer;
   pMovieObject : TMovieObject;
begin
   if (m_bMouseDown) then
   begin
      m_forceLabel.m_nX := X;
      m_forceLabel.m_nY := Y;
      xDiff := m_forceLabel.m_nX - m_forceLabel.m_nCenterX;
      yDiff := m_forceLabel.m_nY - m_forceLabel.m_nCenterY;
      angle := 180 * (1 + ArcTan2(yDiff, xDiff) / PI);
      length := round(sqrt( sqr(xDiff) + sqr(yDiff) ));
      if (length > 50) then
      begin
         length := 50;
         angle := (angle+180) *  pi / 180;
         m_forceLabel.m_nX := m_forceLabel.m_nCenterX + round(cos(angle)*length);
         m_forceLabel.m_nY := m_forceLabel.m_nCenterY + round(sin(angle)*length);
      end;

      pMovieObject := m_lstObjects.Selected.Data;
      pMovieObject.m_fForce[0] := -xDiff;
      pMovieObject.m_fForce[1] := -yDiff;

      Paint;
   end;
end;

procedure TfrmCAS.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMouseDown := FALSE;
end;

end.


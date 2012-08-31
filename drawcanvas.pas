unit drawcanvas;

interface

uses
  Windows, Messages, SysUtils, {Variants,} Classes, Graphics, Controls, Forms,
  {Dialogs,} Menus, dcAVI, stickjoint;

type

  pfUpdate = procedure(nIndex : integer) of object;
  TLabel2Ptr = ^TLabel2;
  TLabel2 = class(TObject)
  public
      Left, Top : integer;
      Tag : integer;
      Color : TColor;
      m_pUpdate : pfUpdate;
      m_bLocked : BOOLEAN;
  end;


  TfrmCanvas = class(TForm)
    mnuActions: TPopupMenu;
    Move1: TMenuItem;
    SavePose1: TMenuItem;
    RestorePose1: TMenuItem;
    Setposetopreviousframe1: TMenuItem;
    Setposetonextkeyframe1: TMenuItem;
    N1: TMenuItem;
    OpenMouth1: TMenuItem;
    ChangeFaceDirection1: TMenuItem;
    N2: TMenuItem;
    FlipHorizontally1: TMenuItem;
    FlipVertically1: TMenuItem;
    FlipLegs1: TMenuItem;
    FlipArms1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Move1Click(Sender: TObject);
    procedure SavePose1Click(Sender: TObject);
    procedure RestorePose1Click(Sender: TObject);
    procedure Setposetopreviousframe1Click(Sender: TObject);
    procedure Setposetonextkeyframe1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure OpenMouth1Click(Sender: TObject);
    procedure ChangeFaceDirection1Click(Sender: TObject);
    procedure FlipVertically1Click(Sender: TObject);
    procedure FlipHorizontally1Click(Sender: TObject);
    procedure FlipLegs1Click(Sender: TObject);
    procedure FlipArms1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    m_nX1, m_nY1, m_nX2, m_nY2, m_nX, m_nY : integer;
    m_bMoving : boolean;
    m_pSelectedJoint : TJoint;
    m_nJointX, m_nJointY : integer;
    m_pLastSelectedJoint : TJoint;
    procedure rotate(amount : integer);
    procedure alpha(amount : integer);
  public
   aviPlaya : TDCAVIPlayer;
      m_pPnt : TLabel2Ptr;
      m_PntList : TList;
      m_bOld : boolean;

      procedure StoreSelectedJointPos;
      procedure SetSelectedJointByPos;

      procedure Paint; override;

      property SelectedJoint : TJoint read m_pLastSelectedJoint;
  end;

var
   frmCanvas : TfrmCanvas;

implementation

uses main, tools, configfile, stickstuff;

{$R *.dfm}

procedure TfrmCanvas.StoreSelectedJointPos;
begin
   if (m_pLastSelectedJoint <> nil) then
   begin
      m_nJointX := m_pLastSelectedJoint.X;
      m_nJointY := m_pLastSelectedJoint.Y;
   end else
   begin
      m_nJointX := -10000;
      m_nJointY := -10000
   end;
   m_pLastSelectedJoint := nil;
end;

procedure TfrmCanvas.SetSelectedJointByPos;
begin
   if (m_nJointX <> -10000) and (m_nJointY <> -10000) then
   begin
      FormMouseDown(self, mbLeft, [], m_nJointX, m_nJointY);
      FormMouseUp(self, mbLeft, [], m_nJointX, m_nJointY);
   end;
   m_nJointX := -10000;
   m_nJointY := -10000;
end;

procedure TfrmCanvas.rotate(amount : integer);
begin
   if (frmMain.m_pTweenFrame = nil) then
      exit;

   if (frmMain.m_pTweenFrame^.m_nType = O_BITMAP) then TBitManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Rotate(amount);
   if (frmMain.m_pTweenFrame^.m_nType = O_RECTANGLE) then TSquareObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Rotate(amount);
   if (frmMain.m_pTweenFrame^.m_nType = O_OVAL) then TOvalObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Rotate(amount);
   if (frmMain.m_pTweenFrame^.m_nType = O_TEXT) then TTextObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Rotate(amount);

   frmMain.Render(frmMain.m_col, TRUE);
end;

procedure TfrmCanvas.alpha(amount : integer);
begin
   if (frmMain.m_pTweenFrame = nil) then
      exit;

   if (frmMain.m_pTweenFrame^.m_nType = O_BITMAP) then TBitManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Alpha(amount);
   if (frmMain.m_pTweenFrame^.m_nType = O_RECTANGLE) then TSquareObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Alpha(amount);
   if (frmMain.m_pTweenFrame^.m_nType = O_OVAL) then TOvalObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Alpha(amount);
   if (frmMain.m_pTweenFrame^.m_nType = O_TEXT) then TTextObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Alpha(amount);

   if (frmMain.m_pTweenFrame^.m_nType = O_STICKMAN) then TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Alpha(amount);
   if (frmMain.m_pTweenFrame^.m_nType = O_SPECIALSTICK) then TSpecialStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Alpha(amount);
   if (frmMain.m_pTweenFrame^.m_nType = O_STICKMANBMP) then TStickManBMPPtr(frmMain.m_pTweenFrame^.m_pObject)^.Alpha(amount);
   if (frmMain.m_pTweenFrame^.m_nType = O_LINE) then TLineObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Alpha(amount);
   if (frmMain.m_pTweenFrame^.m_nType = O_POLY) then TPolyObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Alpha(amount);

   frmMain.Render(frmMain.m_col, TRUE);
end;

procedure TfrmCanvas.FormCreate(Sender: TObject);
begin
   aviPlaya := TDCAVIPlayer.Create(nil);
   aviPlaya.Parent := self;
   m_pPnt := nil;
   ClientWidth := 320;
   ClientHeight := 240;
   m_bMoving := FALSE;
   if (LoadSettings(frmMain.m_strTHEPATH+'tis.fat', frmMain.m_Settings)) then
   begin
      Left := frmMain.m_Settings.CanvasLeft;
      Top := frmMain.m_Settings.CanvasTop;
   end;
   m_PntList := TList.Create;
end;

procedure TfrmCanvas.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   f,g : integer;
   pTemp : TLabel2Ptr;
   nType : integer;
   bSave : boolean;
begin
   bSave := FALSE;
   m_pPnt := nil;

   x := x - frmMain.m_nXoffset;
   y := y - frmMain.m_nYoffset;

   //nuke any existing data
   if (frmMain.m_Undo.m_pSavedObject <> nil) then
   begin
      TLimbList(frmMain.m_Undo.m_pSavedObject).Destroy;
      frmMain.m_Undo.m_pSavedObject := nil;
   end;

   if (frmMain.m_pTweenFrame <> nil) then
   begin
      nType := frmMain.m_pTweenFrame^.m_nType;
      if (Button = mbLeft) then
      begin

         /////////////////////
         m_pSelectedJoint := nil;
         if (nType = O_T2STICK) then
         begin
            m_pSelectedJoint := TLimbListPtr(frmMain.m_pTweenFrame^.m_pObject)^.GetJointAt(x, y, 4);
            m_pLastSelectedJoint := m_pSelectedJoint;
            if (m_pSelectedJoint <> nil) then
            begin
               m_nX1 := x;
               m_nY1 := y;
               m_nX2 := x;
               m_nY2 := y;
               bSave := true;

               if (Shift = [ssLeft, ssCtrl]) then
               begin
                  if (m_pSelectedJoint.State = C_STATE_NORMAL) then
                     m_pSelectedJoint.State := C_STATE_LOCKED
                  else if (m_pSelectedJoint.State = C_STATE_LOCKED) then
                     m_pSelectedJoint.State := C_STATE_NORMAL;
                  //frmMain.Render(frmMain.m_col);
                  exit;
               end;

               frmToolBar.ShowDetails(TLimbListPtr(frmMain.m_pTempObject)^, TLimbListPtr(frmMain.m_pTweenFrame^.m_pObject)^, m_pSelectedJoint);
               SetCapture(Handle);
            end;
         end;
         ///

         pTemp := nil;
         for f := 0 to m_PntList.Count-1 do
         begin
            pTemp := m_PntList.Items[f];
            if (x >= pTemp^.Left) and (y >= pTemp^.Top) and (x <= (pTemp^.Left+6)) and (y <= (pTemp^.Top+6)) then
            begin
               if (Shift = [ssLeft, ssCtrl]) and ((nType=O_STICKMAN) or (nType=O_STICKMANBMP) or (nType=O_SPECIALSTICK)) then
               begin
                  pTemp^.m_bLocked := not pTemp^.m_bLocked;
                  frmMain.Render(frmMain.m_col);
               end;
               //if (not pTemp^.m_bLocked) then
               begin
                  m_pPnt := pTemp;
               m_bOld := m_pPnt^.m_bLocked;
               m_pPnt^.m_bLocked := FALSE;
                  m_nX := x - m_pPnt^.Left;
                  m_nY := y - m_pPnt^.Top;
                  frmMain.m_Undo.m_nChange := E_POINTCHANGE;
                  bSave := TRUE;
               end;
               break;
            end;
         end;
      end;
      if (Button = mbRight) or (frmToolBar.m_bMove) then
      begin
         frmMain.m_Undo.m_nChange := E_MOVEOBJECT;
         m_bMoving := TRUE;
         bSave := TRUE;
      end;
      if (bSave) then
      begin
         frmMain.m_Undo.m_nType := nType;
         frmMain.Undo1.Enabled := tRUE;
         frmMain.m_Undo.m_pObject := frmMain.m_pTweenFrame^.m_pObject;
         if (nType = O_T2STICK) then
         begin
            frmMain.m_Undo.m_nChange := E_T2STICK;
            frmMain.m_Undo.m_nType := O_T2STICK;
            frmMain.m_Undo.m_pSavedObject := TLimbList.Create;
            TLimbList(frmMain.m_Undo.m_pSavedObject).CopyFrom(TLimbListPtr(frmMain.m_pTweenFrame^.m_pObject)^);
         end;         
         if (nType = O_STICKMAN) then
         begin
            f := 1;
            while f < 20 do
            begin
               frmMain.m_Undo.m_nParams[f] := TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(((f-1)+2) div 2)^.Left;   //changing a point
               frmMain.m_Undo.m_nParams[f+1] := TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(((f-1)+2) div 2)^.Top;   //changing a point
               f := f + 2;
            end;
         end;
         if (nType = O_SPECIALSTICK) then
         begin
            f := 1;
            while f < 28 do
            begin
               frmMain.m_Undo.m_nParams[f] := TSpecialStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(((f-1)+2) div 2)^.Left;   //changing a point
               frmMain.m_Undo.m_nParams[f+1] := TSpecialStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(((f-1)+2) div 2)^.Top;   //changing a point
               f := f + 2;
            end;
         end;
         if (nType = O_BITMAP) then
         begin
            f := 1;
            while f < 8 do
            begin
               frmMain.m_Undo.m_nParams[f] := TBitmanPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(((f-1)+2) div 2)^.Left;   //changing a point
               frmMain.m_Undo.m_nParams[f+1] := TBitmanPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(((f-1)+2) div 2)^.Top;   //changing a point
               f := f + 2;
            end;
         end;
         if (nType = O_RECTANGLE) then
         begin
            f := 1;
            while f < 8 do
            begin
               frmMain.m_Undo.m_nParams[f] := TSquareObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(((f-1)+2) div 2)^.Left;   //changing a point
               frmMain.m_Undo.m_nParams[f+1] := TSquareObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(((f-1)+2) div 2)^.Top;   //changing a point
               f := f + 2;
            end;
         end;
         if (nType = O_OVAL) then
         begin
            f := 1;
            while f < 8 do
            begin
               frmMain.m_Undo.m_nParams[f] := TOvalObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(((f-1)+2) div 2)^.Left;   //changing a point
               frmMain.m_Undo.m_nParams[f+1] := TOvalObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(((f-1)+2) div 2)^.Top;   //changing a point
               f := f + 2;
            end;
         end;
         if (nType = O_TEXT) then
         begin
            f := 1;
            while f < 8 do
            begin
               frmMain.m_Undo.m_nParams[f] := TTextObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(((f-1)+2) div 2)^.Left;   //changing a point
               frmMain.m_Undo.m_nParams[f+1] := TTextObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(((f-1)+2) div 2)^.Top;   //changing a point
               f := f + 2;
            end;
         end;
         if (nType = O_EXPLODE) then
         begin
            f := 1;
            while f < 4 do
            begin
               frmMain.m_Undo.m_nParams[f] := TExplodeObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(((f-1)+2) div 2)^.Left;   //changing a point
               frmMain.m_Undo.m_nParams[f+1] := TExplodeObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(((f-1)+2) div 2)^.Top;   //changing a point
               f := f + 2;
            end;
         end;
         if (nType = O_LINE) then
         begin
            f := 1;
            while f < 4 do
            begin
               frmMain.m_Undo.m_nParams[f] := TLineObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(((f-1)+2) div 2).Left;   //changing a point
               frmMain.m_Undo.m_nParams[f+1] := TLineObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(((f-1)+2) div 2).Top;   //changing a point
               f := f + 2;
            end;
         end;
         if (nType = O_STICKMANBMP) then
         begin
            f := 1;
            while f < 20 do
            begin
               frmMain.m_Undo.m_nParams[f] := TStickManBMPPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(((f-1)+2) div 2)^.Left;   //changing a point
               frmMain.m_Undo.m_nParams[f+1] := TStickManBMPPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(((f-1)+2) div 2)^.Top;   //changing a point
               f := f + 2;
            end;
         end;
         if (nType = O_POLY) then
         begin
            frmMain.Undo1.Enabled := FALSE;
         end;
            m_nX1 := x;
            m_nY1 := y;
            m_nX2 := x;
            m_nY2 := y;
            SetCapture(Handle);
      end;
   end;
end;

procedure TfrmCanvas.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   bSwitchy : boolean;
begin
   ReleaseCapture;
   m_pSelectedJoint := nil;

   x := x - frmMain.m_nXoffset;
   y := y - frmMain.m_nYoffset;

   if (m_pPnt <> nil) then
   begin
      m_pPnt^.m_bLocked := m_bOld;
      if (frmMain.m_Undo.m_nType = O_EXPLODE) then
      begin
         TExplodeObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.InitParts;
      end;
   end;
   m_pPnt := nil;
   m_bMoving := FALSE;
   frmToolBar.m_bMove := fALSE;
   if (Button = mbRight) then
   begin
      if (m_nX2 = x) and (m_nY2 = y) then
      begin
         if (frmMain.m_pTweenFrame <> nil) then
         begin
            mnuActions.Items[6].Enabled := (frmMain.m_pTweenFrame^.m_nType = O_STICKMANBMP);
            mnuActions.Items[7].Enabled := (frmMain.m_pTweenFrame^.m_nType = O_STICKMANBMP);

            bSwitchy := (frmMain.m_pTweenFrame^.m_nType = O_STICKMAN) or
                        (frmMain.m_pTweenFrame^.m_nType = O_STICKMANBMP) or
                        (frmMain.m_pTweenFrame^.m_nType = O_LINE){ or
                        (frmMain.m_pTweenFrame^.m_nType = O_RECTANGLE)};
            mnuActions.Items[9].Enabled := bSwitchy;
            mnuActions.Items[10].Enabled := bSwitchy;

            bSwitchy := (frmMain.m_pTweenFrame^.m_nType = O_STICKMAN) or
                        (frmMain.m_pTweenFrame^.m_nType = O_STICKMANBMP);
            mnuActions.Items[11].Enabled := bSwitchy;
            mnuActions.Items[12].Enabled := bSwitchy;
         end;
         mnuActions.Popup(Left+x,Top+y);
         m_nX2 := x;
         m_nY2 := y;
      end;
   end;
   frmMain.Render(frmMain.m_col, TRUE);
end;

procedure TfrmCanvas.FormMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
   if (frmMain.m_pTweenFrame = nil) then
      exit;

   if (frmMain.m_pTweenFrame^.m_nType = O_BITMAP) then TBitManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Rotate(-1);
   if (frmMain.m_pTweenFrame^.m_nType = O_RECTANGLE) then TSquareObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Rotate(-1);
   if (frmMain.m_pTweenFrame^.m_nType = O_OVAL) then TOvalObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Rotate(-1);
   if (frmMain.m_pTweenFrame^.m_nType = O_TEXT) then TTextObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Rotate(-1);

   frmMain.Render(frmMain.m_col, TRUE);
end;

procedure TfrmCanvas.FormMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
   if (frmMain.m_pTweenFrame = nil) then
      exit;

   if (frmMain.m_pTweenFrame^.m_nType = O_BITMAP) then TBitManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Rotate(1);
   if (frmMain.m_pTweenFrame^.m_nType = O_RECTANGLE) then TSquareObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Rotate(1);
   if (frmMain.m_pTweenFrame^.m_nType = O_OVAL) then TOvalObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Rotate(1);
   if (frmMain.m_pTweenFrame^.m_nType = O_TEXT) then TTextObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Rotate(1);

   frmMain.Render(frmMain.m_col, TRUE);
end;

procedure TfrmCanvas.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
   xdiff, ydiff : integer;
   strTemp : string;
   pTemp : TLabel2Ptr;
   f,g,h : integer;
   pLayer : TLayerObjPtr;
   pFrameSet : TSingleFramePtr;
   nFrame : integer;
   pKeyFrame : TIFramePtr;
begin
   x := x - frmMain.m_nXoffset;
   y := y - frmMain.m_nYoffset;
   
   str(x, strTemp);
   frmToolBar.lblXPos.Caption := 'X Pos: ' + strTemp;
   str(y, strTemp);
   frmToolBar.lblYPos.Caption := 'Y Pos: ' + strTemp;

   if (m_pSelectedJoint <> nil) then
   begin
      m_pSelectedJoint.SetPos(x,y);
      frmMain.Render(frmMain.m_col, TRUE);
      exit;
   end;

   if (m_bMoving) then
   begin
      xdiff := x - m_nX1;
      ydiff := y - m_nY1;
      //added 65
      nFrame := frmMain.m_col;
      if (frmMain.m_olSelectedLayers.Count > 0) then
      begin   //try move every iframe of every frameset
         for f := 0 to frmMain.m_olSelectedLayers.Count-1 do    //for each layer
         begin
            pLayer := frmMain.m_olSelectedLayers.Items[f];
            for g := 0 to pLayer^.m_olFrames.Count-1 do    //for each frameset
            begin
               pFrameSet := pLayer^.m_olFrames.Items[g];
               if (nFrame >= TIFramePtr(pFrameSet^.m_Frames.First)^.m_FrameNo) and (nFrame <= TIFramePtr(pFrameSet^.m_Frames.Last)^.m_FrameNo) then
               begin  //if the current frame is within this frameset
                  for h := 0 to pFrameset^.m_Frames.Count-1 do
                  begin
                     pKeyFrame := pFrameSet^.m_Frames.Items[h];
                     if (pKeyFrame^.m_FrameNo = nFrame) then  //if the keyframe is on the selected frame, move it.
                     begin
         if (pKeyFrame^.m_nType = O_STICKMAN) then TStickManPtr(pKeyFrame^.m_pObject)^.Move(xdiff,ydiff);
         if (pKeyFrame^.m_nType = O_SPECIALSTICK) then TSpecialStickManPtr(pKeyFrame^.m_pObject)^.Move(xdiff,ydiff);
         if (pKeyFrame^.m_nType = O_STICKMANBMP) then TStickManBMPPtr(pKeyFrame^.m_pObject)^.Move(xdiff,ydiff);
         if (pKeyFrame^.m_nType = O_BITMAP) then TBitManPtr(pKeyFrame^.m_pObject)^.Move(xdiff,ydiff);
         if (pKeyFrame^.m_nType = O_RECTANGLE) then TSquareObjPtr(pKeyFrame^.m_pObject)^.Move(xdiff,ydiff);
         if (pKeyFrame^.m_nType = O_EDITVIDEO) then TEditVideoObjPtr(pKeyFrame^.m_pObject)^.Move(xdiff,ydiff);
         if (pKeyFrame^.m_nType = O_LINE) then TLineObjPtr(pKeyFrame^.m_pObject)^.Move(xdiff,ydiff);
         if (pKeyFrame^.m_nType = O_EXPLODE) then TExplodeObjPtr(pKeyFrame^.m_pObject)^.Move(xdiff,ydiff);
         if (pKeyFrame^.m_nType = O_POLY) then TPolyObjPtr(pKeyFrame^.m_pObject)^.Move(xdiff,ydiff);
         if (pKeyFrame^.m_nType = O_OVAL) then TOvalObjPtr(pKeyFrame^.m_pObject)^.Move(xdiff,ydiff);
         if (pKeyFrame^.m_nType = O_SOUND) then TSoundObjPtr(pKeyFrame^.m_pObject)^.Move(xdiff,ydiff);
         if (pKeyFrame^.m_nType = O_TEXT) then TTextObjPtr(pKeyFrame^.m_pObject)^.Move(xdiff,ydiff);
         //if (pKeyFrame^.m_nType = O_T2STICK) then TLimbListPtr(pKeyFrame^.m_pObject)^.Move(-xdiff*2,-ydiff*2);
                     end;
                  end;
               end;
            end;
         end;
      end else
      begin  //no grouped layers, so just move the selected frame
         if (frmMain.m_pTweenFrame^.m_nType = O_STICKMAN) then TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Move(xdiff,ydiff);
         if (frmMain.m_pTweenFrame^.m_nType = O_SPECIALSTICK) then TSpecialStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Move(xdiff,ydiff);
         if (frmMain.m_pTweenFrame^.m_nType = O_STICKMANBMP) then TStickManBMPPtr(frmMain.m_pTweenFrame^.m_pObject)^.Move(xdiff,ydiff);
         if (frmMain.m_pTweenFrame^.m_nType = O_BITMAP) then TBitManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Move(xdiff,ydiff);
         if (frmMain.m_pTweenFrame^.m_nType = O_RECTANGLE) then TSquareObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Move(xdiff,ydiff);
         if (frmMain.m_pTweenFrame^.m_nType = O_EDITVIDEO) then TEditVideoObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Move(xdiff,ydiff);
         if (frmMain.m_pTweenFrame^.m_nType = O_LINE) then TLineObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Move(xdiff,ydiff);
         if (frmMain.m_pTweenFrame^.m_nType = O_EXPLODE) then TExplodeObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Move(xdiff,ydiff);
         if (frmMain.m_pTweenFrame^.m_nType = O_POLY) then TPolyObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Move(xdiff,ydiff);
         if (frmMain.m_pTweenFrame^.m_nType = O_OVAL) then TOvalObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Move(xdiff,ydiff);
         if (frmMain.m_pTweenFrame^.m_nType = O_SOUND) then TSoundObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Move(xdiff,ydiff);
         if (frmMain.m_pTweenFrame^.m_nType = O_TEXT) then TTextObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Move(xdiff,ydiff);
         if (frmMain.m_pTweenFrame^.m_nType = O_T2STICK) then
            TLimbListPtr(frmMain.m_pTweenFrame^.m_pObject)^.Move(xdiff,ydiff);
      end;
      frmMain.Render(frmMain.m_col, TRUE);
      m_nX1 := x;
      m_nY1 := y;
   end;

   if (m_pPnt <> nil) then
   begin
      screen.cursor := crHandPoint;
      m_pPnt^.Left := x - m_nX;
      m_pPnt^.Top := y - m_nY;
      if (Assigned(m_pPnt^.m_pUpdate)) then
      begin
         m_pPnt^.m_pUpdate(m_pPnt^.Tag);
      end;
      frmMain.Render(frmMain.m_col);
   end else
   begin
      screen.cursor := crDefault;
      for f := 0 to m_PntList.Count-1 do
      begin
         //crashy!
         pTemp := m_PntList.Items[f];
         if (x >= pTemp^.Left) and (y >= pTemp^.Top) and (x <= (pTemp^.Left+6)) and (y <= (pTemp^.Top+6)) then
         begin
            screen.cursor := crHandPoint;
            break;
         end;
      end;
   end;

end;

procedure TfrmCanvas.Move1Click(Sender: TObject);
begin
   FormMouseDown(self, (mbRight), [ssRight], m_nX2, m_nY2);
end;

procedure TfrmCanvas.SavePose1Click(Sender: TObject);
begin
   frmToolBar.imgSavePoseClick(Sender);
end;

procedure TfrmCanvas.RestorePose1Click(Sender: TObject);
begin
   frmToolBar.imgRestorePoseClick(Sender);
end;

procedure TfrmCanvas.Setposetopreviousframe1Click(Sender: TObject);
var
   pPrev : TIFramePtr;
   nIndex : integer;
   f : integer;
begin
   if (frmMain.m_pTweenFrame <> nil) then
   begin
      nIndex := frmMain.m_pFrame^.m_Frames.IndexOf(frmMain.m_pTweenFrame);
      if (nIndex > 0) then
      begin
         pPrev := frmMain.m_pFrame^.m_Frames.Items[nIndex-1];
         if (frmMain.m_pTweenFrame^.m_nType = O_STICKMAN) then TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Assign(TStickManPtr(pPrev^.m_pObject));
         if (frmMain.m_pTweenFrame^.m_nType = O_SPECIALSTICK) then TSpecialStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Assign(TSpecialStickManPtr(pPrev^.m_pObject));
         if (frmMain.m_pTweenFrame^.m_nType = O_EDITVIDEO) then TEditVideoObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Assign(TEditVideoObjPtr(pPrev^.m_pObject));
         if (frmMain.m_pTweenFrame^.m_nType = O_STICKMANBMP) then TStickManBMPPtr(frmMain.m_pTweenFrame^.m_pObject)^.Assign(TStickManBMPPtr(pPrev^.m_pObject));
         if (frmMain.m_pTweenFrame^.m_nType = O_T2STICK) then TLimbListPtr(frmMain.m_pTweenFrame^.m_pObject)^.CopyFrom(TLimbListPtr(pPrev^.m_pObject)^);
         if (frmMain.m_pTweenFrame^.m_nType = O_BITMAP) then TBitManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Assign(TBitManPtr(pPrev^.m_pObject));
         if (frmMain.m_pTweenFrame^.m_nType = O_RECTANGLE) then TSquareObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Assign(TSquareObjPtr(pPrev^.m_pObject));
         if (frmMain.m_pTweenFrame^.m_nType = O_LINE) then TLineObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Assign(TLineObjPtr(pPrev^.m_pObject));
         if (frmMain.m_pTweenFrame^.m_nType = O_EXPLODE) then TExplodeObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Assign(TExplodeObjPtr(pPrev^.m_pObject));
         if (frmMain.m_pTweenFrame^.m_nType = O_POLY) then TPolyObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Assign(TPolyObjPtr(pPrev^.m_pObject));
         if (frmMain.m_pTweenFrame^.m_nType = O_OVAL) then TOvalObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Assign(TOvalObjPtr(pPrev^.m_pObject));
         if (frmMain.m_pTweenFrame^.m_nType = O_SOUND) then TSoundObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Assign(TSoundObjPtr(pPrev^.m_pObject));
         if (frmMain.m_pTweenFrame^.m_nType = O_TEXT) then
         begin
            for f := 1 to 4 do
            begin
               TTextObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(f)^.Left := TTextObjPtr(pPrev^.m_pObject)^.Pnt(f)^.Left;
               TTextObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(f)^.Top := TTextObjPtr(pPrev^.m_pObject)^.Pnt(f)^.Top;
            end;
         end;
         frmMain.Render(frmMain.m_col, TRUE);
      end;
   end;
end;

procedure TfrmCanvas.Setposetonextkeyframe1Click(Sender: TObject);
var
   pNext : TIFramePtr;
   nIndex : integer;
   f : integer;
begin
   if (frmMain.m_pTweenFrame <> nil) then
   begin
      nIndex := frmMain.m_pFrame^.m_Frames.IndexOf(frmMain.m_pTweenFrame);
      if (nIndex < (frmMain.m_pFrame^.m_Frames.Count-1)) then
      begin
         pNext := frmMain.m_pFrame^.m_Frames.Items[nIndex+1];
         if (frmMain.m_pTweenFrame^.m_nType = O_STICKMAN) then TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Assign(TStickManPtr(pNext^.m_pObject));
         if (frmMain.m_pTweenFrame^.m_nType = O_EDITVIDEO) then TEditVideoObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Assign(TEditVideoObjPtr(pNext^.m_pObject));
         if (frmMain.m_pTweenFrame^.m_nType = O_SPECIALSTICK) then TSpecialStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Assign(TSpecialStickManPtr(pNext^.m_pObject));
         if (frmMain.m_pTweenFrame^.m_nType = O_STICKMANBMP) then TStickManBMPPtr(frmMain.m_pTweenFrame^.m_pObject)^.Assign(TStickManBMPPtr(pNext^.m_pObject));
         if (frmMain.m_pTweenFrame^.m_nType = O_T2STICK) then TLimbListPtr(frmMain.m_pTweenFrame^.m_pObject)^.CopyFrom(TLimbListPtr(pNext^.m_pObject)^);
         if (frmMain.m_pTweenFrame^.m_nType = O_BITMAP) then TBitManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Assign(TBitManPtr(pNext^.m_pObject));
         if (frmMain.m_pTweenFrame^.m_nType = O_RECTANGLE) then TSquareObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Assign(TSquareObjPtr(pNext^.m_pObject));
         if (frmMain.m_pTweenFrame^.m_nType = O_LINE) then TLineObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Assign(TLineObjPtr(pNext^.m_pObject));
         if (frmMain.m_pTweenFrame^.m_nType = O_EXPLODE) then TExplodeObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Assign(TExplodeObjPtr(pNext^.m_pObject));
         if (frmMain.m_pTweenFrame^.m_nType = O_POLY) then TPolyObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Assign(TPolyObjPtr(pNext^.m_pObject));
         if (frmMain.m_pTweenFrame^.m_nType = O_OVAL) then TOvalObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Assign(TOvalObjPtr(pNext^.m_pObject));
         if (frmMain.m_pTweenFrame^.m_nType = O_SOUND) then TSoundObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Assign(TSoundObjPtr(pNext^.m_pObject));
         if (frmMain.m_pTweenFrame^.m_nType = O_TEXT) then
         begin
            for f := 1 to 4 do
            begin
               TTextObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(f)^.Left := TTextObjPtr(pNext^.m_pObject)^.Pnt(f)^.Left;
               TTextObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(f)^.Top := TTextObjPtr(pNext^.m_pObject)^.Pnt(f)^.Top;
            end;
         end;
         frmMain.Render(frmMain.m_col, TRUE);
      end;
   end;
end;

procedure TfrmCanvas.FormDestroy(Sender: TObject);
begin
   aviPlaya.Free;
   LoadSettings(frmMain.m_strTHEPATH+'tis.fat', frmMain.m_Settings);
   frmMain.m_Settings.CanvasLeft := Left;
   frmMain.m_Settings.CanvasTop := Top;
   SaveSettings(frmMain.m_strTHEPATH+'tis.fat', frmMain.m_Settings);
   m_PntList.Free;
   m_PntList := nil;
end;

procedure TfrmCanvas.Paint;
begin
   if not frmMain.m_bPlaying then
   begin
      frmMain.ReRender;
 //     Canvas.CopyRect(rect(0,0,clientwidth,clientheight), frmMain.m_Canvas, rect(0,0,frmMain.m_Bitmap.Width, frmMain.m_Bitmap.Height));
   end;
end;

procedure TfrmCanvas.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if (key = VK_LEFT) then
   begin
      if shift = [ssShift] then
         rotate(-10)
      else
         rotate(-1);
   end;
   if (key = VK_RIGHT) then
   begin
      if shift = [ssShift] then
         rotate(10)
      else
         rotate(1);
   end;
   if (key = VK_UP) then
   begin
      if shift = [ssShift] then
         alpha(10)
      else
         alpha(1);
   end;
   if (key = VK_DOWN) then
   begin
      if shift = [ssShift] then
         alpha(-10)
      else
         alpha(-1);
   end;
end;

procedure TfrmCanvas.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if (Key = VK_RETURN) then
   begin
      frmToolBar.imgPropsClick(Sender);
   end;
   if (Key = 70) then
   begin
      ChangeFaceDirection1Click(nil);
   end;
   if (Key = 77) then
   begin
      OpenMouth1Click(nil);
   end;
end;

procedure TfrmCanvas.OpenMouth1Click(Sender: TObject);
begin
   if (frmMain.m_pTweenFrame <> nil) then
   begin
      if (frmMain.m_pTweenFrame^.m_nType = O_STICKMANBMP) then
      begin
         TStickManBMPPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_bMouthOpen := not (TStickManBMPPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_bMouthOpen);
         frmMain.Render(frmMain.m_col);
      end;
   end;
end;

procedure TfrmCanvas.ChangeFaceDirection1Click(Sender: TObject);
begin
   if (frmMain.m_pTweenFrame <> nil) then
   begin
      if (frmMain.m_pTweenFrame^.m_nType = O_STICKMANBMP) then
      begin
         TStickManBMPPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_bFlipped := not (TStickManBMPPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_bFlipped);
         frmMain.Render(frmMain.m_col);
      end;
   end;
end;

procedure GetStickCenter(pStickman : TStickManPtr; var midX, midY : integer);
var
   minX, minY, maxX, maxY : integer;
   f : integer;
   pPoint : TLabel2Ptr;
begin
   minX := 65535;
   minY := 65535;
   maxX := -65534;
   maxY := -65534;
   for f := 0 to pStickman^.PntList.Count-1 do
   begin
      pPoint := pStickman^.PntList.Items[f];
      if (pPoint^.Left < minX) then minX := pPoint^.Left;
      if (pPoint^.Left > maxX) then maxX := pPoint^.Left;
      if (pPoint^.Top < minY) then minY := pPoint^.Top;
      if (pPoint^.Top > maxY) then maxY := pPoint^.Top;
   end;
   midX := minX + ((maxX - minX) shr 1);
   midY := minY + ((maxY - minY) shr 1);
end;

procedure TfrmCanvas.FlipVertically1Click(Sender: TObject);
var
   midX, midY : integer;
   diffX, diffY : integer;
   f : integer;
   pPoint : TLabel2Ptr;
   pStick : TStickmanPtr;
   pLine : TLineObjPtr;
   temp : integer;
begin

   if (frmMain.m_pTweenFrame^.m_nType = O_STICKMAN) then
   begin
      pStick := TStickManPtr(frmMain.m_pTweenFrame^.m_pObject);
      GetStickCenter(pStick, midX, midY);
      for f := 0 to pStick^.PntList.Count-1 do
      begin
         pPoint := pStick^.PntList.Items[f];
         //diffX := pPoint^.Left - midX;
         diffY := pPoint^.Top - midY;
         //pPoint^.Left := midX + (diffX * -1);
         pPoint^.Top := midY + (diffY * -1);
      end;
   end;

   if (frmMain.m_pTweenFrame^.m_nType = O_LINE) then
   begin
      pLine := TLineObjPtr(frmMain.m_pTweenFrame^.m_pObject);
      temp := pLine^.Pnt(1)^.top;
      pLine^.Pnt(1)^.top := pLine^.Pnt(2)^.top;
      pLine^.Pnt(2)^.top := temp;
   end;

   frmMain.Render(frmMain.m_col);

end;

procedure TfrmCanvas.FlipHorizontally1Click(Sender: TObject);
var
   midX, midY : integer;
   diffX, diffY : integer;
   f : integer;
   pPoint : TLabel2Ptr;
   pStick : TStickmanPtr;
   pLine : TLineObjPtr;
   temp : integer;
begin

   if (frmMain.m_pTweenFrame^.m_nType = O_STICKMAN) then
   begin
      pStick := TStickManPtr(frmMain.m_pTweenFrame^.m_pObject);
      GetStickCenter(pStick, midX, midY);
      for f := 0 to pStick^.PntList.Count-1 do
      begin
         pPoint := pStick^.PntList.Items[f];
         diffX := pPoint^.Left - midX;
         //diffY := pPoint^.Top - midY;
         pPoint^.Left := midX + (diffX * -1);
         //pPoint^.Top := midY + (diffY * -1);
      end;
   end;

   if (frmMain.m_pTweenFrame^.m_nType = O_LINE) then
   begin
      pLine := TLineObjPtr(frmMain.m_pTweenFrame^.m_pObject);
      temp := pLine^.Pnt(1)^.left;
      pLine^.Pnt(1)^.left := pLine^.Pnt(2)^.left;
      pLine^.Pnt(2)^.left := temp;
   end;

   frmMain.Render(frmMain.m_col);

end;

procedure swapLabels(var a,b : TLabel2Ptr);
var
   tempLeft, tempTop : integer;
begin
   tempLeft := a^.Left;
   tempTop := a^.Top;
   a^.Top := b^.Top;
   a^.Left := b^.Left;
   b^.Left := tempLeft;
   b^.Top := tempTop;
end;

procedure TfrmCanvas.FlipLegs1Click(Sender: TObject);
var
   a,b,c,d : TLabel2Ptr;
begin
   if (frmMain.m_pTweenFrame^.m_nType = O_STICKMAN) then
   begin
      a := TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.PntList.Items[1];
      b := TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.PntList.Items[3];
      c := TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.PntList.Items[2];
      d := TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.PntList.Items[4];
   end;

   if (frmMain.m_pTweenFrame^.m_nType = O_STICKMANBMP) then
   begin
      a := TStickManBMPPtr(frmMain.m_pTweenFrame^.m_pObject)^.PntList.Items[1];
      b := TStickManBMPPtr(frmMain.m_pTweenFrame^.m_pObject)^.PntList.Items[3];
      c := TStickManBMPPtr(frmMain.m_pTweenFrame^.m_pObject)^.PntList.Items[2];
      d := TStickManBMPPtr(frmMain.m_pTweenFrame^.m_pObject)^.PntList.Items[4];
   end;

   swapLabels(a,b);
   swapLabels(c,d);

   frmMain.Render(frmMain.m_col);
end;

procedure TfrmCanvas.FlipArms1Click(Sender: TObject);
var
   a,b,c,d : TLabel2Ptr;
begin
   if (frmMain.m_pTweenFrame^.m_nType = O_STICKMAN) then
   begin
      a := TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.PntList.Items[6];
      b := TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.PntList.Items[8];
      c := TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.PntList.Items[7];
      d := TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.PntList.Items[9];
   end;

   if (frmMain.m_pTweenFrame^.m_nType = O_STICKMANBMP) then
   begin
      a := TStickManBMPPtr(frmMain.m_pTweenFrame^.m_pObject)^.PntList.Items[6];
      b := TStickManBMPPtr(frmMain.m_pTweenFrame^.m_pObject)^.PntList.Items[8];
      c := TStickManBMPPtr(frmMain.m_pTweenFrame^.m_pObject)^.PntList.Items[7];
      d := TStickManBMPPtr(frmMain.m_pTweenFrame^.m_pObject)^.PntList.Items[9];
   end;

   swapLabels(a,b);
   swapLabels(c,d);

   frmMain.Render(frmMain.m_col);
end;

procedure TfrmCanvas.FormResize(Sender: TObject);
begin
//
   if (frmMain <> nil) and (frmMain.m_bMovieReady) then
   begin
      frmMain.ResizeStage(clientwidth, clientheight);
      frmMain.ReRender();
   end;
end;

end.

unit scale;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, main, ExtCtrls, stickstuff;

type
  TfrmScale = class(TForm)
    cmdOK: TButton;
    cmdCancel: TButton;
    scaler: TTrackBar;
    lblInfo: TLabel;
    imgMove: TImage;
    procedure FormCreate(Sender: TObject);
    procedure scalerChange(Sender: TObject);
    procedure cmdCancelClick(Sender: TObject);
    procedure cmdOKClick(Sender: TObject);
    procedure imgMoveMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgMoveMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgMoveMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    m_bClose, m_bOK : BOOLEAN;
    m_xoffs, m_yoffs : integer;
    m_nX, m_nY : integer;
    m_bMoving : boolean;
    procedure moveScaleKeyFrame(dPercent :double; pKeyFrame : TIFrame);
    procedure moveScaleObject(dPercent : double; pObject : pointer; nType : integer);
  end;

var
  frmScale: TfrmScale;

implementation

{$R *.dfm}

//uses main;

procedure TfrmScale.FormCreate(Sender: TObject);
begin
   m_bClose := FALSE;
   m_bOK := FALSE;
   scaler.position := 100;
   lblInfo.Caption := 'Current scale: 100%';
   m_xoffs := 0;
   m_yoffs := 0;
   m_bMoving := FALSE;
end;

procedure TfrmScale.moveScaleObject(dPercent : double; pObject : pointer; nType : integer);
var
   nPnt : array[1..100,1..2] of integer;
   xdiff,ydiff : integer;
   midX, midY: integer;
   f : integer;
   //
   minX,minY,maxX,maxY : integer;
   pCustom : TLimbList;
begin
   if (nType = O_RECTANGLE) then
   begin
      with TSquareObjPtr(pObject)^ do
      begin
         for f := 1 to 4 do
         begin
            nPnt[f, 1] := Pnt(f)^.Left;
            nPnt[f, 2] := Pnt(f)^.Top;
         end;
         nPnt[5,1] := m_nLineWidth;
         midX := Pnt(1)^.Left + ((Pnt(3)^.Left - Pnt(1)^.Left) div 2);
         midY := Pnt(1)^.Top + ((Pnt(3)^.Top - Pnt(1)^.Top) div 2);
         xdiff := midX - Pnt(1)^.Left;
         ydiff := midY - Pnt(1)^.Top;
         Pnt(1)^.Left := m_xoffs+ (midX - round(xdiff * dPercent));
         Pnt(1)^.Top := m_yoffs+ (midY - round(ydiff * dPercent));
         Pnt(3)^.Left := m_xoffs+ (midX + round(xdiff * dPercent));
         Pnt(3)^.Top := m_yoffs+ (midY + round(ydiff * dPercent));
         Pnt(2)^.Left := Pnt(3)^.Left;
         Pnt(2)^.Top :=  Pnt(1)^.Top;
         Pnt(4)^.Left := Pnt(1)^.Left;
         Pnt(4)^.Top :=  Pnt(3)^.Top;
         m_nLineWidth := round(m_nLineWidth * dPercent);
         frmMain.Render(frmMain.m_col);
         if (m_bClose) and (m_bOK) then
         begin
            Close;
         end else
         begin
            for f := 1 to 4 do
            begin
               Pnt(f)^.Left := nPnt[f, 1];
               Pnt(f)^.Top := nPnt[f, 2];
            end;
            m_nLineWidth := nPnt[5,1];
            if (m_bClose) then Close;
         end;
      end;
   end;
   if (nType = O_OVAL) then
   begin
      with TOvalObjPtr(pObject)^ do
      begin
         for f := 1 to 4 do
         begin
            nPnt[f, 1] := Pnt(f)^.Left;
            nPnt[f, 2] := Pnt(f)^.Top;
         end;
         nPnt[5,1] := m_nLineWidth;
         midX := Pnt(1)^.Left + ((Pnt(3)^.Left - Pnt(1)^.Left) div 2);
         midY := Pnt(1)^.Top + ((Pnt(3)^.Top - Pnt(1)^.Top) div 2);
         xdiff := midX - Pnt(1)^.Left;
         ydiff := midY - Pnt(1)^.Top;
         Pnt(1)^.Left := m_xoffs+ (midX - round(xdiff * dPercent));
         Pnt(1)^.Top := m_yoffs+ (midY - round(ydiff * dPercent));
         Pnt(3)^.Left := m_xoffs+ (midX + round(xdiff * dPercent));
         Pnt(3)^.Top := m_yoffs+ (midY + round(ydiff * dPercent));
         Pnt(2)^.Left := Pnt(3)^.Left;
         Pnt(2)^.Top :=  Pnt(1)^.Top;
         Pnt(4)^.Left := Pnt(1)^.Left;
         Pnt(4)^.Top :=  Pnt(3)^.Top;
         m_nLineWidth := round(m_nLineWidth * dPercent);
         frmMain.Render(frmMain.m_col);
         if (m_bClose) and (m_bOK) then
         begin
            Close;
         end else
         begin
            for f := 1 to 4 do
            begin
               Pnt(f)^.Left := nPnt[f, 1];
               Pnt(f)^.Top := nPnt[f, 2];
            end;
            m_nLineWidth := nPnt[5,1];
            if (m_bClose) then Close;
         end;
      end;
   end;
   if (nType = O_BITMAP) then
   begin
      with TBitmanPtr(pObject)^ do
      begin
         for f := 1 to 4 do
         begin
            nPnt[f, 1] := Pnt(f)^.Left;
            nPnt[f, 2] := Pnt(f)^.Top;
         end;
         midX := Pnt(1)^.Left + ((Pnt(3)^.Left - Pnt(1)^.Left) div 2);
         midY := Pnt(1)^.Top + ((Pnt(3)^.Top - Pnt(1)^.Top) div 2);
         xdiff := midX - Pnt(1)^.Left;
         ydiff := midY - Pnt(1)^.Top;
         Pnt(1)^.Left := m_xoffs+ (midX - round(xdiff * dPercent));
         Pnt(1)^.Top := m_yoffs+ (midY - round(ydiff * dPercent));
         Pnt(3)^.Left := m_xoffs+ (midX + round(xdiff * dPercent));
         Pnt(3)^.Top := m_yoffs+ (midY + round(ydiff * dPercent));
         Pnt(2)^.Left := Pnt(3)^.Left;
         Pnt(2)^.Top :=  Pnt(1)^.Top;
         Pnt(4)^.Left := Pnt(1)^.Left;
         Pnt(4)^.Top :=  Pnt(3)^.Top;
         frmMain.Render(frmMain.m_col);
         if (m_bClose) and (m_bOK) then
         begin
            Close;
         end else
         begin
            for f := 1 to 4 do
            begin
               Pnt(f)^.Left := nPnt[f, 1];
               Pnt(f)^.Top := nPnt[f, 2];
            end;
            if (m_bClose) then Close;
         end;
      end;
   end;
   if (nType = O_LINE) then
   begin
      with TLineObjPtr(pObject)^ do
      begin
         for f := 1 to 2 do
         begin
            nPnt[f, 1] := Pnt(f)^.Left;
            nPnt[f, 2] := Pnt(f)^.Top;
         end;
         nPnt[3,1] := m_nLineWidth;
         midX := Pnt(1)^.Left + ((Pnt(2)^.Left - Pnt(1)^.Left) div 2);
         midY := Pnt(1)^.Top + ((Pnt(2)^.Top - Pnt(1)^.Top) div 2);
         xdiff := midX - Pnt(1)^.Left;
         ydiff := midY - Pnt(1)^.Top;
         Pnt(1)^.Left := m_xoffs+ (midX - round(xdiff * dPercent));
         Pnt(1)^.Top := m_yoffs+ (midY - round(ydiff * dPercent));
         Pnt(2)^.Left := m_xoffs+ (midX + round(xdiff * dPercent));
         Pnt(2)^.Top := m_yoffs+ (midY + round(ydiff * dPercent));
         m_nLineWidth := round(m_nLineWidth * dPercent);
         frmMain.Render(frmMain.m_col);
         if (m_bClose) and (m_bOK) then
         begin
            Close;
         end else
         begin
            for f := 1 to 2 do
            begin
               Pnt(f)^.Left := nPnt[f, 1];
               Pnt(f)^.Top := nPnt[f, 2];
            end;
            m_nLineWidth := nPnt[3,1];
            if (m_bClose) then Close;
         end;
      end;
   end;
   if (nType = O_TEXT) then
   begin
      with TTextObjPtr(pObject)^ do
      begin
         for f := 1 to 4 do
         begin
            nPnt[f, 1] := Pnt(f)^.Left;
            nPnt[f, 2] := Pnt(f)^.Top;
         end;
         midX := Pnt(1)^.Left + ((Pnt(3)^.Left - Pnt(1)^.Left) div 2);
         midY := Pnt(1)^.Top + ((Pnt(3)^.Top - Pnt(1)^.Top) div 2);
         xdiff := midX - Pnt(1)^.Left;
         ydiff := midY - Pnt(1)^.Top;
         Pnt(1)^.Left := m_xoffs+ (midX - round(xdiff * dPercent));
         Pnt(1)^.Top := m_yoffs+ (midY - round(ydiff * dPercent));
         Pnt(3)^.Left := m_xoffs+ (midX + round(xdiff * dPercent));
         Pnt(3)^.Top := m_yoffs+ (midY + round(ydiff * dPercent));
         Pnt(2)^.Left := Pnt(3)^.Left;
         Pnt(2)^.Top :=  Pnt(1)^.Top;
         Pnt(4)^.Left := Pnt(1)^.Left;
         Pnt(4)^.Top :=  Pnt(3)^.Top;
         frmMain.Render(frmMain.m_col);
         if (m_bClose) and (m_bOK) then
         begin
            Close;
         end else
         begin
            for f := 1 to 4 do
            begin
               Pnt(f)^.Left := nPnt[f, 1];
               Pnt(f)^.Top := nPnt[f, 2];
            end;
            if (m_bClose) then Close;
         end;
      end;
   end;
   if (nType = O_POLY) then
   begin
      with TPolyObjPtr(pObject)^ do
      begin
         for f := 1 to PntList.Count do
         begin
            nPnt[f, 1] := Pnt(f)^.Left;
            nPnt[f, 2] := Pnt(f)^.Top;
         end;
         nPnt[PntList.Count+1,1] := m_nLineWidth;
         minX := 32000;
         minY := 32000;
         maxX := -32000;
         maxY := -32000;
         for f := 1 to PntList.Count do
         begin
            if (Pnt(f)^.Left < minX) then minX := Pnt(f)^.Left;
            if (Pnt(f)^.Left > maxX) then maxX := Pnt(f)^.Left;
            if (Pnt(f)^.Top < minY) then minY := Pnt(f)^.Top;
            if (Pnt(f)^.Top > maxY) then maxY := Pnt(f)^.Top;
         end;
         midX := (minX + (maxX - minX) div 2);
         midY := (minY + (maxY - minY) div 2);
         xdiff := midX - minX;
         ydiff := midY - minY;
         for f := 1 to PntList.Count do
         begin
            Pnt(f)^.Left := m_xoffs+ (midX + round((Pnt(f)^.Left-midX) * dPercent));
            Pnt(f)^.Top := m_yoffs+ (midY + round((Pnt(f)^.Top-midY) * dPercent));
         end;
         m_nLineWidth := round(m_nLineWidth * dPercent);
         frmMain.Render(frmMain.m_col);
         if (m_bClose) and (m_bOK) then
         begin
            Close;
         end else
         begin
            for f := 1 to PntList.Count do
            begin
               Pnt(f)^.Left := nPnt[f, 1];
               Pnt(f)^.Top := nPnt[f, 2];
            end;
            m_nLineWidth := nPnt[PntList.Count+1,1];
            if (m_bClose) then Close;
         end;
      end;
   end;
   if (nType = O_STICKMAN) then
   begin
      with TStickmanPtr(pObject)^ do
      begin
         for f := 1 to 10 do
         begin
            nPnt[f, 1] := Pnt(f)^.Left;
            nPnt[f, 2] := Pnt(f)^.Top;
         end;
         for f := 1 to 10 do
         begin
            nPnt[10+f, 1] := Wid[f];
         end;
         for f := 1 to 9 do
         begin
            nPnt[30+f, 1] := Lng[f];
         end;
         nPnt[50,1] := m_nHeadDiam;
         minX := 32000;
         minY := 32000;
         maxX := -32000;
         maxY := -32000;
         for f := 1 to PntList.Count do
         begin
            if (Pnt(f)^.Left < minX) then minX := Pnt(f)^.Left;
            if (Pnt(f)^.Left > maxX) then maxX := Pnt(f)^.Left;
            if (Pnt(f)^.Top < minY) then minY := Pnt(f)^.Top;
            if (Pnt(f)^.Top > maxY) then maxY := Pnt(f)^.Top;
         end;
         midX := (minX + (maxX - minX) div 2);
         midY := (minY + (maxY - minY) div 2);
         xdiff := midX - minX;
         ydiff := midY - minY;
         for f := 1 to 10 do
         begin
            Pnt(f)^.Left := m_xoffs+ (midX + round((Pnt(f)^.Left-midX) * dPercent));
            Pnt(f)^.Top := m_yoffs+ (midY + round((Pnt(f)^.Top-midY) * dPercent));
         end;
         for f := 1 to 10 do
         begin
            Wid[f] := round(Wid[f] * dPercent);
         end;
         for f := 1 to 9 do
         begin
            Lng[f] := round(Lng[f] * dPercent);
         end;
         m_nHeadDiam := round(m_nHeadDiam * dPercent);
         frmMain.Render(frmMain.m_col);
         if (m_bClose) and (m_bOK) then
         begin
            Close;
         end else
         begin
            for f := 1 to 10 do
            begin
               Pnt(f)^.Left := nPnt[f, 1];
               Pnt(f)^.Top := nPnt[f, 2];
            end;
            for f := 1 to 10 do
            begin
               Wid[f] := nPnt[10+f, 1];
            end;
            for f := 1 to 9 do
            begin
               Lng[f] := nPnt[30+f, 1];
            end;
            m_nHeadDiam := nPnt[50,1];
            if (m_bClose) then Close;
         end;
      end;
   end;
//
   if (nType = O_T2STICK) then
   begin
      pCustom := TLimbList.Create;
      pCustom.CopyFrom(TLimbListPtr(pObject)^);
      with TLimbListPtr(pObject)^ do
      begin
         TLimbListPtr(pObject)^.Scale(dPercent);
         frmMain.Render(frmMain.m_col);
         if (m_bClose) and (m_bOK) then
         begin
            pCustom.Destroy;
            Close;
         end else
         begin
            TLimbListPtr(pObject)^.CopyFrom(pCustom);
            pCustom.Destroy;
            if (m_bClose) then Close;
         end;
      end;
   end;
//
   if (nType = O_SPECIALSTICK) then
   begin
      with TSpecialStickmanPtr(pObject)^ do
      begin
         for f := 1 to 14 do
         begin
            nPnt[f, 1] := Pnt(f)^.Left;
            nPnt[f, 2] := Pnt(f)^.Top;
         end;
         for f := 1 to 14 do
         begin
            nPnt[14+f, 1] := Wid[f];
         end;
         for f := 1 to 13 do
         begin
            nPnt[30+f, 1] := Lng[f];
         end;
         nPnt[50,1] := m_nHeadDiam;
         minX := 32000;
         minY := 32000;
         maxX := -32000;
         maxY := -32000;
         for f := 1 to PntList.Count do
         begin
            if (Pnt(f)^.Left < minX) then minX := Pnt(f)^.Left;
            if (Pnt(f)^.Left > maxX) then maxX := Pnt(f)^.Left;
            if (Pnt(f)^.Top < minY) then minY := Pnt(f)^.Top;
            if (Pnt(f)^.Top > maxY) then maxY := Pnt(f)^.Top;
         end;
         midX := (minX + (maxX - minX) div 2);
         midY := (minY + (maxY - minY) div 2);
         xdiff := midX - minX;
         ydiff := midY - minY;
         for f := 1 to 14 do
         begin
            Pnt(f)^.Left := m_xoffs+ (midX + round((Pnt(f)^.Left-midX) * dPercent));
            Pnt(f)^.Top := m_yoffs+ (midY + round((Pnt(f)^.Top-midY) * dPercent));
         end;
         for f := 1 to 14 do
         begin
            Wid[f] := round(Wid[f] * dPercent);
         end;
         for f := 1 to 13 do
         begin
            Lng[f] := round(Lng[f] * dPercent);
         end;
         m_nHeadDiam := round(m_nHeadDiam * dPercent);

         frmMain.Render(frmMain.m_col);
         if (m_bClose) and (m_bOK) then
         begin
            Close;
         end else
         begin
            for f := 1 to 14 do
            begin
               Pnt(f)^.Left := nPnt[f, 1];
               Pnt(f)^.Top := nPnt[f, 2];
            end;
            for f := 1 to 14 do
            begin
               Wid[f] := nPnt[14+f, 1];
            end;
            for f := 1 to 13 do
            begin
               Lng[f] := nPnt[30+f, 1];
            end;
            m_nHeadDiam := nPnt[50,1];
            if (m_bClose) then Close;
         end;
      end;
   end;
//
   if (nType = O_STICKMANBMP) then
   begin
      with TStickmanBMPPtr(pObject)^ do
      begin
         for f := 1 to 10 do
         begin
            nPnt[f, 1] := Pnt(f)^.Left;
            nPnt[f, 2] := Pnt(f)^.Top;
         end;
         for f := 1 to 10 do
         begin
            nPnt[10+f, 1] := Wid[f];
         end;
         for f := 1 to 9 do
         begin
            nPnt[30+f, 1] := Lng[f];
         end;
         nPnt[50,1] := m_nHeadDiam;
         minX := 32000;
         minY := 32000;
         maxX := -32000;
         maxY := -32000;
         for f := 1 to PntList.Count do
         begin
            if (Pnt(f)^.Left < minX) then minX := Pnt(f)^.Left;
            if (Pnt(f)^.Left > maxX) then maxX := Pnt(f)^.Left;
            if (Pnt(f)^.Top < minY) then minY := Pnt(f)^.Top;
            if (Pnt(f)^.Top > maxY) then maxY := Pnt(f)^.Top;
         end;
         midX := (minX + (maxX - minX) div 2);
         midY := (minY + (maxY - minY) div 2);
         xdiff := midX - minX;
         ydiff := midY - minY;
         for f := 1 to 10 do
         begin
            Pnt(f)^.Left := m_xoffs+ (midX + round((Pnt(f)^.Left-midX) * dPercent));
            Pnt(f)^.Top := m_yoffs+ (midY + round((Pnt(f)^.Top-midY) * dPercent));
         end;
         for f := 1 to 10 do
         begin
            Wid[f] := round(Wid[f] * dPercent);
         end;
         for f := 1 to 9 do
         begin
            Lng[f] := round(Lng[f] * dPercent);
         end;
         m_nHeadDiam := round(m_nHeadDiam * dPercent);

         frmMain.Render(frmMain.m_col);
         if (m_bClose) and (m_bOK) then
         begin
            Close;
         end else
         begin
            for f := 1 to 10 do
            begin
               Pnt(f)^.Left := nPnt[f, 1];
               Pnt(f)^.Top := nPnt[f, 2];
            end;
            for f := 1 to 10 do
            begin
               Wid[f] := nPnt[10+f, 1];
            end;
            for f := 1 to 9 do
            begin
               Lng[f] := nPnt[30+f, 1];
            end;
            m_nHeadDiam := nPnt[50,1];
            if (m_bClose) then Close;
         end;
      end;
   end;

end;

procedure TfrmScale.moveScaleKeyFrame(dPercent :double; pKeyFrame : TIFrame);
begin
   moveScaleObject(dPercent, pKeyFrame.m_pObject, pKeyFrame.m_nType);
end;

procedure TfrmScale.scalerChange(Sender: TObject);
var
   dPercent : double;
   f,g,h : integer;
   pLayer : TLayerObjPtr;
   pFrameSet : TSingleFramePtr;
   nFrame : integer;
   pKeyFrame : TIFramePtr;
begin
   dPercent := scaler.position / 100;
   lblInfo.Caption := 'Current scale: ' + floattostr(dPercent*100) + '%';

   {if (frmMain.m_olSelectedLayers.Count > 0) and (not m_bClose) then
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
                     moveScaleKeyFrame(dPercent, pKeyFrame^);
                  end;
               end;
            end;
         end;
      end;
   end else }
   begin
      moveScaleKeyFrame(dPercent, frmMain.m_pTweenFrame^);
   end;

end;

procedure TfrmScale.cmdCancelClick(Sender: TObject);
begin
   m_bOK := FALSE;
   m_bClose := TRUE;
   scalerchange(sender);
end;

procedure TfrmScale.cmdOKClick(Sender: TObject);
begin
   m_bOK := TRUE;
   m_bClose := TRUE;
   scalerchange(sender);
end;

procedure TfrmScale.imgMoveMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := tRUE;
   m_nX := x;
   m_nY := y;
   screen.Cursor := crNone;
   SetCapture(imgMove.Canvas.Handle);
end;

procedure TfrmScale.imgMoveMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   ReleaseCapture;
   screen.Cursor := crDefault;
   m_bMoving := FALSE;
end;

procedure TfrmScale.imgMoveMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   if (m_bMoving) then
   begin
      m_xoffs := x - m_nX;
      m_yoffs := y - m_nY;
      scalerChange(Sender);
   end;
end;

end.

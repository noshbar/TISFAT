unit stickrenderer;

interface

uses classes, stickstuff, stickjoint, graphics, GDIPAPI, GDIPOBJ;

type
   TDeferredItem = class(TObject)
   public
      bitmap : TGPBitmap;
      x,y : integer;
      alpha : single;
      angle : single;
      r,g,b : byte;
      state : integer;
   end;

   TStickRenderer = class(TObject)
   protected
      m_pCanvas : TGPGraphics;
      m_bDrawControlPoints : boolean;
      m_nOffsetX, m_nOffsetY : integer;

      m_olDeferredItems : TList;

      procedure addDeferredBitmap(bitmap : TGPBitmap; x,y : integer; alpha, angle : single);
      procedure addDeferredPoint(state, x,y : integer);
      procedure drawPoint(Pt : TDeferredItem);
      procedure clearDeferredItems;

      procedure DrawBorder(x,y,wide,high : integer; r,g,b : byte; linewide : integer; alpha, angle : single);
      procedure DrawEllipse(x,y,wide,high : integer; r,g,b,fr,fg,fb : byte; linewide : integer; alpha, angle : single);
      procedure DrawEllipseBorder(x,y,wide,high : integer; r,g,b : byte; linewide : integer; alpha, angle : single);
      procedure DrawImage(x,y,wide,high : integer; alpha, angle : single; pImage : TGPBitmap);

      procedure DrawJoint(pStick : TLimbList; pJoint, pChild : TJoint; alpha : single);
      procedure DrawChild(pStick : TLimbList; olPointys : TList; pParent, pJoint : TJoint; alpha : single; nCurveWidth : integer);
      procedure previewStick(pStick : TLimbList; angle : single; canvas : TCanvas);
      procedure drawJointBitmap(pStick : TLimbList; pJoint, pChild : TJoint; alpha : single);
   public
      constructor Create(Canvas : TGPGraphics);
      destructor Destroy; override;

      procedure DrawStick(pStick : TLimbList; angle : single; alpha : byte);
      procedure DrawLine(x,y,wide,high : integer; r,g,b : byte; linewide : integer; alpha, angle : single);
      procedure DrawRect(x,y,wide,high : integer; r,g,b,fr,fg,fb : byte; linewide : integer; alpha, angle : single);

      property Canvas : TGPGraphics read m_pCanvas write m_pCanvas;
      property DrawControlPoints : boolean read m_bDrawControlPoints write m_bDrawControlPoints;
      property XOffset : integer read m_nOffsetX write m_nOffsetX;
      property YOffset : integer read m_nOffsetY write m_nOffsetY;
   end;

implementation

uses math, jointbitmap;

constructor TStickRenderer.Create(Canvas : TGPGraphics);
begin
   m_nOffsetX := 0;
   m_nOffsetY := 0;
   m_pCanvas := Canvas;
   m_olDeferredItems := TList.Create;
end;

destructor TStickRenderer.Destroy;
begin
   clearDeferredItems;
   m_olDeferredItems.Free;
   inherited;
end;

procedure TStickRenderer.clearDeferredItems;
var
   bmp : TDeferredItem;
   f : integer;
begin
   for f := 0 to m_olDeferredItems.Count-1 do
   begin
      bmp := m_olDeferredItems.Items[f];
      bmp.Free;
   end;
   m_olDeferredItems.Clear;
end;

procedure TStickRenderer.addDeferredBitmap(bitmap : TGPBitmap; x,y : integer; alpha, angle : single);
var
   bmp : TDeferredItem;
begin
   bmp := TDeferredItem.Create;
   bmp.bitmap := bitmap;
   bmp.x := x;
   bmp.y := y;
   bmp.alpha := alpha;
   bmp.angle := angle;
   m_olDeferredItems.Add(bmp);
end;

procedure TStickRenderer.addDeferredPoint(state, x,y : integer);
var
   Pt : TDeferredItem;
begin
   Pt := TDeferredItem.Create;
   Pt.bitmap := nil;
   Pt.x := x;
   Pt.y := y;
   Pt.state := state;
   m_olDeferredItems.Add(Pt);
end;

procedure TStickRenderer.drawPoint(Pt : TDeferredItem);
begin
   if (Pt.State = C_STATE_NORMAL) then
   begin
      DrawBorder(Pt.x, Pt.y, 8,8, 0,255,0, 1, 0.6, 0);
   end;
   if (Pt.State = C_STATE_SELECTED) then
   begin
      DrawBorder(Pt.x, Pt.y, 12,12, 0,0,0, 1, 0.6, 0);
   end;
   if (Pt.State = C_STATE_LOCKED) then
   begin
      DrawBorder(Pt.x, Pt.y, 8,8, 0,0,255, 1, 0.6, 0);
   end;
   if (Pt.State = C_STATE_ADJUST_TO_PARENT) then
   begin
      DrawEllipse(Pt.X,Pt.Y,8,8, 0,0,0, 255,255,255, 1, 0.6,0);
      DrawEllipse(Pt.X,Pt.Y,4,4, 0,0,0, 255,255,255, 1, 0.6,0);
   end;
   if (Pt.State = C_STATE_ADJUST_TO_PARENT_LOCKED) then
   begin
      DrawEllipse(Pt.X,Pt.Y,8,8, 255,0,0, 255,255,255, 1, 0.6,0);
      DrawEllipse(Pt.X,Pt.Y,4,4, 255,0,0, 255,255,255, 1, 0.6,0);
   end;
end;

procedure TStickRenderer.drawJointBitmap(pStick : TLimbList; pJoint, pChild : TJoint; alpha : single);
var
   dAngle : real;
   posAngle : real;
   x,y : integer;
   bmp : TGPBitmap;
begin
   if (pJoint = nil) then
      exit;
   if (pChild = nil) then
      exit;
   if (pJoint.CurrentBitmap = -1) then
      exit;

   dAngle := 180 * (1 + ArcTan2(pJoint.y-pChild.Y, pJoint.x-pChild.x) / PI);
   dAngle := dAngle + 270;
   x := pChild.X + ((pJoint.X - pChild.X) div 2);
   y := pChild.Y + ((pJoint.Y - pChild.Y) div 2);
   // offset the bitmap from the centre point
   posAngle := degtorad(dAngle-90);
   x := x + round(  (cos(posAngle) * pJoint.BitmapY) - (sin(posAngle) * pJoint.BitmapX)  );
   y := y + round(  (cos(posAngle) * pJoint.BitmapX) + (sin(posAngle) * pJoint.BitmapY)  );
   //
   bmp := pStick.Bitmap[pJoint.CurrentBitmap];
   if (bmp <> nil) then
      addDeferredBitmap(bmp, x,y, alpha, dAngle+pJoint.BitmapRotation);
end;

procedure TStickRenderer.DrawJoint(pStick : TLimbList; pJoint, pChild : TJoint; alpha : single);
var
   dAngle : real;
   r,g,b : byte;
   fr,fg,fb : byte;

   w,h,l : integer;
   midX,midY : integer;
begin

   if (pJoint.ShowStick) then
   begin
      r := pJoint.Colour;
      g := pJoint.Colour shr 8;
      b := pJoint.Colour shr 16;
      fr := pJoint.FillColour;
      fg := pJoint.FillColour shr 8;
      fb := pJoint.FillColour shr 16;

      w := pChild.X - pJoint.X;
      h := pChild.Y - pJoint.Y;
      dAngle := 180 * (1 + ArcTan2(h, w) / PI);
      dAngle := dAngle + 90;

      midX := pChild.X - (w div 2);
      midY := pChild.Y - (h div 2);

      if (pJoint.DrawAs = C_DRAW_AS_LINE) then
      begin
         DrawLine(pChild.X, pChild.Y, pJoint.X-pChild.X, pJoint.Y-pChild.Y, r,g,b, pJoint.width, alpha, 0);
      end;
      if (pJoint.DrawAs = C_DRAW_AS_RECT) then
      begin
         if (pJoint.Fill) then
            DrawRect(midX, midY, pJoint.DrawWidth, pJoint.Length, r,g,b, fr,fg,fb, pJoint.Width, alpha, dAngle)
         else
            DrawBorder(midX, midY, pJoint.DrawWidth, pJoint.Length, r,g,b, pJoint.Width, alpha, dAngle);
      end;
      if (pJoint.DrawAs = C_DRAW_AS_CIRCLE) then
      begin
         l := round(sqrt(sqr(w)+sqr(h)));
         if (pJoint.Fill) then
            DrawEllipse(midX, midY, l,l, r,g,b, fr,fg,fb, pJoint.Width, alpha, dAngle)
         else
            DrawEllipseBorder(midX, midY, l,l, r,g,b, pJoint.Width, alpha, dAngle);
      end;

   end;

   drawJointBitmap(pStick, pJoint, pChild, alpha);

   if not m_bDrawControlPoints then exit;

   addDeferredPoint(pJoint.State, pJoint.X,pJoint.Y);
end;

procedure TStickRenderer.DrawChild(pStick : TLimbList; olPointys : TList; pParent, pJoint : TJoint; alpha : single; nCurveWidth : integer);
var
   f, g : integer;
   pChild : TJoint;
   pointy : PGPPointF;
   pointArray : array of TGPPointF;
   pPen : TGPPen;
   bSplitter : boolean;

   bitmap : TGPBitmap;
   dAngle, posAngle : single;
   x,y : integer;

   p : TJoint;
begin

   bSplitter := false;

   if (olPointys <> nil) then
   begin
              //HACK
               if (pJoint.CurrentBitmap <> -1) then
               begin
                  p := pJoint.Parent;
                  if (p = nil) then
                     p := pParent;
                  dAngle := 180 * (1 + ArcTan2(p.Y - pJoint.y, p.X - pJoint.x) / PI);
                  dAngle := dAngle + 90;
                  x := pJoint.X + ((p.X - pJoint.X) div 2);
                  y := pJoint.Y + ((p.Y - pJoint.Y) div 2);
                  // offset the bitmap from the centre point
                  posAngle := degtorad(dAngle-90);
                  x := x + round(  (cos(posAngle) * pJoint.BitmapY) - (sin(posAngle) * pJoint.BitmapX)  );
                  y := y + round(  (cos(posAngle) * pJoint.BitmapX) + (sin(posAngle) * pJoint.BitmapY)  );
                  //
                  bitmap := pStick.Bitmap[pJoint.CurrentBitmap];
                  if (bitmap <> nil) then
                     addDeferredBitmap(bitmap, x,y, alpha, dAngle+pJoint.BitmapRotation);
               end;

      //add yourself as the start point ONLY IF YOU'RE NOT A SPLITTER ON COMPLEX SHAPE
      if (pJoint.DrawAs = C_DRAW_AS_LINE) {or (pJoint.DrawAs = C_DRAW_AS_BITMAP)} then
      begin
         new(pointy);
         pointy^.X := pJoint.X;
         pointy^.Y := pJoint.Y;
         olPointys.Add(pointy);
      end;

      bSplitter := pJoint.m_olChildren.Count <> 1;
      bSplitter := bSplitter or (pJoint.DrawAs <> C_DRAW_AS_LINE);

      if (bSplitter) then
      begin
         setlength(pointArray, olPointys.Count);
         for f := 0 to olPointys.Count-1 do
         begin
            pointy := olPointys.Items[f];
            if m_bDrawControlPoints then
               addDeferredPoint(pJoint.State, round(pointy^.X),round(pointy^.Y));
            pointArray[f] := pointy^;
            freemem(pointy);
         end;

         m_pCanvas.ResetTransform();
         m_pCanvas.TranslateTransform(m_nOffsetX,m_nOffsetY);
         pPen := TGPPen.Create(makecolor(round(alpha*255), 0,0,0), nCurveWidth);
   pPen.SetStartCap(LineCapRound);
   pPen.SetEndCap(LineCapRound);
         m_pCanvas.DrawCurve(pPen, PGPPointF(pointArray), olPointys.Count, pStick.Tension);
         pPen.Destroy;
         setlength(pointArray, 0);
         olPointys.Clear;
         // if you're not the end of the line, you have to add yourself as a start point
         if (pJoint.m_olChildren.Count <> 0) then
         begin
            new(pointy);
            pointy^.X := pJoint.X;
            pointy^.Y := pJoint.Y;
            olPointys.Add(pointy);
         end;

         if (pJoint.DrawAs <> C_DRAW_AS_LINE) {and (pJoint.DrawAs <> C_DRAW_AS_BITMAP)} then
         begin
            if (pParent <> nil) then
            begin
               DrawJoint(pStick, pJoint, pParent, alpha);
            end;
         end;
      end;
   end;

   for f := 0 to pJoint.m_olChildren.Count-1 do
   begin
      pChild := pJoint.m_olChildren.Items[f];
      if (olPointys = nil) then    //normal stick figure
      begin
         DrawJoint(pStick, pChild, pJoint, alpha);
         DrawChild(pStick, olPointys, pJoint, pChild, alpha, nCurveWidth);
      end else
      begin         //curvy stick
         DrawChild(pStick, olPointys, pJoint, pChild, alpha, nCurveWidth);
         if (bSplitter) then
         begin
            for g := 0 to olPointys.Count-1 do
            begin
               pointy := olPointys.Items[g];
               freemem(pointy);
            end;
            olPointys.Clear;
            new(pointy);
            pointy^.X := pJoint.X;
            pointy^.Y := pJoint.Y;
            olPointys.Add(pointy);
         end;
      end;
   end;

end;

procedure TStickRenderer.previewStick(pStick : TLimbList; angle : single; canvas : TCanvas);
var
   f : integer;
   pJoint : TJoint;
   pBackup : TGPGraphics;
   l,t,r,b : integer;
begin
   pBackup := m_pCanvas;
   m_pCanvas := TGPGraphics.Create(canvas.handle);
   m_bDrawControlPoints := false;

   m_pCanvas.ResetTransform();

   pStick.GetExtent(l,t,r,b);
   pStick.Move(-l,-t);

   for f := 0 to pStick.JointCount-1 do
   begin
      pJoint := pStick.Joint[f];
      DrawChild(pStick, nil, nil, pJoint, 1.0, pStick.CurveWidth);
   end;
   pStick.Move(l,t);

   m_pCanvas.Free;
   m_pCanvas := pBackup;

   m_bDrawControlPoints := true;
end;

procedure TStickRenderer.DrawStick(pStick : TLimbList; angle : single; alpha : byte);
var
   f, g : integer;
   pJoint : TJoint;
   pointy : PGPPointF;
   olPointys : TList;
   ite : TDeferredItem;
begin
   //m_bShowJoints := pStick.ShowJoints;
   clearDeferredItems;

   m_pCanvas.ResetTransform();
   olPointys := nil;

   for f := 0 to pStick.JointCount-1 do
   begin
      if (pStick.DrawMode = C_STICK_DRAWMODE_CURVY) then
         olPointys := TList.Create;

      pJoint := pStick.Joint[f];
      DrawChild(pStick, olPointys, nil, pJoint, {pStick.}Alpha/255, pStick.CurveWidth);
      if (olPointys <> nil) then
      begin
         for g:= 0 to olPointys.Count-1 do
         begin
            pointy := olPointys.Items[g];
            freemem(pointy);
         end;
         olPointys.Destroy;
      end;
      //
      if m_bDrawControlPoints then
      begin
         DrawRect(pJoint.X,pJoint.Y, 8, 8, 0,0,0, 255,0,0, 1, 1.0, 0);
         DrawEllipse(pJoint.X,pJoint.Y, 8, 8, 0,0,0, 255,128,128, 1, 1.0, 0);
      end;
   end;

   for f := 0 to m_olDeferredItems.Count-1 do
   begin
      ite := m_olDeferredItems.Items[f];
      if (ite.bitmap <> nil) then
         DrawImage(ite.x, ite.y, ite.bitmap.GetWidth, ite.bitmap.GetHeight, ite.alpha, ite.angle, ite.bitmap);
   end;
   for f := 0 to m_olDeferredItems.Count-1 do
   begin
      ite := m_olDeferredItems.Items[f];
      if (ite.bitmap = nil) then
         DrawPoint(ite);
   end;
   clearDeferredItems;
end;

procedure TStickRenderer.DrawLine(x,y,wide,high : integer; r,g,b : byte; linewide : integer; alpha, angle : single);
var
   pen : TGPPen;
begin
   if (linewide = 0) then exit;
   pen := TGPPen.Create(MakeColor(round(alpha*255), r,g,b), linewide);
   pen.SetStartCap(LineCapRound);
   pen.SetEndCap(LineCapRound);
   m_pCanvas.ResetTransform();
   m_pCanvas.TranslateTransform(m_nOffsetX+x,m_nOffsetY+y);
   m_pCanvas.RotateTransform(angle);
   m_pCanvas.DrawLine(pen, 0,0, wide,high);
   pen.Free;
end;

procedure TStickRenderer.DrawRect(x,y,wide,high : integer; r,g,b,fr,fg,fb : byte; linewide : integer; alpha, angle : single);
var
   pen : TGPPen;
   brush : TGPSolidBrush;
begin
   pen := TGPPen.Create(MakeColor(round(alpha*255), r,g,b), linewide);
   brush := TGPSolidBrush.Create(MakeColor(round(alpha*255), fr,fg,fb));
   m_pCanvas.ResetTransform();
   m_pCanvas.TranslateTransform(m_nOffsetX+x,m_nOffsetY+y);
   m_pCanvas.RotateTransform(angle);
   m_pCanvas.FillRectangle(brush, -wide div 2,-high div 2, wide,high);
   m_pCanvas.DrawRectangle(pen, -wide div 2,-high div 2, wide,high);
   pen.Free;
   brush.Free;
end;

procedure TStickRenderer.DrawBorder(x,y,wide,high : integer; r,g,b : byte; linewide : integer; alpha, angle : single);
var
   pen : TGPPen;
begin
   pen := TGPPen.Create(MakeColor(round(alpha*255),r,g,b), linewide);
   m_pCanvas.ResetTransform();
   m_pCanvas.TranslateTransform(m_nOffsetX+x,m_nOffsetY+y);
   m_pCanvas.RotateTransform(angle);
   m_pCanvas.DrawRectangle(pen, -wide div 2,-high div 2, wide,high);
   pen.Free;
end;

procedure TStickRenderer.DrawEllipse(x,y,wide,high : integer; r,g,b,fr,fg,fb : byte; linewide : integer; alpha, angle : single);
var
   pen : TGPPen;
   brush : TGPSolidBrush;
begin
   pen := TGPPen.Create(MakeColor(round(alpha*255), r,g,b), linewide);
   brush := TGPSolidBrush.Create(MakeColor(round(alpha*255), fr,fg,fb));
   m_pCanvas.ResetTransform();
   m_pCanvas.TranslateTransform(m_nOffsetX+x,m_nOffsetY+y);
   m_pCanvas.RotateTransform(angle);
   m_pCanvas.FillEllipse(brush, -wide div 2,-high div 2, wide,high);
   m_pCanvas.DrawEllipse(pen, -wide div 2,-high div 2, wide,high);
   pen.Free;
   brush.Free;
end;

procedure TStickRenderer.DrawEllipseBorder(x,y,wide,high : integer; r,g,b : byte; linewide : integer; alpha, angle : single);
var
   pen : TGPPen;
begin
   pen := TGPPen.Create(MakeColor(round(alpha*255), r,g,b), linewide);
   m_pCanvas.ResetTransform();
   m_pCanvas.TranslateTransform(m_nOffsetX+x,m_nOffsetY+y);
   m_pCanvas.RotateTransform(angle);
   m_pCanvas.DrawEllipse(pen, -wide div 2,-high div 2, wide,high);
   pen.Free;
end;

procedure TStickRenderer.DrawImage(x,y,wide,high : integer; alpha, angle : single; pImage : TGPBitmap);
var
   pAttribs : TGPImageAttributes;
   destRect : TGPRect;
   colorMatrix : TColorMatrix;
begin
   m_pCanvas.ResetTransform();
   m_pCanvas.TranslateTransform(m_nOffsetX+x,m_nOffsetY+y);
   m_pCanvas.RotateTransform(angle);

   if (alpha >= 1) then
   begin
      m_pCanvas.DrawImage(pImage, -wide div 2,-high div 2,wide,high);
   end else
   begin
      colorMatrix[0,0] := 1; colorMatrix[1,0] := 0; colorMatrix[2,0] := 0; colorMatrix[3,0] := 0; colorMatrix[4,0] := 0;
      colorMatrix[0,1] := 0; colorMatrix[1,1] := 1; colorMatrix[2,1] := 0; colorMatrix[3,1] := 0; colorMatrix[4,1] := 0;
      colorMatrix[0,2] := 0; colorMatrix[1,2] := 0; colorMatrix[2,2] := 1; colorMatrix[3,2] := 0; colorMatrix[4,2] := 0;
      colorMatrix[0,3] := 0; colorMatrix[1,3] := 0; colorMatrix[2,3] := 0; colorMatrix[3,3] := alpha; colorMatrix[4,3] := 0;
      colorMatrix[0,4] := 0; colorMatrix[1,4] := 0; colorMatrix[2,4] := 0; colorMatrix[3,4] := 0; colorMatrix[4,4] := 1;
      pAttribs := TGPImageAttributes.Create();
      pAttribs.SetColorMatrix(colorMatrix, ColorMatrixFlagsDefault, ColorAdjustTypeBitmap);

      destRect.X := -wide div 2;
      destRect.Y := -high div 2;
      destRect.width := wide;
      destRect.height := high;
      m_pCanvas.DrawImage(pImage, destRect, 0,0, pImage.GetWidth,pImage.GetHeight, UnitPixel, pAttribs);

      pAttribs.Destroy;
   end;
end;

end.

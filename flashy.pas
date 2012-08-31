unit flashy;

interface

uses main, math, classes;

procedure ExportFlash(strFileName, strSoundtrack : string; var olLayers : TList);

implementation

uses windows, jpeg, stickstuff, stickjoint, GDIPAPI, GDIPOBJ, GDIPUTIL, ming, shlobj;

const
    TYPE_MORPH = 1;
    TYPE_MANUAL = 2;

type
    TBox = record
       x1,y1,x2,y2 : integer;
       alpha : byte;
       angle : single;
    end;

    THolder = class
    public
        m_nMin, m_nMax : integer;
        m_nType : integer;
        m_nCurrent, m_nTotal : integer;
        m_pDisplay : pointer;
        m_pMorph : pointer;
        startbox, endbox : TBox;
        m_nImageHeight, m_nImageWidth : integer;
        m_szImage : array[0..255] of char;
        m_pStartShape, m_pEndShape : pointer;
    end;

   TMovieClipCombo = class(TObject)
   protected
      m_clip : SWFMovieClip;
   public
      startFrame, stopFrame : integer;
      item : SWFDisplayItem;
      constructor Create(c : SWFMovieClip; start,stop : integer);

      property Clip : SWFMovieClip read m_clip;
   end;

constructor TMovieClipCombo.Create(c : SWFMovieClip; start,stop : integer);
begin
  m_clip := c;
  startFrame := start;
  stopFrame := stop;
end;

procedure DWORDtoRGB(t : longword; var r,g,b : byte);
begin
   b := t shr 16;
   g := t shr 8;
   r := t;
end;

function GetLastFrame(var olLayers : TList) : integer;
var
   pLayer : TLayerObjPtr;
   pFrameSet : TSingleFramePtr;
   pFrame : TIFramePtr;
   nLastFrame : integer;
   f,g,h : integer;
begin
   nLastFrame := 0;
   for f := 0 to olLayers.Count-1 do
   begin
      pLayer := olLayers.Items[f];
      for g := 0 to pLayer^.m_olFrames.Count-1 do
      begin
         pFrameSet := pLayer^.m_olFrames.Items[g];
         for h := 0 to pFrameSet^.m_Frames.Count-1 do
         begin
            pFrame := pFrameSet^.m_Frames.Items[h];
            if pFrame^.m_FrameNo > nLastFrame then
               nLastFrame := pFrame^.m_FrameNo;
         end;
      end;
   end;
   GetLastFrame := nLastFrame;
end;

/////////////////////////////////////////////

procedure ShapeLine(shape : SWFShape; x1,y1,x2,y2 : integer; r,g,b,a : byte; lineWidth : integer);
begin
   SWFShape_setLine(shape, lineWidth, r,g,b,a);
   SWFShape_movePenTo(shape, x1,y1);
   SWFShape_drawLineTo(shape, x2,y2);
end;

procedure ShapeComplete(shape : SWFShape);
begin
   SWFShape_end(shape);
end;

procedure ShapeCircle(shape : SWFShape; x1,y1,x2,y2 : integer; r,g,b,fr,fg,fb,a : byte; lineWidth : integer);
var
   fill : SWFFillStyle;
   wide : single;
   high : single;
   centerX, centerY : single;
   xrCtrl, yrCtrl : single;
	 index : integer;
	 angle, theta, angleMid : single;
	 cx,cy,px,py : single;
begin
   wide := (x2-x1) / 2;
   high := (y2-y1) / 2;

   centerX := x1 + wide;
   centerY := y1 + high;
   theta   := 0.78539816339744830962;

   xrCtrl := wide/cos(theta/2.0);
   yrCtrl := high/cos(theta/2.0);
   angle := 0;

	 fill := SWFShape_addSolidFillStyle(shape, fr,fg,fb, a);
	 SWFShape_setLeftFillStyle(shape, fill);

	 SWFShape_setLine(shape, lineWidth, r,g,b, a);
   SWFShape_movePenTo(shape, centerX + wide, centerY);

	 for index := 0 to 7 do
	 begin
      angle := angle + theta;
      angleMid := angle-(theta/2.0);
      cx := centerX+cos(angleMid)*xrCtrl;
      cy := centerY+sin(angleMid)*yrCtrl;
      px := centerX+cos(angle)*wide;
      py := centerY+sin(angle)*high;
      SWFShape_drawCurveTo(shape, cx, cy, px, py);
   end;
end;

procedure ShapeCircle2(shape : SWFShape; width, height : integer; r,g,b,fr,fg,fb,a : byte; lineWidth : integer);
var
   fill : SWFFillStyle;
   xrCtrl, yrCtrl : single;
	 index : integer;
	 angle, theta, angleMid : single;
	 cx,cy,px,py : single;
   wide,high : single;
begin
   wide := width / 2;
   high := height / 2;
   theta   := 0.78539816339744830962;

   xrCtrl := wide/cos(theta/2.0);
   yrCtrl := high/cos(theta/2.0);
   angle := 0;

	 fill := SWFShape_addSolidFillStyle(shape, fr,fg,fb, a);
	 SWFShape_setLeftFillStyle(shape, fill);

	 SWFShape_setLine(shape, lineWidth, r,g,b, a);
   SWFShape_movePenTo(shape, wide, 0);

	 for index := 0 to 7 do
	 begin
      angle := angle + theta;
      angleMid := angle-(theta/2.0);
      cx := cos(angleMid)*xrCtrl;
      cy := sin(angleMid)*yrCtrl;
      px := cos(angle)*wide;
      py := sin(angle)*high;
      SWFShape_drawCurveTo(shape, cx, cy, px, py);
   end;
end;

procedure ShapeRectangle(shape : SWFShape; x1,y1,x2,y2 : integer; r,g,b,fr,fg,fb,a : byte; lineWidth : integer);
var
   fill : SWFFillStyle;
begin
	fill := SWFShape_addSolidFillStyle(shape, fr,fg,fb, a);
	SWFShape_setLeftFillStyle(shape, fill);

	SWFShape_setLine(shape, lineWidth, r,g,b, a);
	SWFShape_movePenTo(shape, x1,y1);
	SWFShape_drawLineTo(shape, x2,y1);
	SWFShape_drawLineTo(shape, x2,y2);
	SWFShape_drawLineTo(shape, x1,y2);
	SWFShape_drawLineTo(shape, x1,y1);
end;

function MorphCreate(movie : SWFMovie; var shape1, shape2 : SWFShape) : SWFMorph;
var
  morph : SWFMorph;
begin
  MorphCreate := nil;
  morph := newSWFMorphShape();
  if (morph = nil) then
     exit;
  shape1 := SWFMorph_getShape1(morph);
  shape2 := SWFMorph_getShape2(morph);
  MorphCreate := morph;
end;

procedure MorphMorph(item : SWFDisplayItem; nCurrent : integer; nMax : integer);
begin
	if (item = nil) then
		exit;

	SWFDisplayItem_setRatio(item, nCurrent/nMax);
end;

function MorphShow(movie : SWFMovie; morph : SWFMorph) : SWFDisplayItem;
var
	item : SWFDisplayItem;
begin
  MorphShow := nil;
	if ((movie = nil) or (morph = nil)) then
		exit;

	item := SWFMovie_add(movie, morph);
	MorphShow := item;
end;

procedure DisplayHide(movie : SWFMovie; item : SWFDisplayItem);
begin
	if ((movie = nil) or (item = nil)) then
		exit;

	SWFMovie_remove(movie, item);
end;

function MovieAddBitmap(movie : SWFMovieClip; image : TGPImage; depth : integer; var width,height : integer) : SWFDisplayItem;
var
   bitmap : SWFDBLBitmapData;
   strTempFileName : string;
   tempFileName : array[0..255] of char;
   id : TGUID;
   item : SWFDisplayItem;
begin
   GetTempPath(255, tempFileName);
   strTempFileName := tempFileName;
   GetTempFileName(pchar(strTempFileName), 'tisbmp', 0, tempFileName);
   strTempFileName := tempFileName;
   GetEncoderClsid('image/png', id);
   image.Save(strTempFileName, id);

   bitmap := newSWFDBLBitmapData_fromPngFile(pChar(strTempFileName));
   item := SWFMovieClip_add(movie, bitmap);

   SWFDisplayItem_setDepth(item, depth);
   DeleteFile(pChar(strTempFileName));
   MovieAddBitmap := item;

   width := image.GetWidth();
   height := image.GetHeight();
end;

function MovieAddText(movie : SWFMovieClip; text, fontName : string; depth : integer; var width,height : integer) : SWFDisplayItem;
var
   font : SWFFont;
   item : SWFDisplayItem;
   texy : SWFText;
   fontPath : string;
   advance : integer;
   fontDir : array[0..255] of char;
   pidl : PITEMIDLIST;
begin
   MovieAddText := nil;

   if (SHGetSpecialFolderLocation(0,CSIDL_FONTS,pidl) <> NOERROR) then
     exit;

   SHGetPathFromIDList(pidl,fontDir);

   fontPath := fontDir;
   fontPath := fontPath + '\' + fontName + '.ttf';
   font := newSWFFont_fromFile(pchar(fontPath));

   texy := newSWFText();
   SWFText_setFont(texy, font);
   advance := 1; //really?
   SWFText_addString(texy, pchar(text), advance);
   SWFText_setColor(texy, 255,255,255,255);
   SWFText_setHeight(texy, 100);

   item := SWFMovieClip_add(movie, texy);
   SWFDisplayItem_setDepth(item, depth);
   MovieAddText := item;

   height := 100;
   width := round(SWFText_getStringWidth(texy, pchar(text)));
end;

procedure ShapeBitmap(item : SWFDisplayItem; x, y : integer; xScale, yScale : single; a : byte; angle : single);
begin

end;

procedure MovieNextFrame(movie : SWFMovie);
begin
  SWFMovie_nextFrame(movie);
end;

/////////////////////////////////////////////
procedure drawLine(xo,yo : integer; pShape : SWFShape; pLine : TLineObjPtr);
var
   r,g,b : byte;
begin
   with pLine^ do
   begin
      DWORDtoRGB(m_Colour, r,g,b);
      ShapeLine(pShape, xo+Pnt(1)^.Left, yo+Pnt(1)^.Top, xo+Pnt(2)^.Left, yo+Pnt(2)^.Top, r,g,b,m_alpha, m_nLineWidth);
      ShapeComplete(pShape);
   end;
end;

procedure drawPoly(xo,yo : integer; shape : SWFShape; pPoly : TPolyObjPtr);
var
   r,g,b : byte;
   r2,g2,b2 : byte;
   f : integer;
   fill : SWFFillStyle;
begin
   with pPoly^ do
   begin
      DWORDtoRGB(m_outColour, r,g,b);
      DWORDtoRGB(m_inColour, r2,g2,b2);

      SWFShape_setLine(shape, m_nLineWidth, r,g,b,m_alpha);
      fill := newSWFSolidFillStyle(r2,g2,b2,m_alpha);
      SWFShape_setLeftFillStyle(shape, fill);
      SWFShape_movePenTo(shape, xo+Pnt(1)^.Left, yo+Pnt(1)^.Top);

      for f := 2 to PntList.Count-1 do
      begin
         SWFShape_drawLineTo(shape, xo+Pnt(f)^.Left, yo+Pnt(f)^.Top);
      end;
      SWFShape_drawLineTo(shape, xo+Pnt(1)^.Left, yo+Pnt(1)^.Top);
      ShapeComplete(shape);
   end;
end;

procedure drawOval(xo,yo : integer; pShape : pointer; pOval : TOvalObjPtr);
var
   r,g,b : byte;
   r2,g2,b2 : byte;
begin
   with pOval^ do
   begin
      DWORDtoRGB(m_outColour, r,g,b);
      DWORDtoRGB(m_inColour, r2,g2,b2);
      ShapeCircle(pShape, Pnt(1)^.Left, Pnt(1)^.Top, Pnt(3)^.Left, Pnt(3)^.Top, r,g,b, r2,g2,b2, m_alpha, m_nLineWidth);
      ShapeComplete(pShape);
   end;
end;

procedure drawRect(xo,yo : integer; pShape : pointer; pRect : TSquareObjPtr);
var
   r,g,b : byte;
   r2,g2,b2 : byte;
begin
   with pRect^ do
   begin
      DWORDtoRGB(m_outColour, r,g,b);
      DWORDtoRGB(m_inColour, r2,g2,b2);
      ShapeRectangle(pShape, xo+Pnt(1)^.Left, yo+Pnt(1)^.Top, xo+Pnt(3)^.Left, yo+Pnt(3)^.Top, r,g,b, r2,g2,b2, m_alpha, m_nLineWidth);
      ShapeComplete(pShape);
   end;
end;

procedure drawStick(xo,yo : integer; pShape : pointer; pStick : TStickManPtr);
var
   sr,sg,sb : byte;
   br,bg,bb : byte;
   angle : double;
   Rads : double;
   cx, cy : double;
begin
   with pStick^ do
   begin
      DWORDtoRGB(m_OutColour, sr,sg,sb);
      ShapeLine(pShape,
                Pnt(6)^.Left+xo, Pnt(6)^.Top+yo,
                Pnt(1)^.Left+xo, Pnt(1)^.Top+yo,
                sr,sg,sb, m_alpha,
                Wid[5]);

      ShapeLine(pShape,
                Pnt(1)^.Left+xo, Pnt(1)^.Top+yo,
                Pnt(2)^.Left+xo, Pnt(2)^.Top+yo,
                sr,sg,sb, m_alpha,
                Wid[1]);

      ShapeLine(pShape,
                Pnt(2)^.Left+xo, Pnt(2)^.Top+yo,
                Pnt(3)^.Left+xo, Pnt(3)^.Top+yo,
                sr,sg,sb, m_alpha,
                Wid[2]);

      ShapeLine(pShape,
                Pnt(1)^.Left+xo, Pnt(1)^.Top+yo,
                Pnt(4)^.Left+xo, Pnt(4)^.Top+yo,
                sr,sg,sb, m_alpha,
                Wid[3]);

      ShapeLine(pShape,
                Pnt(4)^.Left+xo, Pnt(4)^.Top+yo,
                Pnt(5)^.Left+xo, Pnt(5)^.Top+yo,
                sr,sg,sb, m_alpha,
                Wid[4]);

      ShapeLine(pShape,
                Pnt(6)^.Left+xo, Pnt(6)^.Top+yo,
                Pnt(7)^.Left+xo, Pnt(7)^.Top+yo,
                sr,sg,sb, m_alpha,
                Wid[6]);

      ShapeLine(pShape,
                Pnt(7)^.Left+xo, Pnt(7)^.Top+yo,
                Pnt(8)^.Left+xo, Pnt(8)^.Top+yo,
                sr,sg,sb, m_alpha,
                Wid[7]);

      ShapeLine(pShape,
                Pnt(6)^.Left+xo, Pnt(6)^.Top+yo,
                Pnt(9)^.Left+xo, Pnt(9)^.Top+yo,
                sr,sg,sb,  m_alpha,
                Wid[8]);

      ShapeLine(pShape,
                Pnt(9)^.Left+xo, Pnt(9)^.Top+yo,
                Pnt(10)^.Left+xo, Pnt(10)^.Top+yo,
                sr,sg,sb, m_alpha,
                Wid[9]);

      angle := 180 * (1 + ArcTan2(Pnt(6)^.Top-Pnt(1)^.Top, Pnt(6)^.Left-Pnt(1)^.Left) / PI);
      if angle >= 360.0 then angle := angle - 360.0;
      angle := angle - 180;
      Rads := DegToRad(angle);
      cx := (m_nHeadDiam div 2) * Cos(Rads);
      cy := (m_nHeadDiam div 2) * Sin(Rads);
      cx := Pnt(6)^.Left+cx;
      cy := Pnt(6)^.Top+cy;
      DWORDtoRGB(m_InColour, br,bg,bb);
      ShapeCircle(pShape,
                  round(cx)-(m_nHeadDiam div 2), round(cy)-(m_nHeadDiam div 2),
                  round(cx)+(m_nHeadDiam div 2), round(cy)+(m_nHeadDiam div 2),
                  sr,sg,sb, br,bg,bb, m_alpha, Wid[10]);

      //makes buggy line
      {angle := angle - 180;
      Rads := DegToRad(angle);
      cx := cx + (m_nHeadDiam div 2-2) * Cos(Rads);
      cy := cy + (m_nHeadDiam div 2-2) * Sin(Rads);
      ShapeLine(pShape,
                Pnt(6)^.Left+xo, Pnt(6)^.Top+yo,
                round(cx), round(cy),
                sr,sg,sb, m_alpha,
                Wid[5]);}
      ShapeComplete(pShape);
   end;
end;

procedure drawExplosion(xo,yo : integer; var pShape : pointer; pExplode : TExplodeObjPtr; fPercent : single);
var
   pParticle : TParticlePtr;
   f : integer;
   x1, y1 : integer;
   iCol : byte;
   nRadius : integer;
   x,y : double;
   fr,fg,fb,br,bg,bb: byte;
begin

   begin
      iCol := 0;//round(255 * fPercent);
      fr := 255;
      fb := iCol;
      fg := iCol;
      br := 255;
      bb := iCol;
      bg := iCol;
      for f := 0 to pExplode^.m_Particles.Count-1 do
      begin
         pParticle := pExplode^.m_Particles.Items[f];
         nRadius := 3;//-round(5 * (fPercent/100));
         x := pExplode^.m_nMidX + pParticle^.xinc * fPercent;
         y := pExplode^.m_nMidY + pParticle^.yinc * fPercent;
         x1 := trunc(x);
         y1 := trunc(y);
         ShapeCircle(pShape, x1,y1,x1+nRadius,y1+nRadius, fr,fg,fb, br,bg,bb, round(255-(200*(fPercent/100))), 1);
      end;

   end;
end;

   procedure drawJoint2(pMovie : pointer; olHolders : TList; var nIndex : integer; bCreate : boolean; nMin, nMax : integer; xo, yo : integer; pStart, pStop : TJoint; alpha : byte);
   var
      pStopChild : TJoint;
      l,w,h,x,y : integer;
      i : integer;
      dAngle : single;
      points : array[0..3] of TPoint;
      sr,sg,sb : byte;
      br,bg,bb : byte;

      pHolder : THolder;
      pStartShape, pEndShape, pShape : pointer;

      fill : SWFFillStyle;
   begin
      if (pStop = nil) then
         exit;

      nIndex := nIndex + 1;

      if (bCreate) then
      begin
         pHolder := THolder.Create;
         olHolders.Add(pHolder);

         pHolder.m_pMorph := MorphCreate(pMovie, pStartShape, pEndShape);;
         pHolder.m_nMin := nMin;
         pHolder.m_nMax := nMax;
         pHolder.m_nType := TYPE_MORPH;
         pHolder.m_nCurrent := 0;
         pHolder.m_nTotal := pHolder.m_nMax - pHolder.m_nMin;
         pHolder.m_pDisplay := nil;
         pHolder.m_pStartShape := pStartShape;
         pHolder.m_pEndShape := pEndShape;
         pShape := pHolder.m_pStartShape;
      end else
      begin
         pHolder := olHolders.Items[nIndex-1];
         pShape := pHolder.m_pEndShape;
      end;

      sb := pStop.FillColour shr 16;
      sg := pStop.FillColour shr 8;
      sr := pStop.FillColour;
      bb := pStop.Colour shr 16;
      bg := pStop.Colour shr 8;
      br := pStop.Colour;

      if (pStop.DrawAs = C_DRAW_AS_LINE) then
      begin
         ShapeLine(pShape,
                   pStart.X + xo, pStart.Y + yo,
                   pStop.X + xo, pStop.Y + yo,
                   br,bg,bb, alpha,
                   pStop.Width);
      end;
      if (pStop.DrawAs = C_DRAW_AS_RECT) then
      begin
         w := pStop.X - pStart.X;
         h := pStop.Y - pStart.Y;
         dAngle := 180 * (1 + ArcTan2(h, w) / PI);
         dAngle := dAngle + 90;

         w := round( cos(dAngle * PI / 180) * (pStart.DrawWidth / 2) );
         h := round( sin(dAngle * PI / 180) * (pStart.DrawWidth / 2) );

         points[0].X := pStop.X + w;
         points[0].Y := pStop.Y + h;
         points[1].X := pStop.X - w;
         points[1].Y := pStop.Y - h;
         points[2].X := pStart.X - w;
         points[2].Y := pStart.Y - h;
         points[3].X := pStart.X + w;
         points[3].Y := pStart.Y + h;

         SWFShape_setLine(pShape, pStop.Width, br,bg,bb,Alpha);
         fill := newSWFSolidFillStyle(sr,sg,sb,alpha);
         SWFShape_setLeftFillStyle(pShape, fill);
         SWFShape_movePenTo(pShape, xo+points[0].X, yo+points[0].Y);
         SWFShape_drawLineTo(pShape, xo+points[1].X, yo+points[1].Y);
         SWFShape_drawLineTo(pShape, xo+points[2].X, yo+points[2].Y);
         SWFShape_drawLineTo(pShape, xo+points[3].X, yo+points[3].Y);
         SWFShape_drawLineTo(pShape, xo+points[0].X, yo+points[0].Y);
      end;
      if (pStop.DrawAs = C_DRAW_AS_CIRCLE) then
      begin
         w := pStop.X - pStart.X;
         h := pStop.Y - pStart.Y;
         l := round(sqrt(sqr(w)+sqr(h)));
         x := pStop.X - (w div 2);
         y := pStop.Y - (h div 2);
         l := l div 2; //radius
         ShapeCircle(pShape,
                     x-l,y-l,x+l,y+l,
                     br,bg,bb,
                     sr,sg,sb, alpha,
                     pStop.Width);
      end;
      ShapeComplete(pShape);

      if (pStop.GetFirstChild) then
      begin
         while (pStop.GetNextChild(pStopChild)) do
         begin
            drawJoint2(pMovie,
                       olHolders,
                       nIndex,
                       bCreate,
                       nMin, nMax,
                       xo,yo, pStop, pStopChild, alpha);
         end;
      end;
   end;
procedure drawT2stick2(pMovie : pointer; xo,yo : integer; var olHolders : TList; pStart, pEnd : TIFramePtr);
var
   pJoint : TJoint;
   pChild : TJoint;
   f,h : integer;
   //
   pStick : array[0..1] of TLimbListPtr;
   bCreate : boolean;
   nIndex : integer;
   nStart : integer;
begin
   pStick[0] := pStart^.m_pObject;
   pStick[1] := pEnd^.m_pObject;
   bCreate := true; //create shapes first time round

   nStart := olHolders.Count;

   for h := 0 to 1 do
   begin
      nIndex := nStart;
      for f := 0 to pStick[h]^.JointCount-1 do
      begin
         pJoint := pStick[h]^.Joint[f];

         if (pJoint.GetFirstChild) then
         begin
            while (pJoint.GetNextChild(pChild)) do
            begin
               drawJoint2(pMovie,
                          olHolders,
                          nIndex,
                          bCreate,
                          pStart^.m_FrameNo, pEnd^.m_FrameNo,
                          xo,yo, pJoint, pChild, round(pStick[h].Alpha*255));
            end;
         end;
      end;
      bCreate := false;
   end; //h
end;

/////////////////////////////////////////////

function MovieAddSimpleStick(movie : SWFMovieClip; start,finish : TStickManPtr; layer : integer) : SWFDisplayItem;
var
   morph : SWFMorph;
   shape1, shape2 : SWFShape;
   item : SWFDisplayItem;

   blur : SWFBlur;
   filter : SWFFilter;
   colour : SWFColor;
begin
   MovieAddSimpleStick := nil;
   morph := newSWFMorphShape();
   if (morph = nil) then
      exit;
   shape1 := SWFMorph_getShape1(morph);
   shape2 := SWFMorph_getShape2(morph);
   drawstick(0,0, shape1, start);
   drawstick(0,0, shape2, finish);

   //
   {blur := newSWFBlur(20,20, 2);
   colour.red := $ff;
   colour.green := $fc;
   colour.blue := $cc;
   colour.alpha := 255;
   filter := newGlowFilter(colour, blur, 10, FILTER_FLAG_PRESERVE_ALPHA);}
   //

   item := SWFMovieClip_add(movie, morph);
   SWFDisplayItem_setDepth(item, layer);

   //
   //SWFDisplayItem_addFilter(item, filter);
   //

   MovieAddSimpleStick := item;
end;

function MovieAddExplosion(movie : SWFMovieClip; start,finish : TExplodeObjPtr; layer : integer) : SWFDisplayItem;
var
   morph : SWFMorph;
   shape1, shape2 : SWFShape;
   item : SWFDisplayItem;
begin
   MovieAddExplosion := nil;
   morph := newSWFMorphShape();
   if (morph = nil) then
      exit;
   shape1 := SWFMorph_getShape1(morph);
   shape2 := SWFMorph_getShape2(morph);
   drawexplosion(0,0, shape1, start, 0);
   drawexplosion(0,0, shape2, start, 100);

   item := SWFMovieClip_add(movie, morph);
   SWFDisplayItem_setDepth(item, layer);

   MovieAddExplosion := item;
end;

function MovieAddPoly(movie : SWFMovieClip; start,finish : TPolyObjPtr; layer : integer) : SWFDisplayItem;
var
   morph : SWFMorph;
   shape1, shape2 : SWFShape;
   item : SWFDisplayItem;
begin
   MovieAddPoly := nil;
   morph := newSWFMorphShape();
   if (morph = nil) then
      exit;
   shape1 := SWFMorph_getShape1(morph);
   shape2 := SWFMorph_getShape2(morph);
   drawpoly(0,0, shape1, start);
   drawpoly(0,0, shape2, finish);

   item := SWFMovieClip_add(movie, morph);
   SWFDisplayItem_setDepth(item, layer);

   MovieAddPoly := item;
end;

function MovieAddRectangle(movie : SWFMovieClip; start,finish : TSquareObjPtr; layer : integer) : SWFDisplayItem;
var
   morph : SWFMorph;
   shape1, shape2 : SWFShape;
   item : SWFDisplayItem;
   procedure rect(shape : SWFShape; square : TSquareObj);
   var
      r,g,b : byte;
      fill : SWFFillStyle;
      wide,high : single;
   begin
      wide := (square.Pnt(3).left - square.Pnt(1).left) / 2;
      high := (square.Pnt(3).top - square.Pnt(1).top) / 2;

      r := square.m_OutColour;
      g := square.m_OutColour shr 8;
      b := square.m_OutColour shr 16;
      SWFShape_setLine(shape, square.m_nLineWidth, r,g,b, square.m_alpha);
      r := square.m_InColour;
      g := square.m_InColour shr 8;
      b := square.m_InColour shr 16;
      fill := SWFShape_addSolidFillStyle(shape, r,g,b, square.m_alpha);
      SWFShape_setLeftFillStyle(shape, fill);
      SWFShape_movePenTo(shape,  -wide,-high);
      SWFShape_drawLineTo(shape,  wide,-high);
      SWFShape_drawLineTo(shape,  wide, high);
      SWFShape_drawLineTo(shape, -wide, high);
      SWFShape_drawLineTo(shape, -wide,-high);
   end;
begin
   MovieAddRectangle := nil;
   morph := newSWFMorphShape();
   if (morph = nil) then
      exit;

   shape1 := SWFMorph_getShape1(morph);
   rect(shape1, start^);

   shape2 := SWFMorph_getShape2(morph);
   rect(shape2, finish^);

   item := SWFMovieClip_add(movie, morph);
   SWFDisplayItem_setDepth(item, layer);

   MovieAddRectangle := item;
end;

function MovieAddOval(movie : SWFMovieClip; start,finish : TOvalObjPtr; layer : integer) : SWFDisplayItem;
var
   morph : SWFMorph;
   shape1, shape2 : SWFShape;
   item : SWFDisplayItem;
   procedure oval(shape : SWFShape; oval : TOvalObj);
   var
      r,g,b,fr,fg,fb : byte;
   begin
      r := oval.m_OutColour;
      g := oval.m_OutColour shr 8;
      b := oval.m_OutColour shr 16;
      fr := oval.m_InColour;
      fg := oval.m_InColour shr 8;
      fb := oval.m_InColour shr 16;
      ShapeCircle2(shape,
                   oval.Pnt(3)^.left - oval.Pnt(1)^.left,
                   oval.Pnt(3)^.top - oval.Pnt(1)^.top,
                   r,g,b, fr,fg,fb, oval.m_alpha, oval.m_nLineWidth);
   end;
begin
   MovieAddOval := nil;
   morph := newSWFMorphShape();
   if (morph = nil) then
      exit;

   shape1 := SWFMorph_getShape1(morph);
   oval(shape1, start^);

   shape2 := SWFMorph_getShape2(morph);
   oval(shape2, finish^);

   item := SWFMovieClip_add(movie, morph);
   SWFDisplayItem_setDepth(item, layer);

   MovieAddOval := item;
end;

function MovieAddLine(movie : SWFMovieClip; start,finish : TLineObjPtr; layer : integer) : SWFDisplayItem;
var
   morph : SWFMorph;
   shape1, shape2 : SWFShape;
   item : SWFDisplayItem;
begin
   MovieAddLine := nil;
   morph := newSWFMorphShape();
   if (morph = nil) then
      exit;
   shape1 := SWFMorph_getShape1(morph);
   shape2 := SWFMorph_getShape2(morph);
   drawline(0,0, shape1, start);
   drawline(0,0, shape2, finish);

   item := SWFMovieClip_add(movie, morph);
   SWFDisplayItem_setDepth(item, layer);

   MovieAddLine := item;
end;

procedure TweenBitmap(item : SWFDisplayItem; start,finish : TBitmanPtr; tween, tweenFrameDiff : integer; originalWidth, originalHeight : integer);
var
   x,y : single;
   wide,high :array[0..1] of  single;
   percent : single;
   scaleX, scaleY : single;
   width, height : single;
   angle : single;
   alpha : byte;
begin
   percent := tween / tweenFrameDiff;

   wide[0] := start^.Pnt(3)^.Left - start^.Pnt(1)^.Left;
   high[0] := start^.Pnt(3)^.Top - start^.Pnt(1)^.Top;
   wide[1] := finish^.Pnt(3)^.Left - finish^.Pnt(1)^.Left;
   high[1] := finish^.Pnt(3)^.Top - finish^.Pnt(1)^.Top;

   width := wide[0] + ((wide[1] - wide[0]) * percent);
   height := high[0] + ((high[1] - high[0]) * percent);

   scaleX := width / originalWidth;
   scaleY := height / originalHeight;

   angle := start^.m_angle + ((finish^.m_angle - start^.m_angle) * percent);
   alpha := round(start^.m_alpha + ((finish^.m_alpha - start^.m_alpha) * percent));

   x := start^.Pnt(1)^.Left + ((finish^.Pnt(1)^.Left - start^.Pnt(1)^.Left) * percent);
   y := start^.Pnt(1)^.Top + ((finish^.Pnt(1)^.Top - start^.Pnt(1)^.Top) * percent);
   x := x - (width / 2);
   y := y - (height / 2);

   SWFDisplayItem_moveTo(item, x,y);
   SWFDisplayItem_scaleTo(item, scaleX, scaleY);
   SWFDisplayItem_rotateTo(item, angle);
   SWFDisplayItem_setColorMult(item, 1,1,1, alpha/255);
end;

procedure TweenColour(colour1, colour2 : longint; percent : single; var r,g,b : byte);
var
  rr,gg,bb : array[0..1] of byte;
begin
  rr[0] := colour1;
  gg[0] := colour1 shr 8;
  bb[0] := colour1 shr 16;
  rr[1] := colour2;
  gg[1] := colour2 shr 8;
  bb[1] := colour2 shr 16;

  r := round(rr[0] + ((rr[1] - rr[0]) * percent));
  g := round(gg[0] + ((gg[1] - gg[0]) * percent));
  b := round(bb[0] + ((bb[1] - bb[0]) * percent));
end;

procedure TweenText(item : SWFDisplayItem; start,finish : TTextObjPtr; tween, tweenFrameDiff : integer; originalWidth, originalHeight : integer);
var
   x,y : single;
   wide,high :array[0..1] of  single;
   percent : single;
   scaleX, scaleY : single;
   width, height : single;
   angle : single;
   alpha : byte;
   r,g,b : byte;
begin
   percent := tween / tweenFrameDiff;

   wide[0] := start^.Pnt(3)^.Left - start^.Pnt(1)^.Left;
   high[0] := start^.Pnt(3)^.Top - start^.Pnt(1)^.Top;
   wide[1] := finish^.Pnt(3)^.Left - finish^.Pnt(1)^.Left;
   high[1] := finish^.Pnt(3)^.Top - finish^.Pnt(1)^.Top;

   width := wide[0] + ((wide[1] - wide[0]) * percent);
   height := high[0] + ((high[1] - high[0]) * percent);

   scaleX := width / originalWidth;
   scaleY := height / originalHeight;

   angle := start^.m_angle + ((finish^.m_angle - start^.m_angle) * percent);
   alpha := round(start^.m_alpha + ((finish^.m_alpha - start^.m_alpha) * percent));

   x := start^.Pnt(1)^.Left + ((finish^.Pnt(1)^.Left - start^.Pnt(1)^.Left) * percent);
   y := start^.Pnt(1)^.Top + ((finish^.Pnt(1)^.Top - start^.Pnt(1)^.Top) * percent);
   x := x + (width / 2);
   y := y + (height / 2);

   TweenColour(start^.m_InColour, finish^.m_InColour, percent, r,g,b);

   SWFDisplayItem_moveTo(item, x,y);
   SWFDisplayItem_scaleTo(item, scaleX, scaleY);
   SWFDisplayItem_rotateTo(item, angle);
   SWFDisplayItem_setColorMult(item, r/255,g/255,b/255, alpha/255);
end;

procedure TweenRectangle(item : SWFDisplayItem; start,finish : TSquareObjPtr; tween, tweenFrameDiff : integer);
var
   percent : single;
   angle : single;
   x,y : single;
   wide,high : array[0..2] of single;
begin
   percent := tween / tweenFrameDiff;
   SWFDisplayItem_setRatio(item, percent);
   angle := start^.m_angle + ((finish^.m_angle - start^.m_angle) * percent);
   SWFDisplayItem_rotateTo(item, 360-angle);

      wide[0] := (start^.Pnt(3).left - start^.Pnt(1).left) / 2;
      high[0] := (start^.Pnt(3).top - start^.Pnt(1).top) / 2;
      wide[1] := (finish^.Pnt(3).left - finish^.Pnt(1).left) / 2;
      high[1] := (finish^.Pnt(3).top - finish^.Pnt(1).top) / 2;

      wide[2] := wide[0] + ((wide[1] - wide[0]) * percent);
      high[2] := high[0] + ((high[1] - high[0]) * percent);

      x := start^.Pnt(1).left + ((finish^.Pnt(1).left - start^.Pnt(1).left) * percent);
      y := start^.Pnt(1).top + ((finish^.Pnt(1).top - start^.Pnt(1).top) * percent);
      x := x + wide[2];
      y := y + high[2];

   SWFDisplayItem_moveTo(item, x,y);
end;

procedure TweenOval(item : SWFDisplayItem; start,finish : TOvalObjPtr; tween, tweenFrameDiff : integer);
var
   percent : single;
   angle : single;
   x,y : single;
   wide,high : array[0..2] of single;
begin
   percent := tween / tweenFrameDiff;
   SWFDisplayItem_setRatio(item, percent);
   angle := start^.m_angle + ((finish^.m_angle - start^.m_angle) * percent);
   SWFDisplayItem_rotateTo(item, 360-angle);

      wide[0] := (start^.Pnt(3).left - start^.Pnt(1).left) / 2;
      high[0] := (start^.Pnt(3).top - start^.Pnt(1).top) / 2;
      wide[1] := (finish^.Pnt(3).left - finish^.Pnt(1).left) / 2;
      high[1] := (finish^.Pnt(3).top - finish^.Pnt(1).top) / 2;

      wide[2] := wide[0] + ((wide[1] - wide[0]) * percent);
      high[2] := high[0] + ((high[1] - high[0]) * percent);

      x := start^.Pnt(1).left + ((finish^.Pnt(1).left - start^.Pnt(1).left) * percent);
      y := start^.Pnt(1).top + ((finish^.Pnt(1).top - start^.Pnt(1).top) * percent);
      x := x + wide[2];
      y := y + high[2];

   SWFDisplayItem_moveTo(item, x,y);
end;

procedure ExportFlash(strFileName, strSoundtrack : string; var olLayers : TList);
var
   movie : SWFMovie;
   olClips : TList;
   f : integer;
   rr,gg,bb : byte;

  movieFrameCount : integer;

  layers: Integer;
  pLayer : TLayerObjPtr;
  framesets : integer;
  pFrameSet : TSingleFramePtr;
  frame : integer;
  pFrame, pNextFrame : TIFramePtr;

  movieClip : SWFMovieClip;
  iterations : integer;
  nTweenFrameNumber, nTweenFrameCount : integer;
  item : SWFDisplayItem;

  nFirstFrame, nLastFrame, nFrameIndex : integer;

  combo : TMovieClipCombo;
  clips : integer;

  originalWidth, originalHeight : integer;
begin
   if (not LoadMing) then
   begin
      //showmessage
      exit;
   end;

   movieFrameCount := GetLastFrame(olLayers);
   DWORDtoRGB(frmMain.m_bgColor, rr,gg,bb);

   Ming_setScale(1);
   Ming_setSWFCompression(9);
   movie := newSWFMovieWithVersion(8);
   if (movie = nil) then
   begin
      UnloadMing;
      exit;
   end;

   olClips := TList.Create;

   SWFMovie_setDimension(movie, frmMain.frmCanvas.ClientWidth, frmMain.frmCanvas.ClientHeight);
   SWFMovie_setRate(movie, frmMain.m_nFPS*2);
   SWFMovie_setBackground(movie, rr,gg,bb);
   SWFMovie_setNumberOfFrames(movie, movieFrameCount);

   ////
   ///  BAH!
   ///  Probably going to have to make a resource TList
   ///  so when you add the same bitmap twice, it only
   ///  saves it to the swf once, saving filesize
   ///  same with font
   ///
   ///  oh, and this will need a file format change,
   ///  but store if something had transparency,
   ///  and if it didn't, store as compressed jpg
   ///////////////////////////////////////////////
   for layers := 0 to olLayers.Count - 1 do
   begin
      pLayer := olLayers.Items[layers];
      movieClip := newSWFMovieClip();
      //do any layer init needed, like adding shapes/fonts/bitmaps
      item := nil;
      if (pLayer^.m_nType = O_BITMAP) then
      begin
         item := MovieAddBitmap(movieClip, TBitmanPtr(pLayer^.m_pTempObject)^.Imarge, layers, originalWidth, originalHeight);
      end;

      for framesets := 0 to pLayer^.m_olFrames.Count - 1 do
      begin
         pFrameSet := pLayer^.m_olFrames.Items[framesets];
         nFirstFrame := TIFramePtr(pFrameSet^.m_Frames.First)^.m_FrameNo;
         nLastFrame := TIFramePtr(pFrameSet^.m_Frames.Last)^.m_FrameNo;
         combo := TMovieClipCombo.Create(movieClip, nFirstFrame, nLastFrame);
         olClips.Add(combo);
         nFrameIndex := 0;
         pFrame := pFrameSet^.m_Frames.Items[nFrameIndex];
         pNextFrame := pFrameSet^.m_Frames.Items[nFrameIndex+1];
         nTweenFrameNumber := 0;
         for frame := nFirstFrame to nLastFrame do
         begin
            if (frame > pNextFrame^.m_FrameNo) then
            begin
               nFrameIndex := nFrameIndex + 1;
               pFrame := pFrameSet^.m_Frames.Items[nFrameIndex];
               pNextFrame := pFrameSet^.m_Frames.Items[nFrameIndex+1];
               nTweenFrameNumber := 0;
            end;
            if (nTweenFrameNumber = 0) then
            begin
               if (pLayer^.m_nType = O_STICKMAN) then
               begin
                  if (item <> nil) then
                     SWFMovieClip_remove(movieClip, item);
                  item := MovieAddSimpleStick(movieClip, pFrame^.m_pObject, pNextFrame^.m_pObject, layers);
               end;
               if (pLayer^.m_nType = O_POLY) then
               begin
                  if (item <> nil) then
                     SWFMovieClip_remove(movieClip, item);
                  item := MovieAddPoly(movieClip, pFrame^.m_pObject, pNextFrame^.m_pObject, layers);
               end;
               if (pLayer^.m_nType = O_TEXT) then
               begin
                  if (item <> nil) then
                     SWFMovieClip_remove(movieClip, item);
                  item := MovieAddText(movieClip, TTextObjPtr(pFrame^.m_pObject)^.m_strCaption, TTextObjPtr(pFrame^.m_pObject)^.m_strFontName, layers, originalWidth, originalHeight);
               end;
               if (pLayer^.m_nType = O_LINE) then
               begin
                  if (item <> nil) then
                     SWFMovieClip_remove(movieClip, item);
                  item := MovieAddLine(movieClip, pFrame^.m_pObject, pNextFrame^.m_pObject, layers);
               end;
               if (pLayer^.m_nType = O_RECTANGLE) then
               begin
                  if (item <> nil) then
                     SWFMovieClip_remove(movieClip, item);
                  item := MovieAddRectangle(movieClip, pFrame^.m_pObject, pNextFrame^.m_pObject, layers);
               end;
               if (pLayer^.m_nType = O_OVAL) then
               begin
                  if (item <> nil) then
                     SWFMovieClip_remove(movieClip, item);
                  item := MovieAddOval(movieClip, pFrame^.m_pObject, pNextFrame^.m_pObject, layers);
               end;
               if (pLayer^.m_nType = O_EXPLODE) then
               begin
                  if (item <> nil) then
                     SWFMovieClip_remove(movieClip, item);
                  item := MovieAddExplosion(movieClip, pFrame^.m_pObject, pNextFrame^.m_pObject, layers);
               end;
            end;

            nTweenFrameCount := pNextFrame^.m_FrameNo - pFrame^.m_FrameNo;

            if (pLayer^.m_nType = O_BITMAP) then
            begin
               TweenBitmap(item, pFrame^.m_pObject, pNextFrame^.m_pObject, nTweenFrameNumber, nTweenFrameCount, originalWidth, originalHeight);
            end;
            if (pLayer^.m_nType = O_TEXT) then
            begin
               TweenText(item, pFrame^.m_pObject, pNextFrame^.m_pObject, nTweenFrameNumber, nTweenFrameCount, originalWidth, originalHeight);
            end;
            if (pLayer^.m_nType = O_RECTANGLE) then
            begin
               if (item <> nil) then
                  TweenRectangle(item, pFrame^.m_pObject, pNextFrame^.m_pObject, nTweenFrameNumber, nTweenFrameCount);
            end;
            if (pLayer^.m_nType = O_OVAL) then
            begin
               if (item <> nil) then
                  TweenOval(item, pFrame^.m_pObject, pNextFrame^.m_pObject, nTweenFrameNumber, nTweenFrameCount);
            end;
            if (pLayer^.m_nType = O_STICKMAN) or
               (pLayer^.m_nType = O_LINE) or
               (pLayer^.m_nType = O_EXPLODE) or
               (pLayer^.m_nType = O_RECTANGLE) or
               (pLayer^.m_nType = O_POLY) then
            begin
               if (item <> nil) then
                  SWFDisplayItem_setRatio(item, nTweenFrameNumber/nTweenFrameCount);
            end;

            SWFMovieClip_nextFrame(movieClip);
            nTweenFrameNumber := nTweenFrameNumber + 1;
         end;
      end;
   end;
   ///////////////////////////////////////////////
   for frame := 1 to movieFrameCount do
   begin
      for clips := 0 to olClips.Count - 1 do
      begin
        combo := olClips.Items[clips];
        if (combo.startFrame = frame) then
           combo.item := SWFMovie_add(movie, combo.Clip);
        if (combo.stopFrame = frame) and (frame <> movieFrameCount) then
           SWFMovie_remove(movie, combo.item);
      end;
      SWFMovie_nextFrame(movie);
   end;
   ///////////////////////////////////////////////

   SWFMovie_nextFrame(movie);
   SWFMovie_save(movie, pchar(strFileName));
 	 destroySWFMovie(movie);

   for layers := 0 to olClips.count - 1 do
   begin
      TMovieClipCombo(olClips.Items[layers]).Destroy;
   end;
   olClips.Destroy;

   UnloadMing;
end;

end.

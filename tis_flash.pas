unit tis_flash;

interface

uses main, math;

function ExportFlash(strFileName : string) : boolean;

implementation

uses windows, classes, jpeg;

type
   TFlashSet = class(TObject)
      pDisplay : pointer;
      pMorph : pointer;
      pStartShape : pointer;
      pEndShape : pointer;
      nCurrent, nCount : integer;
      pFrameSet : TSingleFramePtr;
      nLayer : integer;
     public
      procedure Assign(pSource : TFlashSet);
   end;

   pfMovieCreate = function(nWidth, nHeight, nFPS : integer; r,g,b : byte; nFrameCount : integer) : pointer; cdecl;
   pfMovieDestroy = procedure(pMovie : pointer); cdecl;
   pfMovieAddObject = function(pMovie : pointer; pObject : pointer) : pointer; cdecl;
   pfMovieRemoveObject = procedure(pMovie : pointer; pDisplay : pointer); cdecl;
   pfMovieNextFrame = procedure(pMovie : pointer); cdecl;
   pfMovieSave = function(pMovie : pointer; szFileName : PChar) : integer; cdecl;

   pfMorphCreate = function(pMovie : pointer; var pDisplay, pStart, pEnd : pointer) : pointer; cdecl;
   pfMorphMorph = procedure(pDisplay : pointer; nCurrent, nMax : integer); cdecl;
   pfMorphDestroy = procedure(pMorph : pointer); cdecl;

   pfShapeLine = procedure(pShape : pointer; x1,y1,x2,y2 : integer; r,g,b : byte; nWidth : integer); cdecl;
   pfShapeRectangle = procedure(pShape : pointer; x1,y1,x2,y2 : integer; fr,fg,fb : byte; nWidth : integer; br,bg,bb : byte); cdecl;
   pfShapeCircle = procedure(pShape : pointer; x,y, nRadius : integer; fr,fg,fb : byte; nWidth : integer; br,bg,bb : byte); cdecl;
   pfShapeComplete = procedure(pShape : pointer); cdecl;
   pfShapePolyStart = procedure(pShape : pointer; x,y : integer; fr,fg,fb : byte; nWidth : integer; br,bg,bb : byte); cdecl;
   pfShapePolyNext = procedure(pShape : pointer; x,y : integer); cdecl;

   pfShapeAddBitmap = function(pMovie : pointer; szFileName : pchar); pointer; cdecl;
   pfShapeBitmap = procedure(pDisplay : pointer; x1,y1,x2,y2 : integer); cdecl;

var
   MovieCreate : pfMovieCreate;
   MovieDestroy : pfMovieDestroy;
   MovieAddObject : pfMovieAddObject;
   MovieRemoveObject : pfMovieRemoveObject;
   MovieNextFrame : pfMovieNextFrame;
   MovieSave : pfMovieSave;

   MorphCreate : pfMorphCreate;
   MorphMorph : pfMorphMorph;
   MorphDestroy : pfMorphDestroy;

   ShapeLine : pfShapeLine;
   ShapeRectangle : pfShapeRectangle;
   ShapeCircle : pfShapeCircle;
   ShapeComplete : pfShapeComplete;
   ShapePolyStart : pfShapePolyStart;
   ShapePolyNext : pfShapePolyNext;

   ShapeAddBitmap : pfShapeAddBitmap;
   ShapeBitmap : pfShapeBitmap;

procedure TFlashSet.Assign(pSource : TFlashSet);
begin
      pDisplay := pSource.pDisplay;
      pMorph := pSource.pMorph;
      pStartShape := pSource.pStartShape;
      pEndShape := pSource.pEndShape;
      nCurrent := pSource.nCurrent;
      nCount := pSource.nCount;
      pFrameSet := pSource.pFrameSet;
      nLayer := pSource.nLayer;
end;

procedure DWORDtoRGB(t : longword; var r,g,b : byte);
begin
   b := t shr 16;
   g := t shr 8;
   r := t;
end;

procedure drawPoly(xo,yo : integer; pShape : pointer; pPoly : TPolyObjPtr);
var
   r,g,b : byte;
   r2,g2,b2 : byte;
   f : integer;
begin
   with pPoly^ do
   begin
      DWORDtoRGB(m_outColour, r,g,b);
      DWORDtoRGB(m_inColour, r2,g2,b2);
      ShapePolyStart(pShape, xo+Pnt(1)^.Left, yo+Pnt(1)^.Top, r,g,b, m_nLineWidth, r2,g2,b2);
      for f := 1 to PntList.Count-1 do
      begin
         ShapePolyNext(pShape, xo+Pnt(f+1)^.Left, yo+Pnt(f+1)^.Top);
      end;
      ShapePolyNext(pShape, xo+Pnt(1)^.Left, yo+Pnt(1)^.Top);
      ShapeComplete(pShape);
   end;
end;

procedure drawOval(xo,yo : integer; pShape : pointer; pOval : TOvalObjPtr);
var
   r,g,b : byte;
   r2,g2,b2 : byte;
   x,y : integer;
   radius : integer;
begin
   with pOval^ do
   begin
      DWORDtoRGB(m_outColour, r,g,b);
      DWORDtoRGB(m_inColour, r2,g2,b2);
      radius := Pnt(3)^.Left - Pnt(1)^.Left;
      x := xo + Pnt(1)^.Left + (Pnt(3)^.Left - Pnt(1)^.Left);
      y := yo + Pnt(1)^.Top + (Pnt(3)^.Top - Pnt(1)^.Top);
      ShapeCircle(pShape, x,y, radius, r,g,b, m_nLineWidth, r2,g2,b2);
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
      ShapeRectangle(pShape, xo+Pnt(1)^.Left, yo+Pnt(1)^.Top, xo+Pnt(3)^.Left, yo+Pnt(3)^.Top, r,g,b, m_nLineWidth, r2,g2,b2);
      ShapeComplete(pShape);
   end;
end;

procedure drawLine(xo,yo : integer; pShape : pointer; pLine : TLineObjPtr);
var
   r,g,b : byte;
begin
   with pLine^ do
   begin
      DWORDtoRGB(m_Colour, r,g,b);
      ShapeLine(pShape, xo+Pnt(1)^.Left, yo+Pnt(1)^.Top, xo+Pnt(2)^.Left, yo+Pnt(2)^.Top, r,g,b, m_nLineWidth);
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
                sr,sg,sb,
                Wid[5]);

      ShapeLine(pShape,
                Pnt(1)^.Left+xo, Pnt(1)^.Top+yo,
                Pnt(2)^.Left+xo, Pnt(2)^.Top+yo,
                sr,sg,sb,
                Wid[1]);

      ShapeLine(pShape,
                Pnt(2)^.Left+xo, Pnt(2)^.Top+yo,
                Pnt(3)^.Left+xo, Pnt(3)^.Top+yo,
                sr,sg,sb,
                Wid[2]);

      ShapeLine(pShape,
                Pnt(1)^.Left+xo, Pnt(1)^.Top+yo,
                Pnt(4)^.Left+xo, Pnt(4)^.Top+yo,
                sr,sg,sb,
                Wid[3]);

      ShapeLine(pShape,
                Pnt(4)^.Left+xo, Pnt(4)^.Top+yo,
                Pnt(5)^.Left+xo, Pnt(5)^.Top+yo,
                sr,sg,sb,
                Wid[4]);

      ShapeLine(pShape,
                Pnt(6)^.Left+xo, Pnt(6)^.Top+yo,
                Pnt(7)^.Left+xo, Pnt(7)^.Top+yo,
                sr,sg,sb,
                Wid[6]);

      ShapeLine(pShape,
                Pnt(7)^.Left+xo, Pnt(7)^.Top+yo,
                Pnt(8)^.Left+xo, Pnt(8)^.Top+yo,
                sr,sg,sb,
                Wid[7]);

      ShapeLine(pShape,
                Pnt(6)^.Left+xo, Pnt(6)^.Top+yo,
                Pnt(9)^.Left+xo, Pnt(9)^.Top+yo,
                sr,sg,sb,
                Wid[8]);

      ShapeLine(pShape,
                Pnt(9)^.Left+xo, Pnt(9)^.Top+yo,
                Pnt(10)^.Left+xo, Pnt(10)^.Top+yo,
                sr,sg,sb,
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
      ShapeCircle(pShape, round(cx), round(cy), m_nHeadDiam, sr,sg,sb, Wid[10], br,bg,bb);

      angle := angle - 180;
      Rads := DegToRad(angle);
      cx := cx + (m_nHeadDiam div 2-2) * Cos(Rads);
      cy := cy + (m_nHeadDiam div 2-2) * Sin(Rads);
      ShapeLine(pShape,
                Pnt(6)^.Left+xo, Pnt(6)^.Top+yo,
                round(cx), round(cy),
                sr,sg,sb,
                Wid[5]);
      ShapeComplete(pShape);
   end;
end;

procedure rekt(pShape : pointer; x1,y1,x2,y2,width:integer; pcolor,bcolor:longword; linewidth:integer);
var
   angle : double;
   Rads : double;
   cx, cy : double;
   xdiff,ydiff:integer;
   sr,sg,sb,br,bg,bb:byte;
begin
   DWORDtoRGB(pcolor, sr,sg,sb);
   DWORDtoRGB(bcolor, br,bg,bb);

   begin
      width := width shr 1;
      angle := 180 * (1 + ArcTan2(y1-y2, x1-x2) / PI);
      if angle >= 360.0 then angle := angle - 360.0;
      angle := angle - 90;
      Rads := DegToRad(angle);
      cx := width * Cos(Rads);
      cy := width * Sin(Rads);
      xdiff := x1 - round(x1 - cx);
      ydiff := y1 - round(y1 - cy);
      ShapePolyStart(pShape, x1-xdiff, y1-ydiff, sr,sg,sb, linewidth, br,bg,bb);
      ShapePolyNext(pShape, x2-xdiff, y2-ydiff);
      ShapePolyNext(pShape, x2+xdiff, y2+ydiff);
      ShapePolyNext(pShape, x1+xdiff, y1+ydiff);
      ShapePolyNext(pShape, x1-xdiff, y1-ydiff);
   end;
end;

procedure drawSpecialStick(xo,yo : integer; pShape : pointer; pStick : TSpecialStickManPtr);
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
      DWORDtoRGB(m_InColour, br,bg,bb);
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
      if (m_nDrawStyle = 0) or (m_nDrawStyle = 1) then
      begin
         ShapeLine(pShape, xo+Pnt(6)^.Left,  yo+Pnt(6)^.Top,  xo+Pnt(1)^.Left,  yo+Pnt(1)^.Top, sr,sg,sb, m_nLineWidth);
         ShapeLine(pShape, xo+Pnt(1)^.Left,  yo+Pnt(1)^.Top,  xo+Pnt(2)^.Left,  yo+Pnt(2)^.Top, sr,sg,sb, m_nLineWidth);
         ShapeLine(pShape, xo+Pnt(2)^.Left,  yo+Pnt(2)^.Top,  xo+Pnt(3)^.Left,  yo+Pnt(3)^.Top, sr,sg,sb, m_nLineWidth);
         ShapeLine(pShape, xo+Pnt(3)^.Left,  yo+Pnt(3)^.Top,  xo+Pnt(13)^.Left, yo+Pnt(13)^.Top, sr,sg,sb, m_nLineWidth);
         ShapeLine(pShape, xo+Pnt(1)^.Left,  yo+Pnt(1)^.Top,  xo+Pnt(4)^.Left,  yo+Pnt(4)^.Top, sr,sg,sb, m_nLineWidth);
         ShapeLine(pShape, xo+Pnt(4)^.Left,  yo+Pnt(4)^.Top,  xo+Pnt(5)^.Left,  yo+Pnt(5)^.Top, sr,sg,sb, m_nLineWidth);
         ShapeLine(pShape, xo+Pnt(5)^.Left,  yo+Pnt(5)^.Top,  xo+Pnt(14)^.Left, yo+Pnt(14)^.Top, sr,sg,sb, m_nLineWidth);
         ShapeLine(pShape, xo+Pnt(6)^.Left,  yo+Pnt(6)^.Top,  xo+Pnt(7)^.Left,  yo+Pnt(7)^.Top, sr,sg,sb, m_nLineWidth);
         ShapeLine(pShape, xo+Pnt(7)^.Left,  yo+Pnt(7)^.Top,  xo+Pnt(8)^.Left,  yo+Pnt(8)^.Top, sr,sg,sb, m_nLineWidth);
         ShapeLine(pShape, xo+Pnt(8)^.Left,  yo+Pnt(8)^.Top,  xo+Pnt(11)^.Left, yo+Pnt(11)^.Top, sr,sg,sb, m_nLineWidth);
         ShapeLine(pShape, xo+Pnt(6)^.Left,  yo+Pnt(6)^.Top,  xo+Pnt(9)^.Left,  yo+Pnt(9)^.Top, sr,sg,sb, m_nLineWidth);
         ShapeLine(pShape, xo+Pnt(9)^.Left,  yo+Pnt(9)^.Top,  xo+Pnt(10)^.Left, yo+Pnt(10)^.Top, sr,sg,sb, m_nLineWidth);
         ShapeLine(pShape, xo+Pnt(10)^.Left, yo+Pnt(10)^.Top, xo+Pnt(12)^.Left, yo+Pnt(12)^.Top, sr,sg,sb, m_nLineWidth);
         if (m_nDrawStyle = 1) then
         begin
            ShapePolyStart(pShape, xo+Pnt(1)^.Left, yo+Pnt(1)^.Top, sr,sg,sb, m_nLineWidth, br,bg,bb);
            ShapePolyNext(pShape, xo+Pnt(2)^.Left, yo+Pnt(2)^.Top);
            ShapePolyNext(pShape, xo+Pnt(4)^.Left, yo+Pnt(4)^.Top);
            ShapePolyNext(pShape, xo+Pnt(1)^.Left, yo+Pnt(1)^.Top);
         end;
         angle := 180 * (1 + ArcTan2(Pnt(6)^.Top-Pnt(1)^.Top, Pnt(6)^.Left-Pnt(1)^.Left) / PI);
         if angle >= 360.0 then angle := angle - 360.0;
         angle := angle - 180;
         Rads := DegToRad(angle);
         cx := (m_nHeadDiam div 2) * Cos(Rads);
         cy := (m_nHeadDiam div 2) * Sin(Rads);
         cx := Pnt(6)^.Left+cx;
         cy := Pnt(6)^.Top+cy;
         //Ellipse(round(cx-(m_nHeadDiam div 2)),round(cy-(m_nHeadDiam div 2)),round(cx+(m_nHeadDiam div 2)),round(cy+(m_nHeadDiam div 2)));

         angle := angle - 180;
         Rads := DegToRad(angle);
         cx := cx + (m_nHeadDiam div 2-2) * Cos(Rads);
         cy := cy + (m_nHeadDiam div 2-2) * Sin(Rads);
         ShapeLine(pShape, xo+Pnt(6)^.Left, yo+Pnt(6)^.Top, xo+round(cx), yo+round(cy), sr,sg,sb, m_nLineWidth);
      end;

      if m_nDrawStyle = 2 then
      begin
        rekt(pShape, Pnt(6)^.Left+xo, Pnt(6)^.Top+yo, Pnt(1)^.Left+xo, Pnt(1)^.Top+yo, Wid[5], m_OutColour, m_InColour, m_nLineWidth);
        rekt(pShape, Pnt(1)^.Left+xo, Pnt(1)^.Top+yo, Pnt(2)^.Left+xo, Pnt(2)^.Top+yo, Wid[1], m_OutColour, m_InColour, m_nLineWidth);
        rekt(pShape, Pnt(2)^.Left+xo, Pnt(2)^.Top+yo, Pnt(3)^.Left+xo, Pnt(3)^.Top+yo, Wid[2], m_OutColour, m_InColour, m_nLineWidth);
        rekt(pShape, Pnt(3)^.Left+xo, Pnt(3)^.Top+yo, Pnt(13)^.Left+xo, Pnt(13)^.Top+yo, Wid[13], m_OutColour, m_InColour, m_nLineWidth);
        rekt(pShape, Pnt(1)^.Left+xo, Pnt(1)^.Top+yo, Pnt(4)^.Left+xo, Pnt(4)^.Top+yo, Wid[3], m_OutColour, m_InColour, m_nLineWidth);
        rekt(pShape, Pnt(4)^.Left+xo, Pnt(4)^.Top+yo, Pnt(5)^.Left+xo, Pnt(5)^.Top+yo, Wid[4], m_OutColour, m_InColour, m_nLineWidth);
        rekt(pShape, Pnt(5)^.Left+xo, Pnt(5)^.Top+yo, Pnt(14)^.Left+xo, Pnt(14)^.Top+yo, Wid[14], m_OutColour, m_InColour, m_nLineWidth);
        rekt(pShape, Pnt(6)^.Left+xo, Pnt(6)^.Top+yo, Pnt(7)^.Left+xo, Pnt(7)^.Top+yo, Wid[6], m_OutColour, m_InColour, m_nLineWidth);
        rekt(pShape, Pnt(7)^.Left+xo, Pnt(7)^.Top+yo, Pnt(8)^.Left+xo, Pnt(8)^.Top+yo, Wid[7], m_OutColour, m_InColour, m_nLineWidth);
        rekt(pShape, Pnt(8)^.Left+xo, Pnt(8)^.Top+yo, Pnt(11)^.Left+xo, Pnt(11)^.Top+yo, Wid[11], m_OutColour, m_InColour, m_nLineWidth);
        rekt(pShape, Pnt(6)^.Left+xo, Pnt(6)^.Top+yo, Pnt(9)^.Left+xo, Pnt(9)^.Top+yo, Wid[8], m_OutColour, m_InColour, m_nLineWidth);
        rekt(pShape, Pnt(9)^.Left+xo, Pnt(9)^.Top+yo, Pnt(10)^.Left+xo, Pnt(10)^.Top+yo, Wid[9], m_OutColour, m_InColour, m_nLineWidth);
        rekt(pShape, Pnt(10)^.Left+xo, Pnt(10)^.Top+yo, Pnt(12)^.Left+xo, Pnt(12)^.Top+yo, Wid[12], m_OutColour, m_InColour, m_nLineWidth);

        angle := 180 * (1 + ArcTan2(Pnt(6)^.Top-Pnt(1)^.Top, Pnt(6)^.Left-Pnt(1)^.Left) / PI);
        if angle >= 360.0 then angle := angle - 360.0;
        angle := angle - 180;
        Rads := DegToRad(angle);
        cx := (m_nHeadDiam div 2) * Cos(Rads);
        cy := (m_nHeadDiam div 2) * Sin(Rads);
        cx := Pnt(6)^.Left+cx;
        cy := Pnt(6)^.Top+cy;
        //Ellipse(round(cx-(m_nHeadDiam div 2)),round(cy-(m_nHeadDiam div 2)),round(cx+(m_nHeadDiam div 2)),round(cy+(m_nHeadDiam div 2)));

        angle := angle - 180;
        Rads := DegToRad(angle);
        cx := cx + (m_nHeadDiam div 2-2) * Cos(Rads);
        cy := cy + (m_nHeadDiam div 2-2) * Sin(Rads);
        ShapeLine(pShape, Pnt(6)^.Left+xo, Pnt(6)^.Top+yo, round(cx),round(cy), sr,sg,sb, m_nLineWidth);
        ShapeComplete(pShape);
      end;
      ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   end;

end;

function ExportFlash(strFileName : string) : boolean;
var
   m_hDLL : HMODULE;

	pMovie : pointer;
   f,g,h,i : integer;

   //
   pAction : TActionObjPtr;
   pPnt : TLabel2Ptr;
   rr,gg,bb : byte;
   nFrameNo : integer;

   m_xinc : integer;
   m_yinc : integer;
   m_xincmax : integer;
   m_yincmax : integer;
   m_bOld : boolean;

   olSets : TList;
   pLayer : TLayerObjPtr;
   pFrameSet : TSingleFramePtr;
   pFrame : TIFramePtr;
   pSet : TFlashSet;
   nLastFrame : integer;
   bAdded : boolean;

   tempFileName : array[0..255] of char;
   strTempFileName : string;

   pSetG, pSetH, pTempSet : TFlashSet;

   jpegFile : TJpegImage;
begin
   ExportFlash := FALSE;
   m_xinc := 0;
   m_yinc := 0;

   /////////////////// load the dll /////////////////////
   m_hDLL := LoadLibrary('tis_flash.dll');
   if (m_hDLL = 0) then
   begin
      exit;
   end;

   MovieCreate := pfMovieCreate(GetProcAddress(m_hDLL, 'Movie_create'));
   MovieDestroy := pfMovieDestroy(GetProcAddress(m_hDLL, 'Movie_destroy'));
   MovieAddObject := pfMovieAddObject(GetProcAddress(m_hDLL, 'Movie_addObject'));
   MovieRemoveObject := pfMovieRemoveObject(GetProcAddress(m_hDLL, 'Movie_removeObject'));
   MovieNextFrame := pfMovieNextFrame(GetProcAddress(m_hDLL, 'Movie_nextFrame'));
   MovieSave := pfMovieSave(GetProcAddress(m_hDLL, 'Movie_save'));

   MorphCreate := pfMorphCreate(GetProcAddress(m_hDLL, 'Morph_create'));
   MorphMorph := pfMorphMorph(GetProcAddress(m_hDLL, 'Morph_morph'));
   MorphDestroy := pfMorphDestroy(GetProcAddress(m_hDLL, 'Morph_destroy'));

   ShapeLine := pfShapeLine(GetProcAddress(m_hDLL, 'Shape_line'));
   ShapeRectangle := pfShapeRectangle(GetProcAddress(m_hDLL, 'Shape_rectangle'));
   ShapeCircle := pfShapeCircle(GetProcAddress(m_hDLL, 'Shape_circle'));
   ShapeComplete := pfShapeComplete(GetProcAddress(m_hDLL, 'Shape_complete'));
   ShapePolyStart := pfShapePolyStart(GetProcAddress(m_hDLL, 'Shape_polyStart'));
   ShapePolyNext := pfShapePolyNext(GetProcAddress(m_hDLL, 'Shape_polyNext'));

   ShapeAddBitmap := pfShapeAddBitmap(GetProcAddress(m_hDLL, 'Shape_addBitmap'));
   ShapeBitmap := pfShapeBitmap(GetProcAddress(m_hDLL, 'Shape_bitmap'));

   if (@MovieCreate = nil) or (@MovieDestroy = nil) or (@MovieAddObject = nil) or
      (@MovieNextFrame = nil) or (@MovieSave = nil) or (@MorphCreate = nil) or
      (@MorphMorph = nil) or (@MovieRemoveObject = nil) or (@ShapePolyStart = nil) or (@ShapePolyNext = nil) or
      (@MorphDestroy = nil) or (@ShapeLine = nil) or (@ShapeRectangle = nil) or
      (@ShapeAddBitmap = nil) or (@ShapeBitmap = nil) or
      (@ShapeCircle = nil) or (@ShapeComplete = nil) then
   begin
      FreeLibrary(m_hDLL);
      exit;
   end;

   ////////////// use dll ////////////////////////

   DWORDtoRGB(frmMain.m_bgColor, rr,gg,bb);

   nLastFrame := 0;
   for f := 0 to frmMain.m_olLayers.Count-1 do
   begin
      pLayer := frmMain.m_olLayers.Items[f];
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

   pMovie := MovieCreate(frmMain.frmCanvas.ClientWidth,
                         frmMain.frmCanvas.ClientHeight,
                         frmMain.m_nFPS*2,
                         rr,gg,bb,
                         nLastFrame);
   if (pMovie = nil) then exit;

   olSets := TList.Create;
   nFrameNo := 1;
   while (nFrameNo < nLastFrame) do
   begin
      for f := 0 to frmMain.m_olLayers.Count-1 do
      begin
         //render layer
         pLayer := frmMain.m_olLayers.Items[f];
         for g := 0 to pLayer^.m_olFrames.Count-1 do
         begin
            pFrameSet := pLayer^.m_olFrames.Items[g];
            for h := 0 to pFrameSet^.m_Frames.Count-1 do
            begin
               pFrame := pFrameSet^.m_Frames.Items[h];
               if (pFrame^.m_FrameNo = nFrameNo) then
               begin
                  for i := 0 to olSets.Count-1 do
                  begin
                     pSet := olSets.Items[i];
                     if (pSet.pFrameSet = pFrameSet) then
                     begin
                        olSets.Remove(pSet);
                        //MorphDestroy(pSet.pMorph);
                        MovieRemoveObject(pMovie, pSet.pDisplay);
                        pSet.Destroy;
                        break;
                     end;
                  end;
                  //if it's not the last frame of the frameset, create a new morph
                  if (pFrame <> pFrameSet^.m_Frames.Last) then
                  begin
                     pSet := TFlashSet.Create;
                     pSet.pMorph := MorphCreate(pMovie, pSet.pDisplay, pSet.pStartShape, pSet.pEndShape);
                     pSet.pFrameSet := pFrameSet;
                     pSet.nCurrent := 0;
                     pSet.nCount := TIFramePtr(pFrameSet^.m_Frames.Items[h+1])^.m_FrameNo - pFrame^.m_FrameNo;
                     pSet.nLayer := f;
                     //bitmap
                     if (pFrame^.m_nType = O_BITMAP) then
                     begin
                        GetTempPath(255, tempFileName);
                        strTempFileName := tempFileName;
                        GetTempFileName(pchar(strTempFileName), 'tisbmp', 0, tempFileName);
                        strTempFileName := tempFileName;
                        jpegFile := TJpegImage.Create;
                        jpegFile.Assign(TBitManPtr(pLayer^.m_pTempObject)^.Imarge.Picture.Bitmap);
                        jpegFile.SaveToFile(strTempFileName);
                        jpegFile.Destroy;

                        with TBitmanPtr(pFrame^.m_pObject)^ do
                        begin
                           ShapeAddBitmap(pSet.pStartShape, tempFileName);
                           ShapeBitmap(pSet.pStartShape, Pnt(1)^.Left, Pnt(1)^.Top, Pnt(3)^.Left, Pnt(3)^.Top);
                           ShapeComplete(pSet.pStartShape);
                        end;
                        pFrame := pFrameSet^.m_Frames.Items[h+1];
                        with TBitmanPtr(pFrame^.m_pObject)^ do
                        begin
                           ShapeAddBitmap(pSet.pEndShape, tempFileName);
                           ShapeBitmap(pSet.pEndShape, Pnt(1)^.Left, Pnt(1)^.Top, Pnt(3)^.Left, Pnt(3)^.Top);
                           ShapeComplete(pSet.pEndShape);
                        end;
                     end;
                     //lines
                     if (pFrame^.m_nType = O_LINE) then
                     begin
                        drawLine(m_xinc, m_yinc, pSet.pStartShape, pFrame^.m_pObject);
                        pFrame := pFrameSet^.m_Frames.Items[h+1];
                        drawLine(m_xinc, m_yinc, pSet.pEndShape, pFrame^.m_pObject);
                     end;
                     //rectangle
                     if (pFrame^.m_nType = O_RECTANGLE) then
                     begin
                        drawRect(m_xinc, m_yinc, pSet.pStartShape, pFrame^.m_pObject);
                        pFrame := pFrameSet^.m_Frames.Items[h+1];
                        drawRect(m_xinc, m_yinc, pSet.pEndShape, pFrame^.m_pObject);
                     end;
                     //polygon
                     if (pFrame^.m_nType = O_POLY) then
                     begin
                        drawPoly(m_xinc, m_yinc, pSet.pStartShape, pFrame^.m_pObject);
                        pFrame := pFrameSet^.m_Frames.Items[h+1];
                        drawPoly(m_xinc, m_yinc, pSet.pEndShape, pFrame^.m_pObject);
                     end;
                     //oval
                     if (pFrame^.m_nType = O_OVAL) then
                     begin
                        drawOval(m_xinc, m_yinc, pSet.pStartShape, pFrame^.m_pObject);
                        pFrame := pFrameSet^.m_Frames.Items[h+1];
                        drawOval(m_xinc, m_yinc, pSet.pEndShape, pFrame^.m_pObject);
                     end;
                     //stickman
                     if (pFrame^.m_nType = O_STICKMAN) then
                     begin
                        drawStick(m_xinc, m_yinc, pSet.pStartShape, pFrame^.m_pObject);
                        pFrame := pFrameSet^.m_Frames.Items[h+1];
                        drawStick(m_xinc, m_yinc, pSet.pEndShape, pFrame^.m_pObject);
                     end;
                     //special stickman
                     if (pFrame^.m_nType = O_SPECIALSTICK) then
                     begin
                        drawSpecialStick(m_xinc, m_yinc, pSet.pStartShape, pFrame^.m_pObject);
                        pFrame := pFrameSet^.m_Frames.Items[h+1];
                        drawSpecialStick(m_xinc, m_yinc, pSet.pEndShape, pFrame^.m_pObject);
                     end;
                     olSets.Add(pSet);
                  end;
               end;
            end;
         end;
         // render actions
         for g := 0 to TLayerObjPtr(frmMain.m_olLayers.Items[f])^.m_olActions.Count - 1 do
         begin
            pAction := TActionObjPtr(TLayerObjPtr(frmMain.m_olLayers.Items[f])^.m_olActions.Items[g]);
            if (pAction^.m_nFrameNo = nFrameNo) then
            begin
               case pAction^.m_nType of
                  A_JUMPTO: if (pAction^.m_nParams[3] < pAction^.m_nParams[2]) then
                     begin
                        nFrameNo := pAction^.m_nParams[1];
                        pAction^.m_nParams[3] := pAction^.m_nParams[3]+1;
                     end;
                  A_SHAKE: begin
                        m_xinc := 0;
                        m_yinc := 0;
                        m_xincmax := 0;
                        m_yincmax := 0;
                        if (pAction^.m_nParams[2] = 1) then
                        begin
                           m_xincmax := pAction^.m_nParams[1];
                        end;
                        if (pAction^.m_nParams[3] = 1) then
                        begin
                           m_yincmax := pAction^.m_nParams[1];
                        end;
                     end;
                  A_OLD: m_bOld := pAction^.m_nParams[1] = 1;
               end;
            end;
         end;
      end;

      //effects do later
      {if (m_xincmax <> 0) then m_xinc := (-m_xincmax) + random(m_xincmax*2);
      if (m_yincmax <> 0) then m_yinc := (-m_yincmax) + random(m_yincmax*2);
      {if (m_bOld) then
      begin
         m_Canvas.Pen.Color := clBlack;
         g := random(8);
         if (g=1) then
         begin
            f := random(frmMain.frmCanvas.ClientWidth);
            ShapeLine(pShape, f,0, f-5+random(10),frmMain.frmCanvas.ClientHeight, 0,0,0, random(3));
         end;
         g := random(6);
         if (g=2) then
         begin
            m_Canvas.Pen.Width := random(3);
            f := random(frmMain.frmCanvas.ClientWidth);
            g := random(frmMain.frmCanvas.ClientHeight);
            h := random(30);
            m_Canvas.Arc(f,g,f+h,g+h,f,g,random(frmCanvas.ClientWidth),random(frmCanvas.ClientHeight));
         end;
         for f := 0 to 100 do
         begin
            m_Canvas.Pen.Width := 1 + random(3);
            g := random(frmCanvas.ClientWidth);
            h := random(frmCanvas.ClientHeight);
            m_Canvas.Ellipse(g,h,g+1,h+1);
         end;
      end;}

      //order the sets
      for g := 0 to olSets.Count-2 do
      begin
         pSetG := olSets.Items[g];
         for h := g+1 to olSets.Count-1 do
         begin
            pSetH := olSets.Items[h];
            if (pSetG.nLayer > pSetH.nLayer) then
            begin
               pTempSet := TFlashSet.Create;
               pTempSet.Assign(pSetG);
               pSetG.Assign(pSetH);
               pSetH.Assign(pTempSet);
               pTempSet.Destroy;
            end;
         end;
      end;

      pSet := nil;
      for g := 0 to olSets.Count-1 do
      begin
         if (pSet <> nil) then
         begin
            if (pSet.nLayer > TFlashSet(olSets.Items[g]).nLayer) then
            begin
               pSet.nLayer := pSet.nLayer-1;
            end;
         end;
         pSet := olSets.Items[g];
         pSet.nCurrent := pSet.nCurrent + 1;
         MorphMorph(pSet.pDisplay, pSet.nCurrent, pSet.nCount);
      end;

      nFrameNo := nFrameNo + 1;
      MovieNextFrame(pMovie);
   end;

   pSet := nil;
   for f := 0 to olSets.Count-1 do
   begin
      pSet := olSets.Items[f];
      //MorphDestroy(pSet.pMorph);
      MovieRemoveObject(pMovie, pSet.pDisplay);
      pSet.Destroy;
   end;
   olSets.Destroy;

   /////////////////////////////////////////////////////////////////////////////////////////////////////////

   MovieNextFrame(pMovie);
   MovieSave(pMovie, 'c:\temp\tis.swf');
	MovieDestroy(pMovie);

   FreeLibrary(m_hDLL);
   ExportFlash := true;
end;

end.

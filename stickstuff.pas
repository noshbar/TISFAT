unit stickstuff;

interface

uses classes, graphics, stickjoint, types, math, sysutils, GDIPAPI, GDIPOBJ;

//{$DEFINE SHOWANGLES}
{$I constants.inc}

type
   TLimbListPtr = ^TLimbList;
   TLimbList = class(TObject)
      protected
         m_olJoints : TList;
         m_bCalcIK : boolean;
         m_nIndex : integer;
         m_pCanvas : TCanvas;
         m_nJointCount : integer;
         m_bShowJoints : boolean;
         m_sAlpha : single;
         m_nDrawMode : integer;
         m_sTension : single;
         m_nCurveWidth : integer;
         m_nPoseCount : integer;
         m_nBitmapCount : integer;
         m_olBitmaps : TList;
         bShallowBitmaps : boolean;
         function GetJoint(nIndex : integer) : TJoint;
         function GetLengthN(nIndex : integer) : integer;
         procedure SetLengthN(nIndex : integer; nVal : integer);
         function GetBitmap(nIndex : integer) : TGPBitmap;
      public
         constructor Create;
         destructor Destroy; override;
         procedure SetJoint(nIndex : integer; x,y : integer);
         function AddJoint(x, y : integer) : TJoint;
         function GetJointAt(x,y, nAllowance : integer) : TJoint;
         function GetJointCount : integer;
         function GetJointCovering(x,y, nAllowance : integer; var pParent : TJoint) : TJoint;
         procedure Draw(xoffs,yoffs:integer);
         procedure DrawChild(xoffs,yoffs:integer; pJoint : TJoint);
         procedure Move(xAmount, yAmount : integer);
         procedure DrawJoint(xoffs,yoffs:integer; pJoint, pChild : TJoint);

         procedure CopyFrom(pSource : TLimbList);
         procedure CopyPropsFrom(pSource : TLimbList);
         procedure Tween(pStart, pEnd : TLimbList; sPercent : single);

         procedure AddMissingBitmaps(Source : TLimbList);

         procedure Scale(sPercent : single);

         procedure GetExtent(var left, top, right, bottom : integer);

         function AddBitmap(f : string) : integer;
         procedure GetBitmapNames(slNames : TStringList);

         procedure Clear(keepBitmaps : BOOLEAN = FALSE);
         function Read(var pFile : TFileStream) : boolean;
         function Write(var pFile : TFileStream) : boolean;
         function Load(strFileName : string) : boolean;

         procedure CopyBitmapsShallow(Source : TLimbList);
         procedure ClearBitmaps;

         property Joint[nIndex : integer] : TJoint read GetJoint;
         property Length[nIndex : integer] : integer read GetLengthN write SetLengthN;
         property CalculateIK : boolean read m_bCalcIK write m_bCalcIK;
         property Canvas : TCanvas read m_pCanvas write m_pCanvas;
         property JointCount : integer read GetJointCount write m_nJointCount;
         property ShowJoints : boolean read m_bShowJoints write m_bShowJoints;
         property Alpha : single read m_sAlpha write m_sAlpha;
         property DrawMode : integer read m_nDrawMode write m_nDrawMode;
         property CurveWidth : integer read m_nCurveWidth write m_nCurveWidth;
         property Bitmap[nIndex : integer] : TGPBitmap read GetBitmap;
         property Tension : single read m_sTension write m_sTension;
   end;

implementation

uses jointbitmap;

constructor TLimbList.Create;
begin
   m_bCalcIK := TRUE;
   m_olJoints := TList.Create;
   m_nJointCount := 0;
   m_bShowJoints := TRUE;
   m_sAlpha := 1.0;
   m_nDrawMode := C_STICK_DRAWMODE_STRAIGHT;
   m_sTension := 0.5;
   m_nCurveWidth := 1;
   m_nPoseCount := 0;
   m_nBitmapCount := 0;
   m_olBitmaps := TList.Create;
   bShallowBitmaps := FALSE;
end;

procedure TLimbList.ClearBitmaps;
var
   f : integer;
begin
   if (not bShallowBitmaps) then
   begin
      for f := 0 to m_olBitmaps.Count-1 do
      begin
         TJointBitmap(m_olBitmaps.Items[f]).Destroy;
      end;
   end;
   m_olBitmaps.Clear;
   m_nBitmapCount := 0;
   bShallowBitmaps := FALSE;
end;

procedure TLimbList.Clear(keepBitmaps : BOOLEAN);
var
   f : integer;
begin
   for f := 0 to m_olJoints.Count-1 do
   begin
      TJoint(m_olJoints.Items[f]).Destroy;
   end;
   m_olJoints.Clear;
   m_nJointCount := 0;

   if (not keepBitmaps) then
      clearBitmaps;
end;

destructor TLimbList.Destroy;
begin
   Clear;
   inherited Destroy;
end;

function TLimbList.GetJointCount : integer;
begin
   GetJointCount := m_olJoints.Count;
end;

function TLimbList.GetJoint(nIndex : integer) : TJoint;
begin
   GetJoint := nil;
   if (nIndex < m_olJoints.Count) then
   begin
      GetJoint := TJoint(m_olJoints.Items[nIndex]);
   end;
end;

function TLimbList.GetLengthN(nIndex : integer) : integer;
begin
   GetLengthN := -1;
   if (nIndex < m_olJoints.Count) then
   begin
      GetLengthN := TJoint(m_olJoints.Items[nIndex]).Length;
   end;
end;

procedure TLimbList.SetLengthN(nIndex : integer; nVal : integer);
begin
   if (nIndex < m_olJoints.Count) then
   begin
      TJoint(m_olJoints.Items[nIndex]).Length := nVal
   end;
end;

function TLimbList.GetJointAt(x,y, nAllowance : integer) : TJoint;
var
   f : integer;
   pJoint : TJoint;
   pResult : TJoint;
begin
   GetJointAt := nil;
   for f := 0 to m_olJoints.Count-1 do
   begin
      pJoint := TJoint(m_olJoints.Items[f]);
      pResult := pJoint.GetJointAt(x,y, nAllowance);
      if (pResult <> nil) then
      begin
         if (pResult.State <> C_STATE_ADJUST_TO_PARENT_LOCKED) then
         begin
            GetJointAt := pResult;
            exit;
         end;
      end;
   end;
end;

function TLimbList.AddJoint(x, y : integer) : TJoint;
var
   pJoint : TJoint;
begin
   pJoint := TJoint.Create;
   m_olJoints.Add(pJoint);
   pJoint.SetPos(x,y);
   AddJoint := pJoint;
   m_nJointCount := m_nJointCount + 1;
end;

procedure TLimbList.SetJoint(nIndex : integer; x,y : integer);
begin
   if (nIndex < m_olJoints.Count) then
   begin
      TJoint(m_olJoints.Items[nIndex]).SetPos(x,y);
   end;
end;

procedure TLimbList.DrawJoint(xoffs,yoffs:integer; pJoint, pChild : TJoint);
var
   dAngle : real;
   x,y : integer;
   w,h,l : integer;
   points : array[0..3] of TPoint;
begin
   m_pCanvas.Pen.Style := psSolid;
   m_pCanvas.Pen.Width := pJoint.Width;
   m_pCanvas.Pen.Color := pJoint.Colour;
   m_pCanvas.Brush.Color := pJoint.FillColour;
   if (pJoint.Fill) then
      m_pCanvas.Brush.Style := bsSolid
   else
      m_pCanvas.Brush.Style := bsClear;

   if (pJoint.DrawAs = C_DRAW_AS_LINE) then
   begin
      m_pCanvas.MoveTo(xoffs+pChild.X, yoffs+pChild.Y);
      m_pCanvas.LineTo(xoffs+pJoint.X, yoffs+pJoint.Y);
   end;
   if (pJoint.DrawAs = C_DRAW_AS_RECT) then
   begin
      w := pChild.X - pJoint.X;
      h := pChild.Y - pJoint.Y;
      dAngle := 180 * (1 + ArcTan2(h, w) / PI);
      dAngle := dAngle + 90;

      w := round( cos(dAngle * PI / 180) * (pJoint.DrawWidth / 2) );
      h := round( sin(dAngle * PI / 180) * (pJoint.DrawWidth / 2) );

      points[0].X := xoffs+pChild.X + w;
      points[0].Y := yoffs+pChild.Y + h;
      points[1].X := xoffs+pChild.X - w;
      points[1].Y := yoffs+pChild.Y - h;
      points[2].X := xoffs+pJoint.X - w;
      points[2].Y := yoffs+pJoint.Y - h;
      points[3].X := xoffs+pJoint.X + w;
      points[3].Y := yoffs+pJoint.Y + h;

      m_pCanvas.Polygon(Slice(points, 4));
   end;
   if (pJoint.DrawAs = C_DRAW_AS_CIRCLE) then
   begin
      w := pChild.X - pJoint.X;
      h := pChild.Y - pJoint.Y;
      l := round(sqrt(sqr(w)+sqr(h)));
      x := pChild.X - (w div 2);
      y := pChild.Y - (h div 2);
      l := l div 2; //radius
      m_pCanvas.Ellipse(xoffs+x-l, yoffs+y-l, xoffs+x+l, yoffs+y+l);
   end;

   m_pCanvas.Brush.Style := bsSolid;
   {$IFDEF SHOWANGLES} m_pCanvas.TextOut(pJoint.x,pJoint.y, floattostr(pJoint.AngleToParent)); {$ENDIF}

   if not m_bShowJoints then exit;

   m_pCanvas.Pen.Width := 1;
   if (pJoint.State = C_STATE_NORMAL) then
   begin
      m_pCanvas.Brush.Color := clGreen;
      m_pCanvas.Pen.Color := clWhite;
      m_pCanvas.Rectangle(xoffs+pJoint.X-4, yoffs+pJoint.Y-4, xoffs+pJoint.X+4, yoffs+pJoint.Y+4);
   end;
   if (pJoint.State = C_STATE_SELECTED) then
   begin
      m_pCanvas.Pen.Color := clBlack;
      m_pCanvas.Brush.Color := $D0D0FF;
      m_pCanvas.Ellipse(xoffs+pJoint.X-6, yoffs+pJoint.Y-6, xoffs+pJoint.X+6, yoffs+pJoint.Y+6);
   end;
   if (pJoint.State = C_STATE_LOCKED) then
   begin
      m_pCanvas.Brush.Color := clBlue;
      m_pCanvas.Pen.Color := clWhite;
      m_pCanvas.Ellipse(xoffs+pJoint.X-4, yoffs+pJoint.Y-4, xoffs+pJoint.X+4, yoffs+pJoint.Y+4);
   end;
   if (pJoint.State = C_STATE_ADJUST_TO_PARENT) then
   begin
      m_pCanvas.Brush.Color := clBlack;
      m_pCanvas.Pen.Color := clWhite;
      m_pCanvas.Ellipse(xoffs+pJoint.X-4, yoffs+pJoint.Y-4, xoffs+pJoint.X+4, yoffs+pJoint.Y+4);
      m_pCanvas.Ellipse(xoffs+pJoint.X-2, yoffs+pJoint.Y-2, xoffs+pJoint.X+2, yoffs+pJoint.Y+2);
   end;
   if (pJoint.State = C_STATE_ADJUST_TO_PARENT_LOCKED) then
   begin
      m_pCanvas.Brush.Color := clRed;
      m_pCanvas.Pen.Color := clWhite;
      m_pCanvas.Ellipse(xoffs+pJoint.X-4, yoffs+pJoint.Y-4, xoffs+pJoint.X+4, yoffs+pJoint.Y+4);
      m_pCanvas.Ellipse(xoffs+pJoint.X-2, yoffs+pJoint.Y-2, xoffs+pJoint.X+2, yoffs+pJoint.Y+2);
   end;
end;

procedure TLimbList.DrawChild(xoffs,yoffs:integer; pJoint : TJoint);
var
   f : integer;
   pChild : TJoint;
begin
   for f := 0 to pJoint.m_olChildren.Count-1 do
   begin
      pChild := TJoint(pJoint.m_olChildren.Items[f]);
      DrawJoint(xoffs,yoffs, pChild, pJoint);
      DrawChild(xoffs,yoffs, pChild);
   end;
end;

procedure TLimbList.Draw(xoffs,yoffs:integer);
var
   f, g : integer;
   pJoint, pChild : TJoint;
begin
   for f := 0 to m_olJoints.Count-1 do
   begin
      pJoint := TJoint(m_olJoints.Items[f]);
      for g := 0 to pJoint.m_olChildren.Count-1 do
      begin
         pChild := TJoint(pJoint.m_olChildren.Items[g]);
         DrawJoint(xoffs,yoffs,pChild, pJoint);
         DrawChild(xoffs,yoffs,pChild);
      end;
      if m_bShowJoints then
      begin
         m_pCanvas.Pen.Width := 1;
         m_pCanvas.Pen.Color := clBlack;
         m_pCanvas.Brush.Color := clYellow;
         m_pCanvas.Rectangle(xoffs+pJoint.X-6, yoffs+pJoint.Y-6, xoffs+pJoint.X+6, yoffs+pJoint.Y+6);
         m_pCanvas.Brush.Color := clGreen;
         m_pCanvas.Ellipse(xoffs+pJoint.X-4, yoffs+pJoint.Y-4, xoffs+pJoint.X+4, yoffs+pJoint.Y+4);

      end;
   end;
end;

procedure TLimbList.Move(xAmount, yAmount : integer);
var
   f, g : integer;
   pJoint, pChild : TJoint;
   procedure MoveChild(pOtherJoint : TJoint);
   var
      f : integer;
      pOtherOtherJoint : TJoint;
   begin
      for f := 0 to pOtherJoint.m_olChildren.Count-1 do
      begin
         pOtherOtherJoint := TJoint(pOtherJoint.m_olChildren.Items[f]);
         pOtherOtherJoint.SetPosAbs(pOtherOtherJoint.X+xAmount, pOtherOtherJoint.Y+yAmount);
         MoveChild(pOtherOtherJoint);
      end;
   end;
begin
   for f := 0 to m_olJoints.Count-1 do
   begin
      pJoint := TJoint(m_olJoints.Items[f]);
      pJoint.SetPosAbs(pJoint.X+xAmount, pJoint.Y+yAmount);
      for g := 0 to pJoint.m_olChildren.Count-1 do
      begin
         pChild := TJoint(pJoint.m_olChildren.Items[g]);
         pChild.SetPosAbs(pChild.X+xAmount, pChild.Y+yAmount);
         MoveChild(pChild);
      end;
   end;
end;

function TLimbList.GetJointCovering(x,y, nAllowance : integer; var pParent : TJoint) : TJoint;
var
   f : integer;
   pJoint : TJoint;
   function _GetCovering(pStart : TJoint; var pMother : TJoint) : TJoint;
   var
      ff,h : integer;
      pChild : TJoint;
      x1,y1,x2,y2 : integer;
      a,b : integer;
      sLength : single;
   begin
      _GetCovering := nil;
      for ff := 0 to pStart.m_olChildren.Count-1 do
      begin
         pChild := TJoint(pStart.m_olChildren.Items[ff]);
         x1 := pStart.X;
         y1 := pStart.Y;
         x2 := pChild.X;
         y2 := pChild.Y;
         begin
            sLength := sqrt( sqr(x1-x2) + sqr(y1-y2) );
            for h := 0 to round(sLength) do
            begin
               if x1<x2
                  then a := round(x1 + (h * ( abs(x1-x2)/sLength )))
                  else a := round(x2 + (h * ( abs(x2-x1)/sLength )));
               if y1<y2
                  then b := round(y1 + (h * ( abs(y1-y2)/sLength )))
                  else b := round(y2 + (h * ( abs(y2-y1)/sLength )));
               if (x >= a-nAllowance) and (x <= a+nAllowance) and (y >= b-nAllowance) and (y <= b+nAllowance) then
               begin
                  GetJointCovering := pChild;
                  pMother := pStart;
                  exit;
               end;
            end;
         end;
         pChild := _GetCovering(pChild, pMother);
         if (pChild <> nil) then
         begin
            pMother := pStart;
            _GetCovering := pChild;
            exit;
         end;
      end;
   end;
begin
   GetJointCovering := nil;
   pParent := nil;
   for f := 0 to m_olJoints.Count-1 do
   begin
      pJoint := TJoint(m_olJoints.Items[f]);
      pJoint := _GetCovering(pJoint, pParent);
      if (pJoint <> nil) then
      begin
         GetJointCovering := pJoint;
         exit;
      end;
   end;
end;

function TLimbList.Read(var pFile : TFileStream) : boolean;
var
   f : integer;
   pJoint : TJoint;
   nCount : integer;
   bmp : TJointBitmap;
begin
   Clear();
   pFile.Read(m_nDrawMode, sizeof(m_nDrawMode));
   pFile.Read(m_sTension, sizeof(m_sTension));
   pFile.Read(m_nCurveWidth, sizeof(m_nCurveWidth));
   pFile.Read(m_nJointCount, sizeof(m_nJointCount));
   pFile.Read(nCount, sizeof(nCount));
   for f := 0 to nCount-1 do
   begin
      pJoint := TJoint.Create;
      m_olJoints.Add(pJoint);
      pJoint.Read(pFile);
   end;

   //THIS IS THE FUTURE HOME OF THE AMOUNT OF POSES
   pFile.Read(m_nPoseCount, sizeof(m_nPoseCount));
   m_sAlpha := 1 - (m_nPoseCount / 255);
   //THIS IS THE FUTURE HOME OF BITMAPS WITHIN THE FILE
   pFile.Read(m_nBitmapCount, sizeof(m_nBitmapCount));
   for f := 0 to m_nBitmapCount-1 do
   begin
      bmp := TJointBitmap.Create(pFile);
      m_olBitmaps.Add(bmp);
   end;

end;

function TLimbList.Load(strFileName : string) : boolean;
var
   pFile : TFileStream;
begin
   Load := FALSE;

   pFile := TFileStream.Create(strFileName, fmOpenRead);
   if (pFile = nil) then
      exit;

   Load := Read(pFile);
   pFile.Destroy;
end;

function TLimbList.Write(var pFile : TFileStream) : boolean;
var
   f : integer;
   pJoint : TJoint;
   count : integer;
begin
   pFile.Write(m_nDrawMode, sizeof(m_nDrawMode));
   pFile.Write(m_sTension, sizeof(m_sTension));
   pFile.Write(m_nCurveWidth, sizeof(m_nCurveWidth));
   pFile.Write(m_nJointCount, sizeof(m_nJointCount));
   count := m_olJoints.Count;
   pFile.Write(count, sizeof(count));
   for f := 0 to count-1 do
   begin
      pJoint := TJoint(m_olJoints.Items[f]);
      pJoint.Write(pFile);
   end;

   //THIS IS THE FUTURE HOME OF THE AMOUNT OF POSES
   m_nPoseCount := 1 - round(m_sAlpha * 255); //HAAAAAAAACK if I ever need it... make this > 255 to signal more info, then append alpha
   pFile.Write(m_nPoseCount, sizeof(m_nPoseCount));
   pFile.Write(m_nBitmapCount, sizeof(m_nBitmapCount));
   for f := 0 to m_nBitmapCount-1 do
   begin
      TJointBitmap(m_olBitmaps.Items[f]).Save(pFile);
   end;
end;

procedure TLimbList.CopyFrom(pSource : TLimbList);
var
   f : integer;
   pJoint : TJoint;
begin
   Clear;

   m_sAlpha := pSource.m_sAlpha;
   m_bCalcIK := pSource.m_bCalcIK;
   m_nIndex := pSource.m_nIndex;
   m_pCanvas := pSource.m_pCanvas;
   m_nJointCount := pSource.m_nJointCount;
   m_bShowJoints := pSource.m_bShowJoints;
   m_nDrawMode := pSource.m_nDrawMode;
   m_sTension := pSource.m_sTension;
   m_nCurveWidth := pSource.m_nCurveWidth;

   for f := 0 to pSource.m_olJoints.Count-1 do
   begin
      pJoint := TJoint.Create;
      m_olJoints.Add(pJoint);
      pJoint.CopyFrom(TJoint(pSource.m_olJoints.Items[f]));
   end;

   m_nPoseCount := pSource.m_nPoseCount;
   //FUTURE POSE COPY
end;

procedure TLimbList.CopyPropsFrom(pSource : TLimbList);
var
   f : integer;
   pJoint : TJoint;
begin
   m_sAlpha := pSource.m_sAlpha;
   m_bCalcIK := pSource.m_bCalcIK;
   m_nIndex := pSource.m_nIndex;
   m_pCanvas := pSource.m_pCanvas;
   m_nJointCount := pSource.m_nJointCount;
   m_bShowJoints := pSource.m_bShowJoints;
   m_nDrawMode := pSource.m_nDrawMode;
   m_sTension := pSource.m_sTension;
   m_nCurveWidth := pSource.m_nCurveWidth;

   for f := 0 to pSource.m_olJoints.Count-1 do
   begin
      pJoint := TJoint(m_olJoints.Items[f]);
      pJoint.CopyPropsFrom(TJoint(pSource.m_olJoints.Items[f]));
   end;
end;

procedure TLimbList.Tween(pStart, pEnd : TLimbList; sPercent : single);
var
   f : integer;
   pNew : TJoint;
begin
   Clear(true);

   m_bCalcIK := pStart.m_bCalcIK;
   m_nIndex := pStart.m_nIndex;
   m_pCanvas := pStart.m_pCanvas;
   m_nJointCount := pStart.m_nJointCount;
   m_bShowJoints := pStart.m_bShowJoints;
   m_nDrawMode := pStart.m_nDrawMode;
   m_sTension := pStart.m_sTension + ((pEnd.m_sTension - pStart.m_sTension) * sPercent);
   m_sAlpha := pStart.m_sAlpha + ((pEnd.m_sAlpha - pStart.m_sAlpha) * sPercent);
   m_nCurveWidth := round(pStart.m_nCurveWidth + ((pEnd.m_nCurveWidth - pStart.m_nCurveWidth) * sPercent));

   for f := 0 to pStart.m_olJoints.Count-1 do
   begin
      pNew := TJoint.Create;
      m_olJoints.Add(pNew);
      pNew.Tween(TJoint(pStart.m_olJoints.Items[f]), TJoint(pEnd.m_olJoints.Items[f]), sPercent);
   end;
end;

procedure TLimbList.GetExtent(var left, top, right, bottom : integer);
var
   f : integer;
   pJoint : TJoint;
   l,t,r,b : integer;
begin
   left := 65535;
   top := 65535;
   right := -65535;
   bottom := -65535;

   l := 65535;
   t := 65535;
   r := -65535;
   b := -65535;

   for f := 0 to m_olJoints.Count-1 do
   begin
      pJoint := TJoint(m_olJoints.Items[f]);
      pJoint.GetExtent(l,t,r,b);
      if l < left then left := l;
      if t < top then top := t;
      if r > right then right := r;
      if b > bottom then bottom := b;
   end;
end;

procedure TLimbList.Scale(sPercent : single);
var
   pJoint : TJoint;
   f : integer;
begin
   m_nCurveWidth := round(m_nCurveWidth * sPercent);
   for f := 0 to m_olJoints.Count-1 do
   begin
      pJoint := TJoint(m_olJoints.Items[f]);
      pJoint.Scale(sPercent);
   end;
end;

function TLimbList.AddBitmap(f : string) : integer;
var
   bmp : TJointBitmap;
begin
   AddBitmap := -1;
   bmp := TJointBitmap.Create(f);
   AddBitmap := m_olBitmaps.Add(bmp);
   m_nBitmapCount := m_nBitmapCount + 1;
end;

function TLimbList.GetBitmap(nIndex : integer) : TGPBitmap;
begin
   GetBitmap := nil;
   if (nIndex < m_olBitmaps.Count) then
      GetBitmap := TJointBitmap(m_olBitmaps.Items[nIndex]).bitmap;   
end;

procedure TLimbList.CopyBitmapsShallow(Source : TLimbList);
var
   f : integer;
begin
   clearBitmaps;
   for f := 0 to source.m_olBitmaps.Count-1 do
   begin
      m_olBitmaps.Add(source.m_olBitmaps[f]);
      m_nBitmapCount := m_nBitmapCount + 1;
   end;
   bShallowBitmaps := TRUE;
end;

procedure TLimbList.GetBitmapNames(slNames : TStringList);
var
   f : integer;
begin
   if (m_olBitmaps = nil) then
      exit;

   for f := 0 to m_olBitmaps.Count-1 do
   begin
      slNames.Add(TJointBitmap(m_olBitmaps.Items[f]).Name);
   end;
end;

procedure TLimbList.AddMissingBitmaps(Source : TLimbList);
var
   f,g : integer;
   found : boolean;
   n : string;
   bmp : TJointBitmap;
begin
   if (source.m_olBitmaps = nil) then
      exit;

   if (m_olBitmaps = nil) then
   begin
      m_olBitmaps := TList.Create;
   end;

   for f := 0 to Source.m_olBitmaps.Count-1 do
   begin
      found := false;
      bmp := TJointBitmap(Source.m_olBitmaps.Items[f]);
      n := bmp.Name;
      for g := 0 to m_olBitmaps.Count-1 do
      begin
         if (n = TJointBitmap(m_olBitmaps.Items[g]).Name) then
         begin
            found := true;
            break;
         end;
      end;

      if (not found) then
      begin
         bmp := TJointBitmap.Create(bmp);
         m_olBitmaps.Add(bmp);
         m_nBitmapCount := m_nBitmapCount + 1;
      end;
   end;
end;

end.

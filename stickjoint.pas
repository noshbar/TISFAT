unit stickjoint;

interface

uses classes, math, graphics;

const
   C_STATE_NORMAL = 1;
   C_STATE_LOCKED = 2;
   C_STATE_ADJUST_TO_PARENT = 3;
   C_STATE_ADJUST_TO_PARENT_LOCKED = 4;
   C_STATE_SELECTED = 5;

   C_DRAW_AS_LINE = 0;
   C_DRAW_AS_RECT = 1;
   C_DRAW_AS_CIRCLE = 2;
   //C_DRAW_AS_BITMAP = 3;
   
type
   TJoint = class(TObject)
      protected
         m_nX,m_nY : integer;
         m_nState : integer;
         m_nLength : integer;
         m_nIndex : integer;
         m_pParent : TJoint;
         m_sAngleToParent : single;
         m_nBitmap : integer; //the index of the bitmap in the stick figure image array
         m_bShowLine : boolean;
         m_nBMPXoffs, m_nBMPYoffs : integer;
         m_sBitmapRotation : single;
         m_nBitmapAlpha : byte;
         m_nLineWidth : integer;
         m_nColour : TColor;
         m_nInColour : TColor;
         m_bFill : boolean;
         m_nDrawAs : integer;
         m_nDrawWidth : integer;
         m_pData : pointer;
         //still need serializing from here on
         m_strName : string;
         //?
      public
         m_olChildren : TList;
         constructor Create;
         destructor Destroy;
         procedure SetPos(vx,vy : integer);
         procedure SetPosAbs(vx,vy:integer);
         procedure CalcLength(pStart : TJoint = nil);
         function AddChild(vx,vy : integer) : TJoint;
         function GetFirstChild : boolean;
         function GetNextChild(var pJoint : TJoint) : boolean;
         function GetJointAt(vx,vy, nAllowance : integer) : TJoint;
         procedure Recalc(pStart : TJoint);
         procedure Clear;

         procedure CopyFrom(pSource : TJoint);
         procedure CopyPropsFrom(pSource : TJoint);
         procedure Tween(pStart, pEnd : TJoint; sPercent : single);

         function Read(var pFile : TFileStream) : boolean;
         function Write(var pFile : TFileStream) : boolean;

         procedure GetExtent(var left, top, right, bottom : integer);

         procedure Scale(sPercent : single);

         property State : integer read m_nState write m_nState;
         property Length : integer read m_nLength write m_nLength;
         property X : integer read m_nX;
         property Y : integer read m_nY;
         property Parent : TJoint read m_pParent write m_pParent;
         property AngleToParent : single read m_sAngleToParent write m_sAngleToParent;
         //property Bitmap : pointer read m_pBitmap write m_pBitmap;
         property Name : String read m_strName write m_strName;
         property Width : Integer read m_nLineWidth write m_nLineWidth;
         property Colour : TColor read m_nColour write m_nColour;
         property FillColour : TColor read m_nInColour write m_nInColour;
         property Fill : boolean read m_bFill write m_bFill;
         property BitmapX : integer read m_nBMPXoffs write m_nBMPXoffs;
         property BitmapY : integer read m_nBMPYoffs write m_nBMPYoffs;
         property ShowStick : boolean read m_bShowLine write m_bShowLine;
         property BitmapRotation : single read m_sBitmapRotation write m_sBitmapRotation;
         property DrawAs : integer read m_nDrawAs write m_nDrawAs;
         property DrawWidth : integer read m_nDrawWidth write m_nDrawWidth;
         property CurrentBitmap : integer read m_nBitmap write m_nBitmap;
         property Data : pointer read m_pData write m_pData;
   end;

implementation

procedure DWORDtoRGB(t : tcolor; var r,g,b : byte);
begin
   b := t shr 16;
   g := t shr 8;
   r := t;
end;
procedure RGBtoDWORD(r,g,b : byte; var t : tcolor);
begin
   t := r + (g shl 8) + (b shl 16);
end;

constructor TJoint.Create;
begin
   m_nState := C_STATE_NORMAL;
   m_nLength := 0;
   m_pParent := nil;
//   m_pBitmap := nil;
   m_olChildren := TList.Create;
   m_nBMPXoffs := 0;
   m_nBMPYoffs := 0;
   m_strName := 'Untitled';
   m_nLineWidth := 1;
   m_bShowLine := TRUE;
   m_sBitmapRotation := 0;
   m_nBitmapAlpha := 255;
   m_nBitmap := -1;
   m_nDrawAs := C_DRAW_AS_LINE;
   m_nDrawWidth := 10;
   m_nColour := clBlack;
   m_nInColour := clBlack;
   m_bFill := false;
end;

procedure TJoint.Clear;
var
   f : integer;
   pChild : TJoint;
begin
   if (m_pParent <> nil) then
   begin
      //remove from the parent list, and add all the children to the parent's children list
      f := m_pParent.m_olChildren.IndexOf(self);
      if (f <> -1) then
      begin
         m_pParent.m_olChildren.Remove(self);
      end;
      for f := 0 to m_olChildren.Count-1 do
      begin
         pChild := TJoint(m_olChildren.Items[f]);
         if (m_pParent.m_olChildren.IndexOf(pChild) = -1) then
         begin
            m_pParent.m_olChildren.Add(pChild);
         end;
      end;
   end;
   for f := 0 to m_olChildren.Count-1 do
   begin
      //set all the childrens new parent to self.parent
      pChild := TJoint(m_olChildren.Items[f]);
      pChild.Parent := m_pParent;
   end;
   m_olChildren.Clear;
end;

destructor TJoint.Destroy;
begin
   Clear;
   m_olChildren.Destroy;
end;

procedure TJoint.CalcLength(pStart : TJoint{ = nil});
var
   f : integer;
   pChild : TJoint;
begin
   if (pStart = nil) then pStart := self;
   if (pStart.Parent <> nil) then pStart.Length := round( sqrt( ((pStart.Parent.X-pStart.X)*(pStart.Parent.X-pStart.X)) +   ((pStart.Parent.Y-pStart.Y)*(pStart.Parent.Y-pStart.Y)) ) );
   if (pStart.GetFirstChild()) then
   begin
      while (pStart.GetNextChild(pChild)) do
      begin
         pChild.CalcLength(pChild);
      end;
   end;
end;
procedure TJoint.SetPosAbs(vx,vy:integer);
begin
   m_nX := vx;
   m_nY := vy;
end;

procedure TJoint.Recalc(pStart : TJoint);
var
   xDiff,yDiff : integer;
   dAngle, dRads, cx,cy : double;
   pJoint : TJoint;
   f : integer;
begin
   if (pStart = nil) then exit;

   for f := 0 to pStart.m_olChildren.Count-1 do
   begin
      pJoint := TJoint(pStart.m_olChildren.Items[f]);
      xDiff := pStart.X - pJoint.X;
      yDiff := pStart.Y - pJoint.Y;
      dAngle := 180 * (1 + ArcTan2(yDiff, xDiff) / PI);
      if ( (pJoint.State = C_STATE_ADJUST_TO_PARENT) or (pJoint.State = C_STATE_ADJUST_TO_PARENT_LOCKED) ) then
      begin
         if (pStart.Parent <> nil) then
         begin
            xDiff := pStart.Parent.X - pStart.X;
            yDiff := pStart.Parent.Y - pStart.Y;
            dAngle := 180 * (1 + ArcTan2(yDiff, xDiff) / PI);
            dAngle := (dAngle - pJoint.AngleToParent);
         end;
      end else
      begin
         if (pStart.Parent <> nil) then
         begin
            xDiff := pStart.Parent.X - pStart.X;
            yDiff := pStart.Parent.Y - pStart.Y;
            pJoint.AngleToParent := (180 * (1 + ArcTan2(yDiff, xDiff) / PI)) - dAngle;
         end;
      end;
      dRads := DegToRad(dAngle);
      cx := Round(pJoint.Length * Cos(dRads));
      cy := Round(pJoint.Length * Sin(dRads));
      pJoint.SetPosAbs(round(pStart.X + cx), round(pStart.Y + cy));
      Recalc(pJoint);
   end;
end;

procedure TJoint.SetPos(vx,vy : integer);
var
   f : integer;
   pChild : TJoint;
   xDiff,yDiff : integer;
   dAngle, dRads, cx,cy : double;
   pParent : TJoint;
   pThis : TJoint;
   bContinue : BOOLEAN;
   dParentAngle : double;
begin
   m_nX := vx;
   m_nY := vy;
   pThis := self;
   pParent := m_pParent;
   bContinue := TRUE;
   while (pParent <> nil) do
   begin
      if (pParent.State <> C_STATE_NORMAL) and (pParent.State <> C_STATE_SELECTED) then bContinue := FALSE;
      if (bContinue) then
      begin
         xDiff := pThis.X - pParent.X;
         yDiff := pThis.Y - pParent.Y;
         dAngle := 180 * (1 + ArcTan2(yDiff, xDiff) / PI);
         dRads := DegToRad(dAngle);
         cx := Round(pThis.Length * Cos(dRads));
         cy := Round(pThis.Length * Sin(dRads));
         pParent.SetPosAbs(round(pThis.X + cx), round(pThis.Y + cy));
         if (pParent.Parent <> nil) then
         begin
            xDiff := pParent.X - pParent.Parent.X;
            yDiff := pParent.Y - pParent.Parent.Y;
            dParentAngle := 180 * (1 + ArcTan2(yDiff, xDiff) / PI);
            pThis.AngleToParent := 360 - (dAngle - dParentAngle);
         end;
      end;
      pThis := pParent;
      pParent := pParent.Parent;
   end;

   Recalc(pThis);
end;

function TJoint.AddChild(vx,vy : integer) : TJoint;
var
   pJoint : TJoint;
   xDiff, yDiff : integer;
   dAngle1, dAngle2 : double;
begin
   pJoint := TJoint.Create;
   pJoint.SetPos(vx,vy);
   pJoint.Parent := self;
   xDiff := pJoint.X - m_nX;
   yDiff := pJoint.Y - m_nY;
   pJoint.Length := round( sqrt( (xDiff*xDiff) + (yDiff*yDiff)  ));

   pJoint.AngleToParent := 360;
   if (m_pParent <> nil) then
   begin
      dAngle1 := 180 * (1 + ArcTan2(yDiff, xDiff) / PI);
      xDiff := m_nX - m_pParent.X;
      yDiff := m_nY - m_pParent.Y;
      dAngle2 := 180 * (1 + ArcTan2(yDiff, xDiff) / PI);
      pJoint.AngleToParent := (dAngle2 - dAngle1);
   end;

   m_olChildren.Add(pJoint);
   AddChild := pJoint;
end;

function TJoint.GetFirstChild : boolean;
begin
   m_nIndex := 0;
   GetFirstChild := false;
   if (m_olChildren.Count <> 0) then GetFirstChild := TRUE;
end;

function TJoint.GetNextChild(var pJoint : TJoint) : boolean;
begin
   GetNextChild := FALSE;
   if (m_nIndex = m_olChildren.Count) then exit;
   pJoint := TJoint(m_olChildren.Items[m_nIndex]);
   m_nIndex := m_nIndex + 1;
   GetNextChild := TRUE;
end;

function TJoint.GetJointAt(vx,vy, nAllowance : integer) : TJoint;
var
   f : integer;
   pChild : TJoint;
begin
   GetJointAt := nil;
   if ( (State <> C_STATE_ADJUST_TO_PARENT_LOCKED) and ( X >= (vx-nAllowance) ) and ( Y >= (vy-nAllowance) ) and ( X <= (vx+nAllowance) ) and ( Y <= (vy+nAllowance) ) ) then
   begin
      GetJointAt := self;
      exit;
   end;
   for f := 0 to m_olChildren.Count-1 do
   begin
      pChild := TJoint(m_olChildren.Items[f]);
      if ( (State <> C_STATE_ADJUST_TO_PARENT_LOCKED) and ( pChild.X >= (vx-nAllowance) ) and ( pChild.Y >= (vy-nAllowance) ) and ( pChild.X <= (vx+nAllowance) ) and ( pChild.Y <= (vy+nAllowance) ) ) then
      begin
         GetJointAt := pChild;
         exit;
      end;
      pChild := pChild.GetJointAt(vx,vy,nAllowance);
      if (pChild <> nil) then
      begin
         GetJointAt := pChild;
         exit;
      end;
   end;
end;

function TJoint.Read(var pFile : TFileStream) : boolean;
var
   f : integer;
   pChild : TJoint;
   nCount : integer;
begin
   Read := FALSE;
   //Clear();
   //MUST STILL SAVE AND LOAD NAME OF JOINT
   pFile.Read(m_nDrawAs, sizeof(m_nDrawAs));
   pFile.Read(m_nDrawWidth, sizeof(m_nDrawWidth));
   pFile.Read(m_nLineWidth, sizeof(m_nLineWidth));
   pFile.Read(m_bShowLine, sizeof(m_bShowLine));
   pFile.Read(m_nColour, sizeof(m_nColour));
   pFile.Read(m_nInColour, sizeof(m_nInColour));
   pFile.Read(m_bFill, sizeof(m_bFill));
   pFile.Read(m_nX, sizeof(m_nX));
   pFile.Read(m_nY, sizeof(m_nY));
   pFile.Read(m_nState, sizeof(m_nState));
   pFile.Read(m_nLength, sizeof(m_nLength));
   pFile.Read(m_nIndex, sizeof(m_nIndex));
   pFile.Read(m_sAngleToParent, sizeof(m_sAngleToParent));
   pFile.Read(m_nBitmap, sizeof(m_nBitmap));
   pFile.Read(m_nBMPXoffs, sizeof(m_nBMPXoffs));
   pFile.Read(m_nBMPYoffs, sizeof(m_nBMPYoffs));
   pFile.Read(m_sBitmapRotation, sizeof(m_sBitmapRotation));
   pFile.Read(m_nBitmapAlpha, sizeof(m_nBitmapAlpha));
   pFile.Read(nCount, sizeof(nCount));
   for f := 0 to nCount-1 do
   begin
      pChild := TJoint.Create;
      m_olChildren.Add(pChild);
      pChild.m_pParent := self;
      pChild.Read(pFile);
   end;
   Read := TRUE;
end;

function TJoint.Write(var pFile : TFileStream) : boolean;
var
   f : integer;
   pChild : TJoint;
   count : integer;
begin
   Write := FALSE;
   pFile.Write(m_nDrawAs, sizeof(m_nDrawAs));
   pFile.Write(m_nDrawWidth, sizeof(m_nDrawWidth));
   pFile.Write(m_nLineWidth, sizeof(m_nLineWidth));
   pFile.Write(m_bShowLine, sizeof(m_bShowLine));
   pFile.Write(m_nColour, sizeof(m_nColour));
   pFile.Write(m_nInColour, sizeof(m_nInColour));
   pFile.Write(m_bFill, sizeof(m_bFill));
   pFile.Write(m_nX, sizeof(m_nX));
   pFile.Write(m_nY, sizeof(m_nY));
   pFile.Write(m_nState, sizeof(m_nState));
   pFile.Write(m_nLength, sizeof(m_nLength));
   pFile.Write(m_nIndex, sizeof(m_nIndex));
   pFile.Write(m_sAngleToParent, sizeof(m_sAngleToParent));
   pFile.Write(m_nBitmap, sizeof(m_nBitmap));
   pFile.Write(m_nBMPXoffs, sizeof(m_nBMPXoffs));
   pFile.Write(m_nBMPYoffs, sizeof(m_nBMPYoffs));
   pFile.Write(m_sBitmapRotation, sizeof(m_sBitmapRotation));
   pFile.Write(m_nBitmapAlpha, sizeof(m_nBitmapAlpha));
   count := m_olChildren.Count;
   pFile.Write(count, sizeof(count));
   for f := 0 to count-1 do
   begin
      pChild := TJoint(m_olChildren.Items[f]);
      pChild.Write(pFile);
   end;
   Write := TRUE;
end;

procedure TJoint.CopyFrom(pSource : TJoint);
var
   f : integer;
   pChild : TJoint;
   nCount : integer;
   pCopy : TJoint;
begin
   Clear();
   //MUST STILL SAVE AND LOAD NAME OF JOINT
   m_pData := pSource.m_pData;
   m_nDrawAs := pSource.m_nDrawAs;
   m_nDrawWidth := pSource.m_nDrawWidth;
   m_nLineWidth := pSource.m_nLineWidth;
   m_nColour := pSource.m_nColour;
   m_nInColour := pSource.m_nInColour;
   m_bFill := pSource.m_bFill;
   m_nX := pSource.m_nX;
   m_nY := pSource.m_nY;
   m_nState := pSource.m_nState;
   m_nLength := pSource.m_nLength;
   m_nIndex := pSource.m_nIndex;
   m_sAngleToParent := pSource.m_sAngleToParent;
   m_nBMPXoffs := pSource.m_nBMPXoffs;
   m_nBMPYoffs := pSource.m_nBMPYoffs;
   m_nBitmap := pSource.m_nBitmap;
   m_bShowLine := pSource.m_bShowLine;
   m_sBitmapRotation := pSource.m_sBitmapRotation;
   m_nBitmapAlpha := pSource.m_nBitmapAlpha;
   for f := 0 to pSource.m_olChildren.Count-1 do
   begin
      pChild := TJoint.Create;
      m_olChildren.Add(pChild);
      pCopy := TJoint(pSource.m_olChildren.Items[f]);
      pChild.CopyFrom(pCopy);
      pChild.m_pParent := self;
   end;
end;

procedure TJoint.CopyPropsFrom(pSource : TJoint);
var
   f : integer;
   pChild : TJoint;
   nCount : integer;
   pCopy : TJoint;
begin
   //MUST STILL SAVE AND LOAD NAME OF JOINT
   m_pData := pSource.m_pData;
   m_nDrawAs := pSource.m_nDrawAs;
   m_nDrawWidth := pSource.m_nDrawWidth;
   m_nLineWidth := pSource.m_nLineWidth;
   m_nColour := pSource.m_nColour;
   m_nInColour := pSource.m_nInColour;
   m_bFill := pSource.m_bFill;
   m_nX := pSource.m_nX;
   m_nY := pSource.m_nY;
   m_nState := pSource.m_nState;
   m_nLength := pSource.m_nLength;
   m_nIndex := pSource.m_nIndex;
   m_sAngleToParent := pSource.m_sAngleToParent;
   m_nBMPXoffs := pSource.m_nBMPXoffs;
   m_nBMPYoffs := pSource.m_nBMPYoffs;
   m_sBitmapRotation := pSource.m_sBitmapRotation;
   m_nBitmap := pSource.m_nBitmap;
   m_bShowLine := pSource.m_bShowLine;
   m_nBitmapAlpha := pSource.m_nBitmapAlpha;
   for f := 0 to pSource.m_olChildren.Count-1 do
   begin
      pChild := TJoint(m_olChildren.Items[f]);
      pChild.CopyPropsFrom(TJoint(pSource.m_olChildren.Items[f]));
   end;
end;

procedure TJoint.Tween(pStart, pEnd : TJoint; sPercent : single);
var
   f : integer;
   pNew : TJoint;
   r,g,b : array[1..3] of byte;
begin
   Clear();

   m_pData := pStart.m_pData;
   m_nState := pStart.m_nState;
   m_nColour := pStart.m_nColour;
   m_nInColour := pStart.m_nInColour;
   m_bFill := pStart.m_bFill;
   m_nIndex := pStart.m_nIndex;
   m_sAngleToParent := pStart.m_sAngleToParent;
   m_nBMPXoffs := round(pStart.m_nBMPXoffs + (( pEnd.m_nBMPXoffs - pStart.m_nBMPXoffs ) * sPercent));
   m_nBMPYoffs := round(pStart.m_nBMPYoffs + (( pEnd.m_nBMPYoffs - pStart.m_nBMPYoffs ) * sPercent));
   m_sBitmapRotation := pStart.m_sBitmapRotation + (( pEnd.m_sBitmapRotation - pStart.m_sBitmapRotation ) * sPercent);
   m_sBitmapRotation := pStart.m_sBitmapRotation + (( pEnd.m_sBitmapRotation - pStart.m_sBitmapRotation ) * sPercent);
   m_nBitmapAlpha := round(pStart.m_nBitmapAlpha + (( pEnd.m_nBitmapAlpha - pStart.m_nBitmapAlpha ) * sPercent));
   m_bShowLine := pStart.m_bShowLine;
   m_nDrawAs := pStart.m_nDrawAs;
   m_nDrawWidth := round(pStart.m_nDrawWidth + (( pEnd.m_nDrawWidth - pStart.m_nDrawWidth ) * sPercent));
   m_nBitmap := pStart.m_nBitmap;

   m_nX := round(pStart.m_nX + (( pEnd.m_nX - pStart.m_nX ) * sPercent));
   m_nY := round(pStart.m_nY + (( pEnd.m_nY - pStart.m_nY ) * sPercent));
   m_nLength := round(pStart.m_nLength + (( pEnd.m_nLength - pStart.m_nLength ) * sPercent));
   m_nLineWidth := round(pStart.m_nLineWidth + (( pEnd.m_nLineWidth - pStart.m_nLineWidth ) * sPercent));

   DWORDtoRGB(pStart.m_nColour, r[1],g[1],b[1]);
   DWORDtoRGB(pEnd.m_nColour, r[2],g[2],b[2]);
   r[3] := r[1]+round(sPercent * (r[2]-r[1]));
   g[3] := g[1]+round(sPercent * (g[2]-g[1]));
   b[3] := b[1]+round(sPercent * (b[2]-b[1]));
   RGBtoDWORD(r[3],g[3],b[3], m_nColour);

   DWORDtoRGB(pStart.m_nInColour, r[1],g[1],b[1]);
   DWORDtoRGB(pEnd.m_nInColour, r[2],g[2],b[2]);
   r[3] := r[1]+round(sPercent * (r[2]-r[1]));
   g[3] := g[1]+round(sPercent * (g[2]-g[1]));
   b[3] := b[1]+round(sPercent * (b[2]-b[1]));
   RGBtoDWORD(r[3],g[3],b[3], m_nInColour);

   for f := 0 to pStart.m_olChildren.Count-1 do
   begin
      pNew := TJoint.Create;
      m_olChildren.Add(pNew);
      pNew.Tween(TJoint(pStart.m_olChildren.Items[f]), TJoint(pEnd.m_olChildren.Items[f]), sPercent);
   end;
end;

procedure TJoint.GetExtent(var left, top, right, bottom : integer);
var
   f : integer;
   pChild : TJoint;
begin
   if X < left then left := X;
   if Y < top then top := Y;
   if X > right then right := X;
   if Y > bottom then bottom := Y;

   for f := 0 to m_olChildren.Count-1 do
   begin
      pChild := TJoint(m_olChildren.Items[f]);
      pChild.GetExtent(left,top,right,bottom);
   end;
end;

procedure TJoint.Scale(sPercent : single);
var
   f : integer;
   pChild : TJoint;
   nCount : integer;
begin
   //MUST STILL SAVE AND LOAD NAME OF JOINT
   m_nDrawWidth := round(m_nDrawWidth * sPercent);
   m_nLineWidth := round(m_nLineWidth * sPercent);
   m_nX := round(m_nX * sPercent);
   m_nY := round(m_nY * sPercent);
   m_nLength := round(m_nLength * sPercent);
   for f := 0 to m_olChildren.Count-1 do
   begin
      pChild := TJoint(m_olChildren.Items[f]);
      pChild.Scale(sPercent);
   end;
end;

end.


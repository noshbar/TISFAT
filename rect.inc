function TSquareObj.Pnt(nIndex : integer) : TLabel2Ptr;
begin
   Pnt := TLabel2Ptr(PntList.Items[nIndex-1]);
end;

constructor TSquareObj.Create(AOwner : TWinControl);
var
   f : integer;
   pPnt : TLabel2Ptr;
begin
   PntList := TList.Create;
   for f := 1 to 4 do
   begin
     new(pPnt);
     pPnt^ := TLabel2.Create();
     pPnt^.Left := 0;
     pPnt^.Top := 0;
     pPnt^.Tag := f;
     pPnt^.Color := clRed;
     pPnt^.m_pUpdate := Update;
     PntList.Add(pPnt);
   end;
   m_styleInner := bsSolid;
   m_styleOuter := psSolid;
   Pnt(1)^.Color := clRed;
   Pnt(1)^.Left := 0;
   Pnt(1)^.Top := 0;
   Pnt(2)^.Color := clBlue;
   Pnt(2)^.Left := 50;
   Pnt(2)^.Top := 0;
   Pnt(3)^.Color := clYellow;
   Pnt(3)^.Left := 50;
   Pnt(3)^.Top := 50;
   Pnt(4)^.Color := clGreen;
   Pnt(4)^.Left := 0;
   Pnt(4)^.Top := 50;
   m_InColour := clBlue;
   m_OutColour := clBlack;
   m_nLineWidth := 2;
   m_alpha := 255;
   m_angle := 0;
   m_aliased := 1;
end;

destructor TSquareObj.Destroy;
var
   f : integer;
   pPnt : TLabel2Ptr;
begin
   for f := 0 to PntList.Count-1 do
   begin
      pPnt := PntList.Items[f];
      pPnt^.Free;
      dispose(pPnt);
   end;
   PntList.Destroy;
end;

procedure TSquareObj.Assign(source : TSquareObjPtr);
var
   f : integer;
begin
   for f := 1 to 4 do
   begin
      Pnt(f)^.Left := source^.Pnt(f)^.Left;
      Pnt(f)^.Top := source^.Pnt(f)^.Top;
   end;
   m_nLineWidth := source^.m_nLineWidth;
   m_InColour := source^.m_InColour;
   m_OutColour := source^.m_OutColour;
   m_styleInner := source^.m_styleInner;
   m_styleOuter := source^.m_styleOuter;
   m_body := source^.m_body;
   m_angle := source^.m_angle;
   m_alpha := source^.m_alpha;
end;

procedure TSquareObj.Update(nIndex : integer);
begin
   SetPoint(Pnt(nIndex)^.Left, Pnt(nIndex)^.Top, Pnt(nIndex)^.Tag);
end;

procedure TSquareObj.SetPoint(x, y, nIndex : integer);
begin
   Pnt(nIndex)^.Left := x;
   Pnt(nIndex)^.Top := y;
   if (nIndex = 1) then
   begin
      Pnt(2)^.top := Pnt(1)^.top;
      Pnt(4)^.Left := Pnt(1)^.Left;
   end;
   if (nIndex = 2) then
   begin
      Pnt(1)^.top := Pnt(2)^.top;
      Pnt(3)^.Left := Pnt(2)^.Left;
   end;
   if (nIndex = 3) then
   begin
      Pnt(4)^.top := Pnt(3)^.top;
      Pnt(2)^.Left := Pnt(3)^.Left;
   end;
   if (nIndex = 4) then
   begin
      Pnt(3)^.top := Pnt(4)^.top;
      Pnt(1)^.Left := Pnt(4)^.Left;
   end;
   frmMain.Render(frmMain.m_col, TRUE);
end;

procedure TSquareObj.Move(xAmount, yAmount : integer);
var
   f : integer;
begin
   for f := 1 to 4 do
   begin
      Pnt(f)^.Left := Pnt(f)^.Left + xAmount;
      Pnt(f)^.top := Pnt(f)^.top + yAmount;
   end;
end;

procedure TSquareObj.Rotate(amount : single);
begin
   m_angle := m_angle + amount;
end;

procedure TSquareObj.Alpha(amount : single);
var
   a : integer;
begin
   a := round(m_alpha + amount);
   if (a < 0) then
      a := 0;
   if (a > 255) then
      a := 255;
   m_alpha := a;
end;

procedure TSquareObj.Tween(pSource, pDest : TSquareObjPtr; nCurrentFrame, nTotalFrames : integer);
var
   f : integer;
   ink : double;
   r,g,b : array[1..3] of byte;
begin
    for f := 1 to 4 do
    begin
          ink := nCurrentFrame * ((pDest^.Pnt(f)^.left - pSource^.Pnt(f)^.left) / nTotalFrames);
          Pnt(f)^.left := round(pSource^.Pnt(f)^.left + ink);
          ink := nCurrentFrame * ((pDest^.Pnt(f)^.top - pSource^.Pnt(f)^.top) / nTotalFrames);
          Pnt(f)^.top := round(pSource^.Pnt(f)^.top + ink);
    end;
   //angle
   ink := nCurrentFrame * ((pDest^.m_angle - pSource^.m_angle) / nTotalFrames);
   m_angle := (pSource^.m_angle + ink);
   //angle/
   //alpha
   ink := nCurrentFrame * ((pDest^.m_alpha - pSource^.m_alpha) / nTotalFrames);
   m_alpha := round(pSource^.m_alpha + ink);
   //alpha/
   ink := nCurrentFrame * ((pDest^.m_nLineWidth - pSource^.m_nLineWidth) / nTotalFrames);
   m_nLineWidth := round(pSource^.m_nLineWidth + ink);

   DWORDtoRGB(pSource^.m_InColour, r[1],g[1],b[1]);
   DWORDtoRGB(pDest^.m_InColour, r[2],g[2],b[2]);
   r[3] := r[1]+round(nCurrentFrame * (r[2] - r[1]) / nTotalFrames);
   g[3] := g[1]+round(nCurrentFrame * (g[2] - g[1]) / nTotalFrames);
   b[3] := b[1]+round(nCurrentFrame * (b[2] - b[1]) / nTotalFrames);
   m_InColour := rgb(r[3],g[3],b[3]);

   DWORDtoRGB(pSource^.m_OutColour, r[1],g[1],b[1]);
   DWORDtoRGB(pDest^.m_OutColour, r[2],g[2],b[2]);
   r[3] := r[1]+round(nCurrentFrame * (r[2] - r[1]) / nTotalFrames);
   g[3] := g[1]+round(nCurrentFrame * (g[2] - g[1]) / nTotalFrames);
   b[3] := b[1]+round(nCurrentFrame * (b[2] - b[1]) / nTotalFrames);
   m_OutColour := rgb(r[3],g[3],b[3]);

   m_styleInner := pSource^.m_styleInner;
   m_styleOuter := pSource^.m_styleOuter;
end;

procedure TSquareObj.Draw(xoffs,yoffs : integer; DrawControlPoints : boolean);
var
   r,g,b,fr,fg,fb : byte;
   x,y,wide,high : integer;
begin
   b := m_outColour shr 16;
   g := m_outColour shr 8;
   r := m_outColour;
   fb := m_InColour shr 16;
   fg := m_InColour shr 8;
   fr := m_InColour;

   wide := (xoffs+Pnt(3)^.Left+3)-(xoffs+Pnt(1)^.Left+3);
   high := (yoffs+Pnt(3)^.top+3)-(yoffs+Pnt(1)^.top+3);
   x := round((xoffs+Pnt(1)^.Left+3) + (wide / 2));
   y := round((yoffs+Pnt(1)^.Top+3) + (high / 2));

   if (m_styleInner = bsSolid) and (m_styleOuter = psSolid) then
   begin
      frmMain.DrawRect( x,y, wide, high, r,g,b, fr,fg,fb, m_alpha, m_nLineWidth, m_angle);
   end else
   if (m_styleInner = bsClear) then
   begin
      frmMain.DrawRectOutLine( x,y, wide, high, m_outColour, m_alpha, m_nLineWidth, m_angle)
   end else
   if (m_styleOuter = psClear) then
   begin
      frmMain.DrawRect( x,y, wide, high, fr,fg,fb, fr,fg,fb, m_alpha, 0, m_angle);
   end;

   {if (m_styleInner = bsClear) then
      frmMain.DrawRectOutLine( x,y, wide, high, m_outColour, m_alpha, m_nLineWidth, m_angle)
   else
      frmMain.DrawRect( x,y, wide, high, r,g,b, fr,fg,fb, m_alpha, m_nLineWidth, m_angle);}

end;

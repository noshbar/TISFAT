function TBitman.Pnt(nIndex : integer) : TLabel2Ptr;
begin
   Pnt := TLabel2Ptr(PntList.Items[nIndex-1]);
end;

constructor TBitman.Create(AOwner : TWinControl; strFileName : string; wide,high : integer);
var
   f : integer;
   pPnt : TLabel2Ptr;
begin
   PntList := TList.Create;
   m_bLoadNew := TRUE;
   m_strFileName := strFileName;
   ms := nil;

   if (strFileNAme <> '') then
   begin
      Imarge := TGPBitmap.Create(strFileName);
      wide := Imarge.GetWidth;
      high := Imarge.GetHeight;
   end;

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
   Pnt(1)^.Color := clRed;
   Pnt(1)^.Left := -3;
   Pnt(1)^.Top := -3;
   Pnt(2)^.Color := clBlue;
   Pnt(2)^.Left := wide-3;
   Pnt(2)^.Top := -3;
   Pnt(3)^.Color := clYellow;
   Pnt(3)^.Left := wide-3;
   Pnt(3)^.Top := high-3;
   Pnt(4)^.Color := clGreen;
   Pnt(4)^.Left := -3;
   Pnt(4)^.Top := high-3;

   m_alpha := 255;
   m_angle := 0;
   m_aliased := 1;
end;

destructor TBitman.Destroy;
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
   Imarge.Free;
   Imarge := nil;
   ms.Free;
   ms := nil;
end;

procedure TBitman.Assign(source : TBitManPtr);
var
   f : integer;
begin
   for f := 1 to 4 do
   begin
      Pnt(f)^.Left := source^.Pnt(f)^.Left;
      Pnt(f)^.Top := source^.Pnt(f)^.Top;
   end;
   m_body := source^.m_body;
   m_angle := source^.m_angle;
   m_alpha := source^.m_alpha;
end;

procedure TBitman.Update(nIndex : integer);
begin
   SetPoint(Pnt(nIndex)^.Left, Pnt(nIndex)^.Top, Pnt(nIndex)^.Tag);
end;

procedure TBitman.SetPoint(x, y, nIndex : integer);
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
   frmMain.Render(frmMain.m_col);
end;

procedure TBitman.Move(xAmount, yAmount : integer);
var
   f : integer;
begin
   for f := 1 to 4 do
   begin
      Pnt(f)^.Left := Pnt(f)^.Left + xAmount;
      Pnt(f)^.top := Pnt(f)^.top + yAmount;
   end;
end;

procedure TBitman.Rotate(amount : single);
begin
   m_angle := m_angle + amount;
end;

procedure TBitman.Alpha(amount : single);
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

procedure TBitman.Draw(xoffs,yoffs : integer; alpha : byte; DrawControlPoints : boolean);
begin
   if (Imarge <> nil) then
   begin
      frmMain.DrawImage(Imarge,
         xoffs+Pnt(1)^.Left,yoffs+Pnt(1)^.Top,xoffs+Pnt(3)^.Left,yoffs+Pnt(3)^.Top, alpha, m_angle);
   end;
end;

procedure TBitman.Tween(pSource, pDest : TBitmanPtr; nCurrentFrame, nTotalFrames : integer);
var
   f : integer;
   ink : double;
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
end;


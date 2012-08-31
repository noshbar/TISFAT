function TEditVideoObj.Pnt(nIndex : integer) : TLabel2Ptr;
begin
   Pnt := TLabel2Ptr(PntList.Items[nIndex-1]);
end;

constructor TEditVideoObj.Create(AOwner : TWinControl);
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
end;

destructor TEditVideoObj.Destroy;
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

procedure TEditVideoObj.Update(nIndex : integer);
begin
   SetPoint(Pnt(nIndex)^.Left, Pnt(nIndex)^.Top, Pnt(nIndex)^.Tag);
end;

procedure TEditVideoObj.SetPoint(x, y, nIndex : integer);
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
   //d/frmMain.frmCanvas.aviPlaya.Width := (Pnt(3)^.Left - Pnt(1)^.Left);
   //d/frmMain.frmCanvas.aviPlaya.Height := (Pnt(3)^.Top - Pnt(1)^.Top);
   frmMain.Render(frmMain.m_col, TRUE);
end;

procedure TEditVideoObj.Move(xAmount, yAmount : integer);
var
   f : integer;
begin
   for f := 1 to 4 do
   begin
      Pnt(f)^.Left := Pnt(f)^.Left + xAmount;
      Pnt(f)^.top := Pnt(f)^.top + yAmount;
   end;
end;

procedure TEditVideoObj.Draw(xoffs,yoffs : integer);
begin
//   frmMain.frmCanvas.aviPlaya.PaintTo(frmMain.m_Canvas, xoffs+Pnt(1)^.Left+3,yoffs+Pnt(1)^.Top+3);
end;

procedure TEditVideoObj.Assign(source : TEditVideoObjPtr);
var
   f : integer;
begin
   for f := 1 to 4 do
   begin
      Pnt(f)^.Left := source^.Pnt(f)^.Left;
      Pnt(f)^.Top := source^.Pnt(f)^.Top;
   end;
end;

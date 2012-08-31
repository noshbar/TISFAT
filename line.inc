function TLineObj.Pnt(nIndex : integer) : TLabel2Ptr;
begin
   Pnt := TLabel2Ptr(PntList.Items[nIndex-1]);
end;

constructor TLineObj.Create(AOwner : TWinControl);
var
   f : integer;
   pPnt : TLabel2Ptr;
begin
   PntList := TList.Create;
   for f := 1 to 2 do
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
   m_Colour := clBlack;
   m_nLineWidth := 2;
   m_alpha := 255;
   m_angle := 0;
   m_aliased := 1;
end;

destructor TLineObj.Destroy;
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

procedure TLineObj.Assign(source : TLineObjPtr);
var
   f : integer;
begin
   for f := 1 to 2 do
   begin
      Pnt(f)^.left := source^.Pnt(f)^.left;
      Pnt(f)^.top := source^.Pnt(f)^.top;
   end;
   m_nLineWidth := source^.m_nLineWidth;
   m_Colour := source^.m_Colour;
   m_body := source^.m_body;
   m_angle := source^.m_angle;
   m_alpha := source^.m_alpha;
end;

procedure TLineObj.Update(nIndex : integer);
begin
   SetPoint(Pnt(nIndex)^.Left, Pnt(nIndex)^.Top, Pnt(nIndex)^.Tag);
end;

procedure TLineObj.SetPoint(x, y, nIndex : integer);
begin
   Pnt(nIndex)^.left := x;
   Pnt(nIndex)^.top := y;
   frmMain.Render(frmMain.m_col, TRUE);
end;

procedure TLineObj.Move(xAmount, yAmount : integer);
var
   f : integer;
begin
   for f := 1 to 2 do
   begin
      Pnt(f)^.left := Pnt(f)^.left + xAmount;
      Pnt(f)^.top := Pnt(f)^.top + yAmount;
   end;
end;

procedure TLineObj.Alpha(amount : single);
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

procedure TLineObj.Draw(xoffs,yoffs : integer; DrawControlPoints : boolean);
var
   r,g,b : byte;
   x,y,wide,high : integer;
begin
   b := m_Colour shr 16;
   g := m_Colour shr 8;
   r := m_Colour;

   wide := (xoffs+Pnt(2)^.Left+3)-(xoffs+Pnt(1)^.Left+3);
   high := (yoffs+Pnt(2)^.top+3)-(yoffs+Pnt(1)^.top+3);
   x := xoffs+Pnt(1)^.Left+3;
   y := yoffs+Pnt(1)^.Top+3;

    frmMain.DrawLine(x,y, wide,high, r,g,b, m_alpha, m_nLineWidth, 0);

end;

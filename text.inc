function TTextObj.Pnt(nIndex : integer) : TLabel2Ptr;
begin
   Pnt := TLabel2Ptr(PntList.Items[nIndex-1]);
end;

constructor TTextObj.Create(AOwner : TWinControl; strCaption : string);
var
   f : integer;
   pPnt : TLabel2Ptr;
begin
   PntList := TList.Create;
   m_strCaption := strCaption;
   m_strFontName := 'Arial';
   m_InColour := clBlack;
   m_OutColour := clWhite;
   m_styleOuter := bsClear;
   m_FontStyle := [];
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
   m_InColour := clBlue;
   m_OutColour := clBlack;
   m_alpha := 255;
   m_angle := 0;
   m_aliased := 1;
end;

destructor TTextObj.Destroy;
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

procedure TTextObj.Assign(source : TTextObjPtr);
var
   f : integer;
begin
   for f := 1 to 4 do
   begin
      Pnt(f)^.Left := source^.Pnt(f)^.Left;
      Pnt(f)^.Top := source^.Pnt(f)^.Top;
   end;
   m_strCaption := source^.m_strCaption;
   m_InColour := source^.m_InColour;
   m_OutColour := source^.m_OutColour;
   m_strFontName := source^.m_strFontName;
   m_styleOuter := source^.m_styleOuter;
   m_FontStyle := source^.m_FontStyle;
   m_body := source^.m_body;
   m_angle := source^.m_angle;
   m_alpha := source^.m_alpha;
end;

procedure TTextObj.Update(nIndex : integer);
begin
   SetPoint(Pnt(nIndex)^.Left, Pnt(nIndex)^.Top, Pnt(nIndex)^.Tag);
end;

procedure TTextObj.SetPoint(x, y, nIndex : integer);
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

procedure TTextObj.Move(xAmount, yAmount : integer);
var
   f : integer;
begin
   for f := 1 to 4 do
   begin
      Pnt(f)^.Left := Pnt(f)^.Left + xAmount;
      Pnt(f)^.top := Pnt(f)^.top + yAmount;
   end;
end;

procedure TTextObj.Rotate(amount : single);
begin
   m_angle := m_angle + amount;
end;

procedure TTextObj.Alpha(amount : single);
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

procedure TTextObj.Draw(xoffs,yoffs : integer; DrawControlPoints : boolean);
var
   high,x,y : integer;
begin

   high := (yoffs+Pnt(3)^.top+3)-(yoffs+Pnt(1)^.top+3);
   x := (xoffs+Pnt(1)^.Left+3);
   y := (yoffs+Pnt(1)^.Top+3);

   frmMain.DrawText(x,y,
                    m_strCaption,
                    m_strFontName,
                    high,
                    m_inColour,
                    m_alpha,
                    m_angle);

end;

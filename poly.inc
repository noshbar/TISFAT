function TPolyObj.Pnt(nIndex : integer) : TLabel2Ptr;
begin
   Pnt := TLabel2Ptr(PntList.Items[nIndex-1]);
end;

constructor TPolyObj.Create(AOwner : TWinControl; VerticeCount : integer);
var
   f : integer;
   pPnt : TLabel2Ptr;
   Rads : extended;
   nMax : integer;
begin
   PntList := TList.Create;
   nMax := frmMain.frmCanvas.ClientHeight;
   if (frmMain.frmCanvas.ClientWidth < nMax) then nMax := frmMain.frmCanvas.ClientWidth;
   nMax := (nMax div 2) - 10;
   for f := 1 to VerticeCount do
   begin
      new(pPnt);
      pPnt^ := TLabel2.Create();
      With pPnt^ do
      begin
         Left := (frmMain.frmCanvas.ClientWidth div 2);
         Top := (frmMain.frmCanvas.ClientWidth div 2);
         Rads := degtorad(((360 / VerticeCount) * f));
         Left := round(Left + (nMax * Cos(Rads)));
         Top := round(Top + (nMax * Sin(Rads)));
      end;
      pPnt^.Tag := f;
      pPnt^.Color := clRed;
      PntList.Add(pPnt);
   end;
   m_styleInner := bsSolid;
   m_styleOuter := psSolid;
   m_InColour := clBlue;
   m_OutColour := clBlack;
   m_nLineWidth := 2;
   m_alpha := 255;
   m_angle := 0;
   m_aliased := 1;
end;

destructor TPolyObj.Destroy;
var
   f : integer;
   pPnt : TLabel2Ptr;
begin
   for f := 0 to PntList.Count-1 do
   begin
      pPnt := PntList.Items[f];
      pPnt^.Destroy;
      dispose(pPnt);
   end;
   PntList.Destroy;
end;

procedure TPolyObj.Assign(source : TPolyObjPtr);
var
   f : integer;
begin
   for f := 0 to PntList.Count-1 do
   begin
      TLabel2Ptr(PntList.Items[f])^.Left := TLabel2Ptr(source^.PntList.Items[f])^.Left;
      TLabel2Ptr(PntList.Items[f])^.Top := TLabel2Ptr(source^.PntList.Items[f])^.Top;
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

procedure TPolyObj.Update(nIndex : integer);
begin
   SetPoint(Pnt(nIndex)^.Left, Pnt(nIndex)^.Top, Pnt(nIndex)^.Tag);
end;

procedure TPolyObj.Move(xAmount, yAmount : integer);
var
   f : integer;
begin
   for f := 1 to PntList.Count do
   begin
      Pnt(f)^.Left := Pnt(f)^.Left + xAmount;
      Pnt(f)^.top := Pnt(f)^.top + yAmount;
   end;
end;

procedure TPolyObj.SetPoint(x, y, nIndex : integer);
begin
   Pnt(nIndex)^.Left := x;
   Pnt(nIndex)^.Top := y;
end;

procedure TPolyObj.Alpha(amount : single);
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

procedure TPolyObj.Draw(xoffs,yoffs : integer; DrawControlPoints : boolean);
var
   f : integer;
   pa : array[0..100] of TPoint;
begin
      for f := 0 to PntList.Count-1 do
      begin
         pa[f].x := xoffs+TLabel2Ptr(PntList.Items[f])^.Left+3;
         pa[f].y := yoffs+TLabel2Ptr(PntList.Items[f])^.Top+3;
      end;
      pa[f+1].x := xoffs+TLabel2Ptr(PntList.Items[0])^.Left+3;
      pa[f+1].y := yoffs+TLabel2Ptr(PntList.Items[0])^.Top+3;
      f := m_nLineWidth;
      if (m_styleouter <> psSolid) then
         f := 0;
      frmMain.DrawPoly(PntList, m_outColour, m_inColour, m_alpha, f, m_StyleInner = bsSolid);

end;

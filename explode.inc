function TExplodeObj.Pnt(nIndex : integer) : TLabel2Ptr;
begin
   Pnt := TLabel2Ptr(PntList.Items[nIndex-1]);
end;

constructor TExplodeObj.Create(AOwner : TWinControl; bGen : boolean);
var
   f : integer;
   pParticle : TParticlePtr;
   pPnt : TLabel2Ptr;
begin
   PntList := TList.Create;
   m_bInit := FALSE;
   m_Particles := nil;
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
   if (bGen) then
   begin
     m_Particles := TList.Create;
     for f := 0 to C_MAXPART do
     begin
        new(pParticle);
        m_Particles.Add(pParticle);
     end;
   end;
   Pnt(1)^.Color := clRed;
   Pnt(1)^.Left := 50;
   Pnt(1)^.Top := 50;
   Pnt(2)^.Color := clBlue;
   Pnt(2)^.Left := 0;
   Pnt(2)^.Top := 0;
   m_nMidX := 25;
   m_nMidY := 25;
end;

destructor TExplodeObj.Destroy;
var
   f : integer;
   pParticle : TParticlePtr;
   pPnt : TLabel2Ptr;
begin
   for f := 0 to PntList.Count-1 do
   begin
      pPnt := PntList.Items[f];
      pPnt^.Free;
      dispose(pPnt);
   end;
   PntList.Destroy;
   if (m_Particles <> nil) then
   begin
      for f := 0 to C_MAXPART do
      begin
         pParticle := m_Particles.Items[f];
         Dispose(pParticle);
      end;
      m_Particles.Destroy;
   end;
end;

procedure TExplodeObj.Assign(source : TExplodeObjPtr);
var
   f : integer;
begin
   for f := 1 to 2 do
   begin
      Pnt(f)^.Left := source^.Pnt(f)^.Left;
      Pnt(f)^.Top := source^.Pnt(f)^.Top;
   end;
end;

procedure TExplodeObj.InitParts;
var
   angle : double;
   leng : double;
   h : integer;
   //

   myAngle : real;
   myRad : real;
   q,w : real;
   l : real;
begin

   m_bInit := TRUE;
   if (m_Particles <> nil) then
   begin
       for h := 0 to m_Particles.Count-1 do
       begin
          TParticlePtr(m_Particles.Items[h])^.xinc := 0;
          TParticlePtr(m_Particles.Items[h])^.yinc := 0;
       end;

       angle := 180 * (1 + ArcTan2(Pnt(1)^.Top-Pnt(2)^.Top, Pnt(1)^.Left-Pnt(2)^.Left) / PI);
       if angle >= 360.0 then angle := angle - 360.0;
       angle := angle + 90;
       leng := sqrt( sqr(Pnt(2)^.Left - Pnt(1)^.Left) + sqr(Pnt(2)^.Top - Pnt(1)^.Top) );

       for h := 0 to m_Particles.Count-1 do
       begin
          myAngle := angle - random(45) + random(40);
          myRad := DegToRad(myAngle);
          l := (leng/2) + random(300);
          q := cos(myRad) * l;
          w := sin(myRad) * l;
          TParticlePtr(m_Particles.Items[h])^.xinc := q / leng;
          TParticlePtr(m_Particles.Items[h])^.yinc := w / leng;
       end;

   end;
end;

{procedure TExplodeObj.MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := FALSE;
   InitParts;
end;   }

procedure TExplodeObj.Update(nIndex : integer);
begin
   SetPoint(Pnt(nIndex)^.Left, Pnt(nIndex)^.Top, Pnt(nIndex)^.Tag);
end;

procedure TExplodeObj.SetPoint(x, y, nIndex : integer);
begin
   Pnt(nIndex)^.Left := x;
   Pnt(nIndex)^.Top := y;
   m_nMidX := Pnt(1)^.Left + ((Pnt(2)^.Left - Pnt(1)^.Left) div 2);
   m_nMidY := Pnt(1)^.Top + ((Pnt(2)^.Top - Pnt(1)^.Top) div 2);
   frmMain.Render(frmMain.m_col, TRUE);
end;

procedure TExplodeObj.Move(xAmount, yAmount : integer);
var
   f : integer;
begin
   for f := 1 to 2 do
   begin
      Pnt(f)^.Left := Pnt(f)^.Left + xAmount;
      Pnt(f)^.top := Pnt(f)^.top + yAmount;
   end;
   m_nMidX := m_nMidX + xAmount;
   m_nMidY := m_nMidY + yAmount;
end;

procedure TExplodeObj.Draw(xoffs,yoffs : integer; nIterations, nCurrentFrame : integer; DrawControlPoints : boolean);
var
   pParticle : TParticlePtr;
   f, h : integer;
   x1, y1 : integer;
   fPercent : double;
   iCol : byte;
   nRadius : integer;
   angle, rads : double;
   x,y : double;
begin

   if (m_Particles = nil) then exit;
   fPercent := nCurrentFrame / nIterations;
   h := nCurrentFrame;
   iCol := round(255 * fPercent);
   if (m_bINit) then
   for f := 0 to m_Particles.Count-1 do
   begin
      pParticle := m_Particles.Items[f];
      nRadius := round(6-(5 * fPercent));
      x := m_nMidX + pParticle^.xinc * h;
      y := m_nMidY + pParticle^.yinc * h;
      x1 := trunc(x);
      y1 := trunc(y);

      frmMAin.dRawEllipse(xoffs+x1,yoffs+y1,
                          nRadius,nRadius,
                          rgb(255,0,0),
                          rgb(255,0,0),
                          255-iCol,
                          1,
                          0);
   end;

      if (DrawControlPoints) and (not frmMain.m_bPlaying) then
      begin
         frmMain.DrawLine2(xoffs+Pnt(1)^.Left, yoffs+Pnt(1)^.Top,
                           xoffs+Pnt(2)^.Left, yoffs+Pnt(2)^.Top,
                           clBlack, 255, 1);

          angle := 180 * (1 + ArcTan2(Pnt(1)^.Top-Pnt(2)^.Top, Pnt(1)^.Left-Pnt(2)^.Left) / PI);
          if angle >= 360.0 then angle := angle - 360.0;
          angle := angle + 90;
          Rads := DegToRad(angle);
          angle := (sqrt( sqr(Pnt(2)^.Left-Pnt(1)^.Left) + sqr(Pnt(2)^.Top-Pnt(1)^.Top) ));
          x1 := m_nMidX + Round(angle * Cos(Rads));
          y1 := m_nMidY + Round(angle * Sin(Rads));

         frmMAin.DrawLine2(xoffs+m_nMidX,yoffs+m_nMidY,
                           xoffs+x1,yoffs+y1,
                           clBlack, 255, 1);
      end;
end;

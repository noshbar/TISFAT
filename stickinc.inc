function TStickMan.Pnt(nIndex : integer) : TLabel2Ptr;
begin
   Pnt := TLabel2Ptr(PntList.Items[nIndex-1]);
end;

constructor TStickMan.Create(AOwner : TWinControl; n1,n2,n3,n4,n5,n6,n7,n8,n9 : integer);
var
   f : integer;
   pPnt : TLabel2Ptr;
begin
   PntList := TList.Create;
   m_pCanvas := @frmMain.m_Canvas;
   m_nHeadDiam := 14;
   m_InColour := clRed;
   m_OutColour := clBlack;
   Lng[1] := n1;
   Lng[2] := n2;
   Lng[3] := n3;
   Lng[4] := n4;
   Lng[5] := n5;
   Lng[6] := n6;
   Lng[7] := n7;
   Lng[8] := n8;
   Lng[9] := n9;
   for f := 1 to 10 do
   begin
      Wid[f] := 1;
   end;
   for f := 1 to 10 do
   begin
      new(pPnt);
      pPnt^ := TLabel2.Create();
      pPnt^.Left := 0;
      pPnt^.Top := 0;
      pPnt^.Tag := f;
      pPnt^.Color := clRed;
      pPnt^.m_pUpdate := Update;
      pPnt^.m_bLocked := FALSE;
      PntList.Add(pPnt);
   end;
   Pnt(1)^.Color := clYellow;
   Pnt(2)^.Color := clRed;
   Pnt(3)^.Color := clRed;
   Pnt(4)^.Color := clBlue;
   Pnt(5)^.Color := clBlue;
   Pnt(6)^.Color := clYellow;
   Pnt(7)^.Color := clRed;
   Pnt(8)^.Color := clRed;
   Pnt(9)^.Color := clBlue;
   Pnt(10)^.Color := clBlue;
   m_alpha := 255;
   m_angle := 0;
   m_aliased := 1;
end;

destructor TStickMan.Destroy;
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
      PntList.Free;
end;

procedure TStickMan.Assign(source : TStickManPtr);
var
   f : integer;
begin
   for f := 1 to 9 do
   begin
      Lng[f] := source^.Lng[f];
   end;
   for f := 1 to 10 do
   begin
      Pnt(f)^.Left := source^.Pnt(f)^.Left;
      Pnt(f)^.Top := source^.Pnt(f)^.Top;
      Wid[f] := source^.Wid[f];
   end;
   m_nHeadDiam := source^.m_nHeadDiam;
   m_InColour := source^.m_InColour;
   m_OutColour := source^.m_OutColour;
end;

procedure TStickMan.Update(nIndex : integer);
begin
   SetPoint(Pnt(nIndex)^.Left, Pnt(nIndex)^.Top, Pnt(nIndex)^.Tag, Pnt(nIndex)^.Tag);
end;

procedure TStickMan.UpdatePoint(nIndex1, nIndex2, nIndex3 : integer);
var
   angle : double;
   Rads : double;
   cx, cy : double;
   pPnt : array[1..2] of TLabel2Ptr;
begin
   pPnt[1] := Pnt(nIndex1);
   pPnt[2] := Pnt(nIndex2);
   angle := 180 * (1 + ArcTan2(pPnt[1]^.Top-pPnt[2]^.Top, pPnt[1]^.Left-pPnt[2]^.Left) / PI);
   if angle >= 360.0 then angle := angle - 360.0;
   Rads := DegToRad(angle);
   cx := Round(Lng[nIndex3] * Cos(Rads));
   cy := Round(Lng[nIndex3] * Sin(Rads));
   pPnt[2]^.Left := round(pPnt[1]^.Left+cx);
   pPnt[2]^.Top := round(pPnt[1]^.Top+cy);
end;

procedure TStickMan.SetPoint(x, y, nIndex, nSrcIndex : integer);
var
   angle : double;
   Rads : double;
   cx, cy : double;
   ox,oy : integer;
   bOld : boolean;
begin
   if (not Pnt(nIndex)^.m_bLocked) then
   begin
      Pnt(nIndex)^.Left := x;
      Pnt(nIndex)^.Top := y;
   end;
   if (nIndex = 6) then
   begin
      if (nSrcIndex = 6) or (nSrcIndex = 1) then
      begin
            if Pnt(7)^.m_bLocked = FALSE then UpdatePoint(6,7, 6);
            SetPoint(Pnt(7)^.Left, Pnt(7)^.Top, 7, 6);
            UpdatePoint(7,6, 6);
            if (Pnt(9)^.m_bLocked) = FALSE then UpdatePoint(6,9, 8);
            SetPoint(Pnt(9)^.Left, Pnt(9)^.Top, 9, 6);
            UpdatePoint(9,6, 8);
         if (Pnt(1)^.m_bLocked) then
         begin
            UpdatePoint(1,6,5);
            if not Pnt(7)^.m_bLocked then
            begin
               UpdatePoint(6,7,7);
               UpdatePoint(7,8,7);
            end;
            if not Pnt(9)^.m_bLocked then
            begin
               UpdatePoint(6,9,8);
               UpdatePoint(9,10,9);
            end;
         end;
         //
         // lock both hands, then pull neck, left arm stretches, can't do bottom code
         // otherwise right arm stretches...dammit..
         //UpdatePoint(7,6, 6);
         //UpdatePoint(9,6, 8);
      end;
      ///////
      if (nSrcIndex = 7) then
      begin
         if Pnt(6)^.m_bLocked then
         begin
            UpdatePoint(6,7, 6);
         end else
         begin
            UpdatePoint(7,6, 6);
            if (Pnt(9)^.m_bLocked) then
            begin
               UpdatePoint(9,6, 8);
               UpdatePoint(6,7, 6);
            end else
            begin
               UpdatePoint(6,9, 8);
               if (Pnt(10)^.m_bLocked) then
               begin
                  UpdatePoint(10,9, 9);
                  UpdatePoint(9,6, 8);
                  UpdatePoint(6,7, 6);
               end else
               begin
                  UpdatePoint(9,10, 9);
               end;
            end;
         end;
       end;
      ///////////////////
      if (nSrcIndex = 9) then
      begin
         if Pnt(6)^.m_bLocked then
         begin
            UpdatePoint(6,9, 8);
         end else
         begin
            UpdatePoint(9,6, 8);
            if (Pnt(7)^.m_bLocked) then
            begin
               UpdatePoint(7,6, 6);
               UpdatePoint(6,9, 8);
            end else
            begin
               UpdatePoint(6,7, 6);
               if (Pnt(8)^.m_bLocked) then
               begin
                  UpdatePoint(8,7, 7);
                  UpdatePoint(7,6, 6);
                  UpdatePoint(6,9, 8);
               end else
               begin
                  UpdatePoint(7,8, 7);
               end;
            end;
         end;
      end;
      //update all
      if (nSrcIndex <> 1) then
      begin
         if (Pnt(1)^.m_bLocked) then
         begin
            UpdatePoint(1,6, 5);
         end else
         begin
            UpdatePoint(6,1, 5);
            SetPoint(Pnt(1)^.Left, Pnt(1)^.Top, 1, 6);
            UpdatePoint(1,6, 5);
            SetPoint(Pnt(6)^.Left, Pnt(6)^.Top, 6, 1);
         end;
      end else
      begin
         UpdatePoint(6,1, 5);
      end;
      ///////////////////////////////
      {UpdatePoint(6,7,6);
      UpdatePoint(7,8,7);
      UpdatePoint(6,9,8);
      UpdatePoint(9,10,9); }
      exit;
   end;
   if (nIndex = 7) then
   begin
      angle := 180 * (1 + ArcTan2(Pnt(7)^.Top-Pnt(6)^.Top, Pnt(7)^.Left-Pnt(6)^.Left) / PI);
      if angle >= 360.0 then angle := angle - 360.0;
      Rads := DegToRad(angle);
      cx := (Lng[6] * Cos(Rads));
      cy := (Lng[6] * Sin(Rads));
      if (nSrcIndex <> 6) then SetPoint( round(Pnt(6)^.Left+cx), round(Pnt(6)^.Top+cy), 6, 7);
      angle := 180 * (1 + ArcTan2(Pnt(7)^.Top-Pnt(8)^.Top, Pnt(7)^.Left-Pnt(8)^.Left) / PI);
      if angle >= 360.0 then angle := angle - 360.0;
      Rads := DegToRad(angle);
      cx := (Lng[7] * Cos(Rads));
      cy := (Lng[7] * Sin(Rads));
      if (nSrcIndex <> 8) then
      begin
         SetPoint( round(Pnt(7)^.Left + cx), round(Pnt(7)^.Top + cy), 8, 7);
         UpdatePoint(8,7, 7);
      end else
      begin
         UpdatePoint(8,7, 7);
      end;
      angle := 180 * (1 + ArcTan2(Pnt(7)^.Top-Pnt(6)^.Top, Pnt(7)^.Left-Pnt(6)^.Left) / PI);
      if angle >= 360.0 then angle := angle - 360.0;
      Rads := DegToRad(angle);
      cx := (Lng[6] * Cos(Rads));
      cy := (Lng[6] * Sin(Rads));
      if (nSrcIndex <> 6) then SetPoint( round(Pnt(6)^.Left+cx), round(Pnt(6)^.Top+cy), 6, 7);
      {UpdatePoint(6,7,6);
      UpdatePoint(7,8,7);
      UpdatePoint(6,9,8);
      UpdatePoint(9,10,9);}
   end;
   if (nIndex = 8) then
   begin
      angle := 180 * (1 + ArcTan2(Pnt(8)^.Top-Pnt(7)^.Top, Pnt(8)^.Left-Pnt(7)^.Left) / PI);
      if angle >= 360.0 then angle := angle - 360.0;
      Rads := DegToRad(angle);
      cx := (Lng[7] * Cos(Rads));
      cy := (Lng[7] * Sin(Rads));
      if (nSrcIndex <> 7) then
      begin
         SetPoint( round(Pnt(8)^.Left+cx), round(Pnt(8)^.Top+cy), 7, 8);
         UpdatePoint(6,7, 6);
         UpdatePoint(7,8, 7);
      end else
      begin
         
      end;
   end;
   if (nIndex = 9) then
   begin
      angle := 180 * (1 + ArcTan2(Pnt(9)^.Top-Pnt(6)^.Top, Pnt(9)^.Left-Pnt(6)^.Left) / PI);
      if angle >= 360.0 then angle := angle - 360.0;
      Rads := DegToRad(angle);
      cx := (Lng[8] * Cos(Rads));
      cy := (Lng[8] * Sin(Rads));
      if (nSrcIndex <> 6) then SetPoint( round(Pnt(6)^.Left+cx), round(Pnt(6)^.Top+cy), 6, 9);
      angle := 180 * (1 + ArcTan2(Pnt(9)^.Top-Pnt(10)^.Top, Pnt(9)^.Left-Pnt(10)^.Left) / PI);
      if angle >= 360.0 then angle := angle - 360.0;
      Rads := DegToRad(angle);
      cx := (Lng[9] * Cos(Rads));
      cy := (Lng[9] * Sin(Rads));
      if (nSrcIndex <> 10) then
      begin
         SetPoint( round(Pnt(9)^.Left + cx), round(Pnt(9)^.Top + cy), 10, 9);
         UpdatePoint(10,9, 9);
      end else
      begin
         UpdatePoint(9,10, 9);
      end;
      angle := 180 * (1 + ArcTan2(Pnt(9)^.Top-Pnt(6)^.Top, Pnt(9)^.Left-Pnt(6)^.Left) / PI);
      if angle >= 360.0 then angle := angle - 360.0;
      Rads := DegToRad(angle);
      cx := (Lng[8] * Cos(Rads));
      cy := (Lng[8] * Sin(Rads));
      if (nSrcIndex <> 6) then SetPoint( round(Pnt(6)^.Left+cx), round(Pnt(6)^.Top+cy), 6, 9);
      {UpdatePoint(6,9,8);
      UpdatePoint(9,10,9);
      UpdatePoint(6,7,6);
      UpdatePoint(7,8,7);}
   end;
   if (nIndex = 10) then
   begin
      bOld := Pnt(10)^.m_bLocked;
      Pnt(10)^.m_bLocked := FALSE;
      ox := Pnt(10)^.Left;
      oy := Pnt(10)^.Top;
      if (nSrcIndex = 10) then
      begin
         SetPoint( round(Pnt(9)^.Left), round(Pnt(9)^.Top), 9, 9);
         UpdatePoint(6,9,8);
      end;
       Pnt(10)^.Left := ox;
       Pnt(10)^.Top := oy;
      angle := 180 * (1 + ArcTan2(Pnt(10)^.Top-Pnt(9)^.Top, Pnt(10)^.Left-Pnt(9)^.Left) / PI);
      if angle >= 360.0 then angle := angle - 360.0;
      Rads := DegToRad(angle);
      cx := (Lng[9] * Cos(Rads));
      cy := (Lng[9] * Sin(Rads));
      if (nSrcIndex <> 9) then
      begin
         SetPoint( round(Pnt(10)^.Left+cx), round(Pnt(10)^.Top+cy), 9, 10);
         UpdatePoint(6,9,8);
      end;
      UpdatePoint(9,10,9);
      Pnt(10)^.m_bLocked := bOld;
   end;

   if (nIndex = 1) then
   begin
      if (nSrcIndex = 1) or (nSrcIndex = 6) then
      begin
         if (nSrcIndex = 1) then
         begin
            if (Pnt(6)^.m_bLocked) then
            begin
               UpdatePoint(6,1, 5);
            end;
         end;
         if Pnt(2)^.m_bLocked = false then UpdatePoint(1,2, 1);
         SetPoint(Pnt(2)^.Left, Pnt(2)^.Top, 2, 1);
         UpdatePoint(2,1, 1);
         if Pnt(4)^.m_bLocked = FALSE then UpdatePoint(1,4, 3);
         SetPoint(Pnt(4)^.Left, Pnt(4)^.Top, 4, 1);
         UpdatePoint(4,1, 3);
         //
         // lock both hands, then pull neck, left arm stretches, can't do bottom code
         // otherwise right arm stretches...dammit..
         //UpdatePoint(7,6, 6);
         //UpdatePoint(9,6, 8);
      end;
      ///////
      if (nSrcIndex = 2) then
      begin
         if Pnt(1)^.m_bLocked then
         begin
            UpdatePoint(1,2, 1);
         end else
         begin
            UpdatePoint(2,1, 1);
            if (Pnt(4)^.m_bLocked) then
            begin
               UpdatePoint(4,1, 3);
               UpdatePoint(1,2, 1);
            end else
            begin
               UpdatePoint(1,4, 3);
               if (Pnt(5)^.m_bLocked) then
               begin
                  UpdatePoint(5,4, 4);
                  UpdatePoint(4,1, 3);
                  UpdatePoint(1,2, 1);
               end else
               begin
                  UpdatePoint(4,5, 4);
               end;
            end;
         end;
      end;
      ///////////////////
      if (nSrcIndex = 4) then
      begin
         if Pnt(1)^.m_bLocked then
         begin
            UpdatePoint(1,4, 3);
         end else
         begin
            UpdatePoint(4,1, 3);
            if (Pnt(2)^.m_bLocked) then
            begin
               UpdatePoint(2,1, 1);
               UpdatePoint(1,4, 3);
            end else
            begin
               UpdatePoint(1,2, 1);
               if (Pnt(3)^.m_bLocked) then
               begin
                  UpdatePoint(3,2, 2);
                  UpdatePoint(2,1, 1);
                  UpdatePoint(1,4, 3);
               end else
               begin
                  UpdatePoint(2,3, 2);
               end;
            end;
         end;
      end;
      ///////////////////////////////
      if (nSrcIndex <> 6) then
      begin
         if (Pnt(6)^.m_bLocked) then
         begin
            UpdatePoint(6,1, 5);
         end else
         begin
            UpdatePoint(1,6, 5);
            SetPoint(Pnt(6)^.Left, Pnt(6)^.Top, 6, 1);
            UpdatePoint(6,1, 5);
            SetPoint(Pnt(1)^.Left, Pnt(1)^.Top, 1, 6);
         end;
      end;
      exit;
   end;

   if (nIndex = 2) then
   begin
         if nSrcIndex = 2 then
         if (Pnt(6)^.m_bLocked) then
         begin
            //UpdatePoint(6,1, 5);
            UpdatePoint(2,1, 1);
            UpdatePoint(1,2, 1);
         end;
      angle := 180 * (1 + ArcTan2(Pnt(2)^.Top-Pnt(1)^.Top, Pnt(2)^.Left-Pnt(1)^.Left) / PI);
      if angle >= 360.0 then angle := angle - 360.0;
      Rads := DegToRad(angle);
      cx := (Lng[1] * Cos(Rads));
      cy := (Lng[1] * Sin(Rads));
      if (nSrcIndex <> 1) then
      begin
         SetPoint( round(Pnt(1)^.Left+cx), round(Pnt(1)^.Top+cy), 1, 2);
      end;
         if nSrcIndex = 2 then
         if (Pnt(6)^.m_bLocked) then
         begin
            //UpdatePoint(6,1, 5);
            UpdatePoint(1,2, 1);
         end;
      angle := 180 * (1 + ArcTan2(Pnt(2)^.Top-Pnt(3)^.Top, Pnt(2)^.Left-Pnt(3)^.Left) / PI);
      if angle >= 360.0 then angle := angle - 360.0;
      Rads := DegToRad(angle);
      cx := (Lng[2] * Cos(Rads));
      cy := (Lng[2] * Sin(Rads));
      if (nSrcIndex <> 3) then
      begin
         SetPoint( round(Pnt(2)^.Left + cx), round(Pnt(2)^.Top + cy), 3, 2);
         UpdatePoint(3,2, 2);
      end else
      begin
         UpdatePoint(2,3, 2);
      end;
      angle := 180 * (1 + ArcTan2(Pnt(2)^.Top-Pnt(1)^.Top, Pnt(2)^.Left-Pnt(1)^.Left) / PI);
      if angle >= 360.0 then angle := angle - 360.0;
      Rads := DegToRad(angle);
      cx := (Lng[1] * Cos(Rads));
      cy := (Lng[1] * Sin(Rads));
      if (nSrcIndex <> 1) then SetPoint( round(Pnt(1)^.Left+cx), round(Pnt(1)^.Top+cy), 1, 2);
   end;
   if (nIndex = 3) then
   begin
      angle := 180 * (1 + ArcTan2(Pnt(3)^.Top-Pnt(2)^.Top, Pnt(3)^.Left-Pnt(2)^.Left) / PI);
      if angle >= 360.0 then angle := angle - 360.0;
      Rads := DegToRad(angle);
      cx := (Lng[2] * Cos(Rads));
      cy := (Lng[2] * Sin(Rads));
      if (nSrcIndex <> 2) then
      begin
         SetPoint( round(Pnt(3)^.Left+cx), round(Pnt(3)^.Top+cy), 2, 3);
         UpdatePoint(1,2, 1);
         UpdatePoint(2,3, 2);
      end else
      begin
         
      end;
   end;
   if (nIndex = 4) then
   begin
      angle := 180 * (1 + ArcTan2(Pnt(4)^.Top-Pnt(1)^.Top, Pnt(4)^.Left-Pnt(1)^.Left) / PI);
      if angle >= 360.0 then angle := angle - 360.0;
      Rads := DegToRad(angle);
      cx := (Lng[3] * Cos(Rads));
      cy := (Lng[3] * Sin(Rads));
      if (nSrcIndex <> 1) then SetPoint( round(Pnt(1)^.Left+cx), round(Pnt(1)^.Top+cy), 1, 4);
      angle := 180 * (1 + ArcTan2(Pnt(4)^.Top-Pnt(5)^.Top, Pnt(4)^.Left-Pnt(5)^.Left) / PI);
      if angle >= 360.0 then angle := angle - 360.0;
      Rads := DegToRad(angle);
      cx := (Lng[4] * Cos(Rads));
      cy := (Lng[4] * Sin(Rads));
      if (nSrcIndex <> 5) then
      begin
         SetPoint( round(Pnt(4)^.Left + cx), round(Pnt(4)^.Top + cy), 5, 4);
         UpdatePoint(5,4, 4);
      end else
      begin
         UpdatePoint(4,5, 4);
      end;
      angle := 180 * (1 + ArcTan2(Pnt(4)^.Top-Pnt(1)^.Top, Pnt(4)^.Left-Pnt(1)^.Left) / PI);
      if angle >= 360.0 then angle := angle - 360.0;
      Rads := DegToRad(angle);
      cx := (Lng[3] * Cos(Rads));
      cy := (Lng[3] * Sin(Rads));
      if (nSrcIndex <> 1) then SetPoint( round(Pnt(1)^.Left+cx), round(Pnt(1)^.Top+cy), 1, 4);
      {UpdatePoint(1,4,3);
      UpdatePoint(4,5,4);
      UpdatePoint(1,2,1);
      UpdatePoint(2,3,2); }
   end;
   if (nIndex = 5) then
   begin
      angle := 180 * (1 + ArcTan2(Pnt(5)^.Top-Pnt(4)^.Top, Pnt(5)^.Left-Pnt(4)^.Left) / PI);
      if angle >= 360.0 then angle := angle - 360.0;
      Rads := DegToRad(angle);
      cx := (Lng[4] * Cos(Rads));
      cy := (Lng[4] * Sin(Rads));
      if (nSrcIndex <> 4) then
      begin
         SetPoint( round(Pnt(5)^.Left+cx), round(Pnt(5)^.Top+cy), 4, 5);
         UpdatePoint(1,4, 3);
         UpdatePoint(4,5, 4);
      end else
      begin
         
      end;
   end;
end;

procedure TStickMan.Move(xAmount, yAmount : integer);
var
   f : integer;
begin
   for f := 1 to 10 do
   begin
      Pnt(f)^.Left := Pnt(f)^.Left + xAmount;
      Pnt(f)^.Top := Pnt(f)^.Top + yAmount;
   end;
end;

procedure TStickMan.Alpha(amount : single);
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

procedure TStickMan.Draw(xoffs,yoffs : integer; DrawControlPoints : Boolean);
var
   angle : double;
   Rads : double;
   cx, cy : double;
   nWide, nHigh : integer;
   q,w : integer;
begin

   nWide := 3;
   nHigh := 3;

        frmMain.DrawLine2(xoffs+Pnt(6)^.Left+nWide, yoffs+Pnt(6)^.Top+nHigh,
                          xoffs+Pnt(1)^.Left+nWide, yoffs+Pnt(1)^.Top+nHigh,
                          m_outColour, m_alpha,
                          Wid[5]);

        frmMain.DrawLine2(xoffs+Pnt(1)^.Left+nWide, yoffs+Pnt(1)^.Top+nHigh,
                          xoffs+Pnt(2)^.Left+nWide, yoffs+Pnt(2)^.Top+nHigh,
                          m_outColour, m_alpha,
                          Wid[1]);

        frmMain.DrawLine2(xoffs+Pnt(2)^.Left+nWide, yoffs+Pnt(2)^.Top+nHigh,
                          xoffs+Pnt(3)^.Left+nWide, yoffs+Pnt(3)^.Top+nHigh,
                          m_outColour, m_alpha,
                          Wid[2]);

        frmMain.DrawLine2(xoffs+Pnt(1)^.Left+nWide, yoffs+Pnt(1)^.Top+nHigh,
                          xoffs+Pnt(4)^.Left+nWide, yoffs+Pnt(4)^.Top+nHigh,
                          m_outColour, m_alpha,
                          Wid[3]);

        frmMain.DrawLine2(xoffs+Pnt(4)^.Left+nWide, yoffs+Pnt(4)^.Top+nHigh,
                          xoffs+Pnt(5)^.Left+nWide, yoffs+Pnt(5)^.Top+nHigh,
                          m_outColour, m_alpha,
                          Wid[4]);

        frmMain.DrawLine2(xoffs+Pnt(6)^.Left+nWide, yoffs+Pnt(6)^.Top+nHigh,
                          xoffs+Pnt(7)^.Left+nWide, yoffs+Pnt(7)^.Top+nHigh,
                          m_outColour, m_alpha,
                          Wid[6]);

        frmMain.DrawLine2(xoffs+Pnt(7)^.Left+nWide, yoffs+Pnt(7)^.Top+nHigh,
                          xoffs+Pnt(8)^.Left+nWide, yoffs+Pnt(8)^.Top+nHigh,
                          m_outColour, m_alpha,
                          Wid[7]);

        frmMain.DrawLine2(xoffs+Pnt(6)^.Left+nWide, yoffs+Pnt(6)^.Top+nHigh,
                          xoffs+Pnt(9)^.Left+nWide, yoffs+Pnt(9)^.Top+nHigh,
                          m_outColour, m_alpha,
                          Wid[8]);

        frmMain.DrawLine2(xoffs+Pnt(9)^.Left+nWide, yoffs+Pnt(9)^.Top+nHigh,
                          xoffs+Pnt(10)^.Left+nWide, yoffs+Pnt(10)^.Top+nHigh,
                          m_outColour, m_alpha,
                          Wid[9]);

        angle := 180 * (1 + ArcTan2(Pnt(6)^.Top-Pnt(1)^.Top, Pnt(6)^.Left-Pnt(1)^.Left) / PI);
        if angle >= 360.0 then angle := angle - 360.0;

        angle := angle - 180;
        Rads := DegToRad(angle);
        cx := (m_nHeadDiam div 2) * Cos(Rads);
        cy := (m_nHeadDiam div 2) * Sin(Rads);
        cx := Pnt(6)^.Left+cx;
        cy := Pnt(6)^.Top+cy;
        q := round(xoffs+cx);
        w := round(yoffs+cy);

        angle := angle - 180;
        Rads := DegToRad(angle);
        cx := cx + (m_nHeadDiam div 2-2) * Cos(Rads);
        cy := cy + (m_nHeadDiam div 2-2) * Sin(Rads);
        frmMain.DrawLine2(xoffs+Pnt(6)^.Left+nWide, yoffs+Pnt(6)^.Top+nHigh,
                          xoffs+round(cx),yoffs+round(cy),
                          m_outColour, m_alpha,
                          Wid[5]);

        frmMain.DrawEllipse(q,w, m_nHeadDiam,m_nHeadDiam, m_outColour, m_inColour, m_alpha, Wid[10], 0);
end;


function TSpecialStickMan.Pnt(nIndex : integer) : TLabel2Ptr;
begin
   Pnt := TLabel2Ptr(PntList.Items[nIndex-1]);
end;

constructor TSpecialStickMan.Create(AOwner : TWinControl; n1,n2,n3,n4,n5,n6,n7,n8,n9 : integer);
var
   f : integer;
   pPnt : TLabel2Ptr;
begin
   m_styleInner := bsSolid;
   m_styleOuter := psSolid;
   m_nLineWidth := 5;
   m_nDrawStyle := 1;
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
   //
   Lng[10] := 10;
   Lng[11] := 10;
   Lng[12] := 15;
   Lng[13] := 15;
   //
   for f := 1 to 14 do
   begin
      Wid[f] := 10;
   end;
   for f := 1 to 14 do
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
   //
   Pnt(11)^.Color := clRed;
   Pnt(12)^.Color := clBlue;
   Pnt(13)^.Color := clRed;
   Pnt(14)^.Color := clBlue;
   m_alpha := 255;
   m_angle := 0;
   m_aliased := 1;
end;

destructor TSpecialStickMan.Destroy;
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

procedure TSpecialStickMan.Assign(source : TSpecialStickManPtr);
var
   f : integer;
begin
   for f := 1 to 13 do
   begin
      Lng[f] := source^.Lng[f];
   end;
   for f := 1 to 14 do
   begin
      Pnt(f)^.Left := source^.Pnt(f)^.Left;
      Pnt(f)^.Top := source^.Pnt(f)^.Top;
      Wid[f] := source^.Wid[f];
   end;
   m_styleInner := source^.m_styleInner;
   m_styleOuter := source^.m_styleOuter;
   m_nDrawStyle := source^.m_nDrawStyle;
   m_nHeadDiam := source^.m_nHeadDiam;
   m_InColour := source^.m_InColour;
   m_OutColour := source^.m_OutColour;
   m_nLineWidth := source^.m_nLineWidth;
end;

procedure TSpecialStickMan.Update(nIndex : integer);
begin
   SetPoint(Pnt(nIndex)^.Left, Pnt(nIndex)^.Top, Pnt(nIndex)^.Tag, Pnt(nIndex)^.Tag);
end;

procedure TSpecialStickMan.UpdatePoint(nIndex1, nIndex2, nIndex3 : integer);
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

procedure TSpecialStickMan.SetPoint(x, y, nIndex, nSrcIndex : integer);
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

   if (m_nDrawStyle = 3) then
   begin
         //////////////
         if (nIndex = 14) then
         begin
            if (nSrcindex <> 5) and (pnt(5)^.m_bLocked) then
            begin
               UpdatePoint(5, 14, 13);
               exit;
            end;
            if (nSrcIndex <> 5) then
            begin
               UpdatePoint(14, 5, 13);
               SetPoint(Pnt(5)^.Left, Pnt(5)^.Top, 5, 14);
            end;
            UpdatePoint(14, 5, 13);
         end;
         if (nIndex = 5) then
         begin
            UpdatePoint(5, 14, 13);
            if (nSrcindex <> 4) and (pnt(4)^.m_bLocked) then
            begin
               UpdatePoint(4, 5, 4);
               SetPoint(Pnt(4)^.Left, Pnt(4)^.Top, 4, 5);
               exit;
            end;
            if (nSrcIndex <> 4) then
            begin
               UpdatePoint(5, 4, 4);
               SetPoint(Pnt(4)^.Left, Pnt(4)^.Top, 4, 5);
            end;
            UpdatePoint(5, 14, 13);
         end;
         if (nIndex = 4) then
         begin
            if (nSrcIndex <> 1) then
            begin
               Pnt(1)^.Left := Pnt(2)^.Left + ((Pnt(4)^.Left - Pnt(2)^.Left) div 2);
               Pnt(1)^.Top := Pnt(2)^.Top + ((Pnt(4)^.Top - Pnt(2)^.Top) div 2);
               angle := 180 * (1 + ArcTan2(Pnt(2)^.Top-Pnt(4)^.Top, Pnt(2)^.Left-Pnt(4)^.Left) / PI);
               if angle >= 360.0 then angle := angle - 360.0;
               Rads := DegToRad(angle-90);
               cx := Round(Lng[5] * Cos(Rads));
               cy := Round(Lng[5] * Sin(Rads));
               Pnt(6)^.Left := round(Pnt(1)^.Left+cx);
               Pnt(6)^.Top := round(Pnt(1)^.Top+cy);
               SetPoint(Pnt(6)^.Left, Pnt(6)^.Top, 6, 4);
            end;
            UpdatePoint(4, 5, 4);
            if (nSrcIndex <> 5) then
            begin
               SetPoint(Pnt(5)^.Left, Pnt(5)^.Top, 5, 4);
            end;
         end;
         ////////////////////////////
         if (nIndex = 13) then
         begin
            if (nSrcindex <> 3) and (pnt(3)^.m_bLocked) then
            begin
               UpdatePoint(3, 13, 12);
               exit;
            end;
            if (nSrcIndex <> 3) then
            begin
               UpdatePoint(13, 3, 12);
               SetPoint(Pnt(3)^.Left, Pnt(3)^.Top, 3, 13);
            end;
            UpdatePoint(13, 3, 12);
         end;
         if (nIndex = 3) then
         begin
            UpdatePoint(3, 13, 12);
            if (nSrcindex <> 2) and (pnt(2)^.m_bLocked) then
            begin
               UpdatePoint(2, 3, 2);
               SetPoint(Pnt(2)^.Left, Pnt(2)^.Top, 2, 3);
               exit;
            end;
            if (nSrcIndex <> 2) then
            begin
               UpdatePoint(3, 2, 2);
               SetPoint(Pnt(2)^.Left, Pnt(2)^.Top, 2, 3);
            end;
            UpdatePoint(3, 13, 12);
         end;
         if (nIndex = 2) then
         begin
            if (nSrcIndex <> 1) then
            begin
               Pnt(1)^.Left := Pnt(2)^.Left + ((Pnt(4)^.Left - Pnt(2)^.Left) div 2);
               Pnt(1)^.Top := Pnt(2)^.Top + ((Pnt(4)^.Top - Pnt(2)^.Top) div 2);
               angle := 180 * (1 + ArcTan2(Pnt(2)^.Top-Pnt(4)^.Top, Pnt(2)^.Left-Pnt(4)^.Left) / PI);
               if angle >= 360.0 then angle := angle - 360.0;
               Rads := DegToRad(angle-90);
               cx := Round(Lng[5] * Cos(Rads));
               cy := Round(Lng[5] * Sin(Rads));
               Pnt(6)^.Left := round(Pnt(1)^.Left+cx);
               Pnt(6)^.Top := round(Pnt(1)^.Top+cy);
               SetPoint(Pnt(6)^.Left, Pnt(6)^.Top, 6, 2);
            end;
            UpdatePoint(2, 3, 2);
            if (nSrcIndex <> 3) then
            begin
               SetPoint(Pnt(3)^.Left, Pnt(3)^.Top, 3, 2);
            end;
         end;
         ////////////////////////////
         if (nIndex = 12) then
         begin
            if (nSrcindex <> 10) and (pnt(10)^.m_bLocked) then
            begin
               UpdatePoint(10, 12, 11);
               exit;
            end;
            if (nSrcIndex <> 10) then
            begin
               UpdatePoint(12, 10, 11);
               SetPoint(Pnt(10)^.Left, Pnt(10)^.Top, 10, 12);
            end;
            UpdatePoint(10, 12, 12);
         end;
         if (nIndex = 10) then
         begin
            UpdatePoint(10, 12, 11);
            if (nSrcindex <> 9) and (pnt(9)^.m_bLocked) then
            begin
               UpdatePoint(9, 10, 9);
               SetPoint(Pnt(9)^.Left, Pnt(9)^.Top, 9, 10);
               exit;
            end;
            if (nSrcIndex <> 9) then
            begin
               UpdatePoint(10, 9, 9);
               SetPoint(Pnt(9)^.Left, Pnt(9)^.Top, 9, 10);
            end;
            UpdatePoint(10, 12, 11);
         end;
         if (nIndex = 9) then
         begin
            if (nSrcIndex <> 6) then
            begin
               Pnt(6)^.Left := Pnt(7)^.Left + ((Pnt(9)^.Left - Pnt(7)^.Left) div 2);
               Pnt(6)^.Top := Pnt(7)^.Top + ((Pnt(9)^.Top - Pnt(7)^.Top) div 2);
               angle := 180 * (1 + ArcTan2(Pnt(7)^.Top-Pnt(9)^.Top, Pnt(7)^.Left-Pnt(9)^.Left) / PI);
               if angle >= 360.0 then angle := angle - 360.0;
               Rads := DegToRad(angle+90);
               cx := Round(Lng[5] * Cos(Rads));
               cy := Round(Lng[5] * Sin(Rads));
               Pnt(1)^.Left := round(Pnt(6)^.Left+cx);
               Pnt(1)^.Top := round(Pnt(6)^.Top+cy);
               SetPoint(Pnt(1)^.Left, Pnt(1)^.Top, 1, 7);
               {UpdatePoint(9, 6, 8);
               SetPoint(Pnt(6)^.Left, Pnt(6)^.Top, 6, 9);
               UpdatePoint(6,9, 8);}
            end;
            UpdatePoint(9, 10, 9);
            if (nSrcIndex <> 10) then
            begin
               SetPoint(Pnt(10)^.Left, Pnt(10)^.Top, 10, 9);
            end;
         end;
         ////////////////////////////
         if (nIndex = 11) then
         begin
            if (nSrcindex <> 8) and (pnt(8)^.m_bLocked) then
            begin
               UpdatePoint(8, 11, 10);
               exit;
            end;
            if (nSrcIndex <> 8) then
            begin
               UpdatePoint(11, 8, 10);
               SetPoint(Pnt(8)^.Left, Pnt(8)^.Top, 8, 10);
            end;
            UpdatePoint(8, 11, 10);
         end;
         if (nIndex = 8) then
         begin
            UpdatePoint(8, 11, 10);
            if (nSrcindex <> 7) and (pnt(7)^.m_bLocked) then
            begin
               UpdatePoint(7, 8, 7);
               SetPoint(Pnt(7)^.Left, Pnt(7)^.Top, 7, 8);
               exit;
            end;
            if (nSrcIndex <> 7) then
            begin
               UpdatePoint(8, 7, 7);
               SetPoint(Pnt(7)^.Left, Pnt(7)^.Top, 7, 8);
            end;
            UpdatePoint(8, 11, 10);
         end;
         if (nIndex = 7) then
         begin
            if (nSrcIndex <> 6) then
            begin
               Pnt(6)^.Left := Pnt(7)^.Left + ((Pnt(9)^.Left - Pnt(7)^.Left) div 2);
               Pnt(6)^.Top := Pnt(7)^.Top + ((Pnt(9)^.Top - Pnt(7)^.Top) div 2);
               angle := 180 * (1 + ArcTan2(Pnt(7)^.Top-Pnt(9)^.Top, Pnt(7)^.Left-Pnt(9)^.Left) / PI);
               if angle >= 360.0 then angle := angle - 360.0;
               Rads := DegToRad(angle+90);
               cx := Round(Lng[5] * Cos(Rads));
               cy := Round(Lng[5] * Sin(Rads));
               Pnt(1)^.Left := round(Pnt(6)^.Left+cx);
               Pnt(1)^.Top := round(Pnt(6)^.Top+cy);
               SetPoint(Pnt(1)^.Left, Pnt(1)^.Top, 1, 7);
               {UpdatePoint(7, 6, 6);
               SetPoint(Pnt(6)^.Left, Pnt(6)^.Top, 6, 7);
               UpdatePoint(6,7, 6); }
            end;
            UpdatePoint(7, 8, 7);
            if (nSrcIndex <> 8) then
            begin
               SetPoint(Pnt(8)^.Left, Pnt(8)^.Top, 8, 7);
            end;
         end;
         /////////////////////
         if (nIndex = 6) then
         begin
            if (nSrcIndex <> 7) and (Pnt(7)^.m_bLocked) then
            begin
               UpdatePoint(7,6, 6);
               ox := Pnt(7)^.Left;
               oy := Pnt(7)^.Top;
               SetPoint(Pnt(6)^.Left, Pnt(6)^.Top, 6,7);
               Pnt(7)^.Left := ox;
               Pnt(7)^.Top := oy;
               UpdatePoint(7,6, 6);
               exit;
            end;
            if (nSrcIndex <> 9) and (Pnt(9)^.m_bLocked) then
            begin
               UpdatePoint(9,6, 8);
               ox := Pnt(9)^.Left;
               oy := Pnt(9)^.Top;
               SetPoint(Pnt(6)^.Left, Pnt(6)^.Top, 6,9);
               Pnt(9)^.Left := ox;
               Pnt(9)^.Top := oy;
               UpdatePoint(9,6, 8);
               exit;
            end;
            angle := 180 * (1 + ArcTan2(Pnt(6)^.Top-Pnt(1)^.Top, Pnt(6)^.Left-Pnt(1)^.Left) / PI);
            if angle >= 360.0 then angle := angle - 360.0;
            Rads := DegToRad(angle);
            cx := Round(Lng[5] * Cos(Rads));
            cy := Round(Lng[5] * Sin(Rads));
            Pnt(1)^.Left := round(Pnt(6)^.Left+cx);
            Pnt(1)^.Top := round(Pnt(6)^.Top+cy);

            Rads := DegToRad(angle+90);
            cx := Round(Lng[6] * Cos(Rads));
            cy := Round(Lng[6] * Sin(Rads));
            Pnt(7)^.Left := round(Pnt(6)^.Left+cx);
            Pnt(7)^.Top := round(Pnt(6)^.Top+cy);
            Rads := DegToRad(angle-90);
            cx := Round(Lng[8] * Cos(Rads));
            cy := Round(Lng[8] * Sin(Rads));
            Pnt(9)^.Left := round(Pnt(6)^.Left+cx);
            Pnt(9)^.Top := round(Pnt(6)^.Top+cy);
            if (nSrcIndex <> 1) then SetPoint(Pnt(1)^.Left, Pnt(1)^.Top, 1, 6);
            if (nSrcIndex <> 7) then SetPoint(Pnt(7)^.Left, Pnt(7)^.Top, 7, 6);
            if (nSrcIndex <> 9) then SetPoint(Pnt(9)^.Left, Pnt(9)^.Top, 9, 6);
         end;
         if (nIndex = 1) then
         begin
            if (nSrcIndex <> 2) and (Pnt(2)^.m_bLocked) then
            begin
               UpdatePoint(2,1, 1);
               ox := Pnt(2)^.Left;
               oy := Pnt(2)^.Top;
               SetPoint(Pnt(1)^.Left, Pnt(1)^.Top, 1,2);
               Pnt(2)^.Left := ox;
               Pnt(2)^.Top := oy;
               UpdatePoint(2,1, 1);
               exit;
            end;
            if (nSrcIndex <> 4) and (Pnt(4)^.m_bLocked) then
            begin
               UpdatePoint(4,1, 3);
               ox := Pnt(4)^.Left;
               oy := Pnt(4)^.Top;
               SetPoint(Pnt(1)^.Left, Pnt(1)^.Top, 1,4);
               Pnt(4)^.Left := ox;
               Pnt(4)^.Top := oy;
               UpdatePoint(4,1, 3);
               exit;
            end;
            angle := 180 * (1 + ArcTan2(Pnt(1)^.Top-Pnt(6)^.Top, Pnt(1)^.Left-Pnt(6)^.Left) / PI);
            if angle >= 360.0 then angle := angle - 360.0;
            Rads := DegToRad(angle);
            cx := Round(Lng[5] * Cos(Rads));
            cy := Round(Lng[5] * Sin(Rads));
            Pnt(6)^.Left := round(Pnt(1)^.Left+cx);
            Pnt(6)^.Top := round(Pnt(1)^.Top+cy);

            Rads := DegToRad(angle-90);
            cx := Round(Lng[1] * Cos(Rads));
            cy := Round(Lng[1] * Sin(Rads));
            Pnt(2)^.Left := round(Pnt(1)^.Left+cx);
            Pnt(2)^.Top := round(Pnt(1)^.Top+cy);
            Rads := DegToRad(angle+90);
            cx := Round(Lng[3] * Cos(Rads));
            cy := Round(Lng[3] * Sin(Rads));
            Pnt(4)^.Left := round(Pnt(1)^.Left+cx);
            Pnt(4)^.Top := round(Pnt(1)^.Top+cy);
            if (nSrcIndex <> 6) then SetPoint(Pnt(6)^.Left, Pnt(6)^.Top, 6, 1);
            if (nSrcIndex <> 2) then SetPoint(Pnt(2)^.Left, Pnt(2)^.Top, 2, 1);
            if (nSrcIndex <> 4) then SetPoint(Pnt(4)^.Left, Pnt(4)^.Top, 4, 1);
         end;
   end else
   begin

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
                  if (not Pnt(11)^.m_bLocked) then
                  begin
                     UpdatePoint(8,11, 10);
                  end else
                  begin
                     UpdatePoint(11,8, 10);
                     UpdatePoint(8,7, 7);
                  end;
               end else
               begin
                  UpdatePoint(8,7, 7);
                  if (not Pnt(11)^.m_bLocked) then
                  begin
                     UpdatePoint(8,11, 10);
                  end else
                  begin
                     UpdatePoint(11,8, 10);
                     UpdatePoint(8,7, 7);
                  end;
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
                  // left hand
                  if (not Pnt(11)^.m_bLocked) then
                  begin
                     UpdatePoint(8,11, 10);
                  end else
                  begin
                     UpdatePoint(11,8, 10);
                  end;
                  //
                  UpdatePoint(6,7, 6);
                  UpdatePoint(7,8, 7);
               end else
               begin
         
               end;
            end;
            if (nIndex = 11) then
            begin
               angle := 180 * (1 + ArcTan2(Pnt(11)^.Top-Pnt(8)^.Top, Pnt(11)^.Left-Pnt(8)^.Left) / PI);
               if angle >= 360.0 then angle := angle - 360.0;
               Rads := DegToRad(angle);
               cx := (Lng[10] * Cos(Rads));
               cy := (Lng[10] * Sin(Rads));
               if (nSrcIndex <> 8) then
               begin
                  SetPoint( round(Pnt(11)^.Left+cx), round(Pnt(11)^.Top+cy), 8, 11);
               end else
               begin

               end;
            end;
            if (nIndex = 12) then
            begin
               angle := 180 * (1 + ArcTan2(Pnt(12)^.Top-Pnt(10)^.Top, Pnt(12)^.Left-Pnt(10)^.Left) / PI);
               if angle >= 360.0 then angle := angle - 360.0;
               Rads := DegToRad(angle);
               cx := (Lng[11] * Cos(Rads));
               cy := (Lng[11] * Sin(Rads));
               if (nSrcIndex <> 8) then
               begin
                  SetPoint( round(Pnt(12)^.Left+cx), round(Pnt(12)^.Top+cy), 10, 12);
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
                  // left hand
                  if (not Pnt(12)^.m_bLocked) then
                  begin
                     UpdatePoint(10,12, 11);
                  end else
                  begin
                     UpdatePoint(12,10, 11);
                  end;
                  //
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
               if (not Pnt(13)^.m_bLocked) then
               begin
                  UpdatePoint(3,13, 12);
               end else
               begin
                  UpdatePoint(13,3, 12);
                  UpdatePoint(3,2, 2);
                  //SetPoint(Pnt(2)^.Left,Pnt(2)^.Top, 2,2);
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
                  if (not Pnt(13)^.m_bLocked) then
                  begin
                     UpdatePoint(3,13, 12);
                  end else
                  begin
                     UpdatePoint(13,3, 12);
                  end;
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
               if (not Pnt(14)^.m_bLocked) then
               begin
                  UpdatePoint(5,14, 13);
               end else
               begin
                  UpdatePoint(14,5, 13);
                  UpdatePoint(5,4, 4);
                  //SetPoint(Pnt(2)^.Left,Pnt(2)^.Top, 2,2);
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
                  if (not Pnt(14)^.m_bLocked) then
                  begin
                     UpdatePoint(5,14, 13);
                  end else
                  begin
                     UpdatePoint(14,5, 13);
                  end;
                  UpdatePoint(1,4, 3);
                  UpdatePoint(4,5, 4);
               end else
               begin
         
               end;
            end;
            if (nIndex = 13) then
            begin
               angle := 180 * (1 + ArcTan2(Pnt(13)^.Top-Pnt(3)^.Top, Pnt(13)^.Left-Pnt(3)^.Left) / PI);
               if angle >= 360.0 then angle := angle - 360.0;
               Rads := DegToRad(angle);
               cx := (Lng[12] * Cos(Rads));
               cy := (Lng[12] * Sin(Rads));
               if (nSrcIndex <> 3) then
               begin
                  SetPoint( round(Pnt(13)^.Left+cx), round(Pnt(13)^.Top+cy), 3, 12);
               end else
               begin

               end;
            end;
            if (nIndex = 14) then
            begin
               angle := 180 * (1 + ArcTan2(Pnt(14)^.Top-Pnt(5)^.Top, Pnt(14)^.Left-Pnt(5)^.Left) / PI);
               if angle >= 360.0 then angle := angle - 360.0;
               Rads := DegToRad(angle);
               cx := (Lng[13] * Cos(Rads));
               cy := (Lng[13] * Sin(Rads));
               if (nSrcIndex <> 5) then
               begin
                  SetPoint( round(Pnt(14)^.Left+cx), round(Pnt(14)^.Top+cy), 5, 13);
               end else
               begin
         
               end;
            end;
   end;
end;

procedure TSpecialStickMan.Move(xAmount, yAmount : integer);
var
   f : integer;
begin
   for f := 1 to 14 do
   begin
      Pnt(f)^.Left := Pnt(f)^.Left + xAmount;
      Pnt(f)^.Top := Pnt(f)^.Top + yAmount;
   end;
end;

procedure rekt(xoffs,yoffs : integer; pCanvas : TpCanvas; x1,y1,x2,y2,width:integer; pcolor,bcolor:tcolor; linewidth:integer; alpha : byte);
var
   angle : double;
   Rads : double;
   cx, cy : double;
   xdiff,ydiff:integer;
   pa : array[0..3] of TPoint;
begin
   begin
      width := width shr 1;
      angle := 180 * (1 + ArcTan2(y1-y2, x1-x2) / PI);
      if angle >= 360.0 then angle := angle - 360.0;
      angle := angle - 90;
      Rads := DegToRad(angle);
      cx := width * Cos(Rads);
      cy := width * Sin(Rads);
      xdiff := x1 - round(x1 - cx);
      ydiff := y1 - round(y1 - cy);
      pa[0].x := xoffs+x1-xdiff;
      pa[0].y := yoffs+y1-ydiff;
      pa[1].x := xoffs+x2-xdiff;
      pa[1].y := yoffs+y2-ydiff;
      pa[2].x := xoffs+x2+xdiff;
      pa[2].y := yoffs+y2+ydiff;
      pa[3].x := xoffs+x1+xdiff;
      pa[3].y := yoffs+y1+ydiff;
      //Polygon(Slice(pa, 4));
      frmMain.DrawPoly2(pa, pcolor, bcolor, alpha, linewidth);
   end;
end;

procedure line(xoffs,yoffs : integer; pCanvas : TpCanvas; x1,y1,x2,y2,width:integer; pcolor,bcolor:tcolor; linewidth:integer; alpha : byte);
begin
   frmMain.DrawLine2(xoffs+x1,yoffs+y1,
                     xoffs+x2,yoffs+y2,
                     pcolor,
                     alpha,
                     linewidth);
end;

procedure TSpecialStickMan.Alpha(amount : single);
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

procedure TSpecialStickMan.Draw(xoffs,yoffs : integer; DrawControlPoints : Boolean);
var
   angle : double;
   Rads : double;
   cx, cy : double;
   nWide, nHigh : integer;
begin

   nWide := 3;
   nHigh := 3;
   begin
      if m_nDrawStyle = 0 then
      begin
        line(xoffs,yoffs, m_pCanvas, Pnt(6)^.Left+nWide, Pnt(6)^.Top+nHigh, Pnt(1)^.Left+nWide, Pnt(1)^.Top+nHigh, Wid[5], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        line(xoffs,yoffs, m_pCanvas, Pnt(1)^.Left+nWide, Pnt(1)^.Top+nHigh, Pnt(2)^.Left+nWide, Pnt(2)^.Top+nHigh, Wid[1], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        line(xoffs,yoffs, m_pCanvas, Pnt(2)^.Left+nWide, Pnt(2)^.Top+nHigh, Pnt(3)^.Left+nWide, Pnt(3)^.Top+nHigh, Wid[2], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        line(xoffs,yoffs, m_pCanvas, Pnt(3)^.Left+nWide, Pnt(3)^.Top+nHigh, Pnt(13)^.Left+nWide, Pnt(13)^.Top+nHigh, Wid[13], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        line(xoffs,yoffs, m_pCanvas, Pnt(1)^.Left+nWide, Pnt(1)^.Top+nHigh, Pnt(4)^.Left+nWide, Pnt(4)^.Top+nHigh, Wid[3], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        line(xoffs,yoffs, m_pCanvas, Pnt(4)^.Left+nWide, Pnt(4)^.Top+nHigh, Pnt(5)^.Left+nWide, Pnt(5)^.Top+nHigh, Wid[4], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        line(xoffs,yoffs, m_pCanvas, Pnt(5)^.Left+nWide, Pnt(5)^.Top+nHigh, Pnt(14)^.Left+nWide, Pnt(14)^.Top+nHigh, Wid[14], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        line(xoffs,yoffs, m_pCanvas, Pnt(6)^.Left+nWide, Pnt(6)^.Top+nHigh, Pnt(7)^.Left+nWide, Pnt(7)^.Top+nHigh, Wid[6], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        line(xoffs,yoffs, m_pCanvas, Pnt(7)^.Left+nWide, Pnt(7)^.Top+nHigh, Pnt(8)^.Left+nWide, Pnt(8)^.Top+nHigh, Wid[7], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        line(xoffs,yoffs, m_pCanvas, Pnt(8)^.Left+nWide, Pnt(8)^.Top+nHigh, Pnt(11)^.Left+nWide, Pnt(11)^.Top+nHigh, Wid[11], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        line(xoffs,yoffs, m_pCanvas, Pnt(6)^.Left+nWide, Pnt(6)^.Top+nHigh, Pnt(9)^.Left+nWide, Pnt(9)^.Top+nHigh, Wid[8], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        line(xoffs,yoffs, m_pCanvas, Pnt(9)^.Left+nWide, Pnt(9)^.Top+nHigh, Pnt(10)^.Left+nWide, Pnt(10)^.Top+nHigh, Wid[9], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        line(xoffs,yoffs, m_pCanvas, Pnt(10)^.Left+nWide, Pnt(10)^.Top+nHigh, Pnt(12)^.Left+nWide, Pnt(12)^.Top+nHigh, Wid[12], m_OutColour, m_InColour, m_nLineWidth, m_alpha);

        angle := 180 * (1 + ArcTan2(Pnt(6)^.Top-Pnt(1)^.Top, Pnt(6)^.Left-Pnt(1)^.Left) / PI);
        if angle >= 360.0 then angle := angle - 360.0;
        angle := angle - 180;
        Rads := DegToRad(angle);
        cx := (m_nHeadDiam div 2) * Cos(Rads);
        cy := (m_nHeadDiam div 2) * Sin(Rads);
        cx := Pnt(6)^.Left+cx;
        cy := Pnt(6)^.Top+cy;
        frmMAin.DrawEllipse(round(xoffs+cx), round(yoffs+cy),
                            m_nHeadDiam, m_nHeadDiam,
                            m_outcolour, m_inColour,
                            m_alpha,
                            m_nLineWidth,
                            0);

        angle := angle - 180;
        Rads := DegToRad(angle);
        cx := cx + (m_nHeadDiam div 2-2) * Cos(Rads);
        cy := cy + (m_nHeadDiam div 2-2) * Sin(Rads);
        frmMain.DrawLine2(xoffs+Pnt(6)^.Left+nWide, yoffs+Pnt(6)^.Top+nHigh,
                          xoffs+round(cx),yoffs+round(cy),
                          m_outColour,
                          m_alpha,
                          m_nLineWidth);
      end;
      if m_nDrawStyle = 1 then
      begin
        line(xoffs,yoffs, m_pCanvas, Pnt(6)^.Left+nWide, Pnt(6)^.Top+nHigh, Pnt(1)^.Left+nWide, Pnt(1)^.Top+nHigh, Wid[5], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        line(xoffs,yoffs, m_pCanvas, Pnt(1)^.Left+nWide, Pnt(1)^.Top+nHigh, Pnt(2)^.Left+nWide, Pnt(2)^.Top+nHigh, Wid[1], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        line(xoffs,yoffs, m_pCanvas, Pnt(2)^.Left+nWide, Pnt(2)^.Top+nHigh, Pnt(3)^.Left+nWide, Pnt(3)^.Top+nHigh, Wid[2], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        line(xoffs,yoffs, m_pCanvas, Pnt(3)^.Left+nWide, Pnt(3)^.Top+nHigh, Pnt(13)^.Left+nWide, Pnt(13)^.Top+nHigh, Wid[13], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        line(xoffs,yoffs, m_pCanvas, Pnt(1)^.Left+nWide, Pnt(1)^.Top+nHigh, Pnt(4)^.Left+nWide, Pnt(4)^.Top+nHigh, Wid[3], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        line(xoffs,yoffs, m_pCanvas, Pnt(4)^.Left+nWide, Pnt(4)^.Top+nHigh, Pnt(5)^.Left+nWide, Pnt(5)^.Top+nHigh, Wid[4], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        line(xoffs,yoffs, m_pCanvas, Pnt(5)^.Left+nWide, Pnt(5)^.Top+nHigh, Pnt(14)^.Left+nWide, Pnt(14)^.Top+nHigh, Wid[14], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        line(xoffs,yoffs, m_pCanvas, Pnt(6)^.Left+nWide, Pnt(6)^.Top+nHigh, Pnt(7)^.Left+nWide, Pnt(7)^.Top+nHigh, Wid[6], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        line(xoffs,yoffs, m_pCanvas, Pnt(7)^.Left+nWide, Pnt(7)^.Top+nHigh, Pnt(8)^.Left+nWide, Pnt(8)^.Top+nHigh, Wid[7], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        line(xoffs,yoffs, m_pCanvas, Pnt(8)^.Left+nWide, Pnt(8)^.Top+nHigh, Pnt(11)^.Left+nWide, Pnt(11)^.Top+nHigh, Wid[11], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        line(xoffs,yoffs, m_pCanvas, Pnt(6)^.Left+nWide, Pnt(6)^.Top+nHigh, Pnt(9)^.Left+nWide, Pnt(9)^.Top+nHigh, Wid[8], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        line(xoffs,yoffs, m_pCanvas, Pnt(9)^.Left+nWide, Pnt(9)^.Top+nHigh, Pnt(10)^.Left+nWide, Pnt(10)^.Top+nHigh, Wid[9], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        line(xoffs,yoffs, m_pCanvas, Pnt(10)^.Left+nWide, Pnt(10)^.Top+nHigh, Pnt(12)^.Left+nWide, Pnt(12)^.Top+nHigh, Wid[12], m_OutColour, m_InColour, m_nLineWidth, m_alpha);

        {m_pCanvas^.Polygon([Point(xoffs+Pnt(1)^.Left+nWide, yoffs+Pnt(1)^.Top+nHigh),
                            Point(xoffs+Pnt(2)^.Left+nWide, yoffs+Pnt(2)^.Top+nHigh),
                            Point(xoffs+Pnt(4)^.Left+nWide, yoffs+Pnt(4)^.Top+nHigh)]);}
        frmMain.DrawPoly2([Point(xoffs+Pnt(1)^.Left+nWide, yoffs+Pnt(1)^.Top+nHigh),
                            Point(xoffs+Pnt(2)^.Left+nWide, yoffs+Pnt(2)^.Top+nHigh),
                            Point(xoffs+Pnt(4)^.Left+nWide, yoffs+Pnt(4)^.Top+nHigh)],
                           m_outColour, m_inColour, m_alpha, m_nLineWidth);

        angle := 180 * (1 + ArcTan2(Pnt(6)^.Top-Pnt(1)^.Top, Pnt(6)^.Left-Pnt(1)^.Left) / PI);
        if angle >= 360.0 then angle := angle - 360.0;
        angle := angle - 180;
        Rads := DegToRad(angle);
        cx := (m_nHeadDiam div 2) * Cos(Rads);
        cy := (m_nHeadDiam div 2) * Sin(Rads);
        cx := Pnt(6)^.Left+cx;
        cy := Pnt(6)^.Top+cy;
        frmMAin.DrawEllipse(round(xoffs+cx), round(yoffs+cy),
                            m_nHeadDiam, m_nHeadDiam,
                            m_outcolour, m_inColour,
                            m_alpha,
                            m_nLineWidth,
                            0);

        angle := angle - 180;
        Rads := DegToRad(angle);
        cx := cx + (m_nHeadDiam div 2-2) * Cos(Rads);
        cy := cy + (m_nHeadDiam div 2-2) * Sin(Rads);
        frmMain.DrawLine2(xoffs+Pnt(6)^.Left+nWide, yoffs+Pnt(6)^.Top+nHigh,
                          xoffs+round(cx),yoffs+round(cy),
                          m_outColour,
                          m_alpha,
                          m_nLineWidth);
      end;
      if m_nDrawStyle = 2 then
      begin
        rekt(xoffs,yoffs, m_pCanvas, Pnt(6)^.Left+nWide, Pnt(6)^.Top+nHigh, Pnt(1)^.Left+nWide, Pnt(1)^.Top+nHigh, Wid[5], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        rekt(xoffs,yoffs, m_pCanvas, Pnt(1)^.Left+nWide, Pnt(1)^.Top+nHigh, Pnt(2)^.Left+nWide, Pnt(2)^.Top+nHigh, Wid[1], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        rekt(xoffs,yoffs, m_pCanvas, Pnt(2)^.Left+nWide, Pnt(2)^.Top+nHigh, Pnt(3)^.Left+nWide, Pnt(3)^.Top+nHigh, Wid[2], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        rekt(xoffs,yoffs, m_pCanvas, Pnt(3)^.Left+nWide, Pnt(3)^.Top+nHigh, Pnt(13)^.Left+nWide, Pnt(13)^.Top+nHigh, Wid[13], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        rekt(xoffs,yoffs, m_pCanvas, Pnt(1)^.Left+nWide, Pnt(1)^.Top+nHigh, Pnt(4)^.Left+nWide, Pnt(4)^.Top+nHigh, Wid[3], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        rekt(xoffs,yoffs, m_pCanvas, Pnt(4)^.Left+nWide, Pnt(4)^.Top+nHigh, Pnt(5)^.Left+nWide, Pnt(5)^.Top+nHigh, Wid[4], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        rekt(xoffs,yoffs, m_pCanvas, Pnt(5)^.Left+nWide, Pnt(5)^.Top+nHigh, Pnt(14)^.Left+nWide, Pnt(14)^.Top+nHigh, Wid[14], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        rekt(xoffs,yoffs, m_pCanvas, Pnt(6)^.Left+nWide, Pnt(6)^.Top+nHigh, Pnt(7)^.Left+nWide, Pnt(7)^.Top+nHigh, Wid[6], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        rekt(xoffs,yoffs, m_pCanvas, Pnt(7)^.Left+nWide, Pnt(7)^.Top+nHigh, Pnt(8)^.Left+nWide, Pnt(8)^.Top+nHigh, Wid[7], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        rekt(xoffs,yoffs, m_pCanvas, Pnt(8)^.Left+nWide, Pnt(8)^.Top+nHigh, Pnt(11)^.Left+nWide, Pnt(11)^.Top+nHigh, Wid[11], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        rekt(xoffs,yoffs, m_pCanvas, Pnt(6)^.Left+nWide, Pnt(6)^.Top+nHigh, Pnt(9)^.Left+nWide, Pnt(9)^.Top+nHigh, Wid[8], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        rekt(xoffs,yoffs, m_pCanvas, Pnt(9)^.Left+nWide, Pnt(9)^.Top+nHigh, Pnt(10)^.Left+nWide, Pnt(10)^.Top+nHigh, Wid[9], m_OutColour, m_InColour, m_nLineWidth, m_alpha);
        rekt(xoffs,yoffs, m_pCanvas, Pnt(10)^.Left+nWide, Pnt(10)^.Top+nHigh, Pnt(12)^.Left+nWide, Pnt(12)^.Top+nHigh, Wid[12], m_OutColour, m_InColour, m_nLineWidth, m_alpha);

        angle := 180 * (1 + ArcTan2(Pnt(6)^.Top-Pnt(1)^.Top, Pnt(6)^.Left-Pnt(1)^.Left) / PI);
        if angle >= 360.0 then angle := angle - 360.0;
        angle := angle - 180;
        Rads := DegToRad(angle);
        cx := (m_nHeadDiam div 2) * Cos(Rads);
        cy := (m_nHeadDiam div 2) * Sin(Rads);
        cx := Pnt(6)^.Left+cx;
        cy := Pnt(6)^.Top+cy;
        frmMAin.DrawEllipse(round(xoffs+cx), round(yoffs+cy),
                            m_nHeadDiam, m_nHeadDiam,
                            m_outcolour, m_inColour,
                            m_alpha,
                            m_nLineWidth,
                            0);

        angle := angle - 180;
        Rads := DegToRad(angle);
        cx := cx + (m_nHeadDiam div 2-2) * Cos(Rads);
        cy := cy + (m_nHeadDiam div 2-2) * Sin(Rads);
        frmMain.DrawLine2(xoffs+Pnt(6)^.Left+nWide, yoffs+Pnt(6)^.Top+nHigh,
                          xoffs+round(cx),yoffs+round(cy),
                          m_outColour,
                          m_alpha,
                          m_nLineWidth);
      end;
   end;

end;


constructor TSoundObj.Create(AOwner : TWinControl; strFileName : string);
begin
   m_strFileName := strFileName;
//   m_CHANNEL := nil;
   Pnt := TLabel.Create(nil);
   With Pnt do
   begin
       Parent := AOwner;
       Caption := '.';
       Width := 10;
       Height := 10;
       OnMouseDown := MouseDown;
       OnMouseMove := MouseMove;
       OnMouseUp := MouseUp;
   end;
   Pnt.Color := clGreen;
   Pnt.Left := frmCanvas.ClientWidth div 2 - 5;
   Pnt.Top := frmCanvas.ClientHeight div 2 - 5;
end;

destructor TSoundObj.Destroy;
begin
   Pnt.Free;
   Pnt := nil;
   {if (m_CHANNEL <> nil) then
   begin
      m_CHANNEL.Free;
      m_CHANNEL := nil;
   end;}
   inherited Destroy;
end;

procedure TSoundObj.Assign(source : TSoundObjPtr);
begin
   ShowMessage('Nothing done');
end;

procedure TSoundObj.MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if ssLeft in Shift then
   begin
      m_bMoving := TRUE;
      m_nX := X;
      m_nY := Y;
   end;
end;

procedure TSoundObj.MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
   xdiff, ydiff : integer;
begin
   frmToolBar.lblXPos.Caption := 'X Pos: ' + inttostr(TLabel(Sender).Left+TLabel(Sender).Width div 2);
   frmToolBar.lblYPos.Caption := 'Y Pos: ' + inttostr(TLabel(Sender).Left+TLabel(Sender).Height div 2);
   if (m_bMoving) then
   begin
      with Sender as TLabel do
      begin
         xdiff := X - m_nX;
         ydiff := Y - m_nY;
         SetPoint(Left + xDiff, Top + yDiff, Tag);
      end;
   end;
end;

procedure TSoundObj.MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := FALSE;
end;

procedure TSoundObj.SetPoint(x, y, nIndex : integer);
begin
   Pnt.Left := x;
   Pnt.Top := y;
   frmMain.Render(frmMain.m_col, TRUE);
end;

procedure TSoundObj.Move(xAmount, yAmount : integer);
begin
   Pnt.Left := Pnt.Left + xAmount;
   Pnt.Top := Pnt.Top + yAmount;
end;

procedure TSoundObj.SetVisible(newVal : Boolean);
begin
   Pnt.Visible := newVal;
end;

procedure TSoundObj.Draw(DrawControlPoints : boolean);
var
   nVol, nPan : integer;
begin
      (*if (DrawControlPoints) then
      //if not frmMain.m_bPlaying then
      begin
         frmMain.m_Canvas.Pen.Width := 1;
         frmMain.m_Canvas.Pen.Color := clBlue;
         frmMain.m_Canvas.Brush.Color := clRed;
         frmMain.m_Canvas.Ellipse(Pnt.Left-15,Pnt.Top-15,Pnt.Left+5,Pnt.Top+5);
         nVol := round(-10000 * (Pnt.Top / frmCanvas.ClientHeight));
         nPan := -10000 + round(10000*(Pnt.Left / (frmCanvas.ClientWidth/2)));
         frmMain.m_Canvas.Font.Color := clBlack;
         frmMAin.m_Canvas.Brush.Color := clWhite;
         frmMain.m_Canvas.Pen.Color := clWhite;
         nVol := round(100-(Pnt.Top / frmCanvas.ClientHeight));
         frmMain.m_Canvas.TextOut(2,2, 'Volume: ' + inttostr(nVol));
         frmMain.m_Canvas.TextOut(2,16, 'Pan: ' + inttostr(nPan));
      end;  *)
end;

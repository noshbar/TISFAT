constructor TSingleFrame.Create;
begin
   inherited;
   m_Frames := TList.Create;
end;

destructor TSingleFrame.Destroy;
var
   f : integer;
   pIFrame : TIFramePtr;
begin
   for f := 0 to m_Frames.Count-1 do
   begin
      pIFrame := m_Frames.Items[f];
      pIFrame^.Free;
      Dispose(pIFrame);
   end;
   m_Frames.Free;
   inherited destroy;
end;

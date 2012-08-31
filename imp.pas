/////////////////// FRAMELIST /////////////////

constructor TFrameObj.Create;
begin
   m_olObjects := TList.Create;
   m_nFrameNo := 0;
end;

destructor TFrameObj.Destroy;
begin
   m_olObjects.Destroy;
   inherited Destroy;
end;

/////////////////// LAYERLIST /////////////////

constructor TLayerList.Create;
begin
   m_olFrames := TList.Create;
   m_strName := 'Untitled';
end;

destructor TLayerList.Destroy;
var
   f : integer;
   pItem : TFrameObjPtr;
begin
   for f := 0 to m_olFrames.Count-1 do
   begin
      pItem := m_olFrames.Items[f];
      pItem^.Destroy;
      Dispose(pItem);
   end;
   m_olFrames.Destroy;
   inherited Destroy;
end;

function TLayerList.AddNewFrame(nFrameNo : integer) : TFrameObjPtr;
var
   pNew, pItem : TFrameObjPtr;
   f, g : integer;
begin
   New(pNew);
   pNew^ := TFrameObj.Create;
   pNew^.m_nFrameNo := nFrameNo;
   for f := 0 to m_olFrames.Count-1 do
   begin
      pItem := m_olFrames.Items[f];
      if (f = m_olFrames.Count-1) then
      begin
         m_olFrames.Add(pNew);
         exit;
      end else
      if (pNew^.m_nFrameNo = pItem^.m_nFrameNo) then
      begin
         m_olFrames.Insert(f, pItem);
      end else
      if (pNew^.m_nFrameNo > pItem^.m_nFrameNo) then
      begin
         pItem := m_olFrames.Items[f+1];
         if (pNew^.m_nFrameNo
      end;
   end;
end;


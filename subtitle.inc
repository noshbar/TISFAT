constructor TSubtitleObj.Create(strCaption : string);
begin
   m_strCaption := strCaption;
end;

destructor TSubtitleObj.Destroy;
begin
   inherited destroy;
end;

procedure TSubtitleObj.Assign(source : TSubtitleObjPtr);
begin
   m_strCaption := source^.m_strCaption;
end;

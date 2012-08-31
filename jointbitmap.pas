unit jointbitmap;

interface

uses classes, GDIPAPI, GDIPOBJ;

type
   TJointBitmap = class(TObject)
      public
         ms : TMemoryStream;
         bitmap : TGPBitmap;
         name : string;

         constructor Create;  overload;
         constructor Create(fs : TFileStream);  overload;
         constructor Create(f : string);  overload;
         constructor Create(b : TJointBitmap);  overload;
         destructor Destroy;

         procedure CopyPropsFrom(Source : TJointBitmap);

         procedure Load(fs : TFileStream);
         procedure Save(fs : TFileStream);
   end;

implementation

uses fixedstreamadapter, GDIPUTIL, sysUtils;

constructor TJointBitmap.Create;
begin
end;

constructor TJointBitmap.Create(fs : TFileStream);
begin
   if (fs <> nil) then
      Load(fs);
end;

constructor TJointBitmap.Create(b : TJointBitmap);
var
   c : TGPGraphics;
begin
   name := b.name;
   {ms := TMemoryStream.Create;
   ms.CopyFrom(b.ms, b.ms.size);
   ms.Position := 0;}
   bitmap := TGPBitmap.Create(b.bitmap.getwidth, b.bitmap.getheight);
   c := TGPGraphics.Create(bitmap);
   c.DrawImage(b.bitmap, 0,0);
   c.Free;
//   bitmap := TGPBitmap.Create(TFixedStreamAdapter.Create(ms{, soOwned = crash!}));
end;

constructor TJointBitmap.Create(f : string);
var
   fs : TFileStream;
   i : integer;
begin
   if (not fileexists(f)) then
      exit;

   name := extractfilename(f);
   fs := TFileStream.Create(f, fmOpenRead);
   ms.Free;
   ms := TMemoryStream.Create;
   ms.CopyFrom(fs, fs.Size);
   fs.Free;
   ms.Position := 0;
   bitmap := TGPBitmap.Create(TFixedStreamAdapter.Create(ms{, soOwned = crash!}));
end;

destructor TJointBitmap.Destroy;
begin
   ms.Free;
   bitmap.Free;
end;

procedure TJointBitmap.Load(fs : TFileStream);
var
   l : integer;
   n : string[255];
begin
      fs.Read(l, sizeof(l));
      fs.Read(n, l);
      name := n;

   fs.Read(l, sizeof(l));
   ms.Free;
   ms := TMemoryStream.Create;
   ms.CopyFrom(fs, l);
   ms.Position := 0;
   bitmap.free;
   bitmap := TGPBitmap.Create(TFixedStreamAdapter.Create(ms{, soOwned = crash!}));
end;

procedure TJointBitmap.Save(fs : TFileStream);
var
  id: TGUID;
  ms2 : TMemoryStream;
  l : integer;
  s : string[255];
begin
      l := length(Name)+1;
      fs.Write(l, sizeof(l));
      s := name;
      fs.WriteBuffer(s, l);
      {l := length(Name)+1;
      fs.Write(l, sizeof(l));
      fs.Write(name, l); }

  GetEncoderClsid('image/png', id);

  ms2 := TMemoryStream.Create;
  bitmap.Save(TStreamAdapter.Create(ms2), id);

  l := ms2.Size;
  fs.Write(l, sizeof(l));

  ms2.SaveToStream(fs);
  ms2.Free;
end;

procedure TJointBitmap.CopyPropsFrom(Source : TJointBitmap);
begin
   Name := Source.Name;
end;

end.

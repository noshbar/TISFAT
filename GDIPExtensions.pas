{*****************************************************************************}
{                                                                             }
{    GDI + Controls                                                           }
{      http://lummie.co.uk                                                    }
{        Version: 1.0.3                                                       }
{                                                                             }
{    Copyright (c) 2005 Matt harrison (http://www.lummie.co.uk)               }
{                                                                             }
{*****************************************************************************}
unit GDIPExtensions;

interface

uses
  GDIPOBJ, GDIPAPI, GDIPUtil, sysutils, math, controls, windows, graphics;

type
  TResizeOption = (roSourceIsMax, roCenterVertical, roCenterHorizontal);
  TresizeOptions = set of TResizeOption;
  TFadeDirection = (fdUp, fdDown, fdLeft, fdRight);
  TFadeType = (ftLinear);
  EImageProcessError = exception;

function MaintainAspect(Source : TGPRect; Dest : TGPRect; var Zoom : double; Options : TResizeOptions = []) : TGPRect;
procedure PaintParentToDC(AControl : TWinControl; DC: HDC; ARect : TRect; PerformErase : boolean = true);

function MakeRect(ARect : TGPRect): TGPRectF; overload;
function MakeRect(ARect : TGPRectF): TGPRect; overload;

function GPColorToTColor(ACol : TGPColor) : TColor;

function ColorAsHTML(AColor: TGPColor; ShowAlpha : boolean = false): widestring;

function SplitAlpha(Source : TGPBitmap; var Bitmap : TGPBitmap; var Mask : TGPBitmap) : boolean;
function CombineImageMask(Bitmap : TGPBitmap; Mask : TGPBitmap; var AlphaRGBImage : TGPBitmap) : boolean;

function FadeOut(Image : TGPBitmap; ARect :TGPRect; Direction : TFadeDirection; FadeType : TFadeType) : boolean;


implementation

uses
  messages, types;

type
  TParentControl = class (TWinControl);

function ColorAsHTML(AColor: TGPColor; ShowAlpha : boolean = false): widestring;
begin
  result :='#' + IntToHex(AColor and $FFFFFF,6);
  if ShowAlpha then result := result + ' Alpha:#' + IntToHex((AColor shr 24) and $FF,2);
end;

function MakeRect(ARect : TGPRect): TGPRectF;
begin
  result.X := ARect.X;
  result.Y := ARect.Y;
  result.Width := ARect.Width;
  result.height := ARect.height;
end;

function MakeRect(ARect : TGPRectF): TGPRect;
begin
  result.X := trunc(ARect.X);
  result.Y := trunc(ARect.Y);
  result.Width := trunc(ARect.Width);
  result.height := trunc(ARect.height);
end;

function GPColorToTColor(ACol : TGPColor) : TColor;
var
  Temp : Cardinal;
begin
  Temp := 0;
  Temp := Temp or (ACol and $FF);
  ACol := ACol shr 8;
  Temp := Temp shl 8;
  Temp := Temp or (ACol and $FF);
  ACol := ACol shr 8;
  Temp := Temp shl 8;
  Temp := Temp or (ACol and $FF);
  result := Temp;
end;


procedure PaintParentToDC(AControl : TWinControl; DC: HDC; ARect : TRect; PerformErase : boolean = true);
var
  I, Count, X, Y, SaveIndex: integer;
  R, SelfR, CtlR: TRect;
  Control : TWinControl;
begin
  Control := AControl;
  if Control.Parent = nil then Exit;
  if not TWinControl(Control).HandleAllocated then exit;

  Count := Control.Parent.ControlCount;

  SelfR := ARect;
  X := -Control.left; Y := -Control.Top;

  // Copy parent control image
  SaveIndex := SaveDC(DC);
  SetViewportOrgEx(DC, X, Y, nil);
  IntersectClipRect(DC, 0, 0, Control.Parent.ClientWidth, Control.Parent.ClientHeight);
  if PerformErase then TParentControl(Control.Parent).Perform(WM_ERASEBKGND,DC,0);
  TParentControl(Control.Parent).PaintWindow(DC);
  RestoreDC(DC, SaveIndex);

  //Copy images of graphic controls
  for I := 0 to Count - 1 do begin
    if (Control.Parent.Controls[I] <> nil) {and (Control.Parent.Controls[I] is TGraphicControl) }then
    begin
      if Control.Parent.Controls[I] = Control then break;

      with Control.Parent.Controls[I] do
      begin
        CtlR := Bounds(Left, Top, Width, Height);
        if Bool(IntersectRect(R, SelfR, CtlR)) and Visible then
        begin
          SaveIndex := SaveDC(DC);
          SetViewportOrgEx(DC, left + X, Top + Y, nil);
          IntersectClipRect(DC, 0, 0, Width, Height);
          Perform(WM_ERASEBKGND,DC,0);
          Perform(WM_PAINT, integer(DC), 0);
          RestoreDC(DC, SaveIndex);
        end;
      end;
    end;
  end;
end;


function MaintainAspect(Source : TGPRect; Dest : TGPRect; var Zoom : double; Options : TResizeOptions = []) : TGPRect;
var
  New : integer;
  AWidth, AHeight : integer;
begin
  result := dest;
  if (source.width = 0) or (source.height = 0) then exit;

  AWidth := dest.Width;
  AHeight := dest.height;

  if roSourceIsMax in options then
  begin
    AWidth := min(dest.width,source.width);
    AHeight := min(dest.height,source.height);
  end;

  zoom := AWidth / source.width;
  New := round(source.Height * zoom);
  if New <= AHeight then
  begin
    result.Height := New;
    result.Width := AWidth;
  end
  else
  begin
    zoom := AHeight / source.Height;
    New := round(source.width * zoom);
    result.width := New;
    result.Height := AHeight;
  end;

  if roCenterVertical in options then
  begin
    if result.height < dest.height then
      result.y := dest.y + ((dest.height - result.height) div 2);
  end;

  if roCenterHorizontal in options then
  begin
    if result.Width < dest.Width then
      result.X := dest.X + ((dest.Width - result.width) div 2);
  end;
end;

function SplitAlpha(Source : TGPBitmap; var Bitmap : TGPBitmap; var Mask : TGPBitmap) : boolean;
  Procedure SetGrayScale(palette : PColorPalette);
  var
    i : integer;
  begin
    for i := 0 to Palette.Count -1 do
    begin
      palette.Entries[i] := MakeColor(i,i,i);
    end;
  end;

var
  SourcePixelFormat : PixelFormat;
  w,h : cardinal;
  x,y : cardinal;
  sbmd : TBitmapData;
  bbmd : TBitmapData;
  mbmd : TBitmapData;
  r : TGPRect;
  sImageStart : PByteArray;
  spixelpos : integer;
  sPixel : pARGB;
  bImageStart : PByteArray;
  bpixelpos : integer;
  bPixel : PRGBTriple;
  mImageStart : PByteArray;
  mpixelpos : integer;
  mPixel : pByte;
  Palette : pColorPalette;
  PaletteSize : cardinal;
begin
  Bitmap := nil;
  Mask := nil;

  if not assigned(Source) then raise EImageProcessError.create('No sourceimage assigned');
  if (source.GetWidth = 0) or (source.GetHeight = 0) then raise EImageProcessError.create('Height and width of source image must be greater than zero');

  SourcePixelFormat := source.GetPixelFormat;
  if not IsAlphaPixelFormat(SourcePixelFormat) then raise EImageProcessError.create('Source image does not have alpha channel');

  w := Source.GetWidth;
  h := source.GetHeight;


  Bitmap := TGPBitmap.Create(w,h,PixelFormat32bppRGB);
  Mask := TGPBitmap.Create(w,h,PixelFormat8bppIndexed);

  PaletteSize := mask.GetPaletteSize;
  Palette := AllocMem(PaletteSize);
  mask.GetPalette(Palette,PaletteSize);
  SetGrayScale(Palette);
  mask.SetPalette(Palette);
  FreeMem(Palette,PaletteSize);

  r := MakeRect(0,0,integer(w),integer(h));
  source.LockBits(r, ImageLockModeRead, PixelFormat32bppARGB, sbmd);
  bitmap.LockBits(r, ImageLockModeWrite, PixelFormat32bppRGB, bbmd);
  mask.LockBits(r, ImageLockModeWrite, PixelFormat8bppIndexed, mbmd);

  sImageStart := sbmd.Scan0;
  bImageStart := bbmd.Scan0;
  mImageStart := mbmd.Scan0;
  for y := 0 to sbmd.Height-1 do
  begin
    for x := 0 to sbmd.Width-1 do
    begin
      spixelpos := (y * cardinal(sbmd.Stride)) + (x * 4);
      sPixel := @sImageStart[sPixelPos];

      bpixelpos := (y * cardinal(bbmd.Stride)) + (x * 4);
      bPixel := @bImageStart[bPixelPos];

      mpixelpos := (y * cardinal(mbmd.Stride)) + (x);
      mPixel := @mImageStart[mPixelPos];

      bPixel.rgbtRed := (spixel^ and $FF0000) shr 16;
      bPixel.rgbtGreen := (spixel^ and $00FF00) shr 8;
      bPixel.rgbtBlue := (spixel^ and $0000FF);
      mpixel^ := (spixel^ and ALPHA_MASK) shr ALPHA_SHIFT;
    end;
  end;
  source.UnlockBits(sbmd);
  bitmap.UnlockBits(bbmd);
  mask.UnlockBits(mbmd);
  result := true;
end;

function CombineImageMask(Bitmap : TGPBitmap; Mask : TGPBitmap; var AlphaRGBImage : TGPBitmap) : boolean;
var
  w,h : cardinal;
  x,y : cardinal;
  obmd : TBitmapData;
  bbmd : TBitmapData;
  mbmd : TBitmapData;
  r : TGPRect;
  oImageStart : PByteArray;
  opixelpos : integer;
  oPixel : pARGB;
  bImageStart : PByteArray;
  bpixelpos : integer;
  bPixel : pARGB;
  mImageStart : PByteArray;
  mpixelpos : integer;
  mPixel : pARGB;
  alphalevel : cardinal;
begin
  AlphaRGBImage := nil;

  if not assigned(Bitmap) then raise EImageProcessError.create('No Bitmap assigned');
  if not assigned(Mask) then raise EImageProcessError.create('No Mask assigned');
  if (Bitmap.GetWidth = 0) or (Bitmap.GetHeight = 0) then raise EImageProcessError.create('Height and width of image must be greater than zero');
  if (Bitmap.GetWidth <> Mask.GetWidth) or (Bitmap.GetHeight <> Mask.GetWidth) then raise EImageProcessError.create('The hieght and width of both the image and mask should be the same');

  w := Bitmap.GetWidth;
  h := Bitmap.GetHeight;

  AlphaRGBImage := TGPBitmap.Create(w,h,PixelFormat32bppARGB);

  r := MakeRect(0,0,integer(w),integer(h));
  bitmap.LockBits(r, ImageLockModeRead, PixelFormat32bppRGB, bbmd);
  mask.LockBits(r, ImageLockModeRead, PixelFormat32bppRGB, mbmd);
  AlphaRGBImage.LockBits(r, ImageLockModeWrite, PixelFormat32bppARGB, obmd);

  bImageStart := bbmd.Scan0;
  mImageStart := mbmd.Scan0;
  oImageStart := obmd.Scan0;

  for y := 0 to obmd.Height-1 do
  begin
    for x := 0 to obmd.Width-1 do
    begin
      opixelpos := (y * cardinal(obmd.Stride)) + (x * 4);
      oPixel := @oImageStart[oPixelPos];

      bpixelpos := (y * cardinal(bbmd.Stride)) + (x * 4);
      bPixel := @bImageStart[bPixelPos];

      mpixelpos := (y * cardinal(mbmd.Stride)) + (x * 4);
      mPixel := @mImageStart[mPixelPos];

      oPixel^ := bPixel^ and not ALPHA_MASK; // copy rgb across
      alphalevel := (
                      ((mpixel^ and $FF0000) shr 16) +
                      ((mpixel^ and $00FF00) shr 8) +
                      (mpixel^ and $0000FF)) div 3;
      oPixel^ := ((alphalevel and $FF) shl ALPHA_SHIFT) or oPixel^;
    end;
  end;
  AlphaRGBImage.UnlockBits(obmd);
  bitmap.UnlockBits(bbmd);
  mask.UnlockBits(mbmd);
  result := true;
end;

function FadeOut(Image : TGPBitmap; ARect :TGPRect; Direction : TFadeDirection; FadeType : TFadeType) : boolean;
var
  x,y : integer;
  bmd : TBitmapData;
  ImageStart : integer;
  pixelpos : integer;
  Pixel : pARGB;
  AlphaChange : Double;
  CurrentAlpha, NewAlpha : Cardinal;
begin
  if not assigned(Image) then raise EImageProcessError.create('No Image assigned');
  if (Image.GetWidth = 0) or (Image.GetHeight = 0) then raise EImageProcessError.create('Height and width of image must be greater than zero');
  if (Arect.Width = 0) or (ARect.Height = 0) then raise EImageProcessError.create('Height and width of Rectangle must be greater than zero');

  Image.LockBits(Arect, ImageLockModeWrite, PixelFormat32bppARGB, bmd);

  assert(bmd.PixelFormat = PixelFormat32bppARGB);

  ImageStart := integer(bmd.Scan0);
  for y := 0 to bmd.Height  do
  begin
    AlphaChange := 1;
    case FadeType of
      ftLinear : begin
        case Direction of
          fdDown : AlphaChange := 1-(y + 1) / ARect.Height;
          fdUp : AlphaChange := (y  + 1) / ARect.Height;
        end;
      end;
    end;

    for x := 0 to bmd.Width  do
    begin
      case FadeType of
        ftLinear : begin
          case Direction of
            fdLeft : AlphaChange := (x + 1) / ARect.Width;
            fdRight : AlphaChange := 1-(x + 1) / ARect.Width;
          end;
        end;
      end;
      Pixel := pARGB(ptr(ImageStart + (y * bmd.stride) +(x*4)));
      CurrentAlpha := (Pixel^ and ALPHA_MASK) shr ALPHA_SHIFT;
      NewAlpha := trunc(CurrentAlpha * AlphaChange);

      Pixel^ := (NewAlpha shl ALPHA_SHIFT) or (Pixel^ and not ALPHA_MASK);
    end;
  end;
  Image.UnlockBits(bmd);
  result := true;
end;



end.

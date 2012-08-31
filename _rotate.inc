type RealType = Single;
type AngleType= RealType;
//specify the format we want for Points
type PointType = TPoint;
type CoordType = Integer;
//a structure to hold sine,cosine,distance (faster than angle)
type SiCoDiType=
  record
	 si, co, di:RealType; {sine, cosine, distance 6/29/98}
  end;

//reduce angle to 0..360
function mod360( const angle:AngleType ):AngleType;
begin
	RESULT := FRAC( angle/360 )*360;
	if RESULT<0 then RESULT := RESULT+360;
end;

{	Calculate sine/cosine/distance from INTEGER coordinates}
function SiCoDiPoint ( const p1, p2: PointType ): SiCoDiType; {out}
{	This is MUCH faster than using angle functions such as arctangent}
{11.96    Jim Hargis  original SiCoDi for rotations.
{11/22/96 modified for Zero length check, and replace SiCodi}
{6/14/98  modified  for Delphi}
{6/29/98  renamed from SiCo point}
{8/3/98	  set Zero angle for Zero length line}
{10/24/99 use hypot from math.pas}
	var
		dx, dy: CoordType;
	begin
		dx := ( p2.x - p1.x ); 	dy := ( p2.y - p1.y ); 
		with RESULT do
			begin
				di := HYPOT( dx, dy ); //10/24/99 	di := Sqrt( dx * dx + dy * dy );
				if abs( di )<1
          then begin si := 0.0; co := 1.0 end//Zero length line
					else begin si := dy/di; co := dx/di end;
			end;
	end;

// read time stamp in CPU Cycles for Pentium
function RDTSC: Int64;
asm
  DB 0FH, 31H   //allows out-of-sequence execution, caching
end;

PROCEDURE RotateBitmap(
		const BitmapOriginal:TBitMap;//input bitmap (possibly converted)
		out   BitMapRotated:TBitMap; //output bitmap
		const theta:real;  // rotn angle in radians counterclockwise in windows
		const oldAxis:TPOINT; 	// center of rotation in pixels, rel to bmp origin
		var   newAxis:TPOINT);  // center of rotated bitmap, relative to bmp origin
   VAR
		cosTheta       :  Single;   {in windows}
		sinTheta       :  Single;
		i              :  INTEGER;
		iOriginal      :  INTEGER;
		iRotationAxis  :  INTEGER;// Axis of rotation is normally center of image
		iPrime         :  INTEGER;
//		iPrimeRotated  :  INTEGER; use width if doubled
		j              :  INTEGER;
		jOriginal      :  INTEGER;
		jRotationAxis  :  INTEGER;
		jPrime         :  INTEGER;
//		jPrimeRotated  :  INTEGER; use height if doubled
		NewWidth,NewHeight:INTEGER;
		nBytes, nBits: Integer;//no. bytes per pixelformat
		Oht,Owi,Rht,Rwi: Integer;//Original and Rotated subscripts to bottom/right
//The variant pixel formats for subscripting       1/6/00
	type // from Delphi
		TRGBTripleArray = array [0..32767] of TRGBTriple; //allow integer subscript
		pRGBTripleArray = ^TRGBTripleArray;
		TRGBQuadArray = array [0..32767]  of TRGBQuad;//allow integer subscript
		pRGBQuadArray = ^TRGBQuadArray;
	var //each of the following points to the same scanlines
		RowRotatedB: pByteArray; 			//1 byte
		RowRotatedW: pWordArray;  		//2 bytes
		RowRotatedT: pRGBtripleArray;	//3 bytes
		RowRotatedQ: pRGBquadArray;  	//4 bytes
	var //a single pixel for each format 	1/8/00
		TransparentB: Byte;
		TransparentW: Word;
		TransparentT: TRGBTriple;
		TransparentQ: TRGBQuad;
  var
    DIB: TDIBSection;//10/31/00
    Center:  TPOINT; //the middle of the bmp relative to bmp origin.
    SiCoPhi: SiCoDiType;//sine,cosine, distance
{=======================================}
begin

with BitMapOriginal do begin

//Decipher the appropriate pixelformat to use Delphi byte subscripting 1/6/00
//pfDevice, pf1bit, pf4bit, pf8bit, pf15bit, pf16bit, pf24bit, pf32bit,pfCustom;
		case pixelformat of
      pfDevice: begin //handle only pixelbits= 1..8,16,24,32 //10/31/00
        nbits :=  GetDeviceCaps( Canvas.Handle,BITSPIXEL )+1 ;
        nbytes := nbits div 8; //no. bytes for bits per pixel
        if (nbytes>0)and(nbits mod 8 <> 0) then exit;//ignore if invalid
        end;
			pf1bit:  nBytes:=0;// 1bit, TByteArray      //2 color pallete , re-assign byte value to 8 pixels, for entire scan line
			pf4bit:	 nBytes:=0;// 4bit, PByteArray     // 16 color pallette; build nibble for pixel pallette index; convert to 8 pixels
			pf8bit:  nBytes:=1;// 8bit, PByteArray     // byte pallette, 253 out of 256 colors; depends on display mode, needs truecolor ;
			pf15bit: nBytes:=2;// 15bit,PWordArrayType // 0rrrrr ggggg bbbbb  0+5+5+5
			pf16bit: nBytes:=2;// 16bit,PWordArrayType // rrrrr gggggg bbbbb  5+6+5
			pf24bit: nBytes:=3;// 24bit,pRGBtripleArray// bbbbbbbb gggggggg rrrrrrrr  8+8+8
			pf32bit: nBytes:=4;// 32bit,pRGBquadArray  // bbbbbbbb gggggggg rrrrrrrr aaaaaaaa 8+8+8+alpha
											   // can assign 'Single' reals to this for generating displays/plasma!
      pfCustom: begin  //handle only pixelbits= 1..8,16,24,32  //10/31/00
          GetObject( Handle, SizeOf(DIB), @DIB );
          nbits := DIB.dsBmih.biSizeImage;
          nbytes := nbits div 8;
          if (nbytes>0)and(nbits mod 8 <> 0) then exit;//ignore if invalid
        end;// pfcustom

			else exit;// 10/31/00 ignore invalid formats
		end;// case

// BitmapRotated.PixelFormat is the same as BitmapOriginal.PixelFormat;
// IF PixelFormat is less than 8 bit, then BitMapOriginal.PixelFormat = pf8Bit,
//  because Delphi can't index to bits, just bytes;
// The next time BitMapOriginal is used it will already be converted.
//( bmp storage may increase by factor of n*n, where n=8/(no. bits per pixel)  )
	if nBytes=0 then PixelFormat := pf8bit; //note that input bmp is changed

//assign copies all properties, including pallette and transparency   11/7/00
//fix bug 1/30/00 where BitMapOriginal was overwritten bec. pointer was copied
  BitmapRotated.Assign( BitMapOriginal);

//COUNTERCLOCKWISE rotation angle in radians. 12/10/99
	 sinTheta := SIN( theta ); cosTheta := COS( theta );
//SINCOS( theta, sinTheta, cosTheta ) ; math.pas requires extended reals.

//calculate the enclosing rectangle  12/15/00
	NewWidth  := ABS( ROUND( Height*sinTheta) ) + ABS( ROUND( Width*cosTheta ) );
	NewHeight := ABS( ROUND( Width*sinTheta ) ) + ABS( ROUND( Height*cosTheta) );

//diff size bitmaps have diff resolution of angle, ie r*sin(theta)<1 pixel
//use the small angle approx: sin(theta) ~~ theta   //11/7/00
  if ( ABS(theta)*MAX( width,height ) ) > 1 then
  begin//non-zero rotation

//set output bitmap formats; we do not assume a fixed format or size 1/6/00
	BitmapRotated.Width  := NewWidth;   //resize it for rotation
	BitmapRotated.Height := NewHeight;
//center of rotation is center of bitmap
  iRotationAxis := width div 2;
  jRotationAxis := height div 2;

//local constants for loop, each was hit at least width*height times   1/8/00
	Rwi := NewWidth - 1; //right column index
	Rht := NewHeight - 1;//bottom row index
	Owi := Width - 1;    //transp color column index
	Oht := Height - 1;   //transp color row  index

//Transparent pixel color used for out of range pixels 1/8/00
//how to translate a Bitmap.TransparentColor=Canvas.Pixels[0, Height - 1];
// from Tcolor into pixelformat..
	case nBytes of
		0,1:TransparentB := PByteArray     ( Scanline[ Oht ] )[0];
		2:	TransparentW := PWordArray     ( Scanline[ Oht ] )[0];
		3:	TransparentT := pRGBtripleArray( Scanline[ Oht ] )[0];
		4:	TransparentQ := pRGBquadArray  ( Scanline[ Oht ] )[0];
	end;//case *)

// Step through each row of rotated image.
	FOR j := Rht DOWNTO 0 DO   //1/8/00
	BEGIN //for j

		case nBytes of  //1/6/00
		0,1:RowRotatedB := BitmapRotated.Scanline[ j ] ;
		2:	RowRotatedW := BitmapRotated.Scanline[ j ] ;
		3:	RowRotatedT := BitmapRotated.Scanline[ j ] ;
		4:	RowRotatedQ := BitmapRotated.Scanline[ j ] ;
		end;//case

	// offset origin by the growth factor     //12/25/99
	//	jPrime := 2*(j - (NewHeight - Height) div 2 - jRotationAxis) + 1 ;
		jPrime := 2*j - NewHeight + 1 ;

	// Step through each column of rotated image
		FOR i := Rwi DOWNTO 0 DO   //1/8/00
		BEGIN //for i

			// offset origin by the growth factor  //12/25/99
			//iPrime := 2*(i - (NewWidth - Width) div 2 - iRotationAxis ) + 1;
      iPrime := 2*i - NewWidth   + 1;

			// Rotate (iPrime, jPrime) to location of desired pixel	(iPrimeRotated,jPrimeRotated)
			// Transform back to pixel coordinates of image, including translation
			// of origin from axis of rotation to origin of image.
//iOriginal := ( ROUND( iPrime*CosTheta - jPrime*sinTheta ) - 1) DIV 2 + iRotationAxis;
//jOriginal := ( ROUND( iPrime*sinTheta + jPrime*cosTheta ) - 1) DIV 2 + jRotationAxis;
			iOriginal := ( ROUND( iPrime*CosTheta - jPrime*sinTheta ) -1 + width ) DIV 2;
			jOriginal := ( ROUND( iPrime*sinTheta + jPrime*cosTheta ) -1 + height) DIV 2 ;

			// Make sure (iOriginal, jOriginal) is in BitmapOriginal.  If not,
			// assign background color to corner points.
			IF   ( iOriginal >= 0 ) AND ( iOriginal <= Owi ) AND
					 ( jOriginal >= 0 ) AND ( jOriginal <= Oht )    //1/8/00
			THEN BEGIN //inside
				// Assign pixel from rotated space to current pixel in BitmapRotated
				//( nearest neighbor interpolation)
				case nBytes of  //get pixel bytes according to pixel format   1/6/00
				0,1:RowRotatedB[i] := pByteArray(      scanline[joriginal] )[iOriginal];
				2:	RowRotatedW[i] := pWordArray(      Scanline[jOriginal] )[iOriginal];
				3:	RowRotatedT[i] := pRGBtripleArray( Scanline[jOriginal] )[iOriginal];
				4:	RowRotatedQ[i] := pRGBquadArray(   Scanline[jOriginal] )[iOriginal];
				end;//case
			END //inside
			ELSE	BEGIN //outside

//12/10/99 set background corner color to transparent (lower left corner)
//	RowRotated[i]:=tpixelformat(BitMapOriginal.TRANSPARENTCOLOR) ; wont work
				case nBytes of
				0,1:RowRotatedB[i] := TransparentB;
				2:	RowRotatedW[i] := TransparentW;
				3:	RowRotatedT[i] := TransparentT;
				4:	RowRotatedQ[i] := TransparentQ;
				end;//case
			END //if inside

		END //for i
	END;//for j
  end;//non-zero rotation

//offset to the apparent center of rotation   11/12/00 12/25/99
//rotate/translate the old bitmap origin to the new bitmap origin,FIXED 11/12/00
  sicoPhi := sicodiPoint(  POINT( width div 2, height div 2 ),oldaxis );
  //sine/cosine/dist of axis point from center point
  with sicoPhi do begin
//NewAxis := NewCenter + dist* <sin( theta+phi ),cos( theta+phi )>
    NewAxis.x := newWidth div 2 + ROUND( di*(CosTheta*co - SinTheta*si) );
    NewAxis.y := newHeight div 2- ROUND( di*(SinTheta*co + CosTheta*si) );//flip yaxis
  end;

end;//with

END; {RotateImage}


unit movieobject;

interface

uses main;

type
  TMovieObject = class(TObject)
  protected
    m_pFrameSet : TSingleFramePtr; //this is owned by this
  public
    m_nOriginalLayer : integer;
    m_nOriginalFrameSet : integer;
    m_nOriginalFrame : integer;
    m_pObject : pointer;    // new object, tweened version, this owns it
    m_nType : integer;
    m_pTempObject : pointer; //the main layer object, eg: contains bitmap data
    m_fMass, m_fBouncy : single;
    m_nState : integer;
    m_fForce : array[0..1] of single;
    constructor Create(layer,frameset,frame : integer; layerType : integer; start,stop,temp : pointer; percent : single);
    destructor Destroy; override;
    procedure ResetFrameset;
    function AddKeyFrame(pTweenedObject : pointer; nFrame : integer) : pointer;
    property FrameSet : TSingleFramePtr read m_pFrameSet;
  end;

implementation

uses
  stickstuff;

function tweenColour(start, stop : longword; percent : single) : longword;
var
  r,g,b : array[0..2] of byte;
begin
  r[0] := start;
  g[0] := start shr 8;
  b[0] := start shr 16;
  r[1] := stop;
  g[1] := stop shr 8;
  b[1] := stop shr 16;

  r[2] := round( r[0]+ ( (r[1] - r[0]) * percent ) );
  g[2] := round( g[0]+ ( (g[1] - g[0]) * percent ) );
  b[2] := round( b[0]+ ( (b[1] - b[0]) * percent ) );

  tweenColour := r[2] + (g[2] shl 8) + (b[2] shl 16);
end;

function tweenT2Stick(start, stop : TLimbListPtr; percent : single) : TLimbList;
var
  ret : TLimbList;
begin
  ret := TLimbList.Create;
  ret.Tween(start^, stop^, percent);
  tweenT2Stick := ret;
end;

function tweenRectangle(start, stop : TSquareObjPtr; percent : single) : TSquareObj;
var
  f : integer;
  ret : TSquareObj;
  ink : single;
begin
  ret := TSquareObj.Create(nil);

  for f := 1 to 4 do
  begin
    ink := (stop^.Pnt(f)^.left - start^.Pnt(f)^.left) * percent;
    ret.Pnt(f)^.left := round(start^.Pnt(f)^.left + ink);
    ink := (stop^.Pnt(f)^.top - start^.Pnt(f)^.top) * percent;
    ret.Pnt(f)^.top := round(start^.Pnt(f)^.top + ink);
  end;

  //angle
  ink := (stop^.m_angle - start^.m_angle) * percent;
  ret.m_angle := (start^.m_angle + ink);
  //angle/
  //alpha
  ink := (stop^.m_alpha - start^.m_alpha) * percent;
  ret.m_alpha := round(start^.m_alpha + ink);
  //alpha/
  ink := (stop^.m_nLineWidth - start^.m_nLineWidth) * percent;
  ret.m_nLineWidth := round(start^.m_nLineWidth + ink);

  ret.m_InColour := tweenColour(start^.m_InColour, stop^.m_InColour, percent);
  ret.m_OutColour := tweenColour(start^.m_OutColour, stop^.m_OutColour, percent);
  ret.m_styleInner := start^.m_styleInner;
  ret.m_styleOuter := start^.m_styleOuter;

  tweenRectangle := ret;
end;

function tweenBitmap(start, stop : TBitmanPtr; percent : single) : TBitman;
var
  f : integer;
  ret : TBitman;
  ink : single;
begin
  ret := TBitman.Create(nil, '', 0,0);

  for f := 1 to 4 do
  begin
    ink := (stop^.Pnt(f)^.left - start^.Pnt(f)^.left) * percent;
    ret.Pnt(f)^.left := round(start^.Pnt(f)^.left + ink);
    ink := (stop^.Pnt(f)^.top - start^.Pnt(f)^.top) * percent;
    ret.Pnt(f)^.top := round(start^.Pnt(f)^.top + ink);
  end;

  //angle
  ink := (stop^.m_angle - start^.m_angle) * percent;
  ret.m_angle := (start^.m_angle + ink);
  //angle/
  //alpha
  ink := (stop^.m_alpha - start^.m_alpha) * percent;
  ret.m_alpha := round(start^.m_alpha + ink);
  //alpha/

  tweenBitmap := ret;
end;

function tweenLine(start, stop : TLineObjPtr; percent : single) : TLineObj;
var
  f : integer;
  ret : TLineObj;
  ink : single;
begin
  ret := TLineObj.Create(nil);

  for f := 1 to 2 do
  begin
    ink := (stop^.Pnt(f)^.left - start^.Pnt(f)^.left) * percent;
    ret.Pnt(f)^.left := round(start^.Pnt(f)^.left + ink);
    ink := (stop^.Pnt(f)^.top - start^.Pnt(f)^.top) * percent;
    ret.Pnt(f)^.top := round(start^.Pnt(f)^.top + ink);
  end;

  //angle
  ink := (stop^.m_angle - start^.m_angle) * percent;
  ret.m_angle := (start^.m_angle + ink);
  //angle/
  //alpha
  ink := (stop^.m_alpha - start^.m_alpha) * percent;
  ret.m_alpha := round(start^.m_alpha + ink);
  //alpha/
  ink := (stop^.m_nLineWidth - start^.m_nLineWidth) * percent;
  ret.m_nLineWidth := round(start^.m_nLineWidth + ink);

  ret.m_Colour := tweenColour(start^.m_Colour, stop^.m_Colour, percent);

  tweenLine := ret;
end;

function tweenOval(start, stop : TSquareObjPtr; percent : single) : TOvalObj;
var
  f : integer;
  ret : TOvalObj;
  ink : single;
begin
  ret := TOvalObj.Create(nil);

  for f := 1 to 4 do
  begin
    ink := (stop^.Pnt(f)^.left - start^.Pnt(f)^.left) * percent;
    ret.Pnt(f)^.left := round(start^.Pnt(f)^.left + ink);
    ink := (stop^.Pnt(f)^.top - start^.Pnt(f)^.top) * percent;
    ret.Pnt(f)^.top := round(start^.Pnt(f)^.top + ink);
  end;

  //angle
  ink := (stop^.m_angle - start^.m_angle) * percent;
  ret.m_angle := (start^.m_angle + ink);
  //angle/
  //alpha
  ink := (stop^.m_alpha - start^.m_alpha) * percent;
  ret.m_alpha := round(start^.m_alpha + ink);
  //alpha/
  ink := (stop^.m_nLineWidth - start^.m_nLineWidth) * percent;
  ret.m_nLineWidth := round(start^.m_nLineWidth + ink);

  ret.m_InColour := tweenColour(start^.m_InColour, stop^.m_InColour, percent);
  ret.m_OutColour := tweenColour(start^.m_OutColour, stop^.m_OutColour, percent);
  ret.m_styleInner := start^.m_styleInner;
  ret.m_styleOuter := start^.m_styleOuter;

  tweenOval := ret;
end;

function tweenText(start, stop : TTextObjPtr; percent : single) : TTextObj;
var
  f : integer;
  ret : TTextObj;
  ink : single;
begin
  ret := TTextObj.Create(nil);

  for f := 1 to 4 do
  begin
    ink := (stop^.Pnt(f)^.left - start^.Pnt(f)^.left) * percent;
    ret.Pnt(f)^.left := round(start^.Pnt(f)^.left + ink);
    ink := (stop^.Pnt(f)^.top - start^.Pnt(f)^.top) * percent;
    ret.Pnt(f)^.top := round(start^.Pnt(f)^.top + ink);
  end;

  //angle
  ink := (stop^.m_angle - start^.m_angle) * percent;
  ret.m_angle := (start^.m_angle + ink);
  //angle/
  //alpha
  ink := (stop^.m_alpha - start^.m_alpha) * percent;
  ret.m_alpha := round(start^.m_alpha + ink);
  //alpha/

  ret.m_strFontName := start^.m_strFontName;
  ret.m_strCaption := start^.m_strCaption;
  ret.m_InColour := tweenColour(start^.m_InColour, stop^.m_InColour, percent);
  ret.m_OutColour := tweenColour(start^.m_OutColour, stop^.m_OutColour, percent);
  ret.m_styleOuter := start^.m_styleOuter;

  tweenText := ret;
end;

function tween(layerType : integer; start, stop : pointer; percent : single) : pointer;
var
  pObject : pointer;
begin
  pObject := nil;
  case layerType of
      O_T2STICK:    pObject := tweenT2Stick(start, stop, percent);
      O_RECTANGLE:  pObject := tweenRectangle(start, stop, percent);
      O_BITMAP:     pObject := tweenBitmap(start, stop, percent);
      O_OVAL:       pObject := tweenOval(start, stop, percent);
      O_TEXT:       pObject := tweenText(start, stop, percent);
      O_LINE:       pObject := tweenLine(start, stop, percent);
      {O_STICKMAN:   pObject := tweenStick(start, stop, percent);
      O_BITMAP:     pObject := TBitMan.Create;
      O_POLY:       pObject := TPolyObj.Create;
      }
  end;
  tween := pObject;
end;

constructor TMovieObject.Create(layer,frameset,frame : integer; layerType : integer; start,stop,temp : pointer; percent : single);
begin
  m_nState := 2; //C_STATE_MOVING
  m_nOriginalLayer := layer;
  m_nOriginalFrameSet := frameset;
  m_nOriginalFrame := frame;
  m_nType := layerType;
  m_pTempObject := temp;
  new(m_pFrameSet);
  m_fMass := 1;
  m_fBouncy := 0.1;
  m_pFrameSet^ := TSingleFrame.Create;
  m_pObject := tween(layerType, start, stop, percent);
end;

destructor TMovieObject.Destroy;
begin
  m_pFrameSet^.Free;
  dispose(m_pFrameSet);
   if (m_pObject <> nil) then
   begin
      if (m_nType = O_STICKMAN) then TStickMan(m_pObject).Free;
      if (m_nType = O_T2STICK) then TLimbList(m_pObject).Free;
      if (m_nType = O_BITMAP) then TBitMan(m_pObject).Free;
      if (m_nType = O_RECTANGLE) then TSquareObj(m_pObject).Free;
      if (m_nType = O_LINE) then TLineObj(m_pObject).Free;
      if (m_nType = O_TEXT) then TTextObj(m_pObject).Free;
      if (m_nType = O_POLY) then TPolyObj(m_pObject).Free;
      if (m_nType = O_OVAL) then TOvalObj(m_pObject).Free;
   end;
  inherited;
end;

procedure TMovieObject.ResetFrameset;
begin
  m_pFrameSet^.Free;
  dispose(m_pFrameSet);
  new(m_pFrameSet);
  m_pFrameSet^ := TSingleFrame.Create;
end;

function TMovieObject.AddKeyFrame(pTweenedObject : pointer; nFrame : integer) : pointer;
var
  pFrame : TIFramePtr;
  pObject : pointer;
  stick : TStickManPtr;
  t2stick : TLimbListPtr;
  bitmap : TBitManPtr;
  square : TSquareObjPtr;
  line : TLineObjPtr;
  text : TTextObjPtr;
  poly : TPolyObjPtr;
  oval : TOvalObjPtr;
begin
  if (m_nType = O_STICKMAN) then begin new(stick); stick^ := TStickMan.Create(nil, 0,0,0,0,0,0,0,0,0); stick^.Assign(@pTweenedObject); pObject := stick; end;
  if (m_nType = O_T2STICK) then begin new(t2stick); t2stick^ := TLimbList.Create; t2stick^.CopyFrom(pTweenedObject); pObject := t2stick; end;
  if (m_nType = O_BITMAP) then begin new(bitmap); bitmap^ := TBitMan.Create(nil, '', 0,0); bitmap^.Assign(@pTweenedObject); pObject := bitmap; end;
  if (m_nType = O_RECTANGLE) then begin new(square); square^ := TSquareObj.Create(nil); square^.Assign(@pTweenedObject); pObject := square; end;
  if (m_nType = O_LINE) then begin new(line); line^ := TLineObj.Create(nil); line^.Assign(@pTweenedObject); pObject := line; end;
  if (m_nType = O_TEXT) then begin new(text); text^ := TTextObj.Create(nil); text^.Assign(@pTweenedObject); pObject := text; end;
  if (m_nType = O_POLY) then begin new(poly); poly^ := TPolyObj.Create(nil, TPolyObjPtr(@pTweenedObject)^.PntList.Count); poly^.Assign(pTweenedObject); pObject := poly; end;
  if (m_nType = O_OVAL) then begin new(oval); oval^ := TOvalObj.Create(nil); oval^.Assign(@pTweenedObject); pObject := oval; end;

  new(pFrame);
  pFrame^ := TIFrame.Create;
  pFrame^.m_nType := m_nType;
  pFrame^.m_pObject := pObject;
  pFrame^.m_FrameNo := nFrame;
  pFrame^.m_nOnion := 0;
  m_pFrameSet^.m_Frames.Add(pFrame);
  AddKeyFrame:= pObject;
end;

end.

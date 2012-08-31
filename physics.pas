unit physics;

interface

{$DEFINE PREVIEW}

uses
  ChipmunkImport, stickstuff, main, {$IFDEF PREVIEW}glpreview,{$ENDIF} formgl, stickjoint;

type
  TPhysics = class(TObject)
  protected
    m_space : PcpSpace;
    m_collisions : array[0..4] of boolean;
    m_currentGroup : integer;
    m_groupCount : integer;
    {$IFDEF PREVIEW}m_gl : TglForm;{$ENDIF}
  protected
    function AddJoint(body1, body2 : PcpBody; pos : cpVect; tisJoint : TJoint) : PcpJoint;
  public
    constructor Create(width, height : integer; collisions : array of boolean);
    destructor Destroy; override;

    procedure Step;

    procedure AddT2Stick(pStick : TLimbList; state : integer; bouncy : float; mass : float);
    function AddLine(x1,y1, x2,y2, width : integer; state : integer; bouncy : float; mass : float; prevBody : PcpBody = nil) : PcpBody; overload;
    function AddLine(line : TLineObj; state : integer; bouncy : float; mass : float) : PcpBody; overload;
    function AddRectangle(x1,y1, x2,y2 : single; angle : single; state : integer; bouncy : float; mass : float; prevBody : PcpBody = nil; xoffs : single = 0; yoffs : single = 0) : PcpBody; overload;
    function AddRectangle(square : TSquareObj; state : integer; impulse : array of float; bouncy : float; mass : float) : PcpBody; overload;
    function AddBitmap(bitmap : TBitman; state : integer; impulse : array of float; bouncy : float; mass : float) : PcpBody;
    function AddText(text : TTextObj; state : integer; impulse : array of float; bouncy : float; mass : float) : PcpBody;
    function AddOval(x1,y1, x2,y2 : single; angle : single; state : integer; bouncy : float; mass : float; prevBody : PcpBody = nil) : PcpBody; overload;
    function AddOval(oval : TOvalObj; state : integer; impulse : array of float; bouncy : float; mass : float) : PcpBody; overload;
    function AddPolygon(square : TSquareObj; state : integer; impulse : array of float) : PcpBody; overload;

    property Space : PcpSpace read m_space;
  end;

implementation

uses
  math, windows;

const
   C_STATE_STATIC = 0;
   C_STATE_SLEEPING = 1;
   C_STATE_MOVING = 2;
   C_STATE_PASSTHROUGH = 3;
   DEFAULT_BOUNCY = 0.1;

constructor TPhysics.Create(width, height : integer; collisions : array of boolean);
var
  border : PcpBody;
  shape : PcpShape;
  f : integer;
begin
{$IFDEF PREVIEW}
  m_gl := TglForm.Create(nil);
{$ENDIF}
  //m_gl.Show;

  m_currentGroup := 0;
  m_groupCount := 0;
  for f := 0 to 4 do
    m_collisions[f] := collisions[f];

  cpInitChipmunk();
  cpResetShapeIdCounter();

  border := cpBodyNew(INFINITY, INFINITY);

  m_space := cpSpaceNew();
  m_space^.iterations := 10;
  cpSpaceResizeActiveHash(m_space, 100.0, 999);
  cpSpaceResizeStaticHash(m_space, 100.0, 999);
  m_space^.gravity := cpv(0, 100);

  if (m_collisions[0]) then
  begin
    shape    := cpSegmentShapeNew(border, cpv(0,height), cpv(0, 0), 0.0);
    shape^.e := 1.0;
    shape^.u := 1.0;
    cpSpaceAddStaticShape(m_space, shape);
  end;
  if (m_collisions[1]) then
  begin
    shape    := cpSegmentShapeNew(border, cpv(width,0), cpv(width,height), 0.0);
    shape^.e := 1.0;
    shape^.u := 1.0;
    cpSpaceAddStaticShape(m_space, shape);
  end;
  if (m_collisions[2]) then
  begin
    shape    := cpSegmentShapeNew(border, cpv(0,0), cpv(width, 0), 0.0);
    shape^.e := 1.0;
    shape^.u := 1.0;
    cpSpaceAddStaticShape(m_space, shape);
  end;
  //hack : make the floor thick
  if (m_collisions[3]) then
  begin
    AddRectangle(0,height+1,width,height+10, 0, C_STATE_STATIC, 0, 0);
  end;

end;

destructor TPhysics.Destroy;
begin
  cpSpaceFreeChildren(m_space);
  cpSpaceFree(m_space);
  //cpShutdownChipmunk(); //this causes crash, but not calling it might create weirdness with multiple runs
{$IFDEF PREVIEW}
  m_gl.Free;
{$ENDIF}  
  inherited;
end;

procedure TPhysics.AddT2Stick(pStick : TLimbList; state : integer; bouncy : float; mass : float);
var
  f,c : integer;
  cur,next : TJoint;
  procedure processJoint(parent, joint : TJoint; body : PcpBody; currentX, currentY, currentAngle : single);
  var
    g : integer;
    child : TJoint;
    b : PcpBody;
    wide,high,cx,cy,radius,angle : single;
    length : single;
    prevBody : PcpBody;
    xx,yy : single;
  begin
    b := nil;
    joint.Data := nil;
    prevBody := nil;

    if (joint.State = C_STATE_ADJUST_TO_PARENT) {and inLockState} then
    begin
       prevBody := body;
    end;

    xx := 0;
    yy := 0;

    if (nil <> parent) then
    begin
      wide := parent.X - joint.X;
      high := parent.Y - joint.Y;
      cx := joint.X + (wide / 2);
      cy := joint.Y + (high / 2);
      angle := 180 * (1 + ArcTan2(high, wide) / PI);

      currentAngle := currentAngle + angle;
      if (joint.State = C_STATE_ADJUST_TO_PARENT) then
      begin
        angle := currentAngle;
        xx := cx - currentX;
        yy := cy - currentY;
      end else
      begin
        currentAngle := angle;
        currentX := cx;
        currentY := cy;
      end;

      currentX := cx;
      currentY := cy;

      radius := abs(high);
      if abs(wide) > radius then
        radius := abs(wide);
      radius := radius / 2;

      case (joint.DrawAs) of
        C_DRAW_AS_LINE : b := AddLine(parent.X, parent.Y, joint.X, joint.Y, joint.Width, state, bouncy, mass, prevBody);
        C_DRAW_AS_RECT :
        begin
          wide := joint.Length / 2;
          high := joint.DrawWidth / 2;
          b := AddRectangle(cx - wide, cy - high, cx + wide, cy + high, angle, state, bouncy, mass, prevBody, xx,yy);
          b.drawRotInc := -pi/2;
        end;
        C_DRAW_AS_CIRCLE :
        begin
          wide := joint.Length / 2;
          high := joint.DrawWidth / 2;
          radius := Joint.length / 2;
          b := AddOval(cx-radius,cy-radius,cx+radius,cy+radius, angle, state, bouncy, mass, prevBody);
          b.drawRotInc := -pi/2;
        end;
      end;
      b.Data := joint;
      joint.Data := b;
    end;
    if (prevBody = nil) then
    begin
      if (nil <> body) then
      begin
        AddJoint(body, b, cpv(parent.X, parent.Y), joint);
      end;
    end;
    for g := 0 to joint.m_olChildren.Count - 1 do
    begin
      child := joint.m_olChildren.Items[g];
      processJoint(joint, child, b, currentX, currentY, currentAngle);
    end;
  end;
begin
  if (not m_collisions[4]) then
  begin
    m_groupCount := m_groupCount + 1;
    m_currentGroup := m_groupCount;
  end;
  for f := 0 to pStick.GetJointCount - 1 do
  begin
    processJoint(nil, pStick.Joint[f], nil, 0,0,0);
    for c := 0 to pStick.Joint[f].m_olChildren.Count-2 do
    begin
      cur := pStick.Joint[f].m_olChildren[c];
      next := pStick.Joint[f].m_olChildren[c+1];
      AddJoint(cur.Data, next.Data, cpv(pStick.Joint[f].X, pStick.Joint[f].Y), pStick.Joint[f]);
    end;
  end;
  m_currentGroup := 0;
end;

function TPhysics.AddLine(line : TLineObj; state : integer; bouncy : float; mass : float) : PcpBody;
var
  body : PcpBody;
begin
  body := AddLine(line.Pnt(1)^.Left,
                  line.Pnt(1)^.Top,
                  line.Pnt(2)^.Left,
                  line.Pnt(2)^.Top,
                  line.m_nLineWidth,
                  state,
                  bouncy,
                  mass);

  line.m_body := body;
  AddLine := body;
end;

function TPhysics.AddLine(x1,y1, x2,y2, width : integer; state : integer; bouncy : float; mass : float; prevBody : PcpBody = nil) : PcpBody;
var
  body : PcpBody;
  shape : PcpShape;
  num:    integer;
  verts:  array[0..3] of cpVect;
  angle : single;
  w,h,l : single;
  lineWidth : single;
begin
  w := x2-x1;
  h := y2-y1;
  l := sqrt( sqr(w) + sqr(h) );
  angle := 180 * (1 + ArcTan2(h, w) / PI);
  angle := angle - 180;
  angle := angle + 270;

  lineWidth := width/4;
  num      := 4;
  verts[0] := cpv(-lineWidth, -l/2);
  verts[1] := cpv(-lineWidth,  l/2);
  verts[2] := cpv(lineWidth,   l/2);
  verts[3] := cpv(lineWidth,  -l/2);

  if (prevBody <> nil) then
  begin
    body := prevBody;
  end else
  begin
    if (state = C_STATE_STATIC) then
    begin
      body := cpBodyNew(INFINITY, INFINITY);
    end else
    begin
      body := cpBodyNew(mass, cpMomentForPoly(1.0, num, @verts, cpvzero));
      cpSpaceAddBody(m_space, body);
    end;

    body^.p := cpv(x1 + (w/2), y1 + (h/2));
  end;
  cpBodySetAngle(body, DegToRad(angle));
  shape    := cpPolyShapeNew(body, num, @verts, cpvzero);
  shape^.e := bouncy;
  shape^.u := 0.6;
  shape^.group := m_currentGroup;

  case (state) of
   C_STATE_STATIC : begin shape^.e := 1; shape^.u := 1; cpSpaceAddStaticShape(m_space, shape); end;
   C_STATE_SLEEPING : begin cpSpaceAddShape(m_space, shape); body^.sleeping := true; end;
   C_STATE_MOVING : cpSpaceAddShape(m_space, shape);
//   C_STATE_PASSTHROUGH = 3;
  end;

  AddLine := body;
end;

function TPhysics.AddBitmap(bitmap : TBitman; state : integer; impulse : array of float; bouncy : float; mass : float) : PcpBody;
var
  body : PcpBody;
  j,r : cpVect;
begin
  body := AddRectangle(bitmap.Pnt(1)^.Left,
                       bitmap.Pnt(1)^.Top,
                       bitmap.Pnt(3)^.Left,
                       bitmap.Pnt(3)^.Top,
                       bitmap.m_angle,
                       state,
                       bouncy,
                       mass);

  bitmap.m_body := body;
  j := cpvzero;
  r := cpvzero;
  j.x := impulse[0] * 5;
  j.y := impulse[1] * 5;
  if (state = C_STATE_MOVING) then
    cpBodyApplyImpulse(body, j, r);

  AddBitmap := body;
end;


function TPhysics.AddRectangle(square : TSquareObj; state : integer; impulse : array of float; bouncy : float; mass : float) : PcpBody;
var
  body : PcpBody;
  j,r : cpVect;
begin
  body := AddRectangle(square.Pnt(1)^.Left - square.m_nLineWidth/2,
                       square.Pnt(1)^.Top - square.m_nLineWidth/2,
                       square.Pnt(3)^.Left + square.m_nLineWidth/2,
                       square.Pnt(3)^.Top + square.m_nLineWidth/2,
                       square.m_angle,
                       state,
                       bouncy,
                       mass);

  square.m_body := body;
  j := cpvzero;
  r := cpvzero;
  j.x := impulse[0] * 5;
  j.y := impulse[1] * 5;
  if (state = C_STATE_MOVING) then
    cpBodyApplyImpulse(body, j, r);

  AddRectangle := body;
end;

function TPhysics.AddText(text : TTextObj; state : integer; impulse : array of float; bouncy : float; mass : float) : PcpBody;
var
  body : PcpBody;
  j,r : cpVect;
begin
  body := AddRectangle(text.Pnt(1)^.Left,
                       text.Pnt(1)^.Top,
                       text.Pnt(3)^.Left,
                       text.Pnt(3)^.Top,
                       text.m_angle,
                       state,
                       bouncy,
                       mass);

  text.m_body := body;

  j := cpvzero;
  r := cpvzero;
  j.x := impulse[0] * 5;
  j.y := impulse[1] * 5;
  if (state = C_STATE_MOVING) then
    cpBodyApplyImpulse(body, j, r);

  AddText := body;
end;

function TPhysics.AddRectangle(x1,y1, x2,y2 : single; angle : single; state : integer; bouncy : float; mass : float; prevBody : PcpBody = nil; xoffs : single = 0; yoffs : single = 0) : PcpBody;
var
  body : PcpBody;
  shape : PcpShape;
  num:    integer;
  verts:  array[0..3] of cpVect;
  w,h : single;
  x,y : single;
  f : integer;
begin
  w := (x2-x1)/2;
  h := (y2-y1)/2;

  num      := 4;
  verts[0] := cpv(-w, -h);
  verts[1] := cpv(-w,  h);
  verts[2] := cpv(w,   h);
  verts[3] := cpv(w,  -h);

  if (prevBody <> nil) then
  begin
    angle := degtorad(angle);
    body := prevBody;
    for f := 0 to 3 do
    begin
      x := cos(angle)*verts[f].x - sin(angle)*verts[f].y;
      y := sin(angle)*verts[f].x + cos(angle)*verts[f].y;
      verts[f].x := xoffs + x;
      verts[f].y := yoffs + y;
    end;
  end else
  begin
    if (state = C_STATE_STATIC) then
    begin
      body := cpBodyNew(INFINITY, INFINITY);
    end else
    begin
      body := cpBodyNew(mass, cpMomentForPoly(1.0, num, @verts, cpvzero));
      cpSpaceAddBody(m_space, body);
    end;
    body^.p := cpv(x1 + w, y1 + h);
    cpBodySetAngle(body, DegToRad(angle));
  end;

  shape    := cpPolyShapeNew(body, num, @verts, cpvzero);
  shape^.e := bouncy;
  shape^.u := 0.6;
  shape^.group := m_currentGroup;

  case (state) of
   C_STATE_STATIC : begin shape^.e := 1; shape^.u := 1; cpSpaceAddStaticShape(m_space, shape); end;
   C_STATE_SLEEPING : begin cpSpaceAddShape(m_space, shape); body^.sleeping := true; end;
   C_STATE_MOVING : cpSpaceAddShape(m_space, shape);
//   C_STATE_PASSTHROUGH = 3;
  end;

  AddRectangle := body;
end;

function TPhysics.AddOval(oval : TOvalObj; state : integer; impulse : array of float; bouncy : float; mass : float) : PcpBody;
var
  j,r : cpVect;
  body : PcpBody;
begin
  body := AddOval(oval.Pnt(1)^.Left - oval.m_nLineWidth/2,
                  oval.Pnt(1)^.Top - oval.m_nLineWidth/2,
                  oval.Pnt(3)^.Left + oval.m_nLineWidth/2,
                  oval.Pnt(3)^.Top + oval.m_nLineWidth/2,
                  oval.m_angle,
                  state,
                  bouncy,
                  mass);

  oval.m_body := body;
  j := cpvzero;
  r := cpvzero;
  j.x := impulse[0] * 5;
  j.y := impulse[1] * 5;
  if (state = C_STATE_MOVING) then
    cpBodyApplyImpulse(body, j, r);

  AddOval := body;
end;

function TPhysics.AddOval(x1,y1, x2,y2 : single; angle : single; state : integer; bouncy : float; mass : float; prevBody : PcpBody = nil) : PcpBody;
var
  body : PcpBody;
  shape : PcpShape;
  num:    integer;
  verts:  array[0..100] of cpVect;
  wide,high : single;

  theta, a : single;
  index : integer;
  px,py : single;
begin
  AddOval := nil;
  
  wide := (x2-x1)/2;
  high := (y2-y1)/2;

  if (wide = 0) or (high = 0) then
    exit;

  if (wide < 1) then
  begin
    //px := x1;
    //x1 := x2;
    //x2 := px;
    wide := wide * -1;
  end;
  if (high < 1) then
  begin
    high := high * -1;
    //py := y1;
    //y1 := y2;
    //y2 := py;
  end;


   if (wide > high) then
     num := round(sqrt(wide * 2) * 2)
   else
     num := round(sqrt(high * 2) * 2);

   if (num < 4) then
     num := 4;

   theta := (2 * PI) / num;

   a := 360;

	 for index := 0 to num-1 do
	 begin
      a := a - theta;
      px := cos(a)*wide;
      py := sin(a)*high;
      verts[index].x := px;
      verts[index].y := py;
   end;

  if (prevBody <> nil) then
  begin
    body := prevBody;
  end else
  begin
    if (state = C_STATE_STATIC) then
    begin
      body := cpBodyNew(INFINITY, INFINITY);
    end else
    begin
      body := cpBodyNew(mass, cpMomentForPoly(1.0, num, @verts, cpvzero));
      cpSpaceAddBody(m_space, body);
    end;

    body^.p := cpv(x1+wide, y1+high);
    cpBodySetAngle(body, DegToRad(angle));
  end;

  shape    := cpPolyShapeNew(body, num, @verts, cpvzero);
  shape^.e := bouncy;
  shape^.u := 0.6;
  shape^.group := m_currentGroup;

  case (state) of
   C_STATE_STATIC : begin shape^.e := 1; shape^.u := 1; cpSpaceAddStaticShape(m_space, shape); end;
   C_STATE_SLEEPING : begin cpSpaceAddShape(m_space, shape); body^.sleeping := true; end;
   C_STATE_MOVING : cpSpaceAddShape(m_space, shape);
//   C_STATE_PASSTHROUGH = 3;
  end;

  AddOval := body;
end;

function TPhysics.AddPolygon(square : TSquareObj; state : integer; impulse : array of float) : PcpBody;
begin
  AddPolygon := nil;
end;

function TPhysics.AddJoint(body1, body2 : PcpBody; pos : cpVect; tisJoint : TJoint) : PcpJoint;
var
  joint : PcpJoint;
begin
  joint := cpPivotJointNew(body1, body2, pos);
  cpSpaceAddJoint(m_space, joint);
  joint^.tisJoint := tisJoint;
  AddJoint := joint;
end;

procedure TPhysics.Step;
var
   steps: integer;
   dt:    cpFloat;
   i:     integer;
begin
   steps := 2;
   dt    := 1.0 / 60.0 / steps;

   for i := 0 to steps - 1 do
      cpSpaceStep(m_space, dt);

{$IFDEF PREVIEW}
   previewGL(m_space);
   m_gl.Flip();
   sleep(100);
{$ENDIF}
end;

end.

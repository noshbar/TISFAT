unit glpreview;

interface

uses
   gl, Math, ChipmunkImport;

type
   TStep = procedure(space: PcpSpace);

procedure drawCollisions(ptr: pointer; Data: pointer);
procedure drawCircle(x: cpFloat; y: cpFloat; r: cpFloat; a: cpFloat);
procedure drawCircleShape(shape: PcpShape);
procedure drawSegmentShape(shape: PcpShape);
procedure drawPolyShape(shape: PcpShape);
procedure drawObject(ptr: pointer; unused: pointer);
procedure previewGL(space : PcpSpace);

implementation

procedure drawCollisions(ptr: pointer; Data: pointer);
var
   arb: PcpArbiter;
   i:   integer;
   v:   cpVect;
begin
   arb := PcpArbiter(ptr);
   for i := 0 to arb^.numContacts - 1 do
   begin
      v := arb^.contacts^[i].p;
      glVertex2f(v.x, v.y);
   end;
end;

procedure drawCircle(x: cpFloat; y: cpFloat; r: cpFloat; a: cpFloat);
const
   segs = 15;
var
   coef: cpFloat;
   n:    integer;
   rads: cpFloat;
begin
   coef := 2.0 * PI / segs;
   glBegin(GL_LINE_STRIP);
   for n := 0 to segs do
   begin
      rads := n * coef;
      glVertex2f(r * cos(rads + a) + x, (r * sin(rads + a) + y));
   end;
   glVertex2f(x, y);
   glEnd();
end;

procedure drawCircleShape(shape: PcpShape);
var
   body:   PcpBody;
   circle: PcpCircleShape;
   c:      cpVect;
begin
   body   := shape^.body;
   circle := PcpCircleShape(shape);
   c      := cpvadd(body^.p, cpvrotate(circle^.c, body^.rot));
   drawCircle(c.x, c.y, circle^.r, body^.a);
end;

procedure drawSegmentShape(shape: PcpShape);
var
   body: PcpBody;
   seg:  PcpSegmentShape;
   a, b: cpVect;
begin
   body := shape^.body;
   seg  := PcpSegmentShape(shape);
   a    := cpvadd(body^.p, cpvrotate(seg^.a, body^.rot));
   b    := cpvadd(body^.p, cpvrotate(seg^.b, body^.rot));

   glBegin(GL_LINES);
   glVertex2f(a.x, a.y);
   glVertex2f(b.x, b.y);
   glEnd();
end;

procedure drawPolyShape(shape: PcpShape);
var
   body: PcpBody;
   poly: PcpPolyShape;
   num:  integer;
   i:    integer;
   v:    cpVect;
begin
   body := shape^.body;
   poly := PcpPolyShape(shape);

   num := poly^.numVerts;

   glBegin(GL_LINE_LOOP);
   for i := 0 to num - 1 do
   begin
      v := cpvadd(body^.p, cpvrotate(poly^.verts[i], body^.rot));
      glVertex2f(v.x, v.y);
   end;
   glEnd();
end;

procedure drawObject(ptr: pointer; unused: pointer);
var
   shape: PcpShape;
begin
   shape := PcpShape(ptr);
   case (shape^.cptype) of
      CP_CIRCLE_SHAPE:
         drawCircleShape(shape);
      CP_SEGMENT_SHAPE:
         drawSegmentShape(shape);
      CP_POLY_SHAPE:
         drawPolyShape(shape);
   end;
end;

procedure previewGL(space : PcpSpace);
var
   i, num: integer;
   bodies: PcpArray;
   body:   PcpBody;
begin
   glColor3f(0.0, 0.0, 0.0);
   glClear(GL_COLOR_BUFFER_BIT);

   cpSpaceHashEach(space^.activeShapes, @drawObject, nil);
   cpSpaceHashEach(space^.staticShapes, @drawObject, nil);

   bodies := space^.bodies;
   num    := bodies^.num;

   glBegin(GL_POINTS);
   begin
      glColor3f(0.0, 0.0, 1.0);
      for i := 0 to num - 1 do
      begin
         body := PcpBody(bodies^.arr[i]);
         glVertex2f(body^.p.x, body^.p.y);
      end;
      glColor3f(1.0, 0.0, 0.0);
      cpArrayEach(space^.arbiters, @drawCollisions, nil);
   end;
   glEnd();
end;

end.

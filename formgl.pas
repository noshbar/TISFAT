unit formgl;

interface

uses
   Windows, Classes, Forms, gl, glu, Controls, Graphics;

type
   TglForm = class(TForm)
      procedure FormCreate(Sender: TObject);
      procedure FormDestroy(Sender: TObject);
   protected
      { Private declarations }
      m_hRC:  HGLRC;               // rendering context
      m_hDC:  HDC;                  // device context
      m_PFD:  PIXELFORMATDESCRIPTOR;
      m_fFOV: single;
      m_fNear, m_fFar: double;

      procedure SetupPixelFormat(dc: HDC);
      procedure MyResize(Sender: TObject);
   public
      { Public declarations }
      procedure SetFOV(fFOV: glfloat);
      procedure SetDistances(fNear, fFar: double);
      procedure SetPerspective(fFOV, fNear, fFar: double);
      procedure Flip;

      property FOV: glfloat Read m_fFOV Write SetFOV;
   end;

implementation

{$R *.dfm}

procedure TglForm.Flip;
begin
   glFlush();
   SwapBuffers(m_hDC);
end;

procedure TglForm.SetPerspective(fFOV, fNear, fFar: double);
begin
   m_fFOV  := fFOV;
   m_fNear := fNear;
   m_fFar  := fFar;
   glMatrixMode(GL_PROJECTION);
   glLoadIdentity();
   gluPerspective(m_fFOV, ClientWidth / ClientHeight, m_fNear, m_fFar);
   glMatrixMode(GL_MODELVIEW);
   glLoadIdentity();
end;

procedure TglForm.SetFOV(fFOV: glfloat);
begin
   SetPerspective(fFOV, m_fNear, m_fFar);
end;

procedure TglForm.SetDistances(fNear, fFar: double);
begin
   SetPerspective(m_fFOV, fNear, fFar);
end;

procedure TglForm.SetupPixelFormat(dc: HDC);
var
   nPixelFormat: integer;
begin
   fillchar(m_PFD, sizeof(m_PFD), 0);
   m_PFD.nSize      := sizeof(PIXELFORMATDESCRIPTOR);
   m_PFD.nVersion   := 1;
   m_PFD.dwFlags    := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
   m_PFD.iPixelType := PFD_TYPE_RGBA;
   m_PFD.cColorBits := 16;
   m_PFD.cDepthBits := 16;
   m_PFD.iLayerType := PFD_MAIN_PLANE;

   nPixelFormat := ChoosePixelFormat(m_hDC, @m_PFD);
   SetPixelFormat(m_hDC, nPixelFormat, @m_PFD);
end;

procedure TglForm.MyResize(Sender: TObject);
begin
   if (m_hRC <> 0) then
   begin
      if (ClientHeight = 0) then
      begin
         ClientHeight := 1;
      end;

      glViewport(0, 0, ClientWidth, ClientHeight);
      glMatrixMode(GL_PROJECTION);
      glLoadIdentity();

      gluPerspective(m_fFOV, ClientWidth / ClientHeight, m_fNear, m_fFar);

      glMatrixMode(GL_MODELVIEW);
      glLoadIdentity();
   end;
end;

procedure TglForm.FormCreate(Sender: TObject);
begin
   Parent  := nil;
   //OnResize := MyResize;
   m_fFOV  := 65.0;
   m_fNear := 1.0;
   m_fFar  := 5000.0;
   m_hDC   := GetDC(Handle);
   SetupPixelFormat(m_hDC);
   m_hRC := wglCreateContext(m_hDC);
   wglMakeCurrent(m_hDC, m_hRC);

   glClearColor(1.0, 1.0, 1.0, 0.0);

   glPointSize(3.0);

   glEnable(GL_LINE_SMOOTH);
   glEnable(GL_POINT_SMOOTH);
   glEnable(GL_BLEND);
   glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
   glHint(GL_LINE_SMOOTH_HINT, GL_DONT_CARE);
   glHint(GL_POINT_SMOOTH_HINT, GL_DONT_CARE);
   glLineWidth(2.5);

   ClientWidth := 320;
   ClientHeight := 240;
   Top := 0;
   Left := 500;

   glMatrixMode(GL_PROJECTION);
   glLoadIdentity();
   //glOrtho(-320.0, 320.0, 240.0, -240.0, -1.0, 1.0);
   //glTranslatef(0.5, 0.5, 0.0);
   glOrtho(-640.0, 640.0, 480.0, -480.0, -1.0, 1.0);
   glTranslatef(-640, 240, 0.0);

end;

procedure TglForm.FormDestroy(Sender: TObject);
begin
   if (m_hDC <> 0) then
   begin
      wglMakeCurrent(m_hDC, 0);
      wglDeleteContext(m_hRC);
      ReleaseDC(Handle, m_hDC);
   end;
   m_hDC := 0;
   m_hRC := 0;
end;

end.

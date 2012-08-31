{*****************************************************************************}
{                                                                             }
{    GDI + Controls                                                           }
{      http://lummie.co.uk                                                    }
{        Version: 1.0.3                                                       }
{                                                                             }
{    Copyright (c) 2005 Matt harrison (http://www.lummie.co.uk)               }
{                                                                             }
{*****************************************************************************}
unit GPWinControl;

interface

uses
  SysUtils, Classes, windows, Controls, messages, GDIPAPI, GDIPOBJ, GDIPUTIL, graphics;

type
  TGDIPPaint = procedure (Canvas : TGPGraphics) of object;

  TGDIPWinControl = class(TWinControl)
  private
    { Private declarations }
    FCanvas : TGPGraphics;
    FBuffer : TGPBitmap;
    FTransparent: boolean;
    function GetCanvas: TGPGraphics;
    procedure SetTransparent(const Value: boolean);
  protected
    { Protected declarations }
    procedure AllocateCanvas; virtual;
    procedure DeAllocateCanvas; virtual;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure CreateWnd; override;
    procedure RenderChecked(Canvas : TGPGraphics; FGColor, BGColor: TGPColor);
    procedure Paint(Canvas : TGPGraphics); virtual;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMWindowPosChanging(var Message: TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
    property Canvas : TGPGraphics read GetCanvas;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Transparent : boolean read FTransparent write SetTransparent;
  published
    { Published declarations }
  end;

  TGDIPPaintEvent = procedure(Canvas : TGPGraphics) of object;

  TGDIPCanvas = class(TGDIPWinControl)
  private
    FOnPaint: TGDIPPaintEvent;
  protected
    procedure Paint(Canvas : TGPGraphics); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property OnPaint : TGDIPPaintEvent read FOnPaint write FOnPaint;
    property Transparent;
    property Align;
    property Anchors;
    property Canvas;
    property DragKind;
    property DragCursor;
    property DragMode;
    property MouseCapture;
    property ParentShowHint;
    property PopupMenu;
    property OnContextPopup;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
  end;


implementation

uses
  GDIPExtensions;

{ TGDIPWinControl }

procedure TGDIPWinControl.AllocateCanvas;
var
  recreateBuffer : boolean;
begin
  recreateBuffer := false;
  if not assigned(FCanvas) then recreateBuffer := true;

  if not assigned(FBuffer) then
    recreateBuffer := true
  else
  begin
    if cardinal(width) <> FBuffer.GetWidth then recreateBuffer := true;
    if cardinal(height) <> FBuffer.GetHeight then recreateBuffer := true;
  end;

  if recreateBuffer then
  begin
    DeAllocateCanvas;
    if FTransparent then
      FBuffer := TGPBitmap.Create(width,height,PixelFormat32bppARGB)
    else
      FBuffer := TGPBitmap.Create(width,height,PixelFormat32bppRGB);
    FCanvas := TGPGraphics.Create(FBuffer);
  end;
end;

constructor TGDIPWinControl.Create(AOwner: TComponent);
begin
  inherited;
  FCanvas := nil;
  DoubleBuffered := true;
  controlstyle := controlstyle - [csOpaque] + [csParentBackground];
  color := clnavy;
end;

procedure TGDIPWinControl.CreateWnd;
begin
  inherited;
   SetWindowLong(Parent.Handle, GWL_STYLE, GetWindowLong(Parent.Handle, GWL_STYLE) and not WS_CLIPCHILDREN);
end;

procedure TGDIPWinControl.DeAllocateCanvas;
begin
  FreeAndNil(FCanvas);
  FreeAndNil(FBuffer);
end;

destructor TGDIPWinControl.Destroy;
begin
  DeAllocateCanvas;
  inherited;
end;

function TGDIPWinControl.GetCanvas: TGPGraphics;
begin
  result := FCanvas;
end;

procedure TGDIPWinControl.Paint(Canvas: TGPGraphics);
begin
  RenderChecked(canvas,MakeColor($FF,255,255,255),MakeColor($FF,212,212,212));
end;


procedure TGDIPWinControl.RenderChecked(Canvas : TGPGraphics; FGColor, BGColor: TGPColor);
var
  ABrush : TGPHatchBrush;
begin
  ABrush := TGPHatchBrush.create(HatchStyleLargeCheckerBoard,FGColor,bgColor) ;
  Canvas.FillRectangle(ABrush,makeRect(Clientrect));
  ABrush.free;
end;



procedure TGDIPWinControl.SetTransparent(const Value: boolean);
begin
  FTransparent := Value;
end;

procedure TGDIPWinControl.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
// do not change
end;


procedure TGDIPWinControl.WMPaint(var Message: TWMPaint);
var
  ps: PAINTSTRUCT;
  gr : TGPGraphics;
  r : TRect;
begin
  AllocateCanvas;
  BeginPaint(handle,ps);
  r := Boundsrect;

  // draw checks
  Paint(FCanvas);
 // blit to window
  gr := TGPGraphics.create(Handle,false);
  gr.DrawImage(FBuffer,0,0,FBuffer.GetWidth,FBuffer.GetHeight);
  gr.free;


  endpaint(handle,ps);
  message.result := 0;
end;

procedure TGDIPWinControl.WMWindowPosChanging(
  var Message: TWMWindowPosChanging);
var
  Rect : TRect;
begin
  rect := clientrect;
  invalidaterect(handle,@rect,false);
end;

{ TGDIPCanvas }

constructor TGDIPCanvas.Create(AOwner: TComponent);
begin
  inherited;
  FOnPaint := nil;
  FTransparent := true;
end;

procedure TGDIPCanvas.Paint(Canvas: TGPGraphics);
begin
  //if csDesigning in componentstate then
  inherited;
  if assigned(FOnPaint) then FOnPaint(Canvas);
end;

end.

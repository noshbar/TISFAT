unit newobj;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

{$i inc.inc}

type
  TfrmNewObj = class(TForm)
    cmdCancel: TButton;
    imgNewRect: TImage;
    imgNewOval: TImage;
    imgNewStick: TImage;
    imgNewSound: TImage;
    imgNewBitmap: TImage;
    imgAddPoly: TImage;
    imgNewLine: TImage;
    imgNewText: TImage;
    imgNewBoom: TImage;
    lblTitle: TLabel;
    imgT2Stick: TImage;
    procedure cmdCancelClick(Sender: TObject);
    procedure imgNewRectClick(Sender: TObject);
    procedure imgNewOvalClick(Sender: TObject);
    procedure imgNewStickClick(Sender: TObject);
    procedure imgNewBitmapClick(Sender: TObject);
    procedure imgNewSoundClick(Sender: TObject);
    procedure imgAddPolyClick(Sender: TObject);
    procedure imgNewLineClick(Sender: TObject);
    procedure imgNewTextClick(Sender: TObject);
    procedure imgNewBoomClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lblTitleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblTitleMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblTitleMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure imgNewBMPStickMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgSpecialStickClick(Sender: TObject);
    procedure imgT2StickClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    m_bMoving : boolean;
    m_nX, m_nY : integer;
    m_nChoice : integer;
  end;

implementation

{$R *.dfm}

procedure TfrmNewObj.cmdCancelClick(Sender: TObject);
begin
   m_nChoice := -1;
   Close;
end;

procedure TfrmNewObj.imgNewRectClick(Sender: TObject);
begin
   m_nChoice := O_RECTANGLE;
   Close;
end;

procedure TfrmNewObj.imgNewOvalClick(Sender: TObject);
begin
   m_nChoice := O_OVAL;
   Close;
end;

procedure TfrmNewObj.imgNewStickClick(Sender: TObject);
begin
   m_nChoice := O_STICKMAN;
   Close;
end;

procedure TfrmNewObj.imgNewBitmapClick(Sender: TObject);
begin
   m_nChoice := O_BITMAP;
   Close;
end;

procedure TfrmNewObj.imgNewSoundClick(Sender: TObject);
begin
//   m_nChoice := O_SOUND;
//   Close;
   MEssageBox(Application.HAndle, 'Not implemented in this BETA release. The next version will include sound.', 'Sorry, but...', MB_OK or MB_ICONINFORMATION);
end;

procedure TfrmNewObj.imgAddPolyClick(Sender: TObject);
begin
   m_nChoice := O_POLY;
   Close;
end;

procedure TfrmNewObj.imgNewLineClick(Sender: TObject);
begin
   m_nChoice := O_LINE;
   Close;
end;

procedure TfrmNewObj.imgNewTextClick(Sender: TObject);
begin
   m_nChoice := O_TEXT;
   Close;
end;

procedure TfrmNewObj.imgNewBoomClick(Sender: TObject);
begin
   m_nChoice := O_EXPLODE;
   Close;
end;

procedure TfrmNewObj.FormPaint(Sender: TObject);
begin
   Canvas.Pen.Color := clBlack;
   Canvas.Brush.Color := rgb(240,240,240);
   Canvas.Rectangle(0,0,clientwidth,clientheight);
end;

procedure TfrmNewObj.FormCreate(Sender: TObject);
begin
   Left := screen.width div 2 - (clientwidth div 2);
   Top := screen.height div 2 - (clientheight div 2);
   lblTitle.Color := clBlue;
   lblTitle.Left := 2;
   lblTitle.Top := 2;
   lblTitle.Width := clientwidth - 4;
   lblTitle.Height := 17;   
end;

procedure TfrmNewObj.lblTitleMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := TRUE;
   m_nX := x;
   m_nY := y;
end;

procedure TfrmNewObj.lblTitleMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := FALSE;
end;

procedure TfrmNewObj.lblTitleMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   if (m_bMoving) then
   begin
      left := left + (x - m_nX);
      top := top + (y - m_nY);
   end;
end;

procedure TfrmNewObj.imgNewBMPStickMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_nChoice := O_STICKMANBMP;
   Close;
end;

procedure TfrmNewObj.imgSpecialStickClick(Sender: TObject);
begin
   m_nChoice := O_SPECIALSTICK;
   Close;
end;

procedure TfrmNewObj.imgT2StickClick(Sender: TObject);
begin
   m_nChoice := O_T2STICK;
   Close;
end;

end.

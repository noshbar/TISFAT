unit onion;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmOnion = class(TForm)
    Button1: TButton;
    Button2: TButton;
    m_strFrames: TEdit;
    Label1: TLabel;
    lblTitle: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure lblTitleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblTitleMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lblTitleMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    m_bOk : boolean;
    m_nX, m_nY : integer;
    m_bMoving : boolean;
  end;

var
  frmOnion: TfrmOnion;

implementation

{$R *.dfm}

procedure TfrmOnion.FormCreate(Sender: TObject);
begin
   lblTitle.Color := clBlue;
   lblTitle.Left := 2;
   lblTitle.Top := 2;
   lblTitle.Width := ClientWidth - 4;
   lblTitle.Height := 17;
end;

procedure TfrmOnion.Button1Click(Sender: TObject);
var
   i,code : integer;
begin
   val(m_strFrames.Text, i, code);
   if (code <> 0) then
   begin
      MessageBox(handle, 'Number of Frames can only be an integer value', 'Error', MB_OK or MB_ICONERROR);
      exit;
   end;
   m_bOk := TRUE;
   Close;
end;

procedure TfrmOnion.Button2Click(Sender: TObject);
begin
   m_bOk := FALSE;
   Close;
end;

procedure TfrmOnion.lblTitleMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_nX := x;
   m_nY := y;
   m_bMoving := TRUE;
end;

procedure TfrmOnion.lblTitleMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   if (m_bMoving) then
   begin
      Left := Left + (x - m_nX);
      Top := Top + (y - m_nY);
   end;
end;

procedure TfrmOnion.lblTitleMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := FALSe;
end;

procedure TfrmOnion.FormPaint(Sender: TObject);
begin
   Canvas.Pen.Color := clBlack;
   Canvas.Brush.Color := rgb(240,240,240);
   Canvas.Rectangle(0,0,ClientWidth, ClientHeight);
end;

end.

unit movieprops;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmMovieProps = class(TForm)
    cmdOK: TButton;
    cmdCancel: TButton;
    memDescription: TMemo;
    lblTitle: TLabel;
    m_strWidth: TEdit;
    m_strHeight: TEdit;
    Width: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure lblTitleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblTitleMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lblTitleMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cmdOKClick(Sender: TObject);
    procedure cmdCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    m_bMoving : boolean;
    m_bOK : BOOLEAN;
    m_nX, m_nY : integer;
  end;

var
  frmMovieProps: TfrmMovieProps;

implementation

{$R *.dfm}

procedure TfrmMovieProps.FormCreate(Sender: TObject);
begin
   lblTitle.Left := 2;
   lblTitle.Top := 2;
   m_bMoving := FALSE;
   lblTitle.Width := clientwidth - 4;
   lblTitle.Height := 17;
   lblTitle.Color := clBlue;
   Color := rgb(240,240,240);
end;

procedure TfrmMovieProps.FormPaint(Sender: TObject);
begin
   Canvas.Brush.Color := rgb(240,240,240);
   Canvas.Rectangle(0,0,ClientWidth,ClientHeight);
end;

procedure TfrmMovieProps.lblTitleMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_nX := x;
   m_nY := y;
   m_bMoving := TRUE;
end;

procedure TfrmMovieProps.lblTitleMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   if (m_bMoving) then
   begin
      Left := Left + (x - m_nX);
      Top := Top + (y - m_nY);

   end;
end;

procedure TfrmMovieProps.lblTitleMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := FALSE;
end;

procedure TfrmMovieProps.cmdOKClick(Sender: TObject);
begin
   m_bOK := TRUE;
   Close;
end;

procedure TfrmMovieProps.cmdCancelClick(Sender: TObject);
begin
   m_bOK := FALSE;
   Close;
end;

end.

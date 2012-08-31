unit layername;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmLayerName = class(TForm)
    m_strTitle: TEdit;
    Label1: TLabel;
    cmdOK: TButton;
    cmdCancel: TButton;
    lblTitle: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure cmdOKClick(Sender: TObject);
    procedure cmdCancelClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    m_bOK, m_bMoving : BOOLEAN;
    m_nX, m_nY : integer;
  end;

var
  frmLayerName: TfrmLayerName;

implementation

{$R *.dfm}

procedure TfrmLayerName.FormCreate(Sender: TObject);
begin
   m_bMoving := fALSE;
   lblTitle.Left := 2;
   lblTitle.Top := 2;
   lblTitle.Width := clientwidth - 4;
   lblTitle.Height := clientHeight - 4;
   lblTitle.Color := clBlue;
   lblTitle.Height := 17;
   Left := (screen.width div 2) - (width div 2);
   Top := (screen.height div 2) - (height div 2);
end;

procedure TfrmLayerName.FormPaint(Sender: TObject);
begin
   Canvas.Brush.Color := rgb(240,240,240);
   Canvas.Pen.Color := clBlack;
   Canvas.Rectangle(0,0,ClientWidth,ClientHeight);
end;

procedure TfrmLayerName.cmdOKClick(Sender: TObject);
begin
   m_bOK := TRUE;
   Close;
end;

procedure TfrmLayerName.cmdCancelClick(Sender: TObject);
begin
   m_bOK := FALSE;
   Close;
end;

procedure TfrmLayerName.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := TRUE;
   m_nX := X;
   m_nY := Y;
end;

procedure TfrmLayerName.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   if (m_bMoving) then
   begin
      Left := Left + (x - m_nX);
      Top := Top + (y - m_ny);
   end;
end;

procedure TfrmLayerName.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := FALSE;
end;

procedure TfrmLayerName.FormActivate(Sender: TObject);
begin
   m_strTitle.SelectAll;
   m_strTitle.SetFocus;
end;

procedure TfrmLayerName.FormShow(Sender: TObject);
begin
   m_strTitle.SelectAll;
   m_strTitle.SetFocus;
end;

end.

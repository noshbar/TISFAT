unit export;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmExport = class(TForm)
    cmdExport: TButton;
    cmdCancel: TButton;
    m_strFileName: TEdit;
    cmdBrowse: TButton;
    Label1: TLabel;
    sd: TSaveDialog;
    lblTitle: TLabel;
    procedure cmdCancelClick(Sender: TObject);
    procedure cmdExportClick(Sender: TObject);
    procedure cmdBrowseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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
    m_bOK : BOOLEAN;
    m_bMoving : boolean;
    m_nX, m_nY : integer;
  end;

var
  frmExport: TfrmExport;

implementation

{$R *.dfm}

procedure TfrmExport.cmdCancelClick(Sender: TObject);
begin
   m_bOK := FALSE;
   Close;
end;

procedure TfrmExport.cmdExportClick(Sender: TObject);
var
   strTemp : string;
begin
   if (m_strFileName.Text = '') then
   begin
      MessageBox(Application.Handle, 'Please enter a filename to export movie as', 'Tis an Error', MB_OK or MB_ICONERROR);
      exit;
   end;
   strTemp := copy(m_strFileName.Text, length(m_strFileName.Text)-3, 4);
   if (uppercase(strTemp) <> '.EXE') then
   begin
      m_strFileName.Text := m_strFileName.Text + '.exe';
   end;
   m_bOK := TRUE;
   Close;
end;

procedure TfrmExport.cmdBrowseClick(Sender: TObject);
begin
   if (sd.Execute) then
   begin
      m_strFileName.Text := sd.FileName;
   end;
end;

procedure TfrmExport.FormCreate(Sender: TObject);
begin
   Left := (screen.width div 2) - (width div 2);
   Top := (screen.height div 2) - (height div 2);
   m_bMoving := FALSE;
   lblTitle.Left := 2;
   lblTitle.Top := 2;
   lblTitle.Width := clientwidth - 4;
   lblTitle.Height := 17;
   lblTitle.Color := clBlue;
end;

procedure TfrmExport.lblTitleMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := TRUE;
   m_nX := x;
   m_nY := y;
end;

procedure TfrmExport.lblTitleMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   if (m_bMoving) then
   begin
      left := left + (x - m_nX);
      top := top + (y - m_nY);
   end;
end;

procedure TfrmExport.lblTitleMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := FALSE;
end;

procedure TfrmExport.FormPaint(Sender: TObject);
begin
   Canvas.Pen.Color := clBlack;
   Canvas.Brush.Color := rgb(240,240,240);
   Canvas.Rectangle(0,0,clientwidth,clientheight);
end;

end.

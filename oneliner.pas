unit oneliner;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TfrmLiner = class(TForm)
    cmdOK: TButton;
    cmdCancel: TButton;
    m_strLineWidth: TEdit;
    Label1: TLabel;
    lblHeading: TLabel;
    Label3: TLabel;
    cmdColour: TButton;
    cd: TColorDialog;
    cmdApplyAll: TButton;
    m_strAlpha: TEdit;
    alphaBar: TTrackBar;
    Label2: TLabel;
    procedure cmdOKClick(Sender: TObject);
    procedure cmdCancelClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lblHeadingMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblHeadingMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lblHeadingMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure m_strLineWidthChange(Sender: TObject);
    procedure cmdColourClick(Sender: TObject);
    procedure cmdApplyAllClick(Sender: TObject);
    procedure m_strAlphaChange(Sender: TObject);
    procedure alphaBarChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    m_nX, m_nY : integer;
    m_bOK, m_bMoving : BOOLEAN;
    m_bApplyAll : boolean;
    m_Colour : TColor;
    m_nLineWidth : integer;
    m_nAlpha : integer;
  end;

implementation

{$R *.dfm}

procedure TfrmLiner.cmdOKClick(Sender: TObject);
begin
   m_bApplyAll := FALSE;
   m_bOk := TRUE;
   Close;
end;

procedure TfrmLiner.cmdCancelClick(Sender: TObject);
begin
   m_bOk := FALSE;
   Close;
end;

procedure TfrmLiner.FormPaint(Sender: TObject);
begin
   Canvas.Pen.Width := 1;
   Canvas.Pen.Color := clBlack;
   Canvas.Brush.Color := rgb(240,240,240);
   Canvas.Rectangle(0,0,width,height);

   Canvas.Pen.Width := m_nLineWidth;
   Canvas.Pen.Color := m_Colour;
   Canvas.MoveTo(170,40);
   Canvas.LineTo(300,80);

   Canvas.Pen.Width := 1;
   Canvas.Pen.Color := m_Colour;
   Canvas.Brush.Color := m_Colour;
   Canvas.FillRect(rect(72,32,95,55));

end;

procedure TfrmLiner.FormCreate(Sender: TObject);
begin
   lblHeading.Left := 2;
   lblHeading.Top := 2;
   lblHeading.Width := width - 4;
   lblHeading.Height := 17;
   lblHeading.Color := clBlue;
end;

procedure TfrmLiner.lblHeadingMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := TRUE;
   m_nX := x;
   m_nY := y;
end;

procedure TfrmLiner.lblHeadingMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   if (m_bMoving) then
   begin
      Left := Left + (x - m_nX);
      Top := Top + (y - m_nY);
   end;
end;

procedure TfrmLiner.lblHeadingMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := FALSE;
end;

procedure TfrmLiner.m_strAlphaChange(Sender: TObject);
begin
   if (m_strAlpha.Text <> '') then
   begin
      m_nAlpha := strtoint(m_strAlpha.Text);
      alphaBar.Position := m_nAlpha; 
   end;
end;

procedure TfrmLiner.m_strLineWidthChange(Sender: TObject);
begin
   if (m_strLinewidth.Text <> '') then
   begin
      m_nLineWidth := strtoint(m_strLineWidth.Text);
      Repaint;
   end;
end;

procedure TfrmLiner.cmdColourClick(Sender: TObject);
begin
   if (cd.Execute) then
   begin
      m_Colour := cd.Color;
   end;
   RePaint;
end;

procedure TfrmLiner.alphaBarChange(Sender: TObject);
begin
   m_nAlpha := alphaBAr.Position;
   m_strAlpha.Text := inttostr(m_nAlpha);
end;

procedure TfrmLiner.cmdApplyAllClick(Sender: TObject);
begin
   m_bApplyAll := TRUE;
   m_bOk := TRUE;
   Close;
end;

end.

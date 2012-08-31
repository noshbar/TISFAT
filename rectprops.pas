unit rectprops;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, main, ComCtrls;

type
  TfrmRectProps = class(TForm)
    lblTitle: TLabel;
    cmdOK: TButton;
    cmdCancel: TButton;
    cmdOutercolour: TButton;
    cmdInnerColour: TButton;
    m_strLineWidth: TEdit;
    Label1: TLabel;
    cd: TColorDialog;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    alphaBar: TTrackBar;
    Label2: TLabel;
    m_strAlpha: TEdit;
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
    procedure cmdPreviewClick(Sender: TObject);
    procedure cmdOutercolourClick(Sender: TObject);
    procedure cmdInnerColourClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure m_strLineWidthChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure m_strAlphaChange(Sender: TObject);
    procedure alphaBarChange(Sender: TObject);
  private
    m_bMoving : boolean;
    m_nX, m_nY : integer;
  public
    m_nAlpha : integer;
    m_bOk : boolean;
    m_bApplyAll : boolean;
    m_nLineWidth : integer;
    m_InColour, m_OutColour : TColor;
    m_nType : integer;
    m_styleOuter : TPenStyle;
    m_styleInner : TBrushStyle;
  end;

implementation

{$R *.dfm}

procedure TfrmRectProps.FormCreate(Sender: TObject);
begin
   Color := rgb(240,240,240);
   lblTitle.Width := ClientWidth - 4;
end;

procedure TfrmRectProps.FormPaint(Sender: TObject);
begin
   Canvas.Pen.Color := clBlack;
   Canvas.Pen.Width := 1;
   Canvas.Brush.Color := rgb(240,240,240);
   Canvas.Rectangle(0,0,ClientWidth,ClientHeight);
   Canvas.Pen.Color := m_OutColour;
   Canvas.Pen.Width := m_nLineWidth;
   Canvas.Pen.Style := m_styleOuter;
   Canvas.Brush.Color := m_InColour;
   Canvas.Brush.Style := m_styleInner;
   if (m_nType = O_RECTANGLE) or (m_nType = O_POLY) then Canvas.Rectangle(150,50,250,170);
   if (m_nType = O_OVAL) then Canvas.Ellipse(150,50,250,170);
end;

procedure TfrmRectProps.lblTitleMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_nX := x;
   m_nY := y;
   m_bMoving := TRUE;
end;

procedure TfrmRectProps.lblTitleMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   if (m_bMoving) then
   begin
      Left := Left + (X - m_nX);
      Top := Top + (Y - m_nY);
   end;
end;

procedure TfrmRectProps.lblTitleMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := FALSE;
end;

procedure TfrmRectProps.cmdOKClick(Sender: TObject);
begin
   m_nLineWidth := strtoint(m_strLineWidth.Text);
   m_nAlpha := strtoint(m_strAlpha.Text);
      if (m_nAlpha > 255) then
         m_nAlpha := 255;
      if (m_nAlpha < 0) then
         m_nAlpha := 0;
   m_bApplyAll := FALSE;
   m_bOk := TRUE;
   Close;
end;

procedure TfrmRectProps.cmdCancelClick(Sender: TObject);
begin
   m_bOk := FALSE;
   Close;
end;

procedure TfrmRectProps.cmdPreviewClick(Sender: TObject);
begin
   m_nLineWidth := strtoint(m_strLineWidth.Text);
   Repaint;
end;

procedure TfrmRectProps.cmdOutercolourClick(Sender: TObject);
begin
   if (cd.Execute) then
   begin
      m_OutColour := cd.Color;
      m_styleOuter := psSolid;
   end;
   Repaint;
end;

procedure TfrmRectProps.cmdInnerColourClick(Sender: TObject);
begin
   if (cd.Execute) then
   begin
      m_InColour := cd.Color;
      m_styleInner := bsSolid;
   end;
   Repaint;
end;

procedure TfrmRectProps.FormShow(Sender: TObject);
begin
   m_strLineWidth.Text := inttostr(m_nLineWidth);
end;

procedure TfrmRectProps.m_strAlphaChange(Sender: TObject);
begin
   if (m_strAlpha.Text <> '') then
   begin
      m_nAlpha := strtoint(m_strAlpha.Text);
      alphaBar.Position := m_nAlpha; 
   end;
end;

procedure TfrmRectProps.m_strLineWidthChange(Sender: TObject);
begin
   if (m_strLineWidth.Text <> '') then
   begin
      m_nLineWidth := strtoint(m_strLinewidth.Text);
      Repaint;
   end;
end;

procedure TfrmRectProps.alphaBarChange(Sender: TObject);
begin
   m_nAlpha := alphaBAr.Position;
   m_strAlpha.Text := inttostr(m_nAlpha);
end;

procedure TfrmRectProps.Button1Click(Sender: TObject);
begin
   m_nLineWidth := strtoint(m_strLineWidth.Text);
   m_nAlpha := strtoint(m_strAlpha.Text);
      if (m_nAlpha > 255) then
         m_nAlpha := 255;
      if (m_nAlpha < 0) then
         m_nAlpha := 0;
   m_bApplyAll := TRUE;
   m_bOk := TRUE;
   Close;
end;

procedure TfrmRectProps.Button2Click(Sender: TObject);
begin
   m_styleOuter := psClear;
   Repaint;
end;

procedure TfrmRectProps.Button3Click(Sender: TObject);
begin
   m_styleInner := bsClear;
   Repaint;
end;

end.

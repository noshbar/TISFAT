unit textprops;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TfrmTextProps = class(TForm)
    cmdOuterColour: TButton;
    Label1: TLabel;
    lblColour: TLabel;
    cd: TColorDialog;
    cmdCancel: TButton;
    lblTitle: TLabel;
    cmdClearColour: TButton;
    cmdApply: TButton;
    cmdApplyAll: TButton;
    cboFontNames: TComboBox;
    cmdChangeInnerColour: TButton;
    Label2: TLabel;
    lblFontColour: TLabel;
    m_strCaption: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    chkBold: TCheckBox;
    chkUnderlined: TCheckBox;
    chkItalic: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure cmdOuterColourClick(Sender: TObject);
    procedure cmdCancelClick(Sender: TObject);
    procedure lblTitleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblTitleMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lblTitleMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormPaint(Sender: TObject);
    procedure cmdClearColourClick(Sender: TObject);
    procedure cmdApplyClick(Sender: TObject);
    procedure cmdApplyAllClick(Sender: TObject);
    procedure cmdChangeInnerColourClick(Sender: TObject);
    procedure cboFontNamesChange(Sender: TObject);
    procedure m_strCaptionChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure chkItalicClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    m_bOK : boolean;
    m_bMoving : boolean;
    m_nX, m_nY : integer;
    m_styleOuter : TBrushStyle;
    m_bApplyall : boolean;
    m_strFontName : string;
    m_FontStyle : TFontStyles;
    m_InnerColour, m_OuterColour : TColor;
  end;

implementation

{$R *.dfm}

procedure TfrmTextProps.FormCreate(Sender: TObject);
begin
   left := (screen.width div 2) - (clientwidth div 2);
   top := (screen.height div 2) - (clientheight div 2);
   doublebuffered := TRUE;
   lblTitle.LEft := 2;
   lblTitle.Top := 2;
   lblTitle.Width := clientwidth - 4;
   lblTitle.Height := 17;
   lblTitle.Color := clBlue;
   cboFontNames.Items := screen.fonts;
   cboFontNames.ItemIndex := cboFontNames.Items.IndexOf('Arial');
   m_strFontName := 'Arial';

   chkBold.Color := rgb(240,240,240);
   chkUnderlined.Color := rgb(240,240,240);
   chkItalic.Color := rgb(240,240,240);

end;

procedure TfrmTextProps.cmdOuterColourClick(Sender: TObject);
begin
   if (cd.Execute) then
   begin
      lblColour.Color := cd.Color;
      m_styleOuter := bsSolid;
   end;
   Repaint;
end;

procedure TfrmTextProps.cmdCancelClick(Sender: TObject);
begin
   m_bOK := FALSE;
   Close;
end;

procedure TfrmTextProps.lblTitleMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := TRUE;
   m_nX := x;
   m_nY := y;
end;

procedure TfrmTextProps.lblTitleMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   if (m_bMoving) then
   begin
      left := left + (x - m_nX);
      top := top + (y - m_nY);
   end;
end;

procedure TfrmTextProps.lblTitleMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := FALSE;
end;

procedure TfrmTextProps.FormPaint(Sender: TObject);
begin
   Canvas.Brush.Color := rgb(240,240,240);
   Canvas.Pen.Color := clBlack;
   Canvas.Rectangle(0,0,ClientWidth,ClientHeight);
   Canvas.Brush.Color := lblColour.Color;
   Canvas.Brush.Style := m_styleOuter;
   Canvas.Font.Color := m_InnerColour;
   Canvas.font.Name := m_strFontName;
   Canvas.Font.Style := m_FontStyle;
   Canvas.Font.Height := 40;
   Canvas.TextOut(10,145, m_strCaption.Text);
end;

procedure TfrmTextProps.cmdClearColourClick(Sender: TObject);
begin
   m_styleOuter := bsClear;
   Repaint;
end;

procedure TfrmTextProps.cmdApplyClick(Sender: TObject);
begin
   m_bOk := TRUE;
   m_bApplyAll := fALSE;
   close;
end;

procedure TfrmTextProps.cmdApplyAllClick(Sender: TObject);
begin
   m_bOk := TRUE;
   m_bApplyAll := TRUE;
   close;
end;

procedure TfrmTextProps.cmdChangeInnerColourClick(Sender: TObject);
begin
   if (cd.Execute) then
   begin
      lblFontColour.Color := cd.Color;
      m_InnerColour := cd.Color;
   end;
   Repaint;
end;

procedure TfrmTextProps.cboFontNamesChange(Sender: TObject);
begin
   m_strFontName := cboFontNames.Items[cboFontNames.ItemIndex];
   repaint;
end;

procedure TfrmTextProps.m_strCaptionChange(Sender: TObject);
begin
   Repaint;
end;

procedure TfrmTextProps.FormShow(Sender: TObject);
begin
   m_strCaption.SetFocus;
end;

procedure TfrmTextProps.chkItalicClick(Sender: TObject);
begin
   if (not chkBold.Checked) and (not chkItalic.Checked) and (not chkUnderlined.Checked) then
   begin
      m_FontStyle := [];
   end;
   if (chkBold.Checked) and (not chkItalic.Checked) and (not chkUnderlined.Checked) then
   begin
      m_FontStyle := [fsBold];
   end;
   if (not chkBold.Checked) and (chkItalic.Checked) and (not chkUnderlined.Checked) then
   begin
      m_FontStyle := [fsItalic];
   end;
   if (not chkBold.Checked) and (not chkItalic.Checked) and (chkUnderlined.Checked) then
   begin
      m_FontStyle := [fsUnderline];
   end;
   if (chkBold.Checked) and (chkItalic.Checked) and (not chkUnderlined.Checked) then
   begin
      m_FontStyle := [fsBold, fsItalic];
   end;
   if (not chkBold.Checked) and (chkItalic.Checked) and (chkUnderlined.Checked) then
   begin
      m_FontStyle := [fsItalic, fsUnderline];
   end;
   if (chkBold.Checked) and (not chkItalic.Checked) and (chkUnderlined.Checked) then
   begin
      m_FontStyle := [fsBold, fsUnderline];
   end;
   if (chkBold.Checked) and (chkItalic.Checked) and (chkUnderlined.Checked) then
   begin
      m_FontStyle := [fsBold, fsItalic, fsUnderline];
   end;
   Repaint;
end;

end.

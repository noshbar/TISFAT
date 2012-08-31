unit stickprops;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, main, math, jpeg, ComCtrls;

type
  TfrmStickProps = class(TForm)
    lblTitle: TLabel;
    m_strHeadDiam: TEdit;
    m_strLeftArmTop: TEdit;
    m_strLeftArmBot: TEdit;
    m_strLeftLegTop: TEdit;
    m_strLeftLegBot: TEdit;
    m_strRightArmTop: TEdit;
    m_strRightArmBot: TEdit;
    m_strBodyLength: TEdit;
    m_strRightLegTop: TEdit;
    m_strRightLegBot: TEdit;
    cmdDone: TButton;
    cmdCancel: TButton;
    cmdPreview: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    Edit10: TEdit;
    cmdDefaults: TButton;
    cmdSetAll: TButton;
    m_strWidths: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    cmdInnerColour: TButton;
    cmdOuterColour: TButton;
    lblColour1: TLabel;
    lblColour2: TLabel;
    cd: TColorDialog;
    Label22: TLabel;
    Button1: TButton;
    m_strAlpha: TEdit;
    Label23: TLabel;
    alphaBar: TTrackBar;
    procedure FormCreate(Sender: TObject);
    procedure lblTitleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblTitleMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lblTitleMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormPaint(Sender: TObject);
    procedure cmdCancelClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cmdPreviewClick(Sender: TObject);
    procedure cmdDoneClick(Sender: TObject);
    procedure cmdSetAllClick(Sender: TObject);
    procedure cmdInnerColourClick(Sender: TObject);
    procedure cmdOuterColourClick(Sender: TObject);
    procedure m_strHeadDiamChange(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure m_strLeftArmTopChange(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    procedure Edit3Change(Sender: TObject);
    procedure Edit4Change(Sender: TObject);
    procedure Edit5Change(Sender: TObject);
    procedure Edit6Change(Sender: TObject);
    procedure Edit7Change(Sender: TObject);
    procedure Edit8Change(Sender: TObject);
    procedure Edit9Change(Sender: TObject);
    procedure Edit10Change(Sender: TObject);
    procedure lblColour1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblColour2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button1Click(Sender: TObject);
    procedure alphaBarChange(Sender: TObject);
    procedure m_strAlphaChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    m_nX, m_nY : integer;
    m_bMoving : boolean;
    m_SickMan : TStickMan;
    m_bOk : boolean;
    m_bApplyAll : boolean;
    m_nAlpha : integer;
    procedure Draw;
    procedure LinkLine(x1,y1,x2,y2 : integer);
  end;

implementation

{$R *.dfm}

procedure TfrmStickProps.FormCreate(Sender: TObject);
begin
   m_SickMan := TStickMan.Create(self, 0,0,0,0,0,0,0,0,0);
   Color := rgb(240,240,240);
   lblTitle.Left := 2;
   lblTitle.Top := 2;
   lblTitle.Width := ClientWidth - 4;
end;

procedure TfrmStickProps.lblTitleMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_nX := x;
   m_nY := y;
   m_bMoving := TRUE;
end;

procedure TfrmStickProps.lblTitleMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   if (m_bMoving) then
   begin
      Left := Left + (X - m_nX);
      Top := Top + (Y - m_nY);
   end;
end;

procedure TfrmStickProps.lblTitleMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := FALSE;
end;

procedure TfrmStickProps.LinkLine(x1,y1,x2,y2 : integer);
begin
   Canvas.MoveTo(x1,y1);
   Canvas.LineTo(x2,y2);
   Canvas.Ellipse(x1-4,y1-4,x1+4,y1+4);
   Canvas.Ellipse(x2-4,y2-4,x2+4,y2+4);
end;

procedure TfrmStickProps.FormPaint(Sender: TObject);
begin
   Canvas.Pen.Width := 1;
   Canvas.Pen.Color := clBlack;
   Canvas.Brush.Color := rgb(240,240,240);
   Canvas.Rectangle(0,0,Width,Height);

   Canvas.Pen.Width := 4;
   Canvas.Pen.Color := clBlack;
   Canvas.Brush.Style := bsClear;
   Canvas.Ellipse(166,36,211,79);

   Canvas.MoveTo(184,80);
   Canvas.LineTo(163,173);

   Canvas.MoveTo(179,99);
   Canvas.LineTo(150,123);
   Canvas.LineTo(141,159);

   Canvas.MoveTo(179,99);
   Canvas.LineTo(195,124);
   Canvas.LineTo(235,129);

   Canvas.MoveTo(163,173);
   Canvas.LineTo(152,202);
   Canvas.LineTo(134,239);

   Canvas.MoveTo(163,173);
   Canvas.LineTo(192,202);
   Canvas.LineTo(203,245);

   Canvas.Pen.Color := rgb(100,100,255);
   Canvas.Pen.Width := 2;

   LinkLine(89,31,163,41);
   LinkLine(89,82,159,104);
   LinkLine(89,129,138,136);
   LinkLine(89,177,151,188);
   LinkLine(89,229,137,218);
   LinkLine(192,104,300,58);
   LinkLine(225,116,300,94);
   LinkLine(179,137,300,139);
   LinkLine(190,185,300,194);
   LinkLine(208,231,300,245);

   Canvas.Brush.Color := clBlue;
   Canvas.Brush.Style := bsSolid;
   Canvas.Pen.Width := 1;
   Canvas.Rectangle(180,76,  188,84);
   Canvas.Rectangle(146,119, 154,127);
   Canvas.Rectangle(137,155, 145,163);
   Canvas.Rectangle(175,95,  183,103);
   Canvas.Rectangle(191,120, 199,128);
   Canvas.Rectangle(231,125, 239,133);
   Canvas.Rectangle(148,198, 156,206);
   Canvas.Rectangle(130,235, 138,243);
   Canvas.Rectangle(188,198, 196,206);
   Canvas.Rectangle(199,241, 207,249);
end;

procedure TfrmStickProps.cmdCancelClick(Sender: TObject);
begin
   m_bOk := FALSE;
   Close;
end;

procedure TfrmStickProps.FormDestroy(Sender: TObject);
begin
   m_SickMan.Destroy;
end;

procedure TfrmStickProps.FormShow(Sender: TObject);
begin
   m_strHeadDiam.Text := inttostr(m_SickMan.m_nHeadDiam);
   m_strLeftLegTop.Text := inttostr(m_SickMan.Lng[1]);
   m_strLeftLegBot.Text := inttostr(m_SickMan.Lng[2]);
   m_strRightLegTop.Text := inttostr(m_SickMan.Lng[3]);
   m_strRightLegBot.Text := inttostr(m_SickMan.Lng[4]);
   m_strBodyLength.Text := inttostr(m_SickMan.Lng[5]);
   m_strLeftArmTop.Text := inttostr(m_SickMan.Lng[6]);
   m_strLeftArmBot.Text := inttostr(m_SickMan.Lng[7]);
   m_strRightArmTop.Text := inttostr(m_SickMan.Lng[8]);
   m_strRightArmBot.Text := inttostr(m_SickMan.Lng[9]);
   Edit1.Text := inttostr(m_SickMan.Wid[10]);
   Edit2.Text := inttostr(m_SickMan.Wid[6]);
   Edit3.Text := inttostr(m_SickMan.Wid[7]);
   Edit4.Text := inttostr(m_SickMan.Wid[1]);
   Edit5.Text := inttostr(m_SickMan.Wid[2]);
   Edit6.Text := inttostr(m_SickMan.Wid[8]);
   Edit7.Text := inttostr(m_SickMan.Wid[9]);
   Edit8.Text := inttostr(m_SickMan.Wid[5]);
   Edit9.Text := inttostr(m_SickMan.Wid[3]);
   Edit10.Text := inttostr(m_SickMan.Wid[4]);
   lblColour1.Color := m_SickMan.m_InColour;
   lblColour2.Color := m_SickMan.m_OutColour;
   m_strAlpha.Text := inttostr(m_SickMan.m_alpha);
   alphaBar.Position := m_SickMan.m_alpha;
   Draw;
end;

procedure TfrmStickProps.cmdPreviewClick(Sender: TObject);
begin
   m_SickMan.Lng[1] := strtoint(m_strLeftLegTop.Text);
   m_SickMan.Lng[2] := strtoint(m_strLeftLegBot.Text);
   m_SickMan.Lng[3] := strtoint(m_strRightLegTop.Text);
   m_SickMan.Lng[4] := strtoint(m_strRightLegBot.Text);
   m_SickMan.Lng[5] := strtoint(m_strBodyLength.Text);
   m_SickMan.Lng[6] := strtoint(m_strLeftArmTop.Text);
   m_SickMan.Lng[7] := strtoint(m_strLeftArmBot.Text);
   m_SickMan.Lng[8] := strtoint(m_strRightArmTop.Text);
   m_SickMan.Lng[9] := strtoint(m_strRightArmBot.Text);
   m_SickMan.Wid[10] := strtoint(Edit1.Text);
   m_SickMan.Wid[6] := strtoint(Edit2.Text);
   m_SickMan.Wid[7] := strtoint(Edit3.Text);
   m_SickMan.Wid[1] := strtoint(Edit4.Text);
   m_SickMan.Wid[2] := strtoint(Edit5.Text);
   m_SickMan.Wid[8] := strtoint(Edit6.Text);
   m_SickMan.Wid[9] := strtoint(Edit7.Text);
   m_SickMan.Wid[5] := strtoint(Edit8.Text);
   m_SickMan.Wid[3] := strtoint(Edit9.Text);
   m_SickMan.Wid[4] := strtoint(Edit10.Text);
   m_SickMan.m_nHeadDiam := strtoint(m_strHeadDiam.Text);
   m_SickMan.SetPoint(m_SickMan.Pnt(1)^.Left,m_SickMan.Pnt(1)^.Top,1,1);
   m_SickMan.m_InColour := lblColour1.Color;
   m_SickMan.m_OutColour := lblColour2.Color;
   Repaint;
   Draw;
end;

procedure TfrmStickProps.Draw;
var
   f : integer;
   pFrame : TSingleFramePtr;
   bRender : boolean;
   angle : double;
   Rads : double;
   cx, cy : double;
   cenx, ceny : integer;
   nWide, nHigh : integer;
begin

   nWide := 3;
   nHigh := 3;
   with m_SickMan do
   begin

      cenx := Pnt(1)^.Left + nWide;
      ceny := Pnt(1)^.Top + nHigh;
      for f := 1 to 10 do
      begin
         Pnt(f)^.Left := Pnt(f)^.Left - cenx;
         Pnt(f)^.Top := Pnt(f)^.Top - ceny;
         Pnt(f)^.Left := Pnt(f)^.Left + 480;
         Pnt(f)^.Top := Pnt(f)^.Top + 150;
      end;

      Canvas.Pen.Color := m_OutColour;
      Canvas.Brush.Color := m_OutColour;
        Canvas.Pen.Width := Wid[5];
        Canvas.MoveTo(Pnt(6)^.Left+nWide, Pnt(6)^.Top+nHigh);
        Canvas.LineTo(Pnt(1)^.Left+nWide, Pnt(1)^.Top+nHigh);

        Canvas.Pen.Width := Wid[1];
        Canvas.MoveTo(Pnt(1)^.Left+nWide, Pnt(1)^.Top+nHigh);
        Canvas.LineTo(Pnt(2)^.Left+nWide, Pnt(2)^.Top+nHigh);
        Canvas.Pen.Width := Wid[2];
        Canvas.MoveTo(Pnt(2)^.Left+nWide, Pnt(2)^.Top+nHigh);
        Canvas.LineTo(Pnt(3)^.Left+nWide, Pnt(3)^.Top+nHigh);

        Canvas.Pen.Width := Wid[3];
        Canvas.MoveTo(Pnt(1)^.Left+nWide, Pnt(1)^.Top+nHigh);
        Canvas.LineTo(Pnt(4)^.Left+nWide, Pnt(4)^.Top+nHigh);
        Canvas.Pen.Width := Wid[4];
        Canvas.MoveTo(Pnt(4)^.Left+nWide, Pnt(4)^.Top+nHigh);
        Canvas.LineTo(Pnt(5)^.Left+nWide, Pnt(5)^.Top+nHigh);

        Canvas.Pen.Width := Wid[6];
        Canvas.MoveTo(Pnt(6)^.Left+nWide, Pnt(6)^.Top+nHigh);
        Canvas.LineTo(Pnt(7)^.Left+nWide, Pnt(7)^.Top+nHigh);
        Canvas.Pen.Width := Wid[7];
        Canvas.MoveTo(Pnt(7)^.Left+nWide, Pnt(7)^.Top+nHigh);
        Canvas.LineTo(Pnt(8)^.Left+nWide, Pnt(8)^.Top+nHigh);

        Canvas.Pen.Width := Wid[8];
        Canvas.MoveTo(Pnt(6)^.Left+nWide, Pnt(6)^.Top+nHigh);
        Canvas.LineTo(Pnt(9)^.Left+nWide, Pnt(9)^.Top+nHigh);
        Canvas.Pen.Width := Wid[9];
        Canvas.MoveTo(Pnt(9)^.Left+nWide, Pnt(9)^.Top+nHigh);
        Canvas.LineTo(Pnt(10)^.Left+nWide, Pnt(10)^.Top+nHigh);

        angle := 180 * (1 + ArcTan2(Pnt(6)^.Top-Pnt(1)^.Top, Pnt(6)^.Left-Pnt(1)^.Left) / PI);
        if angle >= 360.0 then angle := angle - 360.0;
        angle := angle - 175;
        Rads := DegToRad(angle);
        cx := (m_nHeadDiam div 2+3) * Cos(Rads);
        cy := (m_nHeadDiam div 2+3) * Sin(Rads);
        cx := Pnt(6)^.Left+cx;
        cy := Pnt(6)^.Top+cy;
        Canvas.Pen.Width := Wid[10];
      Canvas.Pen.Color := m_OutColour;
      Canvas.Brush.Color := m_InColour;
        Canvas.Ellipse(round(cx-(m_nHeadDiam div 2)),round(cy-(m_nHeadDiam div 2)),round(cx+(m_nHeadDiam div 2)),round(cy+(m_nHeadDiam div 2)));
        Canvas.Pen.Width := Wid[5];
        Canvas.MoveTo(Pnt(6)^.Left+nWide, Pnt(6)^.Top+nHigh);
      Canvas.Pen.Color := m_OutColour;
      Canvas.Brush.Color := m_OutColour;
        cx := (4) * Cos(Rads);
        cy := (4) * Sin(Rads);
        cx := Pnt(6)^.Left+cx;
        cy := Pnt(6)^.Top+cy;
        Canvas.LineTo(round(cx),round(cy));
   end;  

   // m_SickMan.Draw;
end;

procedure TfrmStickProps.cmdDoneClick(Sender: TObject);
begin
   m_SickMan.Lng[1] := strtoint(m_strLeftLegTop.Text);
   m_SickMan.Lng[2] := strtoint(m_strLeftLegBot.Text);
   m_SickMan.Lng[3] := strtoint(m_strRightLegTop.Text);
   m_SickMan.Lng[4] := strtoint(m_strRightLegBot.Text);
   m_SickMan.Lng[5] := strtoint(m_strBodyLength.Text);
   m_SickMan.Lng[6] := strtoint(m_strLeftArmTop.Text);
   m_SickMan.Lng[7] := strtoint(m_strLeftArmBot.Text);
   m_SickMan.Lng[8] := strtoint(m_strRightArmTop.Text);
   m_SickMan.Lng[9] := strtoint(m_strRightArmBot.Text);
   m_SickMan.Wid[10] := strtoint(Edit1.Text);
   m_SickMan.Wid[6] := strtoint(Edit2.Text);
   m_SickMan.Wid[7] := strtoint(Edit3.Text);
   m_SickMan.Wid[1] := strtoint(Edit4.Text);
   m_SickMan.Wid[2] := strtoint(Edit5.Text);
   m_SickMan.Wid[8] := strtoint(Edit6.Text);
   m_SickMan.Wid[9] := strtoint(Edit7.Text);
   m_SickMan.Wid[5] := strtoint(Edit8.Text);
   m_SickMan.Wid[3] := strtoint(Edit9.Text);
   m_SickMan.Wid[4] := strtoint(Edit10.Text);
   m_SickMan.m_nHeadDiam := strtoint(m_strHeadDiam.Text);
   m_SickMan.SetPoint(m_SickMan.Pnt(1)^.Left,m_SickMan.Pnt(1)^.Top,1,1);
   m_SickMan.m_InColour := lblColour1.Color;
   m_SickMan.m_OutColour := lblColour2.Color;
   if (m_nAlpha > 255) then
      m_nAlpha := 255;
   if (m_nAlpha < 0) then
      m_nAlpha := 0;
   m_SickMan.m_alpha := m_nAlpha;
   m_bApplyAll := FALSE;
   m_bOK := TRUE;
   Close;
end;

procedure TfrmStickProps.cmdSetAllClick(Sender: TObject);
var
   f : integer;
begin
   for f := 1 to 10 do
   begin
      m_SickMan.Wid[f] := strtoint(m_strWidths.Text);
   end;
   Edit1.Text := inttostr(m_SickMan.Wid[10]);
   Edit2.Text := inttostr(m_SickMan.Wid[6]);
   Edit3.Text := inttostr(m_SickMan.Wid[7]);
   Edit4.Text := inttostr(m_SickMan.Wid[1]);
   Edit5.Text := inttostr(m_SickMan.Wid[2]);
   Edit6.Text := inttostr(m_SickMan.Wid[8]);
   Edit7.Text := inttostr(m_SickMan.Wid[9]);
   Edit8.Text := inttostr(m_SickMan.Wid[5]);
   Edit9.Text := inttostr(m_SickMan.Wid[3]);
   Edit10.Text := inttostr(m_SickMan.Wid[4]);
   Repaint;
   Draw;
end;

procedure TfrmStickProps.cmdInnerColourClick(Sender: TObject);
begin
   cd.Color := lblColour1.Color;
   if (cd.Execute) then
   begin
      lblColour1.Color := cd.Color;
      Repaint;
      Draw;
   end;
end;

procedure TfrmStickProps.cmdOuterColourClick(Sender: TObject);
begin
   cd.Color := lblColour2.Color;
   if (cd.Execute) then
   begin
      lblColour2.Color := cd.Color;
      Repaint;
      Draw;
   end;
end;

procedure TfrmStickProps.m_strAlphaChange(Sender: TObject);
begin
   if (m_strAlpha.Text <> '') then
   begin
      m_nAlpha := strtoint(m_strAlpha.Text);
      alphaBar.Position := m_nAlpha;
   end;
end;

procedure TfrmStickProps.m_strHeadDiamChange(Sender: TObject);
begin
   if (m_strHeadDiam.Text <> '') then
   begin
     m_SickMan.m_nHeadDiam := strtoint(m_strHeadDiam.Text);
     Repaint;
     Draw;
   end;
end;

procedure TfrmStickProps.Edit1Change(Sender: TObject);
begin
   if (Edit1.Text <> '') then
   begin
     m_SickMan.Wid[10] := strtoint(Edit1.Text);
     Repaint;
     Draw;
   end;
end;

procedure TfrmStickProps.m_strLeftArmTopChange(Sender: TObject);
begin
   if (m_strLeftArmTop.Text <> '') then
   begin
     m_SickMan.Lng[6] := strtoint(m_strLeftArmTop.Text);
     m_SickMan.SetPoint(m_SickMan.Pnt(1)^.Left,m_SickMan.Pnt(1)^.Top,1,1);
     Repaint;
     Draw;
   end;
end;

procedure TfrmStickProps.Edit2Change(Sender: TObject);
begin
   if (Edit2.Text <> '') then
   begin
     m_SickMan.Wid[6] := strtoint(Edit2.Text);
     Repaint;
     Draw;
   end;
end;

procedure TfrmStickProps.Edit3Change(Sender: TObject);
begin
   if (Edit3.Text <> '') then
   begin
     m_SickMan.Wid[7] := strtoint(Edit3.Text);
     Repaint;
     Draw;
   end;
end;

procedure TfrmStickProps.Edit4Change(Sender: TObject);
begin
   if (Edit4.Text <> '') then
   begin
     m_SickMan.Wid[1] := strtoint(Edit4.Text);
     Repaint;
     Draw;
   end;
end;

procedure TfrmStickProps.Edit5Change(Sender: TObject);
begin
   if (Edit5.Text <> '') then
   begin
     m_SickMan.Wid[2] := strtoint(Edit5.Text);
     Repaint;
     Draw;
   end;
end;

procedure TfrmStickProps.Edit6Change(Sender: TObject);
begin
   if (Edit6.Text <> '') then
   begin
     m_SickMan.Wid[8] := strtoint(Edit6.Text);
     Repaint;
     Draw;
   end;
end;

procedure TfrmStickProps.Edit7Change(Sender: TObject);
begin
   if (Edit7.Text <> '') then
   begin
     m_SickMan.Wid[9] := strtoint(Edit7.Text);
     Repaint;
     Draw;
   end;
end;

procedure TfrmStickProps.Edit8Change(Sender: TObject);
begin
   if (Edit8.Text <> '') then
   begin
     m_SickMan.Wid[5] := strtoint(Edit8.Text);
     Repaint;
     Draw;
   end;
end;

procedure TfrmStickProps.Edit9Change(Sender: TObject);
begin
   if (Edit9.Text <> '') then
   begin
     m_SickMan.Wid[3] := strtoint(Edit9.Text);
     Repaint;
     Draw;
   end;
end;

procedure TfrmStickProps.Edit10Change(Sender: TObject);
begin
   if (Edit10.Text <> '') then
   begin
     m_SickMan.Wid[4] := strtoint(Edit10.Text);
     Repaint;
     Draw;
   end;
end;

procedure TfrmStickProps.lblColour1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   cmdInnerColour.Click;
end;

procedure TfrmStickProps.lblColour2MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   cmdOuterColour.Click;
end;

procedure TfrmStickProps.alphaBarChange(Sender: TObject);
begin
   m_strAlpha.Text := inttostr(alphaBar.Position);
   m_nAlpha := alphaBar.Position;
end;

procedure TfrmStickProps.Button1Click(Sender: TObject);
begin
   m_SickMan.Lng[1] := strtoint(m_strLeftLegTop.Text);
   m_SickMan.Lng[2] := strtoint(m_strLeftLegBot.Text);
   m_SickMan.Lng[3] := strtoint(m_strRightLegTop.Text);
   m_SickMan.Lng[4] := strtoint(m_strRightLegBot.Text);
   m_SickMan.Lng[5] := strtoint(m_strBodyLength.Text);
   m_SickMan.Lng[6] := strtoint(m_strLeftArmTop.Text);
   m_SickMan.Lng[7] := strtoint(m_strLeftArmBot.Text);
   m_SickMan.Lng[8] := strtoint(m_strRightArmTop.Text);
   m_SickMan.Lng[9] := strtoint(m_strRightArmBot.Text);
   m_SickMan.Wid[10] := strtoint(Edit1.Text);
   m_SickMan.Wid[6] := strtoint(Edit2.Text);
   m_SickMan.Wid[7] := strtoint(Edit3.Text);
   m_SickMan.Wid[1] := strtoint(Edit4.Text);
   m_SickMan.Wid[2] := strtoint(Edit5.Text);
   m_SickMan.Wid[8] := strtoint(Edit6.Text);
   m_SickMan.Wid[9] := strtoint(Edit7.Text);
   m_SickMan.Wid[5] := strtoint(Edit8.Text);
   m_SickMan.Wid[3] := strtoint(Edit9.Text);
   m_SickMan.Wid[4] := strtoint(Edit10.Text);
   m_SickMan.m_nHeadDiam := strtoint(m_strHeadDiam.Text);
   m_SickMan.SetPoint(m_SickMan.Pnt(1)^.Left,m_SickMan.Pnt(1)^.Top,1,1);
   m_SickMan.m_InColour := lblColour1.Color;
   m_SickMan.m_OutColour := lblColour2.Color;
   if (m_nAlpha > 255) then
      m_nAlpha := 255;
   if (m_nAlpha < 0) then
      m_nAlpha := 0;
   m_SickMan.m_alpha := m_nAlpha;
   m_bApplyAll := TRUE;
   m_bOK := TRUE;
   Close;
end;

end.

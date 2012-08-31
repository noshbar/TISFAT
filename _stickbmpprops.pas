unit stickbmpprops;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, main, math, jpeg;

type
  TfrmStickBMPProps = class(TForm)
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
    cmdOuterColour: TButton;
    lblColour2: TLabel;
    cd: TColorDialog;
    Label22: TLabel;
    Button1: TButton;
    chkOpen: TCheckBox;
    chkFlip: TCheckBox;
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
    procedure lblColour2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button1Click(Sender: TObject);
    procedure chkOpenClick(Sender: TObject);
    procedure chkFlipClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    m_nX, m_nY : integer;
    m_bMoving : boolean;
    m_SickMan : TStickManBMP;
    m_bOk : boolean;
    m_bApplyAll : boolean;
    procedure Draw;
    procedure LinkLine(x1,y1,x2,y2 : integer);
  end;

implementation

{$R *.dfm}

procedure TfrmStickBMPProps.FormCreate(Sender: TObject);
begin
   left := screen.width div 2 - (width div 2);
   top := screen.height div 2 - (height div 2);
   m_SickMan := TStickManBMP.Create(self, 0,0,0,0,0,0,0,0,0);
   Color := rgb(240,240,240);
   lblTitle.Left := 2;
   lblTitle.Top := 2;
   lblTitle.Width := ClientWidth - 4;
   chkOpen.Color := rgb(240,240,240);
   chkFlip.Color := rgb(240,240,240);
   doublebuffered := TRUE;
end;

procedure TfrmStickBMPProps.lblTitleMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_nX := x;
   m_nY := y;
   m_bMoving := TRUE;
end;

procedure TfrmStickBMPProps.lblTitleMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   if (m_bMoving) then
   begin
      Left := Left + (X - m_nX);
      Top := Top + (Y - m_nY);
   end;
end;

procedure TfrmStickBMPProps.lblTitleMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := FALSE;
end;

procedure TfrmStickBMPProps.LinkLine(x1,y1,x2,y2 : integer);
begin
   Canvas.MoveTo(x1,y1);
   Canvas.LineTo(x2,y2);
   Canvas.Ellipse(x1-4,y1-4,x1+4,y1+4);
   Canvas.Ellipse(x2-4,y2-4,x2+4,y2+4);
end;

procedure TfrmStickBMPProps.FormPaint(Sender: TObject);
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

procedure TfrmStickBMPProps.cmdCancelClick(Sender: TObject);
begin
   m_bOk := FALSE;
   Close;
end;

procedure TfrmStickBMPProps.FormDestroy(Sender: TObject);
begin
   m_SickMan.Destroy;
end;

procedure TfrmStickBMPProps.FormShow(Sender: TObject);
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
   lblColour2.Color := m_SickMan.m_OutColour;
   chkOpen.Checked := m_SickMan.m_bMouthOpen;
   chkFlip.Checked := m_SickMan.m_bFlipped;
   Draw;
end;

procedure TfrmStickBMPProps.cmdPreviewClick(Sender: TObject);
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
   m_SickMan.SetPoint(m_SickMan.Pnt(1)^.Left,m_SickMan.Pnt(1)^.Top,1);
   m_SickMan.m_OutColour := lblColour2.Color;
   m_SickMan.m_bFlipped := chkFLip.Checked;
   m_SickMan.m_bMouthOpen := chkOpen.Checked;
   Repaint;
   Draw;
end;

procedure TfrmStickBMPProps.Draw;
begin

end;

procedure TfrmStickBMPProps.cmdDoneClick(Sender: TObject);
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
   m_SickMan.SetPoint(m_SickMan.Pnt(1)^.Left,m_SickMan.Pnt(1)^.Top,1);
   m_SickMan.m_OutColour := lblColour2.Color;
   m_bApplyAll := FALSE;
   m_bOK := TRUE;
   Close;
end;

procedure TfrmStickBMPProps.cmdSetAllClick(Sender: TObject);
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

procedure TfrmStickBMPProps.cmdOuterColourClick(Sender: TObject);
begin
   cd.Color := lblColour2.Color;
   if (cd.Execute) then
   begin
      lblColour2.Color := cd.Color;
      Repaint;
      Draw;
   end;
end;

procedure TfrmStickBMPProps.m_strHeadDiamChange(Sender: TObject);
begin
   if (m_strHeadDiam.Text <> '') then
   begin
     m_SickMan.m_nHeadDiam := strtoint(m_strHeadDiam.Text);
     Repaint;
     Draw;
   end;
end;

procedure TfrmStickBMPProps.Edit1Change(Sender: TObject);
begin
   if (Edit1.Text <> '') then
   begin
     m_SickMan.Wid[10] := strtoint(Edit1.Text);
     Repaint;
     Draw;
   end;
end;

procedure TfrmStickBMPProps.m_strLeftArmTopChange(Sender: TObject);
begin
   if (m_strLeftArmTop.Text <> '') then
   begin
     m_SickMan.Lng[6] := strtoint(m_strLeftArmTop.Text);
     m_SickMan.SetPoint(m_SickMan.Pnt(1)^.Left,m_SickMan.Pnt(1)^.Top,1);
     Repaint;
     Draw;
   end;
end;

procedure TfrmStickBMPProps.Edit2Change(Sender: TObject);
begin
   if (Edit2.Text <> '') then
   begin
     m_SickMan.Wid[6] := strtoint(Edit2.Text);
     Repaint;
     Draw;
   end;
end;

procedure TfrmStickBMPProps.Edit3Change(Sender: TObject);
begin
   if (Edit3.Text <> '') then
   begin
     m_SickMan.Wid[7] := strtoint(Edit3.Text);
     Repaint;
     Draw;
   end;
end;

procedure TfrmStickBMPProps.Edit4Change(Sender: TObject);
begin
   if (Edit4.Text <> '') then
   begin
     m_SickMan.Wid[1] := strtoint(Edit4.Text);
     Repaint;
     Draw;
   end;
end;

procedure TfrmStickBMPProps.Edit5Change(Sender: TObject);
begin
   if (Edit5.Text <> '') then
   begin
     m_SickMan.Wid[2] := strtoint(Edit5.Text);
     Repaint;
     Draw;
   end;
end;

procedure TfrmStickBMPProps.Edit6Change(Sender: TObject);
begin
   if (Edit6.Text <> '') then
   begin
     m_SickMan.Wid[8] := strtoint(Edit6.Text);
     Repaint;
     Draw;
   end;
end;

procedure TfrmStickBMPProps.Edit7Change(Sender: TObject);
begin
   if (Edit7.Text <> '') then
   begin
     m_SickMan.Wid[9] := strtoint(Edit7.Text);
     Repaint;
     Draw;
   end;
end;

procedure TfrmStickBMPProps.Edit8Change(Sender: TObject);
begin
   if (Edit8.Text <> '') then
   begin
     m_SickMan.Wid[5] := strtoint(Edit8.Text);
     Repaint;
     Draw;
   end;
end;

procedure TfrmStickBMPProps.Edit9Change(Sender: TObject);
begin
   if (Edit9.Text <> '') then
   begin
     m_SickMan.Wid[3] := strtoint(Edit9.Text);
     Repaint;
     Draw;
   end;
end;

procedure TfrmStickBMPProps.Edit10Change(Sender: TObject);
begin
   if (Edit10.Text <> '') then
   begin
     m_SickMan.Wid[4] := strtoint(Edit10.Text);
     Repaint;
     Draw;
   end;
end;

procedure TfrmStickBMPProps.lblColour2MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   cmdOuterColour.Click;
end;

procedure TfrmStickBMPProps.Button1Click(Sender: TObject);
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
   m_SickMan.SetPoint(m_SickMan.Pnt(1)^.Left,m_SickMan.Pnt(1)^.Top,1);
   m_SickMan.m_OutColour := lblColour2.Color;
   m_bApplyAll := TRUE;
   m_bOK := TRUE;
   Close;
end;

procedure TfrmStickBMPProps.chkOpenClick(Sender: TObject);
begin
   m_SickMan.m_bMouthOpen := chkOpen.Checked;
   Repaint;
   Draw;
end;

procedure TfrmStickBMPProps.chkFlipClick(Sender: TObject);
begin
   m_SickMan.m_bFlipped := chkFlip.Checked;
   Repaint;
   Draw;
end;

end.

unit specialstickprops;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, main, math, jpeg, ComCtrls;

type
  TfrmSpecialStickProps = class(TForm)
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
    Image1: TImage;
    Label23: TLabel;
    Label24: TLabel;
    Edit11: TEdit;
    Edit12: TEdit;
    Label25: TLabel;
    Label26: TLabel;
    Edit13: TEdit;
    Edit14: TEdit;
    Label27: TLabel;
    Label28: TLabel;
    Edit15: TEdit;
    Edit16: TEdit;
    Label29: TLabel;
    Label30: TLabel;
    Edit17: TEdit;
    Edit18: TEdit;
    Label31: TLabel;
    cboDrawStyle: TComboBox;
    Edit19: TEdit;
    Label32: TLabel;
    m_strAlpha: TEdit;
    Label33: TLabel;
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
    procedure FormShow(Sender: TObject);
    procedure cmdDoneClick(Sender: TObject);
    procedure cmdSetAllClick(Sender: TObject);
    procedure cmdInnerColourClick(Sender: TObject);
    procedure cmdOuterColourClick(Sender: TObject);
    procedure m_strHeadDiamChange(Sender: TObject);
    procedure lblColour1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblColour2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button1Click(Sender: TObject);
    procedure cboDrawStyleChange(Sender: TObject);
    procedure m_strBodyLengthChange(Sender: TObject);
    procedure m_strAlphaChange(Sender: TObject);
    procedure alphaBarChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    m_nX, m_nY : integer;
    m_bMoving : boolean;
    m_bOk : boolean;
    m_bApplyAll : boolean;
   //
      m_nHeadDiam : integer;
      Wid : array[1..14] of integer;
      Lng : array[1..13] of integer;
      m_InColour, m_OutColour : TColor;
      nLineWidth : integer;
      m_alpha : integer;
   //
    procedure SaveAndClose;
  end;

implementation

{$R *.dfm}

function itoa(i : integer) : string;
var
   strTemp : string;
begin
   try
      str(i, strTemp);
      itoa := strTemp;
   except
      itoa := '';
   end;
end;

function atoi(s : string) : integer;
var
   i,c : integer;
begin
   val(s, i, c);
   if (c <> 0) then
   begin
      atoi := 0;
   end else
   begin
      atoi := i;
   end;
end;

procedure TfrmSpecialStickProps.FormCreate(Sender: TObject);
begin
   Color := rgb(240,240,240);
   lblTitle.Left := 2;
   lblTitle.Top := 2;
   lblTitle.Width := ClientWidth - 4;
   cboDrawStyle.ItemIndex := 0;
end;

procedure TfrmSpecialStickProps.lblTitleMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_nX := x;
   m_nY := y;
   m_bMoving := TRUE;
end;

procedure TfrmSpecialStickProps.lblTitleMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   if (m_bMoving) then
   begin
      Left := Left + (X - m_nX);
      Top := Top + (Y - m_nY);
   end;
end;

procedure TfrmSpecialStickProps.lblTitleMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := FALSE;
end;

procedure TfrmSpecialStickProps.FormPaint(Sender: TObject);
begin
   Canvas.Pen.Width := 1;
   Canvas.Pen.Color := clBlack;
   Canvas.Brush.Color := rgb(240,240,240);
   Canvas.Rectangle(0,0,Width,Height);
end;

procedure TfrmSpecialStickProps.cmdCancelClick(Sender: TObject);
begin
   m_bOk := FALSE;
   Close;
end;

procedure TfrmSpecialStickProps.FormShow(Sender: TObject);
begin
   cboDrawStyleChange(Sender);
   m_strHeadDiam.Text := itoa(m_nHeadDiam);
   m_strLeftLegTop.Text := itoa(Lng[1]);
   m_strLeftLegBot.Text := itoa(Lng[2]);
   m_strRightLegTop.Text := itoa(Lng[3]);
   m_strRightLegBot.Text := itoa(Lng[4]);
   m_strBodyLength.Text := itoa(Lng[5]);
   m_strLeftArmTop.Text := itoa(Lng[6]);
   m_strLeftArmBot.Text := itoa(Lng[7]);
   m_strRightArmTop.Text := itoa(Lng[8]);
   m_strRightArmBot.Text := itoa(Lng[9]);
   Edit1.Text := itoa(Wid[10]);
   Edit2.Text := itoa(Wid[6]);
   Edit3.Text := itoa(Wid[7]);
   Edit4.Text := itoa(Wid[1]);
   Edit5.Text := itoa(Wid[2]);
   Edit6.Text := itoa(Wid[8]);
   Edit7.Text := itoa(Wid[9]);
   Edit8.Text := itoa(Wid[5]);
   Edit9.Text := itoa(Wid[3]);
   Edit10.Text := itoa(Wid[4]);

   Edit11.Text := itoa(Lng[10]);
   Edit12.Text := itoa(Wid[11]);
   Edit13.Text := itoa(Lng[12]);
   Edit14.Text := itoa(Wid[13]);
   Edit15.Text := itoa(Lng[11]);
   Edit16.Text := itoa(Wid[12]);
   Edit17.Text := itoa(Lng[13]);
   Edit18.Text := itoa(Wid[14]);

   Edit19.Text := itoa(nLineWidth);
   {lblColour1.Color := m_InColour;
   lblColour2.Color := m_OutColour;}
   alphaBar.Position := m_alpha;
   m_strAlpha.Text := inttostr(m_alpha);

end;

procedure TfrmSpecialStickProps.SaveAndClose;
begin
   Lng[1] := atoi(m_strLeftLegTop.Text);
   Lng[2] := atoi(m_strLeftLegBot.Text);
   Lng[3] := atoi(m_strRightLegTop.Text);
   Lng[4] := atoi(m_strRightLegBot.Text);
   Lng[5] := atoi(m_strBodyLength.Text);
   Lng[6] := atoi(m_strLeftArmTop.Text);
   Lng[7] := atoi(m_strLeftArmBot.Text);
   Lng[8] := atoi(m_strRightArmTop.Text);
   Lng[9] := atoi(m_strRightArmBot.Text);
   Wid[10] := atoi(Edit1.Text);
   Wid[6] := atoi(Edit2.Text);
   Wid[7] := atoi(Edit3.Text);
   Wid[1] := atoi(Edit4.Text);
   Wid[2] := atoi(Edit5.Text);
   Wid[8] := atoi(Edit6.Text);
   Wid[9] := atoi(Edit7.Text);
   Wid[5] := atoi(Edit8.Text);
   Wid[3] := atoi(Edit9.Text);
   Wid[4] := atoi(Edit10.Text);

   Wid[11] := atoi(Edit12.Text);
   Wid[13] := atoi(Edit14.Text);
   Wid[12] := atoi(Edit16.Text);
   Wid[14] := atoi(Edit18.Text);

   Lng[10] := atoi(Edit11.Text);
   Lng[12] := atoi(Edit13.Text);
   Lng[11] := atoi(Edit15.Text);
   Lng[13] := atoi(Edit17.Text);

   nLinewidth := atoi(edit19.text);

   m_nHeadDiam := atoi(m_strHeadDiam.Text);
   m_InColour := lblColour1.Color;
   m_OutColour := lblColour2.Color;

   if (m_Alpha > 255) then
      m_Alpha := 255;
   if (m_Alpha < 0) then
      m_Alpha := 0;

   Close;
end;

procedure TfrmSpecialStickProps.cmdDoneClick(Sender: TObject);
begin
   m_bApplyAll := FALSE;
   m_bOK := TRUE;
   SaveAndClose;
end;

procedure TfrmSpecialStickProps.cmdSetAllClick(Sender: TObject);
var
   f : integer;
begin
   for f := 1 to 14 do
   begin
      Wid[f] := atoi(m_strWidths.Text);
   end;
   Edit1.Text := itoa(atoi(m_strWidths.Text));
   Edit2.Text := itoa(atoi(m_strWidths.Text));
   Edit3.Text := itoa(atoi(m_strWidths.Text));
   Edit4.Text := itoa(atoi(m_strWidths.Text));
   Edit5.Text := itoa(atoi(m_strWidths.Text));
   Edit6.Text := itoa(atoi(m_strWidths.Text));
   Edit7.Text := itoa(atoi(m_strWidths.Text));
   Edit8.Text := itoa(atoi(m_strWidths.Text));
   Edit9.Text := itoa(atoi(m_strWidths.Text));
   Edit10.Text := itoa(atoi(m_strWidths.Text));

   Edit12.Text := itoa(atoi(m_strWidths.Text));
   Edit14.Text := itoa(atoi(m_strWidths.Text));
   Edit16.Text := itoa(atoi(m_strWidths.Text));
   Edit18.Text := itoa(atoi(m_strWidths.Text));
end;

procedure TfrmSpecialStickProps.cmdInnerColourClick(Sender: TObject);
begin
   cd.Color := lblColour1.Color;
   if (cd.Execute) then
   begin
      lblColour1.Color := cd.Color;
   end;
end;

procedure TfrmSpecialStickProps.cmdOuterColourClick(Sender: TObject);
begin
   cd.Color := lblColour2.Color;
   if (cd.Execute) then
   begin
      lblColour2.Color := cd.Color;
   end;
end;

procedure TfrmSpecialStickProps.m_strHeadDiamChange(Sender: TObject);
begin
   if (m_strHeadDiam.Text <> '') then
   begin
     m_nHeadDiam := atoi(m_strHeadDiam.Text);
   end;
end;

procedure TfrmSpecialStickProps.lblColour1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   cmdInnerColour.Click;
end;

procedure TfrmSpecialStickProps.lblColour2MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   cmdOuterColour.Click;
end;

procedure TfrmSpecialStickProps.alphaBarChange(Sender: TObject);
begin
   m_strAlpha.Text := inttostr(alphaBar.Position);
   m_Alpha := alphaBar.Position;
end;

procedure TfrmSpecialStickProps.Button1Click(Sender: TObject);
begin
   m_bApplyAll := TRUE;
   m_bOK := TRUE;
   SaveAndClose;
end;

procedure TfrmSpecialStickProps.cboDrawStyleChange(Sender: TObject);
begin
   Edit1.Enabled := TRUE;
   Edit2.Enabled := TRUE;
   Edit3.Enabled := TRUE;
   Edit12.Enabled := TRUE;
   Edit4.Enabled := TRUE;
   Edit5.Enabled := TRUE;
   Edit14.Enabled := TRUE;

   Edit6.Enabled := TRUE;
   Edit7.Enabled := TRUE;
   Edit16.Enabled := TRUE;
   Edit8.Enabled := TRUE;
   Edit9.Enabled := TRUE;
   Edit10.Enabled := TRUE;
   Edit18.Enabled := TRUE;

   Edit12.Enabled := TRUE;
   Edit14.Enabled := TRUE;
   Edit16.Enabled := TRUE;
   Edit18.Enabled := TRUE;
   m_strWidths.Enabled := TRUE;
   cmdSetAll.Enabled := TRUE;

   case cboDrawStyle.ItemIndex of
      0,1: begin
            m_strWidths.Text := '1';
            cmdSetAllCLick(sender);
               Edit1.Enabled := FALSE;
               Edit2.Enabled := FALSE;
               Edit3.Enabled := FALSE;
               Edit12.Enabled := FALSE;
               Edit4.Enabled := FALSE;
               Edit5.Enabled := FALSE;
               Edit14.Enabled := FALSE;

               Edit6.Enabled := FALSE;
               Edit7.Enabled := FALSE;
               Edit16.Enabled := FALSE;
               Edit8.Enabled := FALSE;
               Edit9.Enabled := FALSE;
               Edit10.Enabled := FALSE;
               Edit18.Enabled := FALSE;
               m_strWidths.Enabled := FALSE;
               cmdSetAll.Enabled := FALSE;
         end;
      2: begin m_strWidths.Text := '10'; cmdSetAllClick(Sender); end;
      3: begin
               m_strWidths.Text := '10';
               Edit19.Text := '1';
               cmdSetAllClick(Sender);
               m_strLeftLegTop.Text := itoa(atoi(m_strBodyLength.Text) div 3);
               m_strRightLegTop.Text := m_strLeftLegTop.Text;
               m_strLeftArmTop.Text := itoa(atoi(m_strBodyLength.Text) div 4);
               m_strRightArmTop.Text := m_strLeftArmTop.Text;

               Edit11.Text := m_strLeftArmBot.Text;
               Edit15.Text := Edit11.Text;
               Edit13.Text := m_strLeftLegBot.Text;
               Edit17.Text := Edit13.Text;

               Edit8.Text := '20';

               Edit1.Enabled := false;
               Edit2.Enabled := false;
               Edit3.Enabled := false;
               Edit12.Enabled := false;
               Edit5.Enabled := false;
               Edit4.Enabled := false;
               Edit14.Enabled := false;
               Edit6.Enabled := false;
               Edit7.Enabled := false;
               Edit16.Enabled := false;
               Edit9.Enabled := false;
               Edit10.Enabled := false;
               Edit18.Enabled := false;
               m_strLeftLegTop.Enabled := FALSE;
               m_strRightLegTop.Enabled := FALSE;
               m_strLeftArmTop.Enabled := FALSE;
               m_strRightArmTop.Enabled := FALSE;
               m_strHeadDiam.Text := '20';
         end;
   end;
end;

procedure TfrmSpecialStickProps.m_strAlphaChange(Sender: TObject);
begin
   if (m_strAlpha.Text <> '') then
   begin
      m_Alpha := strtoint(m_strAlpha.Text);
      alphaBar.Position := m_Alpha;
   end;
end;

procedure TfrmSpecialStickProps.m_strBodyLengthChange(Sender: TObject);
begin
   if (cboDrawStyle.ItemIndex = 3) then
   begin
      m_strLeftLegTop.Text := itoa(atoi(m_strBodyLength.Text) div 3);
      m_strRightLegTop.Text := m_strLeftLegTop.Text;
      m_strLeftArmTop.Text := itoa(atoi(m_strBodyLength.Text) div 4);
      m_strRightArmTop.Text := m_strLeftArmTop.Text;
   end;
end;

end.

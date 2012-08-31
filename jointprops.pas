unit jointprops;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, stickstuff, stickjoint, buttons, ExtCtrls;

type
  TfrmJointProps = class(TForm)
    m_strWidth: TEdit;
    Label2: TLabel;
    lblColour: TLabel;
    Label4: TLabel;
    od: TOpenDialog;
    cd: TColorDialog;
    lblFillColour: TLabel;
    Label3: TLabel;
    chkClear: TCheckBox;
    cboDrawAs: TComboBox;
    m_strDrawWidth: TEdit;
    lblDrawWidth: TLabel;
    addBitmap: TButton;
    Label1: TLabel;
    Label5: TLabel;
    imgBitmapX: TImage;
    imgBitmapY: TImage;
    Label6: TLabel;
    imgRotation: TImage;
    Label7: TLabel;
    chkDrawLine: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure m_strWidthChange(Sender: TObject);
    procedure lblColourClick(Sender: TObject);
    procedure lblFillColourClick(Sender: TObject);
    procedure chkClearClick(Sender: TObject);
    procedure cboDrawAsChange(Sender: TObject);
    procedure m_strDrawWidthChange(Sender: TObject);
    procedure addBitmapClick(Sender: TObject);
    procedure imgBitmapXMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgBitmapXMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure imgBitmapXMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgRotationMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgRotationMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure imgRotationMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgBitmapYMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgBitmapYMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure imgBitmapYMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure chkDrawLineClick(Sender: TObject);
  private
    { Private declarations }
    m_pSelectedJoint : TJoint;
    m_pSender : TObject;
    m_nMouseDown : integer;
    m_nX, m_nY : integer;

    procedure _setJoint(pJoint : TJoint);
  public
    { Public declarations }
    m_pMan : TLimbList;
    m_pTempObject : TLimbList;
    
    property SelectedJoint : TJoint read m_pSelectedJoint write _setJoint;
  end;

implementation

{$IFDEF FPC}
{$ELSE}
   {$R *.dfm}
{$ENDIF}

uses main;

procedure TfrmJointProps._setJoint(pJoint : TJoint);
begin
   m_pSelectedJoint := pJoint;
end;

procedure TfrmJointProps.addBitmapClick(Sender: TObject);
var
   i : integer;
begin
   if (not od.Execute) then
      exit;

   i := m_pMan.AddBitmap(od.FileName);
   if (m_pTempObject <> nil) then
      m_pTempObject.AddBitmap(od.FileName);
   
   cboDrawAs.ItemIndex := cboDrawAs.Items.Add(extractfilename(od.FileName));
   if (m_pSelectedJoint <> nil) then
   begin
      m_pSelectedJoint.CurrentBitmap := i;
   end;
end;

procedure TfrmJointProps.cboDrawAsChange(Sender: TObject);
begin
   lblDrawWidth.Visible := cboDrawAs.ItemIndex <> 0;
   m_strDrawWidth.Visible := cboDrawAs.ItemIndex <> 0;

   if m_pSelectedJoint = nil then
      exit;

   if (m_strDrawWidth.Visible) then
      m_strDrawWidth.Text := inttostr(m_pSelectedJoint.DrawWidth);

   if (cboDrawAs.ItemIndex > 2) then
   begin
      m_pSelectedJoint.DrawAs := C_DRAW_AS_LINE;//C_DRAW_AS_BITMAP;
      m_pSelectedJoint.CurrentBitmap := cboDrawAs.ItemIndex - 3;
   end else
   begin
      m_pSelectedJoint.DrawAs := cboDrawAs.ItemIndex;
      m_pSelectedJoint.CurrentBitmap := -1;
   end;

end;

procedure TfrmJointProps.chkClearClick(Sender: TObject);
begin
   if m_pSelectedJoint = nil then
      exit;

   m_pSelectedJoint.Fill := not chkClear.Checked;
end;

procedure TfrmJointProps.chkDrawLineClick(Sender: TObject);
begin
   if m_pSelectedJoint = nil then
      exit;

   m_pSelectedJoint.ShowStick := not chkDrawLine.Checked;
end;

procedure TfrmJointProps.FormCreate(Sender: TObject);
begin
   m_pSender := Sender;
   m_nMouseDown := 0;
   m_pTempObject := nil;
end;

procedure TfrmJointProps.imgBitmapXMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   SetCapture(handle);
   m_nMouseDown := 3;
   m_nX := x;
   m_nY := y;
end;

procedure TfrmJointProps.imgBitmapXMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
   diffX : integer;
begin
   diffX := m_nX - X;
   m_nX := X;
   if (m_nMouseDown = 1) then
      m_pSelectedJoint.BitmapRotation := m_pSelectedJoint.BitmapRotation - diffX;

   if (m_nMouseDown = 2) then
      m_pSelectedJoint.BitmapY := m_pSelectedJoint.BitmapY - diffX;

   if (m_nMouseDown = 3) then
      m_pSelectedJoint.BitmapX := m_pSelectedJoint.BitmapX - diffX;

end;

procedure TfrmJointProps.imgBitmapXMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_nMouseDown := 0;
   ReleaseCapture();
end;

procedure TfrmJointProps.imgBitmapYMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   SetCapture(handle);
   m_nMouseDown := 1;
   m_nX := x;
   m_nY := y;
end;

procedure TfrmJointProps.imgBitmapYMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
   diffX : integer;
begin
   diffX := m_nX - X;
   m_nX := X;
   if (m_nMouseDown = 1) then
      m_pSelectedJoint.BitmapRotation := m_pSelectedJoint.BitmapRotation - diffX;

   if (m_nMouseDown = 2) then
      m_pSelectedJoint.BitmapY := m_pSelectedJoint.BitmapY - diffX;

   if (m_nMouseDown = 3) then
      m_pSelectedJoint.BitmapX := m_pSelectedJoint.BitmapX - diffX;
end;

procedure TfrmJointProps.imgBitmapYMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_nMouseDown := 0;
   ReleaseCapture();
end;

procedure TfrmJointProps.imgRotationMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   SetCapture(handle);
   m_nMouseDown := 2;
   m_nX := x;
   m_nY := y;
end;

procedure TfrmJointProps.imgRotationMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
   diffX : integer;
begin
   diffX := m_nX - X;
   m_nX := X;
   if (m_nMouseDown = 1) then
      m_pSelectedJoint.BitmapRotation := m_pSelectedJoint.BitmapRotation - diffX;

   if (m_nMouseDown = 2) then
      m_pSelectedJoint.BitmapY := m_pSelectedJoint.BitmapY - diffX;

   if (m_nMouseDown = 3) then
      m_pSelectedJoint.BitmapX := m_pSelectedJoint.BitmapX - diffX;
end;

procedure TfrmJointProps.m_strDrawWidthChange(Sender: TObject);
begin
   if (m_pSelectedJoint = nil) and (m_pMan.DrawMode = C_STICK_DRAWMODE_STRAIGHT) then
      exit;

   if (m_strDrawWidth.Text <> '') then
   begin
      if (m_pMan.DrawMode = C_STICK_DRAWMODE_STRAIGHT) then
         m_pSelectedJoint.DrawWidth := strtoint(m_strDrawWidth.Text);
      {else
         m_pMan.CurveWidth := strtoint(m_strDrawWidth.Text); }
   end;
end;

procedure TfrmJointProps.m_strWidthChange(Sender: TObject);
begin
   if (m_pSelectedJoint = nil) and (m_pMan.DrawMode = C_STICK_DRAWMODE_STRAIGHT) then
      exit;

   if (m_strWidth.Text <> '') then
   begin
      if (m_pMan.DrawMode = C_STICK_DRAWMODE_STRAIGHT) then
         m_pSelectedJoint.Width := strtoint(m_strWidth.Text)
      else
         m_pMan.CurveWidth := strtoint(m_strWidth.Text);
   end;
end;

procedure TfrmJointProps.lblColourClick(Sender: TObject);
begin
   if m_pSelectedJoint = nil then
      exit;

   if (cd.Execute) then
   begin
      m_pSelectedJoint.Colour := cd.Color;
      lblColour.Color := cd.Color;
   end;
end;

procedure TfrmJointProps.lblFillColourClick(Sender: TObject);
begin
   if m_pSelectedJoint = nil then
      exit;

   if (cd.Execute) then
   begin
      m_pSelectedJoint.Fill := TRUE;
      m_pSelectedJoint.FillColour := cd.Color;
      lblFillColour.Color := cd.Color;
      chkClear.Checked := false;
   end;
end;

procedure TfrmJointProps.imgRotationMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_nMouseDown := 0;
   ReleaseCapture();
end;

end.

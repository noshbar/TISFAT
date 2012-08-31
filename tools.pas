unit tools;

interface

uses
  Windows, Messages, SysUtils, Graphics, Controls, Forms, StdCtrls, ExtCtrls, ExtDlgs, Dialogs, Classes,
  ComCtrls, stickstuff, stickjoint, casform;

type
  TfrmToolBar = class(TForm)
    m_strFPS: TEdit;
    lblFrameNo: TLabel;
    imgNewLayer: TImage;
    imgAddKeyFrame: TImage;
    imgPlay: TImage;
    cd: TColorDialog;
    lblTitle: TLabel;
    lblTime: TLabel;
    imgSavePose: TImage;
    imgRestorePose: TImage;
    imgAddTween: TImage;
    imgMove: TImage;
    imgProps: TImage;
    lblXPos: TLabel;
    lblYPos: TLabel;
    imgStop: TImage;
    imgClickAnim: TImage;
    imgScale: TImage;
    od: TOpenDialog;
    alphaBar: TTrackBar;
    lblColours: TLabel;
    lblAlpha: TLabel;
    lblInColour: TLabel;
    lblOutColour: TLabel;
    lblRotation: TLabel;
    imgBGColour: TImage;
    cboDrawType: TComboBox;
    imgCAS: TImage;
    procedure FormCreate(Sender: TObject);
    procedure m_strFPSClick(Sender: TObject);
    procedure lblTitleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblTitleMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblTitleMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormPaint(Sender: TObject);
    procedure m_strFPSChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    function FormHelp(Command: Word; Data: Integer;
      var CallHelp: Boolean): Boolean;
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure imgNewLayerClick(Sender: TObject);
    procedure imgAddKeyFrameClick(Sender: TObject);
    procedure imgAddTweenClick(Sender: TObject);
    procedure imgBGColourClick(Sender: TObject);
    procedure imgSavePoseClick(Sender: TObject);
    procedure imgRestorePoseClick(Sender: TObject);
    procedure imgMoveClick(Sender: TObject);
    procedure imgPropsClick(Sender: TObject);
    procedure imgClickAnimClick(Sender: TObject);
    procedure imgPlayClick(Sender: TObject);
    procedure imgScaleClick(Sender: TObject);
    procedure imgStopClick(Sender: TObject);
    procedure alphaBarChange(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblInColourClick(Sender: TObject);
    procedure lblOutColourClick(Sender: TObject);
    procedure cboDrawTypeChange(Sender: TObject);
    procedure imgCASClick(Sender: TObject);
  private
    { Private declarations }
    m_inColour, m_outColour : Cardinal;
    m_alpha : byte;
    m_angle : single;
    m_nippleX, m_nippleY : integer;
    m_nMouseDown : boolean;
    m_nMouseX, m_nMouseY : integer;
    m_knobX, m_knobY : integer;
    m_joint : TJoint;
    m_pMain, m_pStick : TLimbList;
    m_cas : TfrmCAS;
    procedure changeAngle;
    procedure SetClientHeight(h : integer);
  public
    { Public declarations }
    m_nPnt : array[1..20, 1..2] of integer;
    m_nLng : array[1..20] of integer;
    m_nWid : array[1..20] of integer;
    m_nHeadDiam : integer;
    m_bMove : boolean;
    m_nX, m_nY : integer;
    m_bMoving : BOOLEAN;
    m_nCurrentFrame : integer;
    m_nEnd : integer;
    m_nStartHeight : integer;

    procedure ResetHeight;
    procedure ShowDetails(inColour, outColour : Cardinal; alpha : byte; angle : single); overload;
    procedure ShowDetails(inColour, outColour : Cardinal; alpha : byte); overload;
    procedure ShowDetailsMin(Colour: Cardinal; alpha : byte);
    procedure ShowDetails(alpha : byte; angle : single); overload;
    procedure ShowDetails(pMain, pStick : TLimbList; pJoint : TJoint); overload;
  end;

var
  frmToolBar: TfrmToolBar;

implementation

uses main, drawcanvas, newobj, stickprops, rectprops, configfile, newpoly, subedit, oneliner, textprops, newstickbmp,
  scale, sticked, math;

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

procedure TfrmToolBar.alphaBarChange(Sender: TObject);
begin
   if (frmMain.m_pTweenFrame = nil) then
     exit;

   if (frmMain.m_pTweenFrame^.m_nType = O_BITMAP) then
   begin
      TBitmanPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_alpha := alphaBar.Position;
   end;
   if (frmMain.m_pTweenFrame^.m_nType = O_STICKMAN) then
   begin
      TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_alpha := alphaBar.Position;
   end;
   if (frmMain.m_pTweenFrame^.m_nType = O_T2STICK) then
   begin
      TLimbListPtr(frmMain.m_pTweenFrame^.m_pObject)^.Alpha := alphaBar.Position/255;
   end;
   if (frmMain.m_pTweenFrame^.m_nType = O_SPECIALSTICK) then
   begin
      TSpecialStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_alpha := alphaBar.Position;
   end;
   if (frmMain.m_pTweenFrame^.m_nType = O_RECTANGLE) then
   begin
      TSquareObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_alpha := alphaBar.Position;
   end;
   if (frmMain.m_pTweenFrame^.m_nType = O_LINE) then
   begin
      TLineObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_alpha := alphaBar.Position;
   end;
   if (frmMain.m_pTweenFrame^.m_nType = O_OVAL) then
   begin
      TOvalObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_alpha := alphaBar.Position;
   end;
   if (frmMain.m_pTweenFrame^.m_nType = O_POLY) then
   begin
      TPolyObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_alpha := alphaBar.Position;
   end;
   if (frmMain.m_pTweenFrame^.m_nType = O_TEXT) then
   begin
      TTextObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_alpha := alphaBar.Position;
   end;

   frmMain.ReRender;
end;

procedure TfrmToolBar.FormCreate(Sender: TObject);
begin
   m_cas := TfrmCAS.Create(nil);

   DoubleBuffered := TRUE;
   m_nMouseDown := false;
   m_nMouseX := 0;
   m_nMouseY := 0;
   m_bMoving := FALSE;
   m_bMove := fALSE;
   Left := 10;
   Width := imgAddKeyFrame.Left + imgAddKeyFrame.Width + imgNewLayer.Left + 1;
   Color := rgb(240,240,240);
   lblTitle.Top := 2;
   lblTitle.Left := 2;
   lblTitle.Width := Width - 4;
   if (LoadSettings(frmMain.m_strTHEPATH+'tis.fat', frmMain.m_Settings)) then
   begin
      Left := frmMain.m_Settings.ToolLeft;
      Top := frmMain.m_Settings.ToolTop;
   end;
   m_nCurrentFrame := 1;
   m_nStartHeight := imgCAS.Top + imgCAS.Height + 10;
   ClientHeight := m_nStartHeight;

   m_cas.Left := Left;
   m_cas.Top := Top;
end;

procedure TfrmToolBar.m_strFPSClick(Sender: TObject);
begin
   m_strFPS.SetFocus;
end;

procedure TfrmToolBar.lblInColourClick(Sender: TObject);
var
   pJoint : TJoint;
begin
   if not cd.execute then
      exit;

   lblInColour.Color := cd.Color;

   if (frmMain.m_pTweenFrame^.m_nType = O_STICKMAN) then
   begin
      TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_InColour := cd.Color;
   end;
   if (frmMain.m_pTweenFrame^.m_nType = O_T2STICK) then
   begin
      pJoint := frmMain.frmCanvas.SelectedJoint;
      if (pJoint <> nil) then
      begin
        pJoint.Fill := true;
        pJoint.FillColour := cd.Color;
      end;
   end;
   if (frmMain.m_pTweenFrame^.m_nType = O_SPECIALSTICK) then
   begin
      TSpecialStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_InColour := cd.Color;
   end;
   if (frmMain.m_pTweenFrame^.m_nType = O_RECTANGLE) then
   begin
      TSquareObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_InColour := cd.Color;
   end;
   if (frmMain.m_pTweenFrame^.m_nType = O_LINE) then
   begin
      TLineObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_Colour := cd.Color;
   end;
   if (frmMain.m_pTweenFrame^.m_nType = O_OVAL) then
   begin
      TOvalObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_InColour := cd.Color;
   end;
   if (frmMain.m_pTweenFrame^.m_nType = O_POLY) then
   begin
      TPolyObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_InColour := cd.Color;
   end;
   if (frmMain.m_pTweenFrame^.m_nType = O_TEXT) then
   begin
      TTextObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_InColour := cd.Color;
   end;
   frmMain.ReRender;
end;

procedure TfrmToolBar.lblOutColourClick(Sender: TObject);
var
   pJoint : TJoint;
begin
   if not cd.execute then
      exit;

   lblOutColour.Color := cd.Color;

   if (frmMain.m_pTweenFrame^.m_nType = O_STICKMAN) then
   begin
      TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_OutColour := cd.Color;
   end;
   if (frmMain.m_pTweenFrame^.m_nType = O_T2STICK) then
   begin
      pJoint := frmMain.frmCanvas.SelectedJoint;
      if (pJoint <> nil) then
      begin
        pJoint.Colour := cd.Color;
      end;
   end;
   if (frmMain.m_pTweenFrame^.m_nType = O_SPECIALSTICK) then
   begin
      TSpecialStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_OutColour := cd.Color;
   end;
   if (frmMain.m_pTweenFrame^.m_nType = O_RECTANGLE) then
   begin
      TSquareObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_OutColour := cd.Color;
   end;
   if (frmMain.m_pTweenFrame^.m_nType = O_OVAL) then
   begin
      TOvalObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_OutColour := cd.Color;
   end;
   if (frmMain.m_pTweenFrame^.m_nType = O_POLY) then
   begin
      TPolyObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_OutColour := cd.Color;
   end;
   if (frmMain.m_pTweenFrame^.m_nType = O_TEXT) then
   begin
      TTextObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_OutColour := cd.Color;
   end;
   frmMain.ReRender;
end;

procedure TfrmToolBar.lblTitleMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := TRUE;
   m_nX := x;
   m_nY := y;
   BringToFront;
end;

procedure TfrmToolBar.lblTitleMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := FALSE;
end;

procedure TfrmToolBar.lblTitleMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   if (m_bMoving) then
   begin
      Left := Left + (x - m_nX);
      Top := Top + (y - m_nY);
   end;
end;

procedure TfrmToolBar.ResetHeight;
begin
   ClientHeight := m_nStartHeight;
   m_joint := nil;

   lblInColour.Show;
   lblOutColour.Show;
   lblColours.Show;
   lblAlpha.Top := 319;
   alphaBar.Top := 335;
   lblRotation.Top := 360;
end;

procedure TfrmToolBar.SetClientHeight(h : integer);
begin
   if (ClientHeight = h) then
      repaint
   else
      ClientHeight := h;
end;

procedure TfrmToolBar.ShowDetails(pMain, pStick : TLimbList; pJoint : TJoint);
var
  f : integer;
  slNames : TStringList;
begin
   m_joint := pJoint;
   m_pMain := pMain;
   m_pStick := pStick;
   lblInColour.Color := pJoint.FillColour;
   lblOutColour.Color := pJoint.Colour;

   m_inColour := lblInColour.Color;
   m_outColour := lblOutColour.Color;
   m_alpha := round(pStick.alpha * 255);
   alphaBar.Position := round(pStick.alpha * 255);

   cboDrawType.Top := alphaBar.Top + alphaBar.Height + 5;
   lblRotation.Top := cboDrawType.Top + cboDrawType.Height + 5;

   cboDrawType.Clear;
   cboDrawType.Items.Add('Line');
   cboDrawType.Items.Add('Rectangle');
   cboDrawType.Items.Add('Circle');

   slNames := TStringList.Create;
   pMain.GetBitmapNames(slNames);
   for f := 0 to slNames.Count - 1 do
   begin
     cboDrawType.Items.Add(slNames[f]);
   end;
   slNames.Clear;

   if (pJoint.CurrentBitmap = -1) then
   begin
      cboDrawType.ItemIndex := pJoint.DrawAs;
   end else
   begin
      cboDrawType.ItemIndex := 3 + pJoint.CurrentBitmap;
   end;

   if (pJoint.CurrentBitmap <> -1) then
   begin
      m_angle := pJoint.BitmapRotation;
      SetClientHeight(455);
   end else
   begin
      SetClientHeight(lblRotation.Top);
   end;
   self.Repaint;
end;

procedure TfrmToolBar.ShowDetails(alpha : byte; angle : single);
begin
   m_alpha := alpha;
   m_angle := angle;
   alphaBar.Position := alpha;

   lblInColour.Hide;
   lblOutColour.Hide;
   lblColours.Hide;

   lblAlpha.Top := 277; //42 difference
   alphaBar.Top := 293;

   lblRotation.Top := 318;
   //hide colour boxes
   SetClientHeight(388); //430- 42
   self.Repaint;
end;

procedure TfrmToolBar.ShowDetails(inColour, outColour : Cardinal; alpha : byte);
begin
   lblInColour.Color := inColour;
   lblOutColour.Color := outColour;

   m_inColour := inColour;
   m_outColour := outColour;
   m_alpha := alpha;
   alphaBar.Position := alpha;
   SetClientHeight(lblRotation.Top);
   self.Repaint;
end;

procedure TfrmToolBar.ShowDetailsMin(Colour : Cardinal; alpha : byte);
begin
   lblInColour.Color := Colour;
   lblOutcolour.Hide;

   m_inColour := Colour;
   m_outColour := Colour;
   m_alpha := alpha;
   alphaBar.Position := alpha;
   SetClientHeight(lblRotation.Top);
   self.Repaint;
end;

procedure TfrmToolBar.ShowDetails(inColour, outColour : Cardinal; alpha : byte; angle : single);
begin
   lblInColour.Color := inColour;
   lblOutColour.Color := outColour;

   m_inColour := inColour;
   m_outColour := outColour;
   m_alpha := alpha;
   alphaBar.Position := alpha;
   m_angle := angle;
   SetClientHeight(430);
   self.Repaint;
end;

procedure TfrmToolBar.FormPaint(Sender: TObject);
var
   h : integer;
   w : integer;
   rads : extended;
   nippleRadius : integer;
begin
   Canvas.Pen.Width := 1;
   Canvas.Pen.Color := clBlack;
   Canvas.Brush.Color := rgb(240,240,240);
   Canvas.Rectangle(0,0,Width,Height);

   if (ClientHeight <= m_nStartHeight) then
      exit;

   Canvas.MoveTo(0, m_nStartHeight);
   Canvas.LineTo(ClientWidth, m_nStartHeight);

   h := lblRotation.Top + lblRotation.Height + 2;
   w := ClientWidth - 40;
   Canvas.Brush.Color := rgb(200,200,200);
   Canvas.Ellipse(20, h,
                  ClientWidth-20, h + w);

   rads := degtorad(m_angle);
   nippleRadius := 4;
   m_knobY := h + (w div 2); //center y
   m_knobX := ClientWidth div 2; //center x
   m_nippleX := round(m_knobX + (cos(rads) * ((w/2)-(nippleRadius*1.5))));
   m_nippleY := round(m_knobY + (sin(rads) * ((w/2)-(nippleRadius*1.5))));
   Canvas.Brush.Color := rgb(0,0,0);//rgb(240,240,240);
   Canvas.Ellipse(m_nippleX-nippleRadius,m_nippleY-nippleRadius, m_nippleX+nippleRadius,m_nippleY+nippleRadius);
end;

procedure TfrmToolBar.m_strFPSChange(Sender: TObject);
var
   i,code : integer;
begin
   if (m_strFPS.Text = '') then exit;
   val(m_strFPS.Text, i,code);
   if (code <> 0) then
   begin
      MessageBox(Application.Handle, 'Please enter an integer for the FrameRate', 'Tis an Error', MB_OK or MB_ICONERROR);
      m_strFPS.Text := '12';
      exit;
   end;
   if (i > 0) then
   begin
      lblTime.Caption := 'Time ' + floattostrf(frmMain.m_col / atoi(m_strFPS.Text), ffFixed, 4,2) + 's';
      frmMain.m_nFPS := atoi(m_strFPS.Text);
   end else
   begin
      m_strFPS.Text := '1';
   end;
end;

procedure TfrmToolBar.FormDestroy(Sender: TObject);
begin
   LoadSettings(frmMain.m_strTHEPATH+'tis.fat', frmMain.m_Settings);
   frmMain.m_Settings.ToolLeft := Left;
   frmMain.m_Settings.ToolTop := Top;
   SaveSettings(frmMain.m_strTHEPATH+'tis.fat', frmMain.m_Settings);
//   m_cas.Destroy;
end;

function TfrmToolBar.FormHelp(Command: Word; Data: Integer; var CallHelp: Boolean): Boolean;
begin
   frmMain.Help2Click(self);
end;

procedure TfrmToolBar.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if (x >= m_nippleX-4) and (x <=m_nippleX+4) and (y >= m_nippleY-4) and (y <= m_nippleY+4) then
   begin
      m_nMouseDown := true;
      m_nMouseX := X;
      m_nMouseY := Y;
   end;
end;

procedure TfrmToolBar.cboDrawTypeChange(Sender: TObject);
begin
   if (cboDrawType.ItemIndex > 2) then
   begin
      m_joint.DrawAs := C_DRAW_AS_LINE;//C_DRAW_AS_BITMAP;
      m_joint.CurrentBitmap := cboDrawType.ItemIndex - 3;
   end else
   begin
      m_joint.DrawAs := cboDrawType.ItemIndex;
      m_joint.CurrentBitmap := -1;
   end;
   ShowDetails(m_pMain, m_pStick, m_joint);
   frmMain.ReRender;
end;

procedure TfrmToolBar.changeAngle;
begin
   if (frmMain.m_pTweenFrame = nil) then
     exit;

   if (frmMain.m_pTweenFrame^.m_nType = O_BITMAP) then
   begin
      TBitmanPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_angle := m_angle;
   end;
   if (frmMain.m_pTweenFrame^.m_nType = O_RECTANGLE) then
   begin
      TSquareObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_angle := m_angle;
   end;
   if (frmMain.m_pTweenFrame^.m_nType = O_OVAL) then
   begin
      TOvalObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_angle := m_angle;
   end;
   if (frmMain.m_pTweenFrame^.m_nType = O_T2STICK) then
   begin
      if (m_joint <> nil) then
      begin
         m_joint.BitmapRotation := m_angle;
      end;
   end;
   {if (frmMain.m_pTweenFrame^.m_nType = O_POLY) then
   begin
      TPolyObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_alpha := alphaBar.Position;
   end;}
   if (frmMain.m_pTweenFrame^.m_nType = O_TEXT) then
   begin
      TTextObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_angle := m_angle;
   end;
end;

procedure TfrmToolBar.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
   //angle : single;
   xDiff, yDiff : integer;
begin
   if (m_nMouseDown) then
   begin
      xDiff := X - m_knobX;
      yDiff := Y - m_knobY;
      m_Angle := (180 * (1 + ArcTan2(yDiff, xDiff) / PI)) - 180;
      changeAngle;
      frmMain.ReRender;
      repaint;
   end else
   if ((x >= m_nippleX-4) and (x <=m_nippleX+4) and (y >= m_nippleY-4) and (y <= m_nippleY+4)) then
   begin
      screen.Cursor := crHandPoint;
   end else
   begin
      screen.Cursor := crDefault;
   end;
end;

procedure TfrmToolBar.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_nMouseDown := false;
end;

procedure TfrmToolBar.imgNewLayerClick(Sender: TObject);
var
   pLayer : TLayerObjPtr;
   nIndex : integer;
   strFileName, strFile2 : string;
   f, g : integer;
   strTemp : string;
   bOk : BOOLEAN;
   keyy : word;
   frmNewObj : TfrmNewObj;
   frmNewPoly : TfrmNewPoly;
   frmNewStickBMP : TfrmNewStickBMP;
   frmStickEd : TfrmStickEd;
   strForceSaveName : string;
begin
   frmNewObj := TfrmNewObj.Create(frmMain);
   if Left < (screen.width-(frmNewObj.Width+Width)) then
   begin
      frmNewObj.Left := Left + Width -1;
      frmNewObj.Top := Top;
   end else
   begin
      frmNewObj.Left := Left - frmNewObj.Width +1;
      frmNewObj.Top := Top;
   end;
   frmNewObj.ShowModal;
   if (frmNewObj.m_nChoice <> -1) then
   begin
      if (frmNewObj.m_nChoice = O_POLY) then
      begin
         frmNewPoly := TfrmNewPoly.Create(self);
         frmNewPoly.ShowModal;
         if (frmNewPoly.m_bOK) then
         begin
            strFileName := frmNewPoly.m_strPoints.Text;
         end else
         begin
            frmNewPoly.Destroy;
            frmNewObj.Destroy;
            exit;
         end;
         frmNewPoly.Destroy;
      end;
      if (frmNewObj.m_nChoice = O_BITMAP) then
      begin
         if (LoadSettings(frmMain.m_strTHEPATH+'tis.fat', frmMain.m_Settings)) then
         begin
            od.InitialDir := frmMain.m_Settings.OPFilePath;
         end;
         if (od.Execute) then
         begin
            strFileName := od.FileName;
            frmMain.m_Settings.OPFilePath := extractfilepath(strFileName);
            SaveSettings(frmMain.m_strTHEPATH+'tis.fat', frmMain.m_Settings);
         end else
         begin
            frmNewObj.Destroy;
            exit;
         end;
      end;
      if (frmNewObj.m_nChoice = O_T2STICK) then
      begin
         strForceSaveName := extractfilepath(Application.ExeName) + 'temp.sff';
         frmStickEd := TfrmStickEd.Create(frmMain);
         frmStickEd.ForceSaveName := strForceSaveName;
         frmStickEd.Hide;
         frmStickEd.ShowModal;
         if (not frmStickEd.AddStick) then
         begin
            frmNewObj.Destroy;
            frmStickEd.Destroy;
            exit;
         end;
         strFileName := strForceSaveName;
         frmStickEd.Destroy;
      end;
      ////////// !!! MAKE NEW FORM with two buttons for loading open and closed pics, with previews that stretch to fit
      if (frmNewObj.m_nChoice = O_STICKMANBMP) then
      begin
         frmNewStickBMP := TfrmNewStickBMP.Create(self);
         frmNewStickBmp.ShowModal;
         if (frmNewStickBMP.m_bOK) then
         begin
            strFileNAme := frmNewStickBMP.m_strFileName1;
            strFile2 := frmNewStickBMP.m_strFileName2;
         end else
         begin
            frmNewStickBMP.Destroy;
            exit;
         end;
         frmNewStickBMP.Destroy;
      end;

      for f := 1 to 32000 do
      begin
         bOk := TRUE;
         strTemp := 'Object ' + itoa(f);
         for g := 0 to frmMAin.m_olLayers.Count-1 do
         begin
            if TLayerObjPtr(frmMain.m_olLAyers.Items[g])^.m_strName = strTemp then bOk := FALSE;
         end;
         if (bOk) then
         begin
            break;
         end;
      end;
      frmMain.grdFrames.RowCount := frmMain.grdFrames.RowCount + 1;
      New(pLayer);
      pLayer^ := TLayerObj.Create(frmNewObj.m_nChoice, strFileName, strFile2);
      pLayer^.m_strName := strTemp;
      nIndex := frmMain.m_olLayers.Add(pLayer);
      //frmMain.m_col := 1;
      frmMAin.m_row := nIndex + 1;
      keyy := VK_F5;
      frmMain.grdFramesKeyUp(nil, keyy, [ssLeft]);
   end;
   frmNewObj.Free;
end;

procedure TfrmToolBar.imgAddKeyFrameClick(Sender: TObject);
var
   k : word;
begin
   if (frmMain.m_pFrame <> nil) then
   begin
      MessageBox(Application.HAndle, 'You cannot insert a FrameSet over another', 'Tis an Error', MB_OK or MB_ICONERROR);
      exit;
   end;
   k := VK_F5;
   frmMain.grdFramesKeyUp(nil, k, [ssLeft]);
end;

procedure TfrmToolBar.imgAddTweenClick(Sender: TObject);
var
   k : word;
begin
   k := VK_F6;
   frmMain.grdFramesKeyUp(self, k, [ssLeft]);
end;

procedure TfrmToolBar.imgBGColourClick(Sender: TObject);
begin
   if cd.Execute then
   begin
      frmMain.m_bgColor := cd.Color;
      frmMain.m_bChanged := TRUE;
   end;
   frmMain.Render(frmMain.m_col);

end;

procedure TfrmToolBar.imgSavePoseClick(Sender: TObject);
var
   f : integer;
begin
   if (frmMain.m_pTweenFrame <> nil) then
   begin
      if (frmMain.m_pTweenFrame^.m_nType = O_STICKMAN) then
      begin
         for f := 1 to 10 do
         begin
            m_nWid[f] := TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Wid[f];
            m_nPnt[f,1] := TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(f)^.Left;
            m_nPnt[f,2] := TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(f)^.Top;
            if f <> 10 then m_nLng[f] := TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Lng[f];
         end;
         m_nHeadDiam := TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_nHeadDiam;
      end;
      if (frmMain.m_pTweenFrame^.m_nType = O_SPECIALSTICK) then
      begin
         for f := 1 to 14 do
         begin
            m_nWid[f] := TSpecialStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Wid[f];
            m_nPnt[f,1] := TSpecialStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(f)^.Left;
            m_nPnt[f,2] := TSpecialStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(f)^.Top;
            if f <> 14 then m_nLng[f] := TSpecialStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Lng[f];
         end;
         m_nHeadDiam := TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_nHeadDiam;
      end;
      if (frmMain.m_pTweenFrame^.m_nType = O_STICKMANBMP) then
      begin
         for f := 1 to 10 do
         begin
            m_nWid[f] := TStickManBMPPtr(frmMain.m_pTweenFrame^.m_pObject)^.Wid[f];
            m_nPnt[f,1] := TStickManBMPPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(f)^.Left;
            m_nPnt[f,2] := TStickManBMPPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(f)^.Top;
            if f <> 10 then m_nLng[f] := TStickManBMPPtr(frmMain.m_pTweenFrame^.m_pObject)^.Lng[f];
         end;
      end;
      frmMain.Render(frmMain.m_col, TRUE);
   end;
end;

procedure TfrmToolBar.imgRestorePoseClick(Sender: TObject);
var
   f : integer;
begin
   if (frmMain.m_pTweenFrame <> nil) then
   begin
      if (frmMain.m_pTweenFrame^.m_nType = O_STICKMAN) then
      begin
         frmMain.m_bChanged := TRUE;
         for f := 1 to 10 do
         begin
            TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Wid[f] := m_nWid[f];
            TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(f)^.Left := m_nPnt[f,1];
            TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(f)^.Top := m_nPnt[f,2];
            if f <> 10 then TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Lng[f] := m_nLng[f];
         end;
         TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_nHeadDiam := m_nHeadDiam;
      end;
      if (frmMain.m_pTweenFrame^.m_nType = O_SPECIALSTICK) then
      begin
         frmMain.m_bChanged := TRUE;
         for f := 1 to 14 do
         begin
            TSpecialStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Wid[f] := m_nWid[f];
            TSpecialStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(f)^.Left := m_nPnt[f,1];
            TSpecialStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(f)^.Top := m_nPnt[f,2];
            if f <> 14 then TSpecialStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Lng[f] := m_nLng[f];
         end;
         TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_nHeadDiam := m_nHeadDiam;
      end;
      if (frmMain.m_pTweenFrame^.m_nType = O_STICKMANBMP) then
      begin
         frmMain.m_bChanged := TRUE;
         for f := 1 to 10 do
         begin
            TStickManBMPPtr(frmMain.m_pTweenFrame^.m_pObject)^.Wid[f] := m_nWid[f];
            TStickManBMPPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(f)^.Left := m_nPnt[f,1];
            TStickManBMPPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(f)^.Top := m_nPnt[f,2];
            if f <> 10 then TStickManBMPPtr(frmMain.m_pTweenFrame^.m_pObject)^.Lng[f] := m_nLng[f];
         end;
      end;
      frmMain.Render(frmMain.m_col, TRUE);
   end;
end;

procedure TfrmToolBar.imgMoveClick(Sender: TObject);
begin
   m_bMove := TRUE;
end;

procedure TfrmToolBar.imgPropsClick(Sender: TObject);
var
   f, g, h : integer;
   frmRectProps : TfrmRectProps;
   frmStickProps : TfrmStickProps;
   frmSubEdit : TfrmSubEdit;
   frmLineProps : TfrmLiner;
   frmTextProps : TfrmTextProps;
   frmStickED : TfrmSticked;
   v1,v2,v3,v4 : integer;
begin
   if (frmMain.m_pTweenFrame <> nil) then
   begin
         if frmMain.m_pTweenFrame^.m_nType = O_EDITVIDEO then
         begin
            frmMain.od.Filter := 'AVI Files (*.AVI)|*.avi';
            if (frmMain.od.Execute) then
            begin
               TEditVideoObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_strFileName := frmMain.od.FileName;
               frmMain.frmCanvas.aviPlaya.FileName := frmMain.od.FileName;
            end;
            frmMain.Render(frmMain.m_col);
            exit;
         end;
         if frmMain.m_pTweenFrame^.m_nType = O_STICKMAN then
         begin
            frmStickProps := TfrmStickProps.Create(frmMain);
            frmStickProps.m_SickMan.Assign(TStickManPtr(frmMain.m_pTweenFrame^.m_pObject));
            frmStickProps.ShowModal;
            if (frmStickProps.m_bOk) then
            begin
               frmMain.m_bChanged := TRUE;
               if (not frmStickProps.m_bApplyAll) then
               begin
                   for f := 1 to 9 do
                   begin
                      TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Lng[f] := frmStickProps.m_SickMan.Lng[f];
                   end;
                   for f := 1 to 10 do
                   begin
                      TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Wid[f] := frmStickProps.m_SickMan.Wid[f];
                   end;
                   TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_alpha := frmStickProps.m_nAlpha;
                   TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_InColour := frmStickProps.lblColour1.Color;
                   TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_OutColour := frmStickProps.lblColour2.Color;
                   TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_nHeadDiam := atoi(frmStickProps.m_strHeadDiam.Text);//frmStickProps.m_SickMan.m_nHeadDiam;
                   TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.SetPoint(TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(1)^.Left,TStickManPtr(frmMain.m_pTweenFrame^.m_pObject)^.Pnt(1)^.Top,1,1);
               end else
               begin
                  with (TLayerObjPtr(frmMain.m_olLayers.Items[frmMain.m_row-1])^) do
                  begin
                     for g := 0 to m_olFrames.Count-1 do
                     begin
                         with (TSingleFramePtr(m_olFrames.Items[g])^) do
                         begin
                             for h := 0 to m_Frames.Count-1 do
                             begin
                                 with TIFramePtr(m_Frames.Items[h])^ do
                                 begin
                                     for f := 1 to 9 do
                                     begin
                                        TStickManPtr(m_pObject)^.Lng[f] := frmStickProps.m_SickMan.Lng[f];
                                     end;
                                     for f := 1 to 10 do
                                     begin
                                        TStickManPtr(m_pObject)^.Wid[f] := frmStickProps.m_SickMan.Wid[f];
                                     end;
                                     TStickManPtr(m_pObject)^.m_alpha := frmStickProps.m_nAlpha;
                                     TStickManPtr(m_pObject)^.m_InColour := frmStickProps.lblColour1.Color;
                                     TStickManPtr(m_pObject)^.m_OutColour := frmStickProps.lblColour2.Color;
                                     TStickManPtr(m_pObject)^.m_nHeadDiam := atoi(frmStickProps.m_strHeadDiam.Text);//frmStickProps.m_SickMan.m_nHeadDiam;
                                     TStickManPtr(m_pObject)^.SetPoint(TStickManPtr(m_pObject)^.Pnt(1)^.Left,TStickManPtr(m_pObject)^.Pnt(1)^.Top,1,1);
                                 end;
                             end;
                         end;
                     end;
                  end;
               end;
            end;
            frmStickProps.Destroy;
            frmMain.Render(frmMain.m_col, TRUE);
         end;
//
         if frmMain.m_pTweenFrame^.m_nType = O_T2STICK then
         begin
            frmStickED := TfrmStickED.Create(frmMain);
            frmStickED.TempObject := TLimbListPtr(frmMain.m_pTempObject)^;
            frmStickED.Hide;
            frmStickED.AllowJointEditing := FALSE;
            frmStickED.actMoveJoint.Execute;
//
            frmStickED.Stick.CopyFrom(TLimbListPtr(frmMain.m_pTweenFrame^.m_pObject)^);
            frmStickED.Stick.CopyBitmapsShallow(TLimbListPtr(frmMain.m_pTempObject)^);
            frmStickED.alphaBar.Position := round(frmStickED.Stick.Alpha * 255);
            frmStickED.strAlpha.Text := inttostr(frmStickED.alphaBar.Position);
            frmStickED.ShowModal;
            frmStickED.Stick.ClearBitmaps; //just clears the shallows
            frmStickED.Stick.Move(-frmStickED.MoveX, -frmStickED.MoveY);
            if (frmStickED.AddStick) then
            begin
               frmMain.m_bChanged := TRUE;
               TLimbListPtr(frmMain.m_pTweenFrame^.m_pObject)^.CopyPropsFrom(frmStickED.Stick);
            end;
            frmStickED.Free;
            frmMain.Render(frmMain.m_col, TRUE);
         end;
//
         if frmMain.m_pTweenFrame^.m_nType = O_RECTANGLE then
         begin
            frmRectProps := TfrmRectProps.Create(frmMain);
            frmRectProps.m_nType := O_RECTANGLE;
            frmRectProps.m_nLineWidth := TSquareObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_nLineWidth;
            frmRectProps.m_nAlpha := TSquareObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_alpha;
            frmRectProps.alphaBar.Position := frmRectProps.m_nAlpha;
            frmRectProps.m_strAlpha.Text := inttostr(frmRectProps.m_nAlpha);
            frmRectProps.m_InColour := TSquareObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_InColour;
            frmRectProps.m_OutColour := TSquareObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_OutColour;
            frmRectProps.m_styleInner := TSquareObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_styleInner;
            frmRectProps.m_styleOuter := TSquareObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_styleOuter;
            frmRectProps.ShowModal;
            if (frmRectProps.m_bOk) then
            begin
               frmMain.m_bChanged := TRUE;
               if (frmRectProps.m_bApplyAll) then
               begin
                  with (TLayerObjPtr(frmMain.m_olLayers.Items[frmMain.m_row-1])^) do
                  begin
                     for g := 0 to m_olFrames.Count-1 do
                     begin
                         with (TSingleFramePtr(m_olFrames.Items[g])^) do
                         begin
                             for h := 0 to m_Frames.Count-1 do
                             begin
                                 with TIFramePtr(m_Frames.Items[h])^ do
                                 begin
                                   TSquareObjPtr(m_pObject)^.m_nLineWidth := frmRectProps.m_nLineWidth;
                                   TSquareObjPtr(m_pObject)^.m_alpha := frmRectProps.m_nAlpha;
                                   TSquareObjPtr(m_pObject)^.m_InColour := frmRectProps.m_InColour;
                                   TSquareObjPtr(m_pObject)^.m_OutColour := frmRectProps.m_OutColour;
                                   TSquareObjPtr(m_pObject)^.m_styleInner := frmRectProps.m_styleInner;
                                   TSquareObjPtr(m_pObject)^.m_styleOuter := frmRectProps.m_styleOuter;
                                 end;
                             end;
                         end;
                     end;
                  end;
               end else
               begin
                   TSquareObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_nLineWidth := frmRectProps.m_nLineWidth;
                   TSquareObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_alpha := frmRectProps.m_nAlpha;
                   TSquareObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_InColour := frmRectProps.m_InColour;
                   TSquareObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_OutColour := frmRectProps.m_OutColour;
                   TSquareObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_styleInner := frmRectProps.m_styleInner;
                   TSquareObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_styleOuter := frmRectProps.m_styleOuter;
               end;
            end;
            frmRectProps.Destroy;
            frmMain.Render(frmMain.m_col, TRUE);
         end;
         if frmMain.m_pTweenFrame^.m_nType = O_LINE then
         begin
            frmLineProps := TfrmLiner.Create(frmMain);
            frmLineProps.m_nLineWidth := TLineObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_nLineWidth;
            frmLineProps.m_Colour := TLineObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_Colour;
            frmLineProps.m_nAlpha := TLineObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_alpha;
            frmLineProps.alphaBar.Position := frmLineProps.m_nAlpha;
            frmLineProps.m_strAlpha.Text := inttostr(frmLineProps.m_nAlpha);

            frmLineProps.ShowModal;
            if (frmLineProps.m_bOk) then
            begin
               frmMain.m_bChanged := TRUE;
               if (frmLineProps.m_bApplyAll) then
               begin
                  with (TLayerObjPtr(frmMain.m_olLayers.Items[frmMain.m_row-1])^) do
                  begin
                     for g := 0 to m_olFrames.Count-1 do
                     begin
                         with (TSingleFramePtr(m_olFrames.Items[g])^) do
                         begin
                             for h := 0 to m_Frames.Count-1 do
                             begin
                                 with TIFramePtr(m_Frames.Items[h])^ do
                                 begin
                                    TLineObjPtr(m_pObject)^.m_nLineWidth := frmLineProps.m_nLineWidth;
                                    TLineObjPtr(m_pObject)^.m_alpha := frmLineProps.m_nAlpha;
                                    TLineObjPtr(m_pObject)^.m_Colour := frmLineProps.m_Colour;
                                 end;
                             end;
                         end;
                     end;
                  end;
               end else
               begin
                  TLineObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_nLineWidth := frmLineProps.m_nLineWidth;
                  TLineObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_alpha := frmLineProps.m_nAlpha;
                  TLineObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_Colour := frmLineProps.m_Colour;
               end;
            end;
            frmLineProps.Destroy;
            frmMain.Render(frmMain.m_col, TRUE);
         end;
         if frmMain.m_pTweenFrame^.m_nType = O_OVAL then
         begin
            frmRectProps := TfrmRectProps.Create(frmMain);
            frmRectProps.lblTitle.Caption := 'Oval Ovobulator';
            frmRectProps.m_nType := O_OVAL;
            frmRectProps.m_nLineWidth := TOvalObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_nLineWidth;
            frmRectProps.m_nAlpha := TOvalObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_alpha;
            frmRectProps.alphaBar.Position := frmRectProps.m_nAlpha;
            frmRectProps.m_strAlpha.Text := inttostr(frmRectProps.m_nAlpha);
            frmRectProps.m_InColour := TOvalObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_InColour;
            frmRectProps.m_OutColour := TOvalObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_OutColour;
            frmRectProps.m_styleInner := TOvalObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_styleInner;
            frmRectProps.m_styleOuter := TOvalObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_styleOuter;
            frmRectProps.ShowModal;
            if (frmRectProps.m_bOk) then
            begin
               frmMain.m_bChanged := TRUE;
               if (frmRectProps.m_bApplyAll) then
               begin
                  with (TLayerObjPtr(frmMain.m_olLayers.Items[frmMain.m_row-1])^) do
                  begin
                     for g := 0 to m_olFrames.Count-1 do
                     begin
                         with (TSingleFramePtr(m_olFrames.Items[g])^) do
                         begin
                             for h := 0 to m_Frames.Count-1 do
                             begin
                                 with TIFramePtr(m_Frames.Items[h])^ do
                                 begin
                                   TOvalObjPtr(m_pObject)^.m_nLineWidth := frmRectProps.m_nLineWidth;
                                   TOvalObjPtr(m_pObject)^.m_alpha := frmRectProps.m_nAlpha;
                                   TOvalObjPtr(m_pObject)^.m_InColour := frmRectProps.m_InColour;
                                   TOvalObjPtr(m_pObject)^.m_OutColour := frmRectProps.m_OutColour;
                                   TOvalObjPtr(m_pObject)^.m_styleInner := frmRectProps.m_styleInner;
                                   TOvalObjPtr(m_pObject)^.m_styleOuter := frmRectProps.m_styleOuter;
                                 end;
                             end;
                         end;
                     end;
                  end;
               end else
               begin
                   TOvalObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_nLineWidth := frmRectProps.m_nLineWidth;
                   TOvalObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_alpha := frmRectProps.m_nAlpha;
                   TOvalObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_InColour := frmRectProps.m_InColour;
                   TOvalObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_OutColour := frmRectProps.m_OutColour;
                   TOvalObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_styleInner := frmRectProps.m_styleInner;
                   TOvalObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_styleOuter := frmRectProps.m_styleOuter;
               end;
            end;
            frmRectProps.Destroy;
            frmMain.Render(frmMain.m_col, TRUE);
         end;
         if (frmMain.m_pTweenFrame^.m_nType = O_POLY) then
         begin
            frmRectProps := TfrmRectProps.Create(frmMain);
            frmRectProps.lblTitle.Caption := 'Poly Polythene';
            frmRectProps.m_nType := O_POLY;
            frmRectProps.m_nLineWidth := TPolyObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_nLineWidth;
            frmRectProps.m_nAlpha := TSquareObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_alpha;
            frmRectProps.alphaBar.Position := frmRectProps.m_nAlpha;
            frmRectProps.m_strAlpha.Text := inttostr(frmRectProps.m_nAlpha);
            frmRectProps.m_InColour := TPolyObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_InColour;
            frmRectProps.m_OutColour := TPolyObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_OutColour;
            frmRectProps.m_styleInner := TPolyObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_styleInner;
            frmRectProps.m_styleOuter := TPolyObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_styleOuter;
            frmRectProps.ShowModal;
            if (frmRectProps.m_bOk) then
            begin
               frmMain.m_bChanged := TRUE;
               if (frmRectProps.m_bApplyAll) then
               begin
                  with (TLayerObjPtr(frmMain.m_olLayers.Items[frmMain.m_row-1])^) do
                  begin
                     for g := 0 to m_olFrames.Count-1 do
                     begin
                         with (TSingleFramePtr(m_olFrames.Items[g])^) do
                         begin
                             for h := 0 to m_Frames.Count-1 do
                             begin
                                 with TIFramePtr(m_Frames.Items[h])^ do
                                 begin
                                    TPolyObjPtr(m_pObject)^.m_nLineWidth := frmRectProps.m_nLineWidth;
                                    TPolyObjPtr(m_pObject)^.m_alpha := frmRectProps.m_nAlpha;
                                    TPolyObjPtr(m_pObject)^.m_InColour := frmRectProps.m_InColour;
                                    TPolyObjPtr(m_pObject)^.m_OutColour := frmRectProps.m_OutColour;
                                    TPolyObjPtr(m_pObject)^.m_styleInner := frmRectProps.m_styleInner;
                                    TPolyObjPtr(m_pObject)^.m_styleOuter := frmRectProps.m_styleOuter;
                                 end;
                             end;
                         end;
                     end;
                  end;
               end else
               begin
                  TPolyObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_nLineWidth := frmRectProps.m_nLineWidth;
                  TPolyObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_alpha := frmRectProps.m_nAlpha;
                  TPolyObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_InColour := frmRectProps.m_InColour;
                  TPolyObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_OutColour := frmRectProps.m_OutColour;
                  TPolyObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_styleInner := frmRectProps.m_styleInner;
                  TPolyObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_styleOuter := frmRectProps.m_styleOuter;
               end;
            end;
            frmRectProps.Destroy;
            frmMain.Render(frmMain.m_col, TRUE);
         end;
         if (frmMain.m_pTweenFrame^.m_nType = O_SUBTITLE) then
         begin
            frmSubEdit := TfrmSubEdit.Create(self);
            frmSubEdit.memContent.Text := TSubTitleObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_strCaption;
            frmSubEdit.ShowModal;
            if (frmSubEdit.m_bOk) then
            begin
               TSubTitleObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_strCaption := frmSubEdit.memContent.Text;
            end else
            begin
               frmSubEdit.Destroy;
               frmSubEdit := nil;
               exit;
            end;
            frmSubEdit.Destroy;
            frmSubEdit := nil;
         end;
         if (frmMain.m_pTweenFrame^.m_nType = O_TEXT) then
         begin
            frmTextProps := TfrmTextProps.Create(self);
            frmTextProps.m_OuterColour := TTextObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_OutColour;
            frmTextProps.m_InnerColour := TTextObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_InColour;
            frmTextProps.lblFontColour.Color := TTextObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_InColour;
            frmTextProps.lblColour.Color := TTextObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_OutColour;
            frmTextProps.m_strFontName := TTextObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_strFontName;
            frmTextProps.cboFontNames.ItemIndex := frmTextProps.cboFontNames.Items.IndexOf(frmTextProps.m_strFontName);
            frmTextProps.m_styleOuter := TTextObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_styleOuter;
            frmTextProps.m_strCaption.Text := TTextObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_strCaption;
            frmTextProps.ShowModal;
            if (frmTextProps.m_bOk) then
            begin
               frmMain.m_bChanged := TRUE;
               TTextObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_strCaption := frmTextProps.m_strCaption.Text;
               TTextObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_InColour := frmTextProps.lblFontColour.Color;
               TTextObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_OutColour := frmTextProps.lblColour.Color;
               TTextObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_strFontName := frmTextProps.m_strFontName;
               TTextObjPtr(frmMain.m_pTweenFrame^.m_pObject)^.m_styleOuter := frmTextProps.m_styleOuter;
            end else
            begin
               frmTextProps.Destroy;
               frmTextProps := nil;
               exit;
            end;
            frmTextProps.Destroy;
            frmTextProps := nil;
            frmMain.Render(frmMain.m_col, TRUE);
         end;
   end;
end;

procedure TfrmToolBar.imgCASClick(Sender: TObject);
begin
  m_cas.AssignLayers(frmMain.m_olLayers, frmMain.m_col);
  m_cas.Show;
end;

procedure TfrmToolBar.imgClickAnimClick(Sender: TObject);
begin
   frmMain.mnuInsertPoseClick(nil);
end;

procedure TfrmToolBar.imgPlayClick(Sender: TObject);
var
   f, g, h : integer;
   nDel : integer;
   nEnd : integer;
   pLayer : TLayerObjPtr;
   dwStart : DWORD;
   nDiff : integer;
begin

   val(m_strFPS.Text, f,h);
   if (f = 0) then
   begin
      MessageBox(Application.Handle, 'Please enter an integer for the FrameRate', 'Tis an Error', MB_OK or MB_ICONERROR);
      exit;
   end;
   if (f < 1) then
   begin
      MessageBox(Application.Handle, 'Please enter an FrameRate larger than 0', 'Tis an Error', MB_OK or MB_ICONERROR);
      exit;
   end;

   imgStop.Left := imgPlay.Left;
   imgStop.Top := imgPlay.Top;
   imgPlay.Hide;
   imgStop.Show;

   frmMain.m_bPlaying := TRUE;
   nEnd := 1;
   for f := 0 to frmMain.m_olLayers.Count-1 do
   begin
      pLayer := frmMain.m_olLayers.Items[f];
      for g := 0 to pLayer^.m_olFrames.Count-1 do
      begin
         if TIFramePtr(TSingleFramePtr(pLayer^.m_olFrames.Items[g])^.m_Frames.Last)^.m_FrameNo > nEnd then
         begin
            nEnd := TIFramePtr(TSingleFramePtr(pLayer^.m_olFrames.Items[g])^.m_Frames.Last)^.m_FrameNo;
         end;
      end;
      for h := 0 to pLayer^.m_olActions.Count-1 do
      begin
         if (TActionObjPtr(pLayer^.m_olActions.Items[h])^.m_nType = 0) then
         begin
            TActionObjPtr(pLayer^.m_olActions.Items[h])^.m_nParams[3] := 0;
         end;
      end;
   end;
   m_nEnd := nEnd;

   m_nCurrentFrame := frmMain.m_col;
   if (frmMain.m_col >= nEnd) then m_nCurrentFrame := 1;

   nDel := round(600 / atoi(m_strFPS.Text));
   while m_nCurrentFrame < nEnd do
   begin
      frmMain.Render(m_nCurrentFrame);
      Application.ProcessMessages;
      sleep(nDel);
      m_nCurrentFrame := m_nCurrentFrame + 1;
      if (frmMain.m_bQuit) then
      begin
         break;
      end;
   end;
   imgStop.Hide;
   imgPlay.Show;
   m_nCurrentFrame := 1;
   frmMain.m_col := nEnd;
   frmMAin.grdFrames.Repaint;
   frmMain.Render(nEnd);
   frmMain.m_bPlaying := FALSE;
   if (frmMain.m_bQuit) then
   begin
      frmMain.m_bReady := TRUE;
      frmMain.Close;
   frmMain.m_bOld := FALSE;
   end;
end;

procedure TfrmToolBar.imgScaleClick(Sender: TObject);
var
   frmScale : TfrmScale;
begin
//
   if (frmMain.m_pTweenFrame <> nil) then
   begin
      frmScale := TfrmScale.Create(self);
      frmScale.Left := (frmMain.Left + frmMain.Width div 2) - (frmScale.Width div 2);
      frmScale.Top := frmMain.Top + 24;
      frmScale.ShowModal;
      frmScale.Destroy;
      frmMain.Render(frmMain.m_col);
   end else
   begin
      MessageBox(application.handle, 'You need to first select a KeyFrame', 'Tis an Error', MB_OK or MB_ICONERROR);
   end;
end;

procedure TfrmToolBar.imgStopClick(Sender: TObject);
begin
   m_nCurrentFrame := m_nEnd;
   frmMain.m_xinc := 0;
   frmMain.m_yinc := 0;
   frmMain.m_xincmax := 0;
   frmMain.m_yincmax := 0;
   frmMain.m_bOld := FALSE;
end;

end.

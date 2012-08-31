unit newstickbmp;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtDlgs, ExtCtrls, jpeg, configfile;

type
  TfrmNewStickBMP = class(TForm)
    Button1: TButton;
    Button2: TButton;
    od: TOpenPictureDialog;
    lblTitle: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    imgClosed: TImage;
    imgOpen: TImage;
    cmdOK: TButton;
    cmdCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure lblTitleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblTitleMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblTitleMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure cmdOKClick(Sender: TObject);
    procedure cmdCancelClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure imgClosedClick(Sender: TObject);
    procedure imgOpenClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    m_bOK : boolean;
    m_bMoving :  BOOLEAN;
    m_nX, m_nY : integer;
    m_strFileName1, m_strFileName2 : string;
    m_Settings : TSettingsRec;
  end;

implementation

{$R *.dfm}

procedure TfrmNewStickBMP.FormCreate(Sender: TObject);
begin
   lblTitle.Left := 2;
   lblTitle.Top := 2;
   lblTitle.Width := ClientWidth - 4;
   lblTitle.Height := ClientHeight - 4;
   lblTitle.Color := clBlue;
   lblTitle.Height := 17;
   Left := (screen.width div 2) - (clientwidth div 2);
   Top := (screen.height div 2) - (clientheight div 2);
   if (LoadSettings(extractfilepath(application.exename)+'tis.fat', m_Settings)) then
   begin
      od.InitialDir := m_Settings.OPFilePath;
   end;
end;

procedure TfrmNewStickBMP.FormPaint(Sender: TObject);
begin
   Canvas.Pen.Color := clBlack;
   Canvas.Brush.Color := rgb(240,240,240);
   Canvas.Rectangle(0,0,ClientWidth,ClientHeight);
end;

procedure TfrmNewStickBMP.lblTitleMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := TRUE;
   m_nX := x;
   m_nY := y;
end;

procedure TfrmNewStickBMP.lblTitleMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := FALSE;
end;

procedure TfrmNewStickBMP.lblTitleMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   if (m_bMoving) then
   begin
      Left := Left + (x - m_nX);
      Top := Top + (y - m_nY);
   end;
end;

procedure TfrmNewStickBMP.cmdOKClick(Sender: TObject);
begin
   if (m_strFileName1 = '') then
   begin
      MessageBox(Handle, 'You need to load a picture for the closed mouth state before continuing.', 'Tis an Error', MB_OK or MB_ICONERROR);
      exit;
   end;
   if (m_strFileName2 = '') then
   begin
      MessageBox(Handle, 'You need to load a picture for the open mouth state before continuing.', 'Tis an Error', MB_OK or MB_ICONERROR);
      exit;
   end;
   SaveSettings(extractfilepath(application.exename)+'tis.fat', m_Settings);
   m_bOK := TRUE;
   Close;
end;

procedure TfrmNewStickBMP.cmdCancelClick(Sender: TObject);
begin
   m_bOK := FALSE;
   Close;
end;

procedure TfrmNewStickBMP.Button1Click(Sender: TObject);
begin
   if (od.Execute) then
   begin
      imgClosed.Picture.LoadFromFile(od.FileName);
      m_strFileName1 := od.FileName;
      m_Settings.OPFilePath := extractfilepath(od.FileName);
   end;
end;

procedure TfrmNewStickBMP.Button2Click(Sender: TObject);
begin
   if (od.Execute) then
   begin
      imgOpen.Picture.LoadFromFile(od.FileName);
      m_strFileName2 := od.FileName;
      m_Settings.OPFilePath := extractfilepath(od.FileName);
   end;
end;

procedure TfrmNewStickBMP.imgClosedClick(Sender: TObject);
begin
   if (od.Execute) then
   begin
      imgClosed.Picture.LoadFromFile(od.FileName);
      m_strFileName1 := od.FileName;
   end;
end;

procedure TfrmNewStickBMP.imgOpenClick(Sender: TObject);
begin
   if (od.Execute) then
   begin
      imgOpen.Picture.LoadFromFile(od.FileName);
      m_strFileName2 := od.FileName;
   end;
end;

end.

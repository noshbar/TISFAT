unit actions;

interface

uses
  Windows, Messages, SysUtils, {Variants, }Classes,{ Graphics, }Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmAction = class(TForm)
    cmdOK: TButton;
    cmdCancel: TButton;
    rg: TRadioGroup;
    lblTitle: TLabel;
    od: TOpenDialog;
    lblCaption: TLabel;
    strInfo: TEdit;
    cmdBrowse: TButton;
    strInfo2: TEdit;
    lblCaption2: TLabel;
    chk1: TCheckBox;
    chk2: TCheckBox;
    cmdNothing: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure cmdOKClick(Sender: TObject);
    procedure cmdCancelClick(Sender: TObject);
    procedure rgClick(Sender: TObject);
    procedure cmdBrowseClick(Sender: TObject);
    procedure lblTitleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblTitleMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lblTitleMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cmdNothingClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    m_bOK : boolean;
    m_bMoving : boolean;
    m_nX, m_nY : integer;
    m_nEnd : integer;
    m_bNothing : boolean;
  end;

implementation

{$R *.dfm}

{$i inc.inc}

procedure TfrmAction.FormCreate(Sender: TObject);
begin
   lblTitle.Color := rgb(0,0,255);
   lblTitle.Left := 2;
   lblTitle.Top := 2;
   lblTitle.Width := clientwidth - 4;
   lblTitle.Height := 17;
   rg.Color := rgb(240,240,240);
   rg.ItemIndex := 0;
   rgClick(sender);

   strInfo2.Hide;
   strInfo.Hide;
   lblCaption.Hide;
   chk1.Hide;
   chk2.Hide;

   chk1.Color := rgb(240,240,240);
   chk2.Color := rgb(240,240,240);

   m_bNothing := FALSE;

end;

procedure TfrmAction.FormPaint(Sender: TObject);
begin
   Canvas.Pen.Color := rgb(0,0,0);
   Canvas.Brush.Color := rgb(240,240,240);
   Canvas.Rectangle(0,0,width,height);
end;

procedure TfrmAction.cmdOKClick(Sender: TObject);
var
   t : file of integer;
   buffer : array[0..3] of integer;
   nRead : integer;
   v, code : integer;
begin
   if (rg.ItemIndex = A_SHAKE) then
   begin
      val(strInfo.Text, v, code);
      if (code <> 0) then
      begin
         MessageBox(handle, 'Enter an integer value for the amount to shake the screen.', 'Error', MB_OK or MB_ICONERROR);
         exit;
      end;
   end;
   if (rg.ItemIndex = A_JUMPTO) then
   begin
      val(strInfo.Text, v, code);
      if (code <> 0) then
      begin
         MessageBox(handle, 'The frame number can only be an integer value', 'Error', MB_OK or MB_ICONERROR);
         exit;
      end;
      val(strInfo2.Text, v, code);
      if (code <> 0) then
      begin
         MessageBox(handle, 'The loop number can only be an integer value', 'Error', MB_OK or MB_ICONERROR);
         exit;
      end;
      if (v < 1) or (v > m_nEnd) then
      begin
         MessageBox(handle, 'The frame you have entered is out of range', 'Error', MB_OK or MB_ICONERROR);
         exit;
      end;
   end;
   if (rg.ItemIndex = A_LOADNEW) then
   begin
      if (strInfo.Text = '') then
      begin
         MessageBox(handle, 'You need to specify which file to load', 'Error', MB_OK or MB_ICONERROR);
         exit;
      end;
      if (not fileexists(strInfo.Text)) then
      begin
         if (MessageBox(handle, pChar('The file specified (' + strInfo.Text + ') does not exist, continue anyway?'), 'Error', MB_YESNO or MB_ICONERROR) = IDNO) then
         begin
            exit;
         end;
      end;
      if (fileexists(strInfo.Text)) then
      begin
         assignfile(t, strInfo.Text);
         reset(t);
         blockread(t, buffer, 4, nRead);
         closefile(t);
         if (nRead <> 4) then
         begin
            if (MessageBox(handle, pChar('There was an error reading the file specified (' + strInfo.Text + '), or it is not a QSM file. Would you like to use this file anyway?'), 'Error', MB_YESNO or MB_ICONERROR) = IDNO) then
            begin
               exit;
            end;
         end;
         if (buffer[0] <> ord('I')) or (buffer[1] <> ord('H')) or (buffer[2] <> ord('8')) or (buffer[3] <> ord('U')) then
         begin
            if (MessageBox(handle, pChar('There the file specified (' + strInfo.Text + ') does not appear to be a SIF file. Would you like to use this file anyway?'), 'Error', MB_YESNO or MB_ICONERROR) = IDNO) then
            begin
               exit;
            end;
         end;
      end;
   end;
   m_bOk := TRUE;
   Close;
end;

procedure TfrmAction.cmdCancelClick(Sender: TObject);
begin
   m_bOk := FALSE;
   Close;
end;

procedure TfrmAction.rgClick(Sender: TObject);
begin
   lblCaption.Hide;
   strInfo.Hide;
   cmdBrowse.Hide;
   strInfo2.Hide;
   lblCaption2.Hide;
   chk1.Hide;
   chk2.Hide;
   if (rg.ITemIndex = A_JUMPTO) then
   begin
      lblCaption.Caption := 'Jump to frame number (1 to ' + inttostr(m_nEnd) + '): ';
      strInfo.Left := lblCaption.Left + lblCaption.Width;
      strInfo.Text := '1';
      strInfo.Width := 40;
      lblCaption2.Caption := '#Times: ';
      lblCaption2.Left := strInfo.Left + strInfo.Width + 5;
      lblCaption2.Top := lblCaption.Top;
      strInfo2.Width := 24;
      strInfo2.Text := '0';
      strInfo2.Top := strInfo.Top;
      strInfo2.Left := lblCaption2.Left + lblCaption2.Width;

      lblCaption.Show;
      strInfo.Show;
      lblCaption2.Show;
      strInfo2.Show;
   end;
   if (rg.ItemIndex = A_LOADNEW) then
   begin
      lblCaption.Caption := 'Movie name: ';
      strInfo.Left := lblCaption.Left + lblCaption.Width;
      strInfo.Text := '';
      cmdBrowse.Left := ClientWidth - 10 - cmdBrowse.Width;
      strInfo.Width := cmdBrowse.Left - (lblCaption.Left + lblCaption.Width) - 5;
      lblCaption.Show;
      strInfo.Show;
      cmdBrowse.Show;
   end;
   if (rg.ItemIndex = A_SHAKE) then
   begin
      lblCaption.Caption := 'Shake amount: ';
      strInfo.Left := lblCaption.Left + lblCaption.Width;
      strInfo.Text := '3';
      strInfo.Width := 25;
      chk1.Caption := 'Shake X axis';
      chk2.Caption := 'Shake Y axis';
      chk1.Checked := TRUE;
      chk2.Checked := TRUE;

      lblCaption.Show;
      strInfo.Show;
      chk1.Width := chk2.width;
      chk1.Top := chk2.top;
      chk2.Show;
      chk1.Show;
   end;
   if (rg.ItemIndex = A_OLD) then
   begin
      chk1.Caption := 'Make movie look old';
      chk1.Width := 150;
      chk1.Checked := TRUE;
      chk1.top := 120;
      chk1.Show;
   end;
end;

procedure TfrmAction.cmdBrowseClick(Sender: TObject);
begin
   if (od.Execute) then
   begin
      strInfo.Text := od.FileName;
   end;
end;

procedure TfrmAction.lblTitleMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := TRUE;
   m_nX := x;
   m_nY := y;
end;

procedure TfrmAction.lblTitleMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   if (m_bMoving) then
   begin
      left := left + (x - m_nX);
      top := top + (y - m_nY);
   end;
end;

procedure TfrmAction.lblTitleMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := FALSE;
end;

procedure TfrmAction.cmdNothingClick(Sender: TObject);
begin
   m_bOK := TRUE;
   m_bNothing := TRUE;
   close;
end;

end.

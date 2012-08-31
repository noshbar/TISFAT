unit aoubt;

interface

uses
  Windows, Messages, SysUtils, {Variants, }Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, jpeg, shellapi;

type
  TfrmAbout = class(TForm)
    lblMove: TLabel;
    imgOK: TImage;
    Label2: TLabel;
    Image2: TImage;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure lblMoveMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblMoveMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblMoveMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormPaint(Sender: TObject);
    procedure imgOKMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Label2Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    m_bMoving : BOOLEAN;
    m_nX, m_nY : integer;
    m_nRad : integer;
  end;

implementation

{$R *.dfm}

procedure TfrmAbout.FormCreate(Sender: TObject);
var
   f,g : integer;
begin
   m_nRad := 5;

   ClientWidth := Image2.Left + Image2.Width + 2;
   ClientHeight := imgOK.Top + imgOK.Height + 5;

   color := rgb(222,151,00);
   left := screen.width div 2 - width div 2;
   top := screen.Height div 2 - height div 2;
   lblMove.Width := ClientWidth - 4;
end;

procedure TfrmAbout.lblMoveMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_nX := x;
   m_nY := y;
   m_bMoving := TRUE;
end;

procedure TfrmAbout.lblMoveMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := FALSE;
end;

procedure TfrmAbout.lblMoveMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   if (m_bMoving) then
   begin
      Left := LEft + (x - m_nX);
      Top := Top + (y - m_nY);
   end;
end;

procedure TfrmAbout.FormPaint(Sender: TObject);
var
   f, g : integer;
   l, t : integer;
begin
   Canvas.Brush.Color := rgb(41,183,252);
   Canvas.Pen.Color := clBlack;
   Canvas.Rectangle(0,0,Width,Height);
   //
   Canvas.Font.Name := 'Tahoma';
   Canvas.Font.Size := 7;
   Canvas.Font.Color := clBlack;
   Canvas.TextOut(10,Image2.Top + Image2.Height + 5, 'This Is Stick Figure Animation Theatre (TISFAT [tm]) is a');
   Canvas.TextOut(10,Image2.Top + Image2.Height + 20, 'poor production by Dirk de la Hunt, with everything copyright');
   Canvas.TextOut(10,Image2.Top + Image2.Height + 35, '2002-2008. For help, read the help file, or visit these forums:');

//   Canvas.Rectangle(Image2.left-1, image2.top-1, image2.left+image2.width+1, image2.top+image2.height+1);
end;

procedure TfrmAbout.imgOKMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   Close;
end;

procedure TfrmAbout.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if Key = VK_RETURN then
   begin
      Close;
   end;
end;

procedure TfrmAbout.FormClose(Sender: TObject; var Action: TCloseAction);
var
   f : integer;
begin
      for f := 1 to 100000 do
      begin
         Canvas.Pixels[random(width), random(height)] := clGray;
         application.processmessages;
      end;
end;

procedure TfrmAbout.Label1Click(Sender: TObject);
begin
   shellexecute(application.handle, 'open', 'http://s7.invisionfree.com/TISFAT', '', '', SW_NORMAL);
end;

procedure TfrmAbout.Label2Click(Sender: TObject);
begin
   shellexecute(application.handle, 'open', 'http://www.tisfatsucks.com', '', '', SW_NORMAL);
end;

end.

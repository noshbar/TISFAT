unit subtitles;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmSubtitles = class(TForm)
    lblContent: TLabel;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AddString(sub : string);
    procedure Clear;
  end;

var
  frmSubtitles: TfrmSubtitles;

implementation

uses drawcanvas, main;

{$R *.dfm}

procedure TfrmSubtitles.AddString(sub : string);
begin
   lblContent.Caption := lblContent.Caption + sub + '  ' + #10;
end;

procedure TfrmSubtitles.Clear;
begin
   lblContent.Caption := '  ';
end;

procedure TfrmSubtitles.FormResize(Sender: TObject);
begin
   Width := frmMain.frmCanvas.Width;
end;

procedure TfrmSubtitles.FormCreate(Sender: TObject);
begin
   LEft := frmMain.frmCanvas.LEft;
   Top := frmMain.frmCanvas.Top + frmMain.frmCanvas.Height;
end;

procedure TfrmSubtitles.FormPaint(Sender: TObject);
begin
   canvas.pen.color := clBlack;
   canvas.brush.color := rgb(240,240,240);
   canvas.Rectangle(0,0,width,height);
end;

end.

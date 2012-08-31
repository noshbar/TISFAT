unit betanotes;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmReadMe = class(TForm)
    memContent: TMemo;
    cmdClose: TButton;
    chkNoShow: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure cmdCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmReadMe: TfrmReadMe;

implementation

{$R *.dfm}

procedure TfrmReadMe.FormCreate(Sender: TObject);
begin
   if (fileexists(extractfilepath(application.exename)+'new.txt')) then
   begin
      memContent.Lines.LoadFromFile(extractfilepath(application.exename)+'new.txt');
   end else
   begin
      memContent.Text := 'TISFAT is currently in Beta stages, and as with all Beta''s, might have bugs, and different releases may treat things differently. To find out about the changes in each version, read the README.TXT file';
   end;
   Left := (screen.width div 2) - (width div 2);
   Top := (screen.height div 2) - (height div 2);
end;

procedure TfrmReadMe.cmdCloseClick(Sender: TObject);
begin
   Close;
end;

end.

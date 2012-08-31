unit gotoform;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmGoto = class(TForm)
    m_strFrameNo: TEdit;
    cmdOK: TButton;
    cmdCancel: TButton;
    Label1: TLabel;
    procedure cmdOKClick(Sender: TObject);
    procedure cmdCancelClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    m_bOk : boolean;
    m_nFrame : integer;
  end;

var
  frmGoto: TfrmGoto;

implementation

{$R *.dfm}

procedure TfrmGoto.cmdOKClick(Sender: TObject);
var
   i : integer;
begin
   m_bOk := true;
   val(m_strFrameNo.Text, m_nFrame, i);
   if (i = 0) then
   begin
      close;
   end else
   begin
      MessageBox(handle, 'Please type an integer value', 'Error', MB_OK or MB_ICONERROR);
   end;
end;

procedure TfrmGoto.cmdCancelClick(Sender: TObject);
begin
   m_bOk := false;
   close;
end;

procedure TfrmGoto.FormActivate(Sender: TObject);
begin
   m_strFrameNo.SetFocus;
end;

procedure TfrmGoto.FormCreate(Sender: TObject);
begin
   Color := rgb(240,240,240);
end;

end.

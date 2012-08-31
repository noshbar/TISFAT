unit subedit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmSubEdit = class(TForm)
    cmdOK: TButton;
    cmdCancel: TButton;
    memContent: TMemo;
    Label1: TLabel;
    procedure cmdOKClick(Sender: TObject);
    procedure cmdCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    m_bOk : boolean;
  end;

var
  frmSubEdit: TfrmSubEdit;

implementation

{$R *.dfm}

procedure TfrmSubEdit.cmdOKClick(Sender: TObject);
begin
   m_bOK := TRUE;
   Close;
end;

procedure TfrmSubEdit.cmdCancelClick(Sender: TObject);
begin
   m_bOK := FALSE;
   Close;
end;

procedure TfrmSubEdit.FormShow(Sender: TObject);
begin
   memContent.SetFocus;
end;

end.

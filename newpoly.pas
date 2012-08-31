unit newpoly;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmNewPoly = class(TForm)
    cmdOK: TButton;
    cmdCancel: TButton;
    Label1: TLabel;
    m_strPoints: TEdit;
    procedure cmdOKClick(Sender: TObject);
    procedure cmdCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    m_bOK : boolean;
  end;

implementation

{$R *.dfm}

procedure TfrmNewPoly.cmdOKClick(Sender: TObject);
var
   n, code : integer;
begin
   val(m_strPoints.Text, n, code);
   if (code <> 0) then
   begin
      MessageBox(handle, 'The point count can only be an integer value', 'Error', MB_OK or MB_ICONERROR);
      exit;
   end;
   if (n < 3) or (n > 100) then
   begin
      MessageBox(Handle, 'The amount of points must be in the range of 3 to 100', 'New polygon', MB_ICONERROR or MB_OK);
      exit;
   end;
   m_bOK := TRUE;
   Close;
end;

procedure TfrmNewPoly.cmdCancelClick(Sender: TObject);
begin
   m_bOK := FALSE;
   Close;
end;

end.

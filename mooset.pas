unit mooset;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmMovieSettings = class(TForm)
    cmdOK: TButton;
    cmdCancel: TButton;
    m_strWidth: TEdit;
    m_strHeight: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure cmdOKClick(Sender: TObject);
    procedure cmdCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    m_bOK : BOOLEAN;
  end;

implementation

{$R *.dfm}

procedure TfrmMovieSettings.cmdOKClick(Sender: TObject);
var
   v, code : integer;
begin
   val(m_strWidth.Text, v, code);
   if (code <> 0) then
   begin
      MessageBox(handle, 'The width value can only be an integer value', 'Error', MB_OK or MB_ICONERROR);
      exit;
   end;
   val(m_strHeight.Text, v, code);
   if (code <> 0) then
   begin
      MessageBox(handle, 'The height value can only be an integer value', 'Error', MB_OK or MB_ICONERROR);
      exit;
   end;
   m_bOK := TRUE;
   {assignfile(t, 'settings.cfg');
   if not fileexists('settings.cfg') then
   begin
      rewrite(t);
   end else
   begin
      reset(t);
   end;
   while not (eof(t)) do
   begin
      read(t, strHeading);
      if uppercase(strHeading) = '[MOVIE WIDTH]' then
      begin
         strValue := m_strWidth.Text;
         write(t, strValue);
      end else
      if uppercase(strHeading) = '[MOVIE HEIGHT]' then
      begin
         strValue := m_strHeight.Text;
         write(t, strValue);
      end else
      begin
         read(t, strValue);
      end;
   end;
   closefile(t);}
   Close;
end;

procedure TfrmMovieSettings.cmdCancelClick(Sender: TObject);
begin
   m_bOK := FALSe;
   Close;
end;

procedure TfrmMovieSettings.FormCreate(Sender: TObject);
type
   str128 = string[128];
var
   t : file of str128;
   strHeading, strValue : str128;
begin
   if (fileexists('settings.cfg')) then
   begin
      assignfile(t, 'settings.cfg');
      reset(t);
      while not eof(t) do
      begin
         read(t, strHeading);
         if (uppercase(strHeading) = '[MOVIE WIDTH]') then
         begin
            read(t, strValue);
            m_strWidth.Text := strValue;
         end else
         if (uppercase(strHeading) = '[MOVIE HEIGHT]') then
         begin
            read(t, strValue);
            m_strHeight.Text := strValue;
         end else
         begin
            read(t, strValue);
         end;
      end;
      closefile(t);
   end;
end;

end.

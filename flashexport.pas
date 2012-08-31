unit flashexport;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmFlashExport = class(TForm)
    Button1: TButton;
    Button2: TButton;
    m_strFileNAme: TEdit;
    sd: TSaveDialog;
    cmdBrosw: TButton;
    Label1: TLabel;
    Label2: TLabel;
    m_strSoundtrack: TEdit;
    Button3: TButton;
    od: TOpenDialog;
    m_rbMovie: TRadioButton;
    m_rbVideo: TRadioButton;
    Label3: TLabel;
    procedure cmdBroswClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses flashy, main;

{$R *.dfm}

procedure TfrmFlashExport.cmdBroswClick(Sender: TObject);
begin
   if (sd.Execute) then
   begin
      m_strFileName.text := sd.filename;
   end;
end;

procedure TfrmFlashExport.Button3Click(Sender: TObject);
begin
   if (od.execute) then
   begin
      m_strSoundtrack.TExt := od.FileName;
   end;
end;

procedure TfrmFlashExport.Button1Click(Sender: TObject);
begin
   if (m_strFileNAme.Text = '') then
   begin
      MessageBox(self.Handle, 'Please enter a valid filename to export to', 'Error', MB_OK or MB_ICONERROR);
      exit;
   end;
   if (m_rbMovie.Checked) then
   begin
      ExportFlash(m_strFileNAme.text, m_strSoundtrack.Text, frmMain.m_olLayers);
   end else
   begin
      frmMain.ExportFlashVideo(m_strFileName.Text, m_strSoundtrack.Text);
   end;
   close;
end;

procedure TfrmFlashExport.Button2Click(Sender: TObject);
begin
   close;
end;

end.

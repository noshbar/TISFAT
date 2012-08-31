program tisfat;

uses
  Forms,
  main in 'main.pas' {frmMain},
  tools in 'tools.pas' {frmToolBar},
  export in 'export.pas' {frmExport},
  layername in 'layername.pas' {frmLayerName},
  gotoform in 'gotoform.pas' {frmGoto},
  label2 in 'label2.pas',
  stickrenderer in 'stickrenderer.pas',
  CASform in 'CASform.pas' {frmCAS},
  movieobject in 'movieobject.pas';

{$R *.res}

const
    MCW_EM = longword($133f);

begin
  Application.Initialize;
  Set8087CW(MCW_EM);
  Application.Title := 'TISFAT Beta';
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmToolBar, frmToolBar);
  Application.CreateForm(TfrmExport, frmExport);
  Application.CreateForm(TfrmLayerName, frmLayerName);
  Application.CreateForm(TfrmGoto, frmGoto);
  frmToolBar.Show;
  Application.Run;
end.

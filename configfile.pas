unit configfile;

interface

type
   TSettingsRec = record
      Left, Top, Width, Height : integer;
      CanvasLeft, CanvasTop : integer;
      ToolLeft, ToolTop : integer;
      WindowState : integer;
      ODFilePath : string[255];  //open dialog
      OPFilePath : string[255];  //open picture
      OSFilePath : string[255];  //open sound
      AviFilePath : string[255];
      SaveFilePath : string[255];
      OpenFilePath : string[255];
   end;

function LoadSettings(strFileName : string; var recSettings : TSettingsRec) : BOOLEAN;
procedure SaveSettings(strFileName : string; recSettings : TSettingsRec);

implementation

uses SysUtils, Windows;

function LoadSettings(strFileName : string; var recSettings : TSettingsRec) : BOOLEAN;
var
   t : file of TSettingsRec;
begin
   LoadSettings := FALSE;
   if (FileExists(strFileName)) then
   begin
      assignfile(t, strFileName);
      {$I-}
      Reset(t);
      {$I+}
      if IOResult = 0 then
      begin
         read(t, recSettings);
         closefile(t);
         LoadSettings := TRUE;
      end else
      begin
         //MessageBox(getdesktopwindow, pChar('Could not load settings, error ' + inttostr(IOResult)), 'Error', MB_OK or MB_ICONERROR);
      end;
   end;
end;

procedure SaveSettings(strFileName : string; recSettings : TSettingsRec);
var
   t : file of TSettingsRec;
begin
   assignfile(t, strFileName);
   {I-}
   rewrite(t);
   {I+}
   if IOResult = 0 then
   begin
      write(t, recSettings);
      closefile(t);
   end else
   begin
      //MessageBox(getdesktopwindow, pChar('Could not save settings, error ' + inttostr(IOResult)), 'Error', MB_OK or MB_ICONERROR);
   end;
end;

end.
 
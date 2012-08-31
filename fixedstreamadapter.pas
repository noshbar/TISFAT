unit FixedStreamAdapter;
interface
uses
  classes, sysUtils, activex, windows;
type
  TFixedStreamAdapter = class(TStreamAdapter)
public
function Stat(out statstg: TStatStg;
      grfStatFlag: Longint): HResult; override; stdcall;
end;
implementation 

function DateTimeToFileTime(DateTime: TDateTime): TFileTime;
// copied from JclDateTime.pas
const
  FileTimeBase      = -109205.0;
  FileTimeStep: Extended = 24.0 * 60.0 * 60.0 * 1000.0 * 1000.0 *10.0; // 100 nSek per Day
var
  E: Extended;
  F64: Int64;
begin
  E := (DateTime - FileTimeBase) * FileTimeStep;
  F64 := Round(E);
  Result := TFileTime(F64);
end;
function TFixedStreamAdapter.Stat(out statstg: TStatStg; grfStatFlag: Longint): HResult;
Begin
  Result := S_OK;
try
if (@statstg <> nil) then
with statstg do
begin
        FillChar(statstg, sizeof(statstg), 0);
        dwType := STGTY_STREAM;
        cbSize := Stream.size;
        mTime := DateTimeToFileTime(now);
        cTime := DateTimeToFileTime(now);
        aTime := DateTimeToFileTime(now);
        grfLocksSupported := LOCK_WRITE;
end;
except
    Result := E_UNEXPECTED;
end;
end;
end.
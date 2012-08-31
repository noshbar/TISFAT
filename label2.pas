unit label2;

interface

uses graphics;

type
  pfUpdate = procedure(nIndex : integer) of object;

  TLabel2Ptr = ^TLabel2;
  TLabel2 = class(TObject)
  public
      Left, Top : integer;
      Tag : integer;
      Color : TColor;
      m_pUpdate : pfUpdate;
      m_bLocked : BOOLEAN;
      constructor Create;
  end;

implementation

constructor TLabel2.Create;
begin
   m_bLocked := FALSE;
   m_pUpdate := nil;
end;

end.

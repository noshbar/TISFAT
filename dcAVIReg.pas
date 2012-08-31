{*******************************************************}
{                                                       }
{  TDCAVIPlayer Registration Unit                       }
{                                                       }
{  Copyright (c) 1997-1999 Dream Company                }
{  http://www.dream-com.com                             }
{  e-mail: contact@dream-com.com                        }
{                                                       }
{*******************************************************}

unit dcAVIReg;

interface

uses DsgnIntf;

type
  { Property editor for filename property with AVI extension}
  TAVIFileNameEdit = class(TPropertyEditor)
  public
    function  GetAttributes : TPropertyAttributes; override;
    function  GetValue : string; override;
    procedure SetValue(const val : string); override;
    procedure Edit; override;
    function  GetDefaultExtension : string; virtual;
    function  GetFilter : string; virtual;
  end;

procedure Register;

implementation

uses Classes, Dialogs, dcAVI;

const
  SAVIFilesFilter = 'AVI files (*.avi)|*.avi';

function TAVIFileNameEdit.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;

function TAVIFileNameEdit.GetValue : string;
begin
  result := GetStrValue;
end;

procedure TAVIFileNameEdit.SetValue(const val : string);
begin
  SetStrValue(val);
end;

procedure TAVIFileNameEdit.Edit;
begin
  with TOpenDialog.Create(nil) do
    try
      DefaultExt := GetDefaultExtension;
      Filter := GetFilter;
      if Execute then
        SetStrValue(FileName);
    finally
      Free;
    end;
end;

function  TAVIFileNameEdit.GetDefaultExtension : string;
begin
  result := 'avi'; //don't resource
end;

function  TAVIFileNameEdit.GetFilter : string;
begin
  result := SAVIFilesFilter;
end;

procedure Register;
begin
  RegisterComponents('Dream Company',[TDCAVIPlayer]);
  RegisterPropertyEditor(TypeInfo(string), TDCAVIPlayer, 'FileName', TAVIFileNameEdit);//don't resource
end;

end.

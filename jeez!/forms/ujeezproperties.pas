(*

Jeez! - Jesusonic Script Editor

Created by Geep Software

Author:   Derek John Evans (derek.john.evans@hotmail.com)
Website:  http://www.wascal.net/music/

Copyright (C) 2015 Derek John Evans

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*)

unit UJeezProperties;

{$MODE DELPHI}

interface

uses
  ButtonPanel, Classes, ComCtrls, Controls, EditBtn, Forms, JeezLabels, Jes2CppConstants,
  Jes2CppPlatform, Jes2CppStrings, Spin, StdCtrls, SysUtils;

type

  { TJeezProperties }

  TJeezProperties = class(TForm)
    ButtonPanel: TButtonPanel;
    EditUniqueId: TEdit;
    EditPluginInstallPath: TDirectoryEdit;
    EditProductString: TEdit;
    EditEffectName: TEdit;
    EditVendorString: TEdit;
    EditVendorVersion: TSpinEdit;
    PageControl: TPageControl;
    TabSheetSettings: TTabSheet;
    procedure EditPluginInstallPathChange(ASender: TObject);
    procedure FormCreate(ASender: TObject);
    procedure FormShow(ASender: TObject);
  public
    function Execute(const AStrings: TStrings): Boolean;
  end;

var
  JeezProperties: TJeezProperties;

implementation

{$R *.lfm}

uses UJeezOptions;

procedure TJeezProperties.FormCreate(ASender: TObject);
begin
  J2C_ScrollingWinControlPrepare(Self);
  PageControl.PageIndex := 0;
end;

procedure TJeezProperties.FormShow(ASender: TObject);
begin
  J2C_WinControlCreateLabels(Self);
end;

procedure TJeezProperties.EditPluginInstallPathChange(ASender: TObject);
begin
  with ASender as TDirectoryEdit do
  begin
    Directory := IncludeTrailingPathDelimiter(Directory);
  end;
end;

function TJeezProperties.Execute(const AStrings: TStrings): Boolean;
begin
  EditEffectName.Text := J2C_StringsGetValue(AStrings, GsEffectName, 'New Effect');
  EditVendorString.Text := J2C_StringsGetValue(AStrings, GsVendorString, 'Enter Vendor Name');
  EditVendorVersion.Value := StrToIntDef(J2C_StringsGetValue(AStrings, GsVendorVersion, EmptyStr), 1000);
  EditUniqueId.Text := J2C_StringsGetValue(AStrings, GsUniqueId, EmptyStr);
  EditProductString.Text := J2C_StringsGetValue(AStrings, GsProductString, 'Enter Description');
  EditPluginInstallPath.Text := J2C_StringsGetValue(AStrings, GsInstallPath, JeezOptions.EditDefVstPath.Directory, True);
  Result := ShowModal = mrOk;
  if Result then
  begin
    J2C_StringsSetValue(AStrings, GsProductString, EditProductString.Text);
    J2C_StringsSetValue(AStrings, GsEffectName, EditEffectName.Text);
    J2C_StringsSetValue(AStrings, GsVendorString, EditVendorString.Text);
    J2C_StringsSetValue(AStrings, GsVendorVersion, EditVendorVersion.Text);
    J2C_StringsSetValue(AStrings, GsUniqueId, EditUniqueId.Text);
    J2C_StringsSetValue(AStrings, GsInstallPath, EditPluginInstallPath.Text);
  end;
end;

end.

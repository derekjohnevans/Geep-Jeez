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
    EditEffectName: TEdit;
    EditPluginInstallPath: TDirectoryEdit;
    EditProductString: TEdit;
    EditUniqueId: TEdit;
    EditVendorString: TEdit;
    EditVendorVersion: TSpinEdit;
    GroupBoxDescription: TGroupBox;
    GroupBoxInstall: TGroupBox;
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
  GPlatform.ScrollingWinControlPrepare(Self);
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
  EditEffectName.Text := GStrings.GetValue(AStrings, GsEffectName, 'New Effect');
  EditVendorString.Text := GStrings.GetValue(AStrings, GsVendorString, 'Enter Vendor Name');
  EditVendorVersion.Value := StrToIntDef(GStrings.GetValue(AStrings, GsVendorVersion,
    EmptyStr), 1000);
  EditUniqueId.Text := GStrings.GetValue(AStrings, GsUniqueId, EmptyStr);
  EditProductString.Text := GStrings.GetValue(AStrings, GsProductString, 'Enter Description');
  EditPluginInstallPath.Text := GStrings.GetValue(AStrings, GsInstallPath,
    JeezOptions.EditDefVstPath.Directory, True);
  Result := ShowModal = mrOk;
  if Result then
  begin
    GStrings.SetValue(AStrings, GsProductString, EditProductString.Text);
    GStrings.SetValue(AStrings, GsEffectName, EditEffectName.Text);
    GStrings.SetValue(AStrings, GsVendorString, EditVendorString.Text);
    GStrings.SetValue(AStrings, GsVendorVersion, EditVendorVersion.Text);
    GStrings.SetValue(AStrings, GsUniqueId, EditUniqueId.Text);
    GStrings.SetValue(AStrings, GsInstallPath, EditPluginInstallPath.Text);
  end;
end;

end.

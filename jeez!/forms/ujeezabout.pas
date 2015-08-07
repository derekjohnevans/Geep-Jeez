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

unit UJeezAbout;

{$MODE DELPHI}

interface

uses
  ButtonPanel, ComCtrls, Forms, JeezUtils, Jes2CppConstants, Jes2CppFileNames,
  LCLIntf, LCLVersion, SysUtils;

type

  { TJeezAbout }

  TJeezAbout = class(TForm)
    ButtonPanel: TButtonPanel;
    ListView: TListView;
    PageControl: TPageControl;
    TabSheetInfomation: TTabSheet;
    procedure FormCreate(ASender: TObject);
    procedure FormShow(ASender: TObject);
    procedure HelpButtonClick(ASender: TObject);
  private
    procedure AddKey(const AName, AValue: String); overload;
    procedure AddKey(const AName: String; const AValue: Integer); overload;
  public
    procedure Execute;
  end;

var
  JeezAbout: TJeezAbout;

implementation

{$R *.lfm}

procedure TJeezAbout.FormCreate(ASender: TObject);
begin
  Caption := 'About ' + GsJeezName;

  AddKey('Name', GsJeezName);
  AddKey('Version', GsJes2CppVersion);
  AddKey('Description', GsJes2CppSlogan);
  AddKey('Copyright', GsJes2CppCopyright);
  AddKey('Build Date', GsJes2CppBuildDate);
  AddKey('Website', GsJes2CppWebsite);
  AddKey('License', GsJes2CppLicense);
  AddKey('LGPL', 'http://www.gnu.org/licenses/');
  AddKey('LCL Version', lcl_version);
end;

procedure TJeezAbout.FormShow(ASender: TObject);
begin
  ListView.AutoWidthLastColumn := True;
end;

procedure TJeezAbout.HelpButtonClick(ASender: TObject);
begin
  OpenUrl(GUrls.GeepJeez);
end;

procedure TJeezAbout.AddKey(const AName, AValue: String);
begin
  with ListView.Items.Add do
  begin
    Caption := AName;
    SubItems.Add(AValue);
    ImageIndex := 55;
  end;
end;

procedure TJeezAbout.AddKey(const AName: String; const AValue: Integer);
begin
  AddKey(AName, IntToStr(AValue));
end;

procedure TJeezAbout.Execute;
begin
  ShowModal;
end;

end.

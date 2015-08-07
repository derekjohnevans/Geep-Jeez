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

unit UJeezData;

{$MODE DELPHI}

interface

uses
  Classes, Controls, Dialogs, Jes2CppFileNames, StrUtils, SynEditHighlighter,
  SynHighlighterCpp, SysUtils;

const

  // These indexs must match images in ImageList16.
  GiImageIndexFunctionsSystem = 43;
  GiImageIndexFunctionsUser = 44;
  GiImageIndexVariablesSystem = 45;
  GiImageIndexVariablesUser = 46;
  GiImageIndexSliders = 47;
  GiImageIndexSamples = 48;
  GiImageIndexStringTemp = 53;
  GiImageIndexStringNamed = 26;
  GiImageIndexStringLiteral = 52;
  GiImageIndexRefInternal = 37;
  GiImageIndexRefExternal = 39;

  GiImageIndexReference = [GiImageIndexRefInternal, GiImageIndexRefExternal];
  GiImageIndexFunctions = [GiImageIndexFunctionsSystem, GiImageIndexFunctionsUser];

type

  { TJeezData }

  TJeezData = class(TDataModule)
    FontDialog: TFontDialog;
    ImageList32: TImageList;
    ImageListTabSheet: TImageList;
    ImageList16: TImageList;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    SaveDialogHtml: TSaveDialog;
    SynCppSyn: TSynCppSyn;
    procedure DataModuleCreate(ASender: TObject);
  private
  public
    function GetHighlighterFromFileName(const AFileName: TFileName;
      const ADefault: TSynCustomHighlighter): TSynCustomHighlighter;
  end;

var
  JeezData: TJeezData;

implementation

{$R *.lfm}

procedure TJeezData.DataModuleCreate(ASender: TObject);
begin
  SaveDialogHtml.Filter := 'HTML Document (*.htm,*.html)|*.htm;*.html';
  SaveDialogHtml.DefaultExt := GsFileExtHtml;

  OpenDialog.InitialDir := GFilePath.ReaperEffects;
  OpenDialog.Filter := 'Jesusonic Effects (*.*)|*';
  OpenDialog.DefaultExt := GsFileExtJsFx;

  SaveDialog.InitialDir := OpenDialog.InitialDir;
  SaveDialog.Filter := OpenDialog.Filter;
  SaveDialog.DefaultExt := OpenDialog.DefaultExt;
end;

function TJeezData.GetHighlighterFromFileName(const AFileName: TFileName;
  const ADefault: TSynCustomHighlighter): TSynCustomHighlighter;
var
  LIndex: Integer;
  LFileMask, LFileExt: TFileName;
begin
  LFileExt := ExtractFileExt(AFileName);
  if not SameText(LFileExt, GsFileExtH) then
  begin
    LFileMask := AllFilesMask + LFileExt;
    if LFileMask <> AllFilesMask then
    begin
      for LIndex := 0 to ComponentCount - 1 do
      begin
        if Components[LIndex] is TSynCustomHighlighter then
        begin
          Result := TSynCustomHighlighter(Components[LIndex]);
          if AnsiContainsText(Result.DefaultFilter, LFileMask) then
          begin
            Exit;
          end;
        end;
      end;
    end;
  end;
  Result := ADefault;
end;

end.

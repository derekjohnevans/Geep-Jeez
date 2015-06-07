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

unit JeezSynEdit;

{$MODE DELPHI}

interface

uses
  Classes, Jes2CppEel, SynEdit, SynEditHighlighter, SynExportHTML,
  SynHighlighterAny, SysUtils;

type
  TJeezSynEdit = object
  const
{$IF DEFINED(WINDOWS)}
    FontName = 'Courier New';
{$ELSEIF DEFINED(LINUX)}
    FontName = 'Courier';
{$ELSE}
{$ERROR}
{$ENDIF}
  public
    class procedure _SynJsFxInit(const ASynAnySyn: TSynAnySyn);
    class procedure SynEditSectionPrev(const ASynEdit: TSynEdit);
    class procedure SynEditSectionNext(const ASynEdit: TSynEdit);
    class procedure SynCustomHighlighterExport(const AHighlighter: TSynCustomHighlighter; const AStrings: TStrings; const AFileName: TFileName);
  end;

implementation

class procedure TJeezSynEdit._SynJsFxInit(const ASynAnySyn: TSynAnySyn);
var
  LString: String;
begin
  ASynAnySyn.DefaultFilter := 'Jesusonic Scripts (*.*)|*.*';
  for LString in GaEelKeywords do
  begin
    ASynAnySyn.KeyWords.Add(UpperCase(LString));
  end;
  for LString in GaEelSpecial do
  begin
    ASynAnySyn.KeyWords.Add(UpperCase(LString));
  end;
end;

class procedure TJeezSynEdit.SynEditSectionPrev(const ASynEdit: TSynEdit);
var
  LIndex: Integer;
begin
  LIndex := ASynEdit.CaretY;
  repeat
    Dec(LIndex);
    if LIndex < 1 then
    begin
      LIndex := ASynEdit.Lines.Count;
    end;
  until EelIsSection(ASynEdit.Lines[LIndex - 1]) or (LIndex = ASynEdit.CaretY);
  ASynEdit.CaretY := LIndex;
end;

class procedure TJeezSynEdit.SynEditSectionNext(const ASynEdit: TSynEdit);
var
  LIndex: Integer;
begin
  LIndex := ASynEdit.CaretY;
  repeat
    Inc(LIndex);
    if LIndex > ASynEdit.Lines.Count then
    begin
      LIndex := 1;
    end;
  until EelIsSection(ASynEdit.Lines[LIndex - 1]) or (LIndex = ASynEdit.CaretY);
  ASynEdit.CaretY := LIndex;
end;

class procedure TJeezSynEdit.SynCustomHighlighterExport(const AHighlighter: TSynCustomHighlighter; const AStrings: TStrings; const AFileName: TFileName);
const

  LHead = '<!--StartFragment-->';
  LFoot = '<!--EndFragment-->';
var
  LStringStream: TStringStream;
  LPos, LEnd: Integer;
begin
  with  TSynExporterHTML.Create(nil) do
  begin
    try
      Highlighter := AHighlighter;
      ExportAll(AStrings);
      LStringStream := TStringStream.Create(EmptyStr);
      try
        SaveToStream(LStringStream);
        LPos := Pos(LHead, LStringStream.DataString) + Length(LHead);
        LEnd := Pos(LFoot, LStringStream.DataString);
        with TStringList.Create do
        begin
          try
            Text := '<div style="border-style:inset;border-width:2px;background-color:#000000;padding:6px">' +
              Copy(LStringStream.DataString, LPos, LEnd - LPos) + '</div>';
            SaveToFile(AFileName);
          finally
            Free;
          end;
        end;
      finally
        FreeAndNil(LStringStream);
      end;
    finally
      Free;
    end;
  end;
end;

end.

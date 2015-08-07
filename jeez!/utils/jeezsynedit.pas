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
  Classes, Graphics, Jes2CppEel, SynEdit, SynEditHighlighter, SynExportHTML,
  SynHighlighterAny, SysUtils;

type
  GJeezSynEdit = object
  const
{$IF DEFINED(WINDOWS)}
    FontName = 'Courier New';
{$ELSEIF DEFINED(LINUX)}
    FontName = 'Courier';
{$ELSE}
{$ERROR}
{$ENDIF}
  public
    class procedure SetCaretYCentered(const ASynEdit: TSynEdit; const ACaretY: Integer);
    class procedure SectionPrev(const ASynEdit: TSynEdit);
    class procedure SectionNext(const ASynEdit: TSynEdit);
    class procedure ExportHtml(const ASynEdit: TSynEdit; const AStrings: TStrings;
      const AFileName: TFileName);
  end;

  GJeezSynAnySyn = object
    class procedure Setup(const ASynAnySyn: TSynAnySyn);
  end;

  GSynHighlighter = object
    class procedure SetAttribute(const A: TSynHighlighterAttributes; const AForeground: TColor;
      const ABold: Boolean = False);
  end;

implementation

class procedure GSynHighlighter.SetAttribute(const A: TSynHighlighterAttributes;
  const AForeground: TColor; const ABold: Boolean);
begin
  A.Foreground := AForeground;
  if ABold then
  begin
    A.Style := [fsBold];
  end else begin
    A.Style := [];
  end;
end;

class procedure GJeezSynEdit.SetCaretYCentered(const ASynEdit: TSynEdit; const ACaretY: Integer);
begin
  ASynEdit.CaretY := ACaretY - (ASynEdit.LinesInWindow div 2) + 1;
  ASynEdit.CaretY := ACaretY + (ASynEdit.LinesInWindow div 2) - 1;
  ASynEdit.CaretY := ACaretY;
end;

class procedure GJeezSynEdit.SectionPrev(const ASynEdit: TSynEdit);
var
  LCaretY: Integer;
begin
  LCaretY := ASynEdit.CaretY;
  repeat
    Dec(LCaretY);
    if LCaretY < 1 then
    begin
      LCaretY := ASynEdit.Lines.Count;
    end;
  until GEelSectionHeader.IsMaybeSection(ASynEdit.Lines[LCaretY - 1]) or
    (LCaretY = ASynEdit.CaretY);
  SetCaretYCentered(ASynEdit, LCaretY);
end;

class procedure GJeezSynEdit.SectionNext(const ASynEdit: TSynEdit);
var
  LCaretY: Integer;
begin
  LCaretY := ASynEdit.CaretY;
  repeat
    Inc(LCaretY);
    if LCaretY > ASynEdit.Lines.Count then
    begin
      LCaretY := 1;
    end;
  until GEelSectionHeader.IsMaybeSection(ASynEdit.Lines[LCaretY - 1]) or
    (LCaretY = ASynEdit.CaretY);
  SetCaretYCentered(ASynEdit, LCaretY);
end;

class procedure GJeezSynEdit.ExportHtml(const ASynEdit: TSynEdit; const AStrings: TStrings;
  const AFileName: TFileName);
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
      Highlighter := ASynEdit.Highlighter;
      ExportAll(AStrings);
      LStringStream := TStringStream.Create(EmptyStr);
      try
        SaveToStream(LStringStream);
        LPos := Pos(LHead, LStringStream.DataString) + Length(LHead);
        LEnd := Pos(LFoot, LStringStream.DataString);
        with TStringList.Create do
        begin
          try
            Text := '<div style="border-style:inset;border-width:2px;background-color:#' +
              (IntToHex(Red(ASynEdit.Color), 2) + IntToHex(Green(ASynEdit.Color), 2) +
              IntToHex(Blue(ASynEdit.Color), 2)) + ';padding:6px">' +
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

class procedure GJeezSynAnySyn.Setup(const ASynAnySyn: TSynAnySyn);
var
  LKeyword: String;
begin
  ASynAnySyn.DefaultFilter := 'Jesusonic Scripts (*.*)|*.*';
  ASynAnySyn.KeyWords.Clear;
  for LKeyword in GaEelKeywords do
  begin
    ASynAnySyn.KeyWords.Add(UpperCase(LKeyword));
  end;
  for LKeyword in GaEelKeywordsExtra do
  begin
    ASynAnySyn.KeyWords.Add(UpperCase(LKeyword));
  end;
end;

end.

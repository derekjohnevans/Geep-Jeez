(*

Jes2Cpp - Jesusonic Script to C++ Transpiler

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

unit Jes2CppReference;

{$MODE DELPHI}
{$MACRO ON}

interface

uses
  Classes, Jes2CppConstants, Soda, SysUtils;

type

  // TODO: Merge this into the main code.
  TJes2CppFileMarker = object
    FileName: TFileName;
    CaretY: Integer;
  end;

  CJes2CppReferences = class;

  CJes2CppReference = class
    {$DEFINE DItemClass := CJes2CppReference}
    {$DEFINE DItemSuper := CComponent}
    {$DEFINE DItemOwner := CJes2CppReferences}
    {$INCLUDE soda.inc}
  strict private
    FFilePath, FFileName: TFileName;
    FFileCaretY: Integer;
  strict private
    procedure SetFullFileName(const AFileName: TFileName);
    function GetFullFileName: TFileName;
  public
    function EncodeLineFilePath: String;
    function EncodeLineFile: String;
    property FileSource: TFileName read GetFullFileName write SetFullFileName;
    property FileNameOnly: TFileName read FFileName;
    property FileCaretY: Integer read FFileCaretY write FFileCaretY;
  end;

  CJes2CppReferences = class
    {$DEFINE DItemClass := CJes2CppReferences}
    {$DEFINE DItemSuper := CComponent}
    {$DEFINE DItemItems := CJes2CppReference}
    {$INCLUDE soda.inc}
  public
    function CreateReference(const AFileSource: TFileName;
      const AFileCaretY: Integer): CJes2CppReference;
  end;

implementation

{$DEFINE DItemClass := CJes2CppReference} {$INCLUDE soda.inc}

{$DEFINE DItemClass := CJes2CppReferences} {$INCLUDE soda.inc}

procedure CJes2CppReference.SetFullFileName(const AFileName: TFileName);
begin
  FFilePath := ExtractFilePath(AFileName);
  FFileName := ExtractFileName(AFileName);
end;

function CJes2CppReference.GetFullFileName: TFileName;
begin
  Result := FFilePath + FFileName;
end;

function CJes2CppReference.EncodeLineFilePath: String;
begin
  Result := Format('%s=%s %s=%s %s=%s', [GsLine, QuotedStr(IntToStr(FFileCaretY)),
    GsFile, QuotedStr(FFileName), GsPath, QuotedStr(FFilePath)]);
end;

function CJes2CppReference.EncodeLineFile: String;
begin
  Result := Format('%s=%s %s=%s', [GsLine, QuotedStr(IntToStr(FFileCaretY)),
    GsFile, QuotedStr(FFileName)]);
end;

function CJes2CppReferences.CreateReference(const AFileSource: TFileName;
  const AFileCaretY: Integer): CJes2CppReference;
begin
  Result := CreateComponent;
  Result.FileSource := AFileSource;
  Result.FileCaretY := AFileCaretY;
end;

end.

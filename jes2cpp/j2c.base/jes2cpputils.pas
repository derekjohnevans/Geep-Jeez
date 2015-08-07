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

unit Jes2CppUtils;

{$MODE DELPHI}

interface

uses
  Classes, Jes2CppConstants, Jes2CppEel, Jes2CppStrings, Math, StrUtils, SysUtils;

type

  GUtils = object
    class function StripMarkers(const AString: String): String;
    class function CleanComment(const AString: String): String;
    class function ExtractAttribute(const AString, AName: String): String;
    class function ExtractFileSource(const AString: String): TFileName;
    class function ExtractFileCaretY(const AString: String): Integer;
    class procedure ExtractSection(const AName: String; const ADst, ASrc: TStrings;
      const AFileName: TFileName; const AInsertMarkers: Boolean;
      out ASectionHeader: String); overload;
    class function ExtractSection(const AName: String; const ASrc: TStrings;
      const AFileName: TFileName; const AInsertMarker: Boolean;
      out ASectionHeader: String): String; overload;
    class function CodeToInt(const AString: String): Integer;
    class function CodeToIntDef(const AString: String; const ADefault: Integer): Integer;
    class function RPosSetEx(const ACharSet: TSysCharSet; const AString: String;
      const AIndex: Integer): Integer;
  end;

implementation

uses Jes2CppTranslate;

class function GUtils.RPosSetEx(const ACharSet: TSysCharSet; const AString: String;
  const AIndex: Integer): Integer;
begin
  for Result := Min(AIndex, Length(AString)) downto 1 do
  begin
    if AString[Result] in ACharSet then
    begin
      Exit;
    end;
  end;
  Result := 0;
end;

class function GUtils.StripMarkers(const AString: String): String;
var
  LPos, LEnd: Integer;
begin
  Result := AString;
  repeat
    LPos := Pos(GsMarkerHead, Result);
    if LPos = 0 then
    begin
      Break;
    end;
    LEnd := PosEx(GsMarkerFoot, Result, LPos) + Length(GsMarkerFoot);
    Delete(Result, LPos, LEnd - LPos);
  until False;
end;

class function GUtils.CleanComment(const AString: String): String;
begin
  Result := StripMarkers(AString);
  if AnsiStartsStr(GsCppCommentHead, Result) or AnsiStartsStr(GsCppCommentLine, Result) then
  begin
    Result := Copy(Result, Length(GsCppCommentHead) + 1, MaxInt);
  end;
  if AnsiEndsStr(GsCppCommentFoot, Result) then
  begin
    Result := Copy(Result, 1, Length(Result) - Length(GsCppCommentFoot));
  end;
  Result := Trim(Result);
end;

class function GUtils.ExtractAttribute(const AString, AName: String): String;
var
  LPos: Integer;
  LPChar: PChar;
begin
  LPos := Pos(AName + CharEqualSign, AString);
  if LPos = 0 then
  begin
    Abort;
  end else begin
    LPChar := @AString[LPos + Length(AName) + 1];
    Result := AnsiExtractQuotedStr(LPChar, LPChar[0]);
  end;
end;

class function GUtils.ExtractFileSource(const AString: String): TFileName;
begin
  try
    Result := ExtractAttribute(AString, GsPath);
  except
    Result := EmptyStr;
  end;
  Result += ExtractAttribute(AString, GsFile);
end;

class function GUtils.ExtractFileCaretY(const AString: String): Integer;
begin
  Result := StrToInt(ExtractAttribute(AString, GsLine));
end;

class procedure GUtils.ExtractSection(const AName: String; const ADst, ASrc: TStrings;
  const AFileName: TFileName; const AInsertMarkers: Boolean; out ASectionHeader: String);
var
  LIndex: Integer;
  LSrcLine: String;
  LIsRequestedSection: Boolean;
begin
  ASectionHeader := EmptyStr;
  LIsRequestedSection := False;
  if AInsertMarkers then
  begin
    ADst.Add(GsMarkerHeadFile + AFileName + GsMarkerFoot);
  end;
  for LIndex := -1 to ASrc.Count - 1 do
  begin
    if LIndex < 0 then
    begin
      LSrcLine := GEelSectionHeader.Make(GsEelSectionDesc);
    end else begin
      LSrcLine := ASrc[LIndex];
    end;
    if GEelSectionHeader.IsMaybeSection(LSrcLine) then
    begin
      LIsRequestedSection := GEelSectionHeader.IsSectionName(LSrcLine, AName);
      if LIsRequestedSection then
      begin
        ASectionHeader += LSrcLine + LineEnding;
      end;
    end else if LIsRequestedSection then
    begin
      if AInsertMarkers then
      begin
        ADst.Add(GsMarkerHeadLine + IntToStr(LIndex + 1) + GsMarkerFoot + LSrcLine);
      end else begin
        ADst.Add(LSrcLine);
      end;
    end;
  end;
  GStrings.Trim(ADst);
end;

class function GUtils.ExtractSection(const AName: String; const ASrc: TStrings;
  const AFileName: TFileName; const AInsertMarker: Boolean; out ASectionHeader: String): String;
var
  LStrings: TStrings;
begin
  LStrings := TStringList.Create;
  try
    ExtractSection(AName, LStrings, ASrc, AFileName, AInsertMarker, ASectionHeader);
    Result := LStrings.Text;
  finally
    FreeAndNil(LStrings);
  end;
end;

class function GUtils.CodeToInt(const AString: String): Integer;
begin
  if (Length(AString) = 6) and (AString[1] = CharQuoteSingle) and
    (AString[Length(AString)] = CharQuoteSingle) then
  begin
    Exit((Ord(AString[2]) shl 24) or (Ord(AString[3]) shl 16) or (Ord(AString[4]) shl 8) or
      (Ord(AString[5]) shl 0));
  end;
  if (Length(AString) >= 2) and (AString[1] = CharQuoteDouble) and
    (AString[Length(AString)] = CharQuoteDouble) then
  begin
    Exit(HashName(PChar(Copy(AString, 2, Length(AString) - 2))));
  end;
  Result := StrToInt(AString);
end;

class function GUtils.CodeToIntDef(const AString: String; const ADefault: Integer): Integer;
begin
  try
    Result := CodeToInt(AString);
  except
    Result := ADefault;
  end;
end;

end.

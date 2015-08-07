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

unit Jes2CppIdentString;

{$MODE DELPHI}

interface

uses
  Jes2CppConstants, Jes2CppEel, Jes2CppParserSimple, Jes2CppToken, Jes2CppUtils,
  Math, StrUtils, SysUtils;

type

  TIdentString = type string;

  GIdentString = object
    class function Clean(const AIdent: TIdentString): String;
    class function Extract(const AString: String; const APos: Integer;
      out AIdent: TIdentString; out AIsFunction: Boolean): Boolean;
    class function ExtractLastName(const AIdent: TIdentString): TIdentString;
    class function ExtractNameSpace(const AIdent: TIdentString): TIdentString;
    class function FixUp(const AIdent: TFileName): TIdentString;
    class function IsIdent(const AIdent: TIdentString): Boolean;
    class function IsNameSpace(const AIdent, ANameSpace: TIdentString): Boolean; overload;
    class function IsNameSpace(const AIdent: TIdentString): Boolean; overload;
    class function IsNameSpaceThis(const AIdent: TIdentString): Boolean;
    class function IsRef(const AIdent: TIdentString): Boolean;
    class function IsSample(AIdent: TIdentString; out AIndex: Integer): Boolean;
    class function IsSlider(AIdent: TIdentString; out AIndex: Integer): Boolean;
    class function IsStringLiteral(const AIdent: TIdentString): Boolean;
    class function IsStringNamed(const AIdent: TIdentString): Boolean;
    class function IsStringHash(const AIdent: TIdentString): Boolean;
    class function RemoveRef(const AIdent: TIdentString): TIdentString;
  end;

implementation

class function GIdentString.IsNameSpace(const AIdent: TIdentString): Boolean;
begin
  Result := (AIdent <> EmptyStr) and (AIdent[Length(AIdent)] = CharDot);
end;

class function GIdentString.IsNameSpace(const AIdent, ANameSpace: TIdentString): Boolean;
begin
  // TODO: Remove this soon.
  //Assert(IsNameSpace(AIdent), AIdent);
  Result := IsNameSpace(ANameSpace) and AnsiStartsText(ANameSpace, AIdent);
end;

class function GIdentString.IsNameSpaceThis(const AIdent: TIdentString): Boolean;
begin
  Result := IsNameSpace(AIdent, GsEelSpaceThis);
end;

class function GIdentString.IsStringLiteral(const AIdent: TIdentString): Boolean;
begin
  Result := IsNameSpace(AIdent, GsEelSpaceStringLiteral);
end;

class function GIdentString.IsStringHash(const AIdent: TIdentString): Boolean;
begin
  Result := IsNameSpace(AIdent, GsEelSpaceStringHash);
end;

class function GIdentString.IsRef(const AIdent: TIdentString): Boolean;
begin
  Result := (AIdent <> EmptyStr) and (AIdent[Length(AIdent)] = CharAsterisk);
end;

class function GIdentString.IsStringNamed(const AIdent: TIdentString): Boolean;
begin
  Result := (AIdent <> EmptyStr) and (AIdent[1] = CharHash);
end;

class function GIdentString.IsSlider(AIdent: TIdentString; out AIndex: Integer): Boolean;
begin
  AIdent := Clean(AIdent);
  Result := AnsiStartsText(GsEelPreVarSlider, AIdent) and
    TryStrToInt(Copy(AIdent, Length(GsEelPreVarSlider) + 1, MaxInt), AIndex) and
    InRange(AIndex, Low(TEelSliderIndex), High(TEelSliderIndex));
end;

class function GIdentString.IsSample(AIdent: TIdentString; out AIndex: Integer): Boolean;
begin
  AIdent := Clean(AIdent);
  Result := AnsiStartsText(GsEelPreVarSpl, AIdent) and
    TryStrToInt(Copy(AIdent, Length(GsEelPreVarSpl) + 1, MaxInt), AIndex) and
    InRange(AIndex, Low(TEelSampleIndex), High(TEelSampleIndex));
end;

class function GIdentString.IsIdent(const AIdent: TIdentString): Boolean;
var
  LIndex: Integer;
begin
  Result := (Length(AIdent) > 0) and (AIdent[1] in CharSetIdentHead);
  if Result then
  begin
    for LIndex := 2 to Length(AIdent) do
    begin
      if not (AIdent[LIndex] in CharSetIdentBody) then
      begin
        Exit(False);
      end;
    end;
  end;
end;

class function GIdentString.FixUp(const AIdent: TFileName): TIdentString;
var
  LIndex: Integer;
begin
  Result := AIdent;
  if Result = EmptyStr then
  begin
    Result := 'NoName';
  end else begin
    if not (Result[1] in CharSetIdentHead) then
    begin
      Result[1] := '_';
    end;
    for LIndex := 2 to Length(Result) do
    begin
      if not (Result[LIndex] in CharSetIdentBody) then
      begin
        Result[LIndex] := '_';
      end;
    end;
  end;
end;

class function GIdentString.Clean(const AIdent: TIdentString): String;
var
  LLength: Integer;
begin
  Result := AIdent;
  LLength := Length(Result);
  if LLength >= 2 then
  begin
    if (Result <> GsEelVariadic) then
    begin
      if Result[LLength] = CharDot then
      begin
        Delete(Result, LLength, 1);
      end else if (Result[LLength] = CharAsterisk) and (Result[LLength - 1] = CharDot) then
      begin
        Delete(Result, LLength - 1, 1);
      end;
    end;
  end;
end;

class function GIdentString.ExtractLastName(const AIdent: TIdentString): TIdentString;
begin
  Result := Copy(AIdent, RPos(CharDot, AIdent) + 1, MaxInt);
end;

class function GIdentString.ExtractNameSpace(const AIdent: TIdentString): TIdentString;
begin
  Result := Copy(AIdent, 1, RPos(CharDot, AIdent));
end;

class function GIdentString.Extract(const AString: String; const APos: Integer;
  out AIdent: TIdentString; out AIsFunction: Boolean): Boolean;
var
  LPos, LEnd: Integer;
  LParser: TJes2CppParserSimple;
begin
  LPos := GUtils.RPosSetEx(CharSetAll - CharSetIdentFull, AString, APos) + 1;
  LEnd := PosSetEx(CharSetAll - CharSetIdentFull, AString, LPos);
  if LEnd = 0 then
  begin
    LEnd := Length(AString) + 1;
  end;
  AIdent := Trim(Copy(AString, LPos, LEnd - LPos));
  Result := IsIdent(AIdent);
  LParser.SetSource(AString, LEnd);
  AIsFunction := Result and LParser.TryUntil([CharOpeningParenthesis]) and
    IsEmptyStr(LParser.AsString, CharSetWhite);
end;

class function GIdentString.RemoveRef(const AIdent: TIdentString): TIdentString;
begin
  Result := AIdent;
  if IsRef(Result) then
  begin
    Delete(Result, Length(Result), 1);
  end;
end;

end.

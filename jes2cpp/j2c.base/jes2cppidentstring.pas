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
  Jes2CppConstants, Jes2CppEat, Jes2CppEel, Jes2CppToken, Masks, Math, StrUtils, SysUtils;

type

  TIdentString = type string;

  TIdentArray = object
  public
    FItems: array of TIdentString;
  public
    function Count: Integer;
    function IsVariadic: Boolean;
    function IsCountMatch(const ACount: Integer): Boolean;
    function IndexOfMatchesMask(const AIdent: TIdentString): Integer;
    function ExistsMatchesMask(const AIdent: TIdentString): Boolean;
    function IndexOfSameText(const AIdent: TIdentString): Integer;
    function ExistsSameText(const AIdent: TIdentString): Boolean;
    function IndexOfIdent(const AIdent: TIdentString): Integer;
    function ExistsIdent(const AIdent: TIdentString): Boolean;
    procedure Append(const AIdent: TIdentString);
    procedure AppendInstance(const AIdent: TIdentString);
    function IsNameSpaceMatch(const AIdent: TIdentString): Boolean;
    function AsString: String;
  end;

function J2C_IdentIsNameSpace(const AIdent: TIdentString): Boolean; overload;
function J2C_IdentIsNameSpace(const AIdent, ANameSpace: TIdentString): Boolean; overload;

function J2C_IdentIsNameSpaceThis(const AIdent: TIdentString): Boolean;

function J2C_IdentIsNamedString(const AIdent: TIdentString): Boolean;
function J2C_IdentIsConstString(const AIdent: TIdentString): Boolean;
function J2C_IdentIsTempString(const AIdent: TIdentString): Boolean;

function J2C_IdentIsSlider(AIdent: TIdentString; out AIndex: Integer): Boolean;
function J2C_IdentIsSample(AIdent: TIdentString; out AIndex: Integer): Boolean;

function J2C_IdentFixUp(const AIdent: TFileName): TIdentString;
function J2C_IdentClean(const AIdent: TIdentString): String;
function J2C_IdentExtractRight(const AIdent: TIdentString): TIdentString;
function J2C_IdentExtract(const AString: String; const APos: Integer; out AIdent: TIdentString; out AIsFunction: Boolean): Boolean;

implementation

uses Jes2CppStrings;

function J2C_IdentIsNameSpace(const AIdent: TIdentString): Boolean;
begin
  Result := (AIdent <> EmptyStr) and (AIdent[Length(AIdent)] = CharDot);
end;

function J2C_IdentIsNameSpace(const AIdent, ANameSpace: TIdentString): Boolean;
begin
  // TODO: Remove this soon.
  Assert(J2C_IdentIsNameSpace(AIdent) and J2C_IdentIsNameSpace(ANameSpace), AIdent + ' ' + ANameSpace);
  Result := AnsiStartsText(ANameSpace, AIdent);
end;

function J2C_IdentIsNameSpaceThis(const AIdent: TIdentString): Boolean;
begin
  Result := J2C_IdentIsNameSpace(AIdent, GsEelSpaceThis);
end;

function J2C_IdentIsConstString(const AIdent: TIdentString): Boolean;
begin
  Result := J2C_IdentIsNameSpace(AIdent, GsEelSpaceConstString);
end;

function J2C_IdentIsTempString(const AIdent: TIdentString): Boolean;
begin
  Result := J2C_IdentIsNameSpace(AIdent, GsEelSpaceTempString);
end;

function J2C_IdentIsRef(const AIdent: TIdentString): Boolean;
begin
  Result := (AIdent <> EmptyStr) and (AIdent[Length(AIdent)] = CharAsterisk);
end;

function J2C_IdentIsNamedString(const AIdent: TIdentString): Boolean;
begin
  Result := (AIdent <> EmptyStr) and (AIdent[1] = CharHash);
end;

function J2C_IdentIsSlider(AIdent: TIdentString; out AIndex: Integer): Boolean;
begin
  AIdent := J2C_IdentClean(AIdent);
  Result := AnsiStartsText(GsEelPreVarSlider, AIdent) and TryStrToInt(Copy(AIdent, Length(GsEelPreVarSlider) + 1, MaxInt), AIndex) and
    InRange(AIndex, Low(TEelSliderIndex), High(TEelSliderIndex));
end;

function J2C_IdentIsSample(AIdent: TIdentString; out AIndex: Integer): Boolean;
begin
  AIdent := J2C_IdentClean(AIdent);
  Result := AnsiStartsText(GsEelPreVarSpl, AIdent) and TryStrToInt(Copy(AIdent, Length(GsEelPreVarSpl) + 1, MaxInt), AIndex) and
    InRange(AIndex, Low(TEelSampleIndex), High(TEelSampleIndex));
end;

function J2C_IsIdent(const AIdent: TIdentString): Boolean;
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

function J2C_RPosSetEx(const ACharSet: TSysCharSet; const AString: TIdentString; const AIndex: Integer): Integer;
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

function J2C_IdentFixUp(const AIdent: TFileName): TIdentString;
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

function J2C_IdentClean(const AIdent: TIdentString): String;
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

function J2C_IdentExtractRight(const AIdent: TIdentString): TIdentString;
begin
  Result := Copy(AIdent, RPos(CharDot, AIdent) + 1, MaxInt);
end;

function J2C_IdentExtract(const AString: String; const APos: Integer; out AIdent: TIdentString; out AIsFunction: Boolean): Boolean;
var
  LPos, LEnd: Integer;
  LEmptyStr: TIdentString;
begin
  LPos := J2C_RPosSetEx(CharSetAll - CharSetIdentFull, AString, APos) + 1;
  LEnd := PosSetEx(CharSetAll - CharSetIdentFull, AString, LPos);
  if LEnd = 0 then
  begin
    LEnd := Length(AString) + 1;
  end;
  AIdent := Trim(Copy(AString, LPos, LEnd - LPos));
  Result := J2C_IsIdent(AIdent);
  AIsFunction := Result and (EatUntil(AString, LEnd, LEmptyStr, ['(']) = '(') and IsEmptyStr(LEmptyStr, CharSetWhite);
end;

function J2C_IdentRemoveRef(const AIdent: TIdentString): TIdentString;
begin
  Result := AIdent;
  if J2C_IdentIsRef(Result) then
  begin
    Delete(Result, Length(Result), 1);
  end;
end;

function TIdentArray.Count: Integer;
begin
  Result := Length(FItems);
end;

function TIdentArray.IsVariadic: Boolean;
begin
  Result := (Length(FItems) > 0) and (FItems[High(FItems)] = GsEelVariadic);
end;

function TIdentArray.IsCountMatch(const ACount: Integer): Boolean;
begin
  Result := (IsVariadic and (ACount >= High(FItems))) or (ACount = Length(FItems));
end;

function TIdentArray.IndexOfMatchesMask(const AIdent: TIdentString): Integer;
begin
  for Result := Low(FItems) to High(FItems) do
  begin
    if MatchesMask(AIdent, FItems[Result]) then
    begin
      Exit;
    end;
  end;
  Result := -1;
end;

function TIdentArray.ExistsMatchesMask(const AIdent: TIdentString): Boolean;
begin
  Result := IndexOfMatchesMask(AIdent) >= 0;
end;

function TIdentArray.IndexOfSameText(const AIdent: TIdentString): Integer;
begin
  for Result := Low(FItems) to High(FItems) do
  begin
    if SameText(AIdent, FItems[Result]) then
    begin
      Exit;
    end;
  end;
  Result := -1;
end;

function TIdentArray.ExistsSameText(const AIdent: TIdentString): Boolean;
begin
  Result := IndexOfSameText(AIdent) >= 0;
end;

function TIdentArray.IndexOfIdent(const AIdent: TIdentString): Integer;
begin
  for Result := Low(FItems) to High(FItems) do
  begin
    if SameText(J2C_IdentRemoveRef(AIdent), J2C_IdentRemoveRef(FItems[Result])) then
    begin
      Exit;
    end;
  end;
  Result := -1;
end;

function TIdentArray.ExistsIdent(const AIdent: TIdentString): Boolean;
begin
  Result := IndexOfIdent(AIdent) >= 0;
end;

procedure TIdentArray.Append(const AIdent: TIdentString);
begin
  SetLength(FItems, Length(FItems) + 1);
  FItems[High(FItems)] := AIdent;
end;

procedure TIdentArray.AppendInstance(const AIdent: TIdentString);
begin
  if not ExistsIdent(AIdent) then
  begin
    Append(AIdent);
  end;
end;

function TIdentArray.IsNameSpaceMatch(const AIdent: TIdentString): Boolean;
var
  LNameSpace: TIdentString;
begin
  for LNameSpace in FItems do
  begin
    if J2C_IdentIsNameSpace(AIdent, LNameSpace) then
    begin
      Exit(True);
    end;
  end;
  Result := False;
end;

function TIdentArray.AsString: String;
var
  LIdent: TIdentString;
begin
  Result := EmptyStr;
  for LIdent in FItems do
  begin
    J2C_StringAppendCSV(Result, LIdent);
  end;
end;

end.

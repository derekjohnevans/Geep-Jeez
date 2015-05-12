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
  Classes, Jes2CppConstants, Jes2CppEel, Jes2CppPlatform, StrUtils, SysUtils, Types;

function StringDynArrayJoin(const AArray: TStringDynArray; const ASeperator: String): String;

function Jes2CppGetValue(const AStrings: TStrings; const AName, AValue: String; const ADecodeMeta: Boolean = False): String;
procedure Jes2CppSetValue(const AStrings: TStrings; const AName, AValue: String);

function Jes2CppExtractAttribute(const AString, AName: String): String;

function Jes2CppExtractSection(const AName: String; const ADst, ASrc: TStrings; const AFileName: TFileName;
  const AInsertMarkers: Boolean; out ASectionHeader: String): Integer; overload;
function Jes2CppExtractSection(const AName: String; const ASrc: TStrings; const AFileName: TFileName;
  const AInsertMarker: Boolean; out ASectionHeader: String): String;
  overload;

procedure ImportModule(const ADst, ASrc: TStrings; const ASectionName, AFileName: String; const AInstances: TComponent);

function Jes2CppStrToIntDef(const AString: String; const ADefault: Integer): Integer;

function Count(const AStrings: TStrings): Integer; overload;
function Count(const AComponent: TComponent): Integer; overload;
function First(const AStrings: TStrings): Integer; overload;
function First(const AComponent: TComponent): Integer; overload;
function Last(const AStrings: TStrings): Integer; overload;
function Last(const AComponent: TComponent): Integer; overload;

implementation

function Count(const AStrings: TStrings): Integer;
begin
  Assert(Assigned(AStrings));
  Result := AStrings.Count;
end;

function Count(const AComponent: TComponent): Integer;
begin
  Assert(Assigned(AComponent));
  Result := AComponent.ComponentCount;
end;

function First(const AStrings: TStrings): Integer;
begin
  Assert(Assigned(AStrings));
  Result := M_ZERO;
end;

function First(const AComponent: TComponent): Integer;
begin
  Assert(Assigned(AComponent));
  Result := M_ZERO;
end;

function Last(const AStrings: TStrings): Integer;
begin
  Assert(Assigned(AStrings));
  Result := AStrings.Count - 1;
end;

function Last(const AComponent: TComponent): Integer;
begin
  Assert(Assigned(AComponent));
  Result := AComponent.ComponentCount - 1;
end;

function StringDynArrayJoin(const AArray: TStringDynArray; const ASeperator: String): String;
var
  LIndex: Integer;
begin
  Result := EmptyStr;
  for LIndex := Low(AArray) to High(AArray) do
  begin
    if Result <> EmptyStr then
    begin
      Result += ASeperator;
    end;
    Result += AArray[LIndex];
  end;
end;

function DecodeNameValue(AString: String; out AName, AValue: String): Boolean;
var
  LPos: Integer;
begin
  AString := Trim(AString);
  Result := AnsiStartsStr('//', AString);
  if Result then
  begin
    LPos := PosSet([':', CharEqu], AString);
    Result := LPos > 0;
    if Result then
    begin
      AName := Trim(Copy(AString, 3, LPos - 3));
      AValue := Trim(Copy(AString, LPos + 1, MaxInt));
    end;
  end else begin
    LPos := Pos(':', AString);
    Result := LPos > 0;
    if Result then
    begin
      AName := Trim(Copy(AString, 1, LPos - 1));
      AValue := Trim(Copy(AString, LPos + 1, MaxInt));
      if SameText(AName, SEelDescDesc) then
      begin
        AName := SProductString;
      end;
    end;
  end;
end;

function EncodeNameValue(const AName, AValue: String): String;
begin
  if SameText(AName, SProductString) then
  begin
    Result := SEelDescDesc + ': ' + Trim(AValue);
  end else begin
    Result := SCppCommentSpace + Trim(AName) + CharEqu + Trim(AValue);
  end;
end;

function Jes2CppGetValue(const AStrings: TStrings; const AName, AValue: String; const ADecodeMeta: Boolean): String;
var
  LIndex: Integer;
  LName, LValue: String;
begin
  Result := AValue;
  for LIndex := 0 to AStrings.Count - 1 do
  begin
    if EelIsSection(AStrings[LIndex]) then
    begin
      Break;
    end;
    if DecodeNameValue(AStrings[LIndex], LName, LValue) and SameText(LName, AName) and (Length(LValue) > 0) then
    begin
      Result := LValue;
      Break;
    end;
  end;
  if ADecodeMeta then
  begin
    Result := DecodeMeta(Result);
  end;
end;

procedure Jes2CppSetValue(const AStrings: TStrings; const AName, AValue: String);
var
  LIndex: Integer;
  LName, LValue: String;
begin
  for LIndex := 0 to AStrings.Count - 1 do
  begin
    if EelIsSection(AStrings[LIndex]) then
    begin
      Break;
    end;
    if DecodeNameValue(AStrings[LIndex], LName, LValue) and SameText(LName, AName) then
    begin
      AStrings[LIndex] := EncodeNameValue(AName, AValue);
      Exit;
    end;
  end;
  AStrings.Insert(LIndex, EncodeNameValue(AName, AValue));
end;

function Jes2CppExtractAttribute(const AString, AName: String): String;
var
  LPos: Integer;
begin
  LPos := Pos(AName + '="', AString);
  if LPos = 0 then
  begin
    Abort;
  end else begin
    Inc(LPos, Length(AName) + 2);
    Result := Copy(AString, LPos, PosEx(CharQuoteDouble, AString, LPos) - LPos);
  end;
end;

function Jes2CppExtractSection(const AName: String; const ADst, ASrc: TStrings; const AFileName: TFileName;
  const AInsertMarkers: Boolean; out ASectionHeader: String): Integer;
var
  LIndex: Integer;
  LSrcLine: String;
  LIsRequestedSection: Boolean;
begin
  Result := 0;
  ASectionHeader := EmptyStr;
  LIsRequestedSection := False;
  if AInsertMarkers then
  begin
    ADst.Add(SFileMarkerHead + AFileName + SFileMarkerFoot);
  end;
  for LIndex := -1 to ASrc.Count - 1 do
  begin
    if LIndex < 0 then
    begin
      LSrcLine := EelSection(SEelSectionDesc);
    end else begin
      LSrcLine := ASrc[LIndex];
    end;
    if EelIsSection(LSrcLine) then
    begin
      LIsRequestedSection := EelIsSection(LSrcLine, AName);
      if LIsRequestedSection then
      begin
        ASectionHeader += LSrcLine + LineEnding;
      end;
    end else if LIsRequestedSection then
    begin
      Inc(Result);
      if AInsertMarkers then
      begin
        ADst.Add(SLineMarkerHead + IntToStr(LIndex + 1) + SLineMarkerFoot + LSrcLine);
      end else begin
        ADst.Add(LSrcLine);
      end;
    end;
  end;
end;

function Jes2CppExtractSection(const AName: String; const ASrc: TStrings; const AFileName: TFileName;
  const AInsertMarker: Boolean; out ASectionHeader: String): String;
var
  LStrings: TStrings;
begin
  LStrings := TStringList.Create;
  try
    Jes2CppExtractSection(AName, LStrings, ASrc, AFileName, AInsertMarker, ASectionHeader);
    Result := LStrings.Text;
  finally
    FreeAndNil(LStrings);
  end;
end;

procedure StringsIndent(const AStrings: TStrings; const ALow, AHigh, AIndent: Integer);
var
  LIndex: Integer;
begin
  for LIndex := ALow to AHigh do
  begin
    AStrings[LIndex] := StringOfChar(' ', AIndent) + AStrings[LIndex];
  end;
end;

procedure ImportModule(const ADst, ASrc: TStrings; const ASectionName, AFileName: String; const AInstances: TComponent);
var
  LIndex: Integer;
  LString, LSectionHeader: String;
begin
  LString := 'instance(';
  for LIndex := First(AInstances) to Last(AInstances) do
  begin
    if LIndex > 0 then
    begin
      LString += SCppCommaSpace;
    end;
    LString += AInstances.Components[LIndex].Name;
  end;
  LString += ')';
  ADst.Add('function ' + ASectionName + '() ' + LString);
  ADst.Add('(');
  LIndex := ADst.Count;
  Jes2CppExtractSection(ASectionName, ADst, ASrc, AFileName, False, LSectionHeader);
  StringsIndent(ADst, LIndex, ADst.Count - 1, 2);
  ADst.Add(');');
end;

function Jes2CppStrToInt(const AString: String): Integer;
begin
  if (Length(AString) = 6) and (AString[1] = CharQuoteSingle) and (AString[Length(AString)] = CharQuoteSingle) then
  begin
    Exit((Ord(AString[2]) shl 24) or (Ord(AString[3]) shl 16) or (Ord(AString[4]) shl 8) or (Ord(AString[5]) shl 0));
  end;
  if (Length(AString) >= 2) and (AString[1] = CharQuoteDouble) and (AString[Length(AString)] = CharQuoteDouble) then
  begin
    Exit(HashName(PChar(Copy(AString, 2, Length(AString) - 2))));
  end;
  Result := StrToInt(AString);
end;

function Jes2CppStrToIntDef(const AString: String; const ADefault: Integer): Integer;
begin
  try
    Result := Jes2CppStrToInt(AString);
  except
    Result := ADefault;
  end;
end;

end.

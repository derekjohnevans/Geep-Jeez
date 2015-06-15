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

unit Jes2CppStrings;

{$MODE DELPHI}

interface

uses
  Classes, Jes2CppConstants, Jes2CppEel, Jes2CppFileNames, Jes2CppTranslate, StrUtils, SysUtils;

type

  TArrayOfString = object
  public
    Items: array of String;
  public
    function Count: Integer;
    procedure Append(const AIdent: String);
  end;

function J2C_StringLine(const ALength: Integer = GiColWidth): String;
function J2C_StringIsSpace(const AString: String): Boolean;
procedure J2C_StringAppendCSV(var AString: String; const AValue: String);
function J2C_DecodeNameValue(AString: String; out AName, AValue: String): Boolean;
function J2C_StringSplit(const AString: String; const ACharSet: TSysCharSet; out ALeft, ARight: String): Boolean;

function J2C_StringsGetValue(const AStrings: TStrings; const AName, AValue: String; const ADecodeMeta: Boolean = False): String;
function J2C_StringsIndexOfName(const AStrings: TStrings; const AName: String): Integer;
procedure J2C_StringsAddComment(const AStrings: TStrings; const AString: String);
procedure J2C_StringsAddCommentLine(const AStrings: TStrings);
procedure J2C_StringsAddCommentTitle(const AStrings: TStrings; const AString: String);
procedure J2C_StringsSetValue(const AStrings: TStrings; const AName, AValue: String);
procedure J2C_StringsTrim(const AStrings: TStrings);

implementation

function TArrayOfString.Count: Integer;
begin
  Result := Length(Items);
end;

procedure TArrayOfString.Append(const AIdent: String);
begin
  SetLength(Items, Length(Items) + 1);
  Items[High(Items)] := AIdent;
end;

function J2C_StringIsSpace(const AString: String): Boolean;
var
  LIndex: Integer;
begin
  for LIndex := 1 to Length(AString) do
  begin
    if AString[LIndex] <> CharSpace then
    begin
      Exit(False);
    end;
  end;
  Result := True;
end;

procedure J2C_StringAppendCSV(var AString: String; const AValue: String);
begin
  if not J2C_StringIsSpace(AString) then
  begin
    AString += GsCppCommaSpace;
  end;
  AString += AValue;
end;

function J2C_StringSplit(const AString: String; const ACharSet: TSysCharSet; out ALeft, ARight: String): Boolean;
var
  LPos: Integer;
begin
  LPos := PosSet(ACharSet, AString);
  Result := LPos > 0;
  if Result then
  begin
    ARight := AString;
    ALeft := Trim(Copy(ARight, 1, LPos - 1));
    ARight := Trim(Copy(ARight, LPos + 1, MaxInt));
  end;
end;

function J2C_EncodeNameValue(AName, AValue: String): String;
begin
  if SameText(AName, GsProductString) then
  begin
    AName := GsEelDescDesc;
  end;
  Result := Trim(AName) + ': ' + Trim(AValue);
end;

function J2C_DecodeNameValue(AString: String; out AName, AValue: String): Boolean;
begin
  AString := Trim(AString);
  if AnsiStartsStr(GsCppCommentLine, AString) then
  begin
    AString := Trim(Copy(AString, Length(GsCppCommentLine) + 1, MaxInt));
  end;
  Result := J2C_StringSplit(AString, [CharColon, CharEqualSign], AName, AValue);
  if Result then
  begin
    if SameText(AName, GsEelDescDesc) then
    begin
      AName := GsProductString;
    end else if SameText(AName, GsVstPath) then
    begin
      AName := GsInstallPath;
    end;
  end;
end;

function J2C_StringsIndexOfName(const AStrings: TStrings; const AName: String): Integer;
var
  LName, LValue: String;
begin
  for Result := 0 to EelDescHigh(AStrings) do
  begin
    if J2C_DecodeNameValue(AStrings[Result], LName, LValue) and SameText(LName, AName) then
    begin
      Exit;
    end;
  end;
  Result := -1;
end;

function J2C_StringsGetValue(const AStrings: TStrings; const AName, AValue: String; const ADecodeMeta: Boolean): String;
var
  LIndex: Integer;
  LName, LValue: String;
begin
  Result := AValue;
  for LIndex := 0 to EelDescHigh(AStrings) do
  begin
    if J2C_DecodeNameValue(AStrings[LIndex], LName, LValue) and SameText(LName, AName) and (Length(LValue) > 0) then
    begin
      Result := LValue;
      Break;
    end;
  end;
  if ADecodeMeta then
  begin
    Result := TJes2CppFileNames.DecodeMeta(Result);
  end;
end;

procedure J2C_StringsSetValue(const AStrings: TStrings; const AName, AValue: String);
var
  LIndex: Integer;
  LName, LValue: String;
begin
  for LIndex := 0 to EelDescHigh(AStrings) do
  begin
    if J2C_DecodeNameValue(AStrings[LIndex], LName, LValue) and SameText(LName, AName) then
    begin
      AStrings[LIndex] := J2C_EncodeNameValue(AName, AValue);
      Exit;
    end;
  end;
  AStrings.Insert(LIndex + 1, J2C_EncodeNameValue(AName, AValue));
end;

procedure J2C_StringsAddComment(const AStrings: TStrings; const AString: String);
var
  LIndex: Integer;
begin
  with TStringList.Create do
  begin
    try
      Text := WrapText(AString, GiColWidth);
      for LIndex := 0 to Count - 1 do
      begin
        AStrings.Add(GsCppCommentSpace + Strings[LIndex]);
      end;
    finally
      Free;
    end;
  end;
end;

function J2C_StringLine(const ALength: Integer): String;
begin
  Result := StringOfChar(CharEqualSign, ALength);
end;

procedure J2C_StringsAddCommentLine(const AStrings: TStrings);
begin
  J2C_StringsAddComment(AStrings, J2C_StringLine);
end;

procedure J2C_StringsAddCommentTitle(const AStrings: TStrings; const AString: String);
begin
  J2C_StringsAddCommentLine(AStrings);
  J2C_StringsAddComment(AStrings, AString);
  J2C_StringsAddCommentLine(AStrings);
end;

procedure J2C_StringsTrim(const AStrings: TStrings);
begin
  while (AStrings.Count > 0) and J2C_StringIsSpace(AStrings[AStrings.Count - 1]) do
  begin
    AStrings.Delete(AStrings.Count - 1);
  end;
  while (AStrings.Count > 0) and J2C_StringIsSpace(AStrings[0]) do
  begin
    AStrings.Delete(0);
  end;
end;

end.

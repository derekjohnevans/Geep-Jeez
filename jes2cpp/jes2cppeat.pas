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

unit Jes2CppEat;

{$MODE DELPHI}

interface

uses
  Jes2CppEel, StrUtils, SysUtils;

function Eat(const AString: String; var APos: Integer; out AResult: String; const ACharSet: TSysCharSet; const ATrim: Boolean = True): Char;
  overload;
function Eat(const AString: String; var APos: Integer; out AResult: Extended; const ACharSet: TSysCharSet;
  const ADefault: Extended; const ATrim: Boolean = True): Char; overload;

implementation

function Eat(const AString: String; var APos: Integer; out AResult: String; const ACharSet: TSysCharSet; const ATrim: Boolean = True): Char;
var
  LEnd: Integer;
begin
  Result := #0;
  LEnd := PosSetEx(ACharSet, AString, APos);
  if LEnd > 0 then
  begin
    Result := AString[LEnd];
  end else if #0 in ACharSet then
  begin
    LEnd := Length(AString) + 1;
  end;
  if LEnd > 0 then
  begin
    AResult := Copy(AString, APos, LEnd - APos);
    if ATrim then
    begin
      AResult := Trim(AResult);
    end;
    APos := LEnd + 1;
  end;
end;

function Eat(const AString: String; var APos: Integer; out AResult: Extended; const ACharSet: TSysCharSet;
  const ADefault: Extended; const ATrim: Boolean): Char;
var
  LPos: Integer;
  LStr: String;
begin
  LPos := APos;
  Result := Eat(AString, APos, LStr, ACharSet, ATrim);
  if Result in ACharSet then
  begin
    AResult := EelStrToFloatDef(LStr, ADefault);
  end else begin
    APos := LPos;
  end;
end;

end.

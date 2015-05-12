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

unit Jes2CppTranslate;

{$MODE DELPHI}

interface

uses
  Jes2CppConstants, Jes2CppEel, Jes2CppVarArray, StrUtils, SysUtils;

type

  TVarableType = (vtGlobal, vtParameter, vtLocal, vtInstance, vtUnknown);

function CppString(const AValue: String): String;

function EelToCppFloat(const AValue: Extended): String; overload;
function EelToCppFloat(const AValue: String): String; overload;
function EelToCppVar(const AString: String; const AType: TVarableType): String;
function EelToCppFun(const AString: String): String;

function CppToEelVar(const AString: String; out AResult: String): Boolean;
function CppIsHashString(const AString: String): Boolean;

implementation

function CppString(const AValue: String): String;
begin
  Result := AValue;
  Result := ReplaceStr(Result, '\', '\\');
  Result := ReplaceStr(Result, '"', '\"');
  Result := '"' + Result + '"';
end;

function EelToCppFloat(const AValue: Extended): String;
begin
  Result := '(' + SEelReal + ')(' + EelFloatToStr(AValue) + ')';
end;

function EelToCppFloat(const AValue: String): String;
begin
  if SameText(AValue, SEelVarPi) then
  begin
    Result := SM_PI;
  end else if AnsiStartsStr('$x', AValue) or AnsiStartsStr('0x', AValue) then
  begin
    Result := EelToCppFloat(StrToInt('$' + Copy(AValue, 3, MaxInt)));
  end else if (Length(AValue) = 4) and (AValue[1] = '$') and (AValue[2] = '''') and (AValue[4] = '''') then
  begin
    Result := EelToCppFloat(Ord(AValue[3]));
  end else begin
    Result := EelToCppFloat(EelStrToFloat(AValue));
  end;
end;

function CppToEel(const AString: String): String;
begin
  Result := ReplaceStr(ReplaceStr(AString, SEelCppDot, CharDot), SEelCppHash, CharHash);
end;

function EelToCpp(const AString: String): String;
begin
  Result := ReplaceStr(ReplaceStr(LowerCase(AString), CharDot, SEelCppDot), CharHash, SEelCppHash);
end;

function EelToCppVar(const AString: String; const AType: TVarableType): String;
begin
  if VarNameIsRef(AString) then
  begin
    Result := '&VAR(' + EelToCpp(VarNameDeRef(AString)) + ')';
  end else begin
    Result := 'VAR(' + EelToCpp(AString) + ')';
  end;
end;

function CppToEelVar(const AString: String; out AResult: String): Boolean;
begin
  Result := AnsiStartsStr('VAR(', AString) and AnsiEndsStr(')', AString) and (Pos(CharSpace, AString) = 0);
  if Result then
  begin
    AResult := CppToEel(Copy(AString, 5, Length(AString) - 6));
  end;
end;

function CppIsHashString(const AString: String): Boolean;
var
  LString: String;
begin
  Result := CppToEelVar(AString, LString) and AnsiStartsStr(SEelVarHash, LString);
end;

function EelToCppFun(const AString: String): String;
begin
  Result := 'FUN(' + EelToCpp(AString) + ')';
end;

end.

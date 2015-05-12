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

unit Jes2CppVarArray;

{$MODE OBJFPC}{$H+}

interface

uses
  Jes2CppConstants, Jes2CppEel, StrUtils, SysUtils;

function VarNameIsRef(const AName: String): Boolean;
function VarNameDeRef(const AName: String): String;

type

  TVariableArray = object
  public
    FItems: array of String;
  public
    function Count: Integer;
    function VirtualCount: Integer;
    function IndexOf(const AName: String): Integer;
    function Exists(const AName: String): Boolean;
    procedure Append(const AString: String; const AIgnoreDuplicates: Boolean);
    function IsNameSpaceMatch(const AName: String): Boolean;
  end;


implementation


function VarNameIsRef(const AName: String): Boolean;
begin
  Result := AnsiEndsStr(CharAsterisk, AName);
end;

function VarNameDeRef(const AName: String): String;
begin
  Result := AName;
  if VarNameIsRef(Result) then
  begin
    Result := Copy(Result, 1, Length(Result) - 1);
  end;
end;

function TVariableArray.Count: Integer;
begin
  Result := Length(FItems);
end;

function TVariableArray.VirtualCount: Integer;
begin
  Result := Length(FItems);
  if (Result > 0) and (FItems[High(FItems)] = SEelVariadic) then
  begin
    Result := 30;
  end;
end;

function TVariableArray.IndexOf(const AName: String): Integer;
begin
  for Result := Low(FItems) to High(FItems) do
  begin
    if SameText(AName, VarNameDeRef(FItems[Result])) then
    begin
      Exit;
    end;
  end;
  Result := -1;
end;

function TVariableArray.Exists(const AName: String): Boolean;
begin
  Result := IndexOf(AName) >= 0;
end;

procedure TVariableArray.Append(const AString: String; const AIgnoreDuplicates: Boolean);
begin
  if not (AIgnoreDuplicates and Exists(AString)) then
  begin
    SetLength(FItems, Length(FItems) + 1);
    FItems[High(FItems)] := AString;
  end;
end;

// TODO: CHECK THIS and document it
function _IsNameSpaceMatch(const ANameSpace, AName: String): Boolean;
begin
  if AnsiEndsStr(CharDot, ANameSpace) then
  begin
    Result := AnsiStartsText(ANameSpace, AName + CharDot);
  end else begin
    Result := AnsiStartsText(ANameSpace + CharDot, AName + CharDot);
  end;
end;

function TVariableArray.IsNameSpaceMatch(const AName: String): Boolean;
var
  LNameSpace: String;
begin
  Result := False;
  for LNameSpace in FItems do
  begin
    if _IsNameSpaceMatch(LNameSpace, AName) then
    begin
      Exit(True);
    end;
  end;
end;

end.

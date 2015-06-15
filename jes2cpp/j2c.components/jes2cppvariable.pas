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

unit Jes2CppVariable;

{$MODE DELPHI}

interface

uses
  Classes, Jes2CppConstants, Jes2CppEel, Jes2CppIdentifier, Jes2CppIterate, Jes2CppStrings, Jes2CppTranslate, SysUtils;

type

  CJes2CppVariable = class(CJes2CppIdentifier)
  public
    FConstantString: String;
  end;

  CJes2CppVariables = class(CJes2CppIdentifiers)
  strict private
    function AddVariable(const AName: String; const AIdentType: TJes2CppIdentifierType): CJes2CppVariable;
  public
    function FindVariable(const AName: TComponentName): CJes2CppVariable;
    function FindOrCreateVariable(const AName: TComponentName; const AFileName: TFileName; const AFileLine: Integer;
      const AComment: String): CJes2CppVariable;
    function GetVariable(const AIndex: Integer): CJes2CppVariable;
    function CppDefineVariables: String;
    function CppClear: String;
    function CppSetStringConstants: String;
  end;

implementation


function CJes2CppVariables.GetVariable(const AIndex: Integer): CJes2CppVariable;
begin
  Result := Self[AIndex] as CJes2CppVariable;
end;

function CJes2CppVariables.FindVariable(const AName: TComponentName): CJes2CppVariable;
begin
  Result := FindBySameText(AName) as CJes2CppVariable;
end;

function CJes2CppVariables.FindOrCreateVariable(const AName: TComponentName; const AFileName: TFileName;
  const AFileLine: Integer; const AComment: String): CJes2CppVariable;
begin
  Result := FindVariable(AName);
  if not Assigned(Result) then
  begin
    Result := CJes2CppVariable.Create(Self, AName);
    Result.Comment := AComment;
  end;
  Result.References.AddReference(AFileName, AFileLine);
end;

function CJes2CppVariables.AddVariable(const AName: String; const AIdentType: TJes2CppIdentifierType): CJes2CppVariable;
begin
  if Assigned(FindBySameText(AName)) then
  begin
    raise Exception.Create('Duplicate Variable');
  end;
  Result := CJes2CppVariable.Create(Self, AName);
  Result.IdentType := AIdentType;
end;

function CJes2CppVariables.CppDefineVariables: String;
var
  LIndex: Integer;
begin
  Result := EmptyStr;
  for LIndex := IndexFirst(Self) to IndexLast(Self) do
  begin
    if GetIdentifier(LIndex).IdentType = itInternal then
    begin
      J2C_StringAppendCSV(Result, CppEncodeVariable(Self[LIndex].Name));
    end;
  end;
  if Result <> EmptyStr then
  begin
    Result := GsCppEelF + CharSpace + Result + GsCppLineEnding;
  end;
end;

function CJes2CppVariables.CppClear: String;
var
  LIndex: Integer;
  LVariable: CJes2CppVariable;
begin
  Result := EmptyStr;
  for LIndex := IndexFirst(Self) to IndexLast(Self) do
  begin
    LVariable := GetVariable(LIndex);
    if LVariable.IdentType = itInternal then
    begin
      Result += CppEncodeVariable(LVariable.Name) + GsCppEqu + GsCppZero + GsCppLineEnding;
    end;
  end;
end;

function CJes2CppVariables.CppSetStringConstants: String;
var
  LIndex: Integer;
  LVariable: CJes2CppVariable;
begin
  Result := EmptyStr;
  for LIndex := IndexFirst(Self) to IndexLast(Self) do
  begin
    LVariable := GetVariable(LIndex);
    if (LVariable.IdentType = itInternal) and (LVariable.FConstantString <> EmptyStr) then
    begin
      Result += CppEncodeVariable(LVariable.Name) + GsCppEqu + GsFnStr + CharOpeningParenthesis +
        LVariable.FConstantString + CharClosingParenthesis + GsCppLineEnding;
    end;
  end;
end;

end.

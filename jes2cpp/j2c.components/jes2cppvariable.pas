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
{$MACRO ON}

interface

uses
  Classes, Jes2CppConstants, Jes2CppEel, Jes2CppIdentifier, Jes2CppStrings, Jes2CppTranslate, Soda, SysUtils;

type

  CJes2CppVariables = class;

  CJes2CppVariable = class
    {$DEFINE DItemClass := CJes2CppVariable}
    {$DEFINE DItemSuper := CJes2CppIdentifier}
    {$INCLUDE soda.inc}
  strict private
    FConstantString: String;
  public
    property ConstantString: String read FConstantString write FConstantString;
  end;

  CJes2CppVariables = class
    {$DEFINE DItemClass := CJes2CppVariables}
    {$DEFINE DItemSuper := CComponent}
    {$DEFINE DItemItems := CJes2CppVariable}
    {$INCLUDE soda.inc}
  strict private
    function CreateVariable(const AName: String; const AIdentType: TJes2CppIdentifierType): CJes2CppVariable;
  public
    function CreateVariable(const AName: TComponentName; const AFileSource: TFileName; const AFileCaretY: Integer;
      const AComment: String): CJes2CppVariable;
    function FindOrCreateVariable(const AName: TComponentName; const AFileSource: TFileName; const AFileCaretY: Integer;
      const AComment: String; out AAlreadyCreated: Boolean): CJes2CppVariable;
  public
    function EncodeDefineCpp: String;
    function EncodeClearCpp: String;
    function EncodeStringLiteralsCpp: String;
  end;

implementation

{$DEFINE DItemClass := CJes2CppVariable} {$INCLUDE soda.inc}

{$DEFINE DItemClass := CJes2CppVariables} {$INCLUDE soda.inc}

function CJes2CppVariables.CreateVariable(const AName: TComponentName; const AFileSource: TFileName;
  const AFileCaretY: Integer; const AComment: String): CJes2CppVariable;
begin
  Result := CreateComponent(AName);
  Result.Comment := AComment;
  Result.References.CreateReference(AFileSource, AFileCaretY);
end;

function CJes2CppVariables.FindOrCreateVariable(const AName: TComponentName; const AFileSource: TFileName;
  const AFileCaretY: Integer; const AComment: String; out AAlreadyCreated: Boolean): CJes2CppVariable;
begin
  Result := FindComponent(AName);
  AAlreadyCreated := Assigned(Result);
  if not AAlreadyCreated then
  begin
    Result := CreateComponent(AName);
    Result.Comment := AComment;
  end;
  Result.References.CreateReference(AFileSource, AFileCaretY);
end;

function CJes2CppVariables.CreateVariable(const AName: String; const AIdentType: TJes2CppIdentifierType): CJes2CppVariable;
begin
  if ComponentExists(AName) then
  begin
    raise Exception.Create('Duplicate Variable Name');
  end;
  Result := CreateComponent(AName);
  Result.IdentType := AIdentType;
end;

function CJes2CppVariables.EncodeDefineCpp: String;
var
  LIdent: CJes2CppIdentifier;
begin
  Result := EmptyStr;
  for LIdent in Self do
  begin
    if LIdent.IdentType = itInternal then
    begin
      J2C_StringAppendCSV(Result, CppEncodeVariable(LIdent.Name));
    end;
  end;
  if Result <> EmptyStr then
  begin
    Result := GsCppEelF + CharSpace + Result + GsCppLineEnding;
  end;
end;

function CJes2CppVariables.EncodeClearCpp: String;
var
  LIdent: CJes2CppIdentifier;
begin
  Result := EmptyStr;
  for LIdent in Self do
  begin
    if LIdent.IdentType = itInternal then
    begin
      Result += CppEncodeVariable(LIdent.Name) + GsCppAssign + GsCppZero + GsCppLineEnding;
    end;
  end;
end;

function CJes2CppVariables.EncodeStringLiteralsCpp: String;
var
  LVariable: CJes2CppVariable;
begin
  Result := EmptyStr;
  for LVariable in Self do
  begin
    if (LVariable.IdentType = itInternal) and (LVariable.ConstantString <> EmptyStr) then
    begin
      Result += CppEncodeVariable(LVariable.Name) + GsCppAssign + GsFnStr + CharOpeningParenthesis +
        LVariable.ConstantString + CharClosingParenthesis + GsCppLineEnding;
    end;
  end;
end;

end.

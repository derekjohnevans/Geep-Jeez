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

unit Jes2CppFunctionIdentifiers;

{$MODE DELPHI}
{$MACRO ON}

interface

uses
  Classes, Jes2CppConstants, Jes2CppEel, Jes2CppIdentifier, Jes2CppIdentString, Jes2CppMessageLog,
  Jes2CppTranslate, Soda, SysUtils;

type

  CJes2CppFunctionIdentifier = class(CJes2CppDataType)
  end;

  CJes2CppFunctionIdentifiers = class
    {$DEFINE DItemClass := CJes2CppFunctionIdentifiers}
    {$DEFINE DItemSuper := CComponent}
    {$DEFINE DItemOwner := CComponent}
    {$DEFINE DItemItems := CJes2CppFunctionIdentifier}
    {$INCLUDE soda.inc}
  public
    function ExistsIdent(const AIdent: TIdentString; const AMessageLog: CJes2CppMessageLog): Boolean;
    function IndexOfIdent(AIdent: TIdentString): Integer;
    function IsCountMatch(const ACount: Integer): Boolean;
    function IsNameSpaceMatch(const AIdent: TIdentString): Boolean;
    function IsVariadic: Boolean;
  public
    procedure AppendParams(var AResult: String; const AIsDefine, AIsInstance: Boolean);
    procedure CopyFrom(const AIdentifiers: CJes2CppFunctionIdentifiers);
  end;

implementation

{$DEFINE DItemClass := CJes2CppFunctionIdentifiers}
{$INCLUDE soda.inc}

procedure CJes2CppFunctionIdentifiers.CopyFrom(const AIdentifiers: CJes2CppFunctionIdentifiers);
var
  LComponent: TComponent;
begin
  Assert(IsEmpty);
  for LComponent in AIdentifiers do
  begin
    CJes2CppFunctionIdentifier.CreateNamed(Self, LComponent.Name);
  end;
end;

function CJes2CppFunctionIdentifiers.IsVariadic: Boolean;
begin
  Result := HasComponents and (Self[ComponentCount - 1].Name = GsEelVariadic);
end;

function CJes2CppFunctionIdentifiers.IndexOfIdent(AIdent: TIdentString): Integer;
begin
  AIdent := J2C_IdentRemoveRef(AIdent);
  for Result := 0 to ComponentCount - 1 do
  begin
    if SameText(AIdent, J2C_IdentRemoveRef(Self[Result].Name)) then
    begin
      Exit;
    end;
  end;
  Result := -1;
end;

function CJes2CppFunctionIdentifiers.ExistsIdent(const AIdent: TIdentString; const AMessageLog: CJes2CppMessageLog): Boolean;
var
  LIndex: Integer;
begin
  Assert(Assigned(AMessageLog));
  LIndex := IndexOfIdent(AIdent);
  Result := LIndex >= 0;
  if Result then
  begin
    AMessageLog.LogWarningCaseCheck(AIdent, Self[LIndex].Name);
  end;
end;

function CJes2CppFunctionIdentifiers.IsCountMatch(const ACount: Integer): Boolean;
begin
  Result := (IsVariadic and (ACount >= ComponentCount - 1)) or (ACount = ComponentCount);
end;

function CJes2CppFunctionIdentifiers.IsNameSpaceMatch(const AIdent: TIdentString): Boolean;
var
  LComponent: TComponent;
begin
  for LComponent in Self do
  begin
    if J2C_IdentIsNameSpace(AIdent, LComponent.Name) then
    begin
      Exit(True);
    end;
  end;
  Result := False;
end;

procedure CJes2CppFunctionIdentifiers.AppendParams(var AResult: String; const AIsDefine, AIsInstance: Boolean);
var
  LComponent: TComponent;
begin
  for LComponent in Self do
  begin
    if AResult <> EmptyStr then
    begin
      AResult += GsCppCommaSpace;
    end;
    if AIsDefine then
    begin
      AResult += GsCppEelF + CharAmpersand + CharSpace;
    end;
    if AIsInstance then
    begin
      AResult += CppEncodeVariable(GsEelSpaceThis + LComponent.Name);
    end else begin
      AResult += CppEncodeVariable(LComponent.Name);
    end;
  end;
end;

end.

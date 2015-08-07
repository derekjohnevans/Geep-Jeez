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
  Classes, Jes2CppConstants, Jes2CppIdentifier, Jes2CppIdentString, Jes2CppStrings,
  Jes2CppTranslate, Soda, SysUtils;

type

  TJes2CppVariableDataType = (vdtDefault, vdtStringLiteral, vdtStringHash, vdtStringNamed);

  CJes2CppVariables = class;

  CJes2CppVariable = class
    {$DEFINE DItemClass := CJes2CppVariable}
    {$DEFINE DItemSuper := CJes2CppIdentifier}
    {$DEFINE DItemOwner := CJes2CppVariables}
    {$INCLUDE soda.inc}
  strict private
    FStringLiteral: String;
    FDefaultValue: Extended;
    FDataType: TJes2CppVariableDataType;
  protected
    procedure DoCreate; override;
  public
    function EncodeEel: String;
  public
    property StringLiteral: String read FStringLiteral write FStringLiteral;
    property DefaultValue: Extended read FDefaultValue write FDefaultValue;
    property DataType: TJes2CppVariableDataType read FDataType write FDataType;
  end;

  CJes2CppVariables = class
    {$DEFINE DItemClass := CJes2CppVariables}
    {$DEFINE DItemSuper := CComponent}
    {$DEFINE DItemItems := CJes2CppVariable}
    {$INCLUDE soda.inc}
  strict private
    FStringNamedIndex, FStringLiteralIndex, FStringHashIndex: Integer;
  protected
    procedure DoCreate; override;
  public
    function CreateVariable(const AName: TComponentName; const AFileSource: TFileName;
      const AFileCaretY: Integer; const AComment: String): CJes2CppVariable;
    function FindOrCreateVariable(const AName: TComponentName; const AFileSource: TFileName;
      const AFileCaretY: Integer; const AComment: String;
      out AAlreadyCreated: Boolean): CJes2CppVariable;
  public
    function CppDeclare: String;
    function CppSetValues: String;
    function CppSetStrings: String;
  public
    property StringNamedIndex: Integer read FStringNamedIndex write FStringNamedIndex;
    property StringLiteralIndex: Integer read FStringLiteralIndex write FStringLiteralIndex;
    property StringHashIndex: Integer read FStringHashIndex write FStringHashIndex;
  end;

implementation

{$DEFINE DItemClass := CJes2CppVariable} {$INCLUDE soda.inc}

procedure CJes2CppVariable.DoCreate;
begin
  inherited DoCreate;
  if GIdentString.IsStringLiteral(Name) then
  begin
    FDataType := vdtStringLiteral;
    FDefaultValue := Owner.StringLiteralIndex;
    Owner.StringLiteralIndex := Owner.StringLiteralIndex + 1;
  end else if GIdentString.IsStringHash(Name) then
  begin
    FDataType := vdtStringHash;
    FDefaultValue := Owner.StringHashIndex;
    Owner.StringHashIndex := Owner.StringHashIndex + 1;
  end else if GIdentString.IsStringNamed(Name) then
  begin
    FDataType := vdtStringNamed;
    FDefaultValue := Owner.StringNamedIndex;
    Owner.StringNamedIndex := Owner.StringNamedIndex + 1;
  end;
end;

function CJes2CppVariable.EncodeEel: String;
begin
  Result := GIdentString.Clean(Name);
end;

{$DEFINE DItemClass := CJes2CppVariables} {$INCLUDE soda.inc}

procedure CJes2CppVariables.DoCreate;
begin
  inherited DoCreate;
  // These base indexs match REAPER's
  FStringLiteralIndex := 10000;
  FStringNamedIndex := 90000;
  FStringHashIndex := 190000;
end;

function CJes2CppVariables.CreateVariable(const AName: TComponentName;
  const AFileSource: TFileName; const AFileCaretY: Integer;
  const AComment: String): CJes2CppVariable;
begin
  Result := CreateComponent(AName);
  Result.Comment := AComment;
  Result.References.CreateReference(AFileSource, AFileCaretY);
end;

function CJes2CppVariables.FindOrCreateVariable(const AName: TComponentName;
  const AFileSource: TFileName; const AFileCaretY: Integer; const AComment: String;
  out AAlreadyCreated: Boolean): CJes2CppVariable;
begin
  Result := FindComponent(AName);
  AAlreadyCreated := Assigned(Result);
  if AAlreadyCreated then
  begin
    Result.References.CreateReference(AFileSource, AFileCaretY);
  end else begin
    Result := CreateVariable(AName, AFileSource, AFileCaretY, AComment);
  end;
end;

function CJes2CppVariables.CppDeclare: String;
var
  LVariable: CJes2CppVariable;
begin
  Result := EmptyStr;
  for LVariable in Self do
  begin
    if (LVariable.IdentType = itInternal) and (LVariable.DataType in
      [vdtDefault, vdtStringNamed]) then
    begin
      GString.AppendCSV(Result, GCpp.Encode.NameVariable(LVariable.Name));
    end;
  end;
  if Result <> EmptyStr then
  begin
    Result := GsCppEelF + CharSpace + Result + GsCppLineEnding;
  end;
end;

function CJes2CppVariables.CppSetValues: String;
var
  LVariable: CJes2CppVariable;
begin
  Result := EmptyStr;
  for LVariable in Self do
  begin
    if (LVariable.IdentType = itInternal) and (LVariable.DataType in
      [vdtDefault, vdtStringNamed]) then
    begin
      Result += GCpp.Encode.NameVariable(LVariable.Name) + GsCppAssign +
        GCpp.Encode.Float(LVariable.DefaultValue) + GsCppLineEnding;
    end;
  end;
end;

function CJes2CppVariables.CppSetStrings: String;
var
  LVariable: CJes2CppVariable;
begin
  Result := EmptyStr;
  for LVariable in Self do
  begin
    if (LVariable.IdentType = itInternal) and (LVariable.DataType = vdtStringLiteral) then
    begin
      // TODO: Make a constant.
      Result += Format('SetString(%s, %s)', [GCpp.Encode.Float(LVariable.DefaultValue),
        LVariable.StringLiteral]) + GsCppLineEnding;
    end;
  end;
end;

end.

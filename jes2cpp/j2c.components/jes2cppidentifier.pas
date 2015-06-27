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

unit Jes2CppIdentifier;

{$MODE DELPHI}
{$MACRO ON}

interface

uses
  Classes, Jes2CppFileNames, Jes2CppIdentString, Jes2CppReference, Jes2CppTranslate, Soda, SysUtils;

type

  TJes2CppIdentifierType = (itInternal, itExternal);

  CJes2CppDataType = class(CComponent)
  strict private
    FDataType: String;
  strict private
    function GetDataType: String;
  public
    property DataType: String read GetDataType write FDataType;
  end;

  CJes2CppIdentifier = class(CJes2CppDataType)
  strict private
    FComment: String;
    FIdentType: TJes2CppIdentifierType;
    FReferences: CJes2CppReferences;
  protected
    procedure DoCreate; override;
  public
    function IsSystem: Boolean;
    function IsIdent(const AIdent: TIdentString): Boolean;
  public
    property References: CJes2CppReferences read FReferences;
    property IdentType: TJes2CppIdentifierType read FIdentType write FIdentType;
    property Comment: String read FComment write FComment;
  end;

  CJes2CppIdentifiers = class
    {$DEFINE DItemClass := CJes2CppIdentifiers}
    {$DEFINE DItemSuper := CComponent}
    {$DEFINE DItemItems := CJes2CppIdentifier}
    {$INCLUDE soda.inc}
  end;

implementation

{$DEFINE DItemClass := CJes2CppIdentifiers}
{$INCLUDE soda.inc}

function CJes2CppDataType.GetDataType: String;
begin
  Result := FDataType;
  if Result = EmptyStr then
  begin
    Result := GsCppEelF;
  end;
end;

procedure CJes2CppIdentifier.DoCreate;
begin
  inherited DoCreate;
  FReferences := CJes2CppReferences.Create(Self);
end;

function CJes2CppIdentifier.IsSystem: Boolean;
begin
  Result := (IdentType = itExternal) or (References.HasComponents and SameText(References[0].FilePartName,
    GsFilePartJes2Cpp + GsFileExtJsFxInc));
end;

function CJes2CppIdentifier.IsIdent(const AIdent: TIdentString): Boolean;
begin
  Result := SameText(Name, AIdent);
end;

end.

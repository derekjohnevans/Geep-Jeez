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

interface

uses
  Classes, Jes2CppReference, SysUtils;

type

  TJes2CppIdentifierClass = class of CJes2CppIdentifier;

  TJes2CppIdentifierType = (itUser, itSystem);

  CJes2CppIdentifier = class(TComponent)
  strict private
    FIdentType: TJes2CppIdentifierType;
    FIsHidden: Boolean;
    FReferences: TJes2CppReferences;
  protected
    procedure SetName(const AName: TComponentName); override;
  public
    constructor Create(AOwner: TComponent); override;
  public
    property References: TJes2CppReferences read FReferences;
    property IdentType: TJes2CppIdentifierType read FIdentType write FIdentType;
    property IsHidden: Boolean read FIsHidden write FIsHidden;
  end;

  CJes2CppIdentifiers = class(TComponent)
  public
    function Find(const AName: TComponentName): CJes2CppIdentifier;
    function FindOrCreate(const AName: TComponentName; const AClass: TJes2CppIdentifierClass; const AFileName: TFileName;
      const AFileLine: Integer): CJes2CppIdentifier;
    function GetIdentifier(const AIndex: Integer): CJes2CppIdentifier;
  end;

implementation

constructor CJes2CppIdentifier.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FReferences := TJes2CppReferences.Create(Self);
end;

procedure CJes2CppIdentifier.SetName(const AName: TComponentName);
begin
  ChangeName(AName);
end;

function CJes2CppIdentifiers.GetIdentifier(const AIndex: Integer): CJes2CppIdentifier;
begin
  Result := Components[AIndex] as CJes2CppIdentifier;
end;

function CJes2CppIdentifiers.Find(const AName: TComponentName): CJes2CppIdentifier;
begin
  Result := FindComponent(AName) as CJes2CppIdentifier;
end;

function CJes2CppIdentifiers.FindOrCreate(const AName: TComponentName; const AClass: TJes2CppIdentifierClass;
  const AFileName: TFileName; const AFileLine: Integer): CJes2CppIdentifier;
begin
  Result := Find(AName);
  if not Assigned(Result) then
  begin
    Result := AClass.Create(Self);
    Result.Name := AName;
  end;
  Result.References.AddReference(AFileName, AFileLine);
end;

end.

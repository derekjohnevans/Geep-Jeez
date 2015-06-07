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
  Classes, Dialogs, Jes2CppFileNames, Jes2CppIdentString, Jes2CppReference, SysUtils;

type

  TJes2CppIdentifierType = (itInternal, itExternal);

  CJes2CppIdentifier = class(TComponent)
  strict private
    FComment: String;
    FIdentType: TJes2CppIdentifierType;
    FReferences: CJes2CppReferences;
  protected
    function GetName: TComponentName;
    procedure SetName(const AName: TComponentName); override;
  public
    constructor Create(const AOwner: TComponent; const AName: TComponentName); virtual; reintroduce;
  public
    function IsSystem: Boolean;
    function IsIdent(const AIdent: TIdentString): Boolean;
  public
    property References: CJes2CppReferences read FReferences;
    property IdentType: TJes2CppIdentifierType read FIdentType write FIdentType;
    property Comment: String read FComment write FComment;
    property Name: TComponentName read GetName;
  end;

  CJes2CppIdentifiers = class(TComponent)
  public
    function GetIdentifier(const AIndex: Integer): CJes2CppIdentifier;
  end;

  // Unused. Doesn't seem to help much.
  CJes2CppIdentifiersFastFind = class(CJes2CppIdentifiers)
  strict private
    FNames: TStringList;
  protected
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  public
    function FindComponent(const AName: TComponentName): TComponent;
  end;

implementation

constructor CJes2CppIdentifier.Create(const AOwner: TComponent; const AName: TComponentName);
begin
  SetName(AName);
  inherited Create(AOwner);
  FReferences := CJes2CppReferences.Create(Self);
end;

function CJes2CppIdentifier.GetName: TComponentName;
begin
  Result := inherited Name;
end;

procedure CJes2CppIdentifier.SetName(const AName: TComponentName);
begin
  ChangeName(AName);
end;

function CJes2CppIdentifier.IsSystem: Boolean;
begin
  Result := (IdentType = itExternal) or ((References.ComponentCount > 0) and
    SameText(References.GetReference(0).FilePartName, GsFilePartJes2Cpp + GsFileExtJsFxInc));
end;

function CJes2CppIdentifier.IsIdent(const AIdent: TIdentString): Boolean;
begin
  Result := SameText(Name, AIdent);
end;

function CJes2CppIdentifiers.GetIdentifier(const AIndex: Integer): CJes2CppIdentifier;
begin
  Result := Components[AIndex] as CJes2CppIdentifier;
end;

constructor CJes2CppIdentifiersFastFind.Create(AOwner: TComponent);
begin
  FNames := TStringList.Create;
  FNames.Sorted := True;
  FNames.Duplicates := dupError;
  FNames.CaseSensitive := False;
  inherited Create(AOwner);
end;

destructor CJes2CppIdentifiersFastFind.Destroy;
begin
  inherited Destroy;
  FreeAndNil(FNames);
end;

procedure CJes2CppIdentifiersFastFind.Notification(AComponent: TComponent; AOperation: TOperation);
var
  LIndex: Integer;
begin
  inherited  Notification(AComponent, AOperation);
  if AComponent.Owner = Self then
  begin
    case AOperation of
      opInsert: begin
        FNames.AddObject(AComponent.Name, AComponent);
      end;
      opRemove: begin
        if FNames.Find(AComponent.Name, LIndex) then
        begin
          FNames.Delete(LIndex);
        end;
      end;
    end;
  end;
end;

function CJes2CppIdentifiersFastFind.FindComponent(const AName: TComponentName): TComponent;
var
  LIndex: Integer;
begin
  if FNames.Find(AName, LIndex) then
  begin
    Result := FNames.Objects[LIndex] as TComponent;
  end else begin
    Result := inherited FindComponent(AName);
  end;
end;

end.

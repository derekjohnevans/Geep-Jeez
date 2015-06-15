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

unit Jes2CppComponent;

{$MODE DELPHI}

interface

uses
  Classes, Masks, SysUtils;

type
  CJes2CppComponent = class(TComponent)
  protected
    function GetName: TComponentName;
    procedure SetName(const AName: TComponentName); override;
    procedure FindComponent; // Hide this, so we cant use it.
  public
    constructor Create(const AOwner: TComponent; const AName: TComponentName); virtual; reintroduce;
  public
    function ExistsFiltered(const AName: TComponentName): Boolean;
    function ExistsSameText(const AName: TComponentName): Boolean;
    function FindByFiltered(const AName: TComponentName): TComponent;
    function FindBySameText(const AName: TComponentName): TComponent;
  public
    property Components; default;
  end;

implementation

constructor CJes2CppComponent.Create(const AOwner: TComponent; const AName: TComponentName);
begin
  SetName(AName);
  inherited Create(AOwner);
end;

function CJes2CppComponent.GetName: TComponentName;
begin
  Result := inherited Name;
end;

procedure CJes2CppComponent.SetName(const AName: TComponentName);
begin
  ChangeName(AName);
end;

procedure CJes2CppComponent.FindComponent;
begin

end;

function CJes2CppComponent.FindBySameText(const AName: TComponentName): TComponent;
var
  LIndex: Integer;
begin
  for LIndex := 0 to ComponentCount - 1 do
  begin
    Result := Self[LIndex];
    if SameText(AName, Result.Name) then
    begin
      Exit;
    end;
  end;
  Result := nil;
end;

function CJes2CppComponent.FindByFiltered(const AName: TComponentName): TComponent;
var
  LIndex: Integer;
begin
  for LIndex := 0 to ComponentCount - 1 do
  begin
    Result := Self[LIndex];
    if MatchesMask(AName, Result.Name) then
    begin
      Exit;
    end;
  end;
  Result := nil;
end;

function CJes2CppComponent.ExistsSameText(const AName: TComponentName): Boolean;
begin
  Result := Assigned(FindBySameText(AName));
end;

function CJes2CppComponent.ExistsFiltered(const AName: TComponentName): Boolean;
begin
  Result := Assigned(FindByFiltered(AName));
end;

end.

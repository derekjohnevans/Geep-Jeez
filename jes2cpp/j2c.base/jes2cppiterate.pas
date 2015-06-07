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

unit Jes2CppIterate;

{$MODE DELPHI}

interface

uses
  Classes, ComCtrls;

function ItemCount(const AList: TStrings): Integer; overload;
function ItemCount(const AList: TComponent): Integer; overload;
function ItemCount(const AList: TPageControl): Integer; overload;

function ItemFirst(const AList: TStrings): Integer; overload;
function ItemFirst(const AList: TComponent): Integer; overload;
function ItemFirst(const AList: TPageControl): Integer; overload;

function ItemLast(const AList: TStrings): Integer; overload;
function ItemLast(const AList: TComponent): Integer; overload;
function ItemLast(const AList: TPageControl): Integer; overload;

implementation

function ItemCount(const AList: TStrings): Integer;
begin
  Assert(Assigned(AList));
  Result := AList.Count;
end;

function ItemCount(const AList: TComponent): Integer;
begin
  Assert(Assigned(AList));
  Result := AList.ComponentCount;
end;

function ItemCount(const AList: TPageControl): Integer; overload;
begin
  Assert(Assigned(AList));
  Result := AList.PageCount;
end;

function ItemFirst(const AList: TStrings): Integer;
begin
  Assert(Assigned(AList));
  Result := 0;
end;

function ItemFirst(const AList: TComponent): Integer;
begin
  Assert(Assigned(AList));
  Result := 0;
end;

function ItemFirst(const AList: TPageControl): Integer;
begin
  Assert(Assigned(AList));
  Result := 0;
end;

function ItemLast(const AList: TStrings): Integer;
begin
  Result := ItemCount(AList) - 1;
end;

function ItemLast(const AList: TComponent): Integer;
begin
  Result := ItemCount(AList) - 1;
end;

function ItemLast(const AList: TPageControl): Integer;
begin
  Result := ItemCount(AList) - 1;
end;

end.


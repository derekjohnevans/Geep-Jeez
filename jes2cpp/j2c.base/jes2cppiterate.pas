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

function IndexFirst(const AList: TObject): Integer; overload;

function IndexCount(const AList: TStrings): Integer; overload;
function IndexCount(const AList: TComponent): Integer; overload;
function IndexCount(const AList: TPageControl): Integer; overload;
function IndexCount(const AList: TToolBar): Integer; overload;

function IndexLast(const AList: TStrings): Integer; overload;
function IndexLast(const AList: TComponent): Integer; overload;
function IndexLast(const AList: TPageControl): Integer; overload;
function IndexLast(const AList: TToolBar): Integer; overload;

implementation

function IndexFirst(const AList: TObject): Integer;
begin
  Assert(Assigned(AList));
  Result := 0;
end;

function IndexCount(const AList: TStrings): Integer;
begin
  Assert(Assigned(AList));
  Result := AList.Count;
end;

function IndexCount(const AList: TComponent): Integer;
begin
  Assert(Assigned(AList));
  Result := AList.ComponentCount;
end;

function IndexCount(const AList: TPageControl): Integer;
begin
  Assert(Assigned(AList));
  Result := AList.PageCount;
end;

function IndexCount(const AList: TToolBar): Integer;
begin
  Assert(Assigned(AList));
  Result := AList.ButtonCount;
end;

function IndexLast(const AList: TStrings): Integer;
begin
  Result := IndexCount(AList) - 1;
end;

function IndexLast(const AList: TComponent): Integer;
begin
  Result := IndexCount(AList) - 1;
end;

function IndexLast(const AList: TPageControl): Integer;
begin
  Result := IndexCount(AList) - 1;
end;

function IndexLast(const AList: TToolBar): Integer;
begin
  Result := IndexCount(AList) - 1;
end;

end.


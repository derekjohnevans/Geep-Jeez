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

unit Jes2CppReference;

{$MODE DELPHI}

interface

uses
  Classes, Jes2CppConstants, SysUtils;

type
  TJes2CppReference = class(TComponent)
  strict private
    FFileName: TFileName;
    FFileLine: Integer;
  public
    function Encode: String;
    property FileName: TFileName read FFileName write FFileName;
    property FileLine: Integer read FFileLine write FFileLine;
  end;

  TJes2CppReferences = class(TComponent)
  public
    function AddReference(const AFileName: TFileName; const AFileLine: Integer): TJes2CppReference;
  end;

implementation

function TJes2CppReference.Encode: String;
begin
  Result := Format('%s="%d" %s="%s" %s="%s"', [SLine, FFileLine, SFile, ExtractFileName(FFileName),
    SPath, ExtractFilePath(FFileName)]);
end;

function TJes2CppReferences.AddReference(const AFileName: TFileName; const AFileLine: Integer): TJes2CppReference;
begin
  Result := TJes2CppReference.Create(Self);
  Result.FileName := AFileName;
  Result.FileLine := AFileLine;
end;

end.

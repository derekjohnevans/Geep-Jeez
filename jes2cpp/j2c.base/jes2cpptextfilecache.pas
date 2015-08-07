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

unit Jes2CppTextFileCache;

{$MODE DELPHI}

interface

uses
  Classes, Contnrs, FileUtil, Jes2CppConstants, SysUtils;

type
  TJes2CppTextFile = class(TStringList)
  strict private
    FFileAge: longint;
  strict private
    procedure LogAssert(const ATrue: Boolean; const AMessage, AFileName: String);
  public
    procedure LoadFromFile(const AFileName: TFileName); override;
  end;

  GFileCache = object
    class function LoadFromFile(const AFileName: TFileName): TJes2CppTextFile;
  end;

implementation

procedure TJes2CppTextFile.LogAssert(const ATrue: Boolean; const AMessage, AFileName: String);
begin
  if not ATrue then
  begin
    raise Exception.Create(AMessage + ' - ''' + AFileName + '''');
  end;
end;

procedure TJes2CppTextFile.LoadFromFile(const AFileName: TFileName);
var
  LFileAge: longint;
begin
  LogAssert(FilenameIsAbsolute(AFileName), SMsgFileNameMustBeAbsolute, AFileName);
  LFileAge := FileAge(AFileName);
  LogAssert(LFileAge >= 0, SMsgFileDoesNotExist, AFileName);
  if LFileAge > FFileAge then
  begin
    LogAssert(FileIsText(AFileName), SMsgFileIsNotATextFile, AFileName);
    inherited LoadFromFile(AFileName);
    FFileAge := LFileAge;
  end;
end;

var
  GFileObjectList: TFPHashObjectList;

class function GFileCache.LoadFromFile(const AFileName: TFileName): TJes2CppTextFile;
begin
  Result := GFileObjectList.Find(AFileName) as TJes2CppTextFile;
  if not Assigned(Result) then
  begin
    Result := TJes2CppTextFile.Create;
    GFileObjectList.Add(AFileName, Result);
  end;
  Result.LoadFromFile(AFileName);
end;

initialization

  GFileObjectList := TFPHashObjectList.Create;

end.

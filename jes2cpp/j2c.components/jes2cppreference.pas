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
  CJes2CppReference = class(TComponent)
  strict private
    FFilePartPath, FFilePartName: TFileName;
    FFileLine: Integer;
  strict private
    procedure SetFileName(const AFileName: TFileName);
    function GetFileName: TFileName;
  public
    function EncodeLineFilePath: String;
    function EncodeLineFile: String;
    property FileName: TFileName read GetFileName write SetFileName;
    property FilePartName: TFileName read FFilePartName;
    property FileLine: Integer read FFileLine write FFileLine;
  end;

  CJes2CppReferences = class(TComponent)
  public
    function AddReference(const AFileName: TFileName; const AFileLine: Integer): CJes2CppReference;
    function GetReference(const AIndex: Integer): CJes2CppReference;
  end;

implementation

procedure CJes2CppReference.SetFileName(const AFileName: TFileName);
begin
  FFilePartPath := ExtractFilePath(AFileName);
  FFilePartName := ExtractFileName(AFileName);
end;

function CJes2CppReference.GetFileName: TFileName;
begin
  Result := FFilePartPath + FFilePartName;
end;

function CJes2CppReference.EncodeLineFilePath: String;
begin
  Result := Format('%s=%s %s=%s %s=%s', [GsLine, QuotedStr(IntToStr(FFileLine)), GsFile, QuotedStr(FFilePartName),
    GsPath, QuotedStr(FFilePartPath)]);
end;

function CJes2CppReference.EncodeLineFile: String;
begin
  Result := Format('%s=%s %s=%s', [GsLine, QuotedStr(IntToStr(FFileLine)), GsFile, QuotedStr(FFilePartName)]);
end;

function CJes2CppReferences.AddReference(const AFileName: TFileName; const AFileLine: Integer): CJes2CppReference;
begin
  Result := CJes2CppReference.Create(Self);
  Result.FileName := AFileName;
  Result.FileLine := AFileLine;
end;

function CJes2CppReferences.GetReference(const AIndex: Integer): CJes2CppReference;
begin
  Result := Components[AIndex] as CJes2CppReference;
end;

end.

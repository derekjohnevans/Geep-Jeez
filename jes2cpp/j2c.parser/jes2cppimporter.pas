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

unit Jes2CppImporter;

{$MODE DELPHI}

interface

uses
  Classes, Jes2CppConstants, Jes2CppDescription, Jes2CppEel, Jes2CppMessageLog,
  Jes2CppTextFileCache, Math, SysUtils;

type

  CJes2CppImporter = class(CJes2CppMessageLog)
  strict private
    FDescription: CJes2CppDescription;
    FFileNamesImported: TStringList;
  protected
    procedure PrependSliderSerializationCode;
    function LoadStringsFrom(const AFileSource: TFileName): TStrings; virtual;
    procedure ImportFrom(const AScript: TStrings; const AFileSource: TFileName;
      const ALevel: Integer = 0); overload;
    procedure ImportFrom(const AFileSource: TFileName); overload;
  protected
    procedure DoCreate; override;
    procedure DoDestroy; override;
  public
    property Description: CJes2CppDescription read FDescription;
  end;

implementation

procedure CJes2CppImporter.DoCreate;
begin
  inherited DoCreate;
  FDescription := CJes2CppDescription.Create(Self);
  FFileNamesImported := TStringList.Create;
  FFileNamesImported.Sorted := True;
end;

procedure CJes2CppImporter.DoDestroy;
begin
  FreeAndNil(FFileNamesImported);
  inherited DoDestroy;
end;

function CJes2CppImporter.LoadStringsFrom(const AFileSource: TFileName): TStrings;
begin
  Result := GFileCache.LoadFromFile(AFileSource);
end;

procedure CJes2CppImporter.ImportFrom(const AScript: TStrings; const AFileSource: TFileName;
  const ALevel: Integer);
var
  LIndex: Integer;
  LImportFileName: TFileName;
begin
  if ALevel > 10 then
  begin
    LogException('Max Importing Depth Reached.');
  end else begin
    if FFileNamesImported.IndexOf(AFileSource) < ZeroValue then
    begin
      FFileNamesImported.Add(AFileSource);
      LogFileName(SMsgTypeImporting, AFileSource);
      for LIndex := ZeroValue to GEel.DescHigh(AScript) do
      begin
        if GEel.IsImport(AScript[LIndex], LImportFileName) then
        begin
          try
            LogAssert(GEel.ImportResolve(LImportFileName, AFileSource),
              SMsgUnableToFindImportFile);
            ImportFrom(LoadStringsFrom(LImportFileName), LImportFileName, ALevel + 1);
          except
            on AException: Exception do
            begin
              FileCaretY := LIndex + 1;
              FileSource := AFileSource;
              LogException(AException.Message);
            end;
          end;
        end;
      end;
      FDescription.ImportFromScript(AScript, AFileSource);
    end;
  end;
end;

procedure CJes2CppImporter.ImportFrom(const AFileSource: TFileName);
begin
  ImportFrom(LoadStringsFrom(AFileSource), AFileSource);
end;

procedure CJes2CppImporter.PrependSliderSerializationCode;
begin
  // TODO: Read/Write slider in Jesusonic?
end;

end.

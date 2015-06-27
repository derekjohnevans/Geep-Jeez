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
  Classes, Jes2CppConstants, Jes2CppDescription, Jes2CppEel, Jes2CppMessageLog, SysUtils;

type

  CJes2CppImporter = class(CJes2CppMessageLog)
  strict private
    FDescription: CJes2CppDescription;
    FFileNamesImported: TStringList;
  protected
    procedure WriteSliderSerializationCode;
    procedure LoadStringsFrom(const AStrings: TStrings; const AFileName: TFileName); virtual;
    procedure ImportFrom(const AScript: TStrings; const AScriptFileName: TFileName; const ALevel: Integer = 0); overload;
    procedure ImportFrom(const AScriptFileName: TFileName); overload;
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

procedure CJes2CppImporter.LoadStringsFrom(const AStrings: TStrings; const AFileName: TFileName);
begin
  AStrings.LoadFromFile(AFileName);
end;

procedure CJes2CppImporter.ImportFrom(const AScript: TStrings; const AScriptFileName: TFileName; const ALevel: Integer);
var
  LIndex: Integer;
  LImportStrings: TStrings;
  LImportFileName: TFileName;
begin
  if ALevel > 10 then
  begin
    LogException('Max Importing Depth Reached.');
  end else begin
    if FFileNamesImported.IndexOf(AScriptFileName) < 0 then
    begin
      LogFileName(SMsgTypeImporting, AScriptFileName);
      for LIndex := 0 to EelDescHigh(AScript) do
      begin
        if EelIsImport(AScript[LIndex], LImportFileName) then
        begin
          LImportStrings := TStringList.Create;
          try
            LImportFileName := EelFileNameResolve(LImportFileName, AScriptFileName);
            try
              LoadStringsFrom(LImportStrings, LImportFileName);
            except
              on AException: Exception do
              begin
                FileCaretY := LIndex + 1;
                FileSource := AScriptFileName;
                LogException(AException.Message);
              end;
            end;
            ImportFrom(LImportStrings, LImportFileName, ALevel + 1);
          finally
            FreeAndNil(LImportStrings);
          end;
        end;
      end;
      FDescription.ImportFromScript(AScript, AScriptFileName);
      FFileNamesImported.Add(AScriptFileName);
    end;
  end;
end;

procedure CJes2CppImporter.ImportFrom(const AScriptFileName: TFileName);
var
  LStrings: TStrings;
begin
  LStrings := TStringList.Create;
  try
    LoadStringsFrom(LStrings, AScriptFileName);
    ImportFrom(LStrings, AScriptFileName);
  finally
    FreeAndNil(LStrings);
  end;
end;

procedure CJes2CppImporter.WriteSliderSerializationCode;
begin
  LogMessage('HERE'+IntToStr(FDescription.Parameters.ComponentCount));
  //FDescription.
end;

end.

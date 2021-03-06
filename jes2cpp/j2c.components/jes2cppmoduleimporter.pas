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

unit Jes2CppModuleImporter;

{$MODE DELPHI}

interface

uses
  Classes, Jes2Cpp, Jes2CppConstants, Jes2CppEel, Jes2CppIdentString,
  Jes2CppStrings, Jes2CppUtils, Jes2CppVariable, StrUtils, SysUtils;

procedure J2C_ImportModule(const ADst: TStrings; const AFileName: TFileName);

implementation

// TODO: This needs to skip strings, comments and chars.
function EelPosEx(const ASubStr, AString: String; const AIndex: Integer): Integer;
begin
  Result := PosEx(ASubStr, AString, AIndex);
end;

function AdjustArrays(const AString: String): String;
const
  LHead = GsEelThis + '+(';
  LFoot = ')';
var
  LPos, LEnd: Integer;
begin
  Result := AString;
  LEnd := 0;
  repeat
    LPos := EelPosEx('[', Result, LEnd + 1);
    if LPos = 0 then
    begin
      Break;
    end;
    Inc(LPos);
    LEnd := EelPosEx(']', Result, LPos);
    if LEnd = 0 then
    begin
      Break;
    end;
    Result := StuffString(Result, LPos, LEnd - LPos, LHead +
      Copy(Result, LPos, LEnd - LPos) + LFoot);
    LPos := LEnd + Length(LHead) + Length(LFoot);
  until False;
end;

procedure J2C_ImportSection(const ADst, ASrc: TStrings; const AFileName: TFileName;
  const ASectionName: String);
var
  LUnused: Integer;
  LSectionHeader, LInstances: String;
  LSection: TStringList;
  LVariable: CJes2CppVariable;
begin
  GStrings.AddCommentTitle(ADst, GEelSectionHeader.Make(ASectionName));
  LSection := TStringList.Create;
  try
    GUtils.ExtractSection(ASectionName, LSection, ASrc, EmptyStr, False, LSectionHeader);
    LSection.Insert(0, GEelSectionHeader.Make(GsEelSectionInit));
    with CJes2Cpp.Create(nil) do
    begin
      try
        TranspileScript(LSection, AFileName);
        LSection.Delete(0);
        ADst.AddText(WrapText(GsEelFunction + CharSpace +
          GIdentString.FixUp(ASectionName + CharUnderscore + ChangeFileExt(
          ExtractFileName(AFileName), EmptyStr)) + CharOpeningParenthesis +
          CharClosingParenthesis, GiColWidth));
        LInstances := EmptyStr;
        for LVariable in Variables do
        begin
          if not LVariable.IsSystem or ((LVariable.References.ComponentCount > 1) and
            (GIdentString.IsSlider(LVariable.Name, LUnused) or
            GIdentString.IsSample(LVariable.Name, LUnused))) then
          begin
            GString.AppendCSV(LInstances, GIdentString.Clean(LVariable.Name));
          end;
        end;
        if LInstances <> EmptyStr then
        begin
          ADst.AddText(WrapText(GsEelInstance + CharOpeningParenthesis +
            LInstances + CharClosingParenthesis, GiColWidth));
        end;
        ADst.Add(CharOpeningParenthesis);
        ADst.AddText(AdjustArrays(LSection.Text));
        ADst.Add('0;');
        ADst.Add(CharClosingParenthesis + CharSemiColon);
      finally
        Free;
      end;
    end;
  finally
    FreeAndNil(LSection);
  end;
end;

procedure J2C_ImportModule(const ADst: TStrings; const AFileName: TFileName);
var
  LScript: TStrings;
begin
  GStrings.AddCommentTitle(ADst, 'This file was auto generated from: ' +
    QuotedStr(ExtractFileName(AFileName)) + LineEnding +
    'Note: This feature is experimental and the results may need to be hand edited.' +
    LineEnding + 'Module importing only works for simple Jesusonic effects. ie: No functions allowed.');
  ADst.Add(GEelSectionHeader.Make(GsEelSectionInit));
  LScript := TStringList.Create;
  try
    LScript.LoadFromFile(AFileName);
    J2C_ImportSection(ADst, LScript, AFileName, GsEelSectionInit);
    J2C_ImportSection(ADst, LScript, AFileName, GsEelSectionSlider);
    J2C_ImportSection(ADst, LScript, AFileName, GsEelSectionBlock);
    J2C_ImportSection(ADst, LScript, AFileName, GsEelSectionSample);
  finally
    FreeAndNil(LScript);
  end;
end;

end.

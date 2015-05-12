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

unit Jes2CppFileNames;

{$MODE DELPHI}

interface

uses
  FileUtil, Jes2CppConstants, Jes2CppPlatform, SysUtils;

const

  SFilePartJes2Cpp = 'jes2cpp';
  SFilePartGeep = 'geep';
  SFilePartOutput = 'output';
  SFilePartVeST = 'VeST';
  SFilePartBass = 'bass';
  SFilePartWdl = 'wdl';

  SFileExtHtml = ExtensionSeparator + 'html';
  SFileExtJsFx = ExtensionSeparator + 'jsfx';
  SFileExtCpp = ExtensionSeparator + 'cpp';
  SFileExtDll = ExtensionSeparator + 'dll';
  SFileExtLib = ExtensionSeparator + 'lib';
  SFileExtA = ExtensionSeparator + 'a';

function PathToReaperFiles: TFileName;
function PathToReaperData: TFileName;
function PathToReaperEffects: TFileName;
function PathToVstEffects: TFileName;
function PathToBuild: TFileName;
function PathToWdlSdk: TFileName;
function PathToBass: TFileName;
function PathToGeep: TFileName;
function PathToJes2Cpp: TFileName;
function PathToVeSTSdk: TFileName;
function FileNameBassLib: TFileName;
function FileNameVeSTLib32: TFileName;
function FileNameVeSTLib64: TFileName;
function FileNameOutputCpp: TFileName;

implementation

function PathToReaperFiles: TFileName;
begin
  Result := PathToApplicationData + 'REAPER' + DirectorySeparator;
end;

function PathToReaperData: TFileName;
begin
  Result := PathToReaperFiles + 'Data' + DirectorySeparator;
end;

function PathToReaperEffects: TFileName;
begin
  Result := PathToReaperFiles + 'Effects' + DirectorySeparator;
end;

function PathToVstEffects: TFileName;
begin
  Result := PathToProgramFiles + 'VST' + DirectorySeparator;
end;

function PathToBuild: TFileName;
begin
  Result := GetTempDir + SJes2CppName + DirectorySeparator;
  if not ForceDirectory(Result) then
  begin
    raise Exception.Create(SMsgUnableToCreateOuputDirectory);
  end;
end;

function PathToWdlSdk: TFileName;
begin
  Result := ProgramDirectory + SFilePartWdl + DirectorySeparator;
end;

function PathToBass: TFileName;
begin
  Result := ProgramDirectory + SFilePartBass + DirectorySeparator;
end;

function PathToGeep: TFileName;
begin
  Result := ProgramDirectory + SFilePartGeep + DirectorySeparator;
end;

function PathToJes2Cpp: TFileName;
begin
  Result := ProgramDirectory + SFilePartJes2Cpp + DirectorySeparator;
end;

function PathToVeSTSdk: TFileName;
begin
  Result := ProgramDirectory + SFilePartVeST + DirectorySeparator;
end;

function FileNameBassLib: TFileName;
begin
  Result := PathToBass + SFilePartBass + SFileExtLib;
end;

function FileNameVeSTLib32: TFileName;
begin
  Result := PathToVeSTSdk + 'lib' + SFilePartVeST + '32' + SFileExtA;
end;

function FileNameVeSTLib64: TFileName;
begin
  Result := PathToVeSTSdk + 'lib' + SFilePartVeST + '64' + SFileExtA;
end;

function FileNameOutputCpp: TFileName;
begin
  Result := PathToBuild + SFilePartOutput + SFileExtCpp;
end;

end.


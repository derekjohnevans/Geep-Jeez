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
  FileUtil, Jes2CppConstants, Jes2CppPlatform, StrUtils, SysUtils;

const

  GsFileExtA = ExtensionSeparator + 'a';
  GsFileExtCpp = ExtensionSeparator + 'cpp';
  GsFileExtHtml = ExtensionSeparator + 'html';
  GsFileExtJsFx = ExtensionSeparator + 'jsfx';
  GsFileExtJsFxInc = GsFileExtJsFx + '-inc';
  GsFileExtLib = ExtensionSeparator + 'lib';
  GsFileExtExe = ExtensionSeparator + 'exe';

{$IF DEFINED(WINDOWS)}
  GsFileExtDll = ExtensionSeparator + 'dll';
{$ELSEIF DEFINED(LINUX)}
  GsFileExtDll = ExtensionSeparator + 'so';
{$ELSE}
{$ERROR}
{$ENDIF}

const

  GsFilePart32 = '32';
  GsFilePart64 = '64';
  GsFilePartBass = 'bass';
  GsFilePartData = 'Data';
  GsFilePartEffects = 'Effects';
  GsFilePartJes2Cpp = 'jes2cpp';
  GsFilePartLibSndFile = 'libsndfile';
  GsFilePartLibSndFile1 = GsFilePartLibSndFile + '-1';
  GsFilePartLib = 'lib';
  GsFilePartOutput = 'output';
  GsFilePartREAPER = 'REAPER';
  GsFilePartVeST = 'vest';
  GsFilePartVST = 'VST';
  GsFilePartUpX = 'upx';
  GsFilePartSaviHost = 'savihost';

type

  TJes2CppFileNames = object
  public
    class function PathToReaperFiles: TFileName;
    class function PathToReaperData: TFileName;
    class function PathToReaperEffects: TFileName;
    class function PathToVstEffects: TFileName;
    class function PathToTempBuild: TFileName;
    class function PathToSdkJes2Cpp: TFileName;
    class function PathToSdkVeST: TFileName;
  public
    class function FileName32x64(const AFileName: TFileName; const AUse64: Boolean): TFileName;
    class function FileNameJes2CppJsFx: TFileName;
    class function FileNameBassLib(const AUse64: Boolean): TFileName;
    class function FileNameSndFileLib(const AUse64: Boolean): TFileName;
    class function FileNameVeSTLib32: TFileName;
    class function FileNameVeSTLib64: TFileName;
    class function FileNameOutputCpp: TFileName;
    class function FileNameOutputDll: TFileName;
    class function FileNameUpX: TFileName;
    class function FileNameSaviHost(const AUse64: Boolean): TFileName;
  public
    class function DecodeMeta(const AString: String): String;
  end;

implementation

function PathToApplicationData: TFileName;
begin
  Result := J2C_GetSpecialDir(CSIDL_APPDATA);
end;

function PathToProgramFiles: TFileName;
begin
  Result := J2C_GetSpecialDir(CSIDL_PROGRAM_FILES);
end;

function PathToWindows: TFileName;
begin
  Result := J2C_GetSpecialDir(CSIDL_WINDOWS);
end;

function PathToProfiles: TFileName;
begin
  Result := J2C_GetSpecialDir(CSIDL_PROFILES);
end;

function PathToProfile: TFileName;
begin
  Result := J2C_GetSpecialDir(CSIDL_PROFILE);
end;

function PathToTemp: TFileName;
begin
  Result := GetTempDir;
end;

class function TJes2CppFileNames.PathToReaperFiles: TFileName;
begin
  Result := PathToApplicationData + GsFilePartREAPER + DirectorySeparator;
end;

class function TJes2CppFileNames.PathToReaperData: TFileName;
begin
  Result := PathToReaperFiles + GsFilePartData + DirectorySeparator;
end;

class function TJes2CppFileNames.PathToReaperEffects: TFileName;
begin
  Result := PathToReaperFiles + GsFilePartEffects + DirectorySeparator;
end;

class function TJes2CppFileNames.PathToVstEffects: TFileName;
begin
  Result := PathToProgramFiles + GsFilePartVST + DirectorySeparator;
end;

class function TJes2CppFileNames.PathToTempBuild: TFileName;
begin
  Result := PathToTemp + GsJes2CppName + DirectorySeparator;
  if not ForceDirectory(Result) then
  begin
    raise Exception.Create(SMsgUnableToCreateOuputDirectory);
  end;
end;

class function TJes2CppFileNames.PathToSdkJes2Cpp: TFileName;
begin
  Result := ProgramDirectory + GsFilePartJes2Cpp + DirectorySeparator;
end;

class function TJes2CppFileNames.PathToSdkVeST: TFileName;
begin
  Result := PathToSdkJes2Cpp + GsFilePartVeST + DirectorySeparator;
end;

class function TJes2CppFileNames.FileName32x64(const AFileName: TFileName; const AUse64: Boolean): TFileName;
begin
  Result := AFileName;
  if AUse64 then
  begin
    Result := ExtractFilePath(Result) + 'x64' + DirectorySeparator + ExtractFileName(Result);
  end;
end;

class function TJes2CppFileNames.FileNameJes2CppJsFx: TFileName;
begin
  Result := PathToSdkJes2Cpp + GsFilePartJes2Cpp + GsFileExtJsFxInc;
end;

class function TJes2CppFileNames.FileNameBassLib(const AUse64: Boolean): TFileName;
begin
  Result := FileName32x64(PathToSdkJes2Cpp + GsFilePartBass + DirectorySeparator + GsFilePartBass + GsFileExtLib, AUse64);
end;

class function TJes2CppFileNames.FileNameSndFileLib(const AUse64: Boolean): TFileName;
begin
  Result := FileName32x64(PathToSdkJes2Cpp + GsFilePartLibSndFile + DirectorySeparator + GsFilePartLibSndFile1 + GsFileExtLib, AUse64);
end;

class function TJes2CppFileNames.FileNameVeSTLib32: TFileName;
begin
  Result := PathToSdkVeST + GsFilePartLib + GsFilePartVeST + GsFilePart32 + GsFileExtA;
end;

class function TJes2CppFileNames.FileNameVeSTLib64: TFileName;
begin
  Result := PathToSdkVeST + GsFilePartLib + GsFilePartVeST + GsFilePart64 + GsFileExtA;
end;

class function TJes2CppFileNames.FileNameOutputCpp: TFileName;
begin
  Result := PathToTempBuild + GsFilePartOutput + GsFileExtCpp;
end;

class function TJes2CppFileNames.FileNameOutputDll: TFileName;
begin
  Result := PathToTempBuild + GsFilePartOutput + GsFileExtDll;
end;

class function TJes2CppFileNames.FileNameUpX: TFileName;
begin
  Result := ProgramDirectory + GsFilePartUpX + DirectorySeparator + GsFilePartUpX + GsFileExtExe;
end;

class function TJes2CppFileNames.FileNameSaviHost(const AUse64: Boolean): TFileName;
begin
  Result := FileName32x64(ProgramDirectory + GsFilePartSaviHost + DirectorySeparator + GsFilePartSaviHost + GsFileExtExe, AUse64);
end;

class function TJes2CppFileNames.DecodeMeta(const AString: String): String;
const
  GsMetaHead = CharPercent;
  GsMetaFoot = CharPercent;
  GsMetaTemp = GsMetaHead + 'TEMP' + GsMetaFoot;
  GsMetaSystemRoot = GsMetaHead + 'SYSTEMROOT' + GsMetaFoot;
  GsMetaProfilePath = GsMetaHead + 'PROFILEPATH' + GsMetaFoot;
  GsMetaUserProfile = GsMetaHead + 'USERPROFILE' + GsMetaFoot;
  GsMetaProgramFiles = GsMetaHead + 'PROGRAMFILES' + GsMetaFoot;

  function LDecodeMeta(const AString, AMetaName, AValue: String): String; overload;
  begin
    Result := ReplaceText(AString, AMetaName, AValue);
  end;

begin
  Result := AString;
  Result := LDecodeMeta(Result, GsMetaTemp, ExcludeTrailingPathDelimiter(PathToTemp));
  Result := LDecodeMeta(Result, GsMetaSystemRoot, ExcludeTrailingPathDelimiter(PathToWindows));
  Result := LDecodeMeta(Result, GsMetaProfilePath, ExcludeTrailingPathDelimiter(PathToProfiles));
  Result := LDecodeMeta(Result, GsMetaUserProfile, ExcludeTrailingPathDelimiter(PathToProfile));
  Result := LDecodeMeta(Result, GsMetaProgramFiles, ExcludeTrailingPathDelimiter(PathToProgramFiles));
end;

end.

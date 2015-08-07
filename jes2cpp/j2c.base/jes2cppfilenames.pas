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
  GsFileExtDef = ExtensionSeparator + 'def';
  GsFileExtExe = ExtensionSeparator + 'exe';
  GsFileExtH = ExtensionSeparator + 'h';
  GsFileExtHtml = ExtensionSeparator + 'html';
  GsFileExtJsFx = ExtensionSeparator + 'jsfx';
  GsFileExtJsFxInc = GsFileExtJsFx + '-inc';
  GsFileExtLib = ExtensionSeparator + 'lib';

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
  GsFilePartJsFxInc = 'jsfx-inc';
  GsFilePartExports = 'exports';
  GsFilePartLibSndFile = 'libsndfile';
  GsFilePartLibSndFile1 = GsFilePartLibSndFile + '-1';
  GsFilePartLib = 'lib';
  GsFilePartUntitled = 'untitled';
  GsFilePartOutput = 'output';
  GsFilePartREAPER = 'REAPER';
  GsFilePartVeST = 'vest';
  GsFilePartVST = 'VST';
  GsFilePartUpX = 'upx';
  GsFilePartSaviHost = 'savihost';

type

  GUrls = object
  const
    GeepJeez = GsJes2CppWebsite;
    FatCow = 'http://www.fatcow.com/free-icons';
    REAPER = 'http://www.reaper.fm/';
    JSFXReference = 'http://www.reaper.fm/sdk/js/js.php';
    SAVIHost = 'http://www.hermannseib.com/english/savihost.htm';
  end;

  GFilePath = object
    class function ReaperFiles: TFileName;
    class function ReaperData: TFileName;
    class function ReaperEffects: TFileName;
    class function VstEffects: TFileName;
    class function TempBuild: TFileName;
    class function SdkJes2Cpp: TFileName;
    class function SdkJsFxInc: TFileName;
    class function SdkVeST: TFileName;
  end;

  GFileName = object
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
  Result := GPlatform.GetSpecialDir(CSIDL_APPDATA);
end;

function PathToProgramFiles: TFileName;
begin
  Result := GPlatform.GetSpecialDir(CSIDL_PROGRAM_FILES);
end;

function PathToWindows: TFileName;
begin
  Result := GPlatform.GetSpecialDir(CSIDL_WINDOWS);
end;

function PathToProfiles: TFileName;
begin
  Result := GPlatform.GetSpecialDir(CSIDL_PROFILES);
end;

function PathToProfile: TFileName;
begin
  Result := GPlatform.GetSpecialDir(CSIDL_PROFILE);
end;

function PathToTemp: TFileName;
begin
  Result := GetTempDir;
end;

class function GFilePath.ReaperFiles: TFileName;
begin
  Result := PathToApplicationData + GsFilePartREAPER + DirectorySeparator;
end;

class function GFilePath.ReaperData: TFileName;
begin
  Result := ReaperFiles + GsFilePartData + DirectorySeparator;
end;

class function GFilePath.ReaperEffects: TFileName;
begin
  Result := ReaperFiles + GsFilePartEffects + DirectorySeparator;
end;

class function GFilePath.VstEffects: TFileName;
begin
  Result := PathToProgramFiles + GsFilePartVST + DirectorySeparator;
end;

class function GFilePath.TempBuild: TFileName;
begin
  Result := PathToTemp + GsJes2CppName + DirectorySeparator;
  if not ForceDirectory(Result) then
  begin
    raise Exception.Create(SMsgUnableToCreateOuputDirectory);
  end;
end;

class function GFilePath.SdkJes2Cpp: TFileName;
begin
  Result := ProgramDirectory + GsFilePartJes2Cpp + DirectorySeparator;
end;

class function GFilePath.SdkJsFxInc: TFileName;
begin
  Result := ProgramDirectory + GsFilePartJsFxInc + DirectorySeparator;
end;

class function GFilePath.SdkVeST: TFileName;
begin
  Result := SdkJes2Cpp + GsFilePartVeST + DirectorySeparator;
end;

class function GFileName.FileName32x64(const AFileName: TFileName;
  const AUse64: Boolean): TFileName;
begin
  Result := AFileName;
  if AUse64 then
  begin
    Result := ExtractFilePath(Result) + 'x64' + DirectorySeparator + ExtractFileName(Result);
  end;
end;

class function GFileName.FileNameJes2CppJsFx: TFileName;
begin
  Result := GFilePath.SdkJes2Cpp + GsFilePartJes2Cpp + GsFileExtJsFxInc;
end;

class function GFileName.FileNameBassLib(const AUse64: Boolean): TFileName;
begin
  Result := FileName32x64(GFilePath.SdkJes2Cpp + GsFilePartBass + DirectorySeparator +
    GsFilePartBass + GsFileExtLib, AUse64);
end;

class function GFileName.FileNameSndFileLib(const AUse64: Boolean): TFileName;
begin
  Result := FileName32x64(GFilePath.SdkJes2Cpp + GsFilePartLibSndFile +
    DirectorySeparator + GsFilePartLibSndFile1 + GsFileExtLib, AUse64);
end;

class function GFileName.FileNameVeSTLib32: TFileName;
begin
  Result := GFilePath.SdkVeST + GsFilePartLib + GsFilePartVeST + GsFilePart32 + GsFileExtA;
end;

class function GFileName.FileNameVeSTLib64: TFileName;
begin
  Result := GFilePath.SdkVeST + GsFilePartLib + GsFilePartVeST + GsFilePart64 + GsFileExtA;
end;

class function GFileName.FileNameOutputCpp: TFileName;
begin
  Result := GFilePath.TempBuild + GsFilePartOutput + GsFileExtCpp;
end;

class function GFileName.FileNameOutputDll: TFileName;
begin
  Result := GFilePath.TempBuild + GsFilePartOutput + GsFileExtDll;
end;

class function GFileName.FileNameUpX: TFileName;
begin
  Result := ProgramDirectory + GsFilePartUpX + DirectorySeparator + GsFilePartUpX + GsFileExtExe;
end;

class function GFileName.FileNameSaviHost(const AUse64: Boolean): TFileName;
begin
  Result := FileName32x64(ProgramDirectory + GsFilePartSaviHost + DirectorySeparator +
    GsFilePartSaviHost + GsFileExtExe, AUse64);
end;

class function GFileName.DecodeMeta(const AString: String): String;
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
  Result := LDecodeMeta(Result, GsMetaProgramFiles, ExcludeTrailingPathDelimiter(
    PathToProgramFiles));
end;

end.

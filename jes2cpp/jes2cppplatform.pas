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

unit Jes2CppPlatform;

{$MODE DELPHI}

interface

uses
  StrUtils, SysUtils, WinDirs;

const
  SMetaHead = '%';
  SMetaFoot = '%';
  SMetaTemp = SMetaHead + 'TEMP' + SMetaFoot;
  SMetaSystemRoot = SMetaHead + 'SYSTEMROOT' + SMetaFoot;
  SMetaProfilePath = SMetaHead + 'PROFILEPATH' + SMetaFoot;
  SMetaUserProfile = SMetaHead + 'USERPROFILE' + SMetaFoot;
  SMetaProgramFiles = SMetaHead + 'PROGRAMFILES' + SMetaFoot;

function PathToApplicationData: TFileName;
function PathToProgramFiles: TFileName;

function DecodeMeta(const AString: String): String; overload;

implementation

function PathToTemp: TFileName;
begin
  Result := GetTempDir;
end;

function PathToApplicationData: TFileName;
begin
  Result := GetWindowsSpecialDir(CSIDL_APPDATA);
end;

function PathToProgramFiles: TFileName;
begin
  Result := GetWindowsSpecialDir(CSIDL_PROGRAM_FILES);
end;

function PathToWindows: TFileName;
begin
  Result := GetWindowsSpecialDir(CSIDL_WINDOWS);
end;

function PathToProfiles: TFileName;
begin
  Result := GetWindowsSpecialDir(CSIDL_PROFILES);
end;

function PathToProfile: TFileName;
begin
  Result := GetWindowsSpecialDir(CSIDL_PROFILE);
end;

function DecodeMeta(const AString, AMetaName, AValue: String): String; overload;
begin
  Result := ReplaceText(AString, AMetaName, AValue);
end;

function DecodeMeta(const AString: String): String; overload;
begin
  Result := AString;
  Result := DecodeMeta(Result, SMetaTemp, ExcludeTrailingPathDelimiter(PathToTemp));
  Result := DecodeMeta(Result, SMetaSystemRoot, ExcludeTrailingPathDelimiter(PathToWindows));
  Result := DecodeMeta(Result, SMetaProfilePath, ExcludeTrailingPathDelimiter(PathToProfiles));
  Result := DecodeMeta(Result, SMetaUserProfile, ExcludeTrailingPathDelimiter(PathToProfile));
  Result := DecodeMeta(Result, SMetaProgramFiles, ExcludeTrailingPathDelimiter(PathToProgramFiles));
end;

end.

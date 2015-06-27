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
  Forms, Graphics, LclType, SysUtils{$IFDEF WINDOWS}, WinDirs{$ENDIF};

const

  GiFormWidth = 800;
  GiFormHeight = 600;

const

  GsSystemExclamation = 'SYSTEMEXCLAMATION';
  GsSystemAsterix = 'SYSTEMASTERIX';

{$IFDEF WINDOWS}
  CSIDL_APPDATA = WinDirs.CSIDL_APPDATA;
  CSIDL_PROGRAM_FILES = WinDirs.CSIDL_PROGRAM_FILES;
  CSIDL_WINDOWS = WinDirs.CSIDL_WINDOWS;
  CSIDL_PROFILES = WinDirs.CSIDL_PROFILES;
  CSIDL_PROFILE = WinDirs.CSIDL_PROFILE;
{$ELSE}
  CSIDL_APPDATA = 1;
  CSIDL_PROGRAM_FILES = 2;
  CSIDL_WINDOWS = 3;
  CSIDL_PROFILES = 4;
  CSIDL_PROFILE = 5;

{$ENDIF}

type

  NsPlatform = object
    type TProcLoadFromFile = procedure(const AFileName: TFileName);
    class function IsWindows9x: Boolean;
    class function GetSpecialDir(const AIndex: Integer): TFileName;
    class procedure SingleInstanceInit(const AMainWindow: HWND; const AWindowCaption: String; const ALoader: TProcLoadFromFile);
    class procedure ScrollingWinControlPrepare(const AScrollingWinControl: TScrollingWinControl);
  end;

implementation

{$IF DEFINED(WINDOWS)}
uses MMSystem, Windows;

class function NsPlatform.GetSpecialDir(const AIndex: Integer): TFileName;
begin
  Result := GetWindowsSpecialDir(AIndex);
end;

procedure PlaySound(const AName: String);
begin
  MMSystem.PlaySound(PChar(AName), 0, SND_ASYNC);
end;

var
  GPrevWndProc: WNDPROC;
  GpLoader: NsPlatform.TProcLoadFromFile;

function J2C_WindowCallback(AHwnd: HWND; AMessage: UINT; AWParam: WParam; ALParam: LParam): LRESULT; stdcall;
var
  LCopyDataStruct: TCopyDataStruct;
  LFileName: TFileName;
begin
  if AMessage = WM_COPYDATA then
  begin
    LCopyDataStruct := {%H-}PCopyDataStruct(ALParam)^;
    if LCopyDataStruct.dwData = 0 then
    begin
      LFileName := Trim(PChar(LCopyDataStruct.lpData));
      if LFileName <> EmptyStr then
      begin
        Application.Restore;
        if Assigned(GpLoader) then
        begin
          GpLoader(LFileName);
        end;
      end;
    end;
    Result := S_OK;
  end else begin
    Result := CallWindowProc(GPrevWndProc, AHwnd, AMessage, AWParam, ALParam);
  end;
end;

function J2C_WindowSendMessage(const AWindow: HWND; const AWindowCaption, AMessage: String): Boolean;
var
  LHandle: HWND;
  LCopyDataStruct: TCopyDataStruct;
begin
  LHandle := FindWindow(nil, PChar(AWindowCaption));
  Result := LHandle <> 0;
  if Result then
  begin
    LCopyDataStruct.dwData := 0;
    LCopyDataStruct.cbData := Length(AMessage) + 1;
    LCopyDataStruct.lpData := PChar(AMessage);
    SendMessage(LHandle, WM_COPYDATA, WPARAM(AWindow), {%H-}LPARAM(@LCopyDataStruct));
  end;
end;

function J2C_WindowSendParams(const AWindow: HWND; const AWindowCaption: String): Boolean;
begin
  if ParamCount > 0 then
  begin
    Result := J2C_WindowSendMessage(AWindow, AWindowCaption, ParamStr(1));
  end else begin
    Result := J2C_WindowSendMessage(AWindow, AWindowCaption, EmptyStr);
  end;
end;

class procedure NsPlatform.SingleInstanceInit(const AMainWindow: HWND; const AWindowCaption: String; const ALoader: TProcLoadFromFile);
begin
  if J2C_WindowSendParams(AMainWindow, AWindowCaption) then
  begin
    Halt;
  end;
  Application.MainForm.Caption := AWindowCaption;
  GpLoader := ALoader;
  GPrevWndProc := {%H-}Windows.WNDPROC(SetWindowLongPtr(AMainWindow, GWL_WNDPROC, {%H-}PtrInt(@J2C_WindowCallback)));
end;

{$ELSEIF DEFINED(LINUX)}
class procedure NsPlatform.SingleInstanceInit(const AMainWindow: HWND; const AWindowCaption: String; const ALoader: TProcLoadFromFile);
begin
  Application.MainForm.Caption := AWindowCaption;
end;

class function NsPlatform.GetSpecialDir(const AIndex: Integer): TFileName;
begin
  Result := EmptyStr;
  case AIndex of
    CSIDL_APPDATA: begin
    end;
    CSIDL_PROGRAM_FILES: begin
    end;
    CSIDL_WINDOWS: begin
    end;
    CSIDL_PROFILES: begin
    end;
    CSIDL_PROFILE: begin
    end;
  end;
end;

{$ELSE}
{$ERROR}
{$ENDIF}

class procedure NsPlatform.ScrollingWinControlPrepare(const AScrollingWinControl: TScrollingWinControl);
begin
{$IFDEF WINDOWS}
  AScrollingWinControl.Font.Quality := fqProof;
  AScrollingWinControl.Font.Size := 10;
  AScrollingWinControl.Font.Name := 'verdana';
{$ENDIF}
end;

class function NsPlatform.IsWindows9x: Boolean;
begin
{$IFDEF WINDOWS}
  Result := Win32Platform = 1;
{$ELSE}
  Result := False;
{$ENDIF}
end;

end.

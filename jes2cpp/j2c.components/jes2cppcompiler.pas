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

unit Jes2CppCompiler;

{$MODE DELPHI}

interface

uses
  Classes, Jes2CppConstants, Jes2CppFileNames, Jes2CppProcess, Jes2CppTranslate, SysUtils;

type

  TJes2CppCompilerArchitecture = (pa32bit, pa64bit);
  TJes2CppCompilerPrecision = (ptSingle, ptDouble, ptLongDouble);
  TJes2CppCompilerPlugin = (ptVST, ptLV1, ptLV2, ptDX, ptAU, ptVAMP);
  TJes2CppCompilerOption = (coUseLibBass, coUseLibSndFile, coUseFastMath, coUseInline, coUseCompression);
  TJes2CppCompilerOptions = set of TJes2CppCompilerOption;

  CJes2CppCompiler = class(CJes2CppProcess)
  strict private
    FTypeArchitecture: TJes2CppCompilerArchitecture;
    FTypePrecision: TJes2CppCompilerPrecision;
    FTypePlugin: TJes2CppCompilerPlugin;
    FCompilerOptions: TJes2CppCompilerOptions;
  strict private
    procedure AddOptionFlags;
    procedure AddInputFiles(const AFileName: TFileName);
    procedure PrepareParameters(const AFilenameSrc, AFilenameDst: TFileName);
  protected
    procedure DoOnLine(const AString: String); override;
    procedure Compile(const AExecutable, AFilenameSrc, AFilenameDst: TFileName); overload;
  public
    procedure SetCompilerOption(const AOption: TJes2CppCompilerOption; const AState: Boolean);
    function Compile(const AExecutable, AFileNameSrc: TFileName): TFileName; overload;
    function Compile(const AExecutable: TFileName; const AStrings: TStrings): TFileName; overload;
  public
    property CompilerOptions: TJes2CppCompilerOptions read FCompilerOptions write FCompilerOptions;
    property TypeArchitecture: TJes2CppCompilerArchitecture read FTypeArchitecture write FTypeArchitecture;
    property TypePrecision: TJes2CppCompilerPrecision read FTypePrecision write FTypePrecision;
    property TypePlugin: TJes2CppCompilerPlugin read FTypePlugin write FTypePlugin;
  end;

function TypePrecisionAsString(const AType: TJes2CppCompilerPrecision): String;
function TypeArchitectureAsString(const AType: TJes2CppCompilerArchitecture): String;
function TypePluginAsString(const AType: TJes2CppCompilerPlugin): String;

function FileNameOutputDll(const AFileName: TFileName; const AProcessor: TJes2CppCompilerArchitecture;
  const APrecision: TJes2CppCompilerPrecision; const APlugin: TJes2CppCompilerPlugin): TFileName;

implementation

function TypePrecisionAsString(const AType: TJes2CppCompilerPrecision): String;
begin
  case AType of
    ptSingle: begin
      Result := 'f32';
    end;
    ptDouble: begin
      Result := 'f64';
    end;
  end;
end;

function TypeArchitectureAsString(const AType: TJes2CppCompilerArchitecture): String;
begin
  case AType of
    pa32bit: begin
      Result := 'm32';
    end;
    pa64bit: begin
      Result := 'm64';
    end;
  end;
end;

function TypePluginAsString(const AType: TJes2CppCompilerPlugin): String;
begin
  // TODO: Complete these.
  case AType of
    ptVST: begin
      Result := 'vst';
    end;
    ptLV1: begin
      Result := 'lv1';
    end;
  end;
end;

function FileNameOutputDll(const AFileName: TFileName; const AProcessor: TJes2CppCompilerArchitecture;
  const APrecision: TJes2CppCompilerPrecision; const APlugin: TJes2CppCompilerPlugin): TFileName;
begin
  Result := ChangeFileExt(AFileName, EmptyStr);
  Result += ExtensionSeparator + TypeArchitectureAsString(AProcessor) + ExtensionSeparator +
    TypePrecisionAsString(APrecision) + ExtensionSeparator + TypePluginAsString(APlugin) + GsFileExtDll;
end;

procedure CJes2CppCompiler.SetCompilerOption(const AOption: TJes2CppCompilerOption; const AState: Boolean);
begin
  if AState then
  begin
    FCompilerOptions += [AOption];
  end else begin
    FCompilerOptions -= [AOption];
  end;
end;

procedure CJes2CppCompiler.AddOptionFlags;
begin
  AddOption('std=', 'gnu++11');
  AddOption('v');
  AddOption('s');
  AddOption('shared');
  AddOption('W', 'all');
  AddOption('W', 'no-reorder');
  AddOption('W', 'no-unused-value');
  AddOption('W', 'no-unused-variable');
  AddOption('W', 'no-unused-but-set-variable');
  AddOption('O', '2');
  //AddOption('mmmx'); // Does this even do anything?
  AddOption('f', 'PIC');
  AddOption('f', 'message-length=0');
  AddOption('f', 'no-exceptions');
  AddOption('f', 'permissive');
  if coUseInline in FCompilerOptions then
  begin
    AddOption('f', 'inline-functions');
  end;
  if coUseFastMath in FCompilerOptions then
  begin
    AddOption('f', 'fast-math');
  end;
  case FTypeArchitecture of
    pa32bit: begin
      AddOption('m', '32');
    end;
    pa64bit: begin
      AddOption('m', '64');
    end;
  end;
end;

procedure CJes2CppCompiler.AddInputFiles(const AFileName: TFileName);
begin
  AddInputFile(NSFileNames.PathToSdkJes2Cpp + GsFilePartJes2Cpp + GsFileExtCpp);
  AddInputFile(AFileName);
  if coUseLibBass in FCompilerOptions then
  begin
    AddInputFile(NSFileNames.FileNameBassLib(FTypeArchitecture = pa64bit));
  end;
  if coUseLibSndFile in FCompilerOptions then
  begin
    AddInputFile(NSFileNames.FileNameSndFileLib(FTypeArchitecture = pa64bit));
  end;
  case FTypePlugin of
    ptVST: begin
      case FTypeArchitecture of
        pa32bit: begin
          AddInputFile(NSFileNames.FileNameVeSTLib32);//, 'fab1c842d13a2f5842174ad4edea348cb4c37adb');
        end;
        pa64bit: begin
          AddInputFile(NSFileNames.FileNameVeSTLib64);
        end;
      end;
      AddInputFile(NSFileNames.PathToSdkJes2Cpp + GsFilePartExports + GsFileExtDef);
    end;
    ptLV1: begin
      AddInputFile(NSFileNames.PathToSdkVeST + GsFilePartVeST + GsFileExtCpp);
    end;
  end;
end;

procedure CJes2CppCompiler.DoOnLine(const AString: String);
begin
  LogMessage(AString);
end;

procedure CJes2CppCompiler.PrepareParameters(const AFilenameSrc, AFilenameDst: TFileName);
begin
  CurrentDirectory := ExtractFilePath(AFilenameSrc);
  Parameters.Clear;

  AddOptionFlags;

  case FTypePlugin of
    ptVST: begin
      AddDefine(GsCppVestVst, True);
    end;
    ptLV1: begin
      AddDefine(GsCppVestLv1, True);
    end;
    ptLV2: begin
      AddDefine(GsCppVestLv2, True);
    end;
    ptDX: begin
      AddDefine(GsCppVestDx, True);
    end;
    ptAU: begin
      AddDefine(GsCppVestAu, True);
    end;
  end;
  if coUseInline in FCompilerOptions then
  begin
    AddDefine(GsCppJes2CppInline, GsCppInline);
  end else begin
    AddDefine(GsCppJes2CppInline, EmptyStr);
  end;
  case FTypePrecision of
    ptSingle: begin
      AddDefine(GsCppWdlFftRealSize, '4');
    end;
    ptDouble: begin
      AddDefine(GsCppWdlFftRealSize, '8');
    end;
  end;
  if coUseLibBass in FCompilerOptions then
  begin
    AddDefine(GsCppJes2CppBass, True);
  end;
  if coUseLibSndFile in FCompilerOptions then
  begin
    AddDefine(GsCppJes2CppSndFile, True);
  end;
  AddIncludePath(NSFileNames.PathToSdkJes2Cpp);
  AddIncludePath(NSFileNames.PathToSdkVeST);
  AddInputFiles(AFilenameSrc);
{$IFDEF WINDOWS}
  AddLibraries(['user32', 'kernel32', 'ole32', 'oleaut32', 'uuid', 'comdlg32', 'gdi32', 'gdiplus']);
{$ENDIF}
  AddOutputFile(AFilenameDst);
end;

procedure CJes2CppCompiler.Compile(const AExecutable, AFilenameSrc, AFilenameDst: TFileName);
begin
  LogMessage(SMsgStarted);
  try
    if FileExists(AFilenameDst) and not SysUtils.DeleteFile(AFilenameDst) then
    begin
      LogException(SMsgUnableToDeleteOutputFile);
    end;
    Executable := AExecutable;
    PrepareParameters(AFilenameSrc, AFilenameDst);
    try
      if ExecuteAndWait = GiExitStatusAbort then
      begin
        LogException(SMsgCompilationAborted);
      end;
      if (coUseCompression in FCompilerOptions) and FileExists(AFilenameDst) then
      begin
        LogMessage(SMsgCompressing + CharSpace + QuotedStr(AFilenameDst) + CharDot);
        Executable := NSFileNames.FileNameUpX;
        Parameters.Clear;
        AddInputFile(AFilenameDst);
        ExecuteAndWait;
      end;
    except
      on LException: Exception do
      begin
        if GetLastOSError = 2 then
        begin
          LogException(Format(SMsgUnableToFindSelectedCompiler1, [Executable]));
        end else begin
          LogException(Format(SMsgCompilerTerminatedBecause1, [LException.Message]));
        end;
      end;
    end;
    if not FileExists(AFilenameDst) then
    begin
      LogException(SMsgCompilationFailed);
    end;
  finally
    LogMessage(SMsgFinished);
    LogMessage(EmptyStr);
  end;
end;

function CJes2CppCompiler.Compile(const AExecutable, AFileNameSrc: TFileName): TFileName;
begin
  Result := NSFileNames.FileNameOutputDll;
  Compile(AExecutable, AFileNameSrc, Result);
end;

function CJes2CppCompiler.Compile(const AExecutable: TFileName; const AStrings: TStrings): TFileName;
begin
  Result := NSFileNames.FileNameOutputCpp;
  AStrings.SaveToFile(Result);
  Result := Compile(AExecutable, Result);
end;

end.

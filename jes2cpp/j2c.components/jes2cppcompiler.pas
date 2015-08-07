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
  Classes, Jes2CppConstants, Jes2CppFileNames, Jes2CppPlatform, Jes2CppProcess,
  Jes2CppTranslate, SysUtils;

type

  CJes2CppCompiler = class(CJes2CppProcess)
  public
    type TOptimizeLevel = (colNone, colO, colO2, colO3, colOs);
    type TArchitecture = (ca32bit, ca64bit);
    type TFloatPrecision = (cfpSingle, cfpDouble, cfpLongDouble);
    type TPluginType = (cptVST, cptLV1, cptLV2, cptDX, cptAU, cptVAMP);
    type TCompilerOption = (coUseLibBass, coUseLibSndFile, coUseFastMath,
      coUseInline, coUseCompression);
    type TCompilerOptions = set of TCompilerOption;
  private // Here to make source formater happy.
  strict private
    FOptimizeLevel: TOptimizeLevel;
    FArchitecture: TArchitecture;
    FPrecision: TFloatPrecision;
    FPluginType: TPluginType;
    FCompilerOptions: TCompilerOptions;
  strict private
    procedure AddOptionFlags;
    procedure AddInputFiles(const AFileName: TFileName);
    procedure PrepareParameters(const AFilenameSrc, AFilenameDst: TFileName);
  protected
    procedure DoOnLine(const AString: String); override;
    procedure Compile(const AExecutable, AFilenameSrc, AFilenameDst: TFileName); overload;
  public
    procedure SetCompilerOption(const AOption: TCompilerOption; const AState: Boolean);
    function Compile(const AExecutable, AFileNameSrc: TFileName): TFileName; overload;
    function Compile(const AExecutable: TFileName; const AStrings: TStrings): TFileName; overload;
  public
    class function FileNameOutputDll(const AFileName: TFileName;
      const AProcessor: TArchitecture; const APrecision: TFloatPrecision;
      const APlugin: TPluginType): TFileName;
    class function TypePrecisionAsString(const AType: TFloatPrecision): String;
    class function TypeArchitectureAsString(const AType: TArchitecture): String;
    class function TypePluginAsString(const AType: TPluginType): String;
  public
    property CompilerOptions: TCompilerOptions read FCompilerOptions write FCompilerOptions;
    property Architecture: TArchitecture read FArchitecture write FArchitecture;
    property Precision: TFloatPrecision read FPrecision write FPrecision;
    property PluginType: TPluginType read FPluginType write FPluginType;
    property OptimizeLevel: TOptimizeLevel read FOptimizeLevel write FOptimizeLevel;
  end;

implementation

class function CJes2CppCompiler.TypePrecisionAsString(const AType: TFloatPrecision): String;
begin
  case AType of
    cfpSingle: begin
      Result := 'f32';
    end;
    cfpDouble: begin
      Result := 'f64';
    end;
  end;
end;

class function CJes2CppCompiler.TypeArchitectureAsString(const AType: TArchitecture): String;
begin
  case AType of
    ca32bit: begin
      Result := 'm32';
    end;
    ca64bit: begin
      Result := 'm64';
    end;
  end;
end;

class function CJes2CppCompiler.TypePluginAsString(const AType: TPluginType): String;
begin
  // TODO: Complete these.
  case AType of
    cptVST: begin
      Result := 'vst';
    end;
    cptLV1: begin
      Result := 'lv1';
    end;
  end;
end;

class function CJes2CppCompiler.FileNameOutputDll(const AFileName: TFileName;
  const AProcessor: TArchitecture; const APrecision: TFloatPrecision;
  const APlugin: TPluginType): TFileName;
begin
  Result := ChangeFileExt(AFileName, EmptyStr);
  Result += ExtensionSeparator + TypeArchitectureAsString(AProcessor) +
    ExtensionSeparator + TypePrecisionAsString(APrecision) + ExtensionSeparator +
    TypePluginAsString(APlugin) + GsFileExtDll;
end;

procedure CJes2CppCompiler.SetCompilerOption(const AOption: TCompilerOption;
  const AState: Boolean);
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
  AddOptionWarning('all');
  AddOptionWarning('no-reorder');
  AddOptionWarning('no-unused-value');
  AddOptionWarning('no-unused-variable');
  AddOptionWarning('no-unused-but-set-variable');
  //AddOption('mmmx'); // Does this even do anything?
  AddOptionF('PIC');
  AddOptionF('message-length=0');
  AddOptionF('no-exceptions');
  AddOptionF('permissive');
  if coUseInline in FCompilerOptions then
  begin
    AddOptionF('inline-functions');
  end;
  if coUseFastMath in FCompilerOptions then
  begin
    AddOptionF('fast-math');
  end;
  case FOptimizeLevel of
    colNone: begin
    end;
    colO: begin
      AddOption('O');
    end;
    colO2: begin
      AddOption('O', '2');
    end;
    colO3: begin
      AddOption('O', '3');
    end;
    colOs: begin
      AddOption('O', 's');
    end;
  end;
  case FArchitecture of
    ca32bit: begin
      AddOption('m', '32');
    end;
    ca64bit: begin
      AddOption('m', '64');
    end;
  end;
end;

procedure CJes2CppCompiler.AddInputFiles(const AFileName: TFileName);
begin
  AddInputFile(GFilePath.SdkJes2Cpp + GsFilePartJes2Cpp + GsFileExtCpp);
  AddInputFile(AFileName);
  if coUseLibBass in FCompilerOptions then
  begin
    AddInputFile(GFileName.FileNameBassLib(FArchitecture = ca64bit));
  end;
  if coUseLibSndFile in FCompilerOptions then
  begin
    AddInputFile(GFileName.FileNameSndFileLib(FArchitecture = ca64bit));
  end;
  case FPluginType of
    cptVST: begin
      case FArchitecture of
        ca32bit: begin
          AddInputFile(GFileName.FileNameVeSTLib32);
          //, 'fab1c842d13a2f5842174ad4edea348cb4c37adb');
        end;
        ca64bit: begin
          AddInputFile(GFileName.FileNameVeSTLib64);
        end;
      end;
      AddInputFile(GFilePath.SdkJes2Cpp + GsFilePartExports + GsFileExtDef);
    end;
    cptLV1: begin
      AddInputFile(GFilePath.SdkVeST + GsFilePartVeST + GsFileExtCpp);
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

  case FPluginType of
    cptVST: begin
      AddDefine(GsCppVestVst, True);
    end;
    cptLV1: begin
      AddDefine(GsCppVestLv1, True);
    end;
    cptLV2: begin
      AddDefine(GsCppVestLv2, True);
    end;
    cptDX: begin
      AddDefine(GsCppVestDx, True);
    end;
    cptAU: begin
      AddDefine(GsCppVestAu, True);
    end;
  end;
  if coUseInline in FCompilerOptions then
  begin
    AddDefine(GsCppJes2CppInline, GsCppInline);
  end else begin
    AddDefine(GsCppJes2CppInline, EmptyStr);
  end;
  case FPrecision of
    cfpSingle: begin
      AddDefine(GsCppWdlFftRealSize, '4');
    end;
    cfpDouble: begin
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
  AddIncludePath(GFilePath.SdkJes2Cpp);
  AddIncludePath(GFilePath.SdkVeST);
  AddInputFiles(AFilenameSrc);
  if GPlatform.IsWindows then
  begin
    AddLibraries(['user32', 'kernel32', 'ole32', 'oleaut32', 'uuid', 'comdlg32',
      'gdi32', 'gdiplus']);
  end;
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
        Executable := GFileName.FileNameUpX;
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
  Result := GFileName.FileNameOutputDll;
  Compile(AExecutable, AFileNameSrc, Result);
end;

function CJes2CppCompiler.Compile(const AExecutable: TFileName;
  const AStrings: TStrings): TFileName;
begin
  Result := GFileName.FileNameOutputCpp;
  AStrings.SaveToFile(Result);
  Result := Compile(AExecutable, Result);
end;

end.

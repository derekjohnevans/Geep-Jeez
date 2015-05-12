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
  Classes, Jes2CppConstants, Jes2CppFileNames, Jes2CppProcess, SysUtils, Windows;

const

  Jes2CppCompilerAbort = 12345;

  SExeGpp = 'g++';
  SExeTdmGcc32 = 'mingw32-g++';
  SExeTdmGcc64 = 'x86_64-w64-mingw32-g++';

type

  TJes2CppCompilerType = (ctNone, ctTDMGCC64, ctTDMGCC32, ctGpp);
  TJes2CppCompilerProcessor = (ctp32bit, ctp64bit);
  TJes2CppCompilerPrecision = (ctrSingle, ctrDouble);

  CJes2CppCompiler = class(CJes2CppProcess)
  strict private
    FTypeProcessor: TJes2CppCompilerProcessor;
    FTypeCompiler: TJes2CppCompilerType;
    FTypePrecision: TJes2CppCompilerPrecision;
    FIsNoBass: Boolean;
  strict private
    procedure AddOptionFlags;
    procedure AddInputFiles(const AFileName: TFileName);
    procedure PrepareParameters(const AFilenameSrc, AFilenameDst: TFileName);
  protected
    procedure DoOnLine(const AString: String); override;
    procedure LogMessage(const AMessage: String); virtual; overload;
    procedure LogMessage(const AType, AMessage: String); overload;
    procedure LogException(const AMessage: String);
    procedure Compile(const AFilenameSrc, AFilenameDst: TFileName); overload;
  public
    function Compile(const AFileName: TFileName): TFileName; overload;
    function Compile(const AStrings: TStrings): TFileName; overload;
  public
    property IsNoBass: Boolean read FIsNoBass write FIsNoBass;
    property TypeCompiler: TJes2CppCompilerType read FTypeCompiler write FTypeCompiler;
    property TypeProcessor: TJes2CppCompilerProcessor read FTypeProcessor write FTypeProcessor;
    property TypePrecision: TJes2CppCompilerPrecision read FTypePrecision write FTypePrecision;
  end;

function CompilerOutputFileName(const AFileName: TFileName; const AProcessor: TJes2CppCompilerProcessor): TFileName;

implementation

function CompilerOutputFileName(const AFileName: TFileName; const AProcessor: TJes2CppCompilerProcessor): TFileName;
begin
  Result := ChangeFileExt(AFileName, EmptyStr);
  case AProcessor of
    ctp32bit: begin
      Result += '32';
    end;
    ctp64bit: begin
      Result += '64';
    end;
  end;
  Result += SFileExtDll;
end;

procedure CJes2CppCompiler.AddOptionFlags;
begin
  //AddOption('pipe');
  AddOption('std=gnu++11');
  AddOption('v');
  AddOption('s');
  AddOption('shared');
  AddOption('W', 'all');
  AddOption('W', 'no-reorder');
  AddOption('O', '2');
  AddOption('mmmx');
  AddOption('f', 'PIC');
  AddOption('f', 'message-length=0');
  AddOption('f', 'inline-functions');
  AddOption('f', 'no-exceptions');
  AddOption('f', 'permissive');
  // DONT USE FAST MATHS! IT CAUSED MY REVERB TO CRASH
  //AddOption('f', 'fast-math');
  AddOption('W', 'reorder');
  case FTypeProcessor of
    ctp32bit: begin
      AddOption('m', '32');
    end;
    ctp64bit: begin
      AddOption('m', '64');
    end;
  end;
end;

procedure CJes2CppCompiler.AddInputFiles(const AFileName: TFileName);
begin
  AddInputFile(PathToGeep + 'geep.cpp');
  AddInputFile(PathToJes2Cpp + 'jes2cpp.cpp');
  AddInputFile(AFileName);
  AddInputFile(FileNameBassLib);
  case FTypeProcessor of
    ctp32bit: begin
      AddInputFile(FileNameVeSTLib32);
    end;
    ctp64bit: begin
      AddInputFile(FileNameVeSTLib64);
    end;
  end;
end;

procedure CJes2CppCompiler.DoOnLine(const AString: String);
begin
  LogMessage(AString);
end;

procedure CJes2CppCompiler.LogMessage(const AMessage: String);
begin
end;

procedure CJes2CppCompiler.LogMessage(const AType, AMessage: String);
begin
  LogMessage('[' + AType + '] ' + AMessage);
end;

procedure CJes2CppCompiler.LogException(const AMessage: String);
begin
  LogMessage(SMsgTypeException, AMessage);
  raise Exception.Create(AMessage);
end;

procedure CJes2CppCompiler.PrepareParameters(const AFilenameSrc, AFilenameDst: TFileName);
begin
  CurrentDirectory := ExtractFilePath(AFilenameSrc);
  Parameters.Clear;

  case FTypeCompiler of
    ctNone: begin
      LogException(SMsgCompilerNotSelected);
    end;
    ctTDMGCC64: begin
      Executable := SExeTdmGcc64;
    end;
    ctTDMGCC32: begin
      Executable := SExeTdmGcc32;
    end;
    ctGpp: begin
      Executable := SExeGpp;
    end;
  end;
  AddOptionFlags;
  case FTypePrecision of
    ctrSingle: begin
      AddDefine('EEL_F', 'float');
      AddDefine('WDL_FFT_REALSIZE', '4');
    end;
    ctrDouble: begin
      AddDefine('EEL_F', 'double');
      AddDefine('WDL_FFT_REALSIZE', '8');
    end;
  end;
  if FIsNoBass then
  begin
    AddDefine(S_JES2CPP_NO_BASS_, '1');
  end;
  AddIncludePath(PathToGeep);
  AddIncludePath(PathToJes2Cpp);
  AddIncludePath(PathToVeSTSdk);
  AddIncludePath(PathToWdlSdk);
  AddIncludePath(PathToBass);
  AddInputFiles(AFilenameSrc);
  AddLibraries(['user32', 'kernel32', 'ole32', 'oleaut32', 'uuid', 'comdlg32', 'gdi32', 'gdiplus']);
  AddOutputFile(AFilenameDst);
end;

procedure CJes2CppCompiler.Compile(const AFilenameSrc, AFilenameDst: TFileName);
begin
  LogMessage(SMsgStarted);
  try
    if FileExists(AFilenameDst) and not SysUtils.DeleteFile(AFilenameDst) then
    begin
      LogException(SMsgUnableToDeleteOutputFile);
    end;
    PrepareParameters(AFilenameSrc, AFilenameDst);
    try
      if ExecuteAndWait = Jes2CppCompilerAbort then
      begin
        LogException(SMsgCompilationAborted);
      end;
    except
      on LException: Exception do
      begin
        if GetLastError = 2 then
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

function CJes2CppCompiler.Compile(const AFileName: TFileName): TFileName;
begin
  Result := CompilerOutputFileName(AFileName, FTypeProcessor);
  Compile(AFileName, Result);
end;

function CJes2CppCompiler.Compile(const AStrings: TStrings): TFileName;
begin
  Result := FileNameOutputCpp;
  AStrings.SaveToFile(Result);
  Result := Compile(Result);
end;

end.

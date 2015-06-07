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

unit Jes2CppProcess;

{$MODE DELPHI}

interface

uses
  Classes, Forms, Jes2CppConstants, Jes2CppMessageLog, Process, SHA1, StrUtils, SysUtils;

const

  GiExitStatusAbort = 12345;

type

  CJes2CppProcess = class(TProcess)
  protected
    procedure LogMessage(const AMessage: String); virtual; overload;
    procedure LogMessage(const AType, AMessage: String); overload;
    procedure LogException(const AMessage: String);
  protected
    procedure AddDefine(const AName, AValue: String); overload;
    procedure AddDefine(const AName: String; const AValue: Boolean); overload;
    procedure AddOption(const AName: String); overload;
    procedure AddOption(const AName: String; const AValue: String); overload;
    procedure AddInputFile(const AFileName: TFileName); overload;
    procedure AddInputFile(const AFileName: TFileName; const ASHA1String: String); overload;
    procedure AddOutputFile(const AFileName: TFileName);
    procedure AddIncludePath(const APath: String);
    procedure AddLibrary(const AName: String);
    procedure AddLibraries(const ANames: array of String);
  protected
    procedure DoOnLine(const AString: String); virtual; abstract;
  public
    constructor Create(AOwner: TComponent); override;
  public
    function ExecuteAndWait: Integer;
  end;

implementation

function StreamReadChunk(const AStream: TStream): String;
var
  LBuffer: array[byte] of Char;
begin
  LBuffer[0] := #0;
  SetString(Result, LBuffer, AStream.Read(LBuffer, SizeOf(LBuffer)));
end;

constructor CJes2CppProcess.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Options := Options + [poUsePipes, poStderrToOutPut];
  PipeBufferSize := 1024;
  ShowWindow := swoHIDE;
end;

procedure CJes2CppProcess.AddOption(const AName: String);
begin
  Parameters.Add(CharMinusSign + AName);
end;

procedure CJes2CppProcess.AddOption(const AName, AValue: String);
begin
  Parameters.Add(CharMinusSign + AName + AValue);
end;

procedure CJes2CppProcess.LogMessage(const AMessage: String);
begin
end;

procedure CJes2CppProcess.LogMessage(const AType, AMessage: String);
begin
  LogMessage(J2C_StringLogMessage(AType, AMessage));
end;

procedure CJes2CppProcess.LogException(const AMessage: String);
begin
  LogMessage(SMsgTypeException, AMessage);
  raise Exception.Create(AMessage);
end;

procedure CJes2CppProcess.AddDefine(const AName, AValue: String);
begin
  AddOption('D', Format('%s=%s', [AName, AValue]));
end;

procedure CJes2CppProcess.AddDefine(const AName: String; const AValue: Boolean);
begin
  AddDefine(AName, IfThen(AValue, '1', '0'));
end;

procedure CJes2CppProcess.AddInputFile(const AFileName: TFileName);
begin
  Parameters.Add(AFileName);
end;

procedure CJes2CppProcess.AddInputFile(const AFileName: TFileName; const ASHA1String: String);
var
  LIndex: Integer;
  A, B: TSHA1Digest;
begin
  A := SHA1File(AFileName);
  for LIndex := 0 to 19 do
  begin
    B[LIndex] := StrToInt('$' + Copy(ASHA1String, LIndex * 2 + 1, 2));
  end;
  if not SHA1Match(A, B) then
  begin
    LogException(Format('Invalid checksum for %s.' + LineEnding + 'SHA1=%s', [QuotedStr(AFileName), QuotedStr(SHA1Print(A))]));
  end;
  AddInputFile(AFileName);
end;

procedure CJes2CppProcess.AddOutputFile(const AFileName: TFileName);
begin
  AddOption('o');
  Parameters.Add(AFileName);
end;

procedure CJes2CppProcess.AddIncludePath(const APath: String);
begin
  AddOption('I', ReplaceStr(APath, '\', '\\'));
end;

procedure CJes2CppProcess.AddLibrary(const AName: String);
begin
  AddOption('l', AName);
end;

procedure CJes2CppProcess.AddLibraries(const ANames: array of String);
var
  LName: String;
begin
  for LName in ANames do
  begin
    AddLibrary(LName);
  end;
end;

function CJes2CppProcess.ExecuteAndWait: Integer;
var
  LString: String;
  LCount, LPos: Integer;
begin
  Execute;
  LCount := 0;
  LString := EmptyStr;
  while Running do
  begin
    while Running and (Output.NumBytesAvailable = 0) do
    begin
      Sleep(400);
      Inc(LCount);
      if (LCount and 3) = 0 then
      begin
        Application.ProcessMessages;
      end;
    end;
    LString += StreamReadChunk(Output);
    repeat
      LPos := Pos(#10, LString);
      if LPos = 0 then
      begin
        Break;
      end;
      DoOnLine(Trim(Copy(LString, 1, LPos - 1)));
      LString := TrimLeft(Copy(LString, LPos + 1, MaxInt));
    until False;
  end;
  if ExitStatus <> GiExitStatusAbort then
  begin
    repeat
      LString += StreamReadChunk(Output);
      repeat
        LPos := Pos(#10, LString);
        if LPos = 0 then
        begin
          Break;
        end;
        DoOnLine(Trim(Copy(LString, 1, LPos - 1)));
        LString := TrimLeft(Copy(LString, LPos + 1, MaxInt));
      until False;
    until Output.NumBytesAvailable = 0;
  end;
  DoOnLine(LString);
  Result := ExitStatus;
end;

end.

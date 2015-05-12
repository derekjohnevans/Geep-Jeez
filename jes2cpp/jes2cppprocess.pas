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
  Classes, Forms, Process, StrUtils, SysUtils;

type

  CJes2CppProcess = class(TProcess)
  protected
    procedure AddDefine(const AName, AValue: String);
    procedure AddOption(const AName: String; const AValue: String = '');
    procedure AddInputFile(const AFileName: TFileName);
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

function EncodeParam(const S: String): String;
begin
  Result := '"' + ReplaceStr(S, '\', '\\') + '"';
end;

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

procedure CJes2CppProcess.AddDefine(const AName, AValue: String);
begin
  Parameters.Add(Format('-D%s=%s', [AName, AValue]));
end;

procedure CJes2CppProcess.AddInputFile(const AFileName: TFileName);
begin
  Parameters.Add(AFileName);
end;

procedure CJes2CppProcess.AddOutputFile(const AFileName: TFileName);
begin
  Parameters.Add('-o');
  Parameters.Add(AFileName);
end;

procedure CJes2CppProcess.AddIncludePath(const APath: String);
begin
  Parameters.Add('-I' + EncodeParam(APath));
end;

procedure CJes2CppProcess.AddLibrary(const AName: String);
begin
  Parameters.Add('-l' + AName);
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

procedure CJes2CppProcess.AddOption(const AName, AValue: String);
begin
  Parameters.Add('-' + AName + AValue);
end;

function CJes2CppProcess.ExecuteAndWait: Integer;
var
  LString: String;
  LPos: Integer;
begin
  Execute;
  LString := EmptyStr;
  while Running do
  begin
    while Running and (Output.NumBytesAvailable = 0) do
    begin
      Sleep(300);
      Application.ProcessMessages;
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
  DoOnLine(LString);
  Result := ExitStatus;
end;

end.

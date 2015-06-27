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

unit Jes2CppMessageLog;

{$MODE DELPHI}

interface

uses
  Classes, Jes2CppConstants, Jes2CppFileNames, Jes2CppIdentString, Jes2CppStrings, Soda, SysUtils;

type

  CJes2CppMessageLog = class(CComponent)
  strict private
    FWarningsAsErrors: Boolean;
    FFileSource: TFileName;
    FFileCaretY: Integer;
  protected
    procedure LogAssert(const ATrue: Boolean; const AMessage: String);
    procedure LogWarning(const AMessage: String);
    procedure LogNotice(const AMessage: String);
    procedure LogException(const AMessage: String);
    procedure LogExpected(const AExpected: String);
    procedure LogExpectNotEmptyStr(const AString, AExpected: String);
    procedure LogIfExpectNotEmptyStr(const ATrue: Boolean; const AString, AExpected: String);
    procedure LogAssertExpected(const ATrue: Boolean; const AExpected: String);
    procedure LogFileName(const AType, AFileName: String);
    procedure LogMessage(const AMessage: String); virtual; overload;
    procedure LogMessage(const AType, AMessage: String; const AAddReference: Boolean = False; const AException: Boolean = False); overload;
  public
    procedure LogWarningCaseCheck(const A, B: TIdentString);
  protected
    function IsJes2CppInc: Boolean;
    function CurrentToken: String; virtual; abstract;
  protected
    property FileSource: TFileName read FFileSource write FFileSource;
    property FileCaretY: Integer read FFileCaretY write FFileCaretY;
  public
    property WarningsAsErrors: Boolean read FWarningsAsErrors write FWarningsAsErrors;
  end;

type

  NSLog = object
    class function MessageCaretYSource(const AMessage: String; const AFileCaretY: Integer; const AFileSource: TFileName): String;
    class function TypeMessage(const AType, AMessage: String): String;
    class function TypeFileName(const AType, AFileName: String): String;
  end;


implementation

class function NSLog.MessageCaretYSource(const AMessage: String; const AFileCaretY: Integer; const AFileSource: TFileName): String;
begin
  Result := Format(GsErrorLineFile3, [AMessage, AFileCaretY, AFileSource]);
end;

class function NSLog.TypeMessage(const AType, AMessage: String): String;
begin
  Result := AType + CharSpace + '->' + CharSpace + AMessage;
end;

class function NSLog.TypeFileName(const AType, AFileName: String): String;
var
  LFilePath: TFileName;
begin
  LFilePath := ExtractFilePath(AFileName);
  if LFilePath = EmptyStr then
  begin
    Result := TypeMessage(AType, QuotedStr(ExtractFilename(AFileName)));
  end else begin
    Result := TypeMessage(AType, QuotedStr(ExtractFilename(AFileName)) + CharSpace + GsPath + ': ' + QuotedStr(LFilePath));
  end;
end;

procedure CJes2CppMessageLog.LogMessage(const AMessage: String);
begin
end;

procedure CJes2CppMessageLog.LogMessage(const AType, AMessage: String; const AAddReference, AException: Boolean);
var
  LMessage: String;
begin
  if AAddReference and (FFileSource <> EmptyStr) then
  begin
    LMessage := NSLog.MessageCaretYSource(AMessage, FFileCaretY, FFileSource);
  end else begin
    LMessage := AMessage;
  end;
  LogMessage(NSLog.TypeMessage(AType, LMessage));
  if AException then
  begin
    raise Exception.Create(LMessage);
  end;
end;

procedure CJes2CppMessageLog.LogFileName(const AType, AFileName: String);
begin
  LogMessage(NSLog.TypeFileName(AType, AFileName));
end;

procedure CJes2CppMessageLog.LogException(const AMessage: String);
begin
  LogMessage(SMsgTypeException, AMessage, True, True);
end;

procedure CJes2CppMessageLog.LogWarning(const AMessage: String);
begin
  LogMessage(SMsgTypeWarning, AMessage, True, FWarningsAsErrors);
end;

procedure CJes2CppMessageLog.LogNotice(const AMessage: String);
begin
  LogMessage(SMsgTypeNotice, AMessage, True, False);
end;

procedure CJes2CppMessageLog.LogWarningCaseCheck(const A, B: TIdentString);
begin
  if J2C_IdentRemoveRef(A) <> J2C_IdentRemoveRef(B) then
  begin
    LogWarning(Format(SMsgIdentifierNameIsNotIdentical2, [J2C_IdentClean(A), J2C_IdentClean(B)]));
  end;
end;

procedure CJes2CppMessageLog.LogAssert(const ATrue: Boolean; const AMessage: String);
begin
  if not ATrue then
  begin
    LogException(AMessage);
  end;
end;

procedure CJes2CppMessageLog.LogExpected(const AExpected: String);
begin
  LogException(Format(SMsgExpectedButFound2, [AExpected, CurrentToken]));
end;

procedure CJes2CppMessageLog.LogAssertExpected(const ATrue: Boolean; const AExpected: String);
begin
  if not ATrue then
  begin
    LogExpected(AExpected);
  end;
end;

procedure CJes2CppMessageLog.LogExpectNotEmptyStr(const AString, AExpected: String);
begin
  LogAssertExpected(not J2C_StringIsSpace(AString), AExpected);
end;

procedure CJes2CppMessageLog.LogIfExpectNotEmptyStr(const ATrue: Boolean; const AString, AExpected: String);
begin
  if ATrue then
  begin
    LogExpectNotEmptyStr(AString, AExpected);
  end;
end;

function CJes2CppMessageLog.IsJes2CppInc: Boolean;
begin
  // TODO: Improve this.
  Result := SameText(ExtractFileName(FFileSource), GsFilePartJes2Cpp + GsFileExtJsFxInc);
end;

end.

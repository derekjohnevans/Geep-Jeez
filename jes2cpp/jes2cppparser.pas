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

unit Jes2CppParser;

{$MODE DELPHI}

interface

uses
  Classes, Jes2CppConstants, Jes2CppEel, Math, StrUtils, SysUtils;

type

  CJes2CppParser = class(TComponent)
  strict private
    FText: String;
    FFileName: TFileName;
    FLineLine: Integer;
    FToken, FTokenEnd, FTokenNext: PChar;
  strict private
    procedure SkipWhite;
  protected
    procedure LogMessage(const AMessage: String); virtual; overload;
    procedure LogMessage(const AType, AMessage: String); overload;
    procedure LogFileName(const AType, AFileName: String);
    procedure LogException(AMessage: String);
    procedure LogExpected(const AExpected: String);
  public
    function CurrentToken: String;
    function PullToken: String;
    function PullVariableName: String;
    function Remaining: String;
    function IsComment: Boolean;
    function IsEol: Boolean;
    function IsFunctionCall: Boolean;
    function IsIdent: Boolean;
    function IsNull: Boolean;
    function IsNumber: Boolean;
    function IsString: Boolean;
    function IsMultiByteChar: Boolean;
    function IsOperator: Boolean;
    function IsToken(const AToken: String): Boolean;
    function IsTokenThenPull(const AToken: String): Boolean;
    function IsVariable: Boolean;
    function ParseSign: TValueSign;
  public
    procedure ExpectToken(const AToken: String);
    procedure ExpectNotEmpty(const AString, AMessage: String);
    procedure NextToken;
  public
    procedure ResetParser(const AText: String; const AFileName: TFileName);
  public
    property FileName: TFileName read FFileName;
    property FileLine: Integer read FLineLine;
  end;

function LogMessageString(const AType, AMessage: String): String;
function LogFileNameString(const AType, AFileName: String): String;

implementation

function LogMessageString(const AType, AMessage: String): String;
begin
  Result := AType + CharSpace + '->' + CharSpace + AMessage;
end;

function LogFileNameString(const AType, AFileName: String): String;
var
  LFilePath: TFileName;
begin
  LFilePath := ExtractFilePath(AFileName);
  if Length(LFilePath) = M_ZERO then
  begin
    Result := LogMessageString(AType, QuotedStr(ExtractFilename(AFileName)));
  end else begin
    Result := LogMessageString(AType, QuotedStr(ExtractFilename(AFileName)) + ' Path: ' + QuotedStr(LFilePath));
  end;
end;

procedure CJes2CppParser.LogMessage(const AMessage: String);
begin

end;

procedure CJes2CppParser.LogMessage(const AType, AMessage: String);
begin
  LogMessage(LogMessageString(AType, AMessage));
end;

procedure CJes2CppParser.LogFileName(const AType, AFileName: String);
begin
  LogMessage(LogFileNameString(AType, AFileName));
end;

procedure CJes2CppParser.LogException(AMessage: String);
begin
  if Length(FFileName) > M_ZERO then
  begin
    AMessage := Format(SMsgErrorInLine3, [FLineLine, AMessage, FFileName]);
  end;
  LogMessage(SMsgTypeException, AMessage);
  raise Exception.Create(AMessage);
end;

procedure CJes2CppParser.LogExpected(const AExpected: String);
begin
  LogException(Format(SMsgExpectedButFound2, [AExpected, CurrentToken]));
end;

procedure CJes2CppParser.ResetParser(const AText: String; const AFileName: TFileName);
begin
  FLineLine := M_ZERO;
  FFileName := AFileName;
  FText := AText;
  FTokenNext := PChar(FText);
  SkipWhite;
  NextToken;
end;

procedure CJes2CppParser.SkipWhite;
var
  LPtr: PChar;
  LString: String;
begin
  repeat
    while FTokenNext[0] in CharSetWhite do
    begin
      Inc(FTokenNext);
    end;
    if StrLComp(FTokenNext, SFileMarkerHead, Length(SFileMarkerHead)) = 0 then
    begin
      Inc(FTokenNext, Length(SFileMarkerHead));
      LPtr := FTokenNext;
      while not (FTokenNext[0] in [CharNull, SFileMarkerFoot]) do
      begin
        Inc(FTokenNext);
      end;
      SetString(FFileName, LPtr, FTokenNext - LPtr);
      if FTokenNext[0] <> CharNull then
      begin
        Inc(FTokenNext);
      end;
    end else if StrLComp(FTokenNext, SLineMarkerHead, Length(SLineMarkerHead)) = 0 then
    begin
      Inc(FTokenNext, Length(SLineMarkerHead));
      LPtr := FTokenNext;
      while not (FTokenNext[0] in [CharNull, SLineMarkerFoot]) do
      begin
        Inc(FTokenNext);
      end;
      SetString(LString, LPtr, FTokenNext - LPtr);
      FLineLine := StrToInt(LString);
      if FTokenNext[0] <> CharNull then
      begin
        Inc(FTokenNext);
      end;
    end else if (FTokenNext[0] = CharSlashForward) and (FTokenNext[1] = CharAsterisk) then
    begin
      repeat
        Inc(FTokenNext);
      until (FTokenNext[0] in CharSetEof) or ((FTokenNext[-2] = CharAsterisk) and (FTokenNext[-1] = CharSlashForward));
    end else if (FTokenNext[0] = CharSlashForward) and (FTokenNext[1] = CharSlashForward) then
    begin
      repeat
        Inc(FTokenNext);
      until FTokenNext[0] in CharSetEol;
    end else begin
      Break;
    end;
  until False;
end;

function CJes2CppParser.CurrentToken: String;
begin
  if FTokenEnd > FToken then
  begin
    SetString(Result, FToken, FTokenEnd - FToken);
  end else begin
    Result := EmptyStr;
  end;
end;

function CJes2CppParser.PullToken: String;
begin
  Result := CurrentToken;
  NextToken;
end;

function CJes2CppParser.PullVariableName: String;
begin
  Result := PullToken;
  if AnsiContainsStr(Result, SEelEllipses) then
  begin
    LogException(SMsgEllipsesNotSupported);
  end;
  if not AnsiEndsStr(SEelRef, Result) then
  begin
    Result += SEelRef;
  end;
end;

function CJes2CppParser.Remaining: String;
begin
  SetString(Result, FToken, StrLen(FToken));
end;

function CJes2CppParser.IsToken(const AToken: String): Boolean;
begin
  Result := SameText(CurrentToken, AToken);
end;

function CJes2CppParser.IsTokenThenPull(const AToken: String): Boolean;
begin
  Result := IsToken(AToken);
  if Result then
  begin
    NextToken;
  end;
end;

function CJes2CppParser.IsNull: Boolean;
begin
  Result := FToken[0] in CharSetEof;
end;

function CJes2CppParser.IsEol: Boolean;
begin
  Result := FToken[0] in CharSetEol;
end;

function CJes2CppParser.IsIdent: Boolean;
begin
  Result := FToken[0] in CharSetIdent1;
end;

function CJes2CppParser.IsComment: Boolean;
begin
  Result := (FToken[0] = CharSlashForward) and (FToken[1] = CharSlashForward);
end;

function CJes2CppParser.IsNumber: Boolean;
begin
  Result := FToken[0] in CharSetNumber1;
end;

function CJes2CppParser.IsString: Boolean;
begin
  Result := FToken[0] = CharQuoteDouble;
end;

function CJes2CppParser.IsMultiByteChar: Boolean;
begin
  Result := FToken[0] = CharQuoteSingle;
end;

function CJes2CppParser.IsOperator: Boolean;
begin
  Result := FToken[0] in CharSetOperator1;
end;

function CJes2CppParser.IsVariable: Boolean;
begin
  Result := IsIdent and (FTokenNext[0] <> '(');
end;

function CJes2CppParser.IsFunctionCall: Boolean;
begin
  Result := IsIdent and (FTokenNext[0] = '(');
end;

function CJes2CppParser.ParseSign: TValueSign;
var
  LToken: String;
begin
  Result := PositiveValue;
  LToken := CurrentToken;
  while (LToken = CharPlusSign) or (LToken = CharMinusSign) do
  begin
    if LToken = CharMinusSign then
    begin
      Result := -Result;
    end;
    NextToken;
    LToken := CurrentToken;
  end;
end;

// TODO: Merge this with PullToken?
procedure CJes2CppParser.NextToken;
begin
  FToken := FTokenNext;
  FTokenEnd := FToken;
  if not IsNull then
  begin
    if FToken[0] in CharSetQuote then
    begin
      repeat
        Inc(FTokenEnd);
      until (FTokenEnd[0] = CharNull) or ((FTokenEnd[0] = FToken[0]) and (FTokenEnd[-1] <> '\'));
      if FTokenEnd[0] in CharSetQuote then
      begin
        Inc(FTokenEnd);
      end;
    end else if FToken[0] in CharSetOperator1 then
    begin
      if FToken[1] = CharEqu then
      begin
        Inc(FTokenEnd);
        if FToken[2] = CharEqu then
        begin
          Inc(FTokenEnd);
        end;
      end else if (FToken[0] in CharSetOperator2) and (FToken[0] = FToken[1]) then
      begin
        Inc(FTokenEnd);
      end;
      Inc(FTokenEnd);
    end else if (FToken[0] = CharDollar) and (FToken[1] = CharQuoteSingle) and (FToken[2] <> CharNull) and (FToken[3] = CharQuoteSingle) then
    begin
      Inc(FTokenEnd, 4);
    end else if IsNumber then
    begin
      repeat
        Inc(FTokenEnd);
      until not (FTokenEnd[0] in CharSetNumber2);
    end else begin
      if IsIdent then
      begin
        repeat
          Inc(FTokenEnd);
        until not (FTokenEnd[0] in CharSetIdent2);
      end else begin
        Inc(FTokenEnd);
      end;
    end;
    FTokenNext := FTokenEnd;
    SkipWhite;
  end;
end;

procedure CJes2CppParser.ExpectToken(const AToken: String);
begin
  if not IsToken(AToken) then
  begin
    LogExpected(AToken);
  end;
  NextToken;
end;

procedure CJes2CppParser.ExpectNotEmpty(const AString, AMessage: String);
begin
  if Length(Trim(AString)) = M_ZERO then
  begin
    LogExpected(AMessage);
  end;
end;

end.

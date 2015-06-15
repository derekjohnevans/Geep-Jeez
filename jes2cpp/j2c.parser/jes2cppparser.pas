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
  Jes2CppConstants, Jes2CppEel, Jes2CppImporter, Jes2CppToken, Jes2CppTranslate, Jes2CppUtils, Math, StrUtils, SysUtils;

type

  CJes2CppParser = class(CJes2CppImporter)
  strict private
    FSource, FCurrentComment: String;
    FToken, FTokenEnd, FTokenNext: PChar;
  strict private
    procedure ParseWhiteSpace;
  protected
    function ParseSign: TValueSign;
    function ParseRawString: String;
  protected
    function CurrentToken: String; override;
    function PullToken: String;
    function PullIdent: String;
    function PullIdentVariable: String;
    function PullIdentFunctionCall: String;
  protected
    function IsEol: Boolean;
    function IsFunctionCall: Boolean;
    function IsFunctionHead: Boolean;
    function IsIdentHead: Boolean;
    function IsNull: Boolean;
    function IsNumberHead: Boolean;
    function IsStringHead: Boolean;
    function IsCharHead: Boolean;
    function IsOperator: Boolean;
    function IsToken(const AToken: String): Boolean;
    function IsTokenThenPull(const AToken: String): Boolean;
    function IsVariable: Boolean;
  protected
    procedure ExpectToken(const AToken: String);
    procedure NextToken;
  protected
    procedure ResetParser(const ASource: String; const AFileName: TFileName);
  protected
    property CurrentComment: String read FCurrentComment;
  end;

implementation

procedure CJes2CppParser.ResetParser(const ASource: String; const AFileName: TFileName);
begin
  FileLine := M_ZERO;
  FileName := AFileName;
  FSource := ASource;
  FTokenNext := PChar(FSource);
  ParseWhiteSpace;
  NextToken;
end;

procedure CJes2CppParser.ParseWhiteSpace;
var
  LToken: PChar;
  LString: String;
begin
  repeat
    while FTokenNext[0] in CharSetWhite do
    begin
      Inc(FTokenNext);
    end;
    if StrLComp(FTokenNext, GsMarkerHeadFile, Length(GsMarkerHeadFile)) = 0 then
    begin
      Inc(FTokenNext, Length(GsMarkerHeadFile));
      LToken := FTokenNext;
      while not (FTokenNext[0] in [CharNull, GsMarkerFoot]) do
      begin
        Inc(FTokenNext);
      end;
      SetString(LString, LToken, FTokenNext - LToken);
      FileName := LString;
      if FTokenNext[0] <> CharNull then
      begin
        Inc(FTokenNext);
      end;
    end else if StrLComp(FTokenNext, GsMarkerHeadLine, Length(GsMarkerHeadLine)) = 0 then
    begin
      Inc(FTokenNext, Length(GsMarkerHeadLine));
      LToken := FTokenNext;
      while not (FTokenNext[0] in [CharNull, GsMarkerFoot]) do
      begin
        Inc(FTokenNext);
      end;
      SetString(LString, LToken, FTokenNext - LToken);
      FileLine := StrToInt(LString);
      if FTokenNext[0] <> CharNull then
      begin
        Inc(FTokenNext);
      end;
    end else if (FTokenNext[0] = CharSlashForward) and (FTokenNext[1] = CharAsterisk) then
    begin
      LToken := FTokenNext;
      repeat
        Inc(FTokenNext);
      until (FTokenNext[0] in CharSetEof) or ((FTokenNext[-2] = CharAsterisk) and (FTokenNext[-1] = CharSlashForward));
      SetString(FCurrentComment, LToken, FTokenNext - LToken);
      FCurrentComment := J2C_CleanComment(FCurrentComment);
    end else if (FTokenNext[0] = CharSlashForward) and (FTokenNext[1] = CharSlashForward) then
    begin
      LToken := FTokenNext;
      repeat
        Inc(FTokenNext);
      until FTokenNext[0] in CharSetEol;
      SetString(FCurrentComment, LToken, FTokenNext - LToken);
      FCurrentComment := J2C_CleanComment(FCurrentComment);
    end else begin
      Break;
    end;
  until False;
end;

function CJes2CppParser.CurrentToken: String;
begin
  // TODO: Why is this here?
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

function CJes2CppParser.PullIdent: String;
begin
  LogAssertExpected(IsIdentHead, SMsgIdentifier);
  Result := PullToken;
end;

function CJes2CppParser.PullIdentVariable: String;
begin
  Result := PullIdent;
  LogAssert(not AnsiContainsStr(Result, GsEelEllipses), SMsgEllipsesNotSupported);
  if not AnsiEndsStr(CharDot, Result) then
  begin
    Result += CharDot;
  end;
end;

function CJes2CppParser.PullIdentFunctionCall: String;
begin
  LogAssertExpected(IsFunctionCall, SMsgIdentifier);
  Result := PullToken;
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

function CJes2CppParser.IsIdentHead: Boolean;
begin
  Result := FToken[0] in CharSetIdentHead;
end;

function CJes2CppParser.IsNumberHead: Boolean;
begin
  Result := FToken[0] in CharSetNumberHead;
end;

function CJes2CppParser.IsStringHead: Boolean;
begin
  Result := FToken[0] = CharQuoteDouble;
end;

function CJes2CppParser.IsCharHead: Boolean;
begin
  Result := FToken[0] = CharQuoteSingle;
end;

function CJes2CppParser.IsOperator: Boolean;
begin
  Result := FToken[0] in CharSetOperator1;
end;

function CJes2CppParser.IsVariable: Boolean;
begin
  Result := IsIdentHead and (FTokenNext[0] <> CharOpeningParenthesis);
end;

function CJes2CppParser.IsFunctionHead: Boolean;
begin
  Result := FToken[0] in CharSetFunctHead;
end;

function CJes2CppParser.IsFunctionCall: Boolean;
begin
  Result := (FToken[0] in CharSetFunctHead) and (FTokenNext[0] = CharOpeningParenthesis);
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

function CJes2CppParser.ParseRawString: String;
begin
  LogAssertExpected(IsStringHead, 'String');
  Result := CppDecodeString(PullToken);
  while IsStringHead do
  begin
    Result += LineEnding + CppDecodeString(PullToken);
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
      until (FTokenEnd[0] = CharNull) or ((FTokenEnd[0] = FToken[0]) and (FTokenEnd[-1] <> CharSlashBackward));
      if FTokenEnd[0] <> FToken[0] then
      begin
        LogException(SMsgIncompleteStringCharSequence);
      end;
      Inc(FTokenEnd);
    end else if FToken[0] in CharSetOperator1 then
    begin
      if FToken[1] = CharEqualSign then
      begin
        Inc(FTokenEnd);
        if FToken[2] = CharEqualSign then
        begin
          Inc(FTokenEnd);
        end;
      end else if (FToken[0] in CharSetOperator2) and (FToken[0] = FToken[1]) then
      begin
        Inc(FTokenEnd);
      end;
      Inc(FTokenEnd);
    end else if (FToken[0] = CharDollar) and (FToken[1] = CharQuoteSingle) and (FToken[2] <> CharNull) and
      (FToken[3] = CharQuoteSingle) then
    begin
      Inc(FTokenEnd, 4);
    end else if IsNumberHead then
    begin
      repeat
        Inc(FTokenEnd);
      until not (FTokenEnd[0] in CharSetNumberBody);
    end else begin
      if IsIdentHead then
      begin
        repeat
          Inc(FTokenEnd);
        until not (FTokenEnd[0] in CharSetIdentBody);
      end else begin
        Inc(FTokenEnd);
      end;
    end;
    FTokenNext := FTokenEnd;
    ParseWhiteSpace;
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

end.

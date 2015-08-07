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
  Jes2CppConstants, Jes2CppEel, Jes2CppImporter, Jes2CppToken, Jes2CppTranslate,
  Jes2CppUtils, Math,
  StrUtils, SysUtils;

type

  CJes2CppParser = class(CJes2CppImporter)
  strict private
    FSource, FCurrentComment: String;
    FTokenHead, FTokenFoot, FTokenNext: PChar;
  strict private
    procedure ParseWhiteSpace;
  protected
    function ParseSign: String;
    function ParseCppString: String;
    function ParseCppExtension: String;
  protected
    function CurrentToken: String; override;
    function PullToken: String;
    function PullIdent: String;
    function PullIdentVariable: String;
    function PullIdentFunction: String;
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
  FileCaretY := ZeroValue;
  FileSource := AFileName;
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
      FileSource := LString;
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
      FileCaretY := StrToInt(LString);
      if FTokenNext[0] <> CharNull then
      begin
        Inc(FTokenNext);
      end;
    end else if (FTokenNext[0] = CharSlashForward) and (FTokenNext[1] = CharAsterisk) then
    begin
      LToken := FTokenNext;
      repeat
        Inc(FTokenNext);
      until (FTokenNext[0] in CharSetNull) or ((FTokenNext[-2] = CharAsterisk) and
          (FTokenNext[-1] = CharSlashForward));
      SetString(FCurrentComment, LToken, FTokenNext - LToken);
      FCurrentComment := GUtils.CleanComment(FCurrentComment);
    end else if (FTokenNext[0] = CharSlashForward) and (FTokenNext[1] = CharSlashForward) then
    begin
      LToken := FTokenNext;
      repeat
        Inc(FTokenNext);
      until FTokenNext[0] in CharSetLineEnding;
      SetString(FCurrentComment, LToken, FTokenNext - LToken);
      FCurrentComment := GUtils.CleanComment(FCurrentComment);
    end else begin
      Break;
    end;
  until False;
end;

procedure CJes2CppParser.NextToken;
begin
  FTokenHead := FTokenNext;
  FTokenFoot := FTokenHead;
  if not IsNull then
  begin
    if FTokenHead[0] in CharSetQuote then
    begin
      Inc(FTokenFoot);
      while not (FTokenFoot[0] in CharSetLineEnding + [FTokenHead[0]]) do
      begin
        if (FTokenFoot[0] = CharSlashBackward) and not (FTokenFoot[1] in CharSetLineEnding) then
        begin
          Inc(FTokenFoot);
        end;
        Inc(FTokenFoot);
      end;
      if FTokenFoot[0] <> FTokenHead[0] then
      begin
        LogException(SMsgIncompleteStringCharSequence);
      end;
      Inc(FTokenFoot);
    end else if FTokenHead[0] in CharSetOperator1 then
    begin
      if FTokenHead[1] = CharEqualSign then
      begin
        Inc(FTokenFoot);
        if FTokenHead[2] = CharEqualSign then
        begin
          Inc(FTokenFoot);
        end;
      end else if (FTokenHead[0] in CharSetOperator2) and (FTokenHead[0] = FTokenHead[1]) then
      begin
        Inc(FTokenFoot);
      end;
      Inc(FTokenFoot);
    end else if (FTokenHead[0] = CharDollar) and (FTokenHead[1] = CharQuoteSingle) and
      (FTokenHead[2] <> CharNull) and (FTokenHead[3] = CharQuoteSingle) then
    begin
      Inc(FTokenFoot, 4);
    end else if FTokenHead[0] in CharSetNumberHead then
    begin
      repeat
        Inc(FTokenFoot);
      until not (FTokenFoot[0] in CharSetNumberBody);
    end else begin
      if FTokenHead[0] in CharSetIdentHead then
      begin
        repeat
          Inc(FTokenFoot);
        until not (FTokenFoot[0] in CharSetIdentBody);
      end else begin
        Inc(FTokenFoot);
      end;
    end;
    FTokenNext := FTokenFoot;
    ParseWhiteSpace;
  end;
end;

function CJes2CppParser.CurrentToken: String;
begin
  SetString(Result, FTokenHead, FTokenFoot - FTokenHead);
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
  LogAssert(not AnsiContainsStr(Result, GsEelEllipses), SMsgIdentifierEllipsesNotSupported);
end;

function CJes2CppParser.PullIdentVariable: String;
begin
  Result := PullIdent + CharDot;
end;

function CJes2CppParser.PullIdentFunction: String;
begin
  LogAssertExpected(IsFunctionCall, SMsgIdentifier);
  Result := PullIdent;
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
  Result := FTokenHead[0] in CharSetNull;
end;

function CJes2CppParser.IsEol: Boolean;
begin
  Result := FTokenHead[0] in CharSetLineEnding;
end;

function CJes2CppParser.IsIdentHead: Boolean;
begin
  Result := FTokenHead[0] in CharSetIdentHead;
end;

function CJes2CppParser.IsNumberHead: Boolean;
begin
  Result := FTokenHead[0] in CharSetNumberHead;
end;

function CJes2CppParser.IsStringHead: Boolean;
begin
  Result := FTokenHead[0] = CharQuoteDouble;
end;

function CJes2CppParser.IsCharHead: Boolean;
begin
  Result := FTokenHead[0] = CharQuoteSingle;
end;

function CJes2CppParser.IsOperator: Boolean;
begin
  Result := FTokenHead[0] in CharSetOperator1;
end;

function CJes2CppParser.IsVariable: Boolean;
begin
  Result := IsIdentHead and (FTokenNext[0] <> CharOpeningParenthesis);
end;

function CJes2CppParser.IsFunctionHead: Boolean;
begin
  Result := FTokenHead[0] in CharSetFunctHead;
end;

function CJes2CppParser.IsFunctionCall: Boolean;
begin
  Result := (FTokenHead[0] in CharSetFunctHead) and (FTokenNext[0] = CharOpeningParenthesis);
end;

function CJes2CppParser.ParseSign: String;
var
  LIsNegitive: Boolean;
begin
  LIsNegitive := False;
  while (CurrentToken = CharPlusSign) or (CurrentToken = CharMinusSign) do
  begin
    if CurrentToken = CharMinusSign then
    begin
      LIsNegitive := not LIsNegitive;
    end;
    NextToken;
  end;
  if LIsNegitive then
  begin
    Result := CharMinusSign;
  end else begin
    Result := EmptyStr;
  end;
end;

function CJes2CppParser.ParseCppString: String;
begin
  LogAssertExpected(IsStringHead, 'String');
  Result := GCpp.Decode.QuotedString(PullToken);
  while IsStringHead do
  begin
    Result += LineEnding + GCpp.Decode.QuotedString(PullToken);
  end;
end;

function CJes2CppParser.ParseCppExtension: String;
begin
  if IsTokenThenPull(CharExclamation) then
  begin
    Result := ParseCppString;
  end else if AnsiStartsStr(CharExclamation, FCurrentComment) then
  begin
    Result := Copy(FCurrentComment, 2, MaxInt);
    FCurrentComment := EmptyStr;
  end else begin
    Result := EmptyStr;
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

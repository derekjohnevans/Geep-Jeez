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

unit Jes2CppParserExpression;

{$MODE DELPHI}

interface

uses
  Jes2CppConstants, Jes2CppParser, Jes2CppStrings, Jes2CppTranslate, SysUtils;

type

  CJes2CppParserExpression = class(CJes2CppParser)
  protected
    function ParseElement(const AIsExpected: Boolean): String; virtual; abstract;
    function ParseExpression(const AIsExpected: Boolean): String; virtual; abstract;
  protected
    function ParseParenthesis: String;
    function ParseBlock(out ALastExpression: String): String; overload;
    function ParseBlock: String; overload;
  end;

implementation

function CJes2CppParserExpression.ParseParenthesis: String;
begin
  ExpectToken(CharOpeningParenthesis);
  Result := EmptyStr;
  repeat
    if not (IsToken(CharSemiColon) or IsToken(CharClosingParenthesis)) then
    begin
      J2C_StringAppendCSV(Result, ParseExpression(True));
    end;
  until not IsTokenThenPull(CharSemiColon);
  ExpectToken(CharClosingParenthesis);
  LogExpectNotEmptyStr(Result, SMsgParenthesisBlock);
  Result := CharOpeningParenthesis + Result + CharClosingParenthesis;
end;

function CJes2CppParserExpression.ParseBlock(out ALastExpression: String): String;
var
  LExpression: String;
begin
  Result := EmptyStr;
  ALastExpression := EmptyStr;
  ExpectToken(CharOpeningParenthesis);
  repeat
    LExpression := ParseExpression(False);
    if LExpression <> EmptyStr then
    begin
      if ALastExpression <> EmptyStr then
      begin
        Result += ALastExpression + GsCppLineEnding;
        ALastExpression := EmptyStr;
      end;
      ALastExpression := LExpression;
    end;
  until not IsTokenThenPull(CharSemiColon);
  ExpectToken(CharClosingParenthesis);
  LogExpectNotEmptyStr(ALastExpression, SMsgExpression);
end;

function CJes2CppParserExpression.ParseBlock: String;
begin
  Result := ParseBlock(Result) + Result + GsCppLineEnding;
end;

end.

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

unit Jes2CppParserLoops;

{$MODE DELPHI}

interface

uses
  Classes, Jes2CppConstants, Jes2CppEel, Jes2CppLoop, Jes2CppParserElements, Jes2CppTranslate, SysUtils;

type

  CJes2CppParserLoops = class(CJes2CppParserElements)
  strict private
    FLoops: CJes2CppLoops;
  strict private
    function ParseLoopBlock: String;
  protected
    function ParseWhile: String;
    function ParseLoop: String;
  public
    constructor Create(const AOwner: TComponent; const AName: TComponentName); override;
  public
    property Loops: CJes2CppLoops read FLoops;
  end;

implementation

constructor CJes2CppParserLoops.Create(const AOwner: TComponent; const AName: TComponentName);
begin
  inherited Create(AOwner, AName);
  FLoops := CJes2CppLoops.Create(Self, EmptyStr);
end;

function CJes2CppParserLoops.ParseWhile: String;
var
  LLoop: CJes2CppLoop;
begin
  ExpectToken(GsEelWhile);
  LLoop := CJes2CppLoop.Create(FLoops, ltDoWhile, FCurrentFunction);
  LLoop.FBlock := ParseBlock(LLoop.FCondition);
  if IsToken(CharOpeningParenthesis) then
  begin
    LLoop.FType := ltWhile;
    LLoop.FPreCondition := LLoop.FBlock;
    LLoop.FBlock := ParseBlock;
  end;
  Result := LLoop.CppCall;
end;

function CJes2CppParserLoops.ParseLoopBlock: String;
var
  LExpression: String;
begin
  Result := EmptyStr;
  repeat
    LExpression := ParseExpression(False);
    if LExpression <> EmptyStr then
    begin
      Result += LExpression + GsCppLineEnding;
    end;
  until not IsTokenThenPull(CharSemiColon);
end;

function CJes2CppParserLoops.ParseLoop: String;
var
  LLoop: CJes2CppLoop;
begin
  ExpectToken(GsEelLoop);
  LLoop := CJes2CppLoop.Create(FLoops, ltLoop, FCurrentFunction);
  ExpectToken(CharOpeningParenthesis);
  LLoop.FCondition := ParseExpression(True);
  ExpectToken(CharComma);
  LLoop.FBlock := ParseLoopBlock;
  ExpectToken(CharClosingParenthesis);
  Result := LLoop.CppCall;
end;

end.


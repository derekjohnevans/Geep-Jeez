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

unit Jes2CppOperatorParser;

// NOTE: This is the only non-delphi compatible unit.
// I will change the code when i'm happy its stable.
{$MODE OBJFPC}{$H+}

interface

uses
  Jes2CppConstants, Jes2CppEel, Jes2CppEelConstants, Jes2CppParser, Jes2CppTranslate, SysUtils;

type

  CJes2CppOperatorParser = class(CJes2CppParser)
  public
    FParameterAssignmentCount: Integer;
    FStatementAssignmentCount: Integer;
  strict private
    function ParseOperatorLevel0(const AIsExpected: Boolean): String;
    function ParseOperatorLevel1(const AIsExpected: Boolean): String;
    function ParseOperatorLevel2(const AIsExpected: Boolean): String;
    function ParseOperatorLevel3(const AIsExpected: Boolean): String;
    function ParseOperatorLevel4(const AIsExpected: Boolean): String;
    function ParseOperatorLevel5(const AIsExpected: Boolean): String;
    function ParseOperatorLevel6(const AIsExpected: Boolean): String;
    function ParseOperatorLevel7(const AIsExpected: Boolean): String;
  protected
    function ParseElement(const AIsExpected: Boolean): String; virtual; abstract;
    function ParseExpression(const AIsExpected: Boolean): String; virtual; abstract;
  protected
    function ParseOperator(const AIsExpected: Boolean): String;
  end;

implementation

function CJes2CppOperatorParser.ParseOperatorLevel0(const AIsExpected: Boolean): String;

  function LUpLevel(const AIsExpected: Boolean): String;
  begin
    Result := ParseExpression(AIsExpected);
  end;

  function LFunctionSet(const ALeft, AOpName: String): String;
  begin
    Inc(FParameterAssignmentCount);
    Inc(FStatementAssignmentCount);
    NextToken;
    Result := Format(SCppFunct3, [AOpName, ALeft, LUpLevel(True)]);
  end;

  function LFunctionOpSet(const ALeft, AOpName: String): String;
  begin
    if FStatementAssignmentCount > 0 then
    begin
      //LogException(SMsgMultipleAssignmentsInStatements);
    end;
    Inc(FParameterAssignmentCount);
    Inc(FStatementAssignmentCount);
    NextToken;
    Result := SFnSet + CharOpeningParenthesis + ALeft + SCppCommaSpace + Format(SCppFunct3, [AOpName, ALeft, LUpLevel(True)]) +
      CharClosingParenthesis;
  end;

begin
  Result := ParseElement(False);
  case CurrentToken of
    SOpSet: begin
      if CppIsHashString(Result) then
      begin
        Result := LFunctionSet(Result, EelToCppFun(SEelFnStrCpy));
      end else begin
        Result := LFunctionSet(Result, SFnSet);
      end;
    end;
    SOpDivSet: begin
      Result := LFunctionOpSet(Result, SFnDiv);
    end;
    SOpAndSet: begin
      Result := LFunctionOpSet(Result, SFnAnd);
    end;
    SOpOrSet: begin
      Result := LFunctionOpSet(Result, SFnOr);
    end;
    SOpModSet: begin
      Result := LFunctionOpSet(Result, SFnMod);
    end;
    SOpXorSet: begin
      Result := LFunctionOpSet(Result, SFnXor);
    end;
    SOpAddSet: begin
      if CppIsHashString(Result) then
      begin
        Result := LFunctionSet(Result, EelToCppFun(SEelFnStrCat));
      end else begin
        Result := LFunctionOpSet(Result, SFnAdd);
      end;
    end;
    SOpSubSet: begin
      Result := LFunctionOpSet(Result, SFnSub);
    end;
    SOpMulSet: begin
      Result := LFunctionOpSet(Result, SFnMul);
    end;
  end;
  if AIsExpected then
  begin
    ExpectNotEmpty(Result, 'Parse Operator Level 0');
  end;
end;

function CJes2CppOperatorParser.ParseOperatorLevel1(const AIsExpected: Boolean): String;

  function LUpLevel(const AIsExpected: Boolean): String;
  begin
    Result := ParseOperatorLevel0(AIsExpected);
  end;

  function LFunction(const ALeft, AName: String): String;
  begin
    NextToken;
    Result := Format(SCppFunct3, [AName, ALeft, LUpLevel(True)]);
  end;

begin
  Result := LUpLevel(False);
  repeat
    case CurrentToken of
      SOpPow: begin
        Result := LFunction(Result, SFnPow);
      end else begin
        Break;
      end;
    end;
  until False;
  if AIsExpected then
  begin
    ExpectNotEmpty(Result, 'Parse Operator Level 1');
  end;
end;

function CJes2CppOperatorParser.ParseOperatorLevel2(const AIsExpected: Boolean): String;

  function LUpLevel(const AIsExpected: Boolean): String;
  begin
    Result := ParseOperatorLevel1(AIsExpected);
  end;

  function LFunction(const ALeft, AName: String): String;
  begin
    NextToken;
    Result := Format(SCppFunct3, [AName, ALeft, LUpLevel(True)]);
  end;

begin
  Result := LUpLevel(False);
  repeat
    case CurrentToken of
      SOpShr: begin
        Result := LFunction(Result, SFnShr);
      end;
      SOpShl: begin
        Result := LFunction(Result, SFnShl);
      end else begin
        Break;
      end;
    end;
  until False;
  if AIsExpected then
  begin
    ExpectNotEmpty(Result, 'Parse Operator Level 2');
  end;
end;

function CJes2CppOperatorParser.ParseOperatorLevel3(const AIsExpected: Boolean): String;

  function LUpLevel(const AIsExpected: Boolean): String;
  begin
    Result := ParseOperatorLevel2(AIsExpected);
  end;

  function LFunction(const ALeft, AName: String): String;
  begin
    NextToken;
    Result := Format(SCppFunct3, [AName, ALeft, LUpLevel(True)]);
  end;

begin
  Result := LUpLevel(False);
  repeat
    case CurrentToken of
      SOpDiv: begin
        Result := LFunction(Result, SFnDiv);
      end;
      SOpMod: begin
        Result := LFunction(Result, SFnMod);
      end;
      SOpMul: begin
        Result := LFunction(Result, SFnMul);
      end else begin
        Break;
      end;
    end;
  until False;
  if AIsExpected then
  begin
    ExpectNotEmpty(Result, 'Parse Operator Level 3');
  end;
end;

function CJes2CppOperatorParser.ParseOperatorLevel4(const AIsExpected: Boolean): String;

  function LUpLevel(const AIsExpected: Boolean): String;
  begin
    Result := ParseOperatorLevel3(AIsExpected);
  end;

  function LFunction(const ALeft, AName: String): String;
  begin
    NextToken;
    Result := Format(SCppFunct3, [AName, ALeft, LUpLevel(True)]);
  end;

begin
  Result := LUpLevel(False);
  repeat
    case CurrentToken of
      SOpAdd: begin
        Result := LFunction(Result, SFnAdd);
      end;
      SOpSub: begin
        Result := LFunction(Result, SFnSub);
      end else begin
        Break;
      end;
    end;
  until False;
  if AIsExpected then
  begin
    ExpectNotEmpty(Result, 'Parse Operator Level 4');
  end;
end;

function CJes2CppOperatorParser.ParseOperatorLevel5(const AIsExpected: Boolean): String;

  function LUpLevel(const AIsExpected: Boolean): String;
  begin
    Result := ParseOperatorLevel4(AIsExpected);
  end;

  function LFunction(const ALeft, AName: String): String;
  begin
    NextToken;
    Result := Format(SCppFunct3, [AName, ALeft, LUpLevel(True)]);
  end;

begin
  Result := LUpLevel(False);
  repeat
    case CurrentToken of
      SOpAnd: begin
        Result := LFunction(Result, SFnAnd);
      end;
      SOpOr: begin
        Result := LFunction(Result, SFnOr);
      end;
      SOpXor: begin
        Result := LFunction(Result, SFnXor);
      end else begin
        Break;
      end;
    end;
  until False;
  if AIsExpected then
  begin
    ExpectNotEmpty(Result, 'Parse Operator Level 5');
  end;
end;

function CJes2CppOperatorParser.ParseOperatorLevel6(const AIsExpected: Boolean): String;

  function LUpLevel(const AIsExpected: Boolean): String;
  begin
    Result := ParseOperatorLevel5(AIsExpected);
  end;

  function LFunction(const ALeft, AFunctionName: String): String;
  begin
    NextToken;
    Result := Format(SCppFunct3, [AFunctionName, ALeft, LUpLevel(True)]);
  end;

begin
  Result := LUpLevel(False);
  repeat
    case CurrentToken of
      SOpEquX: begin
        Result := LFunction(Result, SFnEquX);
      end;
      SOpNeqX: begin
        Result := LFunction(Result, SFnNeqX);
      end;
      SOpGt: begin
        Result := LFunction(Result, SFnGt);
      end;
      SOpLt: begin
        Result := LFunction(Result, SFnLt);
      end;
      SOpGte: begin
        Result := LFunction(Result, SFnGte);
      end;
      SOpLte: begin
        Result := LFunction(Result, SFnLte);
      end;
      SOpEqu: begin
        Result := LFunction(Result, SFnEqu);
      end;
      SOpNeq: begin
        Result := LFunction(Result, SFnNeq);
      end else begin
        Break;
      end;
    end;
  until False;
  if AIsExpected then
  begin
    ExpectNotEmpty(Result, 'Parse Operator Level 6');
  end;
end;

function CJes2CppOperatorParser.ParseOperatorLevel7(const AIsExpected: Boolean): String;

  function LUpLevel(const AIsExpected: Boolean): String;
  begin
    Result := ParseOperatorLevel6(AIsExpected);
  end;

  function LFunction(const ALeft, AFunctionName: String): String;
  begin
    NextToken;
    Result := Format(SCppFunct3, [AFunctionName, ALeft, LUpLevel(True)]);
  end;

begin
  Result := LUpLevel(False);
  repeat
    case CurrentToken of
      SOpAndIf: begin
        Result := LFunction(Result, SFnAndIf);
      end;
      SOpOrIf: begin
        Result := LFunction(Result, SFnOrIf);
      end else begin
        Break;
      end;
    end;
  until False;
  if AIsExpected then
  begin
    ExpectNotEmpty(Result, 'Parse Operator Level 7');
  end;
end;

function CJes2CppOperatorParser.ParseOperator(const AIsExpected: Boolean): String;
begin
  Result := ParseOperatorLevel7(AIsExpected);
end;

end.

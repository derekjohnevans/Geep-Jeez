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

unit Jes2CppParserOperator;

// NOTE: This is the only non-delphi compatible unit.
// I will change the code when i'm happy its stable.
{$MODE OBJFPC}{$H+}

interface

uses
  Jes2CppConstants, Jes2CppEel, Jes2CppParserExpression, Jes2CppTranslate, SysUtils;

type

  CJes2CppParserOperator = class(CJes2CppParserExpression)
  public
    FParameterAssignmentCount: Integer;
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
    function ParseOperator(const AIsExpected: Boolean): String;
  end;

implementation

function CJes2CppParserOperator.ParseOperatorLevel0(const AIsExpected: Boolean): String;

const
  LMessage = 'ParseOperatorLevel0';

  function LUpLevel(const AIsExpected: Boolean): String;
  begin
    Result := ParseExpression(AIsExpected);
  end;

  function LOperator(const ALeft: String): String;
  begin
    LogExpectNotEmptyStr(ALeft, LMessage);
    Inc(FParameterAssignmentCount);
    Result := Format(GsCppOperator, [ALeft, PullToken, Format(GsCppFunct2,
      [GsFnVal, LUpLevel(True)])]);
  end;

  function LFunctionSet(const ALeft, AName: String): String;
  begin
    LogExpectNotEmptyStr(ALeft, LMessage);
    Inc(FParameterAssignmentCount);
    NextToken;
    Result := Format(GsCppFunct3, [AName, ALeft, LUpLevel(True)]);
  end;

  function LFunctionOpSet(const ALeft, AName: String): String;
  begin
    LogExpectNotEmptyStr(ALeft, LMessage);
    Result := Format(GsCppOperator, [ALeft, CharEqualSign, Format(GsCppFunct2,
      [GsFnVal, LFunctionSet(ALeft, AName)])]);
  end;

begin
  Result := ParseElement(False);
  case CurrentToken of
    GsOpSet: begin
      if GCpp.IsHashString(Result) then
      begin
        Result := LFunctionSet(Result, GCpp.Encode.NameFunction(GsEelFnStrCpy, 0));
      end else begin
        Result := LOperator(Result);
      end;
    end;
    GsOpAddSet: begin
      if GCpp.IsHashString(Result) then
      begin
        Result := LFunctionSet(Result, GCpp.Encode.NameFunction(GsEelFnStrCat, 0));
      end else begin
        Result := LOperator(Result);
      end;
    end;
    GsOpDivSet, GsOpSubSet, GsOpMulSet: begin
      Result := LOperator(Result);
    end;
    GsOpAndSet: begin
      Result := LFunctionOpSet(Result, GsFnAnd);
    end;
    GsOpOrSet: begin
      Result := LFunctionOpSet(Result, GsFnAor);
    end;
    GsOpModSet: begin
      Result := LFunctionOpSet(Result, GsFnFmod);
    end;
    GsOpXorSet: begin
      Result := LFunctionOpSet(Result, GsFnXor);
    end;
    GsOpPowSet: begin
      Result := LFunctionOpSet(Result, GsFnPow);
    end;
  end;
  LogIfExpectNotEmptyStr(AIsExpected, Result, LMessage);
end;

function CJes2CppParserOperator.ParseOperatorLevel1(const AIsExpected: Boolean): String;

const
  LMessage = 'ParseOperatorLevel1';

  function LUpLevel(const AIsExpected: Boolean): String;
  begin
    Result := ParseOperatorLevel0(AIsExpected);
  end;

  function LFunction(const ALeft, AName: String): String;
  begin
    LogExpectNotEmptyStr(ALeft, LMessage);
    NextToken;
    Result := Format(GsCppFunct3, [AName, ALeft, LUpLevel(True)]);
  end;

begin
  Result := LUpLevel(False);
  repeat
    case CurrentToken of
      GsOpPow: begin
        Result := LFunction(Result, GsFnPow);
      end else begin
        Break;
      end;
    end;
  until False;
  LogIfExpectNotEmptyStr(AIsExpected, Result, LMessage);
end;

function CJes2CppParserOperator.ParseOperatorLevel2(const AIsExpected: Boolean): String;

const
  LMessage = 'ParseOperatorLevel2';

  function LUpLevel(const AIsExpected: Boolean): String;
  begin
    Result := ParseOperatorLevel1(AIsExpected);
  end;

  function LFunction(const ALeft, AName: String): String;
  begin
    LogExpectNotEmptyStr(ALeft, LMessage);
    NextToken;
    Result := Format(GsCppFunct3, [AName, ALeft, LUpLevel(True)]);
  end;

begin
  Result := LUpLevel(False);
  repeat
    case CurrentToken of
      GsOpShr: begin
        Result := LFunction(Result, GsFnShr);
      end;
      GsOpShl: begin
        Result := LFunction(Result, GsFnShl);
      end else begin
        Break;
      end;
    end;
  until False;
  LogIfExpectNotEmptyStr(AIsExpected, Result, LMessage);
end;

function CJes2CppParserOperator.ParseOperatorLevel3(const AIsExpected: Boolean): String;

const
  LMessage = 'ParseOperatorLevel3';

  function LUpLevel(const AIsExpected: Boolean): String;
  begin
    Result := ParseOperatorLevel2(AIsExpected);
  end;

  function LOperator(const ALeft: String): String;
  begin
    LogExpectNotEmptyStr(ALeft, LMessage);
    Result := Format(GsCppOperator, [ALeft, PullToken, LUpLevel(True)]);
  end;

  function LFunction(const ALeft, AName: String): String;
  begin
    LogExpectNotEmptyStr(ALeft, LMessage);
    NextToken;
    Result := Format(GsCppFunct3, [AName, ALeft, LUpLevel(True)]);
  end;

begin
  Result := LUpLevel(False);
  repeat
    case CurrentToken of
      GsOpMul, GsOpDiv: begin
        Result := LOperator(Result);
      end;
      GsOpMod: begin
        Result := LFunction(Result, GsFnFmod);
      end else begin
        Break;
      end;
    end;
  until False;
  LogIfExpectNotEmptyStr(AIsExpected, Result, LMessage);
end;

function CJes2CppParserOperator.ParseOperatorLevel4(const AIsExpected: Boolean): String;

const
  LMessage = 'ParseOperatorLevel4';

  function LUpLevel(const AIsExpected: Boolean): String;
  begin
    Result := ParseOperatorLevel3(AIsExpected);
  end;

  function LOperator(const ALeft: String): String;
  begin
    LogExpectNotEmptyStr(ALeft, LMessage);
    Result := Format(GsCppOperator, [ALeft, PullToken, LUpLevel(True)]);
  end;

begin
  Result := LUpLevel(False);
  repeat
    case CurrentToken of
      GsOpAdd, GsOpSub: begin
        Result := LOperator(Result);
      end else begin
        Break;
      end;
    end;
  until False;
  LogIfExpectNotEmptyStr(AIsExpected, Result, LMessage);
end;

function CJes2CppParserOperator.ParseOperatorLevel5(const AIsExpected: Boolean): String;

const
  LMessage = 'ParseOperatorLevel5';

  function LUpLevel(const AIsExpected: Boolean): String;
  begin
    Result := ParseOperatorLevel4(AIsExpected);
  end;

  function LFunction(const ALeft, AName: String): String;
  begin
    LogExpectNotEmptyStr(ALeft, LMessage);
    NextToken;
    Result := Format(GsCppFunct3, [AName, ALeft, LUpLevel(True)]);
  end;

begin
  Result := LUpLevel(False);
  repeat
    case CurrentToken of
      GsOpAnd: begin
        Result := LFunction(Result, GsFnAnd);
      end;
      GsOpOr: begin
        Result := LFunction(Result, GsFnAor);
      end;
      GsOpXor: begin
        Result := LFunction(Result, GsFnXor);
      end else begin
        Break;
      end;
    end;
  until False;
  LogIfExpectNotEmptyStr(AIsExpected, Result, LMessage);
end;

function CJes2CppParserOperator.ParseOperatorLevel6(const AIsExpected: Boolean): String;

const
  LMessage = 'ParseOperatorLevel6';

  function LUpLevel(const AIsExpected: Boolean): String;
  begin
    Result := ParseOperatorLevel5(AIsExpected);
  end;

  function LOperator(const ALeft: String): String;
  begin
    LogExpectNotEmptyStr(ALeft, LMessage);
    Result := Format(GsCppOperator, [ALeft, Copy(PullToken, 1, 2), LUpLevel(True)]);
  end;

  function LFunction(const ALeft, AFunctionName: String): String;
  begin
    LogExpectNotEmptyStr(ALeft, LMessage);
    NextToken;
    Result := Format(GsCppFunct3, [AFunctionName, ALeft, LUpLevel(True)]);
  end;

begin
  Result := LUpLevel(False);
  repeat
    case CurrentToken of
      GsOpEquX, GsOpNeqX, GsOpGt, GsOpLt, GsOpGte, GsOpLte: begin
        Result := LOperator(Result);
      end;
      GsOpEqu: begin
        Result := LFunction(Result, GsFnEqu);
      end;
      GsOpNeq: begin
        Result := LFunction(Result, GsFnNeq);
      end else begin
        Break;
      end;
    end;
  until False;
  LogIfExpectNotEmptyStr(AIsExpected, Result, LMessage);
end;

function CJes2CppParserOperator.ParseOperatorLevel7(const AIsExpected: Boolean): String;

const
  LMessage = 'ParseOperatorLevel7';

  function LUpLevel(const AIsExpected: Boolean): String;
  begin
    Result := ParseOperatorLevel6(AIsExpected);
  end;

  function LOperator(const ALeft: String): String;
  begin
    LogExpectNotEmptyStr(ALeft, LMessage);
    Result := Format('(%s(%s) %s %s(%s))', [GsFnIf, ALeft, PullToken, GsFnIf, LUpLevel(True)]);
  end;

begin
  Result := LUpLevel(False);
  repeat
    case CurrentToken of
      GsOpAndIf, GsOpOrIf: begin
        Result := LOperator(Result);
      end else begin
        Break;
      end;
    end;
  until False;
  LogIfExpectNotEmptyStr(AIsExpected, Result, LMessage);
end;

function CJes2CppParserOperator.ParseOperator(const AIsExpected: Boolean): String;
begin
  Result := ParseOperatorLevel7(AIsExpected);
end;

end.

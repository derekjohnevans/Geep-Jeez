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

unit Jes2CppParserFunctions;

{$MODE DELPHI}

interface

uses
  Jes2CppConstants, Jes2CppEel, Jes2CppFunction, Jes2CppFunctionIdentifiers, Jes2CppIdentifier, Jes2CppIdentString,
  Jes2CppIterate, Jes2CppParserLoops, Jes2CppStrings, Jes2CppTranslate, Math, StrUtils, SysUtils;

type

  CJes2CppParserFunctions = class(CJes2CppParserLoops)
  strict private
    FForceGlobals: Boolean;
  strict private
    function ParseFunctionCall: String;
    function ParseFunctionCallExpressions: TArrayOfString;
  strict private
    procedure ParseFunctionDefine;
    procedure ParseVariableDefines(const AIdentifiers: CJes2CppFunctionIdentifiers; const AIsFunctionParameters, ACanRef: Boolean);
  protected
    function ParseElement(const AIsExpected: Boolean): String; override;
    function ParseExpression(const AIsExpected: Boolean): String; override;
    function ParseSectionBody: String;
  public
    property ForceGlobals: Boolean write FForceGlobals;
  end;

implementation

procedure CJes2CppParserFunctions.ParseVariableDefines(const AIdentifiers: CJes2CppFunctionIdentifiers;
  const AIsFunctionParameters, ACanRef: Boolean);
var
  LIdent: TIdentString;
begin
  ExpectToken(CharOpeningParenthesis);
  while not IsToken(CharClosingParenthesis) do
  begin
    if AIsFunctionParameters and IsToken(GsEelVariadic) then
    begin
      LogAssert(AIdentifiers.ComponentCount > 0, SMsgVariadicFunctionsMustHaveAtLeastOneParameter);
      LogAssert(not AIdentifiers.IsVariadic, SMsgVariadicEllipsisHasAlreadyBeenUsed);
      LIdent := PullToken;
    end else begin
      LogAssert(not AIdentifiers.IsVariadic, SMsgVariadicEllipsisMustBeTheLastParameter);
      LIdent := PullIdentVariable;
    end;
    if ACanRef and IsToken(CharAsterisk) then
    begin
      LIdent := LIdent + PullToken;
    end;
    LogAssert(not AnsiMatchText(J2C_IdentClean(LIdent), GaEelKeywords), SMsgKeywordsCantBeUsedAsIdentNames);
    LogAssert(not FCurrentFunction.ExistsGlobal(LIdent, Self), Format(SMsgAlreadyDefinedAsGlobal1, [J2C_IdentClean(LIdent)]));
    LogAssert(not FCurrentFunction.ExistsInstanceSelf(LIdent, Self), Format(SMsgAlreadyDefinedAsInstance1, [J2C_IdentClean(LIdent)]));
    LogAssert(not FCurrentFunction.ExistsLocal(LIdent, Self), Format(SMsgAlreadyDefinedAsLocal1, [J2C_IdentClean(LIdent)]));
    LogAssert(not FCurrentFunction.ExistsParam(LIdent, Self), Format(SMsgAlreadyDefinedAsParameter1, [J2C_IdentClean(LIdent)]));
    LogAssert(not FCurrentFunction.ExistsStatic(LIdent, Self), Format(SMsgAlreadyDefinedAsStatic1, [J2C_IdentClean(LIdent)]));

    AIdentifiers.Append(LIdent);

    if not IsToken(CharClosingParenthesis) then
    begin
      IsTokenThenPull(CharComma);
    end;
  end;
  ExpectToken(CharClosingParenthesis);
end;

procedure CJes2CppParserFunctions.ParseFunctionDefine;
var
  LIsAlias: Boolean;
begin
  ExpectToken(GsEelFunction);
  LogAssert(not Assigned(FCurrentFunction), SMsgFunctionDefinedInsideFunction);
  LIsAlias := IsTokenThenPull(CharAmpersand);
  LogAssertExpected(IsFunctionHead, SMsgIdentifier);
  FCurrentFunction := CJes2CppFunction.Create(Functions, PullToken);
  FCurrentFunction.Comment := CurrentComment;
  FCurrentFunction.References.AddReference(FileName, FileLine);
  FCurrentFunction.ForceGlobals := FForceGlobals;
  FCurrentFunction.IsRef := IsTokenThenPull(CharAsterisk);
  try
    ParseVariableDefines(FCurrentFunction.Params, True, True);
    LogAssert(Functions.FindFunction(FCurrentFunction.Name, FCurrentFunction.Params.ComponentCount) = FCurrentFunction,
      Format(SMsgFunctionasDuplicateOverloads1, [FCurrentFunction.Name]));
    repeat
      if IsTokenThenPull(GsEelLocal) then
      begin
        ParseVariableDefines(FCurrentFunction.Locals, False, False);
      end else if IsTokenThenPull(GsEelStatic) then
      begin
        ParseVariableDefines(FCurrentFunction.Static, False, False);
      end else if IsTokenThenPull(GsEelInstance) then
      begin
        ParseVariableDefines(FCurrentFunction.InstancesSelf, False, False);
        FCurrentFunction.InstancesAll.CopyFrom(FCurrentFunction.InstancesSelf);
      end else if IsTokenThenPull(GsEelGlobal) or IsTokenThenPull(GsEelGlobals) then
      begin
        ParseVariableDefines(FCurrentFunction.Globals, False, True);
        FCurrentFunction.HasGlobals := True;
      end else begin
        Break;
      end;
    until False;
    if IsTokenThenPull(GsEelExtern) then
    begin
      FCurrentFunction.IdentType := itExternal;
    end else begin
      FCurrentFunction.FBody := ParseBlock(FCurrentFunction.FReturnExpression);
    end;
  finally
    FCurrentFunction := nil;
  end;
end;

function CJes2CppParserFunctions.ParseSectionBody: String;
var
  LExpression: String;
begin
  Result := EmptyStr;
  repeat
    if IsToken(GsEelFunction) then
    begin
      ParseFunctionDefine;
    end else begin
      LExpression := ParseExpression(False);
      if LExpression <> EmptyStr then
      begin
        Result += LExpression + GsCppLineEnding;
      end;
    end;
  until not IsTokenThenPull(CharSemiColon);
end;

function CJes2CppParserFunctions.ParseFunctionCallExpressions: TArrayOfString;
begin
  SetLength(Result.Items, M_ZERO);
  FParameterAssignmentCount := M_ZERO;
  while not IsToken(CharClosingParenthesis) do
  begin
    if Result.Count > M_ZERO then
    begin
      ExpectToken(CharComma);
    end;
    Result.Append(ParseExpression(True));
  end;
  if (Result.Count > 1) and (FParameterAssignmentCount > M_ZERO) then
  begin
    LogException(SMsgAssignmentsInFunctionCall);
  end;
end;

function CJes2CppParserFunctions.ParseFunctionCall: String;
var
  LIndex: Integer;
  LIdent, LFunctName, LNameSpace: TIdentString;
  LExpressions: TArrayOfString;
  LFunction: CJes2CppFunction;
begin
  if IsToken(GsEelWhile) then
  begin
    Result := ParseWhile;
  end else if IsToken(GsEelLoop) then
  begin
    Result := ParseLoop;
  end else begin
    LIdent := PullIdentFunctionCall;
    ExpectToken(CharOpeningParenthesis);
    if Assigned(FCurrentFunction) and FCurrentFunction.InstancesSelf.IsNameSpaceMatch(LIdent + CharDot) then
    begin
      LIdent := GsEelSpaceThis + LIdent;
    end;
    if AnsiMatchText(LIdent, GaEelFunctionsMidi) and not IsJes2CppInc then
    begin
      Description.FIsSynth := True;
    end;
    LExpressions := ParseFunctionCallExpressions;
    LFunction := Functions.FindFunction(LIdent, LNameSpace, LFunctName, LExpressions.Count);
    LogAssert(Assigned(LFunction), Format(SMsgUnableToFindFunction1, [LIdent]));
    LogWarningCaseCheck(LFunctName, LFunction.Name);
    if not SameText(LNameSpace, LFunction.DefaultNameSpace) and not J2C_IdentIsNameSpaceThis(LNameSpace) and
      Assigned(FCurrentFunction) and FCurrentFunction.HasGlobals and not FCurrentFunction.Globals.ExistsFiltered(LIdent) then
    begin
      LogException(Format(SMsgNamespaceNotAccessible1, [J2C_IdentClean(LNameSpace)]));
    end;
    LFunction.References.AddReference(FileName, FileLine);
    if LFunction.IdentType = itInternal then
    begin
      for LIndex := IndexFirst(LFunction.InstancesAll) to IndexLast(LFunction.InstancesAll) do
      begin
        if Assigned(FCurrentFunction) and J2C_IdentIsNameSpaceThis(LNameSpace) then
        begin
          FCurrentFunction.AppendInstance(Copy(LNameSpace, Length(GsEelSpaceThis) + 1, MaxInt) +
            LFunction.InstancesAll[LIndex].Name, Self);
        end else begin
          FindOrCreateVariable(LNameSpace + LFunction.InstancesAll[LIndex].Name, FileName, FileLine, CurrentComment);
        end;
      end;
    end;
    Result := EmptyStr;
    for LIndex := Low(LExpressions.Items) to High(LExpressions.Items) do
    begin
      J2C_StringAppendCSV(Result, LExpressions.Items[LIndex]);
    end;
    for LIndex := IndexFirst(LFunction.InstancesAll) to IndexLast(LFunction.InstancesAll) do
    begin
      J2C_StringAppendCSV(Result, CppEncodeVariable(LNameSpace + LFunction.InstancesAll[LIndex].Name));
    end;
    Result := CppEncodeFunction(LFunctName) + CharOpeningParenthesis + Result + CharClosingParenthesis;
    ExpectToken(CharClosingParenthesis);
  end;
end;

function CJes2CppParserFunctions.ParseElement(const AIsExpected: Boolean): String;
begin
  if IsTokenThenPull(CharExclamation) then
  begin
    if IsStringHead then
    begin
      Result := ParseRawString;
    end else begin
      Result := Format(GsCppFunct2, [GsFnNot, ParseElement(True)]);
    end;
  end else begin
    if ParseSign = NegativeValue then
    begin
      Result := CharMinusSign;
    end else begin
      Result := EmptyStr;
    end;
    if IsToken(CharOpeningParenthesis) then
    begin
      Result += ParseParenthesis;
    end else if IsNumberHead then
    begin
      Result += ParseConstantNumber;
    end else if IsToken(CharHash) then
    begin
      Result += ParseHashSpecial;
    end else if IsVariable then
    begin
      Result += ParseVariable;
    end else if IsFunctionCall then
    begin
      Result += ParseFunctionCall;
    end else if IsStringHead then
    begin
      Result += ParseConstantString;
    end else if IsCharHead then
    begin
      Result += ParseConstantChar;
    end;
    ParseArrayIndex(Result);
  end;
  LogIfExpectNotEmptyStr(AIsExpected, Result, SMsgElement);
end;

function CJes2CppParserFunctions.ParseExpression(const AIsExpected: Boolean): String;
begin
  Result := ParseOperator(False);
  if IsTokenThenPull(CharQuestionMark) then
  begin
    Result := CharOpeningParenthesis + Format(GsCppFunct2, [GsFnIf, Result]) + CharSpace + CharQuestionMark +
      CharSpace + ParseExpression(True) + CharSpace + CharColon + CharSpace;
    if IsTokenThenPull(CharColon) then
    begin
      Result += ParseExpression(True);
    end else begin
      Result += GsCppNop;
    end;
    Result += CharClosingParenthesis;
  end;
  LogIfExpectNotEmptyStr(AIsExpected, Result, SMsgExpression);
end;

end.

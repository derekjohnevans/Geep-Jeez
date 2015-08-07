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
  Classes, Jes2CppConstants, Jes2CppEel, Jes2CppFunction, Jes2CppFunctionIdentifiers,
  Jes2CppIdentifier, Jes2CppIdentString,
  Jes2CppParserLoops, Jes2CppStrings, Jes2CppTranslate, Math, StrUtils, SysUtils;

type

  CJes2CppParserFunctions = class(CJes2CppParserLoops)
  strict private
    FForceGlobals: Boolean;
  strict private
    function ParseFunctionCall: String;
    function ParseFunctionCallExpressions: TArrayOfString;
  strict private
    procedure ParseFunctionDefine;
    procedure ParseVariableDefines(const AIdentifiers: CJes2CppFunctionIdentifiers;
      const ACanHaveRef: Boolean);
  protected
    function ParseElement(const AIsExpected: Boolean): String; override;
    function ParseExpression(const AIsExpected: Boolean): String; override;
    function ParseSectionBody: String;
  public
    property ForceGlobals: Boolean write FForceGlobals;
  end;

implementation

procedure CJes2CppParserFunctions.ParseVariableDefines(
  const AIdentifiers: CJes2CppFunctionIdentifiers; const ACanHaveRef: Boolean);
var
  LIdent: TIdentString;
  LDataType: String;
  LIsParams: Boolean;
begin
  LIsParams := AIdentifiers = FCurrentFunction.Params;
  ExpectToken(CharOpeningParenthesis);
  while not IsToken(CharClosingParenthesis) do
  begin
    if LIsParams then
    begin
      LDataType := ParseCppExtension;
    end else begin
      // TODO: Should we be setting a default value here?
      LDataType := EmptyStr;
    end;
    if LIsParams and IsToken(GsEelVariadic) then
    begin
      LogAssert(AIdentifiers.HasComponents, SMsgVariadicFunctionsMustHaveAtLeastOneParameter);
      LogAssert(not AIdentifiers.IsVariadic, SMsgVariadicEllipsisHasAlreadyBeenUsed);
      LIdent := PullToken;
    end else begin
      LogAssert(not AIdentifiers.IsVariadic, SMsgVariadicEllipsisMustBeTheLastParameter);
      LIdent := PullIdentVariable;
    end;
    if ACanHaveRef and IsToken(CharAsterisk) then
    begin
      LIdent += PullToken;
    end;
    LogAssert(not AnsiMatchText(GIdentString.Clean(LIdent), GaEelKeywords),
      SMsgKeywordsCantBeUsedAsIdentNames);
    LogAssert(not FCurrentFunction.Globals.ComponentExists(LIdent),
      Format(SMsgAlreadyDefinedAsGlobal1, [GIdentString.Clean(LIdent)]));
    LogAssert(not FCurrentFunction.Instances.ExistsIdent(LIdent, Self),
      Format(SMsgAlreadyDefinedAsInstance1, [GIdentString.Clean(LIdent)]));
    LogAssert(not FCurrentFunction.Locals.ExistsIdent(LIdent, Self),
      Format(SMsgAlreadyDefinedAsLocal1, [GIdentString.Clean(LIdent)]));
    LogAssert(not FCurrentFunction.Params.ExistsIdent(LIdent, Self),
      Format(SMsgAlreadyDefinedAsParameter1, [GIdentString.Clean(LIdent)]));
    LogAssert(not FCurrentFunction.Statics.ExistsIdent(LIdent, Self),
      Format(SMsgAlreadyDefinedAsStatic1, [GIdentString.Clean(LIdent)]));

    AIdentifiers.CreateComponent(LIdent).DataType := LDataType;

    if not IsToken(CharClosingParenthesis) then
    begin
      IsTokenThenPull(CharComma);
    end;
  end;
  ExpectToken(CharClosingParenthesis);
end;

procedure CJes2CppParserFunctions.ParseFunctionDefine;
var
  LDataType, LComment: String;
begin
  ExpectToken(GsEelFunction);
  LogAssert(not Assigned(FCurrentFunction), SMsgFunctionDefinedInsideFunction);
  LComment := CurrentComment;
  LDataType := ParseCppExtension;
  FCurrentFunction := Functions.CreateComponent(PullIdentFunction);
  try
    FCurrentFunction.Comment := LComment;
    FCurrentFunction.References.CreateReference(FileSource, FileCaretY);
    FCurrentFunction.ForceGlobals := FForceGlobals;
    FCurrentFunction.DataType := LDataType;
    ParseVariableDefines(FCurrentFunction.Params, True);
    LogAssert(Functions.FindFunction(FCurrentFunction.Name,
      FCurrentFunction.Params.ComponentCount) = FCurrentFunction,
      Format(SMsgFunctionasDuplicateOverloads1, [FCurrentFunction.Name]));
    repeat
      if IsTokenThenPull(GsEelLocal) then
      begin
        ParseVariableDefines(FCurrentFunction.Locals, False);
      end else if IsTokenThenPull(GsEelStatic) then
      begin
        ParseVariableDefines(FCurrentFunction.Statics, False);
      end else if IsTokenThenPull(GsEelInstance) then
      begin
        ParseVariableDefines(FCurrentFunction.Instances, False);
      end else if IsTokenThenPull(GsEelGlobal) or IsTokenThenPull(GsEelGlobals) then
      begin
        ParseVariableDefines(FCurrentFunction.Globals, True);
        FCurrentFunction.HasGlobals := True;
      end else begin
        Break;
      end;
    until False;
    FCurrentFunction.InstancesAll.CopyFrom(FCurrentFunction.Instances);
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
  SetLength(Result.Items, ZeroValue);
  FParameterAssignmentCount := ZeroValue;
  while not IsToken(CharClosingParenthesis) do
  begin
    if Result.Count > ZeroValue then
    begin
      ExpectToken(CharComma);
    end;
    Result.Append(ParseExpression(True));
  end;
  if (Result.Count > 1) and (FParameterAssignmentCount > ZeroValue) then
  begin
    LogException(SMsgAssignmentsInFunctionCall);
  end;
end;

function CJes2CppParserFunctions.ParseFunctionCall: String;
var
  LIndex: Integer;
  LIdent, LFunctName, LNameSpace, LThisSpace: TIdentString;
  LExpression: String;
  LExpressions: TArrayOfString;
  LFunction: CJes2CppFunction;
  LComponent: TComponent;
begin
  LIdent := PullIdentFunction;
  ExpectToken(CharOpeningParenthesis);
  // Check to see if function name is defined as an instance. In which case, treat the function
  // call as this.ident
  if Assigned(FCurrentFunction) and FCurrentFunction.Instances.IsNameSpaceMatch(
    LIdent + CharDot) then
  begin
    LIdent := GsEelSpaceThis + LIdent;
  end;
  // Check to see if function is a midi function. In which case, we indicate that the plugin requires
  // synth support.
  if AnsiMatchText(LIdent, GaEelFunctionsMidi) and not IsJes2CppInc then
  begin
    Description.FIsSynth := True;
  end;
  // Parse the function call expressions.
  LExpressions := ParseFunctionCallExpressions;
  // We can now search for the function overload. We require the number of expressions before we can
  // find the actual function called.
  LFunction := Functions.FindOverload(LIdent, LNameSpace, LFunctName, LExpressions.Count);
  // Assert that we found a function overload.
  LogAssert(Assigned(LFunction), Format(SMsgUnableToFindFunction1, [LIdent]));
  // Warn if the found function name is not the same case.
  LogWarningCaseCheck(LFunctName, LFunction.Name);
  // Handle global filtering. Im unsure how I ever wrote this line of code.
  if not SameText(LNameSpace, LFunction.DefaultNameSpace) and not
    GIdentString.IsNameSpaceThis(LNameSpace) and Assigned(FCurrentFunction) and
    FCurrentFunction.HasGlobals and not FCurrentFunction.Globals.ComponentExistsMaskDest(
    LIdent, WarningsAsErrors) then
  begin
    LogException(Format(SMsgNamespaceNotAccessible1, [GIdentString.Clean(LNameSpace)]));
  end;
  // Create a new source file reference for the function.
  LFunction.References.CreateReference(FileSource, FileCaretY);
  if LFunction.IdentType = itInternal then
  begin
    if Assigned(FCurrentFunction) and GIdentString.IsNameSpaceThis(LNameSpace) then
    begin
      LThisSpace := Copy(LNameSpace, Length(GsEelSpaceThis) + 1, MaxInt);
      // The following handles a strange quirk in Jesusonic, which is difficult to explain.
      if GIdentString.IsNameSpace(LThisSpace, FCurrentFunction.GetNameSpace) then
      begin
        //LogHint('Expermental namespace case 1');
        LThisSpace := Copy(LThisSpace, Length(FCurrentFunction.GetNameSpace) + 1, MaxInt);
        LNameSpace := GsEelSpaceThis + LThisSpace;
      end else if GIdentString.IsNameSpace(FCurrentFunction.GetNameSpace, LThisSpace) then
      begin
        LogHint('Expermental namespace case 2');
        Beep;
        LThisSpace := EmptyStr;
        LNameSpace := GsEelSpaceThis;
      end;
      // Add the instances of the called function to the caller function.
      for LComponent in LFunction.InstancesAll do
      begin
        FCurrentFunction.AppendInstance(LThisSpace + LComponent.Name, Self);
      end;
    end else begin
      for LComponent in LFunction.InstancesAll do
      begin
        FindOrCreateVariable(LNameSpace + LComponent.Name, FileSource, FileCaretY,
          CurrentComment, False);
      end;
    end;
  end;
  Result := EmptyStr;
  for LExpression in LExpressions.Items do
  begin
    GString.AppendCSV(Result, LExpression);
  end;
  for LComponent in LFunction.InstancesAll do
  begin
    if LComponent.Name = EmptyStr then
    begin
      if GIdentString.IsSample(LNameSpace, LIndex) then
      begin
        GString.AppendCSV(Result, Format(GsCppSamples1, [LIndex]));
      end else if GIdentString.IsSlider(LNameSpace, LIndex) then
      begin
        GString.AppendCSV(Result, Format(GsCppSliders1, [LIndex]));
      end else begin
        GString.AppendCSV(Result, GCpp.Encode.NameVariable(LNameSpace));
      end;
    end else begin
      GString.AppendCSV(Result, GCpp.Encode.NameVariable(LNameSpace + LComponent.Name));
    end;
  end;
  Result := LFunction.CppFunctionName + CharOpeningParenthesis + Result + CharClosingParenthesis;
  ExpectToken(CharClosingParenthesis);
end;

function CJes2CppParserFunctions.ParseElement(const AIsExpected: Boolean): String;
var
  LSign: String;
begin
  if IsTokenThenPull(CharExclamation) then
  begin
    if IsStringHead then
    begin
      Result := ParseCppString;
    end else begin
      Result := Format(GsCppFunct2, [GsFnNot, ParseElement(True)]);
    end;
  end else begin
    LSign := ParseSign;
    if IsToken(CharOpeningParenthesis) then
    begin
      Result := ParseParenthesis;
    end else if IsNumberHead then
    begin
      Result := ParseLiteralNumber;
    end else if IsToken(CharHash) then
    begin
      Result := ParseHashVariable;
    end else if IsVariable then
    begin
      Result := ParseVariable;
    end else if IsFunctionCall then
    begin
      if IsToken(GsEelWhile) then
      begin
        Result := ParseWhile;
      end else if IsToken(GsEelLoop) then
      begin
        Result := ParseLoop;
      end else begin
        Result := ParseFunctionCall;
      end;
    end else if IsStringHead then
    begin
      Result := ParseLiteralString;
    end else if IsCharHead then
    begin
      Result := ParseLiteralChar;
    end else if LSign <> EmptyStr then
    begin
      LogExpected(SMsgElement);
    end;
    ParseArrayIndex(Result);
    Result := LSign + Result;
  end;
  LogIfExpectNotEmptyStr(AIsExpected, Result, SMsgElement);
end;

function CJes2CppParserFunctions.ParseExpression(const AIsExpected: Boolean): String;
begin
  Result := ParseOperator(False);
  if IsTokenThenPull(CharQuestionMark) then
  begin
    Result := CharOpeningParenthesis + Format(GsCppFunct2, [GsFnIf, Result]) +
      CharSpace + CharQuestionMark + CharSpace + ParseExpression(True) +
      CharSpace + CharColon + CharSpace;
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

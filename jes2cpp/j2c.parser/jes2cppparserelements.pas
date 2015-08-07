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

unit Jes2CppParserElements;

{$MODE DELPHI}

interface

uses
  Classes, Jes2CppConstants, Jes2CppEel, Jes2CppFunction, Jes2CppIdentifier, Jes2CppIdentString,
  Jes2CppParserOperator, Jes2CppTranslate, Jes2CppVariable, Math, StrUtils, SysUtils;

type

  CJes2CppParserElements = class(CJes2CppParserOperator)
  strict private
    FStringConstCount, FHashVariableCount: Integer;
    FFunctions: CJes2CppFunctions;
    FVariables: CJes2CppVariables;
  protected
    FCurrentFunction: CJes2CppFunction;
  protected
    function ParseLiteralChar: String;
    function ParseLiteralNumber: String;
    function ParseLiteralString: String;
    function ParseHashVariable: String;
    function ParseVariable: String;
    procedure ParseArrayIndex(var AResult: String);
    function FindOrCreateVariable(const AName: TComponentName; const AFileSource: TFileName;
      const AFileCaretY: Integer; const AComment: String;
      const AUnassignedNotice: Boolean): CJes2CppVariable;
  protected
    procedure DoCreate; override;
  public
    property Functions: CJes2CppFunctions read FFunctions;
    property Variables: CJes2CppVariables read FVariables;
  end;

implementation

procedure CJes2CppParserElements.DoCreate;
begin
  inherited DoCreate;
  FFunctions := CJes2CppFunctions.Create(Self);
  FVariables := CJes2CppVariables.Create(Self);
end;

function CJes2CppParserElements.ParseLiteralChar: String;
var
  LChar: Char;
  LValue: Extended;
begin
  LogAssertExpected(IsCharHead, SMsgLiteralChar);
  Result := GCpp.Decode.QuotedString(PullToken);
  LogAssert(InRange(Length(Result), 1, 4), SMsgLiteralCharsMustBe);
  LValue := 0;
  for LChar in Result do
  begin
    LValue := (LValue * 256) + Ord(LChar);
  end;
  Result := GCpp.Encode.Float(LValue);
end;

function CJes2CppParserElements.ParseLiteralNumber: String;
begin
  LogAssertExpected(IsNumberHead, SMsgLiteralNumber);
  try
    Result := GCpp.Encode.Float(CurrentToken);
  except
    LogException(Format(SMsgInvalidNumber1, [CurrentToken]));
  end;
  NextToken;
end;

function CJes2CppParserElements.ParseLiteralString: String;
var
  LVariable: CJes2CppVariable;
begin
  LogAssertExpected(IsStringHead, SMsgLiteralString);
  Inc(FStringConstCount);
  LVariable := FVariables.CreateVariable(GsEelSpaceStringLiteral +
    IntToHex(FStringConstCount, 4) + CharDot, FileSource, FileCaretY, CurrentComment);
  LVariable.StringLiteral := PullToken;
  while IsStringHead do
  begin
    LVariable.StringLiteral := LVariable.StringLiteral + LineEnding + PullToken;
  end;
  Result := GCpp.Encode.Float(LVariable.DefaultValue);
end;

function CJes2CppParserElements.ParseHashVariable: String;
var
  LVariable: CJes2CppVariable;
begin
  LogAssertExpected(IsTokenThenPull(CharHash), SMsgHashSymbol);
  Inc(FHashVariableCount);
  LVariable := FVariables.CreateVariable(GsEelSpaceStringHash +
    IntToHex(FHashVariableCount, 4) + CharDot, FileSource, FileCaretY, CurrentComment);
  LVariable.StringLiteral := CharQuoteDouble + CharQuoteDouble;
  Result := GCpp.Encode.Float(LVariable.DefaultValue);
end;

procedure CJes2CppParserElements.ParseArrayIndex(var AResult: String);
begin
  while IsTokenThenPull(CharOpeningBracket) do
  begin
    LogExpectNotEmptyStr(AResult, SMsgArrayElement);
    if IsToken(CharClosingBracket) then
    begin
      AResult := Format(GsCppFunct3, [GsFnMem, AResult, GsCppZero]);
    end else begin
      AResult := Format(GsCppFunct3, [GsFnMem, AResult, ParseExpression(True)]);
    end;
    ExpectToken(CharClosingBracket);
  end;
end;

function CJes2CppParserElements.FindOrCreateVariable(const AName: TComponentName;
  const AFileSource: TFileName; const AFileCaretY: Integer; const AComment: String;
  const AUnassignedNotice: Boolean): CJes2CppVariable;
var
  LAlreadyCreated: Boolean;
begin
  Result := FVariables.FindOrCreateVariable(AName, AFileSource, AFileCaretY,
    AComment, LAlreadyCreated);
  LogWarningCaseCheck(AName, Result.Name);
  if AUnassignedNotice and not LAlreadyCreated and not (IsToken(CharEqualSign) or
    IsToken(GsEelExtern)) then
  begin
    LogHint(Format(SMsgVariableUsedBeforeAssignment1, [GIdentString.Clean(AName)]));
  end;
end;

function CJes2CppParserElements.ParseVariable: String;
var
  LIndex: Integer;
  LVariable: CJes2CppVariable;
begin
  Result := PullIdentVariable;
  if Assigned(FCurrentFunction) then
  begin
    if FCurrentFunction.Instances.IsNameSpaceMatch(Result) then
    begin
      Result := GsEelSpaceThis + Result;
    end;
    // Another quirk in Jesusonic. When you accessing the var 'this.' from within a function,
    // the result is the same as using 'this'. So, lets disable the behaviour.
    if SameText(Result, GsEelSpaceThis + CharDot) then
    begin
      LogException(Format(SMsgGlobalVariableNotAccessible1, [GIdentString.Clean(Result)]));
    end;
    if GIdentString.IsNameSpaceThis(Result) then
    begin
      FCurrentFunction.AppendInstance(Copy(Result, Length(GsEelSpaceThis) + 1, MaxInt), Self);
    end;
  end;
  if Assigned(FCurrentFunction) and FCurrentFunction.IsNameLocal(Result, Self) then
  begin
    Result := GCpp.Encode.NameVariable(Result);
  end else begin
    LogAssert(not AnsiMatchText(GIdentString.Clean(Result), GaEelKeywords),
      SMsgKeywordsCantBeUsedAsIdentNames);
    if Assigned(FCurrentFunction) and (FCurrentFunction.ForceGlobals or
      FCurrentFunction.HasGlobals) and not FCurrentFunction.Globals.ComponentExistsMaskDest(
      Result, WarningsAsErrors) then
    begin
      LogException(Format(SMsgGlobalVariableNotAccessible1, [GIdentString.Clean(Result)]));
    end;
    LVariable := FindOrCreateVariable(Result, FileSource, FileCaretY, CurrentComment, True);
    if IsTokenThenPull(GsEelExtern) then
    begin
      LVariable.IdentType := itExternal;
    end;
    if GIdentString.IsSample(Result, LIndex) then
    begin
      if LVariable.References.ComponentCount > 1 then
      begin
        Description.FChannelCount := Max(Description.FChannelCount, LIndex + 1);
      end;
      Result := Format(GsCppSamples1, [LIndex]);
    end else if GIdentString.IsSlider(Result, LIndex) then
    begin
      Result := Format(GsCppSliders1, [LIndex]);
    end else begin
      Result := GCpp.Encode.NameVariable(Result);
    end;
  end;
end;

end.

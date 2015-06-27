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
    FStringConstCount, FStringTempCount: Integer;
    FFunctions: CJes2CppFunctions;
    FVariables: CJes2CppVariables;
  protected
    FCurrentFunction: CJes2CppFunction;
  protected
    function ParseLiteralChar: String;
    function ParseLiteralNumber: String;
    function ParseLiteralString: String;
    function ParseHashSpecial: String;
    function ParseVariable: String;
    procedure ParseArrayIndex(var AResult: String);
    function FindOrCreateVariable(const AName: TComponentName; const AFileSource: TFileName; const AFileCaretY: Integer;
      const AComment: String; const AUnassignedNotice: Boolean): CJes2CppVariable;
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
  Result := CppDecodeString(PullToken);
  LogAssert(InRange(Length(Result), 1, 4), SMsgLiteralCharsMustBe);
  LValue := 0;
  for LChar in Result do
  begin
    LValue := (LValue * 256) + Ord(LChar);
  end;
  Result := CppEncodeFloat(LValue);
end;

function CJes2CppParserElements.ParseLiteralNumber: String;
begin
  LogAssertExpected(IsNumberHead, SMsgLiteralNumber);
  try
    Result := CppEncodeFloat(CurrentToken);
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
  LVariable := FVariables.CreateVariable(GsEelSpaceStringLiteral + IntToHex(FStringConstCount, 4) + CharDot,
    FileSource, FileCaretY, CurrentComment);
  LVariable.ConstantString := PullToken;
  while IsStringHead do
  begin
    LVariable.ConstantString := LVariable.ConstantString + LineEnding + PullToken;
  end;
  Result := CppEncodeVariable(LVariable.Name);
end;

function CJes2CppParserElements.ParseHashSpecial: String;
var
  LVariable: CJes2CppVariable;
begin
  LogAssertExpected(IsTokenThenPull(CharHash), SMsgHashSymbol);
  Inc(FStringTempCount);
  LVariable := FVariables.CreateVariable(GsEelSpaceStringTemp + IntToHex(FStringTempCount, 4) + CharDot,
    FileSource, FileCaretY, CurrentComment);
  LVariable.ConstantString := CharQuoteDouble + CharQuoteDouble;
  Result := CppEncodeVariable(LVariable.Name);
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

function CJes2CppParserElements.FindOrCreateVariable(const AName: TComponentName; const AFileSource: TFileName;
  const AFileCaretY: Integer; const AComment: String; const AUnassignedNotice: Boolean): CJes2CppVariable;
var
  LAlreadyCreated: Boolean;
begin
  Result := FVariables.FindOrCreateVariable(AName, AFileSource, AFileCaretY, AComment, LAlreadyCreated);
  LogWarningCaseCheck(AName, Result.Name);
  if AUnassignedNotice and not LAlreadyCreated and not (IsToken(CharEqualSign) or IsToken(GsEelExtern)) then
  begin
    LogNotice(Format(SMsgVariableUsedBeforeAssignment1, [J2C_IdentClean(AName)]));
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
    if J2C_IdentIsNameSpaceThis(Result) then
    begin
      FCurrentFunction.AppendInstance(Copy(Result, Length(GsEelSpaceThis) + 1, MaxInt), Self);
    end;
  end;
  if Assigned(FCurrentFunction) and FCurrentFunction.IsNameLocal(Result, Self) then
  begin
    Result := CppEncodeVariable(Result);
  end else begin
    LogAssert(not AnsiMatchText(J2C_IdentClean(Result), GaEelKeywords), SMsgKeywordsCantBeUsedAsIdentNames);
    if Assigned(FCurrentFunction) and (FCurrentFunction.ForceGlobals or FCurrentFunction.HasGlobals) and
      not FCurrentFunction.Globals.ComponentExistsMaskDest(Result, WarningsAsErrors) then
    begin
      LogException(Format(SMsgGlobalVariableNotAccessible1, [J2C_IdentClean(Result)]));
    end;
    LVariable := FindOrCreateVariable(Result, FileSource, FileCaretY, CurrentComment, True);
    if IsTokenThenPull(GsEelExtern) then
    begin
      LVariable.IdentType := itExternal;
    end;
    if J2C_IdentIsSample(Result, LIndex) then
    begin
      if LVariable.References.ComponentCount > 1 then
      begin
        Description.FChannelCount := Max(Description.FChannelCount, LIndex + 1);
      end;
      Result := Format(GsCppSamples1, [LIndex]);
    end else if J2C_IdentIsSlider(Result, LIndex) then
    begin
      Result := Format(GsCppSliders1, [LIndex]);
    end else begin
      Result := CppEncodeVariable(Result);
    end;
  end;
end;

end.

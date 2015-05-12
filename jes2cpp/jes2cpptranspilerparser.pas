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

unit Jes2CppTranspilerParser;

{$MODE DELPHI}

interface

uses
  Classes, Jes2CppConstants, Jes2CppDescription, Jes2CppEel, Jes2CppFunction, Jes2CppIdentifier, Jes2CppLoop, Jes2CppOperatorParser,
  Jes2CppTranslate, Jes2CppUtils, Jes2CppVarArray, Jes2CppVariable, Math, StrUtils, SysUtils;

type

  CJes2CppTranspilerParser = class(CJes2CppOperatorParser)
  strict private
    FImportFileNames: TStringList;
    FConstStringCount, FHashStringCount: Integer;
    FDescription: CJes2CppDescription;
    FLoops: CJes2CppLoops;
    FFunctions: CJes2CppFunctions;
    FVariables: CJes2CppVariables;
    FCurrentFunction: CJes2CppFunction;
  strict private
    function ParseExpressionBlock(out AReturnExpression: String): String; overload;
    function ParseExpressionBlock: String; overload;
    function ParseFunctionCall: String;
    function ParseFunctionCallParameters: TVariableArray;
    function ParseSectionBody: String;
    function ParseStatement(const AIsExpected: Boolean): String;
    function ParseStatementBlock: String;
    function ParseVariable: String;
    procedure ParseFunctionDefine;
    procedure ParseVariableDefines(var AArray: TVariableArray; const AIsCommasRequired: Boolean);
  protected
    function ParseElement(const AIsExpected: Boolean): String; override;
    function ParseExpression(const AIsExpected: Boolean): String; override;
  protected
    procedure ImportFrom(const AScript: TStrings; const AFileName: TFileName; const ALevel: Integer = 0);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  public
    function ParseSection(const ASectionName, AFunctionName, ASection, AFileName: String): String;
  public
    property Description: CJes2CppDescription read FDescription;
    property Functions: CJes2CppFunctions read FFunctions;
    property Loops: CJes2CppLoops read FLoops;
    property Variables: CJes2CppVariables read FVariables;
  end;

implementation

constructor CJes2CppTranspilerParser.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDescription := CJes2CppDescription.Create(Self);
  FFunctions := CJes2CppFunctions.Create(Self);
  FLoops := CJes2CppLoops.Create(Self);
  FVariables := CJes2CppVariables.Create(Self);
  FImportFileNames := TStringList.Create;
  FImportFileNames.Sorted := True;
end;

destructor CJes2CppTranspilerParser.Destroy;
begin
  FreeAndNil(FImportFileNames);
  // NOTE: All other objects are components, do they dont need to be destroyed here.
  inherited Destroy;
end;

procedure CJes2CppTranspilerParser.ParseVariableDefines(var AArray: TVariableArray; const AIsCommasRequired: Boolean);
var
  LVariableName: String;
begin
  ExpectToken(CharOpeningParenthesis);
  while not IsToken(CharClosingParenthesis) do
  begin
    if not IsIdent then
    begin
      LogExpected(SMsgIdentifier);
    end;
    LVariableName := PullVariableName;
    if FCurrentFunction.FParams.Exists(LVariableName) then
    begin
      LogException(Format(SMsgAlreadyDefinedAsParameter1, [LVariableName]));
    end;
    if FCurrentFunction.FLocals.Exists(LVariableName) then
    begin
      LogException(Format(SMsgAlreadyDefinedAsLocal1, [LVariableName]));
    end;
    if FCurrentFunction.FInstances.Exists(LVariableName) then
    begin
      LogException(Format(SMsgAlreadyDefinedAsInstance1, [LVariableName]));
    end;
    if AArray.Exists(LVariableName) then
    begin
      LogException(Format(SMsgAlreadyDefined1, [LVariableName]));
    end;
    if IsToken('*') then
    begin
      LVariableName := LVariableName + PullToken;
    end;
    AArray.Append(LVariableName, True);
    if not IsToken(CharClosingParenthesis) then
    begin
      if AIsCommasRequired then
      begin
        ExpectToken(CharComma);
      end else begin
        IsTokenThenPull(CharComma);
      end;
    end;
  end;
  ExpectToken(CharClosingParenthesis);
end;

procedure CJes2CppTranspilerParser.ParseFunctionDefine;
begin
  ExpectToken(SEelFunction);
  if Assigned(FCurrentFunction) then
  begin
    LogException(SMsgFunctionDefinedInsideFunction);
  end;
  if not IsIdent then
  begin
    LogExpected(SMsgIdentifier);
  end;
  FCurrentFunction := CJes2CppFunction.Create(FFunctions);
  FCurrentFunction.Name := PullToken;
  FCurrentFunction.References.AddReference(FileName, FileLine);
  try
    ParseVariableDefines(FCurrentFunction.FParams, True);
    if FFunctions.FindFunction(FCurrentFunction.Name, FCurrentFunction.FParams.Count) <> FCurrentFunction then
    begin
      LogException(Format(SMsgFunctionasDuplicateOverloads1, [FCurrentFunction.Name]));
    end;
    while IsToken(SEelLocal) or IsToken(SEelInstance) do
    begin
      if IsTokenThenPull(SEelLocal) then
      begin
        ParseVariableDefines(FCurrentFunction.FLocals, False);
      end else if IsTokenThenPull(SEelInstance) then
      begin
        ParseVariableDefines(FCurrentFunction.FInstances, False);
        FCurrentFunction.FAllInstances.FItems := Copy(FCurrentFunction.FInstances.FItems);
      end;
    end;
    FCurrentFunction.FBody := ParseExpressionBlock(FCurrentFunction.FReturnExpression);
  finally
    FCurrentFunction := nil;
  end;
end;

function CJes2CppTranspilerParser.ParseExpressionBlock(out AReturnExpression: String): String;
var
  LExpression: String;
begin
  Result := EmptyStr;
  AReturnExpression := EmptyStr;
  ExpectToken(CharOpeningParenthesis);
  repeat
    LExpression := ParseStatement(False);
    if Length(LExpression) > M_ZERO then
    begin
      if Length(AReturnExpression) > M_ZERO then
      begin
        Result += AReturnExpression + SCppEol + LineEnding;
        AReturnExpression := EmptyStr;
      end;
      AReturnExpression := LExpression;
    end;
  until not IsTokenThenPull(CharSemiColon);
  ExpectToken(CharClosingParenthesis);
  if Length(AReturnExpression) = M_ZERO then
  begin
    LogException(SMsgExpressionBlockMissingReturn);
  end;
end;

function CJes2CppTranspilerParser.ParseExpressionBlock: String;
var
  LReturnExpression: String;
begin
  Result := ParseExpressionBlock(LReturnExpression);
  Result += LReturnExpression + SCppEol + LineEnding;
end;

function CJes2CppTranspilerParser.ParseSectionBody: String;
var
  LExpression: String;
begin
  Result := EmptyStr;
  repeat
    if SameText(CurrentToken, SEelFunction) then
    begin
      ParseFunctionDefine;
    end else begin
      LExpression := ParseStatement(False);
      if Length(LExpression) > M_ZERO then
      begin
        Result += LExpression + SCppEol + LineEnding;
      end;
    end;
  until not IsTokenThenPull(CharSemiColon);
end;

function CJes2CppTranspilerParser.ParseSection(const ASectionName, AFunctionName, ASection, AFileName: String): String;
begin
  LogMessage(SMsgTypeParsing, EelSection(ASectionName));
  ResetParser(ASection, AFileName);
  Result := SCppVoidSpace + AFunctionName + '()' + LineEnding + CharOpeningBrace + LineEnding;
  Result += STJes2Cpp + '::' + AFunctionName + '();' + LineEnding;
  Result += ParseSectionBody + CharClosingBrace + LineEnding;
  if not IsNull then
  begin
    LogExpected(SMsgEndOfCode);
  end;
end;

function CJes2CppTranspilerParser.ParseFunctionCallParameters: TVariableArray;
begin
  SetLength(Result.FItems, M_ZERO);
  FParameterAssignmentCount := M_ZERO;
  while not IsToken(CharClosingParenthesis) do
  begin
    if Result.Count > M_ZERO then
    begin
      ExpectToken(CharComma);
    end;
    Result.Append(ParseExpression(True), False);
  end;
  if (Result.Count > 1) and (FParameterAssignmentCount > M_ZERO) then
  begin
    LogException(SMsgMultipleAssignmentsInFunctionCall);
  end;
end;

function CJes2CppTranspilerParser.ParseFunctionCall: String;
var
  LIndex: Integer;
  LFunctName, LNameSpace: String;
  LParams: TVariableArray;
  LFunction: CJes2CppFunction;
  LLoop: CJes2CppLoop;
begin
  if IsTokenThenPull(SEelWhile) then
  begin
    LLoop := CJes2CppLoop.Create(FLoops, ltDoWhile, FCurrentFunction);
    LLoop.FBody := ParseExpressionBlock(LLoop.FCondition);
    if IsToken(CharOpeningParenthesis) then
    begin
      LLoop.FType := ltWhile;
      LLoop.FPreCondition := LLoop.FBody;
      LLoop.FBody := ParseExpressionBlock;
    end;
    Result := LLoop.CppCall;
  end else if IsTokenThenPull(SEelLoop) then
  begin
    LLoop := CJes2CppLoop.Create(FLoops, ltLoop, FCurrentFunction);
    ExpectToken(CharOpeningParenthesis);
    LLoop.FCondition := ParseStatement(True);
    ExpectToken(CharComma);
    LLoop.FBody := ParseSectionBody;
    ExpectToken(CharClosingParenthesis);
    Result := LLoop.CppCall;
  end else begin
    LFunctName := PullToken;
    if AnsiStartsStr(LFunctName, SEelGfx_) then
    begin
      FDescription.FIsGfx := True;
    end else if AnsiMatchText(LFunctName, GEelFunctionsMidi) then
    begin
      FDescription.FIsSynth := True;
    end else if AnsiMatchText(LFunctName, GEelFunctionsBass) then
    begin
      FDescription.FIsBass := True;
    end;
    if Assigned(FCurrentFunction) and FCurrentFunction.FInstances.IsNameSpaceMatch(LFunctName) then
    begin
      LFunctName := SEelThisRef + LFunctName;
    end;
    ExpectToken(CharOpeningParenthesis);
    LParams := ParseFunctionCallParameters;
    LFunction := FFunctions.FindFunction(LFunctName, LNameSpace, LParams.Count);
    if not Assigned(LFunction) then
    begin
      LogException(Format(SMsgUnableToFindFunction1, [LFunctName]));
    end;
    LFunction.References.AddReference(FileName, FileLine);
    if LFunction.IdentType = itUser then
    begin
      for LIndex := Low(LFunction.FAllInstances.FItems) to High(LFunction.FAllInstances.FItems) do
      begin
        if Assigned(FCurrentFunction) and AnsiStartsText(SEelThisRef, LNameSpace) then
        begin
          FCurrentFunction.FAllInstances.Append(Copy(LNameSpace, Length(SEelThisRef) + 1, MaxInt) +
            LFunction.FAllInstances.FItems[LIndex], True);
        end else begin
          FVariables.FindOrCreate(LNameSpace + LFunction.FAllInstances.FItems[LIndex], CJes2CppVariable, FileName, FileLine);
        end;
      end;
    end;
    Result := EmptyStr;
    for LIndex := Low(LParams.FItems) to High(LParams.FItems) do
    begin
      if Result <> EmptyStr then
      begin
        Result += SCppCommaSpace;
      end;
      Result += LParams.FItems[LIndex];
    end;
    for LIndex := Low(LFunction.FAllInstances.FItems) to High(LFunction.FAllInstances.FItems) do
    begin
      if Result <> EmptyStr then
      begin
        Result += SCppCommaSpace;
      end;
      Result += EelToCppVar(LNameSpace + LFunction.FAllInstances.FItems[LIndex], vtInstance);
    end;
    Result := EelToCppFun(LFunctName) + CharOpeningParenthesis + Result + CharClosingParenthesis;
    ExpectToken(CharClosingParenthesis);
  end;
end;

function CJes2CppTranspilerParser.ParseVariable: String;
var
  LIndex: Integer;
  LVariableName: String;
  LIdentifier: CJes2CppIdentifier;
begin
  Result := EmptyStr;
  LVariableName := PullVariableName;
  LIdentifier := FVariables.Find(LVariableName);
  if Assigned(LIdentifier) and (LIdentifier.IdentType = itSystem) then
  begin
    LIdentifier.References.AddReference(FileName, FileLine);
  end;
  if EelIsSliderIdent(LVariableName, LIndex) then
  begin
    Result += EelToCppVar(SEelVarSlider, vtGlobal) + CharOpeningBracket + IntToStr(LIndex) + CharClosingBracket;
  end else if EelIsSplIdent(LVariableName, LIndex) then
  begin
    Result += EelToCppVar(SEelVarSpl, vtGlobal) + CharOpeningBracket + IntToStr(LIndex) + CharClosingBracket;
    Description.FChannelCount := Max(Description.FChannelCount, LIndex + 1);
  end else begin
    if Assigned(LIdentifier) and (LIdentifier.IdentType = itSystem) then
    begin
      Result += EelToCppVar(LVariableName, vtGlobal);
    end else begin
      if Assigned(FCurrentFunction) then
      begin
        if FCurrentFunction.FInstances.IsNameSpaceMatch(LVariableName) then
        begin
          LVariableName := SEelThisRef + LVariableName;
        end;
        if AnsiStartsText(SEelThisRef, LVariableName) then
        begin
          FCurrentFunction.FAllInstances.Append(Copy(LVariableName, Length(SEelThisRef) + 1, MaxInt), True);
        end;
      end;
      if Assigned(FCurrentFunction) and FCurrentFunction.IsNameLocal(LVariableName) then
      begin
        Result += EelToCppVar(LVariableName, vtUnknown);
      end else begin
        FVariables.FindOrCreate(LVariableName, CJes2CppVariable, FileName, FileLine);
        Result += EelToCppVar(LVariableName, vtGlobal);
      end;
    end;
  end;
end;

function CJes2CppTranspilerParser.ParseElement(const AIsExpected: Boolean): String;
var
  LVariable: CJes2CppVariable;
begin
  if IsTokenThenPull(CharExclamation) then
  begin
    Result := Format(SCppFunct2, [SFnNot, ParseElement(True)]);
  end else begin
    if ParseSign = NegativeValue then
    begin
      Result := CharMinusSign;
    end else begin
      Result := EmptyStr;
    end;
    if IsToken(CharOpeningParenthesis) then
    begin
      Result += ParseStatementBlock;
    end else if IsNumber then
    begin
      try
        Result += EelToCppFloat(CurrentToken);
      except
        LogException(Format(SMsgInvalidNumber1, [CurrentToken]));
      end;
      NextToken;
    end else if IsTokenThenPull(SEelVarHash) then
    begin
      Inc(FHashStringCount);
      LVariable := FVariables.FindOrCreate(S_HashString + IntToHex(FHashStringCount, 4), CJes2CppVariable, FileName, FileLine) as
        CJes2CppVariable;
      LVariable.FConstantString := CharQuoteDouble + CharQuoteDouble;
      Result += EelToCppVar(LVariable.Name, vtGlobal);
    end else if IsVariable then
    begin
      Result += ParseVariable;
    end else if IsFunctionCall then
    begin
      Result += ParseFunctionCall;
    end else if IsString then
    begin
      Inc(FConstStringCount);
      LVariable := FVariables.FindOrCreate(S_ConstString + IntToHex(FConstStringCount, 4), CJes2CppVariable, FileName, FileLine) as
        CJes2CppVariable;
      LVariable.FConstantString := PullToken;
      while IsString do
      begin
        LVariable.FConstantString += LineEnding + PullToken;
      end;
      Result += EelToCppVar(LVariable.Name, vtGlobal);
    end else if IsMultiByteChar then
    begin
      Result += Format(SCppFunct2, [SFnChr, PullToken]);
    end;
    if IsTokenThenPull(CharOpeningBracket) then
    begin
      if IsToken(CharClosingBracket) then
      begin
        Result := Format(SCppFunct3, [SFnMem, Result, SEelZero]);
      end else begin
        Result := Format(SCppFunct3, [SFnMem, Result, ParseExpression(True)]);
      end;
      ExpectToken(CharClosingBracket);
    end;
  end;
  if AIsExpected then
  begin
    ExpectNotEmpty(Result, SMsgElement);
  end;
end;

function CJes2CppTranspilerParser.ParseExpression(const AIsExpected: Boolean): String;
begin
  Result := ParseOperator(False);
  if IsTokenThenPull(CharQuestionMark) then
  begin
    Result := Format('%s(%s) ' + SEelThen + ' %s ' + SEelElse + CharSpace, [SFnIf, Result, ParseStatement(True)]);
    if IsTokenThenPull(CharColon) then
    begin
      Result += ParseStatement(True);
    end else begin
      Result += SEelNop;
    end;
  end;
  if AIsExpected then
  begin
    ExpectNotEmpty(Result, SMsgExpression);
  end;
end;

function CJes2CppTranspilerParser.ParseStatement(const AIsExpected: Boolean): String;
begin
  FStatementAssignmentCount := 0;
  Result := ParseExpression(AIsExpected);
end;

function CJes2CppTranspilerParser.ParseStatementBlock: String;
begin
  ExpectToken(CharOpeningParenthesis);
  Result := EmptyStr;
  repeat
    if not (IsToken(CharSemiColon) or IsToken(CharClosingParenthesis)) then
    begin
      if Result <> EmptyStr then
      begin
        Result += SCppCommaSpace;
      end;
      Result += ParseStatement(True);
    end;
  until not IsTokenThenPull(CharSemiColon);
  ExpectToken(CharClosingParenthesis);
  ExpectNotEmpty(Result, SMsgStatementBlock);
  Result := CharOpeningParenthesis + Result + CharClosingParenthesis;
end;

procedure CJes2CppTranspilerParser.ImportFrom(const AScript: TStrings; const AFileName: TFileName; const ALevel: Integer);

var
  LIndex: Integer;
  LScript: TStrings;
  LFileName: TFileName;
begin
  if ALevel > 10 then
  begin
    LogException('Max Importing Depth Reached.');
  end else begin
    if FImportFileNames.IndexOf(AFileName) < 0 then
    begin
      LogFileName(SMsgTypeImporting, AFileName);
      for LIndex := First(AScript) to Last(AScript) do
      begin
        if EelIsSection(AScript[LIndex]) then
        begin
          Break;
        end;
        if EelIsImport(AScript[LIndex], LFileName) then
        begin
          LScript := TStringList.Create;
          try
            LFileName := EelFileNameResolve(LFileName, AFileName);
            LScript.LoadFromFile(LFileName);
            ImportFrom(LScript, LFileName, ALevel + 1);
          finally
            FreeAndNil(LScript);
          end;
        end;
      end;
      FDescription.ImportFrom(AScript, AFileName);
      FImportFileNames.Add(AFileName);
    end;
  end;
end;

end.

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

unit Jes2CppFunction;

{$MODE DELPHI}

interface

uses
  Classes, Jes2CppConstants, Jes2CppEel, Jes2CppEelConstants, Jes2CppIdentifier, Jes2CppTranslate, Jes2CppUtils,
  Jes2CppVarArray, StrUtils, SysUtils;

type

  CJes2CppFunction = class(CJes2CppIdentifier)
  public
    FMinParametersAllowed: Integer;
    FBody, FReturnExpression: String;
    FParams, FLocals, FInstances, FAllInstances: TVariableArray;
  strict private
    function CppParameters: String;
    function CppLocalVars: String;
  public
    constructor Create(AOwner: TComponent); override;
  public
    function EelDefine: String;
    function CppDefine: String;
    function IsNameLocal(const AName: TComponentName): Boolean;
  end;

  CJes2CppFunctions = class(CJes2CppIdentifiers)
  strict private
    function AddSystemFunction(const AName: TComponentName; const AParams: array of String): CJes2CppFunction;
  public
    constructor Create(AOwner: TComponent); override;
  public
    function GetFunction(const AIndex: Integer): CJes2CppFunction;
    function FindFunction(const AName: TComponentName; const ACount: Integer): CJes2CppFunction; overload;
    function FindFunction(var AName: TComponentName; out ANameSpace: String; const ACount: Integer): CJes2CppFunction; overload;
  end;

implementation

constructor CJes2CppFunction.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMinParametersAllowed := MaxInt;
end;

function CJes2CppFunction.EelDefine: String;
var
  LString: String;
begin
  Result := EmptyStr;
  for LString in FParams.FItems do
  begin
    if Result <> EmptyStr then
    begin
      Result += SCppCommaSpace;
    end;
    Result += EelCleanVarName(LString);
  end;
  Result := Name + '(' + Result + ')';
end;

function CJes2CppFunction.CppParameters: String;
var
  LString: String;
begin
  Result := EmptyStr;
  for LString in FParams.FItems do
  begin
    if Result <> EmptyStr then
    begin
      Result += SCppCommaSpace;
    end;
    Result += SEelReal + CharSpace + EelToCppVar(LString, vtParameter);
  end;
  for LString in FAllInstances.FItems do
  begin
    if Result <> EmptyStr then
    begin
      Result += SCppCommaSpace;
    end;
    Result += SEelReal + CharAmpersand + CharSpace + EelToCppVar(SEelThisRef + LString, vtInstance);
  end;
end;

function CJes2CppFunction.CppLocalVars: String;
var
  LString: String;
begin
  Result := EmptyStr;
  if FLocals.Count > M_ZERO then
  begin
    for LString in FLocals.FItems do
    begin
      if Result <> EmptyStr then
      begin
        Result += SCppCommaSpace;
      end;
      Result += EelToCppVar(LString, vtLocal) + SCppEqu + SEelZero;
    end;
    Result := SEelReal + CharSpace + Result + SCppEol + LineEnding;
  end;
end;

function CJes2CppFunction.CppDefine: String;
begin
  Result := Format(SCppInlineSpace + '%s %s(%s)' + LineEnding + '{' + LineEnding + '%s', [SEelReal, EelToCppFun(Name),
    CppParameters, CppLocalVars]);
  Result += FBody + SCppReturnSpace + FReturnExpression + SCppEol + LineEnding + '}' + LineEnding;
end;

function CJes2CppFunction.IsNameLocal(const AName: TComponentName): Boolean;
begin
  Result := AnsiStartsText(SEelThisRef, AName) or FParams.Exists(AName) or FLocals.Exists(AName);
end;

constructor CJes2CppFunctions.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  // Basic Math Functions

  AddSystemFunction(SEelFnAbs, [FpX]);
  AddSystemFunction(SEelFnACos, [FpX]);
  AddSystemFunction(SEelFnASin, [FpX]);
  AddSystemFunction(SEelFnATan, [FpX]);
  AddSystemFunction(SEelFnATan2, [FpX, FpY]);
  AddSystemFunction(SEelFnCeil, [FpX]);
  AddSystemFunction(SEelFnCos, [FpX]);
  AddSystemFunction(SEelFnExp, [FpX]);
  AddSystemFunction(SEelFnFloor, [FpX]);
  AddSystemFunction(SEelFnInvSqrt, [FpX]);
  AddSystemFunction(SEelFnLog, [FpX]);
  AddSystemFunction(SEelFnLog10, [FpX]);
  AddSystemFunction(SEelFnMax, [FpX, FpY]);
  AddSystemFunction(SEelFnMin, [FpX, FpY]);
  AddSystemFunction(SEelFnPow, [FpX, FpY]);
  AddSystemFunction(SEelFnRand, [FpX]);
  AddSystemFunction(SEelFnSign, [FpX]);
  AddSystemFunction(SEelFnSin, [FpX]);
  AddSystemFunction(SEelFnSliderChange, [FpIndex]);
  AddSystemFunction(SEelFnSpl, [FpIndex]);
  AddSystemFunction(SEelFnSqr, [FpX]);
  AddSystemFunction(SEelFnSqrt, [FpX]);
  AddSystemFunction(SEelFnTan, [FpX]);

  // Graphics Functions

  AddSystemFunction(SEelFnGfxBlit, [FpImage, FpScale, FpRotation, FpX + '1', FpY + '1', FpW + '1', FpH + '1', FpX +
    '2', FpY + '2', FpW + '2', FpH + '2']).FMinParametersAllowed := 3;
  AddSystemFunction(SEelFnGfxBlitExt, [FpImage, FpCoordList, FpRotation]);
  AddSystemFunction(SEelFnGfxBlurTo, [FpX, FpY]);
  AddSystemFunction(SEelFnGfxCircle, [FpX, FpY, FpRadius, FpFill]);
  AddSystemFunction(SEelFnGfxDrawChar, [FpChar]);
  AddSystemFunction(SEelFnGfxDrawNumber, [FpN, FpNumDigits]);
  AddSystemFunction(SEelFnGfxDrawStr, [FpSrc]);
  AddSystemFunction(SEelFnGfxGetImgDim, [FpImage, FpW, FpH]);
  AddSystemFunction(SEelFnGfxGetPixel, [FpR, FpG, FpB]);
  AddSystemFunction(SEelFnGfxGradRect, [FpX, FpY, FpW, FpH, FpR, FpG, FpB, FpA, FpR + '1', FpG + '1', FpB + '1',
    FpA + '1', FpR + '2', FpG + '2', FpB + '2', FpA + '2']);
  AddSystemFunction(SEelFnGfxLine, [FpX + '1', FpY + '1', FpX + '2', FpY + '2']);
  AddSystemFunction(SEelFnGfxLineTo, [FpX, FpY, FpAlias]).FMinParametersAllowed := 2;
  AddSystemFunction(SEelFnGfxLoadImg, [FpImage, FpFileName]);
  AddSystemFunction(SEelFnGfxMeasureStr, [FpSrc, FpW, FpH]);
  AddSystemFunction(SEelFnGfxPrintF, [FpFmt, SEelVariadic]).FMinParametersAllowed := 1;
  AddSystemFunction(SEelFnGfxRectTo, [FpX, FpY]);
  AddSystemFunction(SEelFnGfxRoundRect, [FpX, FpY, FpW, FpH, FpR]);
  AddSystemFunction(SEelFnGfxSetFont, [FpFont, FpName, FpSize, FpStyle]).FMinParametersAllowed := 1;
  AddSystemFunction(SEelFnGfxSetPixel, [FpR, FpG, FpB]);

  // Midi Functions (TODO: midisyx)

  AddSystemFunction(SEelFnMidiSend, [FpOffset, FpMsg1, FpMsg2]);
  AddSystemFunction(SEelFnMidiRecv, [FpOffset, FpMsg1, FpMsg2]);
  //AddSystemFunction('midisyx', ['offset', FpIndex, FpLength]);

  // MDCT Functions

  AddSystemFunction(SEelFnMdct, [FpIndex, FpLength]);
  AddSystemFunction(SEelFnMdctI, [FpIndex, FpLength]);

  // FFT Functions

  AddSystemFunction(SEelFnFft, [FpIndex, FpLength]);
  AddSystemFunction(SEelFnFftI, [FpIndex, FpLength]);
  AddSystemFunction(SEelFnFftPermute, [FpIndex, FpLength]);
  AddSystemFunction(SEelFnFftPermuteI, [FpIndex, FpLength]);
  AddSystemFunction(SEelFnFftConvolve, [FpDst, FpSrc, FpLength]);

  // Memory Functions

  AddSystemFunction(SEelFnMemCpy, [FpDst, FpSrc, FpLength]);
  AddSystemFunction(SEelFnMemSet, [FpDst, FpSrc, FpLength]);
  AddSystemFunction(SEelFnFreeMBuf, [FpLength]);

  // File Functions

  AddSystemFunction(SEelFnFileOpen, [FpIndex]);
  AddSystemFunction(SEelFnFileClose, [FpFile]);
  AddSystemFunction(SEelFnFileRewind, [FpFile]);
  AddSystemFunction(SEelFnFileVar, [FpFile, FpVar]);
  AddSystemFunction(SEelFnFileMem, [FpFile, FpIndex, FpLength]);
  AddSystemFunction(SEelFnFileAvail, [FpFile]);
  AddSystemFunction(SEelFnFileRiff, [FpFile, FpChannelCount, FpSampleRate]);
  AddSystemFunction(SEelFnFileText, [FpFile]);
  AddSystemFunction(SEelFnFileString, [FpFile, FpStr]);

  // Time Functions

  AddSystemFunction(SEelFnTime, [FpTimeStamp]).FMinParametersAllowed := 0;

  // String Functions

  AddSystemFunction(SEelFnStrLen, [FpSrc]);
  AddSystemFunction(SEelFnStrCpy, [FpDst, FpSrc]);
  AddSystemFunction(SEelFnStrCat, [FpDst, FpSrc]);
  AddSystemFunction(SEelFnStrCmp, [FpStr1, FpStr2]);
  AddSystemFunction(SEelFnStrICmp, [FpStr1, FpStr2]);
  AddSystemFunction(SEelFnStrNCmp, [FpStr1, FpStr2, FpLength]);
  AddSystemFunction(SEelFnStrNICmp, [FpStr1, FpStr2, FpLength]);
  AddSystemFunction(SEelFnStrNCpy, [FpStr1, FpStr2, FpLength]);
  AddSystemFunction(SEelFnStrNCat, [FpStr1, FpStr2, FpLength]);
  AddSystemFunction(SEelFnStrCpyFromSlider, [FpDst, FpSlider]);
  AddSystemFunction(SEelFnStrCpySubStr, [FpDst, FpSrc, FpIndex, FpLength]).FMinParametersAllowed := 3;
  AddSystemFunction(SEelFnStrGetChar, [FpSrc, FpIndex]);
  AddSystemFunction(SEelFnMatch, [FpNeedle, FpHaystack, SEelVariadic]).FMinParametersAllowed := 2;

  AddSystemFunction(SEelFnSPrintF, [FpDst, FpFmt, SEelVariadic]).FMinParametersAllowed := 2;
end;

function CJes2CppFunctions.AddSystemFunction(const AName: TComponentName; const AParams: array of String): CJes2CppFunction;
var
  LIndex: Integer;
begin
  if Assigned(FindComponent(AName)) then
  begin
    raise Exception.Create('Duplicate System Function');
  end;
  Result := CJes2CppFunction.Create(Self);
  Result.Name := AName;
  Result.IdentType := itSystem;
  SetLength(Result.FParams.FItems, Length(AParams));
  for LIndex := Low(AParams) to High(AParams) do
  begin
    Result.FParams.FItems[LIndex] := AParams[LIndex];
  end;
end;

function CJes2CppFunctions.GetFunction(const AIndex: Integer): CJes2CppFunction;
begin
  Result := Components[AIndex] as CJes2CppFunction;
end;

function CJes2CppFunctions.FindFunction(const AName: TComponentName; const ACount: Integer): CJes2CppFunction;
var
  LIndex: Integer;
begin
  for LIndex := First(Self) to Last(Self) do
  begin
    Result := GetFunction(LIndex);
    if SameText(Result.Name, AName) then
    begin
      if ((ACount >= Result.FMinParametersAllowed) and (ACount <= Result.FParams.VirtualCount)) or (ACount = Result.FParams.VirtualCount) then
      begin
        Exit;
      end;
    end;
  end;
  Result := nil;
end;

function CJes2CppFunctions.FindFunction(var AName: TComponentName; out ANameSpace: String; const ACount: Integer): CJes2CppFunction;
var
  LPos: Integer;
begin
  ANameSpace := EmptyStr;
  LPos := M_ZERO;
  repeat
    Result := FindFunction(Copy(AName, LPos + 1, MaxInt), ACount);
    if Assigned(Result) then
    begin
      ANameSpace := Copy(AName, 1, LPos);
      AName := Copy(AName, LPos + 1, MaxInt);
      Break;
    end;
    LPos := PosEx(CharDot, AName, LPos + 1);
  until LPos = M_ZERO;
  if ANameSpace = EmptyStr then
  begin
    ANameSpace := AName + CharDot;
  end;
end;

end.

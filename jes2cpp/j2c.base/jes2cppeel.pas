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

unit Jes2CppEel;

{$MODE DELPHI}

interface

uses Classes, FileUtil, Jes2CppConstants, StrUtils, SysUtils;

const

  GfEelEpsilon = 0.00001;

  GsEelExtern = 'extern'; // Not a standard keyword.
  GsEelFalse = 'false';
  GsEelFunction = 'function';
  GsEelGlobal = 'global';
  GsEelGlobals = 'globals';
  GsEelInstance = 'instance';
  GsEelLocal = 'local';
  GsEelLoop = 'loop';
  GsEelReturn = 'return'; // Not a standard keyword.
  GsEelStatic = 'static';
  GsEelThis = 'this';
  GsEelTrue = 'true';
  GsEelWhile = 'while';

const

  GsEelSpaceSWIPE = 'SWIPE' + CharDot;
  GsEelSpaceJes2Cpp = 'jes2cpp' + CharDot;
  GsEelSpaceThis = GsEelThis + CharDot;
  GsEelSpaceStringLiteral = GsEelSpaceJes2Cpp + 'String' + CharDot + 'Literal' + CharDot;
  GsEelSpaceStringTemp = GsEelSpaceJes2Cpp + 'String' + CharDot + 'Temp' + CharDot;

const

  GsEelDescDesc = 'desc';
  GsEelDescFileName = 'filename';
  GsEelDescImport = 'import';
  GsEelDescInPin = 'in_pin';
  GsEelDescOptions = 'options';
  GsEelDescOutPin = 'out_pin';
  GsEelDescSlider = 'slider';

const

  GsEelSectionBlock = 'block';
  GsEelSectionDesc = 'desc';
  GsEelSectionGfx = 'gfx';
  GsEelSectionInit = 'init';
  GsEelSectionOpen = 'open';
  GsEelSectionSample = 'sample';
  GsEelSectionSerialize = 'serialize';
  GsEelSectionSlider = 'slider';

var

  GaEelKeywords: array[0..9] of String = (GsEelLoop, GsEelWhile, GsEelFunction, GsEelLocal, GsEelStatic,
    GsEelInstance, GsEelGlobal, GsEelGlobals, GsEelThis, GsEelExtern);
  GaEelSpecial: array[0..19] of String = (GsEelFalse, GsEelTrue, GsEffectName, GsVendorString, GsVendorVersion,
    GsUniqueId, GsInstallPath, GsEelReturn, GsEelDescDesc, GsEelDescImport, GsEelDescOptions, GsEelSectionInit,
    GsEelSectionBlock, GsEelSectionSample, GsEelSectionSlider, GsEelSectionSerialize, GsEelSectionGfx,
    GsEelDescInPin, GsEelDescOutPin, GsEelDescFileName);


const

  GsEelM_PI = '$pi';
  GsEelM_PHI = '$phi';
  GsEelM_E = '$e';

const

  GsEelEllipses = '..';
  GsEelVariadic = '...';
  GsEelPreVarSlider = 'slider';
  GsEelPreVarSpl = 'spl';

const

  GsEelVarSliderX = GsEelPreVarSlider + '%d' + CharDot;
  GsEelVarSplX = GsEelPreVarSpl + '%d' + CharDot;
  GsEelVarGfxRate = 'gfx_rate' + CharDot; // Extended
  GsEelVarMouseCap = 'mouse_cap' + CharDot;
  GsEelVarMouseX = 'mouse_x' + CharDot;
  GsEelVarMouseY = 'mouse_y' + CharDot;

  // Eel Functions

  GsEelFnStrCpy = 'strcpy';
  GsEelFnStrCat = 'strcat';
  GsEelFnPow = 'pow';

const

  GsEelFile_ = 'file_';

const

  GsFnAnd = 'AND';
  GsFnAor = 'OR';
  GsFnEqu = 'EQU';
  GsFnIf = 'IF';
  GsFnMem = 'MEM';
  GsFnNeq = 'NEQ';
  GsFnNot = 'NOT';
  GsFnShl = 'SHL';
  GsFnShr = 'SHR';
  GsFnStr = 'STR';
  GsFnVal = 'VAL';
  GsFnXor = 'XOR';

const

  GsOpAdd = '+';
  GsOpAddSet = '+=';
  GsOpAnd = '&';
  GsOpAndIf = '&&';
  GsOpAndSet = '&=';
  GsOpDiv = '/';
  GsOpDivSet = '/=';
  GsOpEqu = '==';
  GsOpEquX = '===';
  GsOpGt = '>';
  GsOpGte = '>=';
  GsOpLt = '<';
  GsOpLte = '<=';
  GsOpMod = '%';
  GsOpModSet = '%=';
  GsOpMul = '*';
  GsOpMulSet = '*=';
  GsOpNeq = '!=';
  GsOpNeqX = '!==';
  GsOpOr = '|';
  GsOpOrIf = '||';
  GsOpOrSet = '|=';
  GsOpPow = '^';
  GsOpSet = '=';
  GsOpShl = '<<';
  GsOpShr = '>>';
  GsOpSub = '-';
  GsOpSubSet = '-=';
  GsOpXor = '~';
  GsOpXorSet = '~=';

type

  TEelSliderIndex = 1..64;
  TEelSampleIndex = 0..63;

var
  GaEelFunctionsMidi: array[0..2] of String = ('midisend', 'midirecv', 'midisyx');

function EelSectionName(const AName: String): String;

function EelFileNameResolve(const AFileName, ABaseFileName: TFileName): TFileName;

function EelDescHigh(const AScript: TStrings): Integer;

function EelIsImport(const AString: String; out AFileName: TFileName): Boolean;
function EelIsSection(const AString: String): Boolean; overload;
function EelIsSection(const AString, AName: String): Boolean; overload;

function EelStrToFloat(const AValue: String): Extended;
function EelStrToFloatDef(const AValue: String; const ADefault: Extended): Extended;
function EelFloatToStr(const AValue: Extended): String;

implementation

uses Jes2CppStrings;

function EelSectionName(const AName: String): String;
begin
  Result := CharAtSymbol + AName;
end;

function EelFileNameResolve(const AFileName, ABaseFileName: TFileName): TFileName;
begin
  Result := AFileName;
  if not FilenameIsAbsolute(Result) then
  begin
    // TODO: Were else should we look for import files?
    Result := CreateAbsolutePath(Result, ExtractFilePath(ABaseFileName));
  end;
end;

function EelIsImport(const AString: String; out AFileName: TFileName): Boolean;
var
  LName: String;
begin
  Result := J2C_StringSplit(AString, [CharSpace], LName, AFileName) and SameText(LName, GsEelDescImport);
end;

function EelIsSection(const AString: String): Boolean;
begin
  Result := AnsiStartsStr(CharAtSymbol, AString);
end;

function EelDescHigh(const AScript: TStrings): Integer;
var
  LIndex: Integer;
begin
  for LIndex := 0 to AScript.Count - 1 do
  begin
    if EelIsSection(AScript[LIndex]) then
    begin
      Exit(LIndex - 1);
    end;
  end;
  Result := AScript.Count - 1;
end;

function EelIsSection(const AString, AName: String): Boolean;
begin
  Result := SameText(Copy(AString, 1, (Pos(CharSpace, AString) - 1) and MaxInt), EelSectionName(AName));
end;

var
  GEelFormatSettings: TFormatSettings;

function EelStrToFloat(const AValue: String): Extended;
begin
  Result := StrToFloat(AValue, GEelFormatSettings);
end;

function EelStrToFloatDef(const AValue: String; const ADefault: Extended): Extended;
begin
  Result := StrToFloatDef(AValue, ADefault, GEelFormatSettings);
end;

function EelFloatToStr(const AValue: Extended): String;
begin
  Result := FloatToStr(AValue, GEelFormatSettings);
end;

initialization

  GEelFormatSettings := DefaultFormatSettings;
  GEelFormatSettings.DecimalSeparator := CharDot;

end.

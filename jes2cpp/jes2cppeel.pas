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

uses FileUtil, Jes2CppConstants, Math, StrUtils, SysUtils;

const

  EelEpsilon = 0.00001;

  SEelFunction = 'function';
  SEelGlobals = 'globals';
  SEelInstance = 'instance';
  SEelLocal = 'local';
  SEelLoop = 'loop';
  SEelRef = '.';
  SEelThis = 'this';
  SEelThisRef = SEelThis + SEelRef;
  SEelWhile = 'while';
  SEelReturn = 'return'; // Not a standard keyword.

const

  SEelDescDesc = 'desc';
  SEelDescFileName = 'filename';
  SEelDescImport = 'import';
  SEelDescInPin = 'in_pin';
  SEelDescOptions = 'options';
  SEelDescOutPin = 'out_pin';
  SEelDescSlider = 'slider';

const


  SEelSectionBlock = 'block';
  SEelSectionDesc = 'desc';
  SEelSectionGfx = 'gfx';
  SEelSectionInit = 'init';
  SEelSectionOpen = 'open';
  SEelSectionSample = 'sample';
  SEelSectionSerialize = 'serialize';
  SEelSectionSlider = 'slider';

var

  GEelKeywords: array[1..8] of String = (SEelLoop, SEelWhile, SEelFunction, SEelLocal, SEelInstance, SEelGlobals, SEelThis, SEelReturn);
  GEelSpecial: array[1..12] of String = (SEelDescDesc, SEelDescImport, SEelDescOptions, SEelSectionInit, SEelSectionBlock,
    SEelSectionSample, SEelSectionSlider, SEelSectionSerialize, SEelSectionGfx, SEelDescInPin, SEelDescOutPin, SEelDescFileName);

const

  SEelEllipses = '..';
  SEelVariadic = '...';
  SEelVarHash = '#';
  SEelPreVarSlider = 'slider';
  SEelPreVarSpl = 'spl';

  SEelVarSlider = SEelPreVarSlider + SEelRef;
  SEelVarSpl = SEelPreVarSpl + SEelRef;
  SEelVarBeatPosition = 'beat_position' + SEelRef;
  SEelVarNumCh = 'num_ch' + SEelRef;
  SEelVarPdcDelay = 'pdc_delay' + SEelRef;
  SEelVarPi = '$pi';
  SEelVarPlayPosition = 'play_position' + SEelRef;
  SEelVarPlayState = 'play_state' + SEelRef;
  SEelVarSamplesBlock = 'samplesblock' + SEelRef;
  SEelVarSRate = 'srate' + SEelRef;
  SEelVarTempo = 'tempo' + SEelRef;
  SEelVarTrigger = 'trigger' + SEelRef;
  SEelVarStrCount = 'str_count' + SEelRef; // Extended

  SEelVarGfxA = 'gfx_a' + SEelRef;
  SEelVarGfxB = 'gfx_b' + SEelRef;
  SEelVarGfxClear = 'gfx_clear' + SEelRef;
  SEelVarGfxG = 'gfx_g' + SEelRef;
  SEelVarGfxH = 'gfx_h' + SEelRef;
  SEelVarGfxR = 'gfx_r' + SEelRef;
  SEelVarGfxW = 'gfx_w' + SEelRef;
  SEelVarGfxX = 'gfx_x' + SEelRef;
  SEelVarGfxY = 'gfx_y' + SEelRef;
  SEelVarGfxMode = 'gfx_mode' + SEelRef;
  SEelVarGfxTextH = 'gfx_texth' + SEelRef;
  SEelVarGfxRate = 'gfx_rate' + SEelRef; // Extended

  SEelVarMouseCap = 'mouse_cap' + SEelRef;
  SEelVarMouseX = 'mouse_x' + SEelRef;
  SEelVarMouseY = 'mouse_y' + SEelRef;

const

  SEelCppDot = '$';
  SEelCppHash = 'H';

const

  SEelReal = 'Real';
  SEelThen = 'THEN';
  SEelElse = 'ELSE';
  SEelNop = 'M_NOP';
  SEelZero = 'M_ZERO';

  SEelGfx_ = 'gfx_';
  SEelFile_ = 'file_';

const

  SFnAdd = 'ADD';
  SFnAnd = 'AND';
  SFnAndIf = 'ANDIF';
  SFnChr = 'CHR';
  SFnDiv = 'DIV';
  SFnEqu = 'EQU';
  SFnEquX = 'EQUX';
  SFnGt = 'GT';
  SFnGte = 'GTE';
  SFnIf = 'IF';
  SFnLt = 'LT';
  SFnLte = 'LTE';
  SFnMax = 'MAX';
  SFnMem = 'MEM';
  SFnMin = 'MIN';
  SFnMod = 'MOD';
  SFnMul = 'MUL';
  SFnNeq = 'NEQ';
  SFnNeqX = 'NEQX';
  SFnNot = 'NOT';
  SFnOr = 'OR';
  SFnOrIf = 'ORIF';
  SFnPow = 'POW';
  SFnRealToInt = 'REAL2INT';
  SFnSet = 'SET';
  SFnShl = 'SHL';
  SFnShr = 'SHR';
  SFnStr = 'STR';
  SFnSub = 'SUB';
  SFnXor = 'XOR';

const

  SOpAdd = '+';
  SOpAddSet = '+=';
  SOpAnd = '&';
  SOpAndIf = '&&';
  SOpAndSet = '&=';
  SOpDiv = '/';
  SOpDivSet = '/=';
  SOpEqu = '==';
  SOpEquX = '===';
  SOpGt = '>';
  SOpGte = '>=';
  SOpLt = '<';
  SOpLte = '<=';
  SOpMod = '%';
  SOpModSet = '%=';
  SOpMul = '*';
  SOpMulSet = '*=';
  SOpNeq = '!=';
  SOpNeqX = '!==';
  SOpOr = '|';
  SOpOrIf = '||';
  SOpOrSet = '|=';
  SOpPow = '^';
  SOpSet = '=';
  SOpShl = '<<';
  SOpShr = '>>';
  SOpSub = '-';
  SOpSubSet = '-=';
  SOpXor = '~';
  SOpXorSet = '~=';

type

  TEelSliderIndex = 1..64;
  TEelSampleIndex = 0..63;

var
  GEelFunctionsMidi: array[0..2] of String = ('midisend', 'midirecv', 'midisyx');
  GEelFunctionsBass: array[0..0] of String = ('file_open');

function EelSection(const AName: String): String;

function EelCleanVarName(const AString: String): String;

function EelFileNameResolve(const AFileName, ABaseFileName: TFileName): TFileName;

function EelIsImport(const AString: String; out AFileName: TFileName): Boolean;
function EelIsSliderIdent(const AIdent: String; out AIndex: Integer): Boolean;
function EelIsSplIdent(const AIdent: String; out AIndex: Integer): Boolean;
function EelIsSection(const AString: String): Boolean; overload;
function EelIsSection(const AString, AName: String): Boolean; overload;

function EelStrToFloat(const AValue: String): Extended;
function EelStrToFloatDef(const AValue: String; const ADefault: Extended): Extended;
function EelFloatToStr(const AValue: Extended): String;

implementation

function EelSection(const AName: String): String;
begin
  Result := CharAtSymbol + AName;
end;

function EelCleanVarName(const AString: String): String;
begin
  Result := AString;
  if (Result <> SEelVariadic) and AnsiEndsStr(SEelRef, Result) then
  begin
    Result := Copy(Result, 1, Length(Result) - 1);
  end;
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
begin
  Result := AnsiStartsText(SEelDescImport + ' ', AString);
  if Result then
  begin
    AFileName := Trim(Copy(AString, Length(SEelDescImport) + 1, MaxInt));
  end;
end;

function EelIsSliderIdent(const AIdent: String; out AIndex: Integer): Boolean;
begin
  Result := AnsiStartsText(SEelPreVarSlider, AIdent) and TryStrToInt(Copy(AIdent, Length(SEelPreVarSlider) + 1, Length(AIdent) - 7), AIndex) and
    InRange(AIndex, Low(TEelSliderIndex), High(TEelSliderIndex));
end;

function EelIsSplIdent(const AIdent: String; out AIndex: Integer): Boolean;
begin
  Result := AnsiStartsText(SEelPreVarSpl, AIdent) and TryStrToInt(Copy(AIdent, Length(SEelPreVarSpl) + 1, Length(AIdent) - 4), AIndex) and
    InRange(AIndex, Low(TEelSampleIndex), High(TEelSampleIndex));
end;

function EelIsSection(const AString: String): Boolean;
begin
  Result := AnsiStartsStr(CharAtSymbol, AString);
end;

function EelIsSection(const AString, AName: String): Boolean;
begin
  Result := SameText(Copy(AString, 1, (Pos(CharSpace, AString) - 1) and MaxInt), EelSection(AName));
end;

var
  EelFormatSettings: TFormatSettings;

function EelStrToFloat(const AValue: String): Extended;
begin
  Result := StrToFloat(AValue, EelFormatSettings);
end;

function EelStrToFloatDef(const AValue: String; const ADefault: Extended): Extended;
begin
  Result := StrToFloatDef(AValue, ADefault, EelFormatSettings);
end;

function EelFloatToStr(const AValue: Extended): String;
begin
  Result := FloatToStr(AValue, EelFormatSettings);
end;

initialization

  EelFormatSettings := DefaultFormatSettings;
  EelFormatSettings.DecimalSeparator := '.';

end.

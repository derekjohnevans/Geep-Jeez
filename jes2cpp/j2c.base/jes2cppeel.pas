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

uses Classes, FileUtil, Jes2CppConstants, Jes2CppFileNames, Math, StrUtils, SysUtils;

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
  GsEelSpaceStringHash = GsEelSpaceJes2Cpp + 'String' + CharDot + 'Hash' + CharDot;

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

  GaEelKeywords: array[0..9] of String = (GsEelLoop, GsEelWhile, GsEelFunction,
    GsEelLocal, GsEelStatic, GsEelInstance, GsEelGlobal, GsEelGlobals, GsEelThis, GsEelExtern);
  GaEelKeywordsExtra: array[0..19] of
  String = (GsEelFalse, GsEelTrue, GsEffectName, GsVendorString, GsVendorVersion,
    GsUniqueId, GsInstallPath, GsEelReturn, GsEelDescDesc, GsEelDescImport,
    GsEelDescOptions, GsEelSectionInit, GsEelSectionBlock, GsEelSectionSample,
    GsEelSectionSlider, GsEelSectionSerialize, GsEelSectionGfx, GsEelDescInPin,
    GsEelDescOutPin, GsEelDescFileName);


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
  GsFnVal = 'VAL';
  GsFnXor = 'XOR';
  GsFnPow = 'pow';
  GsFnFmod = 'fmod';

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
  GsOpPowSet = '^=';
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
  GaEelFunctionsMidi: array[0..3] of String = ('midisend', 'midisend_buf', 'midirecv', 'midisyx');

type

  GEelSectionHeader = object
    class function Make(const AName: String): String;
    class function IsMaybeSection(const ASection: String): Boolean;
    class function IsSectionName(const ASection, AName: String): Boolean;
    class function ExtractName(const ASection: String): String;
  end;

  GEel = object
  strict private
    class function ImportExists(var AFileName: TFileName; const AFilePath: TFileName): Boolean;
    class function ImportLocateInPath(var AFileName: TFileName;
      const AFilePath: TFileName): Boolean;
  public
    class function ImportResolve(var AFileName: TFileName; const AParent: TFileName): Boolean;
    class function DescHigh(const AScript: TStrings): Integer;
    class function IsImport(const AString: String; out AFileName: TFileName): Boolean;
    class function ToFloat(const AValue: String): Extended;
    class function ToFloatDef(const AValue: String; const ADefault: Extended): Extended;
    class function ToString(const AValue: Extended): String;
  end;


implementation

uses Jes2CppStrings;

class function GEelSectionHeader.Make(const AName: String): String;
begin
  Result := CharAtSymbol + AName;
end;

class function GEelSectionHeader.IsMaybeSection(const ASection: String): Boolean;
begin
  Result := (Length(ASection) > 1) and (ASection[1] = CharAtSymbol);
end;

class function GEelSectionHeader.ExtractName(const ASection: String): String;
begin
  Assert(IsMaybeSection(ASection));
  Result := Copy(ASection, 2, ((Pos(CharSpace, ASection) - 1) and MaxInt) - 1);
end;

class function GEelSectionHeader.IsSectionName(const ASection, AName: String): Boolean;
begin
  Result := IsMaybeSection(ASection) and (ExtractName(ASection) = AName);
end;

class function GEel.ImportExists(var AFileName: TFileName; const AFilePath: TFileName): Boolean;
var
  LAbsolutePath: TFileName;
begin
  if FilenameIsAbsolute(AFileName) then
  begin
    Result := FileExists(AFileName);
  end else begin
    LAbsolutePath := CreateAbsolutePath(AFileName, AFilePath);
    Result := FileExists(LAbsolutePath);
    if Result then
    begin
      AFileName := LAbsolutePath;
    end;
  end;
end;

class function GEel.ImportLocateInPath(var AFileName: TFileName;
  const AFilePath: TFileName): Boolean;
var
  LSearchRec: TSearchRec;
begin
  Result := ImportExists(AFileName, AFilePath);
  if not Result then
  begin
    if FindFirst(AFilePath + AllFilesMask, faDirectory, LSearchRec) = 0 then
    begin
      try
        repeat
          if (LSearchRec.Attr and faDirectory) <> 0 then
          begin
            if (LSearchRec.Name <> '.') and (LSearchRec.Name <> '..') then
            begin
              if ImportLocateInPath(AFileName, AFilePath + LSearchRec.Name +
                DirectorySeparator) then
              begin
                Exit(True);
              end;
            end;
          end;
        until FindNext(LSearchRec) <> 0;
      finally
        FindClose(LSearchRec);
      end;
    end;
  end;
end;

class function GEel.ImportResolve(var AFileName: TFileName; const AParent: TFileName): Boolean;
begin
  Result := ImportExists(AFileName, ExtractFilePath(AParent)) or
    ImportLocateInPath(AFileName, GFilePath.ReaperEffects) or
    ImportLocateInPath(AFileName, GFilePath.SdkJsFxInc);
end;

class function GEel.IsImport(const AString: String; out AFileName: TFileName): Boolean;
var
  LName: String;
begin
  Result := GString.Split(AString, [CharSpace], LName, AFileName) and
    SameText(LName, GsEelDescImport);
end;

class function GEel.DescHigh(const AScript: TStrings): Integer;
var
  LIndex: Integer;
begin
  for LIndex := 0 to AScript.Count - 1 do
  begin
    if GEelSectionHeader.IsMaybeSection(AScript[LIndex]) then
    begin
      Exit(LIndex - 1);
    end;
  end;
  Result := AScript.Count - 1;
end;

var
  GEelFormatSettings: TFormatSettings;

class function GEel.ToFloat(const AValue: String): Extended;
begin
  Result := SysUtils.StrToFloat(AValue, GEelFormatSettings);
end;

class function GEel.ToFloatDef(const AValue: String; const ADefault: Extended): Extended;
begin
  Result := SysUtils.StrToFloatDef(AValue, ADefault, GEelFormatSettings);
end;

class function GEel.ToString(const AValue: Extended): String;
begin
  Result := SysUtils.FloatToStr(AValue);
  if PosSet(['.', 'E'], Result) = ZeroValue then
  begin
    Result += '.0';
  end;
end;

initialization

  GEelFormatSettings := DefaultFormatSettings;
  GEelFormatSettings.DecimalSeparator := CharDot;

end.

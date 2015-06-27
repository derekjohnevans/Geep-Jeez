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

unit Jes2CppTranslate;

{$MODE DELPHI}

interface

uses
  Jes2CppConstants, Jes2CppEel, Jes2CppIdentString, Jes2CppToken, StrUtils, SysUtils;

const

  GsCppWin32 = 'WIN32';
  GsCppBeos = 'BEOS';

  GsCppJes2CppInline = 'JES2CPP_INLINE';
  GsCppJes2CppInlineSpace = GsCppJes2CppInline + CharSpace;
  GsCppJes2CppBass = 'JES2CPP_BASS';
  GsCppJes2CppSndFile = 'JES2CPP_SNDFILE';

  GsCppVestVst = 'VEST_VST';
  GsCppVestLv1 = 'VEST_LV1';
  GsCppVestLv2 = 'VEST_LV2';
  GsCppVestDx = 'VEST_DX';
  GsCppVestAu = 'VEST_AU';

  GsCppWdlFftRealSize = 'WDL_FFT_REALSIZE';

const

  GsCppCommaSpace = CharComma + CharSpace;
  GsCppCommentFoot = CharAsterisk + CharSlashForward;
  GsCppCommentHead = CharSlashForward + CharAsterisk;
  GsCppCommentLine = CharSlashForward + CharSlashForward;
  GsCppCommentSpace = GsCppCommentLine + CharSpace;
  GsCppAssign = CharSpace + CharEqualSign + CharSpace;
  GsCppFmod = 'fmod';
  GsCppFunct1 = '%s()';
  GsCppFunct2 = '%s(%s)';
  GsCppFunct3 = '%s(%s, %s)';
  GsCppInline = 'inline';
  GsCppLineEnding = CharSemiColon + LineEnding;
  GsCppOperator = '(%s %s %s)';
  GsCppPow = 'pow';
  GsCppReturnSpace = 'return' + CharSpace;
  GsCppSamples1 = 'FSamples[%d]';
  GsCppSliders1 = 'FSliders[%d]';
  GsCppVoidSpace = 'void' + CharSpace;

  GsCppFloat = 'float';
  GsCppDouble = 'double';
  GsCppStatic = 'static';
  GsCppNullPtr = 'nullptr';
  GsCppEelF = 'EEL_F';
  GsCppNop = 'M_NOP';
  GsCppZero = 'M_ZERO';
  GsCppM_PI = 'M_PI';
  GsCppM_E = 'M_E';
  GsCppM_PHI = 'M_PHI';

const

  GsMarkerHead = '@@@';
  GsMarkerFoot = Char(']');
  GsMarkerHeadFile = GsMarkerHead + 'file[';
  GsMarkerHeadLine = GsMarkerHead + 'line[';

function CppEncodeString(const AString: String; const ACharQuote: Char = CharQuoteDouble): String;
function CppDecodeString(const AString: String): String;

function CppEncodeFloat(const AExtended: Extended): String; overload;
function CppEncodeFloat(const AString: String): String; overload;
function CppEncodeVariable(const AIdent: TIdentString): String;
function CppEncodeFunction(const AIdent: TIdentString): String;

function CppIsHashString(const AString: String): Boolean;

implementation

function CppEncodeString(const AString: String; const ACharQuote: Char): String;

  procedure Encode(const ASrc, ADst: Char);
  begin
    Result := ReplaceStr(Result, ASrc, CharSlashBackward + ADst);
  end;

begin
  Result := AString;
  Encode(CharSlashBackward, CharSlashBackward);
  Encode(CharQuoteDouble, CharQuoteDouble);
  Encode(CharQuoteSingle, CharQuoteSingle);
  Encode(CharLF, 'n');
  Encode(CharCR, 'r');
  Encode(CharTab, 't');
  Result := ACharQuote + Result + ACharQuote;
end;

function CppDecodeString(const AString: String): String;

  procedure Decode(const ASrc, ADst: Char);
  begin
    Result := ReplaceStr(Result, CharSlashBackward + ASrc, ADst);
  end;

begin
  Result := Copy(AString, 2, Length(AString) - 2);
  Decode(CharQuoteDouble, CharQuoteDouble);
  Decode(CharQuoteSingle, CharQuoteSingle);
  Decode('n', CharLF);
  Decode('r', CharCR);
  Decode('t', CharTab);
  Decode(CharSlashBackward, CharSlashBackward);
end;

function CppEncodeFloat(const AExtended: Extended): String;
begin
  Result := '(' + GsCppEelF + ')(' + EelFloatToStr(AExtended) + ')';
end;

function CppEncodeFloat(const AString: String): String;
begin
  if J2C_TokenIsSame(PChar(AString), GsEelM_PI) then
  begin
    Result := GsCppM_PI;
  end else if J2C_TokenIsSame(PChar(AString), GsEelM_E) then
  begin
    Result := GsCppM_E;
  end else if J2C_TokenIsSame(PChar(AString), GsEelM_PHI) then
  begin
    Result := GsCppM_PHI;
  end else if J2C_TokenIsNumberMask(PChar(AString)) then
  begin
    Result := CppEncodeFloat((1 shl StrToInt(Copy(AString, 3, MaxInt))) - 1);
  end else if J2C_TokenIsNumberHex(PChar(AString)) then
  begin
    Result := CppEncodeFloat(StrToInt(CharDollar + Copy(AString, 3, MaxInt)));
  end else if J2C_TokenIsNumberAsc(PChar(AString)) then
  begin
    Result := CppEncodeFloat(Ord(AString[3]));
  end else begin
    Result := CppEncodeFloat(EelStrToFloat(AString));
  end;
end;

function CppIsHashString(const AString: String): Boolean;
begin
  Result := (AString <> EmptyStr) and (AString[1] = CharDollar) and (Pos(CharSpace, AString) = 0);
end;

function CppEncodeIdent(const AIdent: TIdentString): String;
var
  LIndex: Integer;
begin
  Result := LowerCase(AIdent);
  for LIndex := 1 to Length(Result) do
  begin
    if Result[LIndex] in [CharDot, CharHash] then
    begin
      Result[LIndex] := CharDollar;
    end;
  end;
end;

function CppEncodeVariable(const AIdent: TIdentString): String;
begin
  Result := CppEncodeIdent(AIdent);
  if (Result <> EmptyStr) and (Result[Length(AIdent)] = CharAsterisk) then
  begin
    Delete(Result, Length(Result), 1);
    Insert(CharAmpersand, Result, 1);
  end;
end;

function CppEncodeFunction(const AIdent: TIdentString): String;
begin
  Result := CppEncodeIdent(AIdent) + CharUnderscore;
end;

end.

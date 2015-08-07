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
  GsCppFunct1 = '%s()';
  GsCppFunct2 = '%s(%s)';
  GsCppFunct3 = '%s(%s, %s)';
  GsCppInline = 'inline';
  GsCppLineEnding = CharSemiColon + LineEnding;
  GsCppOperator = '(%s %s %s)';
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

type

  GCpp = object
    type Encode = object
      class function Float(const AExtended: Extended): String; overload;
      class function Float(const AString: String): String; overload;
      class function NameFunction(const AIdent: TIdentString; const ACount: Integer): String;
      class function NameIdentifier(const AIdent: TIdentString): String;
      class function NameVariable(const AIdent: TIdentString): String;
      class function QuotedString(const AString: String;
        const ACharQuote: Char = CharQuoteDouble): String;
    end;

    Decode = object
      class function QuotedString(const AString: String): String;
    end;
    class function IsHashString(const AString: String): Boolean;
  end;

implementation

class function GCpp.Encode.QuotedString(const AString: String; const ACharQuote: Char): String;

  procedure LEncode(const ASrc, ADst: Char);
  begin
    Result := ReplaceStr(Result, ASrc, CharSlashBackward + ADst);
  end;

begin
  Result := AString;
  LEncode(CharSlashBackward, CharSlashBackward);
  LEncode(CharQuoteDouble, CharQuoteDouble);
  LEncode(CharQuoteSingle, CharQuoteSingle);
  LEncode(CharLF, 'n');
  LEncode(CharCR, 'r');
  LEncode(CharTab, 't');
  Result := ACharQuote + Result + ACharQuote;
end;

class function GCpp.Decode.QuotedString(const AString: String): String;

  procedure LDecode(const ASrc, ADst: Char);
  begin
    Result := ReplaceStr(Result, CharSlashBackward + ASrc, ADst);
  end;

begin
  Result := Copy(AString, 2, Length(AString) - 2);
  LDecode(CharQuoteDouble, CharQuoteDouble);
  LDecode(CharQuoteSingle, CharQuoteSingle);
  LDecode('n', CharLF);
  LDecode('r', CharCR);
  LDecode('t', CharTab);
  LDecode(CharSlashBackward, CharSlashBackward);
end;

class function GCpp.Encode.Float(const AExtended: Extended): String;
begin
  Result := '(' + GsCppEelF + ')(' + GEel.ToString(AExtended) + ')';
end;

class function GCpp.Encode.Float(const AString: String): String;
begin
  if GToken.IsSame(PChar(AString), GsEelM_PI) then
  begin
    Result := GsCppM_PI;
  end else if GToken.IsSame(PChar(AString), GsEelM_E) then
  begin
    Result := GsCppM_E;
  end else if GToken.IsSame(PChar(AString), GsEelM_PHI) then
  begin
    Result := GsCppM_PHI;
  end else if GToken.IsNumberMask(PChar(AString)) then
  begin
    Result := Float((1 shl StrToInt(Copy(AString, 3, MaxInt))) - 1);
  end else if GToken.IsNumberHex(PChar(AString)) then
  begin
    Result := Float(StrToInt64(CharDollar + Copy(AString, 3, MaxInt)));
  end else if GToken.IsNumberAsc(PChar(AString)) then
  begin
    Result := Float(Ord(AString[3]));
  end else begin
    Result := Float(GEel.ToFloat(AString));
  end;
end;

class function GCpp.IsHashString(const AString: String): Boolean;
begin
  Result := (AString <> EmptyStr) and (AString[1] = CharDollar) and (Pos(CharSpace, AString) = 0);
end;

class function GCpp.Encode.NameIdentifier(const AIdent: TIdentString): String;
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

class function GCpp.Encode.NameVariable(const AIdent: TIdentString): String;
begin
  Result := NameIdentifier(AIdent);
  if (Result <> EmptyStr) and (Result[Length(AIdent)] = CharAsterisk) then
  begin
    Delete(Result, Length(Result), 1);
    Insert(CharAmpersand, Result, 1);
  end;
end;

class function GCpp.Encode.NameFunction(const AIdent: TIdentString; const ACount: Integer): String;
begin
  Result := NameIdentifier(AIdent);
  if ACount > 0 then
  begin
    Result += IntToStr(ACount);
  end;
  Result += CharUnderscore;
end;

end.

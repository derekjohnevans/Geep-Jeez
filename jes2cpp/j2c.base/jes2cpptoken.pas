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

unit Jes2CppToken;

{$MODE DELPHI}

interface

uses Jes2CppConstants, SysUtils;

const

  CharSetAll = [#0..#255];
  CharSetWhite = [#9, #10, #11, #12, #13, #32];
  CharSetQuote = [CharQuoteSingle, CharQuoteDouble];
  CharSetNull = [CharNull];
  CharSetLineEnding = CharSetNull + [#10, #13];
  CharSetUpper = ['A'..'Z'];
  CharSetLower = ['a'..'z'];
  CharSetHex = ['a'..'f', 'A'..'F'];
  CharSetDigit = ['0'..'9'];
  CharSetAlpha = CharSetLower + CharSetUpper;

  CharSetFunctHead = CharSetAlpha + ['_'];

  CharSetIdentHead = CharSetFunctHead + ['$', '#'];
  CharSetIdentBody = CharSetAlpha + CharSetDigit + ['_', '.'];
  CharSetIdentFull = CharSetIdentHead + CharSetIdentBody;

  CharSetNumberHead = CharSetDigit + ['.', '$'];
  CharSetNumberBody = CharSetDigit + CharSetAlpha + ['~', '.', 'x', 'X', 'e', 'E', ''''];

  CharSetOperator1 = ['=', '*', '/', '%', '^', '+', '-', '|', '&', '!', '<', '>', '~'];
  CharSetOperator2 = ['<', '>', '&', '|', '='];

function J2C_TokenIsSame(const AToken1, AToken2: PChar): Boolean;
function J2C_TokenIsNumberAsc(const AToken: PChar): Boolean;
function J2C_TokenIsNumberHex(const AToken: PChar): Boolean;
function J2C_TokenIsNumberMask(const AToken: PChar): Boolean;

implementation

function J2C_TokenIsSame(const AToken1, AToken2: PChar): Boolean;
begin
  Result := StrIComp(AToken1, AToken2) = 0;
end;

function J2C_TokenIsNumberAsc(const AToken: PChar): Boolean;
begin
  Result := (AToken[0] = '$') and (AToken[1] = '''') and (AToken[2] <> #0) and (AToken[3] = '''');
end;

function J2C_TokenIsNumberHex(const AToken: PChar): Boolean;
begin
  Result := (AToken[0] in ['$', '0']) and (AToken[1] in ['x', 'X']);
end;

function J2C_TokenIsNumberMask(const AToken: PChar): Boolean;
begin
  Result := (AToken[0] = '$') and (AToken[1] = '~');
end;

end.


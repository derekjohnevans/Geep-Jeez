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

unit Jes2CppLoop;

{$MODE DELPHI}

interface

uses
  Jes2CppConstants, Jes2CppEel, Jes2CppFunction, Jes2CppIdentifier, Jes2CppIdentString, Jes2CppTranslate, SysUtils;

type

  TJes2CppLoopType = (ltLoop, ltDoWhile, ltWhile);

  CJes2CppLoops = class;

  CJes2CppLoop = class(CJes2CppIdentifier)
  strict private
    FFunction: CJes2CppFunction;
  public
    FCondition, FBlock, FPreCondition: String;
    FType: TJes2CppLoopType;
  strict private
    function CppParameters(const AIsDefine: Boolean): String;
    function CppDefineHead: String;
  public
    constructor Create(const AOwner: CJes2CppLoops; const AType: TJes2CppLoopType; const AFunction: CJes2CppFunction);
      virtual; reintroduce;
  public
    function CppDefine: String;
    function CppCall: String;
  end;

  CJes2CppLoops = class(CJes2CppIdentifiers)
  public
    function GetLoop(const AIndex: Integer): CJes2CppLoop;
  end;

implementation

constructor CJes2CppLoop.Create(const AOwner: CJes2CppLoops; const AType: TJes2CppLoopType; const AFunction: CJes2CppFunction);
begin
  inherited Create(AOwner, GsDoLoop + IntToStr(AOwner.ComponentCount));
  FType := AType;
  FFunction := AFunction;
end;

function CJes2CppLoop.CppParameters(const AIsDefine: Boolean): String;

  procedure LAppendParams(const LParameters: TIdentArray; const AIsInstance: Boolean);
  var
    LIndex: Integer;
  begin
    for LIndex := Low(LParameters.FItems) to High(LParameters.FItems) do
    begin
      if Result <> EmptyStr then
      begin
        Result += GsCppCommaSpace;
      end;
      if AIsDefine then
      begin
        Result += GsCppEelF + CharAmpersand + CharSpace;
      end;
      if AIsInstance then
      begin
        Result += CppEncodeVariable(GsEelSpaceThis + LParameters.FItems[LIndex]);
      end else begin
        Result += CppEncodeVariable(LParameters.FItems[LIndex]);
      end;
    end;
  end;

begin
  Result := EmptyStr;
  if Assigned(FFunction) then
  begin
    LAppendParams(FFunction.FParams, False);
    LAppendParams(FFunction.FLocals, False);
    LAppendParams(FFunction.FAllInstances, True);
  end;
end;

function CJes2CppLoop.CppCall: String;
begin
  Result := Format(GsCppFunct2, [Name, CppParameters(False)]);
end;

function CJes2CppLoop.CppDefineHead: String;
begin
  Result := GsCppInlineSpace + GsCppEelF + CharSpace + Name + '(' + CppParameters(True) + ')' + LineEnding;
end;

function CJes2CppLoop.CppDefine: String;
begin
  Result := CppDefineHead + '{' + LineEnding;
  Result += 'int LMax = 1000000;' + LineEnding;
  case FType of
    ltLoop: begin
      Result += 'for (int LIdx = (int)(' + FCondition + '); (--LIdx >= 0) && (LMax-- > 0);)' + LineEnding;
      Result += '{' + LineEnding + FBlock + '}' + LineEnding;
    end;
    ltDoWhile: begin
      Result += 'do {' + LineEnding + FBlock + '} while (' + GsFnIf + '(' + FCondition + ') && (LMax-- > 0));' + LineEnding;
    end;
    ltWhile: begin
      Result += FPreCondition + 'while (' + GsFnIf + '(' + FCondition + ') && (LMax-- > 0)) {' + LineEnding +
        FBlock + FPreCondition + '}' + LineEnding;

    end;
  end;
  Result += 'return ' + CppEncodeFloat(1) + ';' + LineEnding + '}' + LineEnding;
end;

function CJes2CppLoops.GetLoop(const AIndex: Integer): CJes2CppLoop;
begin
  Result := Components[AIndex] as CJes2CppLoop;
end;

end.

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
  Jes2CppConstants, Jes2CppEel, Jes2CppFunction, Jes2CppIdentifier, Jes2CppTranslate, Jes2CppVarArray, SysUtils;

type

  TJes2CppLoopType = (ltLoop, ltDoWhile, ltWhile);

  CJes2CppLoops = class(CJes2CppIdentifiers)
  end;

  CJes2CppLoop = class(CJes2CppIdentifier)
  strict private
    FFunction: CJes2CppFunction;
  public
    FCondition, FBody, FPreCondition: String;
    FType: TJes2CppLoopType;
  strict private
    function CppParameters(const AIsDefine: Boolean): String;
    function CppDefineHead: String;
  public
    constructor Create(const AOwner: CJes2CppLoops; const AType: TJes2CppLoopType; const AFunction: CJes2CppFunction); virtual; reintroduce;
  public
    function CppDefine: String;
    function CppCall: String;
  end;

implementation

constructor CJes2CppLoop.Create(const AOwner: CJes2CppLoops; const AType: TJes2CppLoopType; const AFunction: CJes2CppFunction);
begin
  inherited Create(AOwner);
  FType := AType;
  FFunction := AFunction;
end;

function CJes2CppLoop.CppParameters(const AIsDefine: Boolean): String;

  procedure LAppendParams(const LParameters: TVariableArray; const AIsDefine, AIsInstance: Boolean);
  var
    LIndex: Integer;
  begin
    for LIndex := Low(LParameters.FItems) to High(LParameters.FItems) do
    begin
      if Result <> EmptyStr then
      begin
        Result += SCppCommaSpace;
      end;
      if AIsDefine then
      begin
        Result += SEelReal + CharAmpersand + CharSpace;
      end;
      if AIsInstance then
      begin
        Result += EelToCppVar(SEelThisRef + LParameters.FItems[LIndex], vtParameter);
      end else begin
        Result += EelToCppVar(LParameters.FItems[LIndex], vtParameter);
      end;
    end;
  end;

begin
  Result := EmptyStr;
  if Assigned(FFunction) then
  begin
    LAppendParams(FFunction.FParams, AIsDefine, False);
    LAppendParams(FFunction.FLocals, AIsDefine, False);
    LAppendParams(FFunction.FAllInstances, AIsDefine, True);
  end;
end;

function CJes2CppLoop.CppCall: String;
begin
  Result := Format('%s%d(%s)', [SDoLoop, ComponentIndex, CppParameters(False)]);
end;

function CJes2CppLoop.CppDefineHead: String;
begin
  Result := SCppInlineSpace + SEelReal + CharSpace + SDoLoop + IntToStr(ComponentIndex) + '(' + CppParameters(True) + ')' + LineEnding;
end;

function CJes2CppLoop.CppDefine: String;
begin
  Result := CppDefineHead + '{' + LineEnding;
  Result += 'int LMax = 1000000;' + LineEnding;
  case FType of
    ltLoop: begin
      Result += 'for (int LIdx = (int)(' + FCondition + '); (--LIdx >= 0) && (LMax-- > 0);)' + LineEnding;
      Result += '{' + LineEnding + FBody + '}' + LineEnding;
    end;
    ltDoWhile: begin
      Result += 'do {' + LineEnding + FBody + '} while (' + SFnIf + '(' + FCondition + ') && (LMax-- > 0));' + LineEnding;
    end;
    ltWhile: begin
      Result += FPreCondition + 'while (' + SFnIf + '(' + FCondition + ') && (LMax-- > 0)) {' + LineEnding + FBody +
        FPreCondition + '}' + LineEnding;
    end;
  end;
  Result += 'return ' + EelToCppFloat(1) + ';' + LineEnding + '}' + LineEnding;
end;

end.

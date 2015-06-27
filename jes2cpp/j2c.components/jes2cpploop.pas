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
{$MACRO ON}

interface

uses
  Classes, Jes2CppConstants, Jes2CppEel, Jes2CppFunction, Jes2CppIdentifier, Jes2CppTranslate, Soda, SysUtils;

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
    function EncodeDefineCpp: String;
    function EncodeCallCpp: String;
  end;

  CJes2CppLoops = class
    {$DEFINE DItemClass := CJes2CppLoops}
    {$DEFINE DItemSuper := CComponent}
    {$DEFINE DItemItems := CJes2CppLoop}
    {$INCLUDE soda.inc}
  end;

implementation

{$DEFINE DItemClass := CJes2CppLoops}
{$INCLUDE soda.inc}

constructor CJes2CppLoop.Create(const AOwner: CJes2CppLoops; const AType: TJes2CppLoopType; const AFunction: CJes2CppFunction);
begin
  inherited CreateNamed(AOwner, GsDoLoop + IntToStr(AOwner.ComponentCount));
  FType := AType;
  FFunction := AFunction;
end;

function CJes2CppLoop.CppParameters(const AIsDefine: Boolean): String;
begin
  Result := EmptyStr;
  if Assigned(FFunction) then
  begin
    FFunction.Params.AppendParams(Result, AIsDefine, False);
    FFunction.Locals.AppendParams(Result, AIsDefine, False);
    FFunction.InstancesAll.AppendParams(Result, AIsDefine, True);
  end;
end;

function CJes2CppLoop.EncodeCallCpp: String;
begin
  Result := Format(GsCppFunct2, [Name, CppParameters(False)]);
end;

function CJes2CppLoop.CppDefineHead: String;
begin
  Result := GsCppJes2CppInlineSpace + GsCppEelF + CharSpace + Name + '(' + CppParameters(True) + ')' + LineEnding;
end;

function CJes2CppLoop.EncodeDefineCpp: String;
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

end.

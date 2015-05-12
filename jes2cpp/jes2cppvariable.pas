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

unit Jes2CppVariable;

{$MODE DELPHI}

interface

uses
  Classes, Jes2CppConstants, Jes2CppEel, Jes2CppIdentifier, Jes2CppTranslate, Jes2CppUtils, SysUtils;

type

  CJes2CppVariable = class(CJes2CppIdentifier)
  public
    FConstantString: String;
  end;

  CJes2CppVariables = class(CJes2CppIdentifiers)
  strict private
    function AddVariable(const AName: String; const AIdentType: TJes2CppIdentifierType; const AIsHidden: Boolean = False): CJes2CppVariable;
  public
    constructor Create(AOwner: TComponent); override;
  public
    function GetVariable(const AIndex: Integer): CJes2CppVariable;
    function CppDefineVariables: String;
    function CppSetVariables: String;
    function CppSetStringConstants: String;
  end;

implementation

constructor CJes2CppVariables.Create(AOwner: TComponent);
var
  LIndex: Integer;
begin
  inherited Create(AOwner);

  AddVariable(SEelVarBeatPosition, itSystem, True);
  AddVariable(SEelVarGfxA, itSystem, True);
  AddVariable(SEelVarGfxB, itSystem, True);
  AddVariable(SEelVarGfxClear, itSystem, True);
  AddVariable(SEelVarGfxG, itSystem, True);
  AddVariable(SEelVarGfxH, itSystem, True);
  AddVariable(SEelVarGfxR, itSystem, True);
  AddVariable(SEelVarGfxW, itSystem, True);
  AddVariable(SEelVarGfxX, itSystem, True);
  AddVariable(SEelVarGfxY, itSystem, True);
  AddVariable(SEelVarGfxRate, itSystem, True);
  AddVariable(SEelVarGfxMode, itSystem, True);
  AddVariable(SEelVarGfxTextH, itSystem, True);
  AddVariable(SEelVarMouseCap, itSystem, True);
  AddVariable(SEelVarMouseX, itSystem, True);
  AddVariable(SEelVarMouseY, itSystem, True);
  AddVariable(SEelVarNumCh, itSystem, True);
  AddVariable(SEelVarPdcDelay, itSystem, True);
  AddVariable(SEelVarPlayPosition, itSystem, True);
  AddVariable(SEelVarPlayState, itSystem, True);
  AddVariable(SEelVarSamplesBlock, itSystem, True);
  AddVariable(SEelVarSRate, itSystem, True);
  AddVariable(SEelVarTempo, itSystem, True);
  AddVariable(SEelVarTrigger, itSystem, True);
  AddVariable(SEelVarStrCount, itSystem, True);

  for LIndex in TEelSampleIndex do
  begin
    AddVariable(SEelPreVarSpl + IntToStr(LIndex) + SEelRef, itSystem, True);
  end;
  for LIndex in TEelSliderIndex do
  begin
    AddVariable(SEelPreVarSlider + IntToStr(LIndex) + SEelRef, itSystem, True);
  end;
end;

function CJes2CppVariables.GetVariable(const AIndex: Integer): CJes2CppVariable;
begin
  Result := Components[AIndex] as CJes2CppVariable;
end;

function CJes2CppVariables.AddVariable(const AName: String; const AIdentType: TJes2CppIdentifierType; const AIsHidden: Boolean): CJes2CppVariable;
begin
  Result := CJes2CppVariable.Create(Self);
  Result.Name := AName;
  Result.IdentType := AIdentType;
  Result.IsHidden := AIsHidden;
end;

function CJes2CppVariables.CppDefineVariables: String;
var
  LIndex: Integer;
begin
  Result := EmptyStr;
  for LIndex := First(Self) to Last(Self) do
  begin
    if not GetIdentifier(LIndex).IsHidden then
    begin
      if Result <> EmptyStr then
      begin
        Result += SCppCommaSpace;
      end;
      Result += EelToCppVar(Components[LIndex].Name, vtGlobal);
    end;
  end;
  if Result <> EmptyStr then
  begin
    Result := SEelReal + CharSpace + Result + SCppEol;
  end;
end;

function CJes2CppVariables.CppSetVariables: String;
var
  LIndex: Integer;
  LVariable: CJes2CppVariable;
begin
  Result := EmptyStr;
  for LIndex := First(Self) to Last(Self) do
  begin
    LVariable := Components[LIndex] as CJes2CppVariable;
    if not LVariable.IsHidden then
    begin
      Result += EelToCppVar(LVariable.Name, vtGlobal) + SCppEqu + SEelZero + SCppEol + LineEnding;
    end;
  end;
end;

function CJes2CppVariables.CppSetStringConstants: String;
var
  LIndex: Integer;
  LVariable: CJes2CppVariable;
begin
  Result := EmptyStr;
  for LIndex := First(Self) to Last(Self) do
  begin
    LVariable := Components[LIndex] as CJes2CppVariable;
    if not LVariable.IsHidden and (LVariable.FConstantString <> EmptyStr) then
    begin
      Result += SFnSet + '(' + EelToCppVar(LVariable.Name, vtGlobal) + SCppCommaSpace + SFnStr + '(' +
        LVariable.FConstantString + '))' + SCppEol + LineEnding;
    end;
  end;
end;

end.

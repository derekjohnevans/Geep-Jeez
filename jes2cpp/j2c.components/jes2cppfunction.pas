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

unit Jes2CppFunction;

{$MODE DELPHI}

interface

uses
  Classes, Jes2CppConstants, Jes2CppEel, Jes2CppIdentifier, Jes2CppIdentString, Jes2CppIterate, Jes2CppStrings,
  Jes2CppTranslate, StrUtils, SysUtils;

type

  CJes2CppFunction = class(CJes2CppIdentifier)
  public
    FBody, FReturnExpression: String;
    FParams, FLocals, FGlobals, FInstances, FAllInstances: TIdentArray;
    FForceGlobals, FHasGlobals, FIsRef: Boolean;
  strict private
    function CppParameters: String;
    function CppLocalVars: String;
  public
    function EelDefine: String;
    function CppDefine: String;
    function GetTitle: String;
    function IsNameLocal(const AName: TComponentName): Boolean;
    function IsInternalAndUsed: Boolean;
    function DefaultNameSpace: String;
  public
    property ForceGlobals: Boolean read FForceGlobals write FForceGlobals;
    property IsRef: Boolean read FIsRef write FIsRef;
  end;

  CJes2CppFunctions = class(CJes2CppIdentifiers)
  public
    function GetFunction(const AIndex: Integer): CJes2CppFunction;
    function FindFunction(const AIdent: TIdentString; const ACount: Integer): CJes2CppFunction; overload;
    function FindFunction(const AName: TIdentString; out ANameSpace, AFunctName: String; const ACount: Integer): CJes2CppFunction;
      overload;
  end;

implementation

function CJes2CppFunction.GetTitle: String;
begin
  Result := GsEelFunction + CharSpace + EelDefine + LineEnding + Comment + LineEnding;
  if References.ComponentCount > 0 then
  begin
    Result += References.GetReference(0).EncodeLineFile;
  end;
end;

function CJes2CppFunction.EelDefine: String;
var
  LIdent: TIdentString;
begin
  Result := EmptyStr;
  for LIdent in FParams.FItems do
  begin
    J2C_StringAppendCSV(Result, J2C_IdentClean(LIdent));
  end;
  Result := Name + CharOpeningParenthesis + Result + CharClosingParenthesis;
end;

function CJes2CppFunction.CppParameters: String;
var
  LIdent: TIdentString;
begin
  Result := EmptyStr;
  for LIdent in FParams.FItems do
  begin
    if LIdent = GsEelVariadic then
    begin
      J2C_StringAppendCSV(Result, GsEelVariadic);
    end else begin
      J2C_StringAppendCSV(Result, CppEncodeEelF(CppEncodeVariable(LIdent), False));
    end;
  end;
  for LIdent in FAllInstances.FItems do
  begin
    J2C_StringAppendCSV(Result, CppEncodeEelF(CppEncodeVariable(GsEelSpaceThis + LIdent), True));
  end;
end;

function CJes2CppFunction.CppLocalVars: String;
var
  LIdent: TIdentString;
begin
  Result := EmptyStr;
  if FLocals.Count > M_ZERO then
  begin
    for LIdent in FLocals.FItems do
    begin
      J2C_StringAppendCSV(Result, CppEncodeVariable(LIdent) + GsCppEqu + GsCppZero);
    end;
    Result := GsCppEelF + CharSpace + Result + GsCppLineEnding;
  end;
end;

function CJes2CppFunction.CppDefine: String;
begin
  Result := Format(GsCppInlineSpace + GsCppFunct2 + LineEnding + '{' + LineEnding + '%s',
    [CppEncodeEelF(CppEncodeFunction(Name), FIsRef), CppParameters, CppLocalVars]);
  Result += FBody + GsCppReturnSpace + FReturnExpression + GsCppLineEnding + '}' + LineEnding;
end;

function CJes2CppFunction.IsNameLocal(const AName: TComponentName): Boolean;
begin
  Result := J2C_IdentIsNameSpaceThis(AName) or FParams.ExistsIdent(AName) or FLocals.ExistsIdent(AName);
end;

function CJes2CppFunction.IsInternalAndUsed: Boolean;
begin
  // TODO: For now, print all functions.
  // There is an issue in opperator code which uses strcat/strcpy.
  Result := (IdentType = itInternal);// and (References.ComponentCount > 1);
end;

function CJes2CppFunction.DefaultNameSpace: String;
begin
  Result := Name + CharDot;
end;

function CJes2CppFunctions.GetFunction(const AIndex: Integer): CJes2CppFunction;
begin
  Result := Components[AIndex] as CJes2CppFunction;
end;

function CJes2CppFunctions.FindFunction(const AIdent: TIdentString; const ACount: Integer): CJes2CppFunction;
var
  LIndex: Integer;
begin
  for LIndex := ItemFirst(Self) to ItemLast(Self) do
  begin
    Result := GetFunction(LIndex);
    if Result.IsIdent(AIdent) and Result.FParams.IsCountMatch(ACount) then
    begin
      Exit;
    end;
  end;
  Result := nil;
end;

function CJes2CppFunctions.FindFunction(const AName: TIdentString; out ANameSpace, AFunctName: String;
  const ACount: Integer): CJes2CppFunction;
var
  LPos: Integer;
begin
  ANameSpace := EmptyStr;
  LPos := M_ZERO;
  repeat
    Result := FindFunction(Copy(AName, LPos + 1, MaxInt), ACount);
    if Assigned(Result) then
    begin
      ANameSpace := Copy(AName, 1, LPos);
      AFunctName := Copy(AName, LPos + 1, MaxInt);
      if ANameSpace = EmptyStr then
      begin
        ANameSpace := Result.DefaultNameSpace;
      end;
      Break;
    end;
    LPos := PosEx(CharDot, AName, LPos + 1);
  until LPos = M_ZERO;
end;

end.

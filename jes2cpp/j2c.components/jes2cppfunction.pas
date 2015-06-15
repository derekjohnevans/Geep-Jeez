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
  Classes, Jes2CppConstants, Jes2CppEel, Jes2CppFunctionIdentifiers, Jes2CppIdentifier, Jes2CppIdentString,
  Jes2CppIterate, Jes2CppMessageLog, Jes2CppStrings, Jes2CppTranslate, StrUtils, SysUtils;

type


  CJes2CppFunction = class(CJes2CppIdentifier)
  strict private
    FForceGlobals, FHasGlobals, FIsRef: Boolean;
    FParams, FStatic, FLocals, FGlobals, FInstancesSelf, FInstancesAll: CJes2CppFunctionIdentifiers;
  public
    FBody, FReturnExpression: String;
  strict private
    function CppEncodeParameters: String;
    function CppEncodeLocalVars: String;
    function CppEncodeStaticVars: String;
  public
    constructor Create(const AOwner: TComponent; const AName: TComponentName); override;
  public
    function ExistsGlobal(const AIdent: TIdentString; const AMessageLog: CJes2CppMessageLog): Boolean;
    function ExistsInstanceSelf(const AIdent: TIdentString; const AMessageLog: CJes2CppMessageLog): Boolean;
    function ExistsLocal(const AIdent: TIdentString; const AMessageLog: CJes2CppMessageLog): Boolean;
    function ExistsParam(const AIdent: TIdentString; const AMessageLog: CJes2CppMessageLog): Boolean;
    function ExistsStatic(const AIdent: TIdentString; const AMessageLog: CJes2CppMessageLog): Boolean;
  public
    procedure AppendInstance(const AIdent: TIdentString; const AMessageLog: CJes2CppMessageLog);
    function CppDefine: String;
    function DefaultNameSpace: String;
    function EelDefine: String;
    function GetTitle: String;
    function IsInternalAndUsed: Boolean;
    function IsNameLocal(const AName: TComponentName; const AMessageLog: CJes2CppMessageLog): Boolean;
  public
    property HasGlobals: Boolean read FHasGlobals write FHasGlobals;
    property ForceGlobals: Boolean read FForceGlobals write FForceGlobals;
    property IsRef: Boolean read FIsRef write FIsRef;
    property Params: CJes2CppFunctionIdentifiers read FParams;
    property Static: CJes2CppFunctionIdentifiers read FStatic;
    property Locals: CJes2CppFunctionIdentifiers read FLocals;
    property Globals: CJes2CppFunctionIdentifiers read FGlobals;
    property InstancesSelf: CJes2CppFunctionIdentifiers read FInstancesSelf;
    property InstancesAll: CJes2CppFunctionIdentifiers read FInstancesAll;
  end;

  CJes2CppFunctions = class(CJes2CppIdentifiers)
  public
    function GetFunction(const AIndex: Integer): CJes2CppFunction;
    function FindFunction(const AIdent: TIdentString; const ACount: Integer): CJes2CppFunction; overload;
    function FindFunction(const AName: TIdentString; out ANameSpace, AFunctName: String; const ACount: Integer): CJes2CppFunction;
      overload;
  end;

implementation

constructor CJes2CppFunction.Create(const AOwner: TComponent; const AName: TComponentName);
begin
  inherited Create(AOwner, AName);
  FParams := CJes2CppFunctionIdentifiers.Create(Self, EmptyStr);
  FStatic := CJes2CppFunctionIdentifiers.Create(Self, EmptyStr);
  FLocals := CJes2CppFunctionIdentifiers.Create(Self, EmptyStr);
  FGlobals := CJes2CppFunctionIdentifiers.Create(Self, EmptyStr);
  FInstancesSelf := CJes2CppFunctionIdentifiers.Create(Self, EmptyStr);
  FInstancesAll := CJes2CppFunctionIdentifiers.Create(Self, EmptyStr);
end;

function CJes2CppFunction.ExistsLocal(const AIdent: TIdentString; const AMessageLog: CJes2CppMessageLog): Boolean;
begin
  Result := FLocals.ExistsIdent(AIdent, AMessageLog);
end;

function CJes2CppFunction.ExistsParam(const AIdent: TIdentString; const AMessageLog: CJes2CppMessageLog): Boolean;
begin
  Result := FParams.ExistsIdent(AIdent, AMessageLog);
end;

function CJes2CppFunction.ExistsStatic(const AIdent: TIdentString; const AMessageLog: CJes2CppMessageLog): Boolean;
begin
  Result := FStatic.ExistsIdent(AIdent, AMessageLog);
end;

function CJes2CppFunction.ExistsGlobal(const AIdent: TIdentString; const AMessageLog: CJes2CppMessageLog): Boolean;
begin
  Result := FGlobals.ExistsSameText(AIdent);
end;

function CJes2CppFunction.ExistsInstanceSelf(const AIdent: TIdentString; const AMessageLog: CJes2CppMessageLog): Boolean;
begin
  Result := FInstancesSelf.ExistsIdent(AIdent, AMessageLog);
end;

procedure CJes2CppFunction.AppendInstance(const AIdent: TIdentString; const AMessageLog: CJes2CppMessageLog);
var
  LIndex: Integer;
begin
  Assert(Assigned(AMessageLog));
  LIndex := FInstancesAll.IndexOfIdent(AIdent);
  if LIndex < 0 then
  begin
    FInstancesAll.Append(AIdent);
  end else begin
    AMessageLog.LogWarningCaseCheck(AIdent, FInstancesAll[LIndex].Name);
  end;
end;

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
  LIndex: Integer;
begin
  Result := EmptyStr;
  for LIndex := IndexFirst(FParams) to IndexLast(FParams) do
  begin
    J2C_StringAppendCSV(Result, J2C_IdentClean(FParams[LIndex].Name));
  end;
  Result := Name + CharOpeningParenthesis + Result + CharClosingParenthesis;
end;

function CJes2CppFunction.CppEncodeParameters: String;
var
  LIndex: Integer;
begin
  Result := EmptyStr;
  for LIndex := IndexFirst(FParams) to IndexLast(FParams) do
  begin
    if FParams[LIndex].Name = GsEelVariadic then
    begin
      J2C_StringAppendCSV(Result, GsEelVariadic);
    end else begin
      J2C_StringAppendCSV(Result, CppEncodeEelF(CppEncodeVariable(FParams[LIndex].Name), False));
    end;
  end;
  for LIndex := IndexFirst(FInstancesAll) to IndexLast(FInstancesAll) do
  begin
    J2C_StringAppendCSV(Result, CppEncodeEelF(CppEncodeVariable(GsEelSpaceThis + FInstancesAll[LIndex].Name), True));
  end;
end;

function CJes2CppFunction.CppEncodeLocalVars: String;
var
  LIndex: Integer;
begin
  Result := EmptyStr;
  if FLocals.ComponentCount > M_ZERO then
  begin
    for LIndex := IndexFirst(FLocals) to IndexLast(FLocals) do
    begin
      J2C_StringAppendCSV(Result, CppEncodeVariable(FLocals[LIndex].Name) + GsCppEqu + GsCppZero);
    end;
    Result := GsCppEelF + CharSpace + Result + GsCppLineEnding;
  end;

end;

function CJes2CppFunction.CppEncodeStaticVars: String;
var
  LIndex: Integer;
begin
  Result := EmptyStr;
  if FStatic.ComponentCount > M_ZERO then
  begin
    for LIndex := IndexFirst(FStatic) to IndexLast(FStatic) do
    begin
      J2C_StringAppendCSV(Result, CppEncodeVariable(FStatic[LIndex].Name) + GsCppEqu + GsCppZero);
    end;
    Result := GsCppStatic + CharSpace + GsCppEelF + CharSpace + Result + GsCppLineEnding;
  end;
end;

function CJes2CppFunction.CppDefine: String;
begin
  Result := GsCppJes2CppInlineSpace + Format(GsCppFunct2, [CppEncodeEelF(CppEncodeFunction(Name), FIsRef), CppEncodeParameters]) +
    LineEnding + CharOpeningBrace + LineEnding + CppEncodeLocalVars + CppEncodeStaticVars + FBody +
    GsCppReturnSpace + FReturnExpression + GsCppLineEnding + CharClosingBrace + LineEnding;
end;

function CJes2CppFunction.IsNameLocal(const AName: TComponentName; const AMessageLog: CJes2CppMessageLog): Boolean;
begin
  Result := J2C_IdentIsNameSpaceThis(AName) or FParams.ExistsIdent(AName, AMessageLog) or FLocals.ExistsIdent(AName, AMessageLog);
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
  Result := Self[AIndex] as CJes2CppFunction;
end;

function CJes2CppFunctions.FindFunction(const AIdent: TIdentString; const ACount: Integer): CJes2CppFunction;
var
  LIndex: Integer;
begin
  for LIndex := IndexFirst(Self) to IndexLast(Self) do
  begin
    Result := GetFunction(LIndex);
    if Result.IsIdent(AIdent) and Result.Params.IsCountMatch(ACount) then
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

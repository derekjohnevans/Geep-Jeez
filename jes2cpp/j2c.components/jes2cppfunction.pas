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
{$MACRO ON}

interface

uses
  Classes, Jes2CppConstants, Jes2CppEel, Jes2CppFunctionIdentifiers,
  Jes2CppIdentifier, Jes2CppIdentString,
  Jes2CppMessageLog, Jes2CppStrings, Jes2CppTranslate, Math, Soda, StrUtils, SysUtils;

type

  CJes2CppFunctions = class;

  CJes2CppFunction = class
    {$DEFINE DItemClass := CJes2CppFunction}
    {$DEFINE DItemSuper := CJes2CppIdentifier}
    {$DEFINE DItemOwner := CJes2CppFunctions}
    {$INCLUDE soda.inc}
  strict private
    FForceGlobals, FHasGlobals: Boolean;
    FParams, FStatics, FLocals, FGlobals, FInstances, FInstancesAll: CJes2CppFunctionIdentifiers;
  public
    FBody, FReturnExpression: String;
  strict private
    function CppFunctionParams: String;
    function CppFunctionLocals: String;
    function CppFunctionStatics: String;
  protected
    procedure DoCreate; override;
  public
    function CppFunction: String;
    function EelPrototype: String;
    function CppFunctionName: String;
  public
    function GetNameSpace: String;
    function DefaultNameSpace: String;
    function GetTitle: String;
    function IsInternalAndUsed: Boolean;
    function IsNameLocal(const AName: TComponentName;
      const AMessageLog: CJes2CppMessageLog): Boolean;
    procedure AppendInstance(const AIdent: TIdentString; const AMessageLog: CJes2CppMessageLog);
  public
    property HasGlobals: Boolean read FHasGlobals write FHasGlobals;
    property ForceGlobals: Boolean read FForceGlobals write FForceGlobals;
  public
    property Params: CJes2CppFunctionIdentifiers read FParams;
    property Statics: CJes2CppFunctionIdentifiers read FStatics;
    property Locals: CJes2CppFunctionIdentifiers read FLocals;
    property Globals: CJes2CppFunctionIdentifiers read FGlobals;
    property Instances: CJes2CppFunctionIdentifiers read FInstances;
    property InstancesAll: CJes2CppFunctionIdentifiers read FInstancesAll;
  end;

  CJes2CppFunctions = class
    {$DEFINE DItemClass := CJes2CppFunctions}
    {$DEFINE DItemSuper := CComponent}
    {$DEFINE DItemOwner := CComponent}
    {$DEFINE DItemItems := CJes2CppFunction}
    {$INCLUDE soda.inc}
  public
    function FindFunction(const AIdent: TIdentString; const ACount: Integer): CJes2CppFunction;
    function FindOverload(const AName: TIdentString; out ANameSpace, AFunctName: String;
      const AParamCount: Integer): CJes2CppFunction;
  end;

implementation

{$DEFINE DItemClass := CJes2CppFunction} {$INCLUDE soda.inc}

{$DEFINE DItemClass := CJes2CppFunctions} {$INCLUDE soda.inc}

procedure CJes2CppFunction.DoCreate;
begin
  inherited DoCreate;
  FParams := CJes2CppFunctionIdentifiers.Create(Self);
  FStatics := CJes2CppFunctionIdentifiers.Create(Self);
  FLocals := CJes2CppFunctionIdentifiers.Create(Self);
  FGlobals := CJes2CppFunctionIdentifiers.Create(Self);
  FInstances := CJes2CppFunctionIdentifiers.Create(Self);
  FInstancesAll := CJes2CppFunctionIdentifiers.Create(Self);
end;

procedure CJes2CppFunction.AppendInstance(const AIdent: TIdentString;
  const AMessageLog: CJes2CppMessageLog);
var
  LIndex: Integer;
begin
  Assert(Assigned(AMessageLog));
  LIndex := FInstancesAll.IndexOfIdent(AIdent);
  if LIndex < 0 then
  begin
    FInstancesAll.CreateComponent(AIdent);
  end else begin
    AMessageLog.LogWarningCaseCheck(AIdent, FInstancesAll[LIndex].Name);
  end;
end;

function CJes2CppFunction.GetTitle: String;
begin
  Result := GsEelFunction + CharSpace + EelPrototype + LineEnding + Comment + LineEnding;
  if References.HasComponents then
  begin
    Result += References[0].EncodeLineFile;
  end;
end;

function CJes2CppFunction.EelPrototype: String;
var
  LIdent: TComponent;
begin
  Result := EmptyStr;
  for LIdent in FParams do
  begin
    GString.AppendCSV(Result, GIdentString.Clean(LIdent.Name));
  end;
  Result := Name + CharOpeningParenthesis + Result + CharClosingParenthesis;
end;

function CJes2CppFunction.CppFunctionParams: String;
var
  LIdent: CJes2CppDataType;
begin
  Result := EmptyStr;
  for LIdent in FParams do
  begin
    if LIdent.Name = GsEelVariadic then
    begin
      GString.AppendCSV(Result, GsEelVariadic);
    end else begin
      GString.AppendCSV(Result, LIdent.DataType + CharSpace +
        GCpp.Encode.NameVariable(LIdent.Name));
    end;
  end;
  for LIdent in FInstancesAll do
  begin
    GString.AppendCSV(Result, LIdent.DataType + CharAmpersand + CharSpace +
      GCpp.Encode.NameVariable(GsEelSpaceThis + LIdent.Name));
  end;
end;

function CJes2CppFunction.CppFunctionLocals: String;
var
  LComponent: TComponent;
begin
  Result := EmptyStr;
  if FLocals.HasComponents then
  begin
    for LComponent in FLocals do
    begin
      GString.AppendCSV(Result, GCpp.Encode.NameVariable(LComponent.Name) +
        GsCppAssign + GsCppZero);
    end;
    Result := GsCppEelF + CharSpace + Result + GsCppLineEnding;
  end;
end;

function CJes2CppFunction.CppFunctionStatics: String;
var
  LComponent: TComponent;
begin
  Result := EmptyStr;
  if FStatics.HasComponents then
  begin
    for LComponent in FStatics do
    begin
      GString.AppendCSV(Result, GCpp.Encode.NameVariable(LComponent.Name) +
        GsCppAssign + GsCppZero);
    end;
    Result := GsCppStatic + CharSpace + GsCppEelF + CharSpace + Result + GsCppLineEnding;
  end;
end;

function CJes2CppFunction.CppFunctionName: String;
begin
  Result := GCpp.Encode.NameFunction(Name, InstancesAll.ComponentCount);
end;

function CJes2CppFunction.CppFunction: String;
begin
  Result := GsCppJes2CppInlineSpace + Format(GsCppFunct2,
    [DataType + CharSpace + CppFunctionName, CppFunctionParams]) + LineEnding +
    CharOpeningBrace + LineEnding + CppFunctionLocals + CppFunctionStatics + FBody +
    GsCppReturnSpace + FReturnExpression + GsCppLineEnding + CharClosingBrace + LineEnding;
end;

function CJes2CppFunction.IsNameLocal(const AName: TComponentName;
  const AMessageLog: CJes2CppMessageLog): Boolean;
begin
  Result := GIdentString.IsNameSpaceThis(AName) or FParams.ExistsIdent(AName, AMessageLog) or
    FLocals.ExistsIdent(AName, AMessageLog);
end;

function CJes2CppFunction.IsInternalAndUsed: Boolean;
begin
  // TODO: For now, print all functions.
  // There is an issue in opperator code which uses strcat/strcpy.
  Result := (IdentType = itInternal);// and (References.Count > 1);
end;

function CJes2CppFunction.GetNameSpace: String;
var
  LPos: Integer;
begin
  LPos := RPos(CharDot, Name);
  if LPos = ZeroValue then
  begin
    Result := Name + CharDot;
  end else begin
    Result := Copy(Name, 1, LPos);
  end;
end;

function CJes2CppFunction.DefaultNameSpace: String;
begin
  Result := Name + CharDot;
end;

function CJes2CppFunctions.FindFunction(const AIdent: TIdentString;
  const ACount: Integer): CJes2CppFunction;
begin
  for Result in Self do
  begin
    if Result.IsIdent(AIdent) and Result.Params.IsCountMatch(ACount) then
    begin
      Exit;
    end;
  end;
  Result := nil;
end;

function CJes2CppFunctions.FindOverload(const AName: TIdentString;
  out ANameSpace, AFunctName: String; const AParamCount: Integer): CJes2CppFunction;
var
  LPos: Integer;
begin
  // TODO: We need to check function find order. Function namespaces might be a linear search, not a
  // namespace search.
  ANameSpace := EmptyStr;
  LPos := ZeroValue;
  repeat
    AFunctName := Copy(AName, LPos + 1, MaxInt);
    Result := FindFunction(AFunctName, AParamCount);
    if Assigned(Result) then
    begin
      ANameSpace := GIdentString.ExtractNameSpace(AName);
      // We can not use ExtractFuncName here because function names can
      // overlap namespaces.
      if ANameSpace = EmptyStr then
      begin
        ANameSpace := Result.DefaultNameSpace;
      end;
      Break;
    end;
    LPos := PosEx(CharDot, AName, LPos + 1);
  until LPos = ZeroValue;
end;

end.

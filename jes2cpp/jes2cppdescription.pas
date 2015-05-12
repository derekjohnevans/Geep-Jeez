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

unit Jes2CppDescription;

{$MODE DELPHI}

interface

uses
  Classes, Contnrs, Jes2CppConstants, Jes2CppEel, Jes2CppParameter, Jes2CppSections, Jes2CppTranslate, Jes2CppUtils, StrUtils, SysUtils;

type

  CJes2CppDescription = class(CJes2CppSections)
  strict private
    FAtDescription: String;
    FBuffer: String;
    FFileNames: TFPStringHashTable;
    FParameters: TJes2CppParameterDynArray;
    FEffectName, FProductString, FVendorString: String;
    FVendorVersion, FUniqueId: Integer;
  public
    FIsGfx, FIsSynth, FIsBass: Boolean;
    FChannelCount: Integer;
  strict private
    procedure ExtractSliders(const AStrings: TStrings);
    procedure ExtractFileNames(const AStrings: TStrings);
    procedure IterateFileName(AFileName: String; const AKey: String; var AContinue: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  public
    procedure ExtractDescriptionElements(const AScript: TStrings; const AFileName, ADefVendorString, ADefEffectName, ADefProductString: String;
      const ADefVendorVersion, ADefUniqueId: Integer);
    function ParameterCount: Integer;
    function CppSetSliders: String;
    function CppSetDescription: String;
    function CppSetFileNames: String;
  public
    property AtDescription: String read FAtDescription;
    property EffectName: String read FEffectName;
    property ProductString: String read FProductString;
    property VendorString: String read FVendorString;
  end;

implementation

constructor CJes2CppDescription.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFileNames := TFPStringHashTable.Create;
  FIsGfx := True;
  FChannelCount := 2;
end;

destructor CJes2CppDescription.Destroy;
begin
  FreeAndNil(FFileNames);
  inherited Destroy;
end;

procedure CJes2CppDescription.ExtractSliders(const AStrings: TStrings);
var
  LIndex: Integer;
  LSliderIndex: TEelSliderIndex;
begin
  SetLength(FParameters, 1);
  AStrings.NameValueSeparator := CharColon;
  for LSliderIndex in TEelSliderIndex do
  begin
    LIndex := AStrings.IndexOfName(SEelDescSlider + IntToStr(LSliderIndex));
    if (LIndex >= M_ZERO) and FParameters[High(FParameters)].FromString(AStrings[LIndex]) then
    begin
      if not AnsiStartsStr(CharMinusSign, FParameters[High(FParameters)].Text) then
      begin
        FIsGfx := False;
      end;
      SetLength(FParameters, Length(FParameters) + 1);
    end;
  end;
  SetLength(FParameters, High(FParameters));
  if Length(FParameters) = M_ZERO then
  begin
    FIsGfx := False;
  end;
end;

procedure CJes2CppDescription.ExtractFileNames(const AStrings: TStrings);
var
  LIndex, LPos1, LPos2: Integer;
  LString: String;
begin
  FFileNames.Clear;
  for LIndex := First(AStrings) to Last(AStrings) do
  begin
    LString := AStrings[LIndex];
    LPos1 := Pos(CharColon, LString);
    if LPos1 > M_ZERO then
    begin
      LPos2 := PosEx(CharComma, LString, LPos1);
      if LPos2 > M_ZERO then
      begin
        if SameText(Trim(Copy(LString, 1, LPos1 - 1)), SEelDescFileName) then
        begin
          LPos1 := StrToIntDef(Trim(Copy(LString, LPos1 + 1, LPos2 - LPos1 - 1)), -1);
          FFileNames.Add(IntToStr(LPos1), Trim(Copy(LString, LPos2 + 1, MaxInt)));
        end;
      end;
    end;
  end;
end;

procedure CJes2CppDescription.ExtractDescriptionElements(const AScript: TStrings;
  const AFileName, ADefVendorString, ADefEffectName, ADefProductString: String; const ADefVendorVersion, ADefUniqueId: Integer);
var
  LStrings: TStrings;
  LSectionHeader: String;
begin
  FAtDescription := Jes2CppExtractSection(SEelSectionDesc, AScript, AFileName, False, LSectionHeader);
  LStrings := TStringList.Create;
  try
    LStrings.Text := FAtDescription;
    FVendorString := Jes2CppGetValue(LStrings, SVendorString, ADefVendorString);
    FEffectName := Jes2CppGetValue(LStrings, SEffectName, ADefEffectName);
    FProductString := Jes2CppGetValue(LStrings, SProductString, ADefProductString);
    FVendorVersion := Jes2CppStrToIntDef(Jes2CppGetValue(LStrings, SVendorVersion, EmptyStr), ADefVendorVersion);
    FUniqueId := Jes2CppStrToIntDef(Jes2CppGetValue(LStrings, SUniqueId, EmptyStr), ADefUniqueId);
    ExtractSliders(LStrings);
    ExtractFileNames(LStrings);
  finally
    FreeAndNil(LStrings);
  end;
end;

function CJes2CppDescription.ParameterCount: Integer;
begin
  Result := Length(FParameters);
end;

function CJes2CppDescription.CppSetSliders: String;
var
  LIndex: Integer;
begin
  Result := EmptyStr;
  for LIndex := Low(FParameters) to High(FParameters) do
  begin
    Result += FParameters[LIndex].CppInitSliders;
  end;
end;

function CJes2CppDescription.CppSetDescription: String;
var
  LIndex: Integer;
begin
  Result := EmptyStr;
  Result += Format('FEffectName = %s;', [CppString(FEffectName)]) + LineEnding;
  Result += Format('FProductString = %s;', [CppString(FProductString)]) + LineEnding;
  Result += Format('FProgramName = %s;', [CppString(FProductString)]) + LineEnding;
  Result += Format('FVendorString = %s;', [CppString(FVendorString)]) + LineEnding;
  Result += Format('FVendorVersion = %d;', [FVendorVersion]) + LineEnding;
  Result += Format('FUniqueId = %d;', [FUniqueId]) + LineEnding;
  Result += Format('FChannelCount = %d;', [FChannelCount]) + LineEnding;
  for LIndex := Low(FParameters) to High(FParameters) do
  begin
    Result += FParameters[LIndex].CppAddParameters;
  end;
end;

procedure CJes2CppDescription.IterateFileName(AFileName: String; const AKey: String; var AContinue: Boolean);
begin
  FBuffer += Format('SetFileName(%s, %s);', [AKey, CppString(AFileName)]) + LineEnding;
end;

function CJes2CppDescription.CppSetFileNames: String;
begin
  FBuffer := EmptyStr;
  FFileNames.Iterate(IterateFileName);
  Result := FBuffer;
end;

end.

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
  Classes, Contnrs, Jes2CppConstants, Jes2CppEel, Jes2CppParameter, Jes2CppSections, Jes2CppStrings,
  Jes2CppTranslate, Jes2CppUtils, SysUtils;

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
    FIsSynth: Boolean;
    FChannelCount: Integer;
  strict private
    procedure ExtractSliders(const AScript: TStrings);
    procedure ExtractFileNames(const AScript: TStrings);
    procedure IterateFileName(AFileName: String; const AKey: String; var AContinue: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  public
    procedure ExtractDescriptionElements(const AScript: TStrings;
      const AFileName, ADefVendorString, ADefEffectName, ADefProductString, ADefVendorVersion, ADefUniqueId: String); overload;
    procedure ExtractDescriptionElements(const AScript: TStrings); overload;
  public
    function ParameterCount: Integer;
    function CppSetDescription: String;
    function CppSetFileNames: String;
  public
    property Parameters: TJes2CppParameterDynArray read FParameters;
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
  FChannelCount := 2;
end;

destructor CJes2CppDescription.Destroy;
begin
  FreeAndNil(FFileNames);
  inherited Destroy;
end;

procedure CJes2CppDescription.ExtractSliders(const AScript: TStrings);
var
  LIndex: Integer;
  LSliderIndex: TEelSliderIndex;
begin
  SetLength(FParameters, 1);
  AScript.NameValueSeparator := CharColon;
  for LSliderIndex in TEelSliderIndex do
  begin
    LIndex := J2C_StringsIndexOfName(AScript, GsEelDescSlider + IntToStr(LSliderIndex));
    if (LIndex >= M_ZERO) and FParameters[High(FParameters)].EelDecode(AScript[LIndex]) then
    begin
      if not FParameters[High(FParameters)].IsHidden then
      begin
        GfxEnabled := False;
      end;
      SetLength(FParameters, Length(FParameters) + 1);
    end;
  end;
  SetLength(FParameters, High(FParameters));
  if Length(FParameters) = M_ZERO then
  begin
    GfxEnabled := False;
  end;
end;

procedure CJes2CppDescription.ExtractFileNames(const AScript: TStrings);
var
  LIndex: Integer;
  LName, LValue, LFileIndex, LFileName: String;
begin
  FFileNames.Clear;
  for LIndex := 0 to EelDescHigh(AScript) do
  begin
    if J2C_DecodeNameValue(AScript[LIndex], LName, LValue) and SameText(LName, GsEelDescFileName) then
    begin
      if J2C_StringSplit(LValue, [CharComma], LFileIndex, LFileName) then
      begin
        FFileNames.Add(IntToStr(StrToInt(LFileIndex)), LFileName);
      end;
    end;
  end;
end;

procedure CJes2CppDescription.ExtractDescriptionElements(const AScript: TStrings;
  const AFileName, ADefVendorString, ADefEffectName, ADefProductString, ADefVendorVersion, ADefUniqueId: String);
var
  LSectionHeader: String;
begin
  FAtDescription := J2C_ExtractSection(GsEelSectionDesc, AScript, AFileName, False, LSectionHeader);
  FVendorString := J2C_StringsGetValue(AScript, GsVendorString, ADefVendorString);
  FEffectName := J2C_StringsGetValue(AScript, GsEffectName, ADefEffectName);
  FProductString := J2C_StringsGetValue(AScript, GsProductString, ADefProductString);
  FVendorVersion := J2C_StrToIntDef(J2C_StringsGetValue(AScript, GsVendorVersion, EmptyStr), J2C_StrToIntDef(ADefVendorVersion, 0));
  FUniqueId := J2C_StrToIntDef(J2C_StringsGetValue(AScript, GsUniqueId, EmptyStr), J2C_StrToIntDef(ADefUniqueId, 0));
  ExtractSliders(AScript);
  ExtractFileNames(AScript);
end;

procedure CJes2CppDescription.ExtractDescriptionElements(const AScript: TStrings);
begin
  ExtractDescriptionElements(AScript, EmptyStr, EmptyStr, EmptyStr, EmptyStr, EmptyStr, EmptyStr);
end;

function CJes2CppDescription.ParameterCount: Integer;
begin
  Result := Length(FParameters);
end;

function CJes2CppDescription.CppSetDescription: String;
var
  LIndex: Integer;
begin
  Result := EmptyStr;
  Result += Format('FEffectName = %s;', [CppEncodeString(FEffectName)]) + LineEnding;
  Result += Format('FProductString = %s;', [CppEncodeString(FProductString)]) + LineEnding;
  Result += Format('FProgramName = %s;', [CppEncodeString(FProductString)]) + LineEnding;
  Result += Format('FVendorString = %s;', [CppEncodeString(FVendorString)]) + LineEnding;
  Result += Format('FVendorVersion = %d;', [FVendorVersion]) + LineEnding;
  Result += Format('FUniqueId = %d;', [FUniqueId]) + LineEnding;
  Result += Format('FChannelCount = %d;', [FChannelCount]) + LineEnding;
  for LIndex := Low(FParameters) to High(FParameters) do
  begin
    Result += FParameters[LIndex].CppEncode;
  end;
end;

procedure CJes2CppDescription.IterateFileName(AFileName: String; const AKey: String; var AContinue: Boolean);
begin
  FBuffer += Format('SetFileName(%s, %s);', [AKey, CppEncodeString(AFileName)]) + LineEnding;
end;

function CJes2CppDescription.CppSetFileNames: String;
begin
  FBuffer := EmptyStr;
  FFileNames.Iterate(IterateFileName);
  Result := FBuffer;
end;

end.

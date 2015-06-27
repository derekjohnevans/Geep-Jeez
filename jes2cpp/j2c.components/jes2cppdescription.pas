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
{$MACRO ON}

interface

uses
  Classes, Dialogs,Jes2CppConstants, Jes2CppEel, Jes2CppIdentString, Jes2CppMessageLog,
  Jes2CppParameter, Jes2CppParserSimple, Jes2CppSections, Jes2CppStrings, Jes2CppTranslate, Jes2CppUtils, Soda, SysUtils;

type

  CJes2CppFileName = class(CComponent)
  public
    FFileName: TFileName;
  public
    function EncodeCpp: String;
  end;

  CJes2CppFileNames = class
    {$DEFINE DItemClass := CJes2CppFileNames}
    {$DEFINE DItemSuper := CComponent}
    {$DEFINE DItemItems := CJes2CppFileName}
    {$INCLUDE soda.inc}
  end;

  CJes2CppDescription = class(CJes2CppSections)
  strict private
    FAtDescription: String;
    FParameters: CJes2CppParameters;
    FFileNames: CJes2CppFileNames;
    FEffectName, FProductString, FVendorString: String;
    FVendorVersion, FUniqueId: Integer;
  public
    FIsSynth: Boolean;
    FChannelCount: Integer;
  strict private
    procedure ExtractSliders(const AScript: TStrings; const AFileName: TFileName);
    procedure ExtractFileNames(const AScript: TStrings; const AFileName: TFileName);
  protected
    procedure DoCreate; override;
  public
    procedure ExtractDescriptionElements(const AScript: TStrings;
      const AFileName, ADefVendorString, ADefEffectName, ADefProductString, ADefVendorVersion, ADefUniqueId: String); overload;
    procedure ExtractDescriptionElements(const AScript: TStrings); overload;
  public
    function EncodeDescriptionCpp: String;
    function EncodeFileNamesCpp: String;
  public
    property Parameters: CJes2CppParameters read FParameters;
    property AtDescription: String read FAtDescription;
    property EffectName: String read FEffectName;
    property ProductString: String read FProductString;
    property VendorString: String read FVendorString;
  end;

implementation

{$DEFINE DItemClass := CJes2CppFileNames}
{$INCLUDE soda.inc}

function CJes2CppFileName.EncodeCpp: String;
begin
  Result := Format(GsCppFunct3, ['SetFileName', Name, CppEncodeString(FFileName)]) + GsCppLineEnding;
end;

procedure CJes2CppDescription.DoCreate;
begin
  inherited DoCreate;
  FParameters := CJes2CppParameters.Create(Self);
  FFileNames := CJes2CppFileNames.Create(Self);
  FChannelCount := 2;
end;

procedure CJes2CppDescription.ExtractSliders(const AScript: TStrings; const AFileName: TFileName);
var
  LName, LValue: String;
  LIndex, LSlider: Integer;
  LParameter: CJes2CppParameter;
begin
  for LIndex := 0 to EelDescHigh(AScript) do
  begin
    if J2C_DecodeNameValue(AScript[LIndex], LName, LValue) and J2C_IdentIsSlider(LName, LSlider) then
    begin
      if FParameters.ComponentExists(IntToStr(LSlider)) then
      begin
        raise Exception.Create(NSLog.MessageCaretYSource('Slider is already defined.', LIndex + 1, AFileName));
      end;
      // TODO: For some reason, CreateComponent doesn't work here?
      LParameter := CJes2CppParameter.CreateNamed(FParameters, IntToStr(LSlider));
      try
        LParameter.DecodeEel(LSlider, LValue);
        if not LParameter.IsHidden then
        begin
          GfxEnabled := False;
        end;
      except
        on AException: Exception do
        begin
          raise Exception.Create(NSLog.MessageCaretYSource(AException.Message, LIndex + 1, AFileName));
        end;
      end;
    end;
  end;
  if FParameters.IsEmpty then
  begin
    GfxEnabled := False;
  end;
end;

procedure CJes2CppDescription.ExtractFileNames(const AScript: TStrings; const AFileName: TFileName);
var
  LIndex, LFile: Integer;
  LName, LValue, LFileName: String;
  LParser: TJes2CppParserSimple;
begin
  FFileNames.DestroyComponents;
  for LIndex := 0 to EelDescHigh(AScript) do
  begin
    if J2C_DecodeNameValue(AScript[LIndex], LName, LValue) and SameText(LName, GsEelDescFileName) then
    begin
      try
        LParser.SetSource(LValue);
        LParser.GetUntil([CharComma]);
        LFile := LParser.AsInteger(0, 256);
        LParser.GetUntil([CharNull]);
        LFileName := LParser.AsFileName;
        if FFileNames.ComponentExists(IntToStr(LFile)) then
        begin
          raise Exception.Create('File handle has already been defined.');
        end;
        CJes2CppFileName.CreateNamed(FFileNames, IntToStr(LFile)).FFileName := LFileName;
      except
        on AException: Exception do
        begin
          raise Exception.Create(NSLog.MessageCaretYSource(AException.Message, LIndex + 1, AFileName));
        end;
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
  ExtractSliders(AScript, AFileName);
  ExtractFileNames(AScript, AFileName);
end;

procedure CJes2CppDescription.ExtractDescriptionElements(const AScript: TStrings);
begin
  ExtractDescriptionElements(AScript, EmptyStr, EmptyStr, EmptyStr, EmptyStr, EmptyStr, EmptyStr);
end;

function CJes2CppDescription.EncodeDescriptionCpp: String;

  procedure LAppendNameValue(const AName, AValue: String); overload;
  begin
    Result += AName + GsCppAssign + CppEncodeString(AValue) + GsCppLineEnding;
  end;

  procedure LAppendNameValue(const AName: String; const AValue: Integer); overload;
  begin
    Result += AName + GsCppAssign + IntToStr(AValue) + GsCppLineEnding;
  end;

var
  LParameter: CJes2CppParameter;
begin
  Result := EmptyStr;
  LAppendNameValue('FEffectName', FEffectName);
  LAppendNameValue('FProductString', FProductString);
  LAppendNameValue('FProgramName', FProductString);
  LAppendNameValue('FVendorString', FVendorString);
  LAppendNameValue('FVendorVersion', FVendorVersion);
  LAppendNameValue('FUniqueId', FUniqueId);
  LAppendNameValue('FChannelCount', FChannelCount);
  for LParameter in FParameters do
  begin
    Result += LParameter.EncodeCpp;
  end;
end;

function CJes2CppDescription.EncodeFileNamesCpp: String;
var
  LFileName: CJes2CppFileName;
begin
  Result := EmptyStr;
  for LFileName in FFileNames do
  begin
    Result += LFileName.EncodeCpp;
  end;
end;

end.

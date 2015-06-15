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

unit Jes2Cpp;

{$MODE DELPHI}

interface

uses
  Classes, Jes2CppCompiler, Jes2CppConstants, Jes2CppEel, Jes2CppFileNames, Jes2CppIterate, Jes2CppPrinter, Jes2CppTranslate,
  SysUtils;

type

  CJes2Cpp = class(CJes2CppPrinter)
  strict private
    FIsNoOutput: Boolean;
  strict private
    procedure PrintAudioEffectCallBacks;
    procedure PrintAudioEffectEntryPoint;
    procedure PrintAudioEffectSetupCallBacks;
    procedure PrintParseSection(const ASectionName, AMethodName, ASource, AFileName: String);
    procedure PrintScriptClass(const AFileName: TFileName);
  public
    procedure TranspileScript(const AScript: TStrings;
      const AFileNameSrc, ADefVendorString, ADefEffectName, ADefProductString, ADefVendorVersion, ADefUniqueId: String); overload;
    procedure TranspileScript(const AScript: TStrings; const AFileNameSrc: String); overload;
    procedure TranspileScriptFromFile(const AFileNameSrc, ADefVendorString, ADefEffectName, ADefProductString,
      ADefVendorVersion, ADefUniqueId: String);
  public
    property IsNoOutput: Boolean read FIsNoOutput write FIsNoOutput;
  end;

procedure Jes2CppTranspile(const AFileNameDst, AFileNameSrc: TFileName;
  const ADefVendorString, ADefEffectName, ADefProductString, ADefVendorVersion, ADefUniqueId: String);

function Jes2CppTranspileCompile(const AFileName: TFileName;
  const ADefVendorString, ADefEffectName, ADefProductString, ADefVendorVersion, ADefUniqueId: String): TFileName;

implementation

procedure CJes2Cpp.PrintParseSection(const ASectionName, AMethodName, ASource, AFileName: String);
begin
  LogMessage(SMsgTypeParsing, EelSectionName(ASectionName));
  ResetParser(ASource, AFileName);
  PrintMethodHead(AMethodName);
  Print(ParseSectionBody);
  PrintMethodFoot;
  if not IsNull then
  begin
    LogExpected(SMsgEndOfCode);
  end;
end;

procedure CJes2Cpp.PrintScriptClass(const AFileName: TFileName);
var
  LIndex: Integer;
begin
  if not FIsNoOutput then
  begin
    PrintTitle(SMsgJes2CppEffectClass);
    Print('class %s : public %s', [GsTJes2CppEffect, GsTJes2Cpp]);
    Print(CharOpeningBrace);
    Print('public:');
  end;
  PrintParseSection(GsEelSectionInit, GsDoInit, Description.AtInit, AFileName);
  PrintParseSection(GsEelSectionSlider, GsDoSlider, Description.AtSlider, AFileName);
  PrintParseSection(GsEelSectionBlock, GsDoBlock, Description.AtBlock, AFileName);
  PrintParseSection(GsEelSectionSerialize, GsDoSerialize, Description.AtSerialize, AFileName);
  PrintParseSection(GsEelSectionSample, GsDoSample, Description.AtSample, AFileName);
  PrintParseSection(GsEelSectionGfx, GsDoGfx, Description.AtGfx, AFileName);

  if not FIsNoOutput then
  begin
    if IndexCount(Variables) > M_ZERO then
    begin
      PrintTitle(SMsgDefineGlobalVariables);
      Print(Variables.CppDefineVariables);
      PrintBlankLine;
    end;
    if IndexCount(Loops) > M_ZERO then
    begin
      PrintTitle(SMsgDefineInnerLoops);
      for LIndex := IndexFirst(Loops) to IndexLast(Loops) do
      begin
        Print(Loops.GetLoop(LIndex).CppDefine);
      end;
    end;
    PrintTitle(SMsgDefineInternalFunctions);
    for LIndex := IndexFirst(Functions) to IndexLast(Functions) do
    begin
      if Functions.GetFunction(LIndex).IsInternalAndUsed then
      begin
        PrintTitle(Functions.GetFunction(LIndex).GetTitle);
        Print(Functions.GetFunction(LIndex).CppDefine);
      end;
    end;

    PrintMethodHead(GsDoOpen);
    Print(Variables.CppClear);
    Print(Description.CppSetFileNames);
    Print(Variables.CppSetStringConstants);
    PrintMethodFoot;

    Print(GsCppFunct1, [GsTJes2CppEffect]);
    Print(CharOpeningBrace);
    PrintTitle(SMsgEffectDescription);
    Print(Description.CppSetDescription);
    PrintMethodFoot;

    Print(CharClosingBrace + CharSemiColon);
  end;
end;

procedure CJes2Cpp.PrintAudioEffectCallBacks;

  procedure LPrintDefineLJes2Cpp;
  begin
    Print('TJes2Cpp* LJes2Cpp = ((TJes2Cpp*)VeST_GetData(AVeST));');
  end;

  procedure LPrintJes2Cpp(const AFuncCall: String);
  begin
    Print('((TJes2Cpp*)VeST_GetData(AVeST))->' + AFuncCall);
  end;

  procedure LPrintJes2CppReturn(const AFuncCall: String);
  begin
    Print('return ((TJes2Cpp*)VeST_GetData(AVeST))->' + AFuncCall);
  end;

  procedure LPrintFunctionNotify(const AName: String);
  begin
    Print(GsCppVoidSpace + 'VEST_WINAPI EffectDo%s(HVEST AVeST)', [AName]);
    Print(CharOpeningBrace);
    LPrintJes2Cpp('Do' + AName + '();');
    Print(CharClosingBrace);
  end;

  procedure LPrintProcessReplacing(const AName, AFloatType: String);
  begin
    Print(GsCppVoidSpace + 'VEST_WINAPI %s(HVEST AVeST, %s** AInputs, %s** AOutputs, int ASampleFrames)', [AName, AFloatType, AFloatType]);
    Print(CharOpeningBrace);
    LPrintJes2Cpp(GsDoSample + '(AInputs, AOutputs, ASampleFrames);');
    Print(CharClosingBrace);
  end;

begin
  PrintTitle(SMsgJes2CppAudioCallBacks);
  Print(GsCppVoidSpace + 'VEST_WINAPI EffectDoCreate(HVEST AVeST)');
  Print(CharOpeningBrace);
  LPrintDefineLJes2Cpp;
  Print('VeST_SetNumInputs(AVeST, LJes2Cpp->GetChannelCount());');
  Print('VeST_SetNumOutputs(AVeST, LJes2Cpp->GetChannelCount());');
  Print('VeST_SetUniqueID(AVeST, LJes2Cpp->GetUniqueId());');
  Print('VeST_SetGraphicsSize(AVeST, %d, %d);', [Description.GfxWidth, Description.GfxHeight], Description.GfxEnabled);
  Print('VeST_SetIsSynth(AVeST, true);', Description.FIsSynth);
  Print(CharClosingBrace);
  Print(GsCppVoidSpace + 'VEST_WINAPI EffectDoDestroy(HVEST AVeST)');
  Print(CharOpeningBrace);
  LPrintDefineLJes2Cpp;
  Print('if (LJes2Cpp) delete LJes2Cpp;');
  Print(CharClosingBrace);
  LPrintFunctionNotify(GsOpen);
  LPrintFunctionNotify(GsClose);
  LPrintFunctionNotify(GsSuspend);
  LPrintFunctionNotify(GsResume);
  Print(GsCppVoidSpace + 'VEST_WINAPI EffectDoIdle(HVEST AVeST)');
  Print(CharOpeningBrace);
  LPrintJes2Cpp(GsDoIdle + '();');
  Print(CharClosingBrace);
  Print(GsCppVoidSpace + 'VEST_WINAPI EffectDoDraw(HVEST AVeST, double AWidth, double AHeight)');
  Print(CharOpeningBrace);
  LPrintJes2Cpp(GsDoGfx + '();');
  Print(CharClosingBrace);
  Print(GsCppVoidSpace + 'VEST_WINAPI EffectDoMouseMoved(HVEST AVeST, double AX, double AY, int AButtons)');
  Print(CharOpeningBrace);
  LPrintJes2Cpp('SetMouse(AX, AY, AButtons);');
  Print(CharClosingBrace);
  Print(GsCppVoidSpace + 'VEST_WINAPI EffectDoMouseDown(HVEST AVeST, double AX, double AY, int AButtons)');
  Print(CharOpeningBrace);
  Print('EffectDoMouseMoved(AVeST, AX, AY, AButtons);');
  Print(CharClosingBrace);
  Print(GsCppVoidSpace + 'VEST_WINAPI EffectDoMouseUp(HVEST AVeST, double AX, double AY, int AButtons)');
  Print(CharOpeningBrace);
  Print('EffectDoMouseMoved(AVeST, AX, AY, AButtons);');
  Print(CharClosingBrace);
  Print('int VEST_WINAPI EffectDoGetChunk(HVEST AVeST, void** AData, bool AIsPreset)');
  Print(CharOpeningBrace);
  Print('return 0;');
  Print(CharClosingBrace);
  Print('int VEST_WINAPI EffectDoSetChunk(HVEST AVeST, void* AData, int ASize, bool AIsPreset)');
  Print(CharOpeningBrace);
  Print('return 0;');
  Print(CharClosingBrace);
  Print('int VEST_WINAPI EffectDoGetVendorVersion(HVEST AVeST)');
  Print(CharOpeningBrace);
  LPrintJes2CppReturn('GetVendorVersion();');
  Print(CharClosingBrace);
  Print('bool VEST_WINAPI EffectDoGetVendorString(HVEST AVeST, char* AString)');
  Print(CharOpeningBrace);
  LPrintJes2Cpp('GetVendorString(AString);');
  Print('return true;');
  Print(CharClosingBrace);
  Print('bool VEST_WINAPI EffectDoGetProductString(HVEST AVeST, char* AString)');
  Print(CharOpeningBrace);
  LPrintJes2Cpp('GetProductString(AString);');
  Print('return true;');
  Print(CharClosingBrace);
  Print('bool VEST_WINAPI EffectDoGetEffectName(HVEST AVeST, char* AString)');
  Print(CharOpeningBrace);
  LPrintJes2Cpp('GetEffectName(AString);');
  Print('return true;');
  Print(CharClosingBrace);
  Print(GsCppVoidSpace + 'VEST_WINAPI EffectDoSetProgramName(HVEST AVeST, char* AString)');
  Print(CharOpeningBrace);
  LPrintJes2Cpp('SetProgramName(AString);');
  Print(CharClosingBrace);
  Print('bool VEST_WINAPI EffectDoGetProgramName(HVEST AVeST, char* AString)');
  Print(CharOpeningBrace);
  LPrintJes2Cpp('GetProgramName(AString);');
  Print('return true;');
  Print(CharClosingBrace);
  Print('bool VEST_WINAPI EffectDoGetProgramNameIndexed(HVEST AVeST, int ACategory, int AIndex, char* AString)');
  Print(CharOpeningBrace);
  Print('return false;');
  Print(CharClosingBrace);
  Print(GsCppVoidSpace + 'VEST_WINAPI EffectDoSetParameter(HVEST AVeST, int AIndex, double AValue)');
  Print(CharOpeningBrace);
  LPrintJes2Cpp('SetParameterValue(AIndex, AValue);');
  Print(CharClosingBrace);
  Print('double VEST_WINAPI EffectDoGetParameter(HVEST AVeST, int AIndex)');
  Print(CharOpeningBrace);
  LPrintJes2CppReturn('GetParameterValue(AIndex);');
  Print(CharClosingBrace);
  Print(GsCppVoidSpace + 'VEST_WINAPI EffectDoGetParameterName(HVEST AVeST, int AIndex, char* AString)');
  Print(CharOpeningBrace);
  LPrintJes2Cpp('GetParameterName(AIndex, AString);');
  Print(CharClosingBrace);
  Print(GsCppVoidSpace + 'VEST_WINAPI EffectDoGetParameterLabel(HVEST AVeST, int AIndex, char* AString)');
  Print(CharOpeningBrace);
  LPrintJes2Cpp('GetParameterLabel(AIndex, AString);');
  Print(CharClosingBrace);
  Print(GsCppVoidSpace + 'VEST_WINAPI EffectDoGetParameterDisplay(HVEST AVeST, int AIndex, char* AString)');
  Print(CharOpeningBrace);
  LPrintJes2Cpp('GetParameterDisplay(AIndex, AString);');
  Print(CharClosingBrace);
  LPrintProcessReplacing('EffectDoProcessReplacing', GsCppFloat);
  LPrintProcessReplacing('EffectDoProcessDoubleReplacing', GsCppDouble);
end;

procedure CJes2Cpp.PrintAudioEffectSetupCallBacks;

  procedure LPrintSetCallBack(const AName: String; const AIsRequired: Boolean = True);
  begin
    Print('AVeSTCallBacks->On%s = EffectDo%s;', [AName, AName], AIsRequired);
  end;

begin
  PrintTitle(SMsgCreateAudioEffectInstance);
  Print('void EffectSetupCallBacks(TVeSTCallBacks* AVeSTCallBacks)');
  Print(CharOpeningBrace);
  Print('memset(AVeSTCallBacks, 0, sizeof(*AVeSTCallBacks));');
  LPrintSetCallBack(GsClose);
  LPrintSetCallBack(GsCreate);
  LPrintSetCallBack(GsDestroy);
  LPrintSetCallBack(GsDraw, Description.GfxEnabled);
  LPrintSetCallBack(GsGetChunk);
  LPrintSetCallBack(GsGetEffectName);
  LPrintSetCallBack(GsGetParameter);
  LPrintSetCallBack(GsGetParameterDisplay);
  LPrintSetCallBack(GsGetParameterLabel);
  LPrintSetCallBack(GsGetParameterName);
  LPrintSetCallBack(GsGetProductString);
  LPrintSetCallBack(GsGetProgramName);
  LPrintSetCallBack(GsGetProgramNameIndexed);
  LPrintSetCallBack(GsGetVendorString);
  LPrintSetCallBack(GsGetVendorVersion);
  LPrintSetCallBack(GsIdle);
  LPrintSetCallBack(GsMouseDown, Description.GfxEnabled);
  LPrintSetCallBack(GsMouseMoved, Description.GfxEnabled);
  LPrintSetCallBack(GsMouseUp, Description.GfxEnabled);
  LPrintSetCallBack(GsOpen);
  LPrintSetCallBack(GsProcessDoubleReplacing);
  LPrintSetCallBack(GsProcessReplacing);
  LPrintSetCallBack(GsResume);
  LPrintSetCallBack(GsSetChunk);
  LPrintSetCallBack(GsSetParameter);
  LPrintSetCallBack(GsSetProgramName);
  LPrintSetCallBack(GsSuspend);
  Print(CharClosingBrace);
end;

procedure CJes2Cpp.PrintAudioEffectEntryPoint;

  procedure LPrintEntryPointBody(const ASystemVariable, AReturnFunction: String);
  begin
    Print(CharOpeningBrace);
    Print('TVeSTCallBacks LVeSTCallBacks;');
    Print('EffectSetupCallBacks(&LVeSTCallBacks);');
    Print('TJes2CppEffect* LJes2Cpp = new TJes2CppEffect();');
    Print('LJes2Cpp->FVeST = VeST_Init((HVEST_DATA)LJes2Cpp, &LVeSTCallBacks, ' + ASystemVariable +
      ', 1, LJes2Cpp->GetParameterCount());');
    Print('return ' + AReturnFunction + '(LJes2Cpp->FVeST);');
    Print(CharClosingBrace);
  end;

  procedure LPrintAlias(const APlatform, AName: String);
  begin
    Print('#if (%s)', [APlatform]);
    Print('JES2CPP_EXPORT VEST_HANDLE %s(HVEST_AUDIOMASTER AAudioMaster)', [AName]);
    Print(CharOpeningBrace);
    Print('return VSTPluginMain(AAudioMaster);');
    Print(CharClosingBrace);
    Print('#endif');
  end;

begin
  PrintTitle('Define VSTPluginMain() - VST Entry Point');
  print('#ifdef VEST_VST');
  PrintExternCHead;
  Print('JES2CPP_EXPORT VEST_HANDLE VSTPluginMain(HVEST_AUDIOMASTER AAudioMaster)');
  LPrintEntryPointBody('AAudioMaster', 'VeST_GetAEffect');
  Print('// Support for old hosts not looking for VSTPluginMain');
  LPrintAlias('TARGET_API_MAC_CARBON && __ppc__', 'main_macho');
  LPrintAlias(GsCppWin32, 'MAIN');
  LPrintAlias(GsCppBeos, 'main_plugin');
  PrintExternCFoot;
  print('#endif // VEST_VST');

  PrintTitle('Define ladspa_descriptor() - LADSPA v1 Entry Point');
  Print('#ifdef VEST_LV1');
  PrintExternCHead;
  Print('JES2CPP_EXPORT const LADSPA_Descriptor* ladspa_descriptor(unsigned long AIndex)');
  Print(CharOpeningBrace);
  Print('if (!AIndex)');
  LPrintEntryPointBody('NULL', 'VeST_GetLADSPA');
  Print('return NULL;');
  Print(CharClosingBrace);
  PrintExternCFoot;
  print('#endif // VEST_LV1');

  PrintTitle('Define lv2_descriptor() - LADSPA v2 Entry Point (NOT FINISHED)');
  Print('#ifdef VEST_LV2');
  PrintExternCHead;
  Print('JES2CPP_EXPORT const LV2_Descriptor* lv2_descriptor(uint32_t AIndex)');
  Print(CharOpeningBrace);
  Print('if (!AIndex)');
  LPrintEntryPointBody('NULL', 'VeST_GetLADSPA');
  Print('return NULL;');
  Print(CharClosingBrace);
  PrintExternCFoot;
  print('#endif // VEST_LV2');
end;

procedure CJes2Cpp.TranspileScript(const AScript: TStrings;
  const AFileNameSrc, ADefVendorString, ADefEffectName, ADefProductString, ADefVendorVersion, ADefUniqueId: String);
begin
  LogMessage(SMsgStarted);
  try
    Output.Clear;

    LogMessage(SMsgTypeParsing, SMsgDescription);

    if not SameText(ExtractFileName(AFileNameSrc), ExtractFileName(TJes2CppFileNames.FileNameJes2CppJsFx)) then
    begin
      ImportFrom(TJes2CppFileNames.FileNameJes2CppJsFx);
    end;
    ImportFrom(AScript, AFileNameSrc);

    Description.ExtractDescriptionElements(AScript, AFileNameSrc, ADefVendorString, ADefEffectName, ADefProductString,
      ADefVendorVersion, ADefUniqueId);

    LogMessage(Format('%s=%s %s=%s %s=%s', [GsVendorString, QuotedStr(Description.VendorString), GsEffectName,
      QuotedStr(Description.EffectName), GsProductString, QuotedStr(Description.ProductString)]));

    LogMessage(Format(SMsgNumberOfParametersFound1, [Description.ParameterCount]));

    if not FIsNoOutput then
    begin
      PrintTitle(SMsgConvertedWith + GsJes2CppTitle);
      PrintOriginalComments(Description.AtDescription);
      PrintTitle('Include ' + GsJes2CppName + ' Header');
      Print('#include "' + GsFilePartJes2Cpp + GsFileExtH + '"');
    end;
    PrintScriptClass(AFileNameSrc);
    if not FIsNoOutput then
    begin
      PrintAudioEffectCallBacks;
      PrintAudioEffectSetupCallBacks;
      PrintAudioEffectEntryPoint;
      PrintTitle('End of File');
    end;
  finally
    LogMessage(SMsgFinished);
  end;
end;

procedure CJes2Cpp.TranspileScript(const AScript: TStrings; const AFileNameSrc: String);
begin
  TranspileScript(AScript, AFileNameSrc, EmptyStr, EmptyStr, EmptyStr, EmptyStr, EmptyStr);
end;

procedure CJes2Cpp.TranspileScriptFromFile(const AFileNameSrc, ADefVendorString, ADefEffectName, ADefProductString,
  ADefVendorVersion, ADefUniqueId: String);
var
  LStrings: TStrings;
begin
  LStrings := TStringList.Create;
  try
    LStrings.LoadFromFile(AFileNameSrc);
    TranspileScript(LStrings, AFileNameSrc, ADefVendorString, ADefEffectName, ADefProductString, ADefVendorVersion, ADefUniqueId);
  finally
    FreeAndNil(LStrings);
  end;
end;

procedure Jes2CppTranspile(const AFileNameDst, AFileNameSrc: TFileName;
  const ADefVendorString, ADefEffectName, ADefProductString, ADefVendorVersion, ADefUniqueId: String);
begin
  with CJes2Cpp.Create(nil, EmptyStr) do
  begin
    try
      TranspileScriptFromFile(AFileNameSrc, ADefVendorString, ADefEffectName, ADefProductString, ADefVendorVersion, ADefUniqueId);
      Output.SaveToFile(AFileNameDst);
    finally
      Free;
    end;
  end;
end;

function Jes2CppTranspileCompile(const AFileName: TFileName;
  const ADefVendorString, ADefEffectName, ADefProductString, ADefVendorVersion, ADefUniqueId: String): TFileName;
var
  LJes2Cpp: CJes2Cpp;
begin
  LJes2Cpp := CJes2Cpp.Create(nil, EmptyStr);
  try
    LJes2Cpp.TranspileScriptFromFile(AFileName, ADefVendorString, ADefEffectName, ADefProductString, ADefVendorVersion, ADefUniqueId);
    with CJes2CppCompiler.Create(nil) do
    begin
      try
        Result := Compile('g++', LJes2Cpp.Output);
      finally
        Free;
      end;
    end;
  finally
    FreeAndNil(LJes2Cpp);
  end;
end;

end.

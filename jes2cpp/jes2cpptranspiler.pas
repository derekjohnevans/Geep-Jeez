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

unit Jes2CppTranspiler;

{$MODE DELPHI}

interface

uses
  Classes, Jes2CppConstants, Jes2CppEel, Jes2CppFunction, Jes2CppIdentifier, Jes2CppLoop, Jes2CppTranslate,
  Jes2CppTranspilerPrinter, Jes2CppUtils, SysUtils;

type

  TJes2CppClientType = (ctVST, ctLADSPA);

  CJes2CppTranspiler = class(CJes2CppTranspilerPrinter)
  strict private
    FClientType: TJes2CppClientType;
    FIsNoOutput: Boolean;
  strict private
    procedure PrintScriptClass(const AFileName: TFileName);
    procedure PrintAudioEffectCallBacks;
    procedure PrintAudioEffectSetupCallBacks;
    procedure PrintAudioEffectEntryPoint;
  public
    procedure TranspileScript(const AScript: TStrings; const AFileName, ADefVendorString, ADefEffectName, ADefProductString: String;
      const ADefVendorVersion, ADefUniqueId: Integer);
    procedure TranspileScriptFromFile(const AFileName, ADefVendorString, ADefEffectName, ADefProductString: String;
      const ADefVendorVersion, ADefUniqueId: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  public
    property IsNoOutput: Boolean read FIsNoOutput write FIsNoOutput;
  end;

procedure Jes2CppTranspile(const AFilenameDst, AFilenameSrc: TFileName; const ADefVendorString, ADefEffectName, ADefProductString: String;
  const ADefVendorVersion, ADefUniqueId: Integer);

implementation

constructor CJes2CppTranspiler.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor CJes2CppTranspiler.Destroy;
begin
  inherited Destroy;
end;

procedure CJes2CppTranspiler.PrintScriptClass(const AFileName: TFileName);
var
  LIndex: Integer;
  LString: String;
begin
  if not FIsNoOutput then
  begin
    PrintTitle(SMsgJes2CppEffectClass);

    Print('class %s : public %s', [STJes2CppEffect, STJes2Cpp]);
    Print(CharOpeningBrace);
    Print('public:');
  end;

  LString := EmptyStr;
  LString += ParseSection(SEelSectionInit, SDoInit, Description.AtInit, AFileName);
  LString += ParseSection(SEelSectionBlock, SDoBlock, Description.AtBlock, AFileName);
  LString += ParseSection(SEelSectionSlider, SDoSlider, Description.AtSlider, AFileName);
  LString += ParseSection(SEelSectionSample, SDoSample, Description.AtSample, AFileName);
  LString += ParseSection(SEelSectionGfx, SDoGfx, Description.AtGfx, AFileName);
  LString += ParseSection(SEelSectionSerialize, SDoSerialize, Description.AtSerialize, AFileName);

  if not FIsNoOutput then
  begin
    if Count(Variables) > M_ZERO then
    begin
      PrintTitle(SMsgDefineGlobalVariables);
      Print(Variables.CppDefineVariables);
      PrintBlankLine;
    end;

    for LIndex := First(Loops) to Last(Loops) do
    begin
      Print((Loops.Components[LIndex] as CJes2CppLoop).CppDefine);
    end;
    for LIndex := First(Functions) to Last(Functions) do
    begin
      if (Functions.Components[LIndex] as CJes2CppFunction).IdentType = itUser then
      begin
        Print((Functions.Components[LIndex] as CJes2CppFunction).CppDefine);
      end;
    end;

    Print(LString);

    Print(SCppVoidSpace + '%s()', [SDoOpen]);
    Print(CharOpeningBrace);
    Print(STJes2Cpp + '::' + SDoOpen + '();');
    Print(Variables.CppSetVariables);
    Print(Description.CppSetFileNames);
    Print(Variables.CppSetStringConstants);
    Print(CharClosingBrace);

    Print('%s()', [STJes2CppEffect]);
    Print(CharOpeningBrace);
    //Print(Description.CppSetSliders);  // Is not needed now.
    PrintTitle(SMsgEffectDescription);
    Print(Description.CppSetDescription);
    Print(CharClosingBrace);

    Print(CharClosingBrace + CharSemiColon);
  end;
end;

procedure CJes2CppTranspiler.PrintAudioEffectCallBacks;

  procedure LPrintDefineLJes2Cpp;
  begin
    Print('TJes2Cpp* LJes2Cpp = ((TJes2Cpp*)VeST_GetData(AVeST));');
  end;

  procedure LPrintFunctionNotify(const AName: String);
  begin
    Print(SCppVoidSpace + 'WINAPI EffectDo%s(HVEST AVeST)', [AName]);
    Print(CharOpeningBrace);
    LPrintDefineLJes2Cpp;
    Print('LJes2Cpp->Do%s();', [AName]);
    Print(CharClosingBrace);
  end;

  procedure LPrintProcessReplacing(const AName, AFloatType: String);
  begin
    Print(SCppVoidSpace + 'WINAPI %s(HVEST AVeST, %s** AInputs, %s** AOutputs, INT ASampleFrames)', [AName, AFloatType, AFloatType]);
    Print(CharOpeningBrace);
    LPrintDefineLJes2Cpp;
    Print('LJes2Cpp->%s(AInputs, AOutputs, ASampleFrames);', [SDoSample]);
    Print(CharClosingBrace);
  end;

begin
  PrintTitle(SMsgJes2CppAudioCallBacks);
  Print(SCppVoidSpace + 'WINAPI EffectDoCreate(HVEST AVeST)');
  Print(CharOpeningBrace);
  LPrintDefineLJes2Cpp;
  Print('VeST_SetNumInputs(AVeST, LJes2Cpp->FChannelCount);');
  Print('VeST_SetNumOutputs(AVeST, LJes2Cpp->FChannelCount);');
  Print('VeST_SetUniqueID(AVeST, LJes2Cpp->FUniqueId);');
  Print('VeST_SetGraphicsSize(AVeST, %d, %d);', [Description.GfxWidth, Description.GfxHeight], Description.FIsGfx);
  Print('VeST_SetIsSynth(AVeST, TRUE);', Description.FIsSynth);
  Print(CharClosingBrace);
  Print(SCppVoidSpace + 'WINAPI EffectDoDestroy(HVEST AVeST)');
  Print(CharOpeningBrace);
  LPrintDefineLJes2Cpp;
  Print('if (LJes2Cpp) delete LJes2Cpp;');
  Print(CharClosingBrace);
  LPrintFunctionNotify(SOpen);
  LPrintFunctionNotify(SClose);
  LPrintFunctionNotify(SSuspend);
  LPrintFunctionNotify(SResume);
  Print(SCppVoidSpace + 'WINAPI EffectDoIdle(HVEST AVeST)');
  Print(CharOpeningBrace);
  LPrintDefineLJes2Cpp;
  Print('LJes2Cpp->%s();', [SDoIdle]);
  Print(CharClosingBrace);
  Print(SCppVoidSpace + 'WINAPI EffectDoDraw(HVEST AVeST, INT AWidth, INT AHeight)');
  Print(CharOpeningBrace);
  LPrintDefineLJes2Cpp;
  Print('LJes2Cpp->%s();', [SDoGfx]);
  Print(CharClosingBrace);
  Print(SCppVoidSpace + 'WINAPI EffectDoMouseMoved(HVEST AVeST, INT AX, INT AY, INT AButtons)');
  Print(CharOpeningBrace);
  LPrintDefineLJes2Cpp;
  Print('LJes2Cpp->%s = ((AButtons&2)>>1)|((AButtons&4)<<4)|((AButtons&8)>>1);', [EelToCppVar(SEelVarMouseCap, vtGlobal)]);
  Print('LJes2Cpp->%s = (%s)AX;', [EelToCppVar(SEelVarMouseX, vtGlobal), SEelReal]);
  Print('LJes2Cpp->%s = (%s)AY;', [EelToCppVar(SEelVarMouseY, vtGlobal), SEelReal]);
  Print('LJes2Cpp->%s = GFX_RATE;', [EelToCppVar(SEelVarGfxRate, vtGlobal)]);
  Print(CharClosingBrace);
  Print(SCppVoidSpace + 'WINAPI EffectDoMouseDown(HVEST AVeST, INT AX, INT AY, INT AButtons)');
  Print(CharOpeningBrace);
  Print('EffectDoMouseMoved(AVeST, AX, AY, AButtons);');
  Print(CharClosingBrace);
  Print(SCppVoidSpace + 'WINAPI EffectDoMouseUp(HVEST AVeST, INT AX, INT AY, INT AButtons)');
  Print(CharOpeningBrace);
  Print('EffectDoMouseMoved(AVeST, AX, AY, AButtons);');
  Print(CharClosingBrace);
  Print('INT WINAPI EffectDoGetChunk(HVEST AVeST, PVOID* AData, BOOL AIsPreset)');
  Print(CharOpeningBrace);
  Print('return 0;');
  Print(CharClosingBrace);
  Print('INT WINAPI EffectDoSetChunk(HVEST AVeST, PVOID AData, INT ASize, BOOL AIsPreset)');
  Print(CharOpeningBrace);
  Print('return 0;');
  Print(CharClosingBrace);
  Print('INT WINAPI EffectDoGetVendorVersion(HVEST AVeST)');
  Print(CharOpeningBrace);
  LPrintDefineLJes2Cpp;
  Print('return LJes2Cpp->FVendorVersion;');
  Print(CharClosingBrace);
  Print('BOOL WINAPI EffectDoGetVendorString(HVEST AVeST, CHAR* AString)');
  Print(CharOpeningBrace);
  LPrintDefineLJes2Cpp;
  Print('strcpy(AString, LJes2Cpp->FVendorString.c_str());');
  Print('return TRUE;');
  Print(CharClosingBrace);
  Print('BOOL WINAPI EffectDoGetProductString(HVEST AVeST, CHAR* AString)');
  Print(CharOpeningBrace);
  LPrintDefineLJes2Cpp;
  Print('strcpy(AString, LJes2Cpp->FProductString.c_str());');
  Print('return TRUE;');
  Print(CharClosingBrace);
  Print('BOOL WINAPI EffectDoGetEffectName(HVEST AVeST, CHAR* AString)');
  Print(CharOpeningBrace);
  LPrintDefineLJes2Cpp;
  Print('strcpy(AString, LJes2Cpp->FEffectName.c_str());');
  Print('return TRUE;');
  Print(CharClosingBrace);
  Print(SCppVoidSpace + 'WINAPI EffectDoSetProgramName(HVEST AVeST, CHAR* AString)');
  Print(CharOpeningBrace);
  LPrintDefineLJes2Cpp;
  Print('LJes2Cpp->FProgramName = AString;');
  Print(CharClosingBrace);
  Print('BOOL WINAPI EffectDoGetProgramName(HVEST AVeST, CHAR* AString)');
  Print(CharOpeningBrace);
  LPrintDefineLJes2Cpp;
  Print('strcpy(AString, LJes2Cpp->FProgramName.c_str());');
  Print('return TRUE;');
  Print(CharClosingBrace);
  Print('BOOL WINAPI EffectDoGetProgramNameIndexed(HVEST AVeST, INT ACategory, INT AIndex, CHAR* AString)');
  Print(CharOpeningBrace);
  Print('return FALSE;');
  Print(CharClosingBrace);
  Print(SCppVoidSpace + 'WINAPI EffectDoSetParameter(HVEST AVeST, INT AIndex, FLOAT AValue)');
  Print(CharOpeningBrace);
  LPrintDefineLJes2Cpp;
  Print('AValue = LJes2Cpp->FParameters[AIndex].ToSlider(AValue);');
  Print('if (%s(AValue, LJes2Cpp->%s[LJes2Cpp->FParameters[AIndex].FIndex]))', [SFnNeq, EelToCppVar(SEelVarSlider, vtGlobal)]);
  Print(CharOpeningBrace);
  Print('LJes2Cpp->%s[LJes2Cpp->FParameters[AIndex].FIndex] = AValue;', [EelToCppVar(SEelVarSlider, vtGlobal)]);
  Print('LJes2Cpp->%s();', [SDoSlider]);
  Print(CharClosingBrace);
  Print(CharClosingBrace);
  Print('FLOAT WINAPI EffectDoGetParameter(HVEST AVeST, INT AIndex)');
  Print(CharOpeningBrace);
  LPrintDefineLJes2Cpp;
  Print('return LJes2Cpp->FParameters[AIndex].FromSlider(LJes2Cpp->%s[LJes2Cpp->FParameters[AIndex].FIndex]);',
    [EelToCppVar(SEelVarSlider, vtGlobal)]);
  Print(CharClosingBrace);
  Print(SCppVoidSpace + 'WINAPI EffectDoGetParameterName(HVEST AVeST, INT AIndex, CHAR* AString)');
  Print(CharOpeningBrace);
  LPrintDefineLJes2Cpp;
  Print('LJes2Cpp->FParameters[AIndex].GetParameterName(AString);');
  Print(CharClosingBrace);
  Print(SCppVoidSpace + 'WINAPI EffectDoGetParameterLabel(HVEST AVeST, INT AIndex, CHAR* AString)');
  Print(CharOpeningBrace);
  LPrintDefineLJes2Cpp;
  Print('LJes2Cpp->FParameters[AIndex].GetLabel(AString, LJes2Cpp->%s[LJes2Cpp->FParameters[AIndex].FIndex]);',
    [EelToCppVar(SEelVarSlider, vtGlobal)]);
  Print(CharClosingBrace);
  Print(SCppVoidSpace + 'WINAPI EffectDoGetParameterDisplay(HVEST AVeST, INT AIndex, CHAR* AString)');
  Print(CharOpeningBrace);
  LPrintDefineLJes2Cpp;
  Print('LJes2Cpp->FParameters[AIndex].GetDisplayFromSliderValue(AString, LJes2Cpp->%s[LJes2Cpp->FParameters[AIndex].FIndex]);',
    [EelToCppVar(SEelVarSlider, vtGlobal)]);
  Print(CharClosingBrace);
  LPrintProcessReplacing('EffectDoProcessReplacing', 'FLOAT');
  LPrintProcessReplacing('EffectDoProcessDoubleReplacing', 'DOUBLE');
end;

procedure CJes2CppTranspiler.PrintAudioEffectSetupCallBacks;

  procedure LPrintSetCallBack(const AName: String; const AIsRequired: Boolean = True);
  begin
    Print('AVeSTCallBacks->On%s = EffectDo%s;', [AName, AName], AIsRequired);
  end;

begin
  PrintTitle(SMsgCreateAudioEffectInstance);
  Print('void EffectSetupCallBacks(TVeSTCallBacks* AVeSTCallBacks)');
  Print(CharOpeningBrace);
  Print('memset(AVeSTCallBacks, 0, sizeof(*AVeSTCallBacks));');
  LPrintSetCallBack(SClose);
  LPrintSetCallBack(SCreate);
  LPrintSetCallBack(SDestroy);
  LPrintSetCallBack(SDraw, Description.FIsGfx);
  LPrintSetCallBack(SGetChunk);
  LPrintSetCallBack(SGetEffectName);
  LPrintSetCallBack(SGetParameter);
  LPrintSetCallBack(SGetParameterDisplay);
  LPrintSetCallBack(SGetParameterLabel);
  LPrintSetCallBack(SGetParameterName);
  LPrintSetCallBack(SGetProductString);
  LPrintSetCallBack(SGetProgramName);
  LPrintSetCallBack(SGetProgramNameIndexed);
  LPrintSetCallBack(SGetVendorString);
  LPrintSetCallBack(SGetVendorVersion);
  LPrintSetCallBack(SIdle);
  LPrintSetCallBack(SMouseDown, Description.FIsGfx);
  LPrintSetCallBack(SMouseMoved, Description.FIsGfx);
  LPrintSetCallBack(SMouseUp, Description.FIsGfx);
  LPrintSetCallBack(SOpen);
  LPrintSetCallBack(SProcessDoubleReplacing);
  LPrintSetCallBack(SProcessReplacing);
  LPrintSetCallBack(SResume);
  LPrintSetCallBack(SSetChunk);
  LPrintSetCallBack(SSetParameter);
  LPrintSetCallBack(SSetProgramName);
  LPrintSetCallBack(SSuspend);
  Print(CharClosingBrace);
end;

procedure CJes2CppTranspiler.PrintAudioEffectEntryPoint;
begin
  Print('extern "C" {');
  case FClientType of
    ctVST: begin
      PrintTitle('Define VSTPluginMain() - VST Entry Point');
      Print('HANDLE VSTPluginMain(HVEST_AUDIOMASTER AAudioMaster)');
      Print(CharOpeningBrace);
      Print('TVeSTCallBacks LVeSTCallBacks;');
      Print('EffectSetupCallBacks(&LVeSTCallBacks);');
      Print('TJes2CppEffect* LJes2Cpp = new TJes2CppEffect();');
      Print('LJes2Cpp->FVeST = VeST_Init((HVEST_DATA)LJes2Cpp, &LVeSTCallBacks, AAudioMaster, 1, LJes2Cpp->FParameters.size());');
      Print('return VeST_GetAEffect(LJes2Cpp->FVeST);');
      Print(CharClosingBrace);
    end;
    ctLADSPA: begin
      PrintTitle('Define ladspa_descriptor() - LADSPA Entry Point');
      Print('const LADSPA_Descriptor* ladspa_descriptor(unsigned long Index)');
      Print(CharOpeningBrace);
      Print('Beep(2000, 200);');
      Print('if (!Index)');
      Print(CharOpeningBrace);
      Print('TVeSTCallBacks LVeSTCallBacks;');
      Print('EffectSetupCallBacks(&LVeSTCallBacks);');
      Print('TJes2CppEffect* LJes2Cpp = new TJes2CppEffect();');
      Print('LJes2Cpp->FVeST = VeST_Init((HVEST_DATA)LJes2Cpp, &LVeSTCallBacks, NULL, 1, LJes2Cpp->FParameters.size());');
      Print('return VeST_GetLADSPA(LJes2Cpp->FVeST);');
      Print(CharClosingBrace);
      Print('return NULL;');
      Print(CharClosingBrace);
    end;
  end;
  Print(CharClosingBrace + ' // extern "C"');
end;

procedure CJes2CppTranspiler.TranspileScript(const AScript: TStrings; const AFileName, ADefVendorString, ADefEffectName, ADefProductString: String;
  const ADefVendorVersion, ADefUniqueId: Integer);
begin
  LogMessage(SMsgStarted);
  try
    Output.Clear;

    LogMessage(SMsgTypeParsing, SMsgDescription);

    ImportFrom(AScript, AFileName);

    Description.ExtractDescriptionElements(AScript, AFileName, ADefVendorString, ADefEffectName, ADefProductString, ADefVendorVersion, ADefUniqueId);

    LogMessage(Format('%s=%s %s=%s %s=%s', [SVendorString, QuotedStr(Description.VendorString), SEffectName,
      QuotedStr(Description.EffectName), SProductString, QuotedStr(Description.ProductString)]));

    LogMessage(Format(SMsgNumberOfParametersFound1, [Description.ParameterCount]));

    if not FIsNoOutput then
    begin
      PrintTitle(SMsgConvertedWith + SJes2CppTitle);
      PrintOriginalComments(Description.AtDescription);
      PrintBlankLine;
      Print('#include "jes2cpp.h"');
    end;
    PrintScriptClass(AFileName);
    if not FIsNoOutput then
    begin
      PrintAudioEffectCallBacks;
      PrintAudioEffectSetupCallBacks;
      PrintAudioEffectEntryPoint;
      PrintTitle('End of File');
    end;
  finally
    LogMessage(SMsgFinished);
    LogMessage(EmptyStr);
  end;
end;

procedure CJes2CppTranspiler.TranspileScriptFromFile(const AFileName, ADefVendorString, ADefEffectName, ADefProductString: String;
  const ADefVendorVersion, ADefUniqueId: Integer);
var
  LStrings: TStrings;
begin
  LStrings := TStringList.Create;
  try
    LStrings.LoadFromFile(AFileName);
    TranspileScript(LStrings, AFileName, ADefVendorString, ADefEffectName, ADefProductString, ADefVendorVersion, ADefUniqueId);
  finally
    FreeAndNil(LStrings);
  end;
end;

procedure Jes2CppTranspile(const AFilenameDst, AFilenameSrc: TFileName; const ADefVendorString, ADefEffectName, ADefProductString: String;
  const ADefVendorVersion, ADefUniqueId: Integer);
begin
  with CJes2CppTranspiler.Create(nil) do
  begin
    try
      TranspileScriptFromFile(AFilenameSrc, ADefVendorString, ADefEffectName, ADefProductString, ADefVendorVersion, ADefUniqueId);
      Output.SaveToFile(AFilenameDst);
    finally
      Free;
    end;
  end;
end;

end.

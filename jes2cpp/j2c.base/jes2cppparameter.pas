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

unit Jes2CppParameter;

{$MODE DELPHI}
{$MACRO ON}

interface

uses
  Classes, Jes2CppConstants, Jes2CppEel, Jes2CppParserSimple, Jes2CppTranslate, Math, Soda, StrUtils, SysUtils, Types;

type

  CJes2CppParameters = class;

  CJes2CppParameter = class
    {$DEFINE DItemClass := CJes2CppParameter}
    {$DEFINE DItemSuper := CComponent}
    {$DEFINE DItemOwner := CJes2CppParameters}
    {$INCLUDE soda.inc}
  strict private
    FIsFileSelection: Boolean;
    FSlider: Integer;
    FVariable, FLabel, FDataType: String;
    FFilePath, FFileName: TFileName;
    FDefValue, FMinValue, FMaxValue, FStepValue: Extended;
    FOptions: TStringDynArray;
  strict private
    procedure AddOption(const AOption: String);
    procedure ExpectEmptyStr(const AString: String);
  public
    procedure DecodeEel(const ASlider: Integer; const ASource: String);
    function EncodeCpp: String;
    function IsHidden: Boolean;
  end;

  CJes2CppParameters = class
    {$DEFINE DItemClass := CJes2CppParameters}
    {$DEFINE DItemSuper := CComponent}
    {$DEFINE DItemItems := CJes2CppParameter}
    {$INCLUDE soda.inc}
  end;

implementation

{$DEFINE DItemClass := CJes2CppParameter} {$INCLUDE soda.inc}

{$DEFINE DItemClass := CJes2CppParameters} {$INCLUDE soda.inc}

const

  CharSetSliderTypes = ['<', CharComma, CharColon, CharEqualSign];

var

  GDataTypes: array[0..5] of String = ('%', 's', 'ms', 'hz', 'db', 'deg');


type
  TEaterEx = object(TJes2CppParserSimple)
    procedure ParseUntilDef(out AResult: Extended; const ACharSet: TSysCharSet; const ADefault: Extended);
  end;


procedure TEaterEx.ParseUntilDef(out AResult: Extended; const ACharSet: TSysCharSet; const ADefault: Extended);
begin
  GetUntil(ACharSet);
  if FToken = EmptyStr then
  begin
    AResult := ADefault;
  end else begin
    AResult := EelStrToFloat(FToken);
  end;
end;

function CJes2CppParameter.IsHidden: Boolean;
begin
  Result := AnsiStartsStr(CharMinusSign, FLabel);
end;

procedure CJes2CppParameter.ExpectEmptyStr(const AString: String);
begin
  if AString <> EmptyStr then
  begin
    raise Exception.CreateFmt('Found unexpected data. ''%s''.', [AString]);
  end;
end;

procedure CJes2CppParameter.AddOption(const AOption: String);
begin
  SetLength(FOptions, Length(FOptions) + 1);
  FOptions[High(FOptions)] := AOption;
end;

procedure CJes2CppParameter.DecodeEel(const ASlider: Integer; const ASource: String);
var
  LEater: TEaterEx;
  LPos: Integer;
  LDataType: String;
begin
  FIsFileSelection := False;
  FSlider := ASlider;
  FDefValue := 0;
  FMinValue := 0;
  FMaxValue := 1;
  FStepValue := GfEelEpsilon;
  FVariable := EmptyStr;
  FLabel := EmptyStr;
  FDataType := EmptyStr;
  SetLength(FOptions, 0);

  LEater.SetSource(ASource);

  if not InRange(FSlider, Low(TEelSliderIndex), High(TEelSliderIndex)) then
  begin
    raise Exception.Create('Index out of range.');
  end;
  LEater.GetUntil(CharSetSliderTypes);
  if LEater.Terminator = CharEqualSign then
  begin
    FVariable := LEater.AsName + CharDot;
    LEater.GetUntil(CharSetSliderTypes);
  end;
  case LEater.Terminator of
    CharComma: begin
      FDefValue := EelStrToFloat(LEater.AsString);
      LEater.GetUntil([CharNull]);
      FLabel := LEater.AsName;
    end;
    CharColon: begin
      FFilePath := LEater.AsFileName;
      LEater.GetUntil([CharColon]);
      FFileName := LEater.AsFileName;
      LEater.GetUntil([CharNull]);
      FLabel := LEater.AsName;
      FIsFileSelection := True;
      FFilePath := SetDirSeparators(ExcludeLeadingPathDelimiter(IncludeTrailingPathDelimiter(FFilePath)));
    end;
    '<': begin
      if LEater.AsString = EmptyStr then
      begin
        FDefValue := M_ZERO;
      end else begin
        FDefValue := EelStrToFloat(LEater.AsString);
      end;
      LEater.ParseUntilDef(FMinValue, [CharComma, '>'], 0);
      if LEater.Terminator = CharComma then
      begin
        LEater.ParseUntilDef(FMaxValue, [CharComma, '>'], 0);
        if LEater.Terminator = CharComma then
        begin
          LEater.ParseUntilDef(FStepValue, [CharComma, '>', CharOpeningBrace], GfEelEpsilon);
          if LEater.Terminator in [CharComma, CharOpeningBrace] then
          begin
            if LEater.Terminator <> CharOpeningBrace then
            begin
              LEater.GetUntil([CharOpeningBrace]);
              ExpectEmptyStr(LEater.AsString);
            end;
            repeat
              LEater.GetUntil([CharComma, CharClosingBrace]);
              if LEater.Terminator in [CharComma, CharClosingBrace] then
              begin
                AddOption(LEater.AsString('Option'));
              end;
            until not (LEater.Terminator in [CharComma]);
            LEater.GetUntil(['>']);
            ExpectEmptyStr(LEater.AsString);
            FMinValue := 0;
            FMaxValue := Length(FOptions) - 1;
            FStepValue := 1;
          end;
        end;
      end;
      LEater.GetUntil([CharNull]);
      FLabel := LEater.AsName;
    end;
  end;
  for LDataType in GDataTypes do
  begin
    LPos := Pos(CharOpeningParenthesis + LDataType + CharClosingParenthesis, LowerCase(FLabel));
    if LPos > 0 then
    begin
      FDataType := Copy(FLabel, LPos + 1, Length(LDataType));
      Delete(FLabel, LPos, Length(LDataType) + 2);
      Break;
    end;
  end;
  // TODO: Replace with a normalize spaces function?
  FLabel := Trim(ReplaceStr(FLabel, CharSpace + CharSpace, CharSpace));
  if FStepValue = 0 then
  begin
    FStepValue := GfEelEpsilon;
  end;
end;

function CJes2CppParameter.EncodeCpp: String;
var
  LString: String;
begin
  LString := FLabel;
  if AnsiStartsStr(CharMinusSign, LString) then
  begin
    LString := Copy(LString, 2, MaxInt);
  end;
  Result := Format('AddParam(%d, %s, %s, %s, %s, %s, %s, %s, %s, %s);', [FSlider, IfThen(FVariable <>
    EmptyStr, CharAmpersand + CppEncodeVariable(FVariable), GsCppNullPtr), CppEncodeFloat(FDefValue),
    CppEncodeFloat(FMinValue), CppEncodeFloat(FMaxValue), CppEncodeFloat(FStepValue), CppEncodeString(FFilePath),
    CppEncodeString(FFileName), CppEncodeString(FDataType), CppEncodeString(LString)]) + LineEnding;

  for LString in FOptions do
  begin
    Result += Format('FParameters[FParameters.size() - 1].AddOption(%s);', [CppEncodeString(LString)]) + LineEnding;
  end;
end;

end.

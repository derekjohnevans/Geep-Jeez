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

interface

uses
  Jes2CppConstants, Jes2CppEat, Jes2CppEel, Jes2CppTranslate, Math, StrUtils, SysUtils, Types;

type

  TJes2CppParameter = object
  strict private
    FIsFileSelection: Boolean;
    FSlider: TEelSliderIndex;
    FVariable, FLabel, FName: String;
    FFilePath, FFileName: TFileName;
    FDefValue, FMinValue, FMaxValue, FStepValue: Extended;
    FOptions: TStringDynArray;
  strict private
    procedure AddOption(const AOption: String);
    procedure Clear;
  public
    function EelDecode(const AString: String): Boolean;
    function CppEncode: String;
    function IsHidden: Boolean;
  public
    property Slider: TEelSliderIndex read FSlider;
    property DefValue: Extended read FDefValue;
    property MinValue: Extended read FMinValue;
    property MaxValue: Extended read FMaxValue;
    property StepValue: Extended read FStepValue;
  end;

  TJes2CppParameterDynArray = array of TJes2CppParameter;

implementation

const

  CharSetSliderTypes = ['<', ',', ':', '='];

var

  GPossibleLabels: array[0..5] of String = ('%', 's', 'ms', 'hz', 'db', 'deg');

procedure TJes2CppParameter.Clear;
begin
  FIsFileSelection := False;
  FSlider := 1;
  FDefValue := 0;
  FMinValue := 0;
  FMaxValue := 1;
  FStepValue := GfEelEpsilon;
  FVariable := EmptyStr;
  FName := EmptyStr;
  FLabel := EmptyStr;
  SetLength(FOptions, 0);
end;

function TJes2CppParameter.IsHidden: Boolean;
begin
  Result := AnsiStartsStr(CharMinusSign, FName);
end;

procedure TJes2CppParameter.AddOption(const AOption: String);
begin
  SetLength(FOptions, Length(FOptions) + 1);
  FOptions[High(FOptions)] := AOption;
end;

function TJes2CppParameter.EelDecode(const AString: String): Boolean;
var
  LPos, LSliderIndex: Integer;
  LToken: String;
  LTerm: Char;
begin
  LSliderIndex := 0;
  LPos := 1;
  Clear;
  Result := False;

  // TODO: Use EEL untils here?
  if (EatUntil(AString, LPos, LToken, [':']) <> CharNull) and AnsiStartsText(GsEelPreVarSlider, LToken) and
    TryStrToInt(Copy(LToken, Length(GsEelPreVarSlider) + 1, MaxInt), LSliderIndex) and InRange(LSliderIndex,
    Low(TEelSliderIndex), High(TEelSliderIndex)) then
  begin
    LTerm := EatUntil(AString, LPos, LToken, CharSetSliderTypes);
    if LTerm = '=' then
    begin
      FVariable := LToken + CharDot;
      LTerm := EatUntil(AString, LPos, LToken, CharSetSliderTypes);
    end;
    case LTerm of
      ',': begin
        FDefValue := StrToInt(LToken);
        Result := EatUntil(AString, LPos, FName, [CharNull]) = CharNull;
      end;
      ':': begin
        FFilePath := LToken;
        Result := (EatUntil(AString, LPos, FFileName, [':']) = ':') and (EatUntil(AString, LPos, FName, [CharNull]) = CharNull);
        if Result then
        begin
          FIsFileSelection := True;
          FFilePath := SetDirSeparators(ExcludeLeadingPathDelimiter(IncludeTrailingPathDelimiter(FFilePath)));
        end;
      end;
      '<': begin
        FDefValue := EelStrToFloat(LToken);
        case EatUntil(AString, LPos, FMinValue, [',', '>'], 0) of
          '>': begin
            Result := EatUntil(AString, LPos, FName, [CharNull]) = CharNull;
          end;
          ',': begin
            case EatUntil(AString, LPos, FMaxValue, [',', '>'], 0) of
              '>': begin
                Result := EatUntil(AString, LPos, FName, [CharNull]) = CharNull;
              end;
              ',': begin
                case EatUntil(AString, LPos, FStepValue, ['>', '{'], GfEelEpsilon) of
                  '>': begin
                    Result := EatUntil(AString, LPos, FName, [CharNull]) = CharNull;
                  end;
                  '{': begin
                    repeat
                      LTerm := EatUntil(AString, LPos, LToken, [',', '}']);
                      if LTerm in [',', '}'] then
                      begin
                        AddOption(LToken);
                      end;
                    until not (LTerm in [',']);
                    Result := (EatUntil(AString, LPos, LToken, ['>']) <> CharNull) and
                      (EatUntil(AString, LPos, FName, [CharNull]) = CharNull);
                    if Result then
                    begin
                      // Reaper ignors the min and max values when there are FOptions, so,
                      // lets override them here to the correct values.
                      FMinValue := 0;
                      FMaxValue := Length(FOptions) - 1;
                      FStepValue := 1;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
      end else begin
        raise Exception.Create('Bad slider');
      end;
    end;
  end;
  if Result then
  begin
    for LToken in GPossibleLabels do
    begin
      LPos := Pos('(' + LToken + ')', LowerCase(FName));
      if LPos > 0 then
      begin
        FLabel := Copy(FName, LPos + 1, Length(LToken));
        Delete(FName, LPos, Length(LToken) + 2);
        Break;
      end;
    end;
    FName := Trim(ReplaceStr(FName, '  ', ' '));
    if FStepValue = 0 then
    begin
      FStepValue := GfEelEpsilon;
    end;
    FSlider := LSliderIndex;
  end;
end;

function TJes2CppParameter.CppEncode: String;
var
  LIndex: Integer;
  LName: String;
begin
  LName := FName;
  if AnsiStartsStr('-', LName) then
  begin
    LName := Copy(LName, 2, MaxInt);
  end;
  Result := Format('AddParam(%d, %s, %s, %s, %s, %s, %s, %s, %s, %s);', [FSlider, IfThen(FVariable <>
    EmptyStr, '&' + CppEncodeVariable(FVariable), GsCppNull), CppEncodeFloat(FDefValue), CppEncodeFloat(FMinValue),
    CppEncodeFloat(FMaxValue), CppEncodeFloat(FStepValue), CppEncodeString(FFilePath), CppEncodeString(FFileName),
    CppEncodeString(FLabel), CppEncodeString(LName)]) + LineEnding;

  for LIndex := Low(FOptions) to High(FOptions) do
  begin
    Result += Format('FParameters[FParameters.size() - 1].FOptions.push_back(%s);', [CppEncodeString(FOptions[LIndex])]) + LineEnding;
  end;
end;

end.

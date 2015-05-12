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
  Jes2CppEat, Jes2CppEel, Jes2CppTranslate, Math, StrUtils, SysUtils, Types;

type

  TJes2CppParameter = object
  strict private
    FIsFileSelection: Boolean;
    FSliderIndex: TEelSliderIndex;
    FLabel, FText: String;
    FFilePath, FFileName: TFileName;
    FDefValue, FMinValue, FMaxValue, FStepValue: Extended;
    FOptions: TStringDynArray;
  public
    procedure Clear;
    function FromString(const AString: String): Boolean;
    function CppInitSliders: String;
    function CppAddParameters: String;
    procedure AddOption(const AOption: String);
  public
    property Text: String read FText;
  end;

  TJes2CppParameterDynArray = array of TJes2CppParameter;

implementation

var

  GPossibleLabels: array[0..5] of String = ('%', 's', 'ms', 'hz', 'db', 'deg');

procedure TJes2CppParameter.Clear;
begin
  FIsFileSelection := False;
  FSliderIndex := 1;
  FDefValue := 0;
  FMinValue := 0;
  FMaxValue := 1;
  FStepValue := EelEpsilon;
  FText := EmptyStr;
  FLabel := EmptyStr;
  SetLength(FOptions, 0);
end;

procedure TJes2CppParameter.AddOption(const AOption: String);
begin
  SetLength(FOptions, Length(FOptions) + 1);
  FOptions[High(FOptions)] := AOption;
end;

function TJes2CppParameter.FromString(const AString: String): Boolean;
var
  LPos, LSliderIndex: Integer;
  LToken: String;
  LTerm: Char;
begin
  LSliderIndex := 0;
  LPos := 1;
  Clear;
  Result := False;

  if (Eat(AString, LPos, LToken, [':']) <> #0) and AnsiStartsText(SEelPreVarSlider, LToken) and
    TryStrToInt(Copy(LToken, Length(SEelPreVarSlider) + 1, MaxInt), LSliderIndex) and InRange(LSliderIndex,
    Low(TEelSliderIndex), High(TEelSliderIndex)) then
  begin
    case Eat(AString, LPos, FDefValue, ['<', ','], 0) of
      ',': begin
        // TODO: Feedback Sliders (How todo them?)
        Result := Eat(AString, LPos, FText, [#0]) = #0;
      end;
      '<': begin
        case Eat(AString, LPos, FMinValue, [',', '>'], 0) of
          '>': begin
            Result := Eat(AString, LPos, FText, [#0]) = #0;
          end;
          ',': begin
            case Eat(AString, LPos, FMaxValue, [',', '>'], 0) of
              '>': begin
                Result := Eat(AString, LPos, FText, [#0]) = #0;
              end;
              ',': begin
                case Eat(AString, LPos, FStepValue, ['>', '{'], EelEpsilon) of
                  '>': begin
                    Result := Eat(AString, LPos, FText, [#0]) = #0;
                  end;
                  '{': begin
                    repeat
                      LTerm := Eat(AString, LPos, LToken, [',', '}']);
                      if LTerm in [',', '}'] then
                      begin
                        AddOption(LToken);
                      end;
                    until not (LTerm in [',']);
                    Result := (Eat(AString, LPos, LToken, ['>']) <> #0) and (Eat(AString, LPos, FText, [#0]) = #0);
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
        Result := (Eat(AString, LPos, FFilePath, [':']) = ':') and (Eat(AString, LPos, FFileName, [':']) = ':') and
          (Eat(AString, LPos, FText, [#0]) = #0);
        if Result then
        begin
          FIsFileSelection := True;
          FFilePath := SetDirSeparators(ExcludeLeadingPathDelimiter(IncludeTrailingPathDelimiter(FFilePath)));
        end;
      end;
    end;
  end;
  if Result then
  begin
    for LToken in GPossibleLabels do
    begin
      LPos := Pos('(' + LToken + ')', LowerCase(FText));
      if LPos > 0 then
      begin
        FLabel := Copy(FText, LPos + 1, Length(LToken));
        Delete(FText, LPos, Length(LToken) + 2);
        Break;
      end;
    end;
    FText := Trim(ReplaceStr(FText, '  ', ' '));
    if FStepValue = 0 then
    begin
      FStepValue := EelEpsilon;
    end;
    FSliderIndex := LSliderIndex;
  end;
end;

function TJes2CppParameter.CppInitSliders: String;
begin
  Result := Format('%s[%d] = %s;', [EelToCppVar(SEelVarSlider, vtGlobal), FSliderIndex, EelToCppFloat(FDefValue)]) +
    LineEnding;
end;

function TJes2CppParameter.CppAddParameters: String;
var
  LIndex: Integer;
  LText: String;
begin
  LText := FText;
  if AnsiStartsStr('-', LText) then
  begin
    LText := Copy(LText, 2, MaxInt);
  end;
  Result := Format('AddParam(%d, %s, %s, %s, %s, %s, %s, %s, %s);', [FSliderIndex, EelToCppFloat(FDefValue),
    EelToCppFloat(FMinValue), EelToCppFloat(FMaxValue), EelToCppFloat(FStepValue), CppString(FFilePath),
    CppString(FFileName), CppString(FLabel), CppString(LText)]) + LineEnding;
  for LIndex := Low(FOptions) to High(FOptions) do
  begin
    Result += Format('FParameters[FParameters.size() - 1].FOptions.push_back(%s);', [CppString(FOptions[LIndex])]) + LineEnding;
  end;
end;

end.

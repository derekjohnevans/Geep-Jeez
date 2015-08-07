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
  Classes, Jes2CppConstants, Jes2CppEel, Jes2CppParserSimple, Jes2CppTranslate,
  Math, Soda, StrUtils, SysUtils, Types;

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

  CharSetSliderTypes = [CharLessThan, CharComma, CharColon, CharEqualSign];

var

  GLabels: array[0..9] of String = ('%', 'bar', 'beat', 'db', 'deg', 'hz', 'khz', 's', 'sr', 'ms');

type

  TJes2CppParserSimple2 = object(TJes2CppParserSimple)
    procedure ParseUntilDef(out AResult: Extended; const ACharSet: TSysCharSet;
      const ADefault: Extended);
  end;

procedure TJes2CppParserSimple2.ParseUntilDef(out AResult: Extended;
  const ACharSet: TSysCharSet; const ADefault: Extended);
begin
  GetUntil(ACharSet);
  if FToken = EmptyStr then
  begin
    AResult := ADefault;
  end else begin
    AResult := GEel.ToFloat(FToken);
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

var
  // TODO: This must be global, otherwise, we get memory leakage. Unsure why. It seems to happen
  // with inherited objects with strings.
  GParserSimple: TJes2CppParserSimple2;

procedure CJes2CppParameter.DecodeEel(const ASlider: Integer; const ASource: String);
var
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

  GParserSimple.SetSource(ASource);

  if not InRange(FSlider, Low(TEelSliderIndex), High(TEelSliderIndex)) then
  begin
    raise Exception.Create('Index out of range.');
  end;
  GParserSimple.GetUntil(CharSetSliderTypes);
  if GParserSimple.Terminator = CharEqualSign then
  begin
    FVariable := GParserSimple.AsName + CharDot;
    GParserSimple.GetUntil(CharSetSliderTypes);
  end;
  case GParserSimple.Terminator of
    CharComma: begin
      FDefValue := GEel.ToFloat(GParserSimple.AsString);
      GParserSimple.GetUntil([CharNull]);
      FLabel := GParserSimple.AsName;
    end;
    CharColon: begin
      FFilePath := GParserSimple.AsFileName;
      GParserSimple.GetUntil([CharColon]);
      FFileName := GParserSimple.AsFileName;
      GParserSimple.GetUntil([CharNull]);
      FLabel := GParserSimple.AsName;
      FIsFileSelection := True;
      FFilePath := SetDirSeparators(ExcludeLeadingPathDelimiter(
        IncludeTrailingPathDelimiter(FFilePath)));
    end;
    CharLessThan: begin
      if GParserSimple.AsString = EmptyStr then
      begin
        FDefValue := ZeroValue;
      end else begin
        FDefValue := GEel.ToFloat(GParserSimple.AsString);
      end;
      GParserSimple.ParseUntilDef(FMinValue, [CharComma, CharGreaterThan], 0);
      if GParserSimple.Terminator = CharComma then
      begin
        GParserSimple.ParseUntilDef(FMaxValue, [CharComma, CharGreaterThan], 0);
        if GParserSimple.Terminator = CharComma then
        begin
          GParserSimple.ParseUntilDef(FStepValue, [CharComma, CharGreaterThan, CharOpeningBrace],
            GfEelEpsilon);
          if GParserSimple.Terminator in [CharComma, CharOpeningBrace] then
          begin
            if GParserSimple.Terminator <> CharOpeningBrace then
            begin
              GParserSimple.GetUntil([CharOpeningBrace]);
              ExpectEmptyStr(GParserSimple.AsString);
            end;
            repeat
              GParserSimple.GetUntil([CharComma, CharClosingBrace]);
              if GParserSimple.Terminator in [CharComma, CharClosingBrace] then
              begin
                AddOption(GParserSimple.AsString('Option'));
              end;
            until not (GParserSimple.Terminator in [CharComma]);
            GParserSimple.GetUntil([CharGreaterThan]);
            ExpectEmptyStr(GParserSimple.AsString);
            FMinValue := 0;
            FMaxValue := Length(FOptions) - 1;
            FStepValue := 1;
          end;
        end;
      end;
      GParserSimple.GetUntil([CharNull]);
      FLabel := GParserSimple.AsName;
    end;
  end;
  for LDataType in GLabels do
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
  Result := Format('AddParam(%d, %s, %s, %s, %s, %s, %s, %s, %s, %s);',
    [FSlider, IfThen(FVariable <> EmptyStr, CharAmpersand + GCpp.Encode.NameVariable(FVariable),
    GsCppNullPtr), GCpp.Encode.Float(FDefValue), GCpp.Encode.Float(FMinValue),
    GCpp.Encode.Float(FMaxValue), GCpp.Encode.Float(FStepValue),
    GCpp.Encode.QuotedString(FFilePath), GCpp.Encode.QuotedString(FFileName),
    GCpp.Encode.QuotedString(FDataType), GCpp.Encode.QuotedString(LString)]) + LineEnding;

  for LString in FOptions do
  begin
    Result += Format('FParameters[FParameters.size() - 1].AddOption(%s);',
      [GCpp.Encode.QuotedString(LString)]) + LineEnding;
  end;
end;

end.

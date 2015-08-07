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

unit Jes2CppStrings;

{$MODE DELPHI}

interface

uses
  Classes, DateUtils, Jes2CppConstants, Jes2CppEel, Jes2CppFileNames, Math, StrUtils, SysUtils;

type

  TArrayOfString = object
  public
    Items: array of String;
  public
    function Count: Integer;
    procedure Append(const AIdent: String);
  end;

type
  GString = object
  private
    class function EncodeNameValue(AName, AValue: String): String;
  public
    class function SplitterLine(const ALength: Integer = GiColWidth): String;
    class function IsEmpty(const AString: String): Boolean;
    class function IsSpace(const AString: String): Boolean;
    class procedure AppendCSV(var AString: String; const AValue: String);
    class function DecodeNameValue(AString: String; out AName, AValue: String): Boolean;
    class function Split(const AString: String; const ACharSet: TSysCharSet;
      out ALeft, ARight: String): Boolean;
  end;


  GStrings = object
    class function GetValue(const AStrings: TStrings; const AName, ADefault: String;
      const ADecodeMeta: Boolean = False): String;
    class function DescIndexOfName(const AStrings: TStrings; const AName: String): Integer;
    class procedure AddComment(const AStrings: TStrings; const AString: String);
    class procedure AddCommentLine(const AStrings: TStrings);
    class procedure AddCommentTitle(const AStrings: TStrings; const AString: String);
    class procedure SetValue(const AStrings: TStrings; const AName, AValue: String);
    class procedure Trim(const AStrings: TStrings);
    class procedure CreateUntitled(const AStrings: TStrings);
  end;

implementation

uses Jes2CppTranslate;

function TArrayOfString.Count: Integer;
begin
  Result := Length(Items);
end;

procedure TArrayOfString.Append(const AIdent: String);
begin
  SetLength(Items, Length(Items) + 1);
  Items[High(Items)] := AIdent;
end;

class function GString.IsEmpty(const AString: String): Boolean;
begin
  Result := Length(AString) = ZeroValue;
end;

class function GString.IsSpace(const AString: String): Boolean;
var
  LIndex: Integer;
begin
  for LIndex := 1 to Length(AString) do
  begin
    if AString[LIndex] <> CharSpace then
    begin
      Exit(False);
    end;
  end;
  Result := True;
end;

class procedure GString.AppendCSV(var AString: String; const AValue: String);
begin
  if not IsSpace(AString) then
  begin
    AString += GsCppCommaSpace;
  end;
  AString += AValue;
end;

class function GString.Split(const AString: String; const ACharSet: TSysCharSet;
  out ALeft, ARight: String): Boolean;
var
  LPos: Integer;
begin
  LPos := PosSet(ACharSet, AString);
  Result := LPos > ZeroValue;
  if Result then
  begin
    ARight := AString;
    ALeft := Trim(Copy(ARight, 1, LPos - 1));
    ARight := Trim(Copy(ARight, LPos + 1, MaxInt));
  end;
end;

class function GString.EncodeNameValue(AName, AValue: String): String;
begin
  if SameText(AName, GsProductString) then
  begin
    AName := GsEelDescDesc;
  end;
  Result := Trim(AName) + CharColon + CharSpace + Trim(AValue);
end;

class function GString.DecodeNameValue(AString: String; out AName, AValue: String): Boolean;
begin
  AString := Trim(AString);
  Result := Split(AString, [CharColon, CharEqualSign], AName, AValue);
  if Result then
  begin
    if SameText(AName, GsEelDescDesc) then
    begin
      AName := GsProductString;
    end else if SameText(AName, GsVstPath) then
    begin
      AName := GsInstallPath;
    end;
  end;
end;

class function GStrings.DescIndexOfName(const AStrings: TStrings; const AName: String): Integer;
var
  LName, LValue: String;
begin
  for Result := ZeroValue to GEel.DescHigh(AStrings) do
  begin
    if GString.DecodeNameValue(AStrings[Result], LName, LValue) and SameText(LName, AName) then
    begin
      Exit;
    end;
  end;
  Result := -1;
end;

class function GStrings.GetValue(const AStrings: TStrings; const AName, ADefault: String;
  const ADecodeMeta: Boolean): String;
var
  LIndex: Integer;
  LName, LValue: String;
begin
  Result := ADefault;
  for LIndex := ZeroValue to GEel.DescHigh(AStrings) do
  begin
    if GString.DecodeNameValue(AStrings[LIndex], LName, LValue) and
      SameText(LName, AName) and (Length(LValue) > 0) then
    begin
      Result := LValue;
      Break;
    end;
  end;
  if ADecodeMeta then
  begin
    Result := GFileName.DecodeMeta(Result);
  end;
end;

class procedure GStrings.SetValue(const AStrings: TStrings; const AName, AValue: String);
var
  LIndex: Integer;
  LName, LValue: String;
begin
  for LIndex := ZeroValue to GEel.DescHigh(AStrings) do
  begin
    if GString.DecodeNameValue(AStrings[LIndex], LName, LValue) and SameText(LName, AName) then
    begin
      AStrings[LIndex] := GString.EncodeNameValue(AName, AValue);
      Exit;
    end;
  end;
  // TODO: Find a better place to insert new values.
  AStrings.Insert(LIndex + 1, GString.EncodeNameValue(AName, AValue));
end;

class procedure GStrings.AddComment(const AStrings: TStrings; const AString: String);
var
  LIndex: Integer;
begin
  with TStringList.Create do
  begin
    try
      Text := WrapText(AString, GiColWidth);
      for LIndex := ZeroValue to Count - 1 do
      begin
        AStrings.Add(GsCppCommentSpace + Strings[LIndex]);
      end;
    finally
      Free;
    end;
  end;
end;

class function GString.SplitterLine(const ALength: Integer): String;
begin
  Result := StringOfChar(CharEqualSign, ALength);
end;

class procedure GStrings.AddCommentLine(const AStrings: TStrings);
begin
  AddComment(AStrings, GString.SplitterLine);
end;

class procedure GStrings.AddCommentTitle(const AStrings: TStrings; const AString: String);
begin
  AddCommentLine(AStrings);
  AddComment(AStrings, AString);
  AddCommentLine(AStrings);
end;

class procedure GStrings.Trim(const AStrings: TStrings);
begin
  while (AStrings.Count > ZeroValue) and GString.IsSpace(AStrings[AStrings.Count - 1]) do
  begin
    AStrings.Delete(AStrings.Count - 1);
  end;
  while (AStrings.Count > ZeroValue) and GString.IsSpace(AStrings[ZeroValue]) do
  begin
    AStrings.Delete(ZeroValue);
  end;
end;

class procedure GStrings.CreateUntitled(const AStrings: TStrings);
begin
  with AStrings do
  begin
    Clear;
    AddCommentLine(AStrings);
    AddComment(AStrings, 'Name:');
    AddComment(AStrings, 'Website:');
    AddComment(AStrings, 'Created: ' + FormatDateTime(FormatSettings.LongDateFormat, Now));
    AddComment(AStrings, Format('Copyright %d (C) (Enter Your Name) <your@email.com>',
      [YearOf(Now)]));
    AddCommentLine(AStrings);
    Add(EmptyStr);

    AddComment(AStrings, 'Desc should be a one line description of your effect.');
    Add('desc: New Jesusonic Effect');
    Add(EmptyStr);

    AddComment(AStrings,
      'The following properties are used for plugin DLL generation. If a property doesnt exist (or is blank), then the default "tools->options" properties are used.');
    Add(EmptyStr);

    AddComment(AStrings, 'EffectName should be ~10-20 chars and simply describe your effect.');
    Add(GsEffectName + ': Enter Effect Name');
    Add(EmptyStr);

    AddComment(AStrings, GsVendorString +
      ' should be ~10-20 chars and common to all your effects. It is shown in brackets after the EffectName. eg: BeatBox (mda)');
    Add(GsVendorString + ': Vendor');
    Add(EmptyStr);

    AddComment(AStrings, GsVendorVersion + ' is a 32bit integer.');
    Add(GsVendorVersion + ': 1000');
    Add(EmptyStr);

    AddComment(AStrings, GsUniqueId +
      ' is a 32bit integer and should be registered with Steinberg if you are releasing a global plugin. It is used to resolve plugin name clashes.');
    Add(GsUniqueId + ': 1234');
    Add(EmptyStr);

    AddComment(AStrings, GsInstallPath +
      ' is the location in which the plugin DLL will be installed. Note: On most systems, the plugin path will require admin privileges, so you may have to place plugin''s in a non-admin folder.');
    Add(GsInstallPath + ': %PROGRAMFILES%\VST\');
    Add(EmptyStr);

    Add(GEelSectionHeader.Make(GsEelSectionInit));
    AddComment(AStrings, '@init is called each time the effect is resumed. ie: Start of play.');
    AddComment(AStrings, 'Constants');
    Add('cDenorm = 10^-30;');
    Add('cAmpDB = 8.65617025;');
    Add(EmptyStr);
    Add(GEelSectionHeader.Make(GsEelSectionBlock));
    AddComment(AStrings,
      '@block is called every N samples, where N is set by your audio card. This setting is often called "latency".');
    Add(EmptyStr);

    Add(GEelSectionHeader.Make(GsEelSectionSample));
    AddComment(AStrings, '@sample is called for each audio sample.');
    AddComment(AStrings, 'Simple M/S Code');
    Add('mid = (spl0 + spl1) * 0.5;');
    Add('sid = (spl0 - spl1) * 0.5;');
    Add('spl0 = mid;');
    Add('spl1 = sid;');
    Add(EmptyStr);

    Add(GEelSectionHeader.Make(GsEelSectionGfx) + ' 320 240');
    AddComment(AStrings,
      'NOTE: Sliders must be hidden before graphics are enabled. Review the SWIPE GUI demos to see how this is done.');
    Add(EmptyStr);

    Add(GEelSectionHeader.Make(GsEelSectionSerialize));
    AddComment(AStrings,
      '@serialize is called when effect settings need to be stored & restored. ' +
      'NOTE: @serialize has just been implemented, so please contact myself if you find a bug. ' +
      'You can also use the default slider serialization to store/restore effect settings.');
    Add(EmptyStr);
  end;
end;

end.

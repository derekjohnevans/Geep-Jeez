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

unit Jes2CppParserSimple;

{$MODE DELPHI}

interface

uses
  Math, SysUtils;

type

  TJes2CppParserSimple = object
  protected
    FPos: Integer;
    FSource, FToken: String;
    FTerminator: Char;
  private
    procedure RaiseExpected(const ATrue: Boolean; const AString: String);
  public
    procedure SetSource(const ASource: String; const APos: Integer = 1);
    function TryUntil(const ATerminators: TSysCharSet): Boolean;
    procedure GetUntil(const ATerminators: TSysCharSet);
  public
    function AsString: String; overload;
    function AsString(const AExpected: String): String; overload;
    function AsName: String;
    function AsInteger: Integer; overload;
    function AsInteger(const AMin, AMax: Integer): Integer; overload;
    function AsFileName: TFileName;
  public
    property Terminator: Char read FTerminator;
  end;

implementation

uses Jes2CppConstants, Jes2CppTranslate;

procedure TJes2CppParserSimple.SetSource(const ASource: String; const APos: Integer);
begin
  FPos := APos;
  // TODO: Should we really be adding a null here?
  // Removing it requires code to be added below to handle NULL terminators.
  FSource := ASource + CharNull;
  FToken := EmptyStr;
  FTerminator := CharNull;
end;

function TJes2CppParserSimple.TryUntil(const ATerminators: TSysCharSet): Boolean;
var
  LEnd: Integer;
begin
  Result := False;
  for LEnd := FPos to Length(FSource) do
  begin
    if FSource[LEnd] in ATerminators then
    begin
      Result := True;
      FTerminator := FSource[LEnd];
      FToken := Trim(Copy(FSource, FPos, LEnd - FPos));
      FPos := LEnd + 1;
      Break;
    end;
  end;
end;

procedure TJes2CppParserSimple.GetUntil(const ATerminators: TSysCharSet);
var
  LChar: Char;
  LString: String;
begin
  if not TryUntil(ATerminators) then
  begin
    LString := EmptyStr;
    for LChar in ATerminators do
    begin
      if LString <> EmptyStr then
      begin
        LString += GsCppCommaSpace;
      end;
      if LChar in [#32..#126] then
      begin
        LString += CharQuoteSingle + LChar + CharQuoteSingle;
      end else begin
        LString += CharHash + IntToStr(Ord(LChar));
      end;
    end;
    RaiseExpected(False, '[' + LString + ']');
  end;
end;

procedure TJes2CppParserSimple.RaiseExpected(const ATrue: Boolean; const AString: String);
begin
  if not ATrue then
  begin
    raise Exception.Create('Expected ' + AString + '.');
  end;
end;

function TJes2CppParserSimple.AsString: String;
begin
  Result := FToken;
end;

function TJes2CppParserSimple.AsInteger: Integer;
begin
  Result := StrToInt(FToken);
end;

function TJes2CppParserSimple.AsInteger(const AMin, AMax: Integer): Integer;
begin
  Result := AsInteger;
  RaiseExpected(InRange(Result, AMin, AMax), Format('Integer %d to %d', [AMin, AMax]));
end;

function TJes2CppParserSimple.AsString(const AExpected: String): String;
begin
  RaiseExpected(FToken <> EmptyStr, AExpected);
  Result := FToken;
end;

function TJes2CppParserSimple.AsName: String;
begin
  Result := AsString('Name');
end;

function TJes2CppParserSimple.AsFileName: TFileName;
begin
  Result := AsString('Filename');
end;

end.

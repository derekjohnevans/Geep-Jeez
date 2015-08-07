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

unit Jes2CppSections;

{$MODE DELPHI}

interface

uses
  Classes, Jes2CppEel, Jes2CppUtils, Soda, StrUtils, SysUtils;

type

  CJes2CppSections = class(CComponent)
  strict private
    FAtInit, FAtSlider, FAtBlock, FAtSample, FAtGfx, FAtSerialize: String;
    FGfxWidth, FGfxHeight: Integer;
    FGfxEnabled: Boolean;
  protected
    procedure DoCreate; override;
  public
    procedure ImportFromScript(const AScript: TStrings; const AFileName: TFileName); overload;
  public
    property AtBlock: String read FAtBlock;
    property AtGfx: String read FAtGfx;
    property AtInit: String read FAtInit;
    property AtSample: String read FAtSample;
    property AtSerialize: String read FAtSerialize;
    property AtSlider: String read FAtSlider;
    property GfxEnabled: Boolean read FGfxEnabled write FGfxEnabled;
    property GfxHeight: Integer read FGfxHeight;
    property GfxWidth: Integer read FGfxWidth;
  end;

implementation

procedure CJes2CppSections.DoCreate;
begin
  inherited DoCreate;
  FGfxWidth := 400;
  FGfxHeight := 300;
  FGfxEnabled := True;
end;

procedure CJes2CppSections.ImportFromScript(const AScript: TStrings; const AFileName: TFileName);
var
  LSectionHeader: String;
begin
  FAtInit += GUtils.ExtractSection(GsEelSectionInit, AScript, AFileName, True, LSectionHeader);
  FAtSlider += GUtils.ExtractSection(GsEelSectionSlider, AScript, AFileName, True, LSectionHeader);
  FAtBlock += GUtils.ExtractSection(GsEelSectionBlock, AScript, AFileName, True, LSectionHeader);
  FAtSerialize += GUtils.ExtractSection(GsEelSectionSerialize, AScript, AFileName,
    True, LSectionHeader);
  FAtSample += GUtils.ExtractSection(GsEelSectionSample, AScript, AFileName, True, LSectionHeader);
  FAtGfx += GUtils.ExtractSection(GsEelSectionGfx, AScript, AFileName, True, LSectionHeader);
  FGfxWidth := StrToIntDef(ExtractDelimited(2, LSectionHeader, StdWordDelims), FGfxWidth);
  FGfxHeight := StrToIntDef(ExtractDelimited(3, LSectionHeader, StdWordDelims), FGfxHeight);
  if (FGfxWidth <= 0) or (FGfxHeight <= 0) then
  begin
    FGfxEnabled := False;
  end;
end;

end.

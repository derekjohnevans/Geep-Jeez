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
  Classes, Jes2CppEel, Jes2CppUtils, StrUtils, SysUtils;

type

  CJes2CppSections = class(TComponent)
  strict private
    FAtInit, FAtSlider, FAtBlock, FAtSample, FAtGfx, FAtSerialize: String;
    FGfxWidth, FGfxHeight: Integer;
  public
    constructor Create(AOwner: TComponent); override;
  public
    procedure ImportFrom(const AScript: TStrings; const AFileName: TFileName); overload;
  public
    property GfxWidth: Integer read FGfxWidth;
    property GfxHeight: Integer read FGfxHeight;
    property AtInit: String read FAtInit;
    property AtSlider: String read FAtSlider;
    property AtBlock: String read FAtBlock;
    property AtSample: String read FAtSample;
    property AtGfx: String read FAtGfx;
    property AtSerialize: String read FAtSerialize;
  end;

implementation

constructor CJes2CppSections.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FGfxWidth := 400;
  FGfxHeight := 300;
end;

procedure CJes2CppSections.ImportFrom(const AScript: TStrings; const AFileName: TFileName);
var
  LSectionHeader: String;
begin
  FAtInit += Jes2CppExtractSection(SEelSectionInit, AScript, AFileName, True, LSectionHeader);
  FAtSlider += Jes2CppExtractSection(SEelSectionSlider, AScript, AFileName, True, LSectionHeader);
  FAtBlock += Jes2CppExtractSection(SEelSectionBlock, AScript, AFileName, True, LSectionHeader);
  FAtSample += Jes2CppExtractSection(SEelSectionSample, AScript, AFileName, True, LSectionHeader);
  FAtSerialize += Jes2CppExtractSection(SEelSectionSerialize, AScript, AFileName, True, LSectionHeader);
  FAtGfx += Jes2CppExtractSection(SEelSectionGfx, AScript, AFileName, True, LSectionHeader);
  FGfxWidth := StrToIntDef(ExtractDelimited(2, LSectionHeader, StdWordDelims), FGfxWidth);
  FGfxHeight := StrToIntDef(ExtractDelimited(3, LSectionHeader, StdWordDelims), FGfxHeight);
end;

end.

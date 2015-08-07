(*

Jeez! - Jesusonic Script Editor

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

unit JeezUtils;

{$MODE DELPHI}

interface

uses
  Classes, ComCtrls, Controls, Forms, Graphics, ImgList, Jes2Cpp, Jes2CppCompiler,
  Jes2CppConstants, LCLType, Math, StdCtrls, StrUtils, SysUtils, Types;

const

  GsJeezName = 'Geep Jeez!';
  GsJeezDescription = 'Jesusonic Editor + Transpiler (' + GsJes2CppBuildDate + ')';
  GsJeezTitle = GsJeezName + ' (v' + GsJes2CppVersion + ') - ' + GsJeezDescription;

type

  CJeezJes2Cpp = class(CJes2Cpp)
  protected
    function LoadStringsFrom(const AFileName: TFileName): TStrings; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  CJeezJes2CppLogMessages = class(CJeezJes2Cpp)
  protected
    procedure LogMessage(const AMessage: String); override;
  end;

  CJeezCompiler = class(CJes2CppCompiler)
  strict private
    FLineBreaker: TStrings;
  protected
    procedure LogMessage(const AMessage: String); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  GJeezCanvas = object
    class procedure DrawFunctionDefine(const ACanvas: TCanvas; const AX, AY: Integer;
      AString: String; const AColorFunctions, AColorVariables, AColorSymbols: TColor);
    class procedure DrawItemBackground(const ACanvas: TCanvas; const ARect: TRect;
      const ASelected: Boolean; const AColor: TColor);
    class procedure DrawItem(const ACanvas: TCanvas; const AString: String;
      const ARect: TRect; const ASelected: Boolean; const AImageList: TCustomImageList;
      const AImageIndex: Integer; const ABGColor, AFGColor: TColor);
    class procedure DrawComboBoxItem(const AComboBox: TComboBox; const AIndex: Integer;
      const ARect: TRect; const ADrawState: TOwnerDrawState; const AImageList: TImageList);
  end;

implementation

uses UJeezBuild, UJeezData, UJeezIde, UJeezMessages, UJeezOptions;

class procedure GJeezCanvas.DrawFunctionDefine(const ACanvas: TCanvas;
  const AX, AY: Integer; AString: String;
  const AColorFunctions, AColorVariables, AColorSymbols: TColor);
var
  LPos, LEnd: Integer;
begin
  with ACanvas do
  begin
    PenPos := Point(AX, AY);
    LPos := 1;
    LEnd := PosEx(CharOpeningParenthesis, AString, LPos);
    if LEnd = ZeroValue then
    begin
      Font.Color := AColorFunctions;
      TextOut(PenPos.X, PenPos.Y, AString);
    end else begin
      Font.Color := AColorFunctions;
      TextOut(PenPos.X, PenPos.Y, Copy(AString, LPos, LEnd - LPos));
      Font.Color := AColorSymbols;
      TextOut(PenPos.X, PenPos.Y, CharOpeningParenthesis);
      repeat
        LPos := LEnd + 1;
        LEnd := PosSetEx([CharClosingParenthesis, CharComma], AString, LPos);
        if LEnd = 0 then
        begin
          Break;
        end;
        Font.Color := AColorVariables;
        TextOut(PenPos.X, PenPos.Y, Copy(AString, LPos, LEnd - LPos));
        if AString[LEnd] = CharComma then
        begin
          Font.Color := AColorSymbols;
          TextOut(PenPos.X, PenPos.Y, CharComma);
        end;
      until AString[LEnd] = CharClosingParenthesis;
      Font.Color := AColorSymbols;
      TextOut(PenPos.X, PenPos.Y, CharClosingParenthesis);
      TextOut(PenPos.X, PenPos.Y, Copy(AString, LEnd + 1, MaxInt));
    end;
  end;
end;

class procedure GJeezCanvas.DrawItemBackground(const ACanvas: TCanvas;
  const ARect: TRect; const ASelected: Boolean; const AColor: TColor);
begin
  if ASelected then
  begin
    ACanvas.Pen.Color := JeezOptions.ColorLineFrame.Selected;
    ACanvas.Brush.Color := JeezOptions.ColorLineColor.Selected;
    ACanvas.Rectangle(ARect);
  end else begin
    ACanvas.Pen.Color := AColor;
    ACanvas.Brush.Color := AColor;
    ACanvas.FillRect(ARect);
  end;
  ACanvas.Brush.Style := bsClear;
end;

class procedure GJeezCanvas.DrawItem(const ACanvas: TCanvas; const AString: String;
  const ARect: TRect; const ASelected: Boolean; const AImageList: TCustomImageList;
  const AImageIndex: Integer; const ABGColor, AFGColor: TColor);
begin
  GJeezCanvas.DrawItemBackground(ACanvas, ARect, ASelected, ABGColor);

  DrawFunctionDefine(ACanvas, 25, (ARect.Top + ARect.Bottom - ACanvas.TextHeight(AString)) div 2,
    AString, AFGColor, JeezOptions.ColorIdentifiers.Selected, JeezOptions.ColorSymbols.Selected);
  if Assigned(AImageList) then
  begin
    AImageList.Draw(ACanvas, 4, ARect.Top + (ARect.Bottom - ARect.Top - AImageList.Height) div 2,
      AImageIndex);
  end;
end;

class procedure GJeezCanvas.DrawComboBoxItem(const AComboBox: TComboBox;
  const AIndex: Integer; const ARect: TRect; const ADrawState: TOwnerDrawState;
  const AImageList: TImageList);
var
  LTreeNode: TTreeNode;
  LImageIndex: Integer;
  LFGColor: TColor;
begin
  LTreeNode := AComboBox.Items.Objects[AIndex] as TTreeNode;
  if Assigned(LTreeNode) then
  begin
    LImageIndex := LTreeNode.ImageIndex;
    if LImageIndex < ZeroValue then
    begin
      LImageIndex := GiImageIndexRefInternal;
    end;
  end else begin
    LImageIndex := GiImageIndexRefInternal;
  end;
  LFGColor := JeezOptions.GetComboBoxFontColor;
  if Assigned(LTreeNode.Parent) then
  begin
    case LTreeNode.Parent.ImageIndex of
      GiImageIndexVariablesSystem, GiImageIndexSliders, GiImageIndexSamples: begin
        LFGColor := JeezOptions.ColorVariables.Selected;
      end;
      GiImageIndexFunctionsSystem: begin
        LFGColor := JeezOptions.ColorFunctions.Selected;
      end;
      GiImageIndexFunctionsUser, GiImageIndexVariablesUser: begin
        LFGColor := JeezOptions.ColorIdentifiers.Selected;
      end;
    end;
  end;
  GJeezCanvas.DrawItem(AComboBox.Canvas, AComboBox.Items[AIndex], ARect,
    odSelected in ADrawState, AImageList,
    LImageIndex, AComboBox.Color, LFGColor);
end;

function CJeezJes2Cpp.LoadStringsFrom(const AFileName: TFileName): TStrings;
var
  LIndex: Integer;
begin
  LIndex := JeezIde.GetPageIndexByFileName(AFileName);
  if LIndex >= ZeroValue then
  begin
    Result := JeezIde.GetEditor(LIndex).SynEdit.Lines;
  end else begin
    Result := inherited LoadStringsFrom(AFileName);
  end;
end;

constructor CJeezJes2Cpp.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  WarningsAsErrors := JeezOptions.EditWarningsAsErrors.Checked;
  HintsAsErrors := JeezOptions.EditHintsAsErrors.Checked;
  ForceGlobals := JeezOptions.EditForceGlobals.Checked;
end;

procedure CJeezJes2CppLogMessages.LogMessage(const AMessage: String);
begin
  JeezConsole.LogMessage(SMsgTranspile, AMessage);
end;

constructor CJeezCompiler.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLineBreaker := TStringList.Create;
  SetCompilerOption(coUseLibBass, JeezOptions.EditUseBass.Checked);
  SetCompilerOption(coUseLibSndFile, JeezOptions.EditUseSndFile.Checked);
  SetCompilerOption(coUseFastMath, JeezOptions.EditUseFastMath.Checked);
  SetCompilerOption(coUseInline, JeezOptions.EditUseInlineFunctions.Checked);
  SetCompilerOption(coUseCompression, JeezOptions.EditUseCompression.Checked);
  Architecture := JeezOptions.GetArchitecture;
  Precision := JeezOptions.GetPrecision;
  PluginType := JeezOptions.GetPluginType;
  OptimizeLevel := JeezOptions.GetOptimizeLevel;
end;

destructor CJeezCompiler.Destroy;
begin
  FreeAndNil(FLineBreaker);
  inherited Destroy;
end;

procedure CJeezCompiler.LogMessage(const AMessage: String);
var
  LIndex: Integer;
begin
  FLineBreaker.Text := WrapText(AMessage, LineEnding, [CharSpace], 100);
  for LIndex := ZeroValue to FLineBreaker.Count - 1 do
  begin
    JeezConsole.LogMessage(SMsgCompiling, StringOfChar(CharSpace, Min(LIndex, 1) * 4) +
      FLineBreaker[LIndex]);
  end;
  if JeezBuild.ProgressBar.Position > ZeroValue then
  begin
    while JeezBuild.ProgressBar.Position < JeezBuild.ProgressBar.Max do
    begin
      JeezBuild.ProgressBar.StepIt;
    end;
    JeezBuild.ProgressBar.Position := ZeroValue;
  end;
  Application.ProcessMessages;
end;

end.

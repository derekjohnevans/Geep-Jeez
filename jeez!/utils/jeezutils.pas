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
  Jes2CppConstants, LCLType, Math, StdCtrls, SysUtils, Types;

const

  GsJeezName = 'Geep Jeez!';
  GsJeezDescription = 'Jesusonic Editor + Transpiler (' + GsJes2CppBuildDate + ')';
  GsJeezTitle = GsJeezName + ' (v' + GsJes2CppVersion + ') - ' + GsJeezDescription;

type

  Jeez_Jes2Cpp = class(CJes2Cpp)
  protected
    procedure LogMessage(const AMessage: String); override;
    procedure LoadStringsFrom(const AStrings: TStrings; const AFileName: TFileName); override;
  end;

  Jeez_Compile = class(CJes2CppCompiler)
  strict private
    FLineBreaker: TStrings;
  protected
    procedure LogMessage(const AMessage: String); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

procedure J2C_CanvasDrawItem(const ACanvas: TCanvas; const AString: String; const ARect: TRect; const ASelected: Boolean;
  const AImageList: TCustomImageList; const AImageIndex: Integer);
procedure J2C_ComboBoxDrawItem(const AComboBox: TComboBox; const AIndex: Integer; const ARect: TRect;
  const ADrawState: TOwnerDrawState; const AImageList: TImageList);

implementation

uses UJeezBuild, UJeezIde, UJeezMessages, UJeezOptions;

procedure J2C_CanvasDrawItem(const ACanvas: TCanvas; const AString: String; const ARect: TRect; const ASelected: Boolean;
  const AImageList: TCustomImageList; const AImageIndex: Integer);
begin
  if ASelected then
  begin
    ACanvas.Brush.Color := JeezOptions.ColorCurrentLine.Selected;
    ACanvas.Font.Color := JeezOptions.ColorIdentifiers.Selected;
  end else begin
    ACanvas.Brush.Color := JeezOptions.ColorBackground.Selected;
    ACanvas.Font.Color := JeezOptions.ColorIdentifiers.Selected;
  end;
  ACanvas.FillRect(ARect);
  ACanvas.TextRect(ARect, 25, (ARect.Top + ARect.Bottom - ACanvas.TextHeight(AString)) div 2, AString);
  if Assigned(AImageList) then
  begin
    AImageList.Draw(ACanvas, 4, ARect.Top + (ARect.Bottom - ARect.Top - AImageList.Height) div 2,
      AImageIndex);
  end;
end;

procedure J2C_ComboBoxDrawItem(const AComboBox: TComboBox; const AIndex: Integer; const ARect: TRect;
  const ADrawState: TOwnerDrawState; const AImageList: TImageList);
begin
  J2C_CanvasDrawItem(AComboBox.Canvas, AComboBox.Items[AIndex], ARect, odSelected in ADrawState, AImageList,
    TTreeNode(AComboBox.Items.Objects[AIndex]).ImageIndex);
end;

procedure Jeez_Jes2Cpp.LogMessage(const AMessage: String);
begin
  JeezMessages.LogMessage(ClassName, AMessage);
end;

procedure Jeez_Jes2Cpp.LoadStringsFrom(const AStrings: TStrings; const AFileName: TFileName);
var
  LIndex: Integer;
begin
  LIndex := JeezIde.GetPageIndexByFileName(AFileName);
  if LIndex < 0 then
  begin
    inherited LoadStringsFrom(AStrings, AFileName);
  end else begin
    AStrings.Assign(JeezIde.GetEditor(LIndex).SynEdit.Lines);
  end;
end;

constructor Jeez_Compile.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLineBreaker := TStringList.Create;
end;

destructor Jeez_Compile.Destroy;
begin
  FreeAndNil(FLineBreaker);
  inherited Destroy;
end;

procedure Jeez_Compile.LogMessage(const AMessage: String);
var
  LIndex: Integer;
begin
  FLineBreaker.Text := WrapText(AMessage, LineEnding, [CharSpace], 100);
  for LIndex := 0 to FLineBreaker.Count - 1 do
  begin
    JeezMessages.LogMessage(ClassName, StringOfChar(CharSpace, Min(LIndex, 1) * 4) + FLineBreaker[LIndex]);
  end;
  if JeezBuild.ProgressBar.Position > 0 then
  begin
    while JeezBuild.ProgressBar.Position < JeezBuild.ProgressBar.Max do
    begin
      JeezBuild.ProgressBar.StepIt;
    end;
    JeezBuild.ProgressBar.Position := 0;
  end;
  Application.ProcessMessages;
end;

end.

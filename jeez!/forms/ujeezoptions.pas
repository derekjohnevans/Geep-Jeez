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

unit UJeezOptions;

{$MODE DELPHI}

interface

uses
  ButtonPanel, ColorBox, ComCtrls, Controls, EditBtn, Forms, Graphics, JeezIniFile, JeezLabels,
  Jes2CppCompiler, Jes2CppConstants, Jes2CppFileNames, Jes2CppPlatform, Spin,
  StdCtrls, StrUtils, SynEdit, SynEditHighlighter, SynHighlighterAny, SynHighlighterCpp, SysUtils;

type

  { TJeezOptions }

  TJeezOptions = class(TForm)
    ButtonPresetTwilight: TButton;
    ButtonPresetDefault: TButton;
    ButtonPresetDaylight: TButton;
    ButtonClear: TButton;
    ButtonPanel: TButtonPanel;
    ButtonPresetOcean: TButton;
    ButtonPresetClassic: TButton;
    ButtonPresetREAPER: TButton;
    EditForceGlobals: TCheckBox;
    EditUseCompression: TCheckBox;
    EditUseInlineFunctions: TCheckBox;
    EditUseFastMath: TCheckBox;
    EditUseBass: TCheckBox;
    EditUseSndFile: TCheckBox;
    EditFontName: TComboBox;
    EditAntialiased: TCheckBox;
    ColorBackground: TColorBox;
    ColorComments: TColorBox;
    ColorFunctions: TColorBox;
    ColorGutter: TColorBox;
    ColorCurrentLine: TColorBox;
    ColorGutterText: TColorBox;
    ColorInfoBlocks: TColorBox;
    ColorIdentifiers: TColorBox;
    ColorNumbers: TColorBox;
    ColorKeywords: TColorBox;
    ColorStrings: TColorBox;
    ColorSymbols: TColorBox;
    ColorVariables: TColorBox;
    EditDefUniqueId: TEdit;
    EditCompiler: TComboBox;
    EditDefProductString: TEdit;
    EditDefVendorString: TEdit;
    EditDefVendorVersion: TSpinEdit;
    EditDefVstPath: TDirectoryEdit;
    EditFloatPrecision: TComboBox;
    EditPluginType: TComboBox;
    EditProcessorType: TComboBox;
    GroupBoxExtraOptions: TGroupBox;
    GroupBoxPresets: TGroupBox;
    GroupBoxFont: TGroupBox;
    GroupBoxColors: TGroupBox;
    GroupBoxCompiler: TGroupBox;
    GroupBoxDefault: TGroupBox;
    EditRecentFiles: TListBox;
    PageControl: TPageControl;
    EditFontSize: TSpinEdit;
    TabSheetCompiler: TTabSheet;
    TabSheetColors: TTabSheet;
    TabSheetRecentFiles: TTabSheet;
    TabSheetGeneral: TTabSheet;
    procedure ButtonClearClick(ASender: TObject);
    procedure ButtonPresetClassicClick(ASender: TObject);
    procedure ButtonPresetDefaultClick(ASender: TObject);
    procedure ButtonPresetDaylightClick(ASender: TObject);
    procedure ButtonPresetREAPERClick(ASender: TObject);
    procedure ButtonPresetOceanClick(ASender: TObject);
    procedure ButtonPresetTwilightClick(ASender: TObject);
    procedure EditDefVstPathChange(ASender: TObject);
    procedure FormCreate(ASender: TObject);
    procedure FormShow(ASender: TObject);
    procedure GroupBoxPresetsResize(ASender: TObject);
  private
    FStorage: TJeezStorage;
    procedure SettingsSave;
    procedure SettingsLoad;
  public
    procedure ApplyControl(const AControl: TControl; const AColor: TColor);
    procedure ApplySynCustomHighlighter(const AHighlighter: TSynCustomHighlighter);
    procedure ApplySynCppSyn(const AHighlighter: TSynCppSyn);
    procedure ApplySynAnySyn(const AHighlighter: TSynAnySyn; const ADetectPreprocessor: Boolean);
    procedure ApplySynEdit(const ASynEdit: TSynEdit; const AColor: TColor);
  public
    function Execute: Boolean;
    function GetCompiler: TFileName;
    function GetTypeProcessor: TJes2CppCompilerProcessor;
    function GetTypePrecision: TJes2CppCompilerPrecision;
    function GetTypePlugin: TJes2CppCompilerPlugin;
  public
    procedure AddRecentFile(const AFileName: TFileName);
  end;

var
  JeezOptions: TJeezOptions;

implementation

{$R *.lfm}

uses UJeezIde;

procedure TJeezOptions.FormCreate(ASender: TObject);
begin
  J2C_ScrollingWinControlPrepare(Self);
  EditRecentFiles.Font.Size := 8;
  FStorage := TJeezStorage.Create(GetAppConfigFile(False));
  PageControl.ActivePageIndex := 0;
  EditDefVstPath.Directory := TJes2CppFileNames.PathToVstEffects;
  with EditCompiler.Items do
  begin
    Add('g++ (Default GCC)');
{$IFDEF WINDOWS}
    Add('x86_64-w64-mingw32-g++ (LDM-GCC-64)');
    Add('mingw32-g++ (LDM-GCC-32)');
{$ENDIF}
  end;
  EditCompiler.ItemIndex := 0;

  ButtonPresetDefault.Click;

  SettingsLoad;
  SettingsSave;
end;

procedure TJeezOptions.FormShow(ASender: TObject);
begin
  J2C_WinControlCreateLabels(Self);
end;

procedure TJeezOptions.GroupBoxPresetsResize(ASender: TObject);
begin
  with ASender as TWinControl do
  begin
    ChildSizing.LeftRightSpacing := (ClientWidth - ButtonPresetTwilight.BoundsRect.Right + 1) div 2;
  end;
end;

procedure TJeezOptions.EditDefVstPathChange(ASender: TObject);
begin
  with ASender as TDirectoryEdit do
  begin
    Directory := IncludeTrailingPathDelimiter(Directory);
  end;
end;

procedure TJeezOptions.ButtonClearClick(ASender: TObject);
begin
  EditRecentFiles.Clear;
end;

procedure TJeezOptions.ButtonPresetClassicClick(ASender: TObject);
begin
  ColorBackground.Selected := clNavy;
  ColorInfoBlocks.Selected := clNavy;
  ColorComments.Selected := clSilver;
  ColorCurrentLine.Selected := clBlue;
  ColorFunctions.Selected := clYellow;
  ColorGutter.Selected := clNavy;
  ColorGutterText.Selected := clYellow;
  ColorIdentifiers.Selected := clYellow;
  ColorKeywords.Selected := clWhite;
  ColorNumbers.Selected := clYellow;
  ColorStrings.Selected := clYellow;
  ColorSymbols.Selected := clYellow;
  ColorVariables.Selected := clYellow;
end;

procedure TJeezOptions.ButtonPresetDefaultClick(ASender: TObject);
begin
  ColorBackground.Selected := $0d0d0d;
  ColorInfoBlocks.Selected := $0d0d0d;
  ColorComments.Selected := $C08060;
  ColorCurrentLine.Selected := $333333;
  ColorFunctions.Selected := clYellow;
  ColorGutter.Selected := $333333;
  ColorGutterText.Selected := clSilver;
  ColorIdentifiers.Selected := clWhite;
  ColorKeywords.Selected := clAqua;
  ColorNumbers.Selected := clLime;
  ColorStrings.Selected := $C0C0FF;
  ColorSymbols.Selected := clAqua;
  ColorVariables.Selected := $8080FF;
end;

procedure TJeezOptions.ButtonPresetDaylightClick(ASender: TObject);
begin
  ColorBackground.Selected := clWhite;
  ColorInfoBlocks.Selected := clInfoBlock;
  ColorComments.Selected := clGreen;
  ColorCurrentLine.Selected := clSilver;
  ColorFunctions.Selected := clMaroon;
  ColorGutter.Selected := clSilver;
  ColorGutterText.Selected := clBlack;
  ColorIdentifiers.Selected := clBlack;
  ColorKeywords.Selected := clNavy;
  ColorNumbers.Selected := clBlue;
  ColorStrings.Selected := clBlue;
  ColorSymbols.Selected := clBlack;
  ColorVariables.Selected := clFuchsia;
end;

procedure TJeezOptions.ButtonPresetREAPERClick(ASender: TObject);
begin
  ColorBackground.Selected := clBlack;
  ColorInfoBlocks.Selected := clBlack;
  ColorComments.Selected := $C08060;
  ColorCurrentLine.Selected := $333333;
  ColorFunctions.Selected := clYellow;
  ColorGutter.Selected := clBlack;
  ColorGutterText.Selected := clBlack;
  ColorIdentifiers.Selected := clWhite;
  ColorKeywords.Selected := clAqua;
  ColorNumbers.Selected := clLime;
  ColorStrings.Selected := $C0C0FF;
  ColorSymbols.Selected := clAqua;
  ColorVariables.Selected := $8080FF;
end;

procedure TJeezOptions.ButtonPresetOceanClick(ASender: TObject);
begin
  ColorBackground.Selected := clNavy;
  ColorInfoBlocks.Selected := clNavy;
  ColorComments.Selected := clGray;
  ColorCurrentLine.Selected := clBlue;
  ColorFunctions.Selected := clLime;
  ColorGutter.Selected := clNavy;
  ColorGutterText.Selected := clYellow;
  ColorIdentifiers.Selected := clYellow;
  ColorKeywords.Selected := clAqua;
  ColorNumbers.Selected := clFuchsia;
  ColorStrings.Selected := clYellow;
  ColorSymbols.Selected := clAqua;
  ColorVariables.Selected := clFuchsia;
end;

procedure TJeezOptions.ButtonPresetTwilightClick(ASender: TObject);
begin
  ColorBackground.Selected := clBlack;
  ColorInfoBlocks.Selected := clBlack;
  ColorComments.Selected := clGray;
  ColorCurrentLine.Selected := clNavy;
  ColorFunctions.Selected := clLime;
  ColorGutter.Selected := clBlack;
  ColorGutterText.Selected := clWhite;
  ColorIdentifiers.Selected := clWhite;
  ColorKeywords.Selected := clAqua;
  ColorNumbers.Selected := clFuchsia;
  ColorStrings.Selected := clYellow;
  ColorSymbols.Selected := clAqua;
  ColorVariables.Selected := clFuchsia;
end;

procedure TJeezOptions.SettingsLoad;
begin
  FStorage.LoadAll(Self);
end;

procedure TJeezOptions.SettingsSave;
begin
  FStorage.SaveAll(Self);
end;

function TJeezOptions.Execute: Boolean;
begin
  SettingsLoad;
  Result := ShowModal = mrOk;
  if Result then
  begin
    SettingsSave;
    JeezIde.UpdateColors;
  end else begin
    SettingsLoad;
  end;
end;

procedure TJeezOptions.AddRecentFile(const AFileName: TFileName);
var
  LIndex: Integer;
begin
  for LIndex := EditRecentFiles.Count - 1 downto 0 do
  begin
    if SameFileName(EditRecentFiles.Items[LIndex], AFileName) then
    begin
      EditRecentFiles.Items.Delete(LIndex);
    end;
  end;
  while EditRecentFiles.Count > 20 do
  begin
    EditRecentFiles.Items.Delete(EditRecentFiles.Count - 1);
  end;
  EditRecentFiles.Items.Insert(0, AFileName);
  SettingsSave;
end;

function TJeezOptions.GetCompiler: TFileName;
begin
  Result := ExtractDelimited(1, EditCompiler.Text, [CharSpace]);
end;

function TJeezOptions.GetTypeProcessor: TJes2CppCompilerProcessor;
begin
  Result := TJes2CppCompilerProcessor(EditProcessorType.ItemIndex);
end;

function TJeezOptions.GetTypePrecision: TJes2CppCompilerPrecision;
begin
  Result := TJes2CppCompilerPrecision(EditFloatPrecision.ItemIndex);
end;

function TJeezOptions.GetTypePlugin: TJes2CppCompilerPlugin;
begin
  Result := TJes2CppCompilerPlugin(EditPluginType.ItemIndex);
end;

procedure TJeezOptions.ApplyControl(const AControl: TControl; const AColor: TColor);
begin
  AControl.Color := AColor;
  if EditAntialiased.Checked then
  begin
    AControl.Font.Quality := fqProof;
  end else begin
    AControl.Font.Quality := fqNonAntialiased;
  end;
  AControl.Font.Name := EditFontName.Text;
  AControl.Font.Size := EditFontSize.Value;
  AControl.Font.Color := ColorIdentifiers.Selected;
  if AControl is TTreeView then
  begin
    TTreeView(AControl).BackgroundColor := AControl.Color;
  end;
end;

procedure TJeezOptions.ApplySynCustomHighlighter(const AHighlighter: TSynCustomHighlighter);
begin
  AHighlighter.CommentAttribute.Foreground := ColorComments.Selected;
  AHighlighter.CommentAttribute.Style := [];
  AHighlighter.KeywordAttribute.Foreground := ColorKeywords.Selected;
  AHighlighter.KeywordAttribute.Style := [fsBold];
  AHighlighter.StringAttribute.Foreground := ColorStrings.Selected;
  AHighlighter.IdentifierAttribute.Foreground := ColorIdentifiers.Selected;
end;

procedure TJeezOptions.ApplySynCppSyn(const AHighlighter: TSynCppSyn);
begin
  ApplySynCustomHighlighter(AHighlighter);
  AHighlighter.DirecAttri.Foreground := AHighlighter.CommentAttribute.Foreground;
  AHighlighter.NumberAttri.Foreground := AHighlighter.StringAttribute.Foreground;
  AHighlighter.SymbolAttri.Foreground := ColorSymbols.Selected;
  AHighlighter.InvalidAttri.Foreground := ColorSymbols.Selected;
end;

procedure TJeezOptions.ApplySynAnySyn(const AHighlighter: TSynAnySyn; const ADetectPreprocessor: Boolean);
begin
  ApplySynCustomHighlighter(AHighlighter);
  AHighlighter.DetectPreprocessor := ADetectPreprocessor;
  AHighlighter.PreprocessorAttri.Foreground := clGreen;
  AHighlighter.PreprocessorAttri.Style := [fsBold];
  AHighlighter.NumberAttri.Foreground := ColorNumbers.Selected;
  AHighlighter.ConstantAttri.Foreground := ColorVariables.Selected;
  AHighlighter.ObjectAttri.Foreground := ColorFunctions.Selected;
  AHighlighter.IdentifierAttri.Foreground := ColorIdentifiers.Selected;
  AHighlighter.SymbolAttribute.Foreground := ColorSymbols.Selected;
  AHighlighter.VariableAttri.Foreground := ColorNumbers.Selected;
  if ADetectPreprocessor then
  begin
    AHighlighter.KeywordAttribute.Foreground := ColorGutterText.Selected;
    AHighlighter.KeywordAttribute.Background := ColorGutter.Selected;
  end;
end;

procedure TJeezOptions.ApplySynEdit(const ASynEdit: TSynEdit; const AColor: TColor);
begin
  ApplyControl(ASynEdit, AColor);
  ASynEdit.SelectedColor.Background := ColorComments.Selected;  // TODO: ???
  ASynEdit.SelectedColor.Foreground := ColorBackground.Selected;
  ASynEdit.LineHighlightColor.Background := ColorCurrentLine.Selected;

  ASynEdit.Gutter.Visible := ColorGutter.Selected <> ColorGutterText.Selected;
  if ASynEdit.Gutter.Visible then
  begin
    ASynEdit.Gutter.Color := ColorGutter.Selected;
    if Assigned(ASynEdit.Gutter.SeparatorPart) then
    begin
      ASynEdit.Gutter.SeparatorPart.Visible := ASynEdit.Gutter.Color = ColorBackground.Selected;
    end;
    if Assigned(ASynEdit.Gutter.LineNumberPart) then
    begin
      ASynEdit.Gutter.LineNumberPart.MarkupInfo.Foreground := ColorGutterText.Selected;
    end;
  end;
end;

end.

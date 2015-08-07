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
  ButtonPanel, ColorBox, ComCtrls, Controls, EditBtn, Forms, Graphics,
  GraphUtil, JeezIniFile, JeezLabels, JeezSynEdit, Jes2CppCompiler, Jes2CppConstants,
  Jes2CppFileNames, Jes2CppPlatform, Spin, StdCtrls, StrUtils, SynEdit,
  SynEditHighlighter, SynHighlighterAny, SynHighlighterCpp, SysUtils;

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
    EditBoldImportant: TCheckBox;
    ColorLineFrame: TColorBox;
    EditOptimizeLevel: TComboBox;
    EditFontName: TComboBox;
    EditAntialiased: TCheckBox;
    ColorBackground: TColorBox;
    ColorComments: TColorBox;
    ColorFunctions: TColorBox;
    ColorGutter: TColorBox;
    ColorLineColor: TColorBox;
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
    EditForceGlobals: TCheckBox;
    EditHintsAsErrors: TCheckBox;
    EditPluginType: TComboBox;
    EditProcessorType: TComboBox;
    EditUseBass: TCheckBox;
    EditUseCompression: TCheckBox;
    EditUseFastMath: TCheckBox;
    EditUseInlineFunctions: TCheckBox;
    EditUseSndFile: TCheckBox;
    EditWarningsAsErrors: TCheckBox;
    GroupBoxExtraOptions: TGroupBox;
    GroupBoxPresets: TGroupBox;
    GroupBoxFont: TGroupBox;
    GroupBoxColors: TGroupBox;
    GroupBoxCompiler: TGroupBox;
    GroupBoxDefault: TGroupBox;
    EditRecentFiles: TListBox;
    PageControl: TPageControl;
    EditFontSize: TSpinEdit;
    TabSheetSwitches: TTabSheet;
    TabSheetBuild: TTabSheet;
    TabSheetEditor: TTabSheet;
    TabSheetRecentFiles: TTabSheet;
    TabSheetDefaults: TTabSheet;
    procedure ButtonClearClick(ASender: TObject);
    procedure ButtonPresetClassicClick(ASender: TObject);
    procedure ButtonPresetDefaultClick(ASender: TObject);
    procedure ButtonPresetDaylightClick(ASender: TObject);
    procedure ButtonPresetREAPERClick(ASender: TObject);
    procedure ButtonPresetOceanClick(ASender: TObject);
    procedure ButtonPresetTwilightClick(ASender: TObject);
    procedure EditDefVstPathChange(ASender: TObject);
    procedure FormCreate(ASender: TObject);
    procedure FormDestroy(ASender: TObject);
    procedure FormShow(ASender: TObject);
    procedure GroupBoxPresetsResize(ASender: TObject);
  private
    FStorage: TJeezStorage;
    procedure SettingsSave;
    procedure SettingsLoad;
  public
    procedure ApplyControl(const AControl: TControl; const AColor: TColor);
    procedure ApplyComboBox(const AComboBox: TComboBox; const AColor: TColor);
    procedure ApplySynCustomHighlighter(const AHighlighter: TSynCustomHighlighter);
    procedure ApplySynCppSyn(const AHighlighter: TSynCppSyn);
    procedure ApplySynAnySyn(const AHighlighter: TSynAnySyn; const ADetectPreprocessor: Boolean);
    procedure ApplySynEdit(const ASynEdit: TSynEdit; const AColor: TColor);
  public
    function Execute: Boolean;
  public
    function GetComboBoxFontColor: TColor;
    function GetGccExecutable: TFileName;
    function GetArchitecture: CJes2CppCompiler.TArchitecture;
    function GetPrecision: CJes2CppCompiler.TFloatPrecision;
    function GetPluginType: CJes2CppCompiler.TPluginType;
    function GetOptimizeLevel: CJes2CppCompiler.TOptimizeLevel;
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
  GPlatform.ScrollingWinControlPrepare(Self);
  EditRecentFiles.Font.Size := 8;
  FStorage := TJeezStorage.Create(GetAppConfigFile(False));
  PageControl.ActivePageIndex := 0;
  EditDefVstPath.Directory := GFilePath.VstEffects;
  with EditCompiler.Items do
  begin
    Add('g++ (Default GCC)');
    if GPlatform.IsWindows then
    begin
      Add('x86_64-w64-mingw32-g++ (LDM-GCC-64)');
      Add('mingw32-g++ (LDM-GCC-32)');
      Add('x86_64-pc-cygwin-gcc (cygwin)');
    end;
  end;
  // Setup defaults.
  EditCompiler.ItemIndex := 1; // TODO: Change this for Linux
  EditProcessorType.ItemIndex := Ord(ca32bit);
  EditFloatPrecision.ItemIndex := Ord(cfpDouble);
  EditPluginType.ItemIndex := Ord(cptVST);
  EditOptimizeLevel.ItemIndex := Ord(colO2);
  if GPlatform.IsWindows then
  begin
    EditFontName.Caption := 'Courier New';
  end else if GPlatform.IsLinux then
  begin
    EditFontName.Caption := 'Courier';
  end;
  EditFontName.Items := Screen.Fonts;

  ButtonPresetDefault.Click;

  SettingsLoad;
  SettingsSave;
end;

procedure TJeezOptions.FormDestroy(ASender: TObject);
begin
  SettingsSave;
end;

procedure TJeezOptions.FormShow(ASender: TObject);
begin
  J2C_WinControlCreateLabels(Self);
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
  SettingsSave;
  Result := ShowModal = mrOk;
  if Result then
  begin
    SettingsSave;
    JeezIde.UpdateAllEditors;
  end else begin
    SettingsLoad;
  end;
end;

procedure TJeezOptions.GroupBoxPresetsResize(ASender: TObject);
begin
  with ASender as TWinControl do
  begin
    ChildSizing.LeftRightSpacing :=
      (ClientWidth - ButtonPresetTwilight.BoundsRect.Right + 1) div 2;
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

procedure TJeezOptions.ButtonPresetDefaultClick(ASender: TObject);
begin
  ColorBackground.Selected := $0f0f0f;
  ColorComments.Selected := $C08060;
  ColorFunctions.Selected := clYellow;
  ColorGutter.Selected := $222222;
  ColorGutterText.Selected := clSilver;
  ColorIdentifiers.Selected := clWhite;
  ColorInfoBlocks.Selected := ColorBackground.Selected;
  ColorKeywords.Selected := clAqua;
  ColorLineColor.Selected := ColorGutter.Selected;
  ColorLineFrame.Selected := $555555;
  ColorNumbers.Selected := clLime;
  ColorStrings.Selected := $C0C0FF;
  ColorSymbols.Selected := clAqua;
  ColorVariables.Selected := $8080FF;
end;

procedure TJeezOptions.ButtonPresetREAPERClick(ASender: TObject);
begin
  ColorBackground.Selected := clBlack;
  ColorComments.Selected := $C08060;
  ColorFunctions.Selected := clYellow;
  ColorGutter.Selected := clBlack;
  ColorGutterText.Selected := clBlack;
  ColorIdentifiers.Selected := clWhite;
  ColorInfoBlocks.Selected := ColorBackground.Selected;
  ColorKeywords.Selected := clAqua;
  ColorLineColor.Selected := $333333;
  ColorLineFrame.Selected := ColorLineColor.Selected;
  ColorNumbers.Selected := clLime;
  ColorStrings.Selected := $C0C0FF;
  ColorSymbols.Selected := clAqua;
  ColorVariables.Selected := $8080FF;
end;

procedure TJeezOptions.ButtonPresetDaylightClick(ASender: TObject);
begin
  ColorBackground.Selected := clWhite;
  ColorComments.Selected := clGreen;
  ColorFunctions.Selected := clMaroon;
  ColorGutter.Selected := clSilver;
  ColorGutterText.Selected := clBlack;
  ColorIdentifiers.Selected := clBlack;
  ColorInfoBlocks.Selected := clInfoBlock;
  ColorKeywords.Selected := clNavy;
  ColorLineColor.Selected := clSilver;
  ColorLineFrame.Selected := ColorLineColor.Selected;
  ColorNumbers.Selected := clBlue;
  ColorStrings.Selected := clBlue;
  ColorSymbols.Selected := clBlack;
  ColorVariables.Selected := clFuchsia;
end;

procedure TJeezOptions.ButtonPresetOceanClick(ASender: TObject);
begin
  ColorBackground.Selected := clNavy;
  ColorComments.Selected := clGray;
  ColorFunctions.Selected := clLime;
  ColorGutter.Selected := clNavy;
  ColorGutterText.Selected := clYellow;
  ColorIdentifiers.Selected := clYellow;
  ColorInfoBlocks.Selected := ColorAdjustLuma(ColorBackground.Selected, -16, False);
  ColorKeywords.Selected := clAqua;
  ColorLineColor.Selected := clBlue;
  ColorLineFrame.Selected := ColorLineColor.Selected;
  ColorNumbers.Selected := clFuchsia;
  ColorStrings.Selected := clYellow;
  ColorSymbols.Selected := clAqua;
  ColorVariables.Selected := clFuchsia;
end;

procedure TJeezOptions.ButtonPresetClassicClick(ASender: TObject);
begin
  ColorBackground.Selected := clNavy;
  ColorComments.Selected := clSilver;
  ColorFunctions.Selected := clYellow;
  ColorGutter.Selected := clNavy;
  ColorGutterText.Selected := clYellow;
  ColorIdentifiers.Selected := clYellow;
  ColorInfoBlocks.Selected := ColorAdjustLuma(ColorBackground.Selected, -16, False);
  ColorKeywords.Selected := clWhite;
  ColorLineColor.Selected := clBlue;
  ColorLineFrame.Selected := ColorLineColor.Selected;
  ColorNumbers.Selected := clYellow;
  ColorStrings.Selected := clYellow;
  ColorSymbols.Selected := clYellow;
  ColorVariables.Selected := clYellow;
end;

procedure TJeezOptions.ButtonPresetTwilightClick(ASender: TObject);
begin
  ColorBackground.Selected := clBlack;
  ColorComments.Selected := clGray;
  ColorFunctions.Selected := clLime;
  ColorGutter.Selected := clBlack;
  ColorGutterText.Selected := clWhite;
  ColorIdentifiers.Selected := clWhite;
  ColorInfoBlocks.Selected := ColorBackground.Selected;
  ColorKeywords.Selected := clAqua;
  ColorLineColor.Selected := clNavy;
  ColorLineFrame.Selected := ColorLineColor.Selected;
  ColorNumbers.Selected := clFuchsia;
  ColorStrings.Selected := clYellow;
  ColorSymbols.Selected := clAqua;
  ColorVariables.Selected := clFuchsia;
end;

procedure TJeezOptions.AddRecentFile(const AFileName: TFileName);
var
  LIndex: Integer;
begin
  if not SameText(ExtractFileExt(AFileName), GsFileExtJsFxInc) then
  begin
    for LIndex := EditRecentFiles.Count - 1 downto 0 do
    begin
      if SameFileName(EditRecentFiles.Items[LIndex], AFileName) then
      begin
        EditRecentFiles.Items.Delete(LIndex);
      end;
    end;
    while EditRecentFiles.Count > 30 do
    begin
      EditRecentFiles.Items.Delete(EditRecentFiles.Count - 1);
    end;
    EditRecentFiles.Items.Insert(0, AFileName);
    SettingsSave;
  end;
end;

function TJeezOptions.GetGccExecutable: TFileName;
begin
  Result := ExtractDelimited(1, EditCompiler.Text, [CharSpace]);
end;

function TJeezOptions.GetArchitecture: CJes2CppCompiler.TArchitecture;
begin
  Result := CJes2CppCompiler.TArchitecture(EditProcessorType.ItemIndex);
end;

function TJeezOptions.GetPrecision: CJes2CppCompiler.TFloatPrecision;
begin
  Result := CJes2CppCompiler.TFloatPrecision(EditFloatPrecision.ItemIndex);
end;

function TJeezOptions.GetPluginType: CJes2CppCompiler.TPluginType;
begin
  Result := CJes2CppCompiler.TPluginType(EditPluginType.ItemIndex);
end;

function TJeezOptions.GetOptimizeLevel: CJes2CppCompiler.TOptimizeLevel;
begin
  Result := CJes2CppCompiler.TOptimizeLevel(EditOptimizeLevel.ItemIndex);
end;

function TJeezOptions.GetComboBoxFontColor: TColor;
begin
  Result := ColorVariables.Selected;
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
  if AControl is TComboBox then
  begin
    AControl.Font.Height := TComboBox(AControl).ItemHeight;
    AControl.Font.Color := GetComboBoxFontColor;
  end else begin
    AControl.Font.Size := EditFontSize.Value;
    AControl.Font.Color := ColorIdentifiers.Selected;
  end;
  if AControl is TTreeView then
  begin
    TTreeView(AControl).BackgroundColor := AControl.Color;
  end;
end;

procedure TJeezOptions.ApplyComboBox(const AComboBox: TComboBox; const AColor: TColor);
begin
  ApplyControl(AComboBox, AColor);
  AComboBox.Invalidate;
end;

procedure TJeezOptions.ApplySynCustomHighlighter(const AHighlighter: TSynCustomHighlighter);
begin
  GSynHighlighter.SetAttribute(AHighlighter.CommentAttribute, ColorComments.Selected);
  GSynHighlighter.SetAttribute(AHighlighter.KeywordAttribute, ColorKeywords.Selected,
    EditBoldImportant.Checked);
  GSynHighlighter.SetAttribute(AHighlighter.StringAttribute, ColorStrings.Selected);
  GSynHighlighter.SetAttribute(AHighlighter.IdentifierAttribute, ColorIdentifiers.Selected);
end;

procedure TJeezOptions.ApplySynCppSyn(const AHighlighter: TSynCppSyn);
begin
  ApplySynCustomHighlighter(AHighlighter);
  GSynHighlighter.SetAttribute(AHighlighter.DirecAttri, AHighlighter.CommentAttribute.Foreground);
  GSynHighlighter.SetAttribute(AHighlighter.NumberAttri, AHighlighter.StringAttribute.Foreground);
  GSynHighlighter.SetAttribute(AHighlighter.SymbolAttri, ColorSymbols.Selected);
  GSynHighlighter.SetAttribute(AHighlighter.InvalidAttri, ColorSymbols.Selected);
end;

procedure TJeezOptions.ApplySynAnySyn(const AHighlighter: TSynAnySyn;
  const ADetectPreprocessor: Boolean);
begin
  ApplySynCustomHighlighter(AHighlighter);
  AHighlighter.DetectPreprocessor := ADetectPreprocessor;
  GSynHighlighter.SetAttribute(AHighlighter.PreprocessorAttri, clGreen);
  GSynHighlighter.SetAttribute(AHighlighter.NumberAttri, ColorNumbers.Selected);
  GSynHighlighter.SetAttribute(AHighlighter.ConstantAttri, ColorVariables.Selected,
    EditBoldImportant.Checked);
  GSynHighlighter.SetAttribute(AHighlighter.ObjectAttri, ColorFunctions.Selected,
    EditBoldImportant.Checked);
  GSynHighlighter.SetAttribute(AHighlighter.IdentifierAttri, ColorIdentifiers.Selected);
  GSynHighlighter.SetAttribute(AHighlighter.SymbolAttribute, ColorSymbols.Selected);
  GSynHighlighter.SetAttribute(AHighlighter.VariableAttri, ColorNumbers.Selected);
  if ADetectPreprocessor then
  begin
    AHighlighter.KeywordAttribute.Foreground := ColorGutterText.Selected;
    AHighlighter.KeywordAttribute.Background := ColorGutter.Selected;
  end;
end;

procedure TJeezOptions.ApplySynEdit(const ASynEdit: TSynEdit; const AColor: TColor);
begin
  ApplyControl(ASynEdit, AColor);
  ASynEdit.SelectedColor.Background := ColorComments.Selected;
  ASynEdit.SelectedColor.Foreground := ColorBackground.Selected;

  ASynEdit.LineHighlightColor.Background := ColorLineColor.Selected;
  ASynEdit.LineHighlightColor.FrameColor := ColorLineFrame.Selected;
  if ASynEdit.LineHighlightColor.FrameColor = ASynEdit.LineHighlightColor.Background then
  begin
    ASynEdit.LineHighlightColor.FrameColor := clNone;
  end;
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

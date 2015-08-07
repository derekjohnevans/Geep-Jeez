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

unit UJeezEditor;

{$MODE DELPHI}

interface

uses
  Buttons, Classes, ComCtrls, Controls, ExtCtrls, Forms, JeezResources, JeezSynEdit,
  JeezTreeView, JeezUtils, Jes2CppCompiler, Jes2CppConstants, Jes2CppEel,
  Jes2CppFileNames, Jes2CppFunction,
  Jes2CppIdentifier, Jes2CppIdentString, Jes2CppPlatform, Jes2CppReference, Jes2CppStrings,
  Jes2CppTextFileCache, Jes2CppUtils, Jes2CppVariable, LCLIntf, LCLType, Math,
  Menus, StdCtrls, StrUtils, SynEdit, SynEditMiscClasses,
  SynEditTypes, SynHighlighterAny, SysUtils, Types;

type

  { TJeezEditor }

  TJeezEditor = class(TFrame)
    ButtonProperties: TToolButton;
    ButtonSectionNext: TToolButton;
    ButtonSectionPrev: TToolButton;
    ButtonSectionSelect: TToolButton;
    ButtonSyntaxCheck: TToolButton;
    EditVariNames: TComboBox;
    EditFuncNames: TComboBox;
    EditTreeFolder: TComboBox;
    ErrorImage: TImage;
    MenuPopupUnused: TMenuItem;
    MenuPopupSearchForVariable: TMenuItem;
    MenuPopupSearchForFunction: TMenuItem;
    MenuPopupOpenImport: TMenuItem;
    MenuPopupOpenImportSep: TMenuItem;
    MenuPopupProperties: TMenuItem;
    MenuPopupSep3: TMenuItem;
    MenuPopupUndo: TMenuItem;
    MenuPopupRedo: TMenuItem;
    MenuPopupSep1: TMenuItem;
    MenuPopupCopy: TMenuItem;
    MenuPopupCut: TMenuItem;
    MenuPopupDelete: TMenuItem;
    MenuPopupPaste: TMenuItem;
    MenuPopupSelectAll: TMenuItem;
    MenuPopupSep2: TMenuItem;
    PanelError: TPanel;
    PanelRight: TPanel;
    PanelTop: TPanel;
    PanelClient: TPanel;
    PopupMenuSections: TPopupMenu;
    PopupMenuSynEdit: TPopupMenu;
    ButtonFindError: TSpeedButton;
    SplitterRight: TSplitter;
    SynEdit: TSynEdit;
    ErrorMessage: TSynEdit;
    SynJsfxSyn: TSynAnySyn;
    TimerCodeInsight: TTimer;
    TimerPopupNotifier: TTimer;
    ToolBar: TToolBar;
    ButtonDiv1: TToolButton;
    ButtonDiv2: TToolButton;
    ButtonDiv3: TToolButton;
    TreeView: TTreeView;
    procedure ButtonFindErrorClick(ASender: TObject);
    procedure ButtonSyntaxCheckClick(ASender: TObject);
    procedure EditFuncNamesChange(ASender: TObject);
    procedure EditFuncNamesDrawItem(AWinControl: TWinControl; AIndex: Integer;
      ARect: TRect; ADrawState: TOwnerDrawState);
    procedure EditFuncNamesKeyDown(ASender: TObject; var AKey: word; AShiftState: TShiftState);
    procedure EditTreeFolderChange(ASender: TObject);
    procedure EditTreeFolderDrawItem(AWinControl: TWinControl; AIndex: Integer;
      ARect: TRect; ADrawState: TOwnerDrawState);
    procedure EditVariNamesDrawItem(AWinControl: TWinControl; AIndex: Integer;
      ARect: TRect; ADrawState: TOwnerDrawState);
    procedure ErrorMessageMouseDown(ASender: TObject; AButton: TMouseButton;
      AShift: TShiftState; AX, AY: Integer);
    procedure MenuPopupCopyClick(ASender: TObject);
    procedure MenuPopupCutClick(ASender: TObject);
    procedure MenuPopupDeleteClick(ASender: TObject);
    procedure MenuPopupSearchForFunctionClick(ASender: TObject);
    procedure MenuPopupSearchForVariableClick(ASender: TObject);
    procedure MenuPopupOpenImportClick(ASender: TObject);
    procedure MenuPopupPasteClick(ASender: TObject);
    procedure MenuPopupPropertiesClick(ASender: TObject);
    procedure MenuPopupRedoClick(ASender: TObject);
    procedure MenuPopupSelectAllClick(ASender: TObject);
    procedure MenuPopupUndoClick(ASender: TObject);
    procedure PanelRightResize(ASender: TObject);
    procedure PopupMenuSectionsPopup(ASender: TObject);
    procedure PopupMenuSynEditPopup(ASender: TObject);
    procedure SynEditChange(ASender: TObject);
    procedure SynEditMouseDown(ASender: TObject; AMouseButton: TMouseButton;
      AShiftState: TShiftState; AX, AY: Integer);
    procedure SynEditMouseLeave(ASender: TObject);
    procedure SynEditMouseMove(ASender: TObject; AShiftState: TShiftState; AX, AY: Integer);
    procedure SynEditMouseWheel(ASender: TObject; AShiftState: TShiftState;
      AWheelDelta: Integer; AMousePos: TPoint; var AHandled: Boolean);
    procedure SynEditSpecialLineMarkup(ASender: TObject; ALine: Integer;
      var ASpecial: Boolean; AMarkup: TSynSelectedColor);
    procedure SynEditStatusChange(ASender: TObject; AStatusChanges: TSynStatusChanges);
    procedure TimerPopupNotifierTimer(ASender: TObject);
    procedure TimerCodeInsightTimer(ASender: TObject);
    procedure ButtonSectionPrevClick(ASender: TObject);
    procedure ButtonSectionNextClick(ASender: TObject);
    procedure TreeViewAddition(ASender: TObject; ATreeNode: TTreeNode);
    procedure TreeViewCustomDrawItem(ASender: TCustomTreeView; ATreeNode: TTreeNode;
      ADrawState: TCustomDrawState; var ADefaultDraw: Boolean);
    procedure TreeViewDeletion(ASender: TObject; ATreeNode: TTreeNode);
    procedure TreeViewKeyPress(ASender: TObject; var AKey: Char);
    procedure TreeViewMouseMove(ASender: TObject; AShiftState: TShiftState; AX, AY: Integer);
    procedure TreeViewSelectionChanged(ASender: TObject);
  strict private
    FMousePoint: TPoint;
    FFileName: TFileName;
    FCodeInsightCount: Integer;
    FStringsHash, FStringsNamed, FStringsLiteral, FVariablesSample, FVariablesSlider,
    FVariablesExternal, FVariablesInternal, FFunctionsSystem, FFunctionsUser: TTreeNode;
    FPrevTreeNode: TTreeNode;
  strict private
    function CreateFunction(const AFunction: CJes2CppFunction): TTreeNode;
    function CreateIdentifier(const AParent: TTreeNode;
      const AIdentifier: CJes2CppIdentifier): TTreeNode;
    function CreateVariable(const AVariable: CJes2CppVariable): TTreeNode;
  strict private
    function FindTreeNodeFunction(const AParent: TTreeNode; AIdent: TIdentString;
      out AFoundAs: TIdentString): TTreeNode; overload;
    function FindTreeNodeFunction(const AName: String; out AFoundAs: String): TTreeNode; overload;
    function FindTreeNodeVariable(const AName: String): TTreeNode;
    function FolderCreate(const AName: String; const AImageIndex: Integer): TTreeNode;
    function GetTabSheet: TTabSheet;
  strict private
    procedure CreateReferences(const AParent: TTreeNode; const AIdentifier: CJes2CppIdentifier);
    procedure FoldersAlphaSort;
    procedure JumpToReferenceNode(const ATreeNode: TTreeNode; const ADontChangeFileName: Boolean);
    procedure SetFileName(const AFileName: TFileName);
  public
    constructor Create(const AOwner: TTabSheet); reintroduce;
  public
    procedure ApplyColors;
    procedure UpdatePopupMenuStates;
    procedure LoadFromUntitled(const AFileName: String);
    procedure LoadFromFile(const AFileName: TFileName);
    procedure SaveToFile(const AFileName: TFileName); overload;
    procedure SaveToFile; overload;
    function GetFileNamePlugin: TFileName;
    function IsFileNameInclude: Boolean;
    procedure ShowToolOptions;
    procedure RestartCodeInsight(const ARestart: Boolean);
    procedure HidePopupNotifier;
    procedure SetFocus; override;
  public
    property FileName: TFileName read FFileName;
  end;

implementation

{$R *.lfm}

uses UJeezData, UJeezIde, UJeezMessages, UJeezOptions, UJeezProperties;

constructor TJeezEditor.Create(const AOwner: TTabSheet);
begin
  inherited Create(AOwner);

  GPlatform.ScrollingWinControlPrepare(Self);
  GJeezSynAnySyn.Setup(SynJsfxSyn);

  ErrorMessage.LineHighlightColor.Background := ErrorMessage.Color;

  FVariablesInternal := FolderCreate('Variables (User)', GiImageIndexVariablesUser);
  FVariablesExternal := FolderCreate('Variables (System)', GiImageIndexVariablesSystem);
  FFunctionsUser := FolderCreate('Functions (User)', GiImageIndexFunctionsUser);
  FFunctionsSystem := FolderCreate('Functions (System)', GiImageIndexFunctionsSystem);
  FVariablesSlider := FolderCreate('Sliders (slider1..64)', GiImageIndexSliders);
  FVariablesSample := FolderCreate('Samples (spl0..63)', GiImageIndexSamples);
  FStringsLiteral := FolderCreate('Literal Strings ("")', GiImageIndexStringLiteral);
  FStringsHash := FolderCreate('Hash Strings (#)', GiImageIndexStringTemp);
  FStringsNamed := FolderCreate('Named Strings (#name)', GiImageIndexStringNamed);

  GJeezTreeNode.MakeSelected(FVariablesInternal);

  ApplyColors;

  EditFuncNames.Text := SMsgParsingDotDotDot;
  EditVariNames.Text := SMsgParsingDotDotDot;
end;

function TJeezEditor.GetFileNamePlugin: TFileName;
begin
  Result := IncludeTrailingPathDelimiter(GStrings.GetValue(SynEdit.Lines,
    GsInstallPath, JeezOptions.EditDefVstPath.Directory, True)) +
    CJes2CppCompiler.FileNameOutputDll(ExtractFilename(FFileName),
    JeezOptions.GetArchitecture, JeezOptions.GetPrecision, JeezOptions.GetPluginType);
end;

function TJeezEditor.IsFileNameInclude: Boolean;
begin
  Result := SameText(ExtractFileExt(FFileName), GsFileExtJsFxInc);
end;

procedure TJeezEditor.ApplyColors;
begin
  JeezOptions.ApplyComboBox(EditTreeFolder, JeezOptions.ColorInfoBlocks.Selected);
  JeezOptions.ApplyComboBox(EditFuncNames, JeezOptions.ColorInfoBlocks.Selected);
  JeezOptions.ApplyComboBox(EditVariNames, JeezOptions.ColorInfoBlocks.Selected);
  JeezOptions.ApplyControl(TreeView, JeezOptions.ColorInfoBlocks.Selected);
  JeezOptions.ApplySynEdit(SynEdit, JeezOptions.ColorBackground.Selected);
  JeezOptions.ApplySynEdit(ErrorMessage, JeezOptions.ColorBackground.Selected);
  JeezOptions.ApplySynAnySyn(SynJsfxSyn, False);
  TreeView.Invalidate;
end;

function TJeezEditor.FindTreeNodeVariable(const AName: String): TTreeNode;
begin
  Result := GJeezTreeNode.FindByName(FVariablesInternal, AName);
  if not Assigned(Result) then
  begin
    Result := GJeezTreeNode.FindByName(FVariablesExternal, AName);
    if not Assigned(Result) then
    begin
      Result := GJeezTreeNode.FindByName(FVariablesSlider, AName);
      if not Assigned(Result) then
      begin
        Result := GJeezTreeNode.FindByName(FVariablesSample, AName);
      end;
    end;
  end;
end;

function TJeezEditor.FindTreeNodeFunction(const AParent: TTreeNode;
  AIdent: TIdentString; out AFoundAs: TIdentString): TTreeNode;
var
  LPos: Integer;
begin
  repeat
    Result := GJeezTreeNode.FindByName(AParent, AIdent);
    if Assigned(Result) then
    begin
      AFoundAs := AIdent;
      Break;
    end;
    LPos := Pos(CharDot, AIdent);
    if LPos = ZeroValue then
    begin
      Break;
    end;
    AIdent := Copy(AIdent, LPos + 1, MaxInt);
  until False;
end;

function TJeezEditor.FindTreeNodeFunction(const AName: String; out AFoundAs: String): TTreeNode;
begin
  Result := FindTreeNodeFunction(FFunctionsUser, AName, AFoundAs);
  if not Assigned(Result) then
  begin
    Result := FindTreeNodeFunction(FFunctionsSystem, AName, AFoundAs);
  end;
end;

function TJeezEditor.FolderCreate(const AName: String; const AImageIndex: Integer): TTreeNode;
begin
  Result := TreeView.Items.AddChild(nil, AName);
  Result.ImageIndex := AImageIndex;
  Result.SelectedIndex := AImageIndex;
  EditTreeFolder.Items.AddObject(AName, Result);
end;

procedure TJeezEditor.FoldersAlphaSort;
var
  LTreeNode: TTreeNode;
begin
  if TreeView.Items.Count > ZeroValue then
  begin
    LTreeNode := TreeView.Items[ZeroValue];
    repeat
      if (LTreeNode <> FVariablesSlider) and (LTreeNode <> FVariablesSample) then
      begin
        LTreeNode.AlphaSort;
      end;
      LTreeNode := LTreeNode.GetNextSibling;
    until not Assigned(LTreeNode);
  end;
end;

procedure TJeezEditor.SynEditStatusChange(ASender: TObject; AStatusChanges: TSynStatusChanges);
begin
  if (scCaretX in AStatusChanges) or (scCaretY in AStatusChanges) then
  begin
    if FCodeInsightCount > ZeroValue then
    begin
      RestartCodeInsight(False);
    end;
  end;
  if (scCaretX in AStatusChanges) or (scCaretY in AStatusChanges) or
    (scModified in AStatusChanges) then
  begin
    JeezIde.UpdateTabSheet(GetTabSheet);
  end;
end;

procedure TJeezEditor.TimerPopupNotifierTimer(ASender: TObject);
var
  LPoint: TPoint;
  LString, LFunctName: String;
  LIsFunction: Boolean;
  LTreeNode: TTreeNode;
begin
  TimerPopupNotifier.Enabled := False;
  LPoint := SynEdit.PixelsToRowColumn(FMousePoint);
  if GIdentString.Extract(SynEdit.Lines[LPoint.Y - 1], LPoint.X - 1, LString, LIsFunction) then
  begin
    if LIsFunction then
    begin
      LTreeNode := FindTreeNodeFunction(LString, LFunctName);
    end else begin
      LTreeNode := FindTreeNodeVariable(LString);
    end;
    if Assigned(LTreeNode) then
    begin
      JeezIde.ShowPopupNotifier(CJes2CppTreeNodeData(LTreeNode.Data).Name,
        CJes2CppTreeNodeData(LTreeNode.Data).Comment);
    end;
  end;
end;

function TJeezEditor.CreateIdentifier(const AParent: TTreeNode;
  const AIdentifier: CJes2CppIdentifier): TTreeNode;
var
  LName, LText: String;
begin
  if AIdentifier is CJes2CppFunction then
  begin
    LText := CJes2CppFunction(AIdentifier).EelPrototype;
    LName := AIdentifier.Name;
  end else begin
    LText := GIdentString.Clean(AIdentifier.Name);
    LName := LText;
  end;
  Result := GJeezTreeNode.FindOrCreate(AParent, LName, LText);
  CJes2CppTreeNodeData(Result.Data).Comment := AIdentifier.Comment;
end;

function TJeezEditor.CreateVariable(const AVariable: CJes2CppVariable): TTreeNode;
var
  LDummy: Integer;
begin
  if AVariable.IsSystem then
  begin
    if GIdentString.IsSlider(AVariable.Name, LDummy) then
    begin
      Result := CreateIdentifier(FVariablesSlider, AVariable);
    end else if GIdentString.IsSample(AVariable.Name, LDummy) then
    begin
      Result := CreateIdentifier(FVariablesSample, AVariable);
    end else begin
      Result := CreateIdentifier(FVariablesExternal, AVariable);
    end;
  end else begin
    if AVariable.DataType = vdtStringNamed then
    begin
      Result := CreateIdentifier(FStringsNamed, AVariable);
    end else if AVariable.DataType = vdtStringLiteral then
    begin
      Result := GJeezTreeNode.FindOrCreate(FStringsLiteral, AVariable.StringLiteral,
        AVariable.StringLiteral);
    end else if AVariable.DataType = vdtStringHash then
    begin
      Result := CreateIdentifier(FStringsHash, AVariable);
    end else begin
      Result := CreateIdentifier(FVariablesInternal, AVariable);
    end;
  end;
  CreateReferences(Result, AVariable);
end;

function TJeezEditor.CreateFunction(const AFunction: CJes2CppFunction): TTreeNode;
begin
  if AFunction.IsSystem then
  begin
    Result := CreateIdentifier(FFunctionsSystem, AFunction);
  end else begin
    Result := CreateIdentifier(FFunctionsUser, AFunction);
  end;
  CreateReferences(Result, AFunction);
end;

procedure TJeezEditor.CreateReferences(const AParent: TTreeNode;
  const AIdentifier: CJes2CppIdentifier);
var
  LReference: CJes2CppReference;
  LTreeNode: TTreeNode;
begin
  for LReference in AIdentifier.References do
  begin
    LTreeNode := GJeezTreeNode.FindOrCreate(AParent, LReference.EncodeLineFilePath,
      LReference.EncodeLineFilePath);
    if SameFileName(FFileName, LReference.FileSource) then
    begin
      LTreeNode.ImageIndex := GiImageIndexRefInternal;
    end else begin
      LTreeNode.ImageIndex := GiImageIndexRefExternal;
    end;
    LTreeNode.SelectedIndex := LTreeNode.ImageIndex;
  end;
end;

procedure TJeezEditor.TimerCodeInsightTimer(ASender: TObject);
var
  LTimer: DWord;
  LVariable: CJes2CppVariable;
  LFunction: CJes2CppFunction;
  LTreeNode: TTreeNode;
  LFuncNamesText, LVariNamesText: String;
begin
  Inc(FCodeInsightCount);
  TimerCodeInsight.Enabled := False;
  EditFuncNames.DroppedDown := False;
  LFuncNamesText := EditFuncNames.Text;
  EditFuncNames.Clear;
  EditVariNames.DroppedDown := False;
  LVariNamesText := EditVariNames.Text;
  EditVariNames.Clear;
  EditFuncNames.Text := SMsgParsingDotDotDot;
  EditVariNames.Text := SMsgParsingDotDotDot;
  TreeView.BeginUpdate;
  try
    GJeezTreeNodes.MarkNonRootsForCutting(TreeView.Items);
    try
      with CJeezJes2Cpp.Create(Self) do
      begin
        try
          IsNoOutput := True;
          LTimer := GetTickCount;
          TranspileScript(SynEdit.Lines, FFileName);
          LTimer := GetTickCount - LTimer;
          //JeezConsole.LogMessage('Timer: ' + IntToStr(LTimer));
          PanelError.Visible := False;
          for LFunction in Functions do
          begin
            EditFuncNames.Items.AddObject(LFunction.EelPrototype, CreateFunction(LFunction));
          end;
          for LVariable in Variables do
          begin
            LTreeNode := CreateVariable(LVariable);
            if not (LVariable.DataType in [vdtStringHash, vdtStringLiteral]) then
            begin
              EditVariNames.Items.AddObject(LVariable.EncodeEel, LTreeNode);
            end;
          end;
          if (LFuncNamesText = EmptyStr) or (LFuncNamesText = SMsgParsingDotDotDot) or
            (LFuncNamesText = SMsgSyntaxError) then
          begin
            EditFuncNames.Text := Format(SMsgCountFunctions1, [EditFuncNames.Items.Count]);
          end else begin
            EditFuncNames.Text := LFuncNamesText;
          end;
          if (LVariNamesText = EmptyStr) or (LVariNamesText = SMsgParsingDotDotDot) or
            (LVariNamesText = SMsgSyntaxError) then
          begin
            EditVariNames.Text := Format(SMsgCountVariables1, [EditVariNames.Items.Count]);
          end else begin
            EditVariNames.Text := LVariNamesText;
          end;
          // We only need to add the system variables and functions to the syntax highligher once.
          if SynJsfxSyn.Objects.Count = ZeroValue then
          begin
            for LFunction in Functions do
            begin
              if LFunction.IsSystem then
              begin
                SynJsfxSyn.Objects.Add(UpperCase(LFunction.Name));
              end;
            end;
            for LVariable in Variables do
            begin
              if LVariable.IsSystem then
              begin
                SynJsfxSyn.Constants.Add(UpperCase(GIdentString.Clean(LVariable.Name)));
              end;
            end;
            SynEdit.Invalidate;
          end;
        finally
          Free;
        end;
      end;
      GJeezTreeNodes.DeleteCuts(TreeView.Items);
      FoldersAlphaSort;
    except
      on LException: Exception do
      begin
        EditFuncNames.Text := SMsgSyntaxError;
        EditVariNames.Text := SMsgSyntaxError;
        ErrorMessage.Caption := LException.Message;
        ErrorMessage.Highlighter := JeezConsole.SynAnySyn;
        PanelError.Visible := True;
        SynEdit.EnsureCursorPosVisible;
      end;
    end;
  finally
    TreeView.EndUpdate;
  end;
end;

procedure TJeezEditor.ButtonSectionPrevClick(ASender: TObject);
begin
  GJeezSynEdit.SectionPrev(SynEdit);
end;

procedure TJeezEditor.ButtonSectionNextClick(ASender: TObject);
begin
  GJeezSynEdit.SectionNext(SynEdit);
end;

procedure TJeezEditor.PopupMenuSectionsPopup(ASender: TObject);
var
  LIndex: Integer;
  LMenuItem: TMenuItem;
begin
  if ASender is TMenuItem then
  begin
    GJeezSynEdit.SetCaretYCentered(SynEdit, (ASender as TMenuItem).Tag + 1);
  end else if ASender = PopupMenuSections then
  begin
    PopupMenuSections.Items.Clear;
    for LIndex := ZeroValue to SynEdit.Lines.Count - 1 do
    begin
      if GEelSectionHeader.IsMaybeSection(SynEdit.Lines[LIndex]) then
      begin
        LMenuItem := TMenuItem.Create(PopupMenuSections);
        LMenuItem.Caption := Trim(SynEdit.Lines[LIndex]);
        LMenuItem.Tag := LIndex;
        LMenuItem.OnClick := PopupMenuSectionsPopup;
        PopupMenuSections.Items.Add(LMenuItem);
      end;
    end;
  end;
end;

procedure TJeezEditor.MenuPopupSearchForVariableClick(ASender: TObject);
var
  LTreeNode: TTreeNode;
begin
  LTreeNode := FindTreeNodeVariable((ASender as TMenuItem).Hint);
  if Assigned(LTreeNode) then
  begin
    TreeView.Selected := nil;
    if LTreeNode.HasChildren then
    begin
      GJeezTreeNode.MakeSelected(LTreeNode.GetFirstChild);
    end else begin
      GJeezTreeNode.MakeSelected(LTreeNode);
    end;
  end else begin
    JeezConsole.LogMessage(Format(SMsgUnableToFindVariable1, [(ASender as TMenuItem).Hint]));
  end;
end;

procedure TJeezEditor.MenuPopupSearchForFunctionClick(ASender: TObject);
var
  LTreeNode: TTreeNode;
  LFunctName: String;
begin
  LTreeNode := FindTreeNodeFunction((ASender as TMenuItem).Hint, LFunctName);
  if Assigned(LTreeNode) then
  begin
    TreeView.Selected := nil;
    if LTreeNode.HasChildren then
    begin
      GJeezTreeNode.MakeSelected(LTreeNode.GetFirstChild);
    end else begin
      GJeezTreeNode.MakeSelected(LTreeNode);
    end;
  end else begin
    JeezConsole.LogMessage(Format(SMsgUnableToFindFunction1, [(ASender as TMenuItem).Hint]));
  end;
end;

procedure TJeezEditor.MenuPopupOpenImportClick(ASender: TObject);
var
  LFileName: TFileName;
begin
  PopupMenuSynEdit.OnPopup(PopupMenuSynEdit);
  if MenuPopupOpenImport.Visible then
  begin
    LFileName := MenuPopupOpenImport.Hint;
    GEel.ImportResolve(LFileName, FFileName);
    JeezConsole.LogFileExists(LFileName);
    JeezIde.LoadFromFile(LFileName);
  end else begin
    JeezIde.MenuFileOpen.Click;
  end;
end;

procedure TJeezEditor.UpdatePopupMenuStates;
begin
  MenuPopupUndo.Enabled := SynEdit.CanUndo;
  MenuPopupRedo.Enabled := SynEdit.CanRedo;
  MenuPopupCut.Enabled := SynEdit.SelAvail;
  MenuPopupCopy.Enabled := SynEdit.SelAvail;
  MenuPopupPaste.Enabled := SynEdit.CanPaste;
  MenuPopupDelete.Enabled := SynEdit.SelAvail;
end;

procedure TJeezEditor.PopupMenuSynEditPopup(ASender: TObject);
var
  LString, LFunctName: String;
  LFileName: TFileName;
  LIdIdent, LIsFunction: Boolean;
begin
  HidePopupNotifier;
  MenuPopupSearchForVariable.Visible := False;
  MenuPopupSearchForFunction.Visible := False;

  LIdIdent := GIdentString.Extract(SynEdit.LineText, SynEdit.CaretX, LString, LIsFunction);

  if LIdIdent and LIsFunction then
  begin
    if (LString <> EmptyStr) and Assigned(FindTreeNodeFunction(LString, LFunctName)) then
    begin
      MenuPopupSearchForFunction.Hint := LFunctName;
      MenuPopupSearchForFunction.Caption := 'Search for function ' + QuotedStr(LFunctName);
      MenuPopupSearchForFunction.Visible := True;
    end;
  end;
  if LIdIdent and not LIsFunction and Assigned(FindTreeNodeVariable(LString)) then
  begin
    MenuPopupSearchForVariable.Hint := LString;
    MenuPopupSearchForVariable.Caption := 'Search for variable ' + QuotedStr(LString);
    MenuPopupSearchForVariable.Visible := True;
  end;
  MenuPopupOpenImport.Visible := GEel.IsImport(SynEdit.LineText, LFileName);
  MenuPopupOpenImport.Hint := LFileName;
  MenuPopupOpenImportSep.Visible :=
    MenuPopupOpenImport.Visible or MenuPopupSearchForFunction.Visible or
    MenuPopupSearchForVariable.Visible;
  if MenuPopupOpenImport.Visible then
  begin
    MenuPopupOpenImport.Caption := GsOpen + CharSpace + QuotedStr(LFileName);
  end;
  UpdatePopupMenuStates;
end;

procedure TJeezEditor.TreeViewAddition(ASender: TObject; ATreeNode: TTreeNode);
begin
  ATreeNode.Data := CJes2CppTreeNodeData.Create;
  GJeezTreeNode.UpdateCount(ATreeNode);
end;

procedure TJeezEditor.TreeViewDeletion(ASender: TObject; ATreeNode: TTreeNode);
begin
  GJeezTreeNode.UpdateCount(ATreeNode);
  if Assigned(ATreeNode.Data) then
  begin
    TObject(ATreeNode.Data).Free;
    ATreeNode.Data := nil;
  end;
end;

procedure TJeezEditor.TreeViewKeyPress(ASender: TObject; var AKey: Char);
begin
  GJeezTreeView.HandleKeyPress(TreeView, AKey);
end;

procedure TJeezEditor.TreeViewCustomDrawItem(ASender: TCustomTreeView;
  ATreeNode: TTreeNode; ADrawState: TCustomDrawState; var ADefaultDraw: Boolean);
begin
  GJeezTreeNode.Draw(ATreeNode, JeezOptions.ColorFunctions.Selected,
    JeezOptions.ColorVariables.Selected, JeezOptions.ColorIdentifiers.Selected,
    JeezOptions.ColorSymbols.Selected);
  ADefaultDraw := False;
end;

procedure TJeezEditor.TreeViewMouseMove(ASender: TObject; AShiftState: TShiftState;
  AX, AY: Integer);
var
  LTreeNode: TTreeNode;
begin
  LTreeNode := TreeView.GetNodeAt(AX, AY);
  if Assigned(LTreeNode) then
  begin
    TreeView.Hint := CJes2CppTreeNodeData(LTreeNode.Data).Comment;
    if TreeView.Hint <> EmptyStr then
    begin
      TreeView.Cursor := crHelp;
      if FPrevTreeNode <> LTreeNode then
      begin
        FPrevTreeNode := LTreeNode;
        Application.ActivateHint(Mouse.CursorPos);
      end;
    end else if LTreeNode.ImageIndex = GiImageIndexRefExternal then
    begin
      TreeView.Cursor := crHandPoint;
    end else begin
      TreeView.Cursor := crArrow;
    end;
  end else begin
    TreeView.Cursor := crDefault;
  end;
end;

procedure TJeezEditor.JumpToReferenceNode(const ATreeNode: TTreeNode;
  const ADontChangeFileName: Boolean);
var
  LText: String;
  LFileSource: TFileName;
  LEditor: TJeezEditor;
  LTreeNode: TTreeNode;
begin
  LText := ATreeNode.Text;
  // This will raise exception if node is not a reference node.
  LFileSource := GUtils.ExtractFileSource(LText);
  // Abort if reference is another file and we dont want to change editors.
  if ADontChangeFileName and not SameFileName(LFileSource, FFileName) then
  begin
    Abort;
  end;
  // Load the source into editor.
  LEditor := JeezIde.LoadFromFile(LFileSource, GUtils.ExtractFileCaretY(LText));
  // Have we opened a new editor?
  if LEditor <> Self then
  begin
    // We need a completed insight in order to find the node in the new editor.
    LEditor.TimerCodeInsightTimer(LEditor.TimerCodeInsight);
    Assert(Assigned(ATreeNode.Parent));
    // Try to find the node in the new editor which matches the reference node.
    LTreeNode := GJeezTreeNodes.FindByName(LEditor.TreeView.Items,
      CJes2CppTreeNodeData(ATreeNode.Parent.Data).Name);
    if Assigned(LTreeNode) then
    begin
      // NOTE: Jumping to ref causes a double jump is dest is also a extern ref.
      // If node has children, then jump to the first. (It should be the first reference node)
      if LTreeNode.HasChildren then
      begin
        GJeezTreeNode.MakeSelected(LTreeNode.GetFirstChild);
      end else begin
        // This should never be called because a node would not exist unless it had at least one reference.
        Beep;
        GJeezTreeNode.MakeSelected(LTreeNode);
      end;
    end;
    try
      LEditor.TreeView.SetFocus;
    except
    end;
  end;
end;

procedure TJeezEditor.TreeViewSelectionChanged(ASender: TObject);
var
  LTreeNode: TTreeNode;
begin
  if Assigned(TreeView.Selected) then
  begin
    // Ensure the node is visible. Node may of been selected via code.
    TreeView.Selected.MakeVisible;
    // Set the tree folder item to the root of selected node.
    EditTreeFolder.ItemIndex := TreeView.Selected.GetParentNodeOfAbsoluteLevel(0).Index;
    try
      // Try to jump to this node. This will fail if a non-reference node is selected.
      JumpToReferenceNode(TreeView.Selected, False);
    except
      try
        // If this node has children, then try to jump to the first internal ref. Again, this
        // will fail if the child is not a reference node. We dont open a new editor
        // in this jump.
        LTreeNode := TreeView.Selected.GetFirstChild;
        while Assigned(LTreeNode) do
        begin
          if LTreeNode.ImageIndex = GiImageIndexRefInternal then
          begin
            JumpToReferenceNode(LTreeNode, True);
            Break;
          end;
          LTreeNode := LTreeNode.GetNextSibling;
        end;
      except
      end;
    end;
  end;
end;

procedure TJeezEditor.MenuPopupCutClick(ASender: TObject);
begin
  SynEdit.CutToClipboard;
end;

procedure TJeezEditor.MenuPopupDeleteClick(ASender: TObject);
begin
  SynEdit.ClearSelection;
end;

procedure TJeezEditor.MenuPopupPasteClick(ASender: TObject);
begin
  SynEdit.PasteFromClipboard;
end;

procedure TJeezEditor.MenuPopupPropertiesClick(ASender: TObject);
begin
  if JeezProperties.Execute(SynEdit.Lines) then
  begin
    SynEdit.Modified := True;
  end;
end;

procedure TJeezEditor.MenuPopupRedoClick(ASender: TObject);
begin
  SynEdit.Redo;
  // Undo/Redo sometimes does not register a change?
  SynEdit.OnChange(SynEdit);
end;

procedure TJeezEditor.MenuPopupSelectAllClick(ASender: TObject);
begin
  SynEdit.SelectAll;
end;

procedure TJeezEditor.MenuPopupUndoClick(ASender: TObject);
begin
  SynEdit.Undo;
  // Undo/Redo sometimes does not register a change?
  SynEdit.OnChange(SynEdit);
end;

procedure TJeezEditor.PanelRightResize(ASender: TObject);
begin
  // TODO: Can we improve this?
  EditTreeFolder.Width := PanelRight.Width - 6;
end;

procedure TJeezEditor.SynEditChange(ASender: TObject);
begin
  HidePopupNotifier;
  RestartCodeInsight(True);
end;

procedure TJeezEditor.SynEditMouseDown(ASender: TObject; AMouseButton: TMouseButton;
  AShiftState: TShiftState; AX, AY: Integer);
begin
  HidePopupNotifier;
end;

procedure TJeezEditor.SynEditMouseLeave(ASender: TObject);
begin
  TimerPopupNotifier.Enabled := False;
end;

procedure TJeezEditor.SynEditMouseMove(ASender: TObject; AShiftState: TShiftState;
  AX, AY: Integer);
var
  LDelta: TPoint;
begin
  LDelta.X := AX - FMousePoint.X;
  LDelta.Y := AY - FMousePoint.Y;
  if (not JeezIde.PopupNotifier.Visible and (Abs(LDelta.X) * Abs(LDelta.Y) > 20)) or
    (LDelta.X > 330) or (LDelta.X < -10) or (LDelta.Y < -20) or (LDelta.Y > 130) then
  begin
    FMousePoint := Point(AX, AY);
    HidePopupNotifier;
    TimerPopupNotifier.Enabled := PanelRight.Visible;
  end;
end;

procedure TJeezEditor.SynEditMouseWheel(ASender: TObject; AShiftState: TShiftState;
  AWheelDelta: Integer; AMousePos: TPoint; var AHandled: Boolean);
begin
  AHandled := ssCtrl in AShiftState;
  if AHandled then
  begin
    JeezOptions.EditFontSize.Value := JeezOptions.EditFontSize.Value + Sign(AWheelDelta);
    JeezIde.UpdateAllEditors;
  end;
end;

procedure TJeezEditor.SynEditSpecialLineMarkup(ASender: TObject; ALine: Integer;
  var ASpecial: Boolean; AMarkup: TSynSelectedColor);
var
  LString: String;
begin
  LString := SynEdit.Lines[ALine - 1];
  ASpecial := GEelSectionHeader.IsMaybeSection(LString) or
    AnsiStartsText(GsEelDescDesc + CharColon, LString);
  if ASpecial then
  begin
    AMarkup.Foreground := JeezOptions.ColorKeywords.Selected;
    if SynEdit.CaretY = ALine then
    begin
      AMarkup.Background := SynEdit.LineHighlightColor.Background;
    end else begin
      AMarkup.Background := JeezOptions.ColorBackground.Selected;
    end;
    AMarkup.FrameColor := JeezOptions.ColorComments.Selected;
    AMarkup.FrameEdges := sfeBottom;
    AMarkup.FrameStyle := slsDashed;
  end;
end;

procedure TJeezEditor.MenuPopupCopyClick(ASender: TObject);
begin
  SynEdit.CopyToClipboard;
end;

procedure TJeezEditor.EditTreeFolderChange(ASender: TObject);
begin
  if EditTreeFolder.ItemIndex >= ZeroValue then
  begin
    GJeezTreeNode.MakeSelected(EditTreeFolder.Items.Objects[EditTreeFolder.ItemIndex] as
      TTreeNode);
  end;
end;

// NOTE: Both EditFuncNames & EditVariNames are linked to this event, so we must handle both.
procedure TJeezEditor.EditFuncNamesChange(ASender: TObject);
var
  LComboBox: TComboBox;
begin
  LComboBox := ASender as TComboBox;
  if LComboBox.ItemIndex >= ZeroValue then
  begin
    if Assigned(TreeView.Selected) then
    begin
      TreeView.Selected.Collapse(False);
    end;
    GJeezTreeNode.MakeSelected(LComboBox.Items.Objects[LComboBox.ItemIndex] as TTreeNode);
  end;
end;

// NOTE: Both EditFuncNames & EditVariNames are linked to this event, so we must handle both.
procedure TJeezEditor.EditFuncNamesKeyDown(ASender: TObject; var AKey: word;
  AShiftState: TShiftState);
var
  LIndex: Integer;
  LTreeNode: TTreeNode;
  LComboBox: TComboBox;
begin
  LComboBox := ASender as TComboBox;
  if AKey in [VK_UP, VK_DOWN] then
  begin
    if not LComboBox.DroppedDown then
    begin
      AKey := VK_UNKNOWN;
      LComboBox.DroppedDown := True;
    end;
  end else if AKey = VK_RETURN then
  begin
    AKey := VK_UNKNOWN;
    LIndex := LComboBox.Items.IndexOf(LComboBox.Text);
    if LIndex < ZeroValue then
    begin
      if LComboBox = EditFuncNames then
      begin
        JeezConsole.LogException(Format(SMsgUnableToFindFunction1, [LComboBox.Text]));
      end else begin
        JeezConsole.LogException(Format(SMsgUnableToFindVariable1, [LComboBox.Text]));
      end;
    end else begin
      LTreeNode := LComboBox.Items.Objects[LIndex] as TTreeNode;
      if Assigned(LTreeNode) and LTreeNode.HasChildren then
      begin
        GJeezTreeNode.MakeSelected(LTreeNode.GetFirstChild);
      end;
    end;
  end;
end;

// TComboBox custom drawing. These 3 could be one callback, but that can be confusing at times.

procedure TJeezEditor.EditTreeFolderDrawItem(AWinControl: TWinControl;
  AIndex: Integer; ARect: TRect; ADrawState: TOwnerDrawState);
begin
  GJeezCanvas.DrawComboBoxItem(AWinControl as TComboBox, AIndex, ARect, ADrawState,
    JeezData.ImageList16);
end;

procedure TJeezEditor.EditVariNamesDrawItem(AWinControl: TWinControl;
  AIndex: Integer; ARect: TRect; ADrawState: TOwnerDrawState);
begin
  GJeezCanvas.DrawComboBoxItem(AWinControl as TComboBox, AIndex, ARect, ADrawState,
    JeezData.ImageList16);
end;

procedure TJeezEditor.EditFuncNamesDrawItem(AWinControl: TWinControl;
  AIndex: Integer; ARect: TRect; ADrawState: TOwnerDrawState);
begin
  GJeezCanvas.DrawComboBoxItem(AWinControl as TComboBox, AIndex, ARect, ADrawState,
    JeezData.ImageList16);
end;

procedure TJeezEditor.ErrorMessageMouseDown(ASender: TObject; AButton: TMouseButton;
  AShift: TShiftState; AX, AY: Integer);
begin
  try
    JeezIde.LoadFromFile(GUtils.ExtractFileSource(ErrorMessage.LineText),
      GUtils.ExtractFileCaretY(ErrorMessage.LineText));
  except
  end;
end;

procedure TJeezEditor.ButtonSyntaxCheckClick(ASender: TObject);
begin
  HidePopupNotifier;
  EditFuncNames.Text := EmptyStr;
  EditVariNames.Text := EmptyStr;
  TimerCodeInsight.Enabled := False;
  try
    JeezConsole.LogFileName(SMsgTypeSyntaxChecking, FFileName);
    with CJeezJes2CppLogMessages.Create(Self) do
    begin
      try
        IsNoOutput := True;
        TranspileScript(SynEdit.Lines, FFileName);
      finally
        Free;
      end;
    end;
    JeezConsole.LogMessage(SMsgSyntaxCheckingCompleteNoErrorsFound +
      ' / Total heap allocated: ' + IntToStr(GetHeapStatus.TotalAllocated) + ' bytes');
  finally
    TimerCodeInsight.Enabled := True;
  end;
end;

procedure TJeezEditor.ButtonFindErrorClick(ASender: TObject);
begin
  ButtonSyntaxCheck.Click;
end;

function TJeezEditor.GetTabSheet: TTabSheet;
begin
  Result := Owner as TTabSheet;
  Assert(Assigned(Result));
end;

procedure TJeezEditor.SetFileName(const AFileName: TFileName);
begin
  FFileName := AFileName;
  SynEdit.Highlighter := JeezData.GetHighlighterFromFileName(AFileName, SynJsfxSyn);
  PanelRight.Visible := SynEdit.Highlighter = SynJsfxSyn;
  PanelTop.Visible := PanelRight.Visible;
  SplitterRight.Visible := PanelRight.Visible;
  JeezIde.UpdateTabSheet(GetTabSheet);
end;

procedure TJeezEditor.LoadFromFile(const AFileName: TFileName);
begin
  JeezConsole.LogTextFileExists(AFileName);
  SynEdit.Lines.Assign(GFileCache.LoadFromFile(AFileName));
  SetFileName(AFileName);
  JeezConsole.LogFileName(SMsgTypeLoaded, AFileName);
  JeezOptions.AddRecentFile(AFileName);
  RestartCodeInsight(True);
end;

procedure TJeezEditor.SaveToFile(const AFileName: TFileName);
begin
  JeezConsole.LogFileNameIsAbsolute(AFileName);
  SynEdit.Lines.SaveToFile(AFileName);
  SynEdit.Modified := False;
  SetFileName(AFileName);
  JeezOptions.AddRecentFile(AFileName);
end;

procedure TJeezEditor.SaveToFile;
begin
  SaveToFile(FFileName);
end;

procedure TJeezEditor.HidePopupNotifier;
begin
  TimerPopupNotifier.Enabled := False;
  JeezIde.HidePopupNotifier;
end;

procedure TJeezEditor.SetFocus;
begin
  inherited SetFocus;
  SynEdit.SetFocus;
end;

procedure TJeezEditor.RestartCodeInsight(const ARestart: Boolean);
begin
  TimerCodeInsight.Enabled := False;
  TimerCodeInsight.Enabled := ARestart and PanelRight.Visible;
end;

procedure TJeezEditor.ShowToolOptions;
begin
  if JeezOptions.Execute then
  begin
    RestartCodeInsight(True);
  end;
end;

procedure TJeezEditor.LoadFromUntitled(const AFileName: String);
var
  LIndex, LCount: Integer;
begin
  GStrings.CreateUntitled(SynEdit.Lines);
  SynEdit.Modified := False;
  LCount := ZeroValue;
  repeat
    Inc(LCount);
    FFileName := ChangeFileExt(AFileName, EmptyStr) + IntToStr(LCount) + ExtractFileExt(AFileName);
    for LIndex := GetTabSheet.PageControl.PageCount - 1 downto ZeroValue do
    begin
      if SameText(GetTabSheet.PageControl.Pages[LIndex].Caption, FFileName) then
      begin
        FFileName := EmptyStr;
        Break;
      end;
    end;
  until FFileName <> EmptyStr;
  SetFileName(FFileName);
end;

end.

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
  Buttons, Classes, ComCtrls, Controls, DateUtils, ExtCtrls, FileUtil, Forms, Graphics, JeezResources, JeezSynEdit,
  JeezTreeView, JeezUtils, Jes2Cpp, Jes2CppCompiler, Jes2CppConstants, Jes2CppEel, Jes2CppFileNames,
  Jes2CppFunction, Jes2CppIdentifier, Jes2CppIdentString, Jes2CppPlatform, Jes2CppReference, Jes2CppStrings,
  Jes2CppUtils, Jes2CppVariable, LCLIntf, LCLType, Menus, StdCtrls, SynEdit, SynEditTypes, SynHighlighterAny, SysUtils, types;

type

  { TJeezEditor }

  TJeezEditor = class(TFrame)
    ButtonProperties: TToolButton;
    ButtonSectionNext: TToolButton;
    ButtonSectionPrev: TToolButton;
    ButtonSectionSelect: TToolButton;
    ButtonSyntaxCheck: TToolButton;
    EditFolder: TComboBox;
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
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    TreeView: TTreeView;
    procedure ButtonFindErrorClick(ASender: TObject);
    procedure ButtonSyntaxCheckClick(ASender: TObject);
    procedure EditFolderChange(ASender: TObject);
    procedure EditFolderDrawItem(AWinControl: TWinControl; AIndex: Integer; ARect: TRect; ADrawState: TOwnerDrawState);
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
    procedure SynEditMouseDown(ASender: TObject; AMouseButton: TMouseButton; AShiftState: TShiftState; AX, AY: Integer);
    procedure SynEditMouseLeave(ASender: TObject);
    procedure SynEditMouseMove(ASender: TObject; AShiftState: TShiftState; AX, AY: Integer);
    procedure SynEditStatusChange(ASender: TObject; AStatusChanges: TSynStatusChanges);
    procedure TimerPopupNotifierTimer(ASender: TObject);
    procedure TimerCodeInsightTimer(ASender: TObject);
    procedure ButtonSectionPrevClick(ASender: TObject);
    procedure ButtonSectionNextClick(ASender: TObject);
    procedure TreeViewAddition(ASender: TObject; ATreeNode: TTreeNode);
    procedure TreeViewCustomDrawItem(ASender: TCustomTreeView; ATreeNode: TTreeNode; ADrawState: TCustomDrawState;
      var ADefaultDraw: Boolean);
    procedure TreeViewDeletion(ASender: TObject; ATreeNode: TTreeNode);
    procedure TreeViewKeyPress(ASender: TObject; var AKey: Char);
    procedure TreeViewMouseMove(ASender: TObject; AShiftState: TShiftState; AX, AY: Integer);
    procedure TreeViewSelectionChanged(ASender: TObject);
  strict private
    FMousePoint: TPoint;
    FFileName: TFileName;
    FStringsTemp, FStringsNamed, FStringsLiteral, FVariablesSample, FVariablesSlider, FVariablesExternal,
    FVariablesInternal, FFunctionsSystem, FFunctionsUser: TTreeNode;
  strict private
    function CreateFunction(const AFunction: CJes2CppFunction): TTreeNode;
    function CreateIdentifier(const AParent: TTreeNode; const AIdentifier: CJes2CppIdentifier): TTreeNode;
    function CreateVariable(const AVariable: CJes2CppVariable): TTreeNode;
  strict private
    function FindTreeNodeFunction(const AName: String; const AStripParams: Boolean): TTreeNode;
    function FindTreeNodeVariable(const AName: String): TTreeNode;
    function FolderCreate(const AName: String; const AImageIndex: Integer): TTreeNode;
    function GetTabSheet: TTabSheet;
  strict private
    procedure CreateReferences(const AParent: TTreeNode; const AIdentifier: CJes2CppIdentifier);
    procedure FoldersAlphaSort;
    procedure FoldersCollapse;
    procedure JumpToReferenceNode(const ATreeNode: TTreeNode; const ANoFileNameChange: Boolean);
    procedure SetFileName(const AFileName: TFileName);
  public
    constructor Create(AOwner: TComponent); override;
  public
    procedure ApplyColors;
    procedure LoadFromUntitled(const AFileName: String);
    procedure LoadFromFile(const AFileName: TFileName);
    procedure SaveToFile(const AFileName: TFileName); overload;
    procedure SaveToFile; overload;
    function GetFileNamePlugin: TFileName;
    function IsFileNameInclude: Boolean;
  public
    property Filename: TFileName read FFileName;
  end;

implementation

{$R *.lfm}

uses UJeezData, UJeezIde, UJeezMessages, UJeezOptions, UJeezProperties;

constructor TJeezEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  if NsPlatform.IsWindows9x then
  begin
    PanelTop.ParentColor := False;
    PanelTop.Color := clBtnFace;
  end;

  NsPlatform.ScrollingWinControlPrepare(Self);
  NsSynEdit.SynJsFxInit(SynJsfxSyn);

  ErrorMessage.LineHighlightColor.Background := ErrorMessage.Color;

  FVariablesInternal := FolderCreate('Variables (User)', GiImageIndexVariablesUser);
  FFunctionsUser := FolderCreate('Functions (User)', GiImageIndexFunctionsUser);
  FVariablesExternal := FolderCreate('Variables (System)', GiImageIndexVariablesSystem);
  FFunctionsSystem := FolderCreate('Functions (System)', GiImageIndexFunctionsSystem);
  FVariablesSlider := FolderCreate('Slider Variables', GiImageIndexVariablesSystem);
  FVariablesSample := FolderCreate('Sample Variables', GiImageIndexVariablesSystem);
  FStringsLiteral := FolderCreate('Literal Strings', GiImageIndexString);
  FStringsNamed := FolderCreate('Named Strings', GiImageIndexString);
  FStringsTemp := FolderCreate('Temporary Strings', GiImageIndexString);
  TreeView.Selected := FVariablesInternal;

  ApplyColors;
end;

function TJeezEditor.GetFileNamePlugin: TFileName;
begin
  Result := IncludeTrailingPathDelimiter(J2C_StringsGetValue(SynEdit.Lines, GsInstallPath,
    JeezOptions.EditDefVstPath.Directory, True)) + FileNameOutputDll(ExtractFilename(FFileName),
    JeezOptions.GetTypeArchitecture, JeezOptions.GetTypePrecision, JeezOptions.GetTypePlugin);
end;

function TJeezEditor.IsFileNameInclude: Boolean;
begin
  Result := SameText(ExtractFileExt(FFileName), GsFileExtJsFxInc);
end;

procedure TJeezEditor.ApplyColors;
begin
  JeezOptions.ApplyControl(EditFolder, JeezOptions.ColorInfoBlocks.Selected);
  JeezOptions.ApplyControl(TreeView, JeezOptions.ColorInfoBlocks.Selected);
  JeezOptions.ApplySynEdit(SynEdit, JeezOptions.ColorBackground.Selected);
  JeezOptions.ApplySynEdit(ErrorMessage, JeezOptions.ColorBackground.Selected);
  JeezOptions.ApplySynAnySyn(SynJsfxSyn, False);
  EditFolder.Invalidate;
  TreeView.Invalidate;
end;

function TJeezEditor.FindTreeNodeVariable(const AName: String): TTreeNode;
begin
  Result := NSJeezTreeView.TreeNodeFind(FVariablesInternal, AName);
  if not Assigned(Result) then
  begin
    Result := NSJeezTreeView.TreeNodeFind(FVariablesExternal, AName);
    if not Assigned(Result) then
    begin
      Result := NSJeezTreeView.TreeNodeFind(FVariablesSlider, AName);
      if not Assigned(Result) then
      begin
        Result := NSJeezTreeView.TreeNodeFind(FVariablesSample, AName);
      end;
    end;
  end;
end;

function TJeezEditor.FindTreeNodeFunction(const AName: String; const AStripParams: Boolean): TTreeNode;
begin
  Result := NSJeezTreeView.TreeNodeFind(FFunctionsUser, AName, AStripParams);
  if not Assigned(Result) then
  begin
    Result := NSJeezTreeView.TreeNodeFind(FFunctionsSystem, AName, AStripParams);
  end;
end;

function TJeezEditor.FolderCreate(const AName: String; const AImageIndex: Integer): TTreeNode;
begin
  Result := TreeView.Items.AddChild(nil, AName);
  Result.ImageIndex := AImageIndex;
  Result.SelectedIndex := AImageIndex;
  EditFolder.Items.AddObject(AName, Result);
end;

procedure TJeezEditor.FoldersCollapse;
begin
  NSJeezTreeView.TreeViewRootNodesCollapse(TreeView);
end;

procedure TJeezEditor.FoldersAlphaSort;
var
  LTreeNode: TTreeNode;
begin
  if TreeView.Items.Count > 0 then
  begin
    LTreeNode := TreeView.Items[0];
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
  if (scCaretX in AStatusChanges) or (scCaretY in AStatusChanges) or (scModified in AStatusChanges) then
  begin
    JeezIde.UpdateTabSheet(GetTabSheet);
  end;
end;

procedure TJeezEditor.TimerPopupNotifierTimer(ASender: TObject);
var
  LPoint: TPoint;
  LString: String;
  LIsFunction: Boolean;
  LTreeNode: TTreeNode;
begin
  TimerPopupNotifier.Enabled := False;
  LPoint := SynEdit.PixelsToRowColumn(FMousePoint);
  if J2C_IdentExtract(SynEdit.Lines[LPoint.Y - 1], LPoint.X - 1, LString, LIsFunction) then
  begin
    if LIsFunction then
    begin
      LTreeNode := FindTreeNodeFunction(J2C_IdentExtractRight(LString), True);
    end else begin
      LTreeNode := FindTreeNodeVariable(LString);
    end;
    if Assigned(LTreeNode) then
    begin
      JeezIde.ShowPopupNotifier(J2C_StringRemoveCount(LTreeNode.Text), CJes2CppTreeNodeData(LTreeNode.Data).FComment);
    end;
  end;
end;

function TJeezEditor.CreateIdentifier(const AParent: TTreeNode; const AIdentifier: CJes2CppIdentifier): TTreeNode;
begin
  if AIdentifier is CJes2CppFunction then
  begin
    Result := NSJeezTreeView.TreeNodeFindOrCreate(AParent, CJes2CppFunction(AIdentifier).EncodeDefineEel);
  end else begin
    Result := NSJeezTreeView.TreeNodeFindOrCreate(AParent, J2C_IdentClean(AIdentifier.Name));
  end;
  CJes2CppTreeNodeData(Result.Data).FComment := AIdentifier.Comment;
end;

function TJeezEditor.CreateVariable(const AVariable: CJes2CppVariable): TTreeNode;
var
  LDummy: Integer;
begin
  if AVariable.IsSystem then
  begin
    if J2C_IdentIsSlider(AVariable.Name, LDummy) then
    begin
      Result := CreateIdentifier(FVariablesSlider, AVariable);
    end else if J2C_IdentIsSample(AVariable.Name, LDummy) then
    begin
      Result := CreateIdentifier(FVariablesSample, AVariable);
    end else begin
      Result := CreateIdentifier(FVariablesExternal, AVariable);
    end;
  end else begin
    if J2C_IdentIsStringNamed(AVariable.Name) then
    begin
      Result := CreateIdentifier(FStringsNamed, AVariable);
    end else if J2C_IdentIsStringLiteral(AVariable.Name) then
    begin
      Result := NSJeezTreeView.TreeNodeFindOrCreate(FStringsLiteral, AVariable.ConstantString);
    end else if J2C_IdentIsStringTemp(AVariable.Name) then
    begin
      Result := CreateIdentifier(FStringsTemp, AVariable);
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

procedure TJeezEditor.CreateReferences(const AParent: TTreeNode; const AIdentifier: CJes2CppIdentifier);
var
  LReference: CJes2CppReference;
  LTreeNode: TTreeNode;
begin
  for LReference in AIdentifier.References do
  begin
    LTreeNode := NSJeezTreeView.TreeNodeFindOrCreate(AParent, LReference.EncodeLineFilePath);
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
begin
  TimerCodeInsight.Enabled := False;
  TreeView.BeginUpdate;
  try
    NSJeezTreeView.TreeNodesMarkNonRootsForCutting(TreeView.Items);
    try
      with CJes2Cpp.Create(Self) do
      begin
        try
          WarningsAsErrors := JeezOptions.EditWarningsAsErrors.Checked;
          ForceGlobals := JeezOptions.EditForceGlobals.Checked;
          IsNoOutput := True;

          LTimer := GetTickCount;
          TranspileScript(SynEdit.Lines, FFileName, EmptyStr, EmptyStr, EmptyStr, EmptyStr, EmptyStr);
          LTimer := GetTickCount - LTimer;
          //JeezMessages.LogMessage('Timer: ' + IntToStr(LTimer));
          PanelError.Visible := False;

          for LVariable in Variables do
          begin
            CreateVariable(LVariable);
          end;
          for LFunction in Functions do
          begin
            CreateFunction(LFunction);
          end;
          if SynJsfxSyn.Objects.Count = 0 then
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
                SynJsfxSyn.Constants.Add(UpperCase(J2C_IdentClean(LVariable.Name)));
              end;
            end;
            SynEdit.Invalidate;
          end;
        finally
          Free;
        end;
      end;
      NSJeezTreeView.TreeNodesDeleteCuts(TreeView.Items);
      FoldersAlphaSort;
      // TODO: Should these be here?
      FVariablesInternal.Expand(False);
      FFunctionsUser.Expand(False);
      FFunctionsSystem.Expand(False);
    except
      on LException: Exception do
      begin
        ErrorMessage.Caption := LException.Message;
        ErrorMessage.Highlighter := JeezMessages.SynAnySyn;
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
  NsSynEdit.SectionPrev(SynEdit);
end;

procedure TJeezEditor.ButtonSectionNextClick(ASender: TObject);
begin
  NsSynEdit.SectionNext(SynEdit);
end;

procedure TJeezEditor.PopupMenuSectionsPopup(ASender: TObject);
var
  LIndex: Integer;
  LMenuItem: TMenuItem;
begin
  if ASender is TMenuItem then
  begin
    SynEdit.CaretY := (ASender as TMenuItem).Tag + 1;
  end else if ASender = PopupMenuSections then
  begin
    PopupMenuSections.Items.Clear;
    for LIndex := 0 to SynEdit.Lines.Count - 1 do
    begin
      if EelIsSection(SynEdit.Lines[LIndex]) then
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
      TreeView.Selected := LTreeNode.GetFirstChild;
    end else begin
      TreeView.Selected := LTreeNode;
    end;
  end else begin
    JeezMessages.LogMessage(Format(SMsgUnableToFindVariable1, [(ASender as TMenuItem).Hint]));
  end;
end;

procedure TJeezEditor.MenuPopupSearchForFunctionClick(ASender: TObject);
var
  LTreeNode: TTreeNode;
begin
  LTreeNode := FindTreeNodeFunction((ASender as TMenuItem).Hint, True);
  if Assigned(LTreeNode) then
  begin
    TreeView.Selected := nil;
    if LTreeNode.HasChildren then
    begin
      TreeView.Selected := LTreeNode.GetFirstChild;
    end else begin
      TreeView.Selected := LTreeNode;
    end;
  end else begin
    JeezMessages.LogMessage(Format(SMsgUnableToFindFunction1, [(ASender as TMenuItem).Hint]));
  end;
end;

procedure TJeezEditor.MenuPopupOpenImportClick(ASender: TObject);
begin
  PopupMenuSynEdit.OnPopup(PopupMenuSynEdit);
  if MenuPopupOpenImport.Visible then
  begin
    JeezIde.LoadFromFile(EelFileNameResolve(MenuPopupOpenImport.Hint, FFileName));
  end else begin
    JeezIde.MenuFileOpen.Click;
  end;
end;

procedure TJeezEditor.PopupMenuSynEditPopup(ASender: TObject);
var
  LString: String;
  LFileName: TFileName;
  LIdIdent, LIsFunction: Boolean;
begin
  JeezIde.HidePopupNotifier;
  TimerPopupNotifier.Enabled := False;
  MenuPopupSearchForVariable.Visible := False;
  MenuPopupSearchForFunction.Visible := False;

  LIdIdent := J2C_IdentExtract(SynEdit.LineText, SynEdit.CaretX, LString, LIsFunction);
  MenuPopupSearchForFunction.Visible := LIdIdent and LIsFunction;

  if LIdIdent and LIsFunction then
  begin
    LString := J2C_IdentExtractRight(LString);
    if (LString <> EmptyStr) and Assigned(FindTreeNodeFunction(LString, True)) then
    begin
      MenuPopupSearchForFunction.Hint := LString;
      MenuPopupSearchForFunction.Caption := 'Search for function ' + QuotedStr(LString);
      MenuPopupSearchForFunction.Visible := True;
    end;
  end;
  if LIdIdent and not LIsFunction and Assigned(FindTreeNodeVariable(LString)) then
  begin
    MenuPopupSearchForVariable.Hint := LString;
    MenuPopupSearchForVariable.Caption := 'Search for variable ' + QuotedStr(LString);
    MenuPopupSearchForVariable.Visible := True;
  end;
  MenuPopupOpenImport.Visible := EelIsImport(SynEdit.LineText, LFileName);
  MenuPopupOpenImport.Hint := LFileName;
  MenuPopupOpenImportSep.Visible := MenuPopupOpenImport.Visible or MenuPopupSearchForFunction.Visible or
    MenuPopupSearchForVariable.Visible;
  if MenuPopupOpenImport.Visible then
  begin
    MenuPopupOpenImport.Caption := GsOpen + CharSpace + QuotedStr(LFileName);
  end;

  MenuPopupUndo.Enabled := SynEdit.CanUndo;
  MenuPopupRedo.Enabled := SynEdit.CanRedo;
  MenuPopupCut.Enabled := SynEdit.SelAvail;
  MenuPopupCopy.Enabled := SynEdit.SelAvail;
  MenuPopupPaste.Enabled := SynEdit.CanPaste;
  MenuPopupDelete.Enabled := SynEdit.SelAvail;
end;

procedure TJeezEditor.TreeViewAddition(ASender: TObject; ATreeNode: TTreeNode);
begin
  ATreeNode.Data := CJes2CppTreeNodeData.Create;
  NSJeezTreeView.TreeNodeUpdateCount(ATreeNode);
end;

procedure TJeezEditor.TreeViewDeletion(ASender: TObject; ATreeNode: TTreeNode);
begin
  NSJeezTreeView.TreeNodeUpdateCount(ATreeNode);
  if Assigned(ATreeNode.Data) then
  begin
    TObject(ATreeNode.Data).Free;
    ATreeNode.Data := nil;
  end;
end;

procedure TJeezEditor.TreeViewKeyPress(ASender: TObject; var AKey: Char);
begin
  NSJeezTreeView.TreeViewHandleKeyPress(TreeView, AKey);
end;

procedure TJeezEditor.TreeViewCustomDrawItem(ASender: TCustomTreeView; ATreeNode: TTreeNode; ADrawState: TCustomDrawState;
  var ADefaultDraw: Boolean);
begin
  NSJeezTreeView.TreeNodeDraw(ATreeNode, JeezOptions.ColorFunctions.Selected,
    JeezOptions.ColorVariables.Selected, JeezOptions.ColorIdentifiers.Selected,
    JeezOptions.ColorSymbols.Selected);
  ADefaultDraw := False;
end;

procedure TJeezEditor.TreeViewMouseMove(ASender: TObject; AShiftState: TShiftState; AX, AY: Integer);
begin
  if Assigned(TreeView.GetNodeAt(AX, AY)) then
  begin
    TreeView.Cursor := crHandPoint;
  end else begin
    TreeView.Cursor := crDefault;
  end;
end;

procedure TJeezEditor.JumpToReferenceNode(const ATreeNode: TTreeNode; const ANoFileNameChange: Boolean);
var
  LText: String;
  LFileName: TFileName;
  LEditor: TJeezEditor;
  LTreeNode: TTreeNode;
begin
  LText := ATreeNode.Text;
  LFileName := J2C_ExtractFileSource(LText);
  if ANoFileNameChange and not SameFileName(LFileName, FFileName) then
  begin
    Abort;
  end;
  LEditor := JeezIde.LoadFromFile(LFileName, J2C_ExtractFileCaretY(LText));
  if LEditor <> Self then
  begin
    LEditor.TimerCodeInsightTimer(LEditor.TimerCodeInsight);
    if NSJeezTreeView.TreeNodeIsReference(ATreeNode) then
    begin
      LTreeNode := NSJeezTreeView.TreeNodesFind(LEditor.TreeView.Items, NSJeezTreeView.TreeNodeGetText(ATreeNode.Parent));
    end else begin
      LTreeNode := NSJeezTreeView.TreeNodesFind(LEditor.TreeView.Items, LText);
    end;
    if Assigned(LTreeNode) then
    begin
      LTreeNode.Selected := True;
    end;
    try
      LEditor.TreeView.SetFocus;
    except
    end;
  end;
end;

procedure TJeezEditor.TreeViewSelectionChanged(ASender: TObject);
begin
  if Assigned(TreeView.Selected) then
  begin
    EditFolder.ItemIndex := TreeView.Selected.GetParentNodeOfAbsoluteLevel(0).Index;
    try
      JumpToReferenceNode(TreeView.Selected, False);
    except
      try
        if TreeView.Selected.HasChildren then
        begin
          JumpToReferenceNode(TreeView.Selected.GetFirstChild, True);
        end;
      except
      end;
    end;
    TreeView.Selected.MakeVisible;
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
end;

procedure TJeezEditor.MenuPopupSelectAllClick(ASender: TObject);
begin
  SynEdit.SelectAll;
end;

procedure TJeezEditor.MenuPopupUndoClick(ASender: TObject);
begin
  SynEdit.Undo;
end;

procedure TJeezEditor.PanelRightResize(ASender: TObject);
begin
  //TreeView.Font.Size := TreeView.Width div 32;
  EditFolder.Width := PanelRight.Width;
end;

procedure TJeezEditor.SynEditChange(ASender: TObject);
begin
  JeezIde.HidePopupNotifier;
  TimerPopupNotifier.Enabled := False;
  TimerCodeInsight.Enabled := False;
  TimerCodeInsight.Enabled := PanelRight.Visible;
end;

procedure TJeezEditor.SynEditMouseDown(ASender: TObject; AMouseButton: TMouseButton; AShiftState: TShiftState; AX, AY: Integer);
begin
  JeezIde.HidePopupNotifier;
end;

procedure TJeezEditor.SynEditMouseLeave(ASender: TObject);
begin
  TimerPopupNotifier.Enabled := False;
end;

procedure TJeezEditor.SynEditMouseMove(ASender: TObject; AShiftState: TShiftState; AX, AY: Integer);
var
  LDelta: TPoint;
begin
  LDelta.X := AX - FMousePoint.X;
  LDelta.Y := AY - FMousePoint.Y;
  if (not JeezIde.PopupNotifier.Visible and (Abs(LDelta.X) * Abs(LDelta.Y) > 20)) or (LDelta.X > 330) or
    (LDelta.X < -10) or (LDelta.Y < -20) or (LDelta.Y > 130) then

  begin
    FMousePoint := Point(AX, AY);
    JeezIde.HidePopupNotifier;
    TimerPopupNotifier.Enabled := False;
    TimerPopupNotifier.Enabled := PanelRight.Visible;
  end;
end;

procedure TJeezEditor.MenuPopupCopyClick(ASender: TObject);
begin
  SynEdit.CopyToClipboard;
end;

procedure TJeezEditor.EditFolderChange(ASender: TObject);
begin
  FoldersCollapse;
  TreeView.Selected := EditFolder.Items.Objects[EditFolder.ItemIndex] as TTreeNode;
  TreeView.TopItem := TreeView.Selected;
  TreeView.Selected.Expand(False);
end;

procedure TJeezEditor.EditFolderDrawItem(AWinControl: TWinControl; AIndex: Integer; ARect: TRect; ADrawState: TOwnerDrawState);
begin
  NSJeezCanvas.DrawComboBoxItem(AWinControl as TComboBox, AIndex, ARect, ADrawState, JeezData.ImageList16);
end;

procedure TJeezEditor.ButtonSyntaxCheckClick(ASender: TObject);
begin
  JeezMessages.LogFileName(SMsgTypeSyntaxChecking, FFileName);
  with Transpile.Create(Self) do
  begin
    try
      WarningsAsErrors := JeezOptions.EditWarningsAsErrors.Checked;
      ForceGlobals := JeezOptions.EditForceGlobals.Checked;
      TranspileScript(SynEdit.Lines, FFileName);
    finally
      Free;
    end;
  end;
  JeezMessages.LogMessage(SMsgSyntaxCheckingCompleteNoErrorsFound + ' / Total heap allocated: ' +
    IntToStr(GetHeapStatus.TotalAllocated) + ' bytes');
end;

procedure TJeezEditor.ButtonFindErrorClick(ASender: TObject);
begin
  ButtonSyntaxCheck.Click;
end;

function TJeezEditor.GetTabSheet: TTabSheet;
var
  LWinControl: TWinControl;
begin
  LWinControl := Self;
  while Assigned(LWinControl) and not (LWinControl is TTabSheet) do
  begin
    LWinControl := LWinControl.Parent;
  end;
  Result := LWinControl as TTabSheet;
  Assert(Assigned(Result));
end;

procedure TJeezEditor.SetFileName(const AFileName: TFileName);
begin
  FFileName := AFileName;
  SynEdit.Highlighter := JeezData.GetHighlighterFromFileName(AFileName, SynJsfxSyn);
  PanelRight.Visible := SynEdit.Highlighter = SynJsfxSyn;
  EditFolder.Visible := PanelRight.Visible;
  SplitterRight.Visible := PanelRight.Visible;
  JeezIde.UpdateTabSheet(GetTabSheet);
end;

procedure TJeezEditor.LoadFromFile(const AFileName: TFileName);
begin
  JeezMessages.LogTextFileExists(AFileName);
  SynEdit.Lines.LoadFromFile(AFileName);
  SetFileName(AFileName);
  JeezMessages.LogFileName(SMsgTypeLoaded, AFileName);
  JeezOptions.AddRecentFile(AFileName);
end;

procedure TJeezEditor.SaveToFile(const AFileName: TFileName);
begin
  if not FilenameIsAbsolute(AFileName) then
  begin
    raise Exception.Create(SMsgFileNameMustBeAbsolute);
  end;
  SynEdit.Lines.SaveToFile(AFileName);
  SynEdit.Modified := False;
  SetFileName(AFileName);
  JeezOptions.AddRecentFile(AFileName);
end;

procedure TJeezEditor.SaveToFile;
begin
  SaveToFile(FFileName);
end;

procedure TJeezEditor.LoadFromUntitled(const AFileName: String);
var
  LIndex, LCount: Integer;
begin
  with SynEdit.Lines do
  begin
    Clear;
    J2C_StringsAddCommentLine(SynEdit.Lines);
    J2C_StringsAddComment(SynEdit.Lines, 'Name:');
    J2C_StringsAddComment(SynEdit.Lines, 'Website:');
    J2C_StringsAddComment(SynEdit.Lines, 'Created: ' + FormatDateTime(FormatSettings.LongDateFormat, Now));
    J2C_StringsAddComment(SynEdit.Lines, Format('Copyright %d (C) (Enter Your Name) <your@email.com>', [YearOf(Now)]));
    J2C_StringsAddCommentLine(SynEdit.Lines);
    Add(EmptyStr);

    J2C_StringsAddComment(SynEdit.Lines, 'Desc should be a one line description of your effect.');
    Add('desc: New Jesusonic Effect');
    Add(EmptyStr);

    J2C_StringsAddComment(SynEdit.Lines,
      'The following properties are used for plugin DLL generation. If a property doesnt exist (or is blank), then the default "tools->options" properties are used.');
    Add(EmptyStr);

    J2C_StringsAddComment(SynEdit.Lines, 'EffectName should be ~10-20 chars and simply describe your effect.');
    Add(GsEffectName + ': Enter Effect Name');
    Add(EmptyStr);

    J2C_StringsAddComment(SynEdit.Lines, GsVendorString +
      ' should be ~10-20 chars and common to all your effects. It is shown in brackets after the EffectName. eg: BeatBox (mda)');
    Add(GsVendorString + ': Vendor');
    Add(EmptyStr);

    J2C_StringsAddComment(SynEdit.Lines, GsVendorVersion + ' is a 32bit integer.');
    Add(GsVendorVersion + ': 1000');
    Add(EmptyStr);

    J2C_StringsAddComment(SynEdit.Lines, GsUniqueId +
      ' is a 32bit integer and should be registered with Steinberg if you are releasing a global plugin. It is used to resolve plugin name clashes.');
    Add(GsUniqueId + ': 1234');
    Add(EmptyStr);

    J2C_StringsAddComment(SynEdit.Lines, GsInstallPath +
      ' is the location in which the plugin DLL will be installed. Note: On most systems, the plugin path will require admin privileges, so you may require your development plugin''s in a non-admin folder.');
    Add(GsInstallPath + ': %PROGRAMFILES%\VST\');
    Add(EmptyStr);

    Add(EelSectionName(GsEelSectionInit));
    J2C_StringsAddComment(SynEdit.Lines, '@init is called each time the effect is resumed. ie: Start of play.');
    J2C_StringsAddComment(SynEdit.Lines, 'Constants');
    Add('cDenorm = 10^-30;');
    Add('cAmpDB = 8.65617025;');
    Add(EmptyStr);
    Add(EelSectionName(GsEelSectionBlock));
    J2C_StringsAddComment(SynEdit.Lines,
      '@block is called every N samples, where N is set by your audio card. This setting is often called "latency".');
    Add(EmptyStr);

    Add(EelSectionName(GsEelSectionSample));
    J2C_StringsAddComment(SynEdit.Lines, '@sample is called for each audio sample.');
    J2C_StringsAddComment(SynEdit.Lines, 'Simple M/S Code');
    Add('mid = (spl0 + spl1) * 0.5;');
    Add('sid = (spl0 - spl1) * 0.5;');
    Add('spl0 = mid;');
    Add('spl1 = sid;');
    Add(EmptyStr);

    Add(EelSectionName(GsEelSectionGfx) + ' 320 240');
    J2C_StringsAddComment(SynEdit.Lines,
      'NOTE: Sliders must be hidden before graphics are enabled. Review the SWIPE GUI demos to see how this is done.');
    Add(EmptyStr);

    Add(EelSectionName(GsEelSectionSerialize));
    J2C_StringsAddComment(SynEdit.Lines,
      '@serialize is called when effect settings need to be stored & restored. NOTE: @serialize is currently not implemented, but will be soon. Until @serialize is implemented, you can use the default slider serialization to store/restore effect settings.');
  end;
  SynEdit.Modified := False;
  LCount := 0;
  repeat
    Inc(LCount);
    FFileName := ChangeFileExt(AFileName, EmptyStr) + IntToStr(LCount) + ExtractFileExt(AFileName);
    for LIndex := GetTabSheet.PageControl.PageCount - 1 downto 0 do
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

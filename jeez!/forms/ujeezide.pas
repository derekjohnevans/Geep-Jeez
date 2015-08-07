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

unit UJeezIde;

{$MODE DELPHI}

interface

uses
  Classes, ComCtrls, Controls, Dialogs, ExtCtrls, Forms, Graphics, JeezResources,
  JeezSynEdit, JeezUtils, Jes2CppCompiler, Jes2CppConstants, Jes2CppFileNames, Jes2CppIterate,
  Jes2CppModuleImporter, Jes2CppPlatform, Jes2CppTranslate, Jes2CppUtils,
  LclIntf, LCLProc, Math, Menus, PopupNotifier, Process, StrUtils, SynEdit, SynEditTypes,
  SysUtils, Types, UJeezEditor;

type

  { TJeezIde }

  TJeezIde = class(TForm)
    ApplicationProperties: TApplicationProperties;
    ButtonBuildAndInstallPlugin: TToolButton;
    FindDialog: TFindDialog;
    MainMenu: TMainMenu;
    MenuFile: TMenuItem;
    MenuEdit: TMenuItem;
    MenuHelp: TMenuItem;
    MenuFileOpen: TMenuItem;
    MenuFileSave: TMenuItem;
    MenuFileSaveAs: TMenuItem;
    MenuFileExit: TMenuItem;
    MenuFileNew: TMenuItem;
    MenuHelpAboutJeez: TMenuItem;
    MenuEditCut: TMenuItem;
    MenuEditCopy: TMenuItem;
    MenuEditPaste: TMenuItem;
    MenuEditDelete: TMenuItem;
    MenuEditSelectAll: TMenuItem;
    MenuFileClose: TMenuItem;
    MenuFileSep1: TMenuItem;
    MenuEditSep1: TMenuItem;
    MenuFileEffectProperties: TMenuItem;
    MenuFileSep4: TMenuItem;
    MenuFileCloseAllOtherPages: TMenuItem;
    MenuFileSep5: TMenuItem;
    MenuFileExportCodeAsHtml: TMenuItem;
    MenuHelpGotoJeezOnline: TMenuItem;
    MenuHelpSep1: TMenuItem;
    MenuFileSep6: TMenuItem;
    MenuHelpFatcowOnline: TMenuItem;
    MenuHelpReaperOnline: TMenuItem;
    MenuHelpSep2: TMenuItem;
    MenuHelpJsFxReferenceOnline: TMenuItem;
    MenuHelpSaviHost: TMenuItem;
    MenuFileExploreReaperEffectsFolder: TMenuItem;
    MenuFileSep7: TMenuItem;
    MenuToolsOpenPluginInHost: TMenuItem;
    MenuToolsSep4: TMenuItem;
    MenuRecentFile: TMenuItem;
    MenuToolsOpenCppOutputFile: TMenuItem;
    MenuFileOpenReaper: TMenuItem;
    MenuToolsConvertEffectToImportModule: TMenuItem;
    MenuPopupSep2: TMenuItem;
    MenuPopupCloseAllOtherPages: TMenuItem;
    MenuToolsSep3: TMenuItem;
    MenuPopupOpenContainingFolder: TMenuItem;
    MenuPopupSep1: TMenuItem;
    MenuPopupSave: TMenuItem;
    MenuPopupClosePage: TMenuItem;
    MenuFileSep3: TMenuItem;
    MenuFileCloseAll: TMenuItem;
    MenuEditUndo: TMenuItem;
    MenuEditRedo: TMenuItem;
    MenuEditSep2: TMenuItem;
    MenuEditSep4: TMenuItem;
    MenuEditFind: TMenuItem;
    MenuEditFindNext: TMenuItem;
    MenuToolsBuildAndInstallPlugin: TMenuItem;
    MenuToolsOptions: TMenuItem;
    MenuToolsSep2: TMenuItem;
    MenuToolsExploreOutputFolder: TMenuItem;
    MenuPageControl: TPopupMenu;
    MenuRecentFiles: TPopupMenu;
    PanelBody: TPanel;
    PopupNotifier: TPopupNotifier;
    ButtonExploreOutput: TToolButton;
    MenuToolsSep1: TMenuItem;
    MenuFileSep2: TMenuItem;
    MenuToolsSyntaxCheck: TMenuItem;
    MenuToolsBuildPlugin: TMenuItem;
    MenuTools: TMenuItem;
    PageControl: TPageControl;
    PageControlSystem: TPageControl;
    PanelBottom: TPanel;
    PanelClient: TPanel;
    SplitterBottom: TSplitter;
    StatusBar: TStatusBar;
    TabSheetMessages: TTabSheet;
    ToolBar: TToolBar;
    ButtonNew: TToolButton;
    ButtonOpen: TToolButton;
    ButtonSave: TToolButton;
    ButtonBuildPlugin: TToolButton;
    ButtonOptions: TToolButton;
    procedure ApplicationPropertiesDropFiles(ASender: TObject; const AFileNames: array of String);
    procedure ApplicationPropertiesException(ASender: TObject; AException: Exception);
    procedure FindDialogClose(ASender: TObject);
    procedure FindDialogShow(ASender: TObject);
    procedure FormCloseQuery(ASender: TObject; var ACanClose: Boolean);
    procedure FormCreate(ASender: TObject);
    procedure FormShow(ASender: TObject);
    procedure MenuEditClick(ASender: TObject);
    procedure MenuEditCopyClick(ASender: TObject);
    procedure MenuEditCutClick(ASender: TObject);
    procedure MenuEditDeleteClick(ASender: TObject);
    procedure MenuEditFindClick(ASender: TObject);
    procedure MenuEditFindNextClick(ASender: TObject);
    procedure MenuEditPasteClick(ASender: TObject);
    procedure MenuEditRedoClick(ASender: TObject);
    procedure MenuEditSelectAllClick(ASender: TObject);
    procedure MenuEditUndoClick(ASender: TObject);
    procedure MenuFileClick(ASender: TObject);
    procedure MenuFileCloseAllClick(ASender: TObject);
    procedure MenuFileCloseAllOtherPagesClick(ASender: TObject);
    procedure MenuFileCloseClick(ASender: TObject);
    procedure MenuFileExitClick(ASender: TObject);
    procedure MenuFileExportCodeAsHtmlClick(ASender: TObject);
    procedure MenuFileNewClick(ASender: TObject);
    procedure MenuFileOpenClick(ASender: TObject);
    procedure MenuFileEffectPropertiesClick(ASender: TObject);
    procedure MenuFileExploreReaperEffectsFolderClick(ASender: TObject);
    procedure MenuFileSaveAsClick(ASender: TObject);
    procedure MenuFileSaveClick(ASender: TObject);
    procedure MenuHelpAboutJeezClick(ASender: TObject);
    procedure MenuHelpFatcowOnlineClick(ASender: TObject);
    procedure MenuHelpGotoJeezOnlineClick(ASender: TObject);
    procedure MenuFileOpenReaperClick(ASender: TObject);
    procedure MenuHelpReaperOnlineClick(ASender: TObject);
    procedure MenuHelpJsFxReferenceOnlineClick(ASender: TObject);
    procedure MenuHelpSaviHostClick(ASender: TObject);
    procedure MenuToolsOpenPluginInHostClick(ASender: TObject);
    procedure MenuPopupOpenContainingFolderClick(ASender: TObject);
    procedure MenuRecentFilesPopup(ASender: TObject);
    procedure MenuToolsBuildAndInstallPluginClick(ASender: TObject);
    procedure MenuToolsBuildPluginClick(ASender: TObject);
    procedure MenuToolsClick(ASender: TObject);
    procedure MenuToolsConvertEffectToImportModuleClick(ASender: TObject);
    procedure MenuToolsOpenCppOutputFileClick(ASender: TObject);
    procedure MenuToolsExploreOutputFolderClick(ASender: TObject);
    procedure MenuToolsOptionsClick(ASender: TObject);
    procedure MenuToolsSyntaxCheckClick(ASender: TObject);
    procedure PageControlCloseTabClicked(ASender: TObject);
    procedure PageControlMouseDown(ASender: TObject; AMouseButton: TMouseButton;
      AShiftState: TShiftState; AX, AY: Integer);
    procedure MenuPageControlPopup(ASender: TObject);
  strict private
    FIsFindDialogOpen: Boolean;
  strict private
    procedure DoOnTabSheetShow(ASender: TObject);
    procedure DoOnToolBarPaint(ASender: TObject);
    procedure SelectJsFxEditor;
  public
    procedure HidePopupNotifier;
    procedure ShowPopupNotifier(const ATitle, AText: String);
    procedure UpdateAllEditors;
    procedure UpdateTabSheet(const ATabSheet: TTabSheet);
  public
    function CreateEditor(const AFileName: String): TJeezEditor;
    function GetActiveEditor: TJeezEditor;
    function GetEditor(const AIndex: Integer): TJeezEditor;
    function GetPageIndexByFileName(const AFileName: TFileName): Integer;
    function LoadFromFile(const AFileName: TFileName): TJeezEditor; overload;
    function LoadFromFile(const AFileName: TFileName; const ACaretY: Integer): TJeezEditor;
      overload;
    function LoadFromPath(const AFilePath: TFileName): TJeezEditor; overload;
  end;

var
  JeezIde: TJeezIde;

implementation

{$R *.lfm}

uses UJeezAbout, UJeezData, UJeezMessages, UJeezOptions;

procedure PlatformLoadFromFile(const AFileName: TFileName);
begin
  Application.Minimize;
  Application.Restore;
  JeezIde.LoadFromFile(AFileName);
end;

procedure TJeezIde.FormCreate(ASender: TObject);
begin
  GPlatform.SingleInstanceInit(Handle, GsJeezTitle, PlatformLoadFromFile);
  GPlatform.ScrollingWinControlPrepare(Self);
  // We must set the default size here so form centering is correct.
  Width := GPlatform.FormWidth;
  Height := GPlatform.FormHeight;
  if GPlatform.IsLinux then
  begin
    MenuFileOpenReaper.Visible := False;
    MenuFileOpenReaper.Enabled := False;
  end;
  PageControl.Height := GPlatform.PageControlHeight;
end;

procedure TJeezIde.FormShow(ASender: TObject);
var
  LIndex: Integer;
begin
  UpdateAllEditors;
  WindowState := wsMaximized;
  if GPlatform.IsWindows then
  begin
    ToolBar.Color := clMenu;
    //PanelBody.Color := $ddaaaa;
  end;
  if GPlatform.IsLinux then
  begin
    PanelBody.Color := $aa8866;
    ToolBar.Color := clDefault;
  end;
  ToolBar.OnPaint := DoOnToolBarPaint;
  for LIndex := IndexFirst(ToolBar) to IndexLast(ToolBar) do
  begin
    ToolBar.Buttons[LIndex].Caption :=
      CharSpace + Trim(ToolBar.Buttons[LIndex].Caption) + CharSpace;
  end;

  PanelBottom.Height := GiDefaultMessageLogHeight;

  JeezConsole.Parent := TabSheetMessages;
  JeezConsole.Visible := True;

  JeezConsole.LogMessage(GsCppCommentSpace + GsJeezTitle);
  JeezConsole.LogMessage(GsCppCommentSpace + SMsgIncludes + CharSpace + GsJes2CppTitle);
  JeezConsole.LogMessage(GsCppCommentSpace + GsJes2CppSlogan);
  JeezConsole.LogMessage(EmptyStr);

  for LIndex := 1 to ParamCount do
  begin
    try
      LoadFromFile(ParamStr(LIndex));
    except
      on LException: Exception do
      begin
        JeezConsole.LogMessage(LException.Message);
      end;
    end;
  end;
  if IndexCount(PageControl) = ZeroValue then
  begin
    MenuFileNew.Click;
  end;
end;

procedure TJeezIde.MenuEditClick(ASender: TObject);
var
  LSynEdit: TSynEdit;
  LEnabled: Boolean;
begin
  LSynEdit := GetActiveEditor.SynEdit;
  LEnabled := LSynEdit.Focused and not FIsFindDialogOpen;
  MenuEditUndo.Enabled := LEnabled and LSynEdit.CanUndo;
  MenuEditRedo.Enabled := LEnabled and LSynEdit.CanRedo;
  MenuEditCut.Enabled := LEnabled and LSynEdit.SelAvail;
  MenuEditCopy.Enabled := LEnabled and LSynEdit.SelAvail;
  MenuEditPaste.Enabled := LEnabled and LSynEdit.CanPaste;
  MenuEditDelete.Enabled := LEnabled and LSynEdit.SelAvail;
  MenuEditSelectAll.Enabled := LEnabled;
  GetActiveEditor.UpdatePopupMenuStates;
end;

procedure TJeezIde.ShowPopupNotifier(const ATitle, AText: String);
begin
  PopupNotifier.Title := ATitle;
  PopupNotifier.Text := AText;
  PopupNotifier.ShowAtPos(Mouse.CursorPos.X, Mouse.CursorPos.Y);
  GetActiveEditor.SetFocus;
end;

procedure TJeezIde.HidePopupNotifier;
begin
  PopupNotifier.Hide;
end;

procedure TJeezIde.ApplicationPropertiesException(ASender: TObject; AException: Exception);
begin
  try
    LoadFromFile(GUtils.ExtractFileSource(AException.Message),
      GUtils.ExtractFileCaretY(AException.Message));
  except
    MessageDlg(AException.Message, mtError, [mbOK], ZeroValue);
  end;
  GetActiveEditor.SetFocus;
end;

procedure TJeezIde.ApplicationPropertiesDropFiles(ASender: TObject;
  const AFileNames: array of String);
var
  LFileName: TFileName;
begin
  for LFileName in AFileNames do
  begin
    LoadFromFile(LFileName);
  end;
end;

procedure TJeezIde.FindDialogShow(ASender: TObject);
begin
  FIsFindDialogOpen := True;
  MenuEdit.Click;
end;

procedure TJeezIde.FindDialogClose(ASender: TObject);
begin
  FIsFindDialogOpen := False;
  MenuEdit.Click;
end;

procedure TJeezIde.FormCloseQuery(ASender: TObject; var ACanClose: Boolean);
begin
  MenuFileCloseAll.Click;
end;

procedure TJeezIde.MenuEditCopyClick(ASender: TObject);
begin
  GetActiveEditor.SynEdit.CopyToClipboard;
end;

procedure TJeezIde.MenuEditCutClick(ASender: TObject);
begin
  GetActiveEditor.SynEdit.CutToClipboard;
end;

procedure TJeezIde.MenuEditPasteClick(ASender: TObject);
begin
  GetActiveEditor.MenuPopupPaste.Click;
end;

procedure TJeezIde.MenuEditRedoClick(ASender: TObject);
begin
  GetActiveEditor.MenuPopupRedo.Click;
end;

procedure TJeezIde.MenuEditSelectAllClick(ASender: TObject);
begin
  GetActiveEditor.MenuPopupSelectAll.Click;
end;

procedure TJeezIde.MenuEditUndoClick(ASender: TObject);
begin
  GetActiveEditor.MenuPopupUndo.Click;
end;

procedure TJeezIde.MenuEditDeleteClick(ASender: TObject);
begin
  GetActiveEditor.MenuPopupDelete.Click;
end;

procedure TJeezIde.MenuEditFindClick(ASender: TObject);
begin
  FindDialog.Execute;
end;

procedure TJeezIde.MenuEditFindNextClick(ASender: TObject);
var
  LOptions: TSynSearchOptions;
begin
  if FindDialog.FindText = EmptyStr then
  begin
    MenuEditFind.Click;
  end else begin
    FindDialog.CloseDialog;
    LOptions := [];
    if not (frDown in FindDialog.Options) then
    begin
      LOptions += [ssoBackwards];
    end;
    if frWholeWord in FindDialog.Options then
    begin
      LOptions += [ssoWholeWord];
    end;
    if frMatchCase in FindDialog.Options then
    begin
      LOptions += [ssoMatchCase];
    end;
    if frEntireScope in FindDialog.Options then
    begin
      LOptions += [ssoEntireScope];
    end;
    if GetActiveEditor.SynEdit.SearchReplace(FindDialog.FindText, EmptyStr, LOptions) = 0 then
    begin
      if MessageDlg(Format(SMsgSearchCompleted1,
        [IfThen(ssoBackwards in LOptions, 'end', 'beginning')]), mtConfirmation,
        [mbYes, mbNo], ZeroValue) = mrYes then
      begin
        if ssoBackwards in LOptions then
        begin
          GetActiveEditor.SynEdit.CaretXY := Types.Point(MaxInt, MaxInt);
        end else begin
          GetActiveEditor.SynEdit.CaretXY := Types.Point(-1, -1);
        end;
        MenuEditFindNext.Click;
      end;
    end;
  end;
end;

procedure TJeezIde.MenuFileClick(ASender: TObject);
begin
  MenuFileSave.Enabled := GetActiveEditor.SynEdit.Modified;
  MenuFileOpenReaper.Enabled := DirectoryExists(GFilePath.ReaperEffects);
  MenuFileExploreReaperEffectsFolder.Enabled := MenuFileOpenReaper.Enabled;
  MenuFileCloseAllOtherPages.Enabled := IndexCount(PageControl) > 1;
end;

procedure TJeezIde.MenuFileCloseAllClick(ASender: TObject);
var
  LIndex: Integer;
begin
  for LIndex := IndexLast(PageControl) downto IndexFirst(PageControl) do
  begin
    PageControl.PageIndex := LIndex;
    MenuFileClose.Click;
  end;
end;

procedure TJeezIde.MenuFileCloseAllOtherPagesClick(ASender: TObject);
var
  LIndex: Integer;
  LTabSheet: TTabSheet;
begin
  LTabSheet := PageControl.ActivePage;
  for LIndex := IndexLast(PageControl) downto IndexFirst(PageControl) do
  begin
    if PageControl.Pages[LIndex] <> LTabSheet then
    begin
      PageControl.PageIndex := LIndex;
      MenuFileClose.Click;
    end;
  end;
  PageControl.ActivePage := LTabSheet;
end;

procedure TJeezIde.MenuFileCloseClick(ASender: TObject);
begin
  if GetActiveEditor.SynEdit.Modified then
  begin
    case MessageDlg(Format(SMsgDoYouWantToSaveModifiedFile1,
        [ExtractFilename(GetActiveEditor.FileName)]), mtConfirmation,
        [mbYes, mbNo, mbCancel], ZeroValue) of
      mrYes: begin
        MenuFileSave.Click;
      end;
      mrNo: begin
      end else begin
        Abort;
      end;
    end;
  end;
  PageControl.ActivePage.Free;
  if IndexCount(PageControl) = ZeroValue then
  begin
    MenuFileExit.Click;
  end else begin
    DoOnTabSheetShow(PageControl.ActivePage);
  end;
end;

procedure TJeezIde.MenuFileExitClick(ASender: TObject);
begin
  Close;
end;

procedure TJeezIde.MenuFileExportCodeAsHtmlClick(ASender: TObject);
begin
  if JeezData.SaveDialogHtml.Execute then
  begin
    GJeezSynEdit.ExportHtml(GetActiveEditor.SynEdit, GetActiveEditor.SynEdit.Lines,
      JeezData.SaveDialogHtml.Filename);
  end;
end;

procedure TJeezIde.MenuFileNewClick(ASender: TObject);
begin
  CreateEditor(GsFilePartUntitled + GsFileExtJsFx);
end;

procedure TJeezIde.MenuFileOpenClick(ASender: TObject);
begin
  LoadFromPath(ExtractFilePath(GetActiveEditor.FileName));
end;

procedure TJeezIde.MenuFileEffectPropertiesClick(ASender: TObject);
begin
  GetActiveEditor.MenuPopupProperties.Click;
end;

procedure TJeezIde.MenuFileSaveAsClick(ASender: TObject);
begin
  JeezData.SaveDialog.FileName := ExtractFilename(GetActiveEditor.FileName);
  JeezData.SaveDialog.InitialDir := ExtractFileDir(GetActiveEditor.FileName);
  if JeezData.SaveDialog.Execute then
  begin
    GetActiveEditor.SaveToFile(JeezData.SaveDialog.FileName);
  end else begin
    Abort;
  end;
end;

procedure TJeezIde.MenuFileSaveClick(ASender: TObject);
begin
  try
    GetActiveEditor.SaveToFile;
  except
    MenuFileSaveAs.Click;
  end;
end;

procedure TJeezIde.MenuHelpAboutJeezClick(ASender: TObject);
begin
  JeezAbout.Execute;
end;

procedure TJeezIde.MenuHelpFatcowOnlineClick(ASender: TObject);
begin
  OpenUrl(GUrls.FatCow);
end;

procedure TJeezIde.MenuHelpReaperOnlineClick(ASender: TObject);
begin
  OpenUrl(GUrls.REAPER);
end;

procedure TJeezIde.MenuHelpJsFxReferenceOnlineClick(ASender: TObject);
begin
  OpenUrl(GUrls.JSFXReference);
end;

procedure TJeezIde.MenuHelpSaviHostClick(ASender: TObject);
begin
  OpenUrl(GUrls.SAVIHost);
end;

procedure TJeezIde.MenuHelpGotoJeezOnlineClick(ASender: TObject);
begin
  OpenUrl(GUrls.GeepJeez);
end;

procedure TJeezIde.MenuFileOpenReaperClick(ASender: TObject);
begin
  LoadFromPath(GFilePath.ReaperEffects);
end;

procedure TJeezIde.MenuFileExploreReaperEffectsFolderClick(ASender: TObject);
begin
  OpenUrl(GFilePath.ReaperEffects);
end;

procedure TJeezIde.MenuPopupOpenContainingFolderClick(ASender: TObject);
begin
  OpenUrl(ExtractFilePath(GetActiveEditor.FileName));
end;

procedure TJeezIde.MenuRecentFilesPopup(ASender: TObject);
var
  LIndex: Integer;
  LMenuItem: TMenuItem;
  LCaption: String;
begin
  if ASender is TMenuItem then
  begin
    LoadFromFile(TMenuItem(ASender).Caption);
  end else begin
    MenuRecentFiles.Items.Clear;
    LMenuItem := TMenuItem.Create(MenuRecentFiles);
    LCaption := MenuFileOpen.Caption;
    DeleteAmpersands(LCaption); // TODO: Unsure if this is needed?
    LMenuItem.Caption := LCaption;
    LMenuItem.OnClick := MenuFileOpenClick;
    LMenuItem.ImageIndex := MenuFileOpen.ImageIndex;
    MenuRecentFiles.Items.Add(LMenuItem);
    for LIndex := IndexFirst(JeezOptions.EditRecentFiles.Items)
      to IndexLast(JeezOptions.EditRecentFiles.Items) do
    begin
      LMenuItem := TMenuItem.Create(MenuRecentFiles);
      LMenuItem.Caption := JeezOptions.EditRecentFiles.Items[LIndex];
      LMenuItem.OnClick := MenuRecentFilesPopup;
      LMenuItem.ImageIndex := MenuFileNew.ImageIndex;
      MenuRecentFiles.Items.Add(LMenuItem);
    end;
  end;
end;

procedure TJeezIde.UpdateTabSheet(const ATabSheet: TTabSheet);
var
  LFileName: TFileName;
  LSynEdit: TSynEdit;
  LEditor: TJeezEditor;
begin
  LEditor := GetEditor(ATabSheet.TabIndex);
  LFileName := LEditor.FileName;
  LSynEdit := LEditor.SynEdit;

  if LSynEdit.Modified then
  begin
    ATabSheet.ImageIndex := 1;
    ATabSheet.Caption := ExtractFilename(LFileName) + ' (' + SMsgModified + ')';
    StatusBar.Panels[1].Text := SMsgModified;
  end else begin
    ATabSheet.ImageIndex := 0;
    ATabSheet.Caption := ExtractFilename(LFileName);
    StatusBar.Panels[1].Text := SMsgUnchanged;
  end;
  StatusBar.Panels[0].Text := Format('%d: %d', [LSynEdit.CaretY, LSynEdit.CaretX]);
  StatusBar.Panels[2].Text := QuotedStr(LFileName);
end;

procedure TJeezIde.DoOnTabSheetShow(ASender: TObject);
begin
  UpdateTabSheet(ASender as TTabSheet);
  HidePopupNotifier;
  GetActiveEditor.BringToFront;
  GetActiveEditor.PanelRightResize(GetActiveEditor.PanelRight);
  MenuEdit.Click;
  if PanelClient.Visible then
  begin
    GetActiveEditor.SetFocus;
  end;
end;

procedure TJeezIde.DoOnToolBarPaint(ASender: TObject);
begin
  with ASender as TCustomControl do
  begin
    Canvas.GradientFill(ClientRect, clBtnHighlight, PanelClient.Color, gdVertical);
  end;
end;

procedure TJeezIde.SelectJsFxEditor;
begin
  while GetActiveEditor.IsFileNameInclude do
  begin
    if PageControl.ActivePageIndex = ZeroValue then
    begin
      JeezConsole.LogException(SMsgUnableToCompileIncludeFile);
    end else begin
      PageControl.SelectNextPage(False);
    end;
  end;
end;

function TJeezIde.GetEditor(const AIndex: Integer): TJeezEditor;
begin
  Result := PageControl.Pages[AIndex].FindComponent(TJeezEditor.ClassName) as TJeezEditor;
  Assert(Assigned(Result));
end;

function TJeezIde.GetActiveEditor: TJeezEditor;
begin
  Result := GetEditor(PageControl.ActivePageIndex);
end;

function TJeezIde.CreateEditor(const AFileName: String): TJeezEditor;
var
  LTabSheet: TTabSheet;
begin
  LTabSheet := PageControl.AddTabSheet;
  LTabSheet.OnShow := DoOnTabSheetShow;
  LTabSheet.BorderSpacing.Left := 0;
  LTabSheet.BorderSpacing.Right := 2;
  LTabSheet.BorderSpacing.Top := 2;
  LTabSheet.BorderSpacing.Bottom := 2;
  Result := TJeezEditor.Create(LTabSheet);
  Result.Name := Result.ClassName;
  Result.Align := alClient;
  Result.Parent := PanelClient;
  Result.LoadFromUntitled(AFileName);
  // TODO: This needs to be tested.
  if GPlatform.IsWindows9x then
  begin
    Result.PanelTop.Color := clBtnFace;
    Result.PanelTop.ParentColor := False;
  end else begin
    //Result.PanelTop.Color := clNone;
    //Result.PanelTop.ParentColor := True;
  end;
  Result.PanelTop.Parent := LTabSheet;
  LTabSheet.Show;
  DoOnTabSheetShow(LTabSheet);
end;

function TJeezIde.GetPageIndexByFileName(const AFileName: TFileName): Integer;
begin
  for Result := IndexFirst(PageControl) to IndexLast(PageControl) do
  begin
    if SameFilename(GetEditor(Result).FileName, AFileName) then
    begin
      Exit;
    end;
  end;
  Result := -1;
end;

function TJeezIde.LoadFromFile(const AFileName: TFileName): TJeezEditor;
var
  LIndex: Integer;
begin
  JeezConsole.EnsureEditorVisible;
  LIndex := GetPageIndexByFileName(AFileName);
  if LIndex >= 0 then
  begin
    PageControl.ActivePageIndex := LIndex;
    Result := GetEditor(LIndex);
  end else begin
    JeezConsole.LogTextFileExists(AFileName);
    MenuFileNew.Click;
    Result := GetActiveEditor;
    Result.LoadFromFile(AFileName);
  end;
end;

function TJeezIde.LoadFromFile(const AFileName: TFileName; const ACaretY: Integer): TJeezEditor;
begin
  Result := LoadFromFile(AFileName);
  GJeezSynEdit.SetCaretYCentered(Result.SynEdit, ACaretY);
end;

function TJeezIde.LoadFromPath(const AFilePath: TFileName): TJeezEditor;
begin
  JeezData.OpenDialog.InitialDir := AFilePath;
  JeezData.OpenDialog.FileName := EmptyStr;
  if JeezData.OpenDialog.Execute then
  begin
    Result := LoadFromFile(JeezData.OpenDialog.Filename);
  end else begin
    Abort;
  end;
end;

procedure TJeezIde.MenuToolsOpenCppOutputFileClick(ASender: TObject);
begin
  LoadFromFile(GFileName.FileNameOutputCpp);
end;

procedure TJeezIde.MenuToolsOpenPluginInHostClick(ASender: TObject);
var
  LFileName: TFileName;
begin
  LFileName := GetActiveEditor.GetFileNamePlugin;
  if not FileExists(LFileName) then
  begin
    if MessageDlg(Format(SMsgPluginDoesNotExistWouldYouLikeToBuildInstallIt1, [LFileName]),
      mtConfirmation, [mbYes, mbNo], ZeroValue) = mrYes then
    begin
      MenuToolsBuildAndInstallPlugin.Click;
    end else begin
      Abort;
    end;
  end;
  JeezConsole.LogFileExists(LFileName);
  with TProcess.Create(Self) do
  begin
    try
      Executable := GFileName.FileNameSaviHost(JeezOptions.GetArchitecture = ca64bit);
      Parameters.Add(LFileName);
      Execute;
    finally
      Free;
    end;
  end;
end;

procedure TJeezIde.MenuToolsExploreOutputFolderClick(ASender: TObject);
begin
  OpenUrl(GFilePath.TempBuild);
end;

procedure TJeezIde.MenuToolsOptionsClick(ASender: TObject);
begin
  GetActiveEditor.ShowToolOptions;
end;

procedure TJeezIde.PageControlMouseDown(ASender: TObject; AMouseButton: TMouseButton;
  AShiftState: TShiftState; AX, AY: Integer);
begin
  if AMouseButton = mbRight then
  begin
    AX := PageControl.IndexOfTabAt(AX, AY);
    if AX >= ZeroValue then
    begin
      PageControl.ActivePageIndex := AX;
    end;
  end;
end;

procedure TJeezIde.MenuPageControlPopup(ASender: TObject);
begin
  MenuPopupCloseAllOtherPages.Enabled := IndexCount(PageControl) > 1;
  MenuPopupSave.Caption := GsSave + CharSpace +
    QuotedStr(ExtractFilename(GetActiveEditor.FileName));
  MenuPopupOpenContainingFolder.Enabled :=
    DirectoryExists(ExtractFilePath(GetActiveEditor.FileName));
end;

procedure TJeezIde.MenuToolsSyntaxCheckClick(ASender: TObject);
begin
  GetActiveEditor.ButtonSyntaxCheck.Click;
end;

procedure TJeezIde.PageControlCloseTabClicked(ASender: TObject);
begin
  MenuFileClose.Click;
end;

procedure TJeezIde.MenuToolsClick(ASender: TObject);
begin
  MenuToolsOpenCppOutputFile.Enabled := FileExists(GFileName.FileNameOutputCpp);
end;

procedure TJeezIde.MenuToolsBuildPluginClick(ASender: TObject);
begin
  SelectJsFxEditor;
  JeezConsole.BuildPlugin(GetActiveEditor);
end;

procedure TJeezIde.MenuToolsBuildAndInstallPluginClick(ASender: TObject);
begin
  SelectJsFxEditor;
  JeezConsole.BuildAndInstallPlugin(GetActiveEditor);
end;

procedure TJeezIde.MenuToolsConvertEffectToImportModuleClick(ASender: TObject);
var
  LStrings: TStrings;
begin
  if JeezData.OpenDialog.Execute then
  begin
    LStrings := TStringList.Create;
    try
      J2C_ImportModule(LStrings, JeezData.OpenDialog.FileName);
      CreateEditor(ChangeFileExt(ExtractFileName(JeezData.OpenDialog.FileName),
        GsFileExtJsfxInc)).SynEdit.Lines.Assign(LStrings);
    finally
      FreeAndNil(LStrings);
    end;
  end;
end;

procedure TJeezIde.UpdateAllEditors;
var
  LIndex: Integer;
begin
  JeezOptions.ApplySynCppSyn(JeezData.SynCppSyn);
  JeezOptions.ApplySynEdit(JeezConsole.SynEdit, JeezOptions.ColorInfoBlocks.Selected);
  JeezOptions.ApplySynAnySyn(JeezConsole.SynAnySyn, True);
  for LIndex := IndexFirst(PageControl) to IndexLast(PageControl) do
  begin
    GetEditor(LIndex).ApplyColors;
  end;
end;

end.

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
  Classes, ComCtrls, Controls, Dialogs, ExtCtrls, FileUtil, Forms, Graphics, JeezResources, JeezSynEdit, JeezUtils,
  Jes2CppCompiler, Jes2CppConstants, Jes2CppFileNames, Jes2CppIterate, Jes2CppModuleImporter, Jes2CppPlatform,
  Jes2CppTranslate, Jes2CppUtils, LclIntf, LCLProc, Menus, PopupNotifier, Process, StrUtils, SynEdit, SynEditTypes,
  SysUtils, Types, UJeezEditor, UJeezMessages;

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
    MenuToolsOpenPluginInHost: TMenuItem;
    MenuToolsSep4: TMenuItem;
    MenuRecentFile: TMenuItem;
    MenuToolsOpenCppOutputFile: TMenuItem;
    MenuToolsEditSliders: TMenuItem;
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
    MenuToolsOpenOutputFolder: TMenuItem;
    MenuPageControl: TPopupMenu;
    MenuRecentFiles: TPopupMenu;
    PanelBody: TPanel;
    PopupNotifier: TPopupNotifier;
    ButtonShowOutput: TToolButton;
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
    procedure MenuEditCopyClick(ASender: TObject);
    procedure MenuEditCutClick(ASender: TObject);
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
    procedure MenuFileSaveAsClick(ASender: TObject);
    procedure MenuFileSaveClick(ASender: TObject);
    procedure MenuHelpAboutJeezClick(ASender: TObject);
    procedure MenuHelpGotoJeezOnlineClick(ASender: TObject);
    procedure MenuFileOpenReaperClick(ASender: TObject);
    procedure MenuToolsOpenPluginInHostClick(ASender: TObject);
    procedure MenuPopupOpenContainingFolderClick(ASender: TObject);
    procedure MenuRecentFilesPopup(ASender: TObject);
    procedure MenuToolsBuildAndInstallPluginClick(ASender: TObject);
    procedure MenuToolsBuildPluginClick(ASender: TObject);
    procedure MenuToolsClick(ASender: TObject);
    procedure MenuToolsEditSlidersClick(ASender: TObject);
    procedure MenuToolsConvertEffectToImportModuleClick(ASender: TObject);
    procedure MenuToolsOpenCppOutputFileClick(ASender: TObject);
    procedure MenuToolsOpenOutputFolderClick(ASender: TObject);
    procedure MenuToolsOptionsClick(ASender: TObject);
    procedure MenuToolsSyntaxCheckClick(ASender: TObject);
    procedure PageControlCloseTabClicked(ASender: TObject);
    procedure PageControlMouseDown(ASender: TObject; AMouseButton: TMouseButton; AShiftState: TShiftState; AX, AY: Integer);
    procedure MenuPageControlPopup(ASender: TObject);
  strict private
    procedure DoTabSheetShow(ASender: TObject);
  public
    procedure UpdateColors;
    procedure UpdateTabSheet(const ATabSheet: TTabSheet);
    procedure ShowPopupNotifier(const ATitle, AText: String);
    procedure HidePopupNotifier;
  public
    function GetEditor(const AIndex: Integer): TJeezEditor;
    function GetPageIndexByFileName(const AFileName: TFileName): Integer;
    function GetActiveEditor: TJeezEditor;
    function NewEditor(const AFileName: String): TJeezEditor;
    function LoadFromFile: TJeezEditor; overload;
    function LoadFromFile(const AFileName: TFileName): TJeezEditor; overload;
    function LoadFromFile(const AFileName: TFileName; const ACaretY: Integer): TJeezEditor; overload;
  end;

var
  JeezIde: TJeezIde;

implementation

{$R *.lfm}

uses UJeezBuild, UJeezData, UJeezGuiEditor, UJeezOptions;

procedure PlatformLoadFromFile(const AFileName: TFileName);
begin
  JeezIde.LoadFromFile(AFileName);
end;

procedure TJeezIde.FormCreate(ASender: TObject);
begin
  J2C_SingleInstanceInit(Handle, GsJeezTitle, PlatformLoadFromFile);
  J2C_ScrollingWinControlPrepare(Self);
  // We must set the default size here so form centering is correct.
  Width := GiFormWidth;
  Height := GiFormHeight;
{$IFDEF LINUX}
  MenuFileOpenReaper.Visible := False;
  MenuFileOpenReaper.Enabled := False;
{$ENDIF}
end;

procedure TJeezIde.FormShow(ASender: TObject);
var
  LIndex: Integer;
begin
  UpdateColors;
  WindowState := wsMaximized;
{$IF DEFINED(WINDOWS)}
  ToolBar.Color := clMenu;
  //PanelBody.Color := $ddaaaa;
{$ELSEIF DEFINED(LINUX)}
  PanelBody.Color := $aa8866;
  ToolBar.Color := clDefault;
{$ELSE}
{$ERROR}
{$ENDIF}
  for LIndex := 0 to ToolBar.ButtonCount - 1 do
  begin
    ToolBar.Buttons[LIndex].Caption := CharSpace + Trim(ToolBar.Buttons[LIndex].Caption) + CharSpace;
  end;
  PanelBottom.Height := GiDefaultMessageLogHeight;
  JeezMessages.Parent := TabSheetMessages;
  JeezMessages.Visible := True;

  JeezMessages.LogMessage(GsCppCommentSpace + GsJeezTitle);
  JeezMessages.LogMessage(GsCppCommentSpace + SMsgIncludes + CharSpace + GsJes2CppTitle);
  JeezMessages.LogMessage(GsCppCommentSpace + GsJes2CppSlogan);
  JeezMessages.LogMessage(EmptyStr);

  for LIndex := 1 to ParamCount do
  begin
    try
      LoadFromFile(ParamStr(LIndex));
    except
      on LException: Exception do
      begin
        JeezMessages.LogMessage(LException.Message);
      end;
    end;
  end;
  if ItemCount(PageControl) = M_ZERO then
  begin
    MenuFileNew.Click;
  end;
end;

procedure TJeezIde.ShowPopupNotifier(const ATitle, AText: String);
begin
  PopupNotifier.Title := ATitle;
  PopupNotifier.Text := AText;
  PopupNotifier.ShowAtPos(Mouse.CursorPos.X, Mouse.CursorPos.Y);
  GetActiveEditor.SynEdit.SetFocus;
end;

procedure TJeezIde.HidePopupNotifier;
begin
  PopupNotifier.Hide;
end;

procedure TJeezIde.ApplicationPropertiesException(ASender: TObject; AException: Exception);
begin
  try
    LoadFromFile(J2C_ExtractFileName(AException.Message), J2C_ExtractFileLine(AException.Message));
  except
  end;
  MessageDlg(AException.Message, mtInformation, [mbOK], M_ZERO);
  GetActiveEditor.SynEdit.SetFocus;
end;

procedure TJeezIde.ApplicationPropertiesDropFiles(ASender: TObject; const AFileNames: array of String);
var
  LFileName: TFileName;
begin
  for LFileName in AFileNames do
  begin
    LoadFromFile(LFileName);
  end;
end;

procedure TJeezIde.FindDialogClose(ASender: TObject);
begin
  MenuEditUndo.Enabled := True;
  MenuEditRedo.Enabled := True;
  MenuEditCut.Enabled := True;
  MenuEditCopy.Enabled := True;
  MenuEditPaste.Enabled := True;
  MenuEditDelete.Enabled := True;
  MenuEditSelectAll.Enabled := True;
end;

procedure TJeezIde.FindDialogShow(ASender: TObject);
begin
  MenuEditUndo.Enabled := False;
  MenuEditRedo.Enabled := False;
  MenuEditCut.Enabled := False;
  MenuEditCopy.Enabled := False;
  MenuEditPaste.Enabled := False;
  MenuEditDelete.Enabled := False;
  MenuEditSelectAll.Enabled := False;
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
      if MessageDlg(Format(SMsgSearchCompleted1, [IfThen(ssoBackwards in LOptions, 'end', 'beginning')]),
        mtConfirmation, [mbYes, mbNo], M_ZERO) = mrYes then
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

procedure TJeezIde.MenuEditPasteClick(ASender: TObject);
begin
  GetActiveEditor.SynEdit.PasteFromClipboard;
end;

procedure TJeezIde.MenuEditRedoClick(ASender: TObject);
begin
  GetActiveEditor.SynEdit.Redo;
end;

procedure TJeezIde.MenuEditSelectAllClick(ASender: TObject);
begin
  GetActiveEditor.SynEdit.SelectAll;
end;

procedure TJeezIde.MenuEditUndoClick(ASender: TObject);
begin
  GetActiveEditor.SynEdit.Undo;
end;

procedure TJeezIde.MenuFileClick(ASender: TObject);
begin
  MenuFileSave.Enabled := GetActiveEditor.SynEdit.Modified;
  MenuFileCloseAllOtherPages.Enabled := ItemCount(PageControl) > 1;
end;

procedure TJeezIde.MenuFileCloseAllClick(ASender: TObject);
var
  LIndex: Integer;
begin
  for LIndex := ItemLast(PageControl) downto ItemFirst(PageControl) do
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
  for LIndex := ItemLast(PageControl) downto ItemFirst(PageControl) do
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
    case MessageDlg(Format(SMsgDoYouWantToSaveModifiedFile1, [ExtractFilename(GetActiveEditor.Filename)]),
        mtConfirmation, [mbYes, mbNo, mbCancel], M_ZERO) of
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
  if ItemCount(PageControl) = M_ZERO then
  begin
    MenuFileExit.Click;
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
    TJeezSynEdit.SynCustomHighlighterExport(GetActiveEditor.SynEdit.Highlighter, GetActiveEditor.SynEdit.Lines,
      JeezData.SaveDialogHtml.Filename);
  end;
end;

procedure TJeezIde.MenuFileNewClick(ASender: TObject);
begin
  NewEditor('untitled' + GsFileExtJsFx);
end;

procedure TJeezIde.MenuFileOpenClick(ASender: TObject);
begin
  JeezData.OpenDialog.InitialDir := ExtractFilePath(GetActiveEditor.Filename);
  JeezData.OpenDialog.FileName := EmptyStr;
  LoadFromFile;
end;

procedure TJeezIde.MenuFileEffectPropertiesClick(ASender: TObject);
begin
  GetActiveEditor.MenuPopupProperties.Click;
end;

procedure TJeezIde.MenuFileSaveAsClick(ASender: TObject);
begin
  JeezData.SaveDialog.FileName := ExtractFilename(GetActiveEditor.Filename);
  JeezData.SaveDialog.InitialDir := ExtractFileDir(GetActiveEditor.Filename);
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
  ShowMessage(GsJeezTitle + LineEnding + GsJes2CppTitle + LineEnding + LineEnding + GsJes2CppCopyright +
    LineEnding + LineEnding + GsJes2CppLicense + LineEnding + LineEnding + GsJes2CppWebsite);
end;

procedure TJeezIde.MenuHelpGotoJeezOnlineClick(ASender: TObject);
begin
  OpenUrl(GsJes2CppWebsite);
end;

procedure TJeezIde.MenuFileOpenReaperClick(ASender: TObject);
begin
  JeezData.OpenDialog.InitialDir := TJes2CppFileNames.PathToReaperEffects;
  JeezData.OpenDialog.FileName := EmptyStr;
  LoadFromFile;
end;

procedure TJeezIde.MenuPopupOpenContainingFolderClick(ASender: TObject);
begin
  OpenUrl(ExtractFilePath(GetActiveEditor.Filename));
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
    for LIndex := ItemFirst(JeezOptions.EditRecentFiles.Items) to ItemLast(JeezOptions.EditRecentFiles.Items) do
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
  LEditor := GetActiveEditor;
  LFileName := LEditor.Filename;
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

procedure TJeezIde.DoTabSheetShow(ASender: TObject);
begin
  UpdateTabSheet(ASender as TTabSheet);
  HidePopupNotifier;
  //GetActiveEditor.TimerCodeInsight.Enabled := False;
  //GetActiveEditor.TimerCodeInsight.Enabled := True;
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

function TJeezIde.NewEditor(const AFileName: String): TJeezEditor;
var
  LTabSheet: TTabSheet;
begin
  LTabSheet := PageControl.AddTabSheet;
  LTabSheet.OnShow := DoTabSheetShow;
  Result := TJeezEditor.Create(LTabSheet);
  Result.Name := Result.ClassName;
  Result.Align := alClient;
  Result.Parent := LTabSheet;
  Result.LoadFromUntitled(AFileName);
  LTabSheet.Show;
end;

function TJeezIde.GetPageIndexByFileName(const AFileName: TFileName): Integer;
begin
  for Result := ItemFirst(PageControl) to ItemLast(PageControl) do
  begin
    if SameFilename(GetEditor(Result).Filename, AFileName) then
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
  LIndex := GetPageIndexByFileName(AFileName);
  if LIndex >= 0 then
  begin
    PageControl.ActivePageIndex := LIndex;
    Result := GetActiveEditor;
  end else begin
    JeezMessages.LogTextFileExists(AFileName);
    MenuFileNew.Click;
    Result := GetActiveEditor;
    Result.LoadFromFile(AFileName);
    if not SameText(ExtractFileExt(AFileName), GsFileExtJsFxInc) then
    begin
      JeezOptions.AddRecentFile(AFileName);
    end;
  end;
end;

function TJeezIde.LoadFromFile(const AFileName: TFileName; const ACaretY: Integer): TJeezEditor;
begin
  Result := LoadFromFile(AFileName);
  Result.SynEdit.CaretY := ACaretY;
end;

function TJeezIde.LoadFromFile: TJeezEditor;
begin
  if JeezData.OpenDialog.Execute then
  begin
    Result := LoadFromFile(JeezData.OpenDialog.Filename);
  end else begin
    Abort;
  end;
end;

procedure TJeezIde.MenuToolsOpenCppOutputFileClick(ASender: TObject);
begin
  LoadFromFile(TJes2CppFileNames.FileNameOutputCpp);
end;

procedure TJeezIde.MenuToolsOpenPluginInHostClick(ASender: TObject);
var
  LFileName: TFileName;
begin
  LFileName := GetActiveEditor.GetPluginFileName;
  if not FileExists(LFileName) then
  begin
    if MessageDlg(Format(SMsgPluginDoesNotExistWouldYouLikeToBuildInstallIt1, [LFileName]), mtConfirmation,
      [mbYes, mbNo], M_ZERO) = mrYes then
    begin
      MenuToolsBuildAndInstallPlugin.Click;
    end else begin
      Abort;
    end;
  end;
  JeezMessages.LogFileExists(LFileName);
  with TProcess.Create(Self) do
  begin
    try
      Executable := TJes2CppFileNames.FileNameSaviHost(JeezOptions.GetTypeProcessor = pt64bit);
      Parameters.Add(LFileName);
      Execute;
    finally
      Free;
    end;
  end;
end;

procedure TJeezIde.MenuToolsOpenOutputFolderClick(ASender: TObject);
begin
  OpenUrl(TJes2CppFileNames.PathToTempBuild);
end;

procedure TJeezIde.MenuToolsOptionsClick(ASender: TObject);
begin
  JeezOptions.Execute;
end;

procedure TJeezIde.PageControlMouseDown(ASender: TObject; AMouseButton: TMouseButton; AShiftState: TShiftState; AX, AY: Integer);
begin
  if AMouseButton = mbRight then
  begin
    AX := PageControl.IndexOfTabAt(AX, AY);
    if AX >= M_ZERO then
    begin
      PageControl.ActivePageIndex := AX;
    end;
  end;
end;

procedure TJeezIde.MenuPageControlPopup(ASender: TObject);
begin
  MenuPopupCloseAllOtherPages.Enabled := ItemCount(PageControl) > 1;
  MenuPopupSave.Caption := GsSave + CharSpace + QuotedStr(ExtractFilename(GetActiveEditor.Filename));
  MenuPopupOpenContainingFolder.Enabled := DirectoryExists(ExtractFilePath(GetActiveEditor.Filename));
end;

procedure TJeezIde.MenuToolsSyntaxCheckClick(ASender: TObject);
begin
  GetActiveEditor.ButtonSyntaxCheck.Click;
end;

procedure TJeezIde.PageControlCloseTabClicked(ASender: TObject);
begin
  MenuFileClose.Click;
end;

procedure TJeezIde.MenuToolsBuildPluginClick(ASender: TObject);
begin
  while SameText(ExtractFileExt(GetActiveEditor.Filename), GsFileExtJsFxInc) do
  begin
    if PageControl.ActivePageIndex = 0 then
    begin
      JeezMessages.LogException(SMsgUnableToCompileIncludeFile);
    end else begin
      PageControl.SelectNextPage(False);
    end;
  end;
  JeezMessages.ButtonShowMessages.Click;
  try
    JeezBuild.Execute;
  finally
    JeezMessages.ButtonHideMessages.Click;
    JeezMessages.SynEdit.EnsureCursorPosVisible;
  end;
end;

procedure TJeezIde.MenuToolsClick(ASender: TObject);
begin
  MenuToolsOpenCppOutputFile.Enabled := FileExists(TJes2CppFileNames.FileNameOutputCpp);
  //MenuToolsOpenPluginInHost.Enabled := FileExists(GetActiveEditor.GetPluginFileName);
end;

procedure TJeezIde.MenuToolsEditSlidersClick(ASender: TObject);
begin
  JeezGuiEditor.Execute(GetActiveEditor.SynEdit.Lines);
end;

procedure TJeezIde.MenuToolsConvertEffectToImportModuleClick(ASender: TObject);
var
  LModule: TStrings;
begin
  if JeezData.OpenDialog.Execute then
  begin
    LModule := TStringList.Create;
    try
      J2C_ImportModule(LModule, JeezData.OpenDialog.FileName);
      NewEditor(ChangeFileExt(ExtractFileName(JeezData.OpenDialog.FileName), GsFileExtJsfxInc)).SynEdit.Lines.Assign(LModule);
    finally
      FreeAndNil(LModule);
    end;
  end;
end;

procedure TJeezIde.MenuToolsBuildAndInstallPluginClick(ASender: TObject);
var
  LFileName: TFileName;
begin
  MenuToolsBuildPlugin.Click;
  Screen.Cursor := crHourGlass;
  try
    LFileName := GetActiveEditor.GetPluginFileName;
    try
      if not FileUtil.CopyFile(JeezBuild.OutputFile, LFileName) then
      begin
        Abort;
      end;
      JeezMessages.LogFileName(SMsgPluginHasBeenInstalled, LFileName);
    except
      on LException: Exception do
      begin
        JeezMessages.LogMessage(LException.Message);
        JeezMessages.LogException(SMsgPluginFailedToInstall);
      end;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TJeezIde.UpdateColors;
var
  LIndex: Integer;
begin
  JeezOptions.ApplySynCppSyn(JeezData.SynCppSyn);
  JeezOptions.ApplySynEdit(JeezMessages.SynEdit, JeezOptions.ColorInfoBlocks.Selected);
  JeezOptions.ApplySynAnySyn(JeezMessages.SynAnySyn, True);
  for LIndex := ItemFirst(PageControl) to ItemLast(PageControl) do
  begin
    GetEditor(LIndex).ApplyColors;
  end;
end;

end.

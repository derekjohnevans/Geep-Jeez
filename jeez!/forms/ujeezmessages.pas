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

unit UJeezMessages;

{$MODE DELPHI}

interface

uses
  Classes, ComCtrls, Controls, FileUtil, Forms, Graphics, JeezResources,
  Jes2CppConstants, Jes2CppMessageLog,
  Jes2CppUtils, Math, SynEdit, SynHighlighterAny, SysUtils, UJeezEditor;

const

  GiDefaultMessageLogHeight = 200;
  GiMaxMessageCount = 512;

type

  { TJeezConsole }

  TJeezConsole = class(TForm)
    ButtonHideMessages: TToolButton;
    ButtonShowMessages: TToolButton;
    SynAnySyn: TSynAnySyn;
    SynEdit: TSynEdit;
    ToolBar: TToolBar;
    procedure ButtonHideMessagesClick(ASender: TObject);
    procedure ButtonShowMessagesClick(ASender: TObject);
    procedure FormCreate(ASender: TObject);
    procedure FormShow(ASender: TObject);
    procedure SynEditMouseDown(ASender: TObject; AButton: TMouseButton;
      AShift: TShiftState; AX, AY: Integer);
  private
    procedure DoOnPaint(ASender: TObject);
  public
    procedure LogMessage(const AMessage: String); overload;
    procedure LogMessage(const AType, AMessage: String); overload;
    procedure LogFileName(const ATask, AFileName: String);
    procedure LogException(const AMessage: String);
    procedure LogFileNameIsAbsolute(const AFileName: TFileName);
    procedure LogFileExists(const AFileName: TFileName);
    procedure LogTextFileExists(const AFileName: TFileName);
  public
    procedure BuildPlugin(const AEditor: TJeezEditor);
    procedure BuildAndInstallPlugin(const AEditor: TJeezEditor);
  public
    procedure EnsureEditorVisible;
  end;

var
  JeezConsole: TJeezConsole;

implementation

{$R *.lfm}

uses UJeezBuild, UJeezIde, UJeezOptions;

procedure TJeezConsole.FormCreate(ASender: TObject);
begin
  ToolBar.OnPaint := DoOnPaint;
end;

procedure TJeezConsole.DoOnPaint(ASender: TObject);
begin
  with ASender as TCustomControl do
  begin
    Canvas.GradientFill(ClientRect, clBtnHighlight, clBtnShadow, gdHorizontal);
  end;
end;

procedure TJeezConsole.FormShow(ASender: TObject);
begin
  JeezOptions.ApplySynEdit(SynEdit, JeezOptions.ColorInfoBlocks.Selected);
  JeezOptions.ApplySynAnySyn(SynAnySyn, True);
  with SynAnySyn.Objects do
  begin
    Add(UpperCase(SMsgTypeSyntaxChecking));
    Add(UpperCase(SMsgTypeLoaded));
    Add(UpperCase(SMsgTypeSaving));
    Add(UpperCase(SMsgTypeGeneral));
    Add(UpperCase('COLLECT_GCC'));
    Add(UpperCase('COLLECT_LTO_WRAPPER'));
    Add(UpperCase('LIBRARY_PATH'));
    Add(UpperCase('COMPILER_PATH'));
    Add(UpperCase('COLLECT_GCC_OPTIONS'));
  end;
  with SynAnySyn.Constants do
  begin
    Add(UpperCase(SMsgTypeError));
    Add(UpperCase(SMsgTypeException));
  end;
  with SynAnySyn.KeyWords do
  begin
    Add(UpperCase(SMsgTranspile));
    Add(UpperCase(SMsgCompiling));
  end;
end;

procedure TJeezConsole.SynEditMouseDown(ASender: TObject; AButton: TMouseButton;
  AShift: TShiftState; AX, AY: Integer);
begin
  try
    JeezIde.LoadFromFile(GUtils.ExtractFileSource(SynEdit.LineText),
      GUtils.ExtractFileCaretY(SynEdit.LineText));
  except
  end;
end;

procedure TJeezConsole.LogMessage(const AMessage: String);
begin
  while SynEdit.Lines.Count > GiMaxMessageCount do
  begin
    SynEdit.Lines.Delete(ZeroValue);
  end;
  SynEdit.CaretY := SynEdit.Lines.Add(AMessage) + 1;
end;

procedure TJeezConsole.LogMessage(const AType, AMessage: String);
begin
  LogMessage(AType + CharSpace + AMessage);
end;

procedure TJeezConsole.LogFileName(const ATask, AFileName: String);
begin
  LogMessage(GMessageLog.TypeFileName(ATask, AFileName));
end;

procedure TJeezConsole.LogException(const AMessage: String);
begin
  LogMessage(GMessageLog.TypeMessage(SMsgTypeException, AMessage));
  raise Exception.Create(AMessage);
end;

procedure TJeezConsole.LogFileNameIsAbsolute(const AFileName: TFileName);
begin
  if not FilenameIsAbsolute(AFileName) then
  begin
    raise Exception.Create(SMsgFileNameMustBeAbsolute);
  end;
end;

procedure TJeezConsole.LogFileExists(const AFileName: TFileName);
begin
  if not FileExists(AFileName) then
  begin
    LogException(Format(SMsgFileDoesNotExist1, [AFileName]));
  end;
  LogFileNameIsAbsolute(AFileName);
end;

procedure TJeezConsole.LogTextFileExists(const AFileName: TFileName);
begin
  LogFileExists(AFileName);
  if not FileIsText(AFileName) then
  begin
    LogException(Format(SMsgFileIsNotText1, [AFileName]));
  end;
end;

procedure TJeezConsole.EnsureEditorVisible;
begin
  if not JeezIde.PanelClient.Visible then
  begin
    JeezIde.PanelBottom.Align := alBottom;
    JeezIde.SplitterBottom.Visible := True;
    JeezIde.PanelClient.Visible := True;
    ButtonShowMessages.Visible := True;
  end;
end;

procedure TJeezConsole.ButtonShowMessagesClick(ASender: TObject);
begin
  if JeezIde.PanelBottom.Height = JeezIde.PanelBottom.Constraints.MinHeight then
  begin
    JeezIde.PanelBottom.Height := GiDefaultMessageLogHeight;
  end else if JeezIde.PanelClient.Visible then
  begin
    JeezIde.PanelClient.Visible := False;
    JeezIde.SplitterBottom.Visible := False;
    JeezIde.PanelBottom.Align := alClient;
    ButtonShowMessages.Visible := False;
  end;
  Application.ProcessMessages;
end;

procedure TJeezConsole.ButtonHideMessagesClick(ASender: TObject);
begin
  if JeezIde.PanelClient.Visible then
  begin
    JeezIde.PanelBottom.Height := JeezIde.PanelBottom.Constraints.MinHeight;
  end else begin
    EnsureEditorVisible;
  end;
  Application.ProcessMessages;
end;

procedure TJeezConsole.BuildPlugin(const AEditor: TJeezEditor);
begin
  ButtonShowMessages.Click;
  try
    JeezBuild.Execute(AEditor);
  finally
    ButtonHideMessages.Click;
    SynEdit.EnsureCursorPosVisible;
  end;
end;

procedure TJeezConsole.BuildAndInstallPlugin(const AEditor: TJeezEditor);
var
  LFileName: TFileName;
begin
  BuildPlugin(AEditor);
  Screen.Cursor := crHourGlass;
  try
    LFileName := AEditor.GetFileNamePlugin;
    try
      if not FileUtil.CopyFile(JeezBuild.OutputFile, LFileName) then
      begin
        Abort;
      end;
      LogFileName(SMsgPluginHasBeenInstalled, LFileName);
    except
      on LException: Exception do
      begin
        LogMessage(LException.Message);
        LogException(SMsgPluginFailedToInstall);
      end;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

end.

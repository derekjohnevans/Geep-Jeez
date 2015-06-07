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
  ComCtrls, Controls, FileUtil, Forms, JeezResources, JeezUtils, Jes2CppConstants, Jes2CppMessageLog,
  SynEdit, SynHighlighterAny, SysUtils;

const

  GiDefaultMessageLogHeight = 200;

type

  { TJeezMessages }

  TJeezMessages = class(TForm)
    ButtonHideMessages: TToolButton;
    ButtonShowMessages: TToolButton;
    SynAnySyn: TSynAnySyn;
    SynEdit: TSynEdit;
    ToolBarMessageLog: TToolBar;
    procedure ButtonHideMessagesClick(ASender: TObject);
    procedure ButtonShowMessagesClick(ASender: TObject);
    procedure FormShow(ASender: TObject);
  private
  public
    procedure LogMessage(const AMessage: String); overload;
    procedure LogMessage(const AType, AMessage: String); overload;
    procedure LogFileName(const ATask, AFileName: String);
    procedure LogException(const AMessage: String);
    procedure LogFileExists(const AFileName: TFileName);
    procedure LogTextFileExists(const AFileName: TFileName);
  end;

var
  JeezMessages: TJeezMessages;

implementation

{$R *.lfm}

uses UJeezIde, UJeezOptions;

procedure TJeezMessages.FormShow(ASender: TObject);
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
    Add(UpperCase(Jeez_Jes2Cpp.ClassName));
    Add(UpperCase(Jeez_Compile.ClassName));
  end;
end;

procedure TJeezMessages.LogMessage(const AMessage: String);
begin
  while SynEdit.Lines.Count > 512 do
  begin
    SynEdit.Lines.Delete(M_ZERO);
  end;
  SynEdit.CaretY := SynEdit.Lines.Add(AMessage) + 1;
end;

procedure TJeezMessages.LogMessage(const AType, AMessage: String);
begin
  LogMessage(AType + CharSpace + AMessage);
end;

procedure TJeezMessages.LogFileName(const ATask, AFileName: String);
begin
  LogMessage(J2C_StringLogFileName(ATask, AFileName));
end;

procedure TJeezMessages.LogException(const AMessage: String);
begin
  LogMessage(J2C_StringLogMessage(SMsgTypeException, AMessage));
  raise Exception.Create(AMessage);
end;

procedure TJeezMessages.LogFileExists(const AFileName: TFileName);
begin
  if not FilenameIsAbsolute(AFileName) then
  begin
    raise Exception.Create(SMsgFileNameMustBeAbsolute);
  end;
  if not FileExists(AFileName) then
  begin
    LogException(Format(SMsgFileDoesNotExist1, [AFileName]));
  end;
end;

procedure TJeezMessages.LogTextFileExists(const AFileName: TFileName);
begin
  LogFileExists(AFileName);
  if not FileIsText(AFileName) then
  begin
    LogException(Format(SMsgFileIsNotText1, [AFileName]));
  end;
end;

procedure TJeezMessages.ButtonShowMessagesClick(ASender: TObject);
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

procedure TJeezMessages.ButtonHideMessagesClick(ASender: TObject);
begin
  if JeezIde.PanelClient.Visible then
  begin
    JeezIde.PanelBottom.Height := JeezIde.PanelBottom.Constraints.MinHeight;
  end else begin
    JeezIde.PanelBottom.Align := alBottom;
    JeezIde.SplitterBottom.Visible := True;
    JeezIde.PanelClient.Visible := True;
    ButtonShowMessages.Visible := True;
  end;
  Application.ProcessMessages;
end;

end.


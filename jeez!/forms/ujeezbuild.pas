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

unit UJeezBuild;

{$MODE DELPHI}

interface

uses
  Buttons, ComCtrls, Controls, ExtCtrls, Forms, JeezResources, JeezUtils,
  Jes2CppCompiler, Jes2CppConstants,
  Jes2CppProcess, SysUtils, UJeezEditor;

type

  { TJeezBuild }

  TJeezBuild = class(TForm)
    ButtonAbortBuild: TBitBtn;
    ProgressBar: TProgressBar;
    Timer: TTimer;
    procedure ButtonAbortBuildClick(ASender: TObject);
    procedure FormPaint(ASender: TObject);
    procedure TimerTimer(ASender: TObject);
  private
    FCaption, FExceptionMessage: String;
    FStartTime: TTime;
    FOutputFile: TFileName;
    FCompiler: CJes2CppCompiler;
    FEditor: TJeezEditor;
  public
    function Execute(const AEditor: TJeezEditor): Boolean;
    property OutputFile: TFileName read FOutputFile;
  end;

var
  JeezBuild: TJeezBuild;

implementation

{$R *.lfm}

uses UJeezMessages, UJeezOptions;

function TJeezBuild.Execute(const AEditor: TJeezEditor): Boolean;
begin
  Assert(Assigned(AEditor));
  FEditor := AEditor;
  FCaption := SMsgTypeBuilding + CharSpace +
    UpperCase(CJes2CppCompiler.TypePluginAsString(JeezOptions.GetPluginType)) +
    CharSpace + GsPlugin + CharSpace + CharOpeningParenthesis;
  case JeezOptions.GetArchitecture of
    ca32bit: begin
      FCaption += Gs32Bit + CharSpace + SMsgArchitecture;
    end;
    ca64bit: begin
      FCaption += Gs64Bit + CharSpace + SMsgArchitecture;
    end;
  end;
  FCaption += CharSlashForward;
  case JeezOptions.GetPrecision of
    cfpSingle: begin
      FCaption += Gs32Bit + CharSpace + SMsgPrecision;
    end;
    cfpDouble: begin
      FCaption += Gs64Bit + CharSpace + SMsgPrecision;
    end;
  end;
  FCaption += CharClosingParenthesis;
  Caption := FCaption;
  FStartTime := Now;
  OnPaint := FormPaint;
  Timer.Enabled := True;
  ProgressBar.Position := 0;
  ButtonAbortBuild.Enabled := True;
  FExceptionMessage := EmptyStr;
  Result := ShowModal = mrOk;
  if FExceptionMessage <> EmptyStr then
  begin
    raise Exception.Create(FExceptionMessage);
  end;
  if ModalResult = mrAbort then
  begin
    Abort;
  end;
end;

procedure TJeezBuild.FormPaint(ASender: TObject);
var
  LTranspiler: CJeezJes2CppLogMessages;
begin
  OnPaint := nil;
  ModalResult := mrAbort;
  Refresh;
  Application.ProcessMessages;
  try
    LTranspiler := CJeezJes2CppLogMessages.Create(Self);
    try
      LTranspiler.TranspileScript(FEditor.SynEdit.Lines, FEditor.FileName,
        JeezOptions.EditDefVendorString.Text, ExtractFileName(FEditor.FileName),
        JeezOptions.EditDefProductString.Text,
        JeezOptions.EditDefVendorVersion.Text, JeezOptions.EditDefUniqueId.Text);
      FCompiler := CJeezCompiler.Create(Self);
      try
        FOutputFile := FCompiler.Compile(JeezOptions.GetGccExecutable, LTranspiler.Output);
        ModalResult := mrOk;
      finally
        FreeAndNil(FCompiler);
      end;
    finally
      FreeAndNil(LTranspiler);
    end;
    JeezConsole.LogMessage(Format(SMsgCompilationComplete1, [TimeToStr(Now - FStartTime)]));
  except
    on AException: Exception do
    begin
      FExceptionMessage := AException.Message;
    end;
  end;
end;

procedure TJeezBuild.TimerTimer(ASender: TObject);
begin
  ProgressBar.StepIt;
  if ProgressBar.Position >= ProgressBar.Max then
  begin
    ProgressBar.Position := ProgressBar.Min;
  end;
end;

procedure TJeezBuild.ButtonAbortBuildClick(ASender: TObject);
begin
  if Assigned(FCompiler) then
  begin
    Caption := SMsgAbortingCompilationPleaseWait;
    ButtonAbortBuild.Enabled := False;
    FCompiler.Terminate(GiExitStatusAbort);
  end;
end;

end.

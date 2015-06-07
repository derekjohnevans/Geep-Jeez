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
  Buttons, ComCtrls, Controls, ExtCtrls, Forms, JeezResources, JeezUtils, Jes2CppCompiler, Jes2CppConstants,
  Jes2CppProcess, SysUtils;

type

  { TJeezBuild }

  TJeezBuild = class(TForm)
    ButtonAbort: TBitBtn;
    ProgressBar: TProgressBar;
    Timer: TTimer;
    procedure ButtonAbortClick(ASender: TObject);
    procedure FormPaint(ASender: TObject);
    procedure TimerTimer(ASender: TObject);
  private
    FCaption, FExceptionMessage: String;
    FStartTime: TTime;
    FOutputFile: TFileName;
    FCompiler: CJes2CppCompiler;
  public
    function Execute: Boolean;
    property OutputFile: TFileName read FOutputFile;
  end;

var
  JeezBuild: TJeezBuild;

implementation

{$R *.lfm}

uses UJeezIde, UJeezMessages, UJeezOptions;

function TJeezBuild.Execute: Boolean;
begin
  FCaption := SMsgTypeBuilding + CharSpace + UpperCase(PluginTypeAsString(JeezOptions.GetTypePlugin)) +
    CharSpace + GsPlugin + CharSpace + CharOpeningParenthesis;
  case JeezOptions.GetTypeProcessor of
    pt32bit: begin
      FCaption += Gs32Bit + CharSpace + SMsgProcessor;
    end;
    pt64bit: begin
      FCaption += Gs64Bit + CharSpace + SMsgProcessor;
    end;
  end;
  FCaption += CharSlashForward;
  case JeezOptions.GetTypePrecision of
    ptSingle: begin
      FCaption += Gs32Bit + CharSpace + SMsgPrecision;
    end;
    ptDouble: begin
      FCaption += Gs64Bit + CharSpace + SMsgPrecision;
    end;
  end;
  FCaption += CharClosingParenthesis;
  Caption := FCaption;
  FStartTime := Now;
  OnPaint := FormPaint;
  Timer.Enabled := True;
  ProgressBar.Position := 0;
  ButtonAbort.Enabled := True;
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
  LTranspiler: Jeez_Jes2Cpp;
begin
  OnPaint := nil;
  ModalResult := mrAbort;
  Refresh;
  Application.ProcessMessages;
  try
    LTranspiler := Jeez_Jes2Cpp.Create(Self);
    try
      LTranspiler.TranspileScript(JeezIde.GetActiveEditor.SynEdit.Lines, JeezIde.GetActiveEditor.Filename,
        JeezOptions.EditDefVendorString.Text, ExtractFileName(JeezIde.GetActiveEditor.Filename), JeezOptions.EditDefProductString.Text,
        JeezOptions.EditDefVendorVersion.Text, JeezOptions.EditDefUniqueId.Text);
      FCompiler := Jeez_Compile.Create(Self);
      try
        FCompiler.SetCompilerOption(coUseLibBass, JeezOptions.EditUseBass.Checked);
        FCompiler.SetCompilerOption(coUseLibSndFile, JeezOptions.EditUseSndFile.Checked);
        FCompiler.SetCompilerOption(coUseFastMath, JeezOptions.EditUseFastMath.Checked);
        FCompiler.SetCompilerOption(coUseInline, JeezOptions.EditUseInlineFunctions.Checked);
        FCompiler.SetCompilerOption(coUseCompression, JeezOptions.EditUseCompression.Checked);
        FCompiler.TypeProcessor := JeezOptions.GetTypeProcessor;
        FCompiler.TypePrecision := JeezOptions.GetTypePrecision;
        FCompiler.TypePlugin := JeezOptions.GetTypePlugin;
        FOutputFile := FCompiler.Compile(JeezOptions.GetCompiler, LTranspiler.Output);
        ModalResult := mrOk;
      finally
        FreeAndNil(FCompiler);
      end;
    finally
      FreeAndNil(LTranspiler);
    end;
    JeezMessages.LogMessage(Format(SMsgCompilationComplete1, [TimeToStr(Now - FStartTime)]));
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

procedure TJeezBuild.ButtonAbortClick(ASender: TObject);
begin
  if Assigned(FCompiler) then
  begin
    Caption := SMsgAbortingCompilationPleaseWait;
    ButtonAbort.Enabled := False;
    FCompiler.Terminate(GiExitStatusAbort);
  end;
end;

end.

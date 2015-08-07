(*

Jes2Cpp - Jesusonic Script to C++ Transpiler

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

unit Jes2CppPrinter;

{$MODE DELPHI}

interface

uses
  Classes, Jes2CppConstants, Jes2CppIterate, Jes2CppParserFunctions, Jes2CppStrings,
  Jes2CppTranslate, Math,
  StrUtils, SysUtils;

type

  CJes2CppPrinter = class(CJes2CppParserFunctions)
  strict private
    FIndent, FTabSize, FColWidth: Integer;
    FOutput, FBreaker: TStringList;
  protected
    procedure DoCreate; override;
    procedure DoDestroy; override;
  protected
    procedure Print(const AFormat: String; const AArgs: array of const;
      const AIsRequired: Boolean = True); overload;
    procedure Print(const ALine: String; const AIsRequired: Boolean = True;
      const AWrapText: Boolean = True); overload;
    procedure PrintBlankLine;
    procedure PrintComment(const AComment: String);
    procedure PrintCommentTitle(const ATitle: String);
    procedure PrintExternCFoot;
    procedure PrintExternCHead;
    procedure PrintMethodFoot;
    procedure PrintMethodHead(const AName: String);
    procedure PrintOriginalComments(const ADescription: String);
    procedure PrintRaw(const ALine: String; const AIsRequired: Boolean = True);
  public
    property Output: TStringList read FOutput;
  end;

implementation

procedure CJes2CppPrinter.DoCreate;
begin
  inherited DoCreate;
  FColWidth := GiColWidth;
  FTabSize := GiTabSize;
  FBreaker := TStringList.Create;
  FOutput := TStringList.Create;
end;

procedure CJes2CppPrinter.DoDestroy;
begin
  FreeAndNil(FOutput);
  FreeAndNil(FBreaker);
  inherited DoDestroy;
end;

procedure CJes2CppPrinter.PrintRaw(const ALine: String; const AIsRequired: Boolean);
begin
  if not AIsRequired then
  begin
    PrintComment(ALine + CharSpace + GsCppCommentSpace + SMsgNotRequiredForThisEffect);
  end else begin
    if AnsiStartsStr(CharClosingBrace, ALine) then
    begin
      Dec(FIndent, FTabSize);
    end;
    Output.Add(StringOfChar(CharSpace, FIndent) + ALine);
    if AnsiEndsStr(CharOpeningBrace, ALine) then
    begin
      Inc(FIndent, FTabSize);
    end;
    if SameText(CharClosingBrace, ALine) and (FIndent = 0) then
    begin
      PrintBlankLine;
    end;
  end;
end;

procedure CJes2CppPrinter.Print(const ALine: String; const AIsRequired: Boolean;
  const AWrapText: Boolean);
var
  LIndex: Integer;
begin
  // NOTE: Wrap text doesn't work for C++ strings, therefore, AWrapText should be false
  // whenever we print C++ strings.
  if AWrapText then
  begin
    FBreaker.Text := WrapText(ALine, LineEnding, [CharSpace], FColWidth - FIndent);
  end else begin
    FBreaker.Text := ALine;
  end;
  for LIndex := IndexFirst(FBreaker) to IndexLast(FBreaker) do
  begin
    PrintRaw(Trim(FBreaker[LIndex]), AIsRequired);
  end;
end;

procedure CJes2CppPrinter.Print(const AFormat: String; const AArgs: array of const;
  const AIsRequired: Boolean);
begin
  Print(Format(AFormat, AArgs), AIsRequired);
end;

procedure CJes2CppPrinter.PrintComment(const AComment: String);
var
  LIndex: Integer;
begin
  FBreaker.Text := WrapText(AComment, LineEnding, [CharSpace], FColWidth - FIndent);
  for LIndex := IndexFirst(FBreaker) to IndexLast(FBreaker) do
  begin
    PrintRaw(GsCppCommentSpace + Trim(FBreaker[LIndex]));
  end;
end;

procedure CJes2CppPrinter.PrintCommentTitle(const ATitle: String);
begin
  PrintComment(GString.SplitterLine(FColWidth - FIndent - 3));
  PrintComment(ATitle);
  PrintComment(GString.SplitterLine(FColWidth - FIndent - 3));
end;

procedure CJes2CppPrinter.PrintOriginalComments(const ADescription: String);
var
  LIndex: Integer;
  LString: String;
begin
  with TStringList.Create do
  begin
    try
      Text := ADescription;
      for LIndex := ZeroValue to Count - 1 do
      begin
        LString := Trim(Strings[LIndex]);
        if AnsiStartsStr('//', LString) then
        begin
          FOutput.Add(LString);
        end;
      end;
    finally
      Free;
    end;
  end;
end;

procedure CJes2CppPrinter.PrintBlankLine;
begin
  PrintComment(EmptyStr);
end;

procedure CJes2CppPrinter.PrintExternCHead;
begin
  Print('extern "C" ' + CharOpeningBrace);
end;

procedure CJes2CppPrinter.PrintExternCFoot;
begin
  Print(CharClosingBrace + ' // extern "C"');
end;

procedure CJes2CppPrinter.PrintMethodHead(const AName: String);
begin
  PrintCommentTitle('Override: ' + AName);
  Print(GsCppVoidSpace + GsCppFunct1, [AName]);
  Print(CharOpeningBrace);
  Print(GsTJes2Cpp + '::' + AName + '();');
end;

procedure CJes2CppPrinter.PrintMethodFoot;
begin
  Print(CharClosingBrace);
end;

end.

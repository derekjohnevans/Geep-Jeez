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

unit Jes2CppTranspilerPrinter;

{$MODE DELPHI}

interface

uses
  Classes, Jes2CppConstants, Jes2CppTranspilerParser, Jes2CppUtils, StrUtils, SysUtils;

type

  CJes2CppTranspilerPrinter = class(CJes2CppTranspilerParser)
  strict private
    FIndent, FTabSize, FColWidth: Integer;
    FOutput, FBreaker: TStringList;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  protected
    procedure PrintRaw(const ALine: String; const AIsRequired: Boolean = True);
    procedure Print(const ALine: String; const AIsRequired: Boolean = True); overload;
    procedure Print(const AFormat: String; const AArgs: array of const; const AIsRequired: Boolean = True); overload;
    procedure PrintBlankLine;
    procedure PrintComment(const AComment: String);
    procedure PrintTitle(const ATitle: String);
    procedure PrintOriginalComments(const ADescription: String);
  public
    property Output: TStringList read FOutput;
  end;

implementation

constructor CJes2CppTranspilerPrinter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FColWidth := 100;
  FTabSize := 2;
  FBreaker := TStringList.Create;
  FOutput := TStringList.Create;
end;

destructor CJes2CppTranspilerPrinter.Destroy;
begin
  FreeAndNil(FOutput);
  FreeAndNil(FBreaker);
  inherited Destroy;
end;

procedure CJes2CppTranspilerPrinter.PrintRaw(const ALine: String; const AIsRequired: Boolean);
begin
  if AIsRequired then
  begin
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
  end else begin
    PrintComment(ALine + CharSpace + SCppCommentSpace + SMsgNotRequiredForThisEffect);
  end;
end;

procedure CJes2CppTranspilerPrinter.Print(const ALine: String; const AIsRequired: Boolean);
var
  LIndex: Integer;
begin
  FBreaker.Text := WrapText(ALine, LineEnding, [CharSpace], FColWidth - FIndent);
  for LIndex := First(FBreaker) to Last(FBreaker) do
  begin
    PrintRaw(Trim(FBreaker[LIndex]), AIsRequired);
  end;
end;

procedure CJes2CppTranspilerPrinter.Print(const AFormat: String; const AArgs: array of const; const AIsRequired: Boolean);
begin
  Print(Format(AFormat, AArgs), AIsRequired);
end;

procedure CJes2CppTranspilerPrinter.PrintComment(const AComment: String);
begin
  Print(SCppCommentSpace + AComment);
end;

procedure CJes2CppTranspilerPrinter.PrintTitle(const ATitle: String);
begin
  PrintComment(StringOfChar(CharEqu, FColWidth - FIndent - 3));
  PrintComment(ATitle);
  PrintComment(StringOfChar(CharEqu, FColWidth - FIndent - 3));
end;

procedure CJes2CppTranspilerPrinter.PrintOriginalComments(const ADescription: String);
var
  LIndex: Integer;
  LString: String;
begin
  with TStringList.Create do
  begin
    try
      Text := ADescription;
      for LIndex := 0 to Count - 1 do
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

procedure CJes2CppTranspilerPrinter.PrintBlankLine;
begin
  PrintComment(EmptyStr);
end;

end.

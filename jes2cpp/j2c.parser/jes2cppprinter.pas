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
  Classes, Jes2CppConstants, Jes2CppIterate, Jes2CppParserFunctions, Jes2CppStrings, Jes2CppTranslate, StrUtils, SysUtils;

type

  CJes2CppPrinter = class(CJes2CppParserFunctions)
  strict private
    FIndent, FTabSize, FColWidth: Integer;
    FOutput, FBreaker: TStringList;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  protected
    procedure Print(const AFormat: String; const AArgs: array of const; const AIsRequired: Boolean = True); overload;
    procedure Print(const ALine: String; const AIsRequired: Boolean = True); overload;
    procedure PrintBlankLine;
    procedure PrintComment(const AComment: String);
    procedure PrintExternCFoot;
    procedure PrintExternCHead;
    procedure PrintMethodFoot;
    procedure PrintMethodHead(const AName: String);
    procedure PrintOriginalComments(const ADescription: String);
    procedure PrintRaw(const ALine: String; const AIsRequired: Boolean = True);
    procedure PrintTitle(const ATitle: String);
  public
    property Output: TStringList read FOutput;
  end;

implementation

constructor CJes2CppPrinter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FColWidth := GiColWidth;
  FTabSize := 2;
  FBreaker := TStringList.Create;
  FOutput := TStringList.Create;
end;

destructor CJes2CppPrinter.Destroy;
begin
  FreeAndNil(FOutput);
  FreeAndNil(FBreaker);
  inherited Destroy;
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

procedure CJes2CppPrinter.Print(const ALine: String; const AIsRequired: Boolean);
var
  LIndex: Integer;
begin
  FBreaker.Text := WrapText(ALine, LineEnding, [CharSpace], FColWidth - FIndent);
  for LIndex := ItemFirst(FBreaker) to ItemLast(FBreaker) do
  begin
    PrintRaw(Trim(FBreaker[LIndex]), AIsRequired);
  end;
end;

procedure CJes2CppPrinter.Print(const AFormat: String; const AArgs: array of const; const AIsRequired: Boolean);
begin
  Print(Format(AFormat, AArgs), AIsRequired);
end;

procedure CJes2CppPrinter.PrintComment(const AComment: String);
var
  LIndex: Integer;
begin
  FBreaker.Text := WrapText(AComment, LineEnding, [CharSpace], FColWidth - FIndent);
  for LIndex := ItemFirst(FBreaker) to ItemLast(FBreaker) do
  begin
    PrintRaw(GsCppCommentSpace + Trim(FBreaker[LIndex]));
  end;
end;

procedure CJes2CppPrinter.PrintTitle(const ATitle: String);
begin
  PrintComment(J2C_StringLine(FColWidth - FIndent - 3));
  PrintComment(ATitle);
  PrintComment(J2C_StringLine(FColWidth - FIndent - 3));
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
  PrintTitle('Override: ' + AName);
  Print(GsCppVoidSpace + GsCppFunct1, [AName]);
  Print(CharOpeningBrace);
  Print(GsTJes2Cpp + '::' + AName + '();');
end;

procedure CJes2CppPrinter.PrintMethodFoot;
begin
  Print(CharClosingBrace);
end;

end.

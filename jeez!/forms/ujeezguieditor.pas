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

unit UJeezGuiEditor;

{$MODE DELPHI}

interface

uses
  BufDataset, ButtonPanel, Classes, Controls, db, DBGrids, Forms, Jes2CppDescription;

type

  { TJeezGuiEditor }

  TJeezGuiEditor = class(TForm)
    BufDataset: TBufDataset;
    ButtonPanel: TButtonPanel;
    DataSource: TDataSource;
    DBGrid1: TDBGrid;
    procedure FormCreate(ASender: TObject);
  private
  public
    function Execute(const AScript: TStrings): Boolean;
  end;

var
  JeezGuiEditor: TJeezGuiEditor;

implementation

{$R *.lfm}

procedure TJeezGuiEditor.FormCreate(ASender: TObject);
begin
  BufDataset.FieldDefs.Add('Index', ftInteger);
  BufDataset.FieldDefs.Add('Default', ftFloat);
  BufDataset.FieldDefs.Add('Low', ftFloat);
  BufDataset.FieldDefs.Add('High', ftFloat);
  BufDataset.FieldDefs.Add('Step', ftFloat);
  BufDataset.FieldDefs.Add('Text', ftString, 100);
  BufDataset.CreateDataset;
end;

function TJeezGuiEditor.Execute(const AScript: TStrings): Boolean;
var
  LIndex: Integer;
begin
  with CJes2CppDescription.Create(Self) do
  begin
    try
      ExtractDescriptionElements(AScript);
      for LIndex := 0 to ParameterCount - 1 do
      begin
        with Parameters[LIndex] do
        begin
          BufDataset.AppendRecord([Slider, DefValue, MinValue, MaxValue, StepValue, Text]);
        end;
      end;
    finally
      Free;
    end;
  end;
  Result := ShowModal = mrOk;
end;

end.

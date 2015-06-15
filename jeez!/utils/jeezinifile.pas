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

unit JeezIniFile;

{$MODE DELPHI}

interface

uses
  ColorBox, Controls, EditBtn, IniFiles, Jes2CppConstants, Spin, StdCtrls, SysUtils;

type

  TJeezStorage = class(TIniFile)
  protected
    procedure Load(const AControl: TSpinEdit); overload;
    procedure Load(const AControl: TColorBox); overload;
    procedure Load(const AControl: TComboBox); overload;
    procedure Load(const AControl: TEdit); overload;
    procedure Load(const AControl: TDirectoryEdit); overload;
    procedure Load(const AControl: TListBox); overload;
    procedure Load(const AControl: TCheckBox); overload;
  protected
    procedure Save(const AControl: TSpinEdit); overload;
    procedure Save(const AControl: TColorBox); overload;
    procedure Save(const AControl: TComboBox); overload;
    procedure Save(const AControl: TEdit); overload;
    procedure Save(const AControl: TDirectoryEdit); overload;
    procedure Save(const AControl: TListBox); overload;
    procedure Save(const AControl: TCheckBox); overload;
  public
    constructor Create(const AFileName: TFileName); virtual; reintroduce;
  public
    procedure SaveAll(const AControl: TControl);
    procedure LoadAll(const AControl: TControl);
  end;

implementation

constructor TJeezStorage.Create(const AFileName: TFileName);
begin
  inherited Create(AFileName, False);
  StripQuotes := False;
end;

procedure TJeezStorage.Load(const AControl: TEdit);
begin
  AControl.Caption := ReadString(AControl.Name, GsCaption, AControl.Text);
end;

procedure TJeezStorage.Load(const AControl: TComboBox);
begin
  if AControl.Style = csDropDown then
  begin
    AControl.Caption := ReadString(AControl.Name, GsCaption, AControl.Text);
  end else begin
    AControl.ItemIndex := ReadInteger(AControl.Name, GsItemIndex, AControl.ItemIndex);
  end;
end;

procedure TJeezStorage.Load(const AControl: TDirectoryEdit);
begin
  AControl.Directory := ReadString(AControl.Name, GsCaption, AControl.Directory);
end;

procedure TJeezStorage.Load(const AControl: TSpinEdit);
begin
  AControl.Value := ReadInteger(AControl.Name, GsValue, AControl.Value);
end;

procedure TJeezStorage.Load(const AControl: TColorBox);
begin
  AControl.Selected := ReadInteger(AControl.Name, GsSelected, AControl.Selected);
end;

procedure TJeezStorage.Load(const AControl: TListBox);
var
  LIndex: Integer;
begin
  AControl.Clear;
  for LIndex := 0 to ReadInteger(AControl.Name, GsCount, AControl.Count) - 1 do
  begin
    AControl.Items.Add(ReadString(AControl.Name, Format(GsItems1, [LIndex]), EmptyStr));
  end;
end;

procedure TJeezStorage.Load(const AControl: TCheckBox); overload;
begin
  AControl.Checked := ReadBool(AControl.Name, GsValue, AControl.Checked);
end;

procedure TJeezStorage.Save(const AControl: TEdit);
begin
  WriteString(AControl.Name, GsCaption, AControl.Text);
end;

procedure TJeezStorage.Save(const AControl: TComboBox);
begin
  if AControl.Style = csDropDown then
  begin
    WriteString(AControl.Name, GsCaption, AControl.Caption);
  end else begin
    WriteInteger(AControl.Name, GsItemIndex, AControl.ItemIndex);
  end;
end;

procedure TJeezStorage.Save(const AControl: TDirectoryEdit);
begin
  WriteString(AControl.Name, GsCaption, AControl.Directory);
end;

procedure TJeezStorage.Save(const AControl: TSpinEdit);
begin
  WriteInteger(AControl.Name, GsValue, AControl.Value);
end;

procedure TJeezStorage.Save(const AControl: TColorBox);
begin
  WriteInteger(AControl.Name, GsSelected, AControl.Selected);
end;

procedure TJeezStorage.Save(const AControl: TListBox);
var
  LIndex: Integer;
begin
  WriteInteger(AControl.Name, GsCount, AControl.Count);
  for LIndex := 0 to AControl.Count - 1 do
  begin
    WriteString(AControl.Name, Format(GsItems1, [LIndex]), AControl.Items[LIndex]);
  end;
end;

procedure TJeezStorage.Save(const AControl: TCheckBox);
begin
  WriteBool(AControl.Name, gsValue, AControl.Checked);
end;

procedure TJeezStorage.SaveAll(const AControl: TControl);
var
  LIndex: Integer;
begin
  if AControl is TSpinEdit then
  begin
    Save(TSpinEdit(AControl));
  end else if AControl is TCheckBox then
  begin
    Save(TCheckBox(AControl));
  end else if AControl is TColorBox then
  begin
    Save(TColorBox(AControl));
  end else if AControl is TListBox then
  begin
    Save(TListBox(AControl));
  end else if AControl is TEdit then
  begin
    Save(TEdit(AControl));
  end else if AControl is TComboBox then
  begin
    Save(TComboBox(AControl));
  end else if AControl is TDirectoryEdit then
  begin
    Save(TDirectoryEdit(AControl));
  end;
  if AControl is TWinControl then
  begin
    for LIndex := 0 to TWinControl(AControl).ControlCount - 1 do
    begin
      SaveAll(TWinControl(AControl).Controls[LIndex]);
    end;
  end;
end;

procedure TJeezStorage.LoadAll(const AControl: TControl);
var
  LIndex: Integer;
begin
  if AControl is TSpinEdit then
  begin
    Load(TSpinEdit(AControl));
  end else if AControl is TCheckBox then
  begin
    Load(TCheckBox(AControl));
  end else if AControl is TColorBox then
  begin
    Load(TColorBox(AControl));
  end else if AControl is TListBox then
  begin
    Load(TListBox(AControl));
  end else if AControl is TEdit then
  begin
    Load(TEdit(AControl));
  end else if AControl is TComboBox then
  begin
    Load(TComboBox(AControl));
  end else if AControl is TDirectoryEdit then
  begin
    Load(TDirectoryEdit(AControl));
  end;
  if AControl is TWinControl then
  begin
    for LIndex := 0 to TWinControl(AControl).ControlCount - 1 do
    begin
      LoadAll(TWinControl(AControl).Controls[LIndex]);
    end;
  end;
end;

end.

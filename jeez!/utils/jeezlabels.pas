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

unit JeezLabels;

{$MODE DELPHI}

interface

uses
  Classes, Controls, EditBtn, ExtCtrls, Graphics, Jes2CppPlatform, StdCtrls, SysUtils, Types;

const

  clInfoBlock = TColor($E1FFFF);

procedure J2C_WinControlCreateLabels(const AWinControl: TWinControl);

implementation

function J2C_ControlCreateLabel(const AControl: TControl): TPanel;
var
  LIndex: Integer;
  LCaption, LHint: String;
  LRect, LUnion: TRect;
begin
  Result := nil;
  LHint := Trim(AControl.Hint);
  if not AControl.ShowHint and (LHint <> EmptyStr) then
  begin
    AControl.ShowHint := True;
    LRect := Rect(0, AControl.Top, AControl.Left, AControl.BoundsRect.Bottom);
    for LIndex := 0 to AControl.Parent.ControlCount - 1 do
    begin
      LUnion := Bounds(0, 0, 0, 0);
      if IntersectRect(LUnion, LRect, AControl.Parent.Controls[LIndex].BoundsRect) then
      begin
        LRect.Left := LUnion.Right;
      end;
    end;
    if not IsRectEmpty(LRect) then
    begin
      LIndex := Pos(#10, LHint);
      if LIndex > 0 then
      begin
        LCaption := Trim(Copy(LHint, 1, LIndex - 1));
        LHint := Trim(Copy(LHint, LIndex + 1, MaxInt));
      end else begin
        LCaption := LHint;
      end;
      AControl.Hint := LHint;
      if not NsPlatform.IsWindows9x then
      begin
        AControl.Color := clInfoBlock;
      end;
      Result := TPanel.Create(AControl);
      Result.BoundsRect := LRect;
      Result.BorderWidth := 6;
      Result.Alignment := taRightJustify;
      Result.BevelOuter := bvNone;
      Result.Caption := LCaption;
      Result.Hint := LHint;
      Result.ShowHint := True;
      Result.Cursor := crHelp;
      Result.Parent := AControl.Parent;
      Result.Font.Color := clBlack;
    end;
  end;
end;

procedure J2C_WinControlCreateLabels(const AWinControl: TWinControl);
var
  LIndex: Integer;
begin
  if (AWinControl is TCustomEdit) or (AWinControl is TDirectoryEdit) or (AWinControl is TCustomComboBox) then
  begin
    J2C_ControlCreateLabel(AWinControl);
  end;
  for LIndex := 0 to AWinControl.ControlCount - 1 do
  begin
    if AWinControl.Controls[LIndex] is TWinControl then
    begin
      J2C_WinControlCreateLabels(TWinControl(AWinControl.Controls[LIndex]));
    end;
  end;
end;

end.


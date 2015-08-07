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

unit JeezTreeView;

{$MODE DELPHI}

interface

uses
  ComCtrls, Graphics, ImgList, JeezUtils, Jes2CppConstants, Math, StrUtils, SysUtils, Types;

type

  CJes2CppTreeNodeData = class
  strict private
    FText, FComment: String;
  public
    property Name: String read FText write FText;
    property Comment: String read FComment write FComment;
  end;

type

  TJeezTreeView = class(TTreeView)
  public
    // We need ScrolledTop in order to center the selected node.
    property ScrolledTop;
  end;

  GJeezTreeNode = object
    class procedure MakeSelected(const ATreeNode: TTreeNode);
    class function IsSameName(const ATreeNode: TTreeNode; const AName: String): Boolean;
    class function GetCount(const ATreeNode: TTreeNode): Integer;
    class procedure UpdateCount(const ATreeNode: TTreeNode);
    class function FindByName(const AParent: TTreeNode; const AName: String): TTreeNode;
    class function FindOrCreate(const AParent: TTreeNode; const AName, AText: String): TTreeNode;
    class procedure Draw(const ATreeNode: TTreeNode;
      const AColorFunction, AColorVariables, AColorIdentifiers, AColorSymbols: TColor);
  end;

  GJeezTreeNodes = object
    class procedure DeleteCuts(const ATreeNodes: TTreeNodes);
    class function FindByName(const ATreeNodes: TTreeNodes; const AName: String): TTreeNode;
    class procedure MarkNonRootsForCutting(const ATreeNodes: TTreeNodes);
  end;

  GJeezTreeView = object
    class procedure HandleKeyPress(const ATreeView: TTreeView; const AKey: Char);
    class procedure RootNodesClear(const ATreeView: TTreeView);
    class procedure RootNodesCollapse(const ATreeView: TTreeView);
  end;

implementation

uses UJeezData, UJeezOptions;

const
  GsTreeNodeCountHead = CharSpace + CharOpeningBracket;
  GsTreeNodeCountFoot = CharClosingBracket;

function J2C_StringRemoveCount(const AString: String): String;
begin
  Result := Copy(AString, 1, (Pos(GsTreeNodeCountHead, AString) - 1) and MaxInt);
end;

function J2C_StringRemoveParams(const AString: String): String;
begin
  Result := Copy(AString, 1, (Pos(CharOpeningParenthesis, AString) - 1) and MaxInt);
end;

class procedure GJeezTreeNode.MakeSelected(const ATreeNode: TTreeNode);
begin
  Assert(Assigned(ATreeNode));
  ATreeNode.Selected := False;
  ATreeNode.Selected := True;
  ATreeNode.Expand(False);
  TJeezTreeView(ATreeNode.TreeView).ScrolledTop :=
    ATreeNode.Top - (ATreeNode.TreeView.ClientHeight - ATreeNode.Height) div 2;
end;

class function GJeezTreeNode.IsSameName(const ATreeNode: TTreeNode; const AName: String): Boolean;
begin
  Result := SameText(CJes2CppTreeNodeData(ATreeNode.Data).Name, AName);
end;

class function GJeezTreeNode.GetCount(const ATreeNode: TTreeNode): Integer;
var
  LTreeNode: TTreeNode;
begin
  Result := ZeroValue;
  LTreeNode := ATreeNode.GetFirstChild;
  while Assigned(LTreeNode) do
  begin
    if not LTreeNode.Deleting then
    begin
      Inc(Result);
    end;
    LTreeNode := LTreeNode.GetNextSibling;
  end;
end;

class procedure GJeezTreeNode.UpdateCount(const ATreeNode: TTreeNode);
begin
  if Assigned(ATreeNode) then
  begin
    ATreeNode.Text := J2C_StringRemoveCount(ATreeNode.Text) + GsTreeNodeCountHead +
      IntToStr(GetCount(ATreeNode)) + GsTreeNodeCountFoot;
    UpdateCount(ATreeNode.Parent);
  end;
end;

class function GJeezTreeNode.FindByName(const AParent: TTreeNode; const AName: String): TTreeNode;
begin
  Result := AParent.GetFirstChild;
  while Assigned(Result) and not IsSameName(Result, AName) do
  begin
    Result := Result.GetNextSibling;
  end;
end;

class function GJeezTreeNode.FindOrCreate(const AParent: TTreeNode;
  const AName, AText: String): TTreeNode;
begin
  Result := FindByName(AParent, AText);
  if not Assigned(Result) then
  begin
    Result := AParent.TreeView.Items.AddChild(AParent, AText);
    CJes2CppTreeNodeData(Result.Data).Name := AName;
  end;
  Result.Cut := False;
end;

class procedure GJeezTreeNode.Draw(const ATreeNode: TTreeNode;
  const AColorFunction, AColorVariables, AColorIdentifiers, AColorSymbols: TColor);
var
  LImageIndex, LTop: Integer;
  LText: String;
  LRect: TRect;
  LCanvas: TCanvas;
  LImageList: TCustomImageList;
  LTreeView: TTreeView;
begin
  LCanvas := ATreeNode.TreeView.Canvas;
  LTreeView := ATreeNode.TreeView as TTreeView;
  LImageList := LTreeView.Images;

  GJeezCanvas.DrawItemBackground(LCanvas, ATreeNode.DisplayRect(False),
    ATreeNode.Selected, LTreeView.Color);

  LRect := ATreeNode.DisplayRect(True);
  if ATreeNode.Level <> 1 then
  begin
    Dec(LRect.Left, LImageList.Width);
  end;
  Dec(LRect.Left, LImageList.Width);
  LImageIndex := IfThen(ATreeNode.HasChildren, IfThen(ATreeNode.Expanded, 35, 36), -1);
  if LImageIndex >= 0 then
  begin
    LImageList.Draw(LCanvas, LRect.Left, LRect.Top + (LRect.Bottom - LRect.Top -
      LImageList.Height) div 2, LImageIndex);
  end;
  if ATreeNode.Level < 2 then
  begin
    Inc(LRect.Left, LImageList.Width);
  end;
  if ATreeNode.ImageIndex >= 0 then
  begin
    LImageList.Draw(LCanvas, LRect.Left, LRect.Top + (LRect.Bottom - LRect.Top -
      LImageList.Height) div 2,
      ATreeNode.ImageIndex);
    Inc(LRect.Left, LImageList.Width + 2);
  end;
  LText := ATreeNode.Text;
  LTop := (LRect.Top + LRect.Bottom - LCanvas.TextHeight(LText)) div 2;
  if ATreeNode.Level = 0 then
  begin
    LCanvas.Font.Color := AColorSymbols;
  end else if ATreeNode.Level = 1 then
  begin
    if ATreeNode.Count > 1 then
    begin
      if ATreeNode.Parent.ImageIndex in GiImageIndexFunctions then
      begin
        if ATreeNode.Parent.ImageIndex = GiImageIndexFunctionsSystem then
        begin
          GJeezCanvas.DrawFunctionDefine(LCanvas, LRect.Left, LTop, LText,
            AColorFunction, AColorIdentifiers, AColorSymbols);
        end else begin
          GJeezCanvas.DrawFunctionDefine(LCanvas, LRect.Left, LTop, LText,
            AColorIdentifiers, AColorIdentifiers, AColorSymbols);
        end;
        Exit;
      end else begin
        if ATreeNode.Parent.ImageIndex = GiImageIndexVariablesSystem then
        begin
          LCanvas.Font.Color := AColorVariables;
        end else begin
          LCanvas.Font.Color := AColorIdentifiers;
        end;
      end;
    end else begin
      LCanvas.Font.Color := JeezOptions.ColorComments.Selected;
    end;
  end else if ATreeNode.ImageIndex in GiImageIndexReference then
  begin
    LCanvas.Font.Color := JeezOptions.ColorStrings.Selected;
  end;
  LCanvas.TextRect(LRect, LRect.Left, LTop, LText);
end;

class procedure GJeezTreeNodes.DeleteCuts(const ATreeNodes: TTreeNodes);
var
  LIndex: Integer;
begin
  for LIndex := ATreeNodes.Count - 1 downto 0 do
  begin
    if ATreeNodes[LIndex].Cut then
    begin
      if LIndex >= ATreeNodes.Count then
      begin
        Beep;
      end;
      ATreeNodes[LIndex].Delete;
    end;
  end;
end;

class function GJeezTreeNodes.FindByName(const ATreeNodes: TTreeNodes;
  const AName: String): TTreeNode;
begin
  Result := ATreeNodes.GetFirstNode;
  while Assigned(Result) and not GJeezTreeNode.IsSameName(Result, AName) do
  begin
    Result := Result.GetNext;
  end;
end;

class procedure GJeezTreeNodes.MarkNonRootsForCutting(const ATreeNodes: TTreeNodes);
var
  LIndex: Integer;
begin
  for LIndex := 0 to ATreeNodes.Count - 1 do
  begin
    if ATreeNodes[LIndex].Level > 0 then
    begin
      ATreeNodes[LIndex].Cut := True;
    end;
  end;
end;

class procedure GJeezTreeView.RootNodesClear(const ATreeView: TTreeView);
var
  LTreeNode: TTreeNode;
begin
  if ATreeView.Items.Count > 0 then
  begin
    LTreeNode := ATreeView.Items[0];
    repeat
      LTreeNode.DeleteChildren;
      LTreeNode := LTreeNode.GetNextSibling;
    until not Assigned(LTreeNode);
  end;
end;

class procedure GJeezTreeView.HandleKeyPress(const ATreeView: TTreeView; const AKey: Char);
var
  LTreeNode: TTreeNode;
begin
  LTreeNode := ATreeView.Selected;
  if Assigned(LTreeNode) then
  begin
    repeat
      LTreeNode := LTreeNode.GetNext;
      if not Assigned(LTreeNode) then
      begin
        LTreeNode := ATreeView.Items[0];
      end;
      if not (LTreeNode.ImageIndex in GiImageIndexReference) and
        AnsiStartsText(AKey, LTreeNode.Text) then
      begin
        ATreeView.Selected := LTreeNode;
        Break;
      end;
    until LTreeNode = ATreeView.Selected;
  end;
end;


class procedure GJeezTreeView.RootNodesCollapse(const ATreeView: TTreeView);
var
  LTreeNode: TTreeNode;
begin
  if ATreeView.Items.Count > 0 then
  begin
    LTreeNode := ATreeView.Items[0];
    repeat
      LTreeNode.Collapse(True);
      LTreeNode := LTreeNode.GetNextSibling;
    until not Assigned(LTreeNode);
  end;
end;

end.

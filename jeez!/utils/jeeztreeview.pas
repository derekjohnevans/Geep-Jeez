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

const

  GiImageIndexFunctionsSystem = 43;
  GiImageIndexFunctionsUser = 44;
  GiImageIndexVariablesSystem = 45;
  GiImageIndexVariablesUser = 46;
  GiImageIndexString = 26;
  GiImageIndexRefInternal = 37;
  GiImageIndexRefExternal = 39;

  GiImageIndexFunctions = [GiImageIndexFunctionsSystem, GiImageIndexFunctionsUser];

type

  CJes2CppTreeNodeData = class
    FComment: String;
  end;

function J2C_StringRemoveCount(const AString: String): String;

type
  NSJeezTreeView = object
    class function TreeNodeSameText(const ATreeNode: TTreeNode; const AText: String; const AStripParams: Boolean): Boolean;
    class function TreeNodeCount(const ATreeNode: TTreeNode): Integer;
    class procedure TreeViewHandleKeyPress(const ATreeView: TTreeView; const AKey: Char);
    class function TreeNodeIsReference(const ATreeNode: TTreeNode): Boolean;
    class function TreeNodeGetText(const ATreeNode: TTreeNode; const AStripParams: Boolean = False): String;
    class procedure TreeNodeUpdateCount(const ATreeNode: TTreeNode);
    class function TreeNodeFind(const ATreeNode: TTreeNode; const AString: String; const AStripParams: Boolean = False): TTreeNode;
    class function TreeNodesFind(const ATreeNodes: TTreeNodes; const AText: String; const AStripParams: Boolean = False): TTreeNode;
    class function TreeNodeFindOrCreate(const ATreeNode: TTreeNode; const AText: String; const AStripParams: Boolean = False): TTreeNode;
    class procedure TreeViewRootNodesClear(const ATreeView: TTreeView);
    class procedure TreeViewRootNodesCollapse(const ATreeView: TTreeView);
    class procedure TreeNodesMarkNonRootsForCutting(const ATreeNodes: TTreeNodes);
    class procedure TreeNodesDeleteCuts(const ATreeNodes: TTreeNodes);
    class procedure TreeNodeDraw(const ATreeNode: TTreeNode; const AColorFunction, AColorVariables, AColorIdentifiers, AColorSymbols: TColor);
  end;

implementation

uses UJeezOptions;

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

class procedure NSJeezTreeView.TreeViewHandleKeyPress(const ATreeView: TTreeView; const AKey: Char);
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
      if AnsiStartsText(AKey, LTreeNode.Text) then
      begin
        ATreeView.Selected := LTreeNode;
        Break;
      end;
    until LTreeNode = ATreeView.Selected;
  end;
end;

class function NSJeezTreeView.TreeNodeIsReference(const ATreeNode: TTreeNode): Boolean;
begin
  Result := AnsiStartsStr(GsLine + CharEqualSign, ATreeNode.Text);
end;

class function NSJeezTreeView.TreeNodeGetText(const ATreeNode: TTreeNode; const AStripParams: Boolean): String;
begin
  Result := J2C_StringRemoveCount(ATreeNode.Text);
  if AStripParams then
  begin
    Result := J2C_StringRemoveParams(Result);
  end;
end;

class function NSJeezTreeView.TreeNodeSameText(const ATreeNode: TTreeNode; const AText: String; const AStripParams: Boolean): Boolean;
begin
  Result := SameText(TreeNodeGetText(ATreeNode, AStripParams), AText);
end;

class function NSJeezTreeView.TreeNodeCount(const ATreeNode: TTreeNode): Integer;
var
  LTreeNode: TTreeNode;
begin
  Result := 0;
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

class procedure NSJeezTreeView.TreeNodeUpdateCount(const ATreeNode: TTreeNode);
begin
  if Assigned(ATreeNode) then
  begin
    ATreeNode.Text := J2C_StringRemoveCount(ATreeNode.Text) + GsTreeNodeCountHead + IntToStr(TreeNodeCount(ATreeNode)) +
      GsTreeNodeCountFoot;
    TreeNodeUpdateCount(ATreeNode.Parent);
  end;
end;

class function NSJeezTreeView.TreeNodeFind(const ATreeNode: TTreeNode; const AString: String; const AStripParams: Boolean): TTreeNode;
begin
  Result := ATreeNode.GetFirstChild;
  while Assigned(Result) and not TreeNodeSameText(Result, AString, AStripParams) do
  begin
    Result := Result.GetNextSibling;
  end;
end;

class function NSJeezTreeView.TreeNodesFind(const ATreeNodes: TTreeNodes; const AText: String; const AStripParams: Boolean): TTreeNode;
begin
  Result := ATreeNodes.GetFirstNode;
  while Assigned(Result) and not TreeNodeSameText(Result, AText, AStripParams) do
  begin
    Result := Result.GetNext;
  end;
end;

class function NSJeezTreeView.TreeNodeFindOrCreate(const ATreeNode: TTreeNode; const AText: String;
  const AStripParams: Boolean): TTreeNode;
begin
  Result := TreeNodeFind(ATreeNode, AText, AStripParams);
  if not Assigned(Result) then
  begin
    Result := ATreeNode.TreeView.Items.AddChild(ATreeNode, AText);
  end;
  Result.Cut := False;
end;

class procedure NSJeezTreeView.TreeViewRootNodesClear(const ATreeView: TTreeView);
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

class procedure NSJeezTreeView.TreeViewRootNodesCollapse(const ATreeView: TTreeView);
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

class procedure NSJeezTreeView.TreeNodesMarkNonRootsForCutting(const ATreeNodes: TTreeNodes);
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

class procedure NSJeezTreeView.TreeNodesDeleteCuts(const ATreeNodes: TTreeNodes);
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

class procedure NSJeezTreeView.TreeNodeDraw(const ATreeNode: TTreeNode;
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

  NSJeezCanvas.DrawItemBackground(LCanvas, ATreeNode.DisplayRect(False), ATreeNode.Selected);

  LRect := ATreeNode.DisplayRect(True);
  if ATreeNode.Level <> 1 then
  begin
    Dec(LRect.Left, LImageList.Width);
  end;
  Dec(LRect.Left, LImageList.Width);
  LImageIndex := IfThen(ATreeNode.HasChildren, IfThen(ATreeNode.Expanded, 35, 36), -1);
  if LImageIndex >= 0 then
  begin
    LImageList.Draw(LCanvas, LRect.Left, LRect.Top + (LRect.Bottom - LRect.Top - LImageList.Height) div 2, LImageIndex);
  end;
  if ATreeNode.Level < 2 then
  begin
    Inc(LRect.Left, LImageList.Width);
  end;
  if ATreeNode.ImageIndex >= 0 then
  begin
    LImageList.Draw(LCanvas, LRect.Left, LRect.Top + (LRect.Bottom - LRect.Top - LImageList.Height) div 2,
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
          NSJeezCanvas.DrawFunctionDefine(LCanvas, LRect.Left, LTop, LText, AColorFunction, AColorIdentifiers, AColorSymbols);
        end else begin
          NSJeezCanvas.DrawFunctionDefine(LCanvas, LRect.Left, LTop, LText, AColorIdentifiers, AColorIdentifiers, AColorSymbols);
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
  end else if TreeNodeIsReference(ATreeNode) then
  begin
    LCanvas.Font.Color := JeezOptions.ColorStrings.Selected;
  end;
  LCanvas.TextRect(LRect, LRect.Left, LTop, LText);
end;

end.

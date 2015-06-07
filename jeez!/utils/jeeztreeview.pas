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
  ComCtrls, Graphics, ImgList, Jes2CppConstants, Math, StrUtils, SysUtils, Types;

const

  GiImageIndexFunctions = 26;
  GiImageIndexVariables = 27;
  GiImageIndexRefInternal = 37;
  GiImageIndexRefExternal = 39;

type

  CJes2CppTreeNodeData = class
    FComment: String;
  end;

function J2C_StringRemoveCount(const AString: String): String;

procedure J2C_TreeViewHandleKeyPress(const ATreeView: TTreeView; const AKey: Char);
function J2C_TreeNodeIsReference(const ATreeNode: TTreeNode): Boolean;
function J2C_TreeNodeGetText(const ATreeNode: TTreeNode; const AStripParams: Boolean = False): String;
procedure J2C_TreeNodeUpdateCount(const ATreeNode: TTreeNode);

function J2C_TreeNodeFind(const ATreeNode: TTreeNode; const AString: String; const AStripParams: Boolean = False): TTreeNode;
function J2C_TreeNodesFind(const ATreeNodes: TTreeNodes; const AText: String; const AStripParams: Boolean = False): TTreeNode;

function J2C_TreeNodeFindOrAdd(const ATreeNode: TTreeNode; const AText: String; const AStripParams: Boolean = False): TTreeNode;

procedure J2C_TreeViewRootNodesClear(const ATreeView: TTreeView);
procedure J2C_TreeViewRootNodesCollapse(const ATreeView: TTreeView);

procedure J2C_TreeNodesMarkNonRootsForCutting(const ATreeNodes: TTreeNodes);
procedure J2C_TreeNodesDeleteCuts(const ATreeNodes: TTreeNodes);

procedure J2C_TreeNodeDraw(const ATreeNode: TTreeNode);

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

procedure J2C_TreeViewHandleKeyPress(const ATreeView: TTreeView; const AKey: Char);
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

function J2C_TreeNodeIsReference(const ATreeNode: TTreeNode): Boolean;
begin
  Result := AnsiStartsStr(GsLine + CharEqualSign, ATreeNode.Text);
end;

function J2C_TreeNodeGetText(const ATreeNode: TTreeNode; const AStripParams: Boolean): String;
begin
  Result := J2C_StringRemoveCount(ATreeNode.Text);
  if AStripParams then
  begin
    Result := J2C_StringRemoveParams(Result);
  end;
end;

function J2C_TreeNodeSameText(const ATreeNode: TTreeNode; const AText: String; const AStripParams: Boolean): Boolean;
begin
  Result := SameText(J2C_TreeNodeGetText(ATreeNode, AStripParams), AText);
end;

function J2C_TreeNodeCount(const ATreeNode: TTreeNode): Integer;
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

procedure J2C_TreeNodeUpdateCount(const ATreeNode: TTreeNode);
begin
  if Assigned(ATreeNode) then
  begin
    ATreeNode.Text := J2C_StringRemoveCount(ATreeNode.Text) + GsTreeNodeCountHead + IntToStr(J2C_TreeNodeCount(ATreeNode)) +
      GsTreeNodeCountFoot;
    J2C_TreeNodeUpdateCount(ATreeNode.Parent);
  end;
end;

function J2C_TreeNodeFind(const ATreeNode: TTreeNode; const AString: String; const AStripParams: Boolean): TTreeNode;
begin
  Result := ATreeNode.GetFirstChild;
  while Assigned(Result) and not J2C_TreeNodeSameText(Result, AString, AStripParams) do
  begin
    Result := Result.GetNextSibling;
  end;
end;

function J2C_TreeNodesFind(const ATreeNodes: TTreeNodes; const AText: String; const AStripParams: Boolean): TTreeNode;
begin
  Result := ATreeNodes.GetFirstNode;
  while Assigned(Result) and not J2C_TreeNodeSameText(Result, AText, AStripParams) do
  begin
    Result := Result.GetNext;
  end;
end;

function J2C_TreeNodeFindOrAdd(const ATreeNode: TTreeNode; const AText: String; const AStripParams: Boolean): TTreeNode;
begin
  Result := J2C_TreeNodeFind(ATreeNode, AText, AStripParams);
  if not Assigned(Result) then
  begin
    Result := ATreeNode.TreeView.Items.AddChild(ATreeNode, AText);
  end;
  Result.Cut := False;
end;

procedure J2C_TreeViewRootNodesClear(const ATreeView: TTreeView);
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

procedure J2C_TreeViewRootNodesCollapse(const ATreeView: TTreeView);
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

procedure J2C_TreeNodesMarkNonRootsForCutting(const ATreeNodes: TTreeNodes);
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

procedure J2C_TreeNodesDeleteCuts(const ATreeNodes: TTreeNodes);
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

procedure J2C_TreeNodeDraw(const ATreeNode: TTreeNode);
var
  LImageIndex: Integer;
  LText: String;
  LRect: TRect;
  LCanvas: TCanvas;
  LImageList: TCustomImageList;
  LTreeView: TTreeView;
begin
  LCanvas := ATreeNode.TreeView.Canvas;
  LTreeView := ATreeNode.TreeView as TTreeView;
  LImageList := LTreeView.Images;
  if ATreeNode.Selected then
  begin
    LCanvas.Brush.Color := JeezOptions.ColorCurrentLine.Selected;
  end else begin
    LCanvas.Brush.Color := LTreeView.BackgroundColor;
  end;
  LRect := ATreeNode.DisplayRect(False);
  LCanvas.FillRect(LRect);
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
  if ATreeNode.Level = 0 then
  begin
    LCanvas.Font.Color := JeezOptions.ColorSymbols.Selected;
  end else if ATreeNode.Level = 1 then
  begin
    if ATreeNode.Count > 1 then
    begin
      if ATreeNode.Parent.ImageIndex = GiImageIndexFunctions then
      begin
        LCanvas.Font.Color := JeezOptions.ColorFunctions.Selected;
      end else begin
        LCanvas.Font.Color := JeezOptions.ColorIdentifiers.Selected;
      end;
    end else begin
      LCanvas.Font.Color := JeezOptions.ColorComments.Selected;
    end;
  end else if J2C_TreeNodeIsReference(ATreeNode) then
  begin
    LCanvas.Font.Color := JeezOptions.ColorStrings.Selected;
  end;
  LCanvas.TextRect(LRect, LRect.Left, (LRect.Top + LRect.Bottom - LCanvas.TextHeight(LText)) div 2, LText);
end;

end.

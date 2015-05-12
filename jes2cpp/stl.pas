// NOT USED. This is an idea that Im working on.

unit STL;

{$MODE objfpc}{$H+}

interface

uses SysUtils;

type
  Std = class
    type
    generic Vector<TItem> = object
    public
      FItems: array of TItem;
    strict private
      function GetItem(const AIndex: Integer): TItem;
      procedure SetItem(const AIndex: Integer; AItem: TItem);
    public
      function Size: Integer;
      procedure Resize(const AIndex: Integer);
      function Find(const AName: TItem): Integer;
    public
      property Items[const AIndex: Integer]: TItem read GetItem write SetItem; default;
    end;
  end;

  VectorString = specialize Std.Vector<String>;
  VectorInteger = specialize Std.Vector<Integer>;

implementation

function Std.Vector.Size: Integer;
begin
  Result := Length(FItems);
end;

procedure Std.Vector.Resize(const AIndex: Integer);
begin
  SetLength(FItems, AIndex);
end;

function Std.Vector.GetItem(const AIndex: Integer): TItem;
begin
  Result := FItems[AIndex];
end;

procedure Std.Vector.SetItem(const AIndex: Integer; AItem: TItem);
begin
  FItems[AIndex] := AItem;
end;

function Std.Vector.Find(const AName: TItem): Integer;
begin
  for Result := 0 to Size - 1 do
  begin
    if AName = FItems[Result] then
    begin
      Exit;
    end;
  end;
  Result := -1;
end;

end.

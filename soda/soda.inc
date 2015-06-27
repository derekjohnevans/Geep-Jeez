{$IF 0}
unit Soda;

{$ENDIF}

{$IFNDEF DItemClass}
{$ERROR Class name is undefined.}
{$ENDIF}

{$IFNDEF DItemOwner}
{$DEFINE DItemOwner := TComponent}
{$ENDIF}

{$IFNDEF DItemItems}
{$DEFINE DItemItemsPrivate}
{$DEFINE DItemItems := CComponent}
{$ENDIF}

{$IFDEF DItemSuper}
{$IF 0}
interface

type
  CComponent = class
{$ENDIF}
    (DItemSuper)
  strict private
    type TClassOf = object
      type Super = DItemSuper;
      type Owner = DItemOwner;
      type Components = DItemItems;
    end;
    type TComponentEnumerator = object
    private
      FIndex: Integer;
      FComponent: DItemClass;
      function GetCurrent: DItemItems;
    public
      function MoveNext: Boolean;
      property Current: DItemItems read GetCurrent;
    end;
    function GetComponent(const AIndex: Integer): DItemItems;
    function GetOwner: DItemOwner; reintroduce;
    function GetSuper: DItemSuper;
  public
    function CreateComponent(const AName: String = ''): DItemItems;
    function FindComponent(const AName: String): DItemItems;
    function GetEnumerator: TComponentEnumerator;
    property Components[const AIndex: Integer]: DItemItems read GetComponent; default;
  public
    constructor Create(const AOwner: DItemOwner); reintroduce;
  public
    property Owner: DItemOwner read GetOwner;
  strict private
{$IF 0}
  end;

implementation

{$ENDIF}

{$ENDIF}

{$IFNDEF DItemSuper}

constructor DItemClass.Create(const AOwner: TClassOf.Owner);
begin
  Assert(AOwner is TClassOf.Owner);
  inherited Create(AOwner);
end;

function DItemClass.CreateComponent(const AName: String): TClassOf.Components;
begin
  Result := TClassOf.Components.CreateNamed(Self, AName);
end;

function DItemClass.FindComponent(const AName: String): TClassOf.Components;
begin
  Result := inherited FindComponent(AName) as TClassOf.Components;
end;

function DItemClass.GetOwner: TClassOf.Owner;
begin
  Result := TClassOf.Owner(inherited Owner);
end;

function DItemClass.GetSuper: TClassOf.Super;
begin
  Result := Self;
end;

function DItemClass.GetComponent(const AIndex: Integer): TClassOf.Components;
begin
  Result := inherited Components[AIndex] as TClassOf.Components;
end;

function DItemClass.TComponentEnumerator.GetCurrent: TClassOf.Components;
begin
  Result := FComponent.Components[FIndex];
end;

function DItemClass.TComponentEnumerator.MoveNext: Boolean;
begin
  Result := FIndex < FComponent.ComponentCount - 1;
  if Result then
  begin
    Inc(FIndex);
  end;
end;

function DItemClass.GetEnumerator: TComponentEnumerator;
begin
  Result.FIndex := -1;
  Result.FComponent := Self;
end;

{$ENDIF}

{$UNDEF DItemItemsPrivate}
{$UNDEF DItemSuper}
{$UNDEF DItemClass}
{$UNDEF DItemOwner}
{$UNDEF DItemItems}

{$IF 0}
end.
{$ENDIF}

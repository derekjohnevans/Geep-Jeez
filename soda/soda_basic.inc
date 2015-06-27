{$IF 0}
unit SodaBasic;

{$ENDIF}

{$IFNDEF DItemItems}
{$DEFINE DItemItems := TComponent}
{$ENDIF}

{$IFDEF DItemSuper}
{$IF 0}
interface

type
  CComponent = class
{$ENDIF}

    // TODO: What about parent & controls type checking?

    (DItemSuper)
  strict private
    type TClassOfSuper = DItemSuper;
    type TClassOfOwner = DItemOwner;
    type TClassOfComponents = DItemItems;
    {$IFDEF DItemClass}
    type TClassOfSelf = DItemClass;
    type TClassOfEnum = DItemItems;
    {$ELSE}
    type TClassOfSelf = TComponent;
    type TClassOfEnum = TComponent;
    {$ENDIF}
    type TComponentEnumerator = object
    private
      FIndex: Integer;
      FComponent: TClassOfSelf;
      function GetCurrent: TClassOfEnum;
    public
      function MoveNext: Boolean;
      property Current: TClassOfEnum read GetCurrent;
    end;
    function GetComponent(const AIndex: Integer): TClassOfComponents; reintroduce;
    function GetOwner: TClassOfOwner; reintroduce;
    function GetSuper: TClassOfSuper;
  protected
    procedure DoCreate;
  public
    constructor Create(const AOwner: TClassOfOwner); reintroduce;
  public
    function GetEnumerator: TComponentEnumerator;
  public
    property Components[const AIndex: Integer]: TClassOfComponents read GetComponent; default;
    property Owner: TClassOfOwner read GetOwner;
  strict private
{$IF 0}
  end;

implementation

{$ENDIF}
{$ENDIF}

{$IFNDEF DItemSuper}

constructor DItemClass.Create(const AOwner: TClassOfOwner);
begin
  Assert(AOwner is TClassOfOwner);
  inherited Create(AOwner);
  DoCreate;
end;

function DItemClass.GetOwner: TClassOfOwner;
begin
  Result := TClassOfOwner(inherited Owner);
end;

function DItemClass.GetSuper: TClassOfSuper;
begin
  Result := Self;
end;

function DItemClass.GetComponent(const AIndex: Integer): TClassOfComponents;
begin
  Result := inherited Components[AIndex] as TClassOfComponents;
end;

function DItemClass.TComponentEnumerator.GetCurrent: TClassOfEnum;
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

{$UNDEF DItemClass}
{$UNDEF DItemSuper}
{$UNDEF DItemOwner}
{$UNDEF DItemItems}

{$IF 0}
end.
{$ENDIF}

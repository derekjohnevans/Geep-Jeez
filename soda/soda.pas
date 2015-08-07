(*
  SSSSSS      OOOOOO    DDDDDDDD        AAAAA
SSSS  SSSS  OOOO  OOOO  DDDD  DDD      AAAAAAA
SSSS        OOOO  OOOO   DDD   DDD    AAA   AAA
  SSSSSS    OOOO  OOOO   DDD   DDD   AAAAAAAAAAA
      SSSS  OOOO  OOOO   DDD   DDD   AAAA   AAAA
SSSS  SSSS  OOOO  OOOO  DDDD  DDD    AAAA   AAAA
  SSSSSS      OOOOOO    DDDDDDDD     AAAA   AAAA

               The SODA Component

*)
unit Soda;

{$MODE DELPHI}

interface

uses
  Classes, Masks, SysUtils;

type

  TItemFlag = (ifCreated, ifDestroyed);
  TItemFlags = set of TItemFlag;

  CComponent = class(TComponent)
  strict private
    FFlags: TItemFlags;
  strict private
    function GetComponent(const AIndex: Integer): CComponent;
  protected
    procedure DoCreate; virtual;
    procedure DoDestroy; virtual;
  public
    function FindComponent(const AName: TComponentName;
      const ACaseSensitive: Boolean = False): CComponent;
    function FindComponentMaskDest(const AName: TComponentName;
      const ACaseSensitive: Boolean = False): CComponent;
    function ComponentExists(const AName: TComponentName): Boolean;
    function ComponentExistsMaskDest(const AName: TComponentName;
      const ACaseSensitive: Boolean = False): Boolean;
    function HasComponents: Boolean;
    function IsEmpty: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    constructor CreateNamed(AOwner: TComponent; const AName: TComponentName); virtual;
    destructor Destroy; override;
  public
    property Components[const AIndex: Integer]: CComponent read GetComponent; default;
  end;

  CComponentEx = class(CComponent)
  public
    procedure ExceptionRaise(const AMessage: String);
    procedure ExceptionAssert(const ATrue: Boolean; const AMessage: String);
  end;

implementation

constructor CComponent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  DoCreate;
  if not (ifCreated in FFlags) then
  begin
    Beep;
  end;
end;

destructor CComponent.Destroy;
begin
  DoDestroy;
  if not (ifDestroyed in FFLags) then
  begin
    Beep;
  end;
  inherited Destroy;
end;

constructor CComponent.CreateNamed(AOwner: TComponent; const AName: TComponentName);
begin
  ChangeName(AName);
  Create(AOwner);
end;

procedure CComponent.DoCreate;
begin
  Include(FFlags, ifCreated);
end;

procedure CComponent.DoDestroy;
begin
  Include(FFlags, ifDestroyed);
end;

function CComponent.IsEmpty: Boolean;
begin
  Result := inherited ComponentCount = 0;
end;

function CComponent.HasComponents: Boolean;
begin
  Result := inherited ComponentCount > 0;
end;

function CComponent.GetComponent(const AIndex: Integer): CComponent;
begin
  Result := inherited Components[AIndex] as CComponent;
end;

function CComponent.FindComponent(const AName: TComponentName;
  const ACaseSensitive: Boolean): CComponent;
var
  LIndex: Integer;
begin
  if ACaseSensitive then
  begin
    for LIndex := 0 to ComponentCount - 1 do
    begin
      Result := Self[LIndex];
      if CompareStr(AName, Result.Name) = 0 then
      begin
        Exit;
      end;
    end;
  end else begin
    for LIndex := 0 to ComponentCount - 1 do
    begin
      Result := Self[LIndex];
      if CompareText(AName, Result.Name) = 0 then
      begin
        Exit;
      end;
    end;
  end;
  Result := nil;
end;

function CComponent.FindComponentMaskDest(const AName: TComponentName;
  const ACaseSensitive: Boolean): CComponent;
var
  LIndex: Integer;
begin
  for LIndex := 0 to ComponentCount - 1 do
  begin
    Result := Self[LIndex];
    if MatchesMask(AName, Result.Name, ACaseSensitive) then
    begin
      Exit;
    end;
  end;
  Result := nil;
end;

function CComponent.ComponentExists(const AName: TComponentName): Boolean;
begin
  Result := Assigned(FindComponent(AName));
end;

function CComponent.ComponentExistsMaskDest(const AName: TComponentName;
  const ACaseSensitive: Boolean): Boolean;
begin
  Result := Assigned(FindComponentMaskDest(AName, ACaseSensitive));
end;

procedure CComponentEx.ExceptionRaise(const AMessage: String);
begin
  raise Exception.Create(AMessage);
end;

procedure CComponentEx.ExceptionAssert(const ATrue: Boolean; const AMessage: String);
begin
  if not ATrue then
  begin
    ExceptionRaise(AMessage);
  end;
end;

end.

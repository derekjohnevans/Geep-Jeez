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

unit UJeezSplash;

{$MODE DELPHI}

interface

uses
  ExtCtrls, Forms, JeezUtils;

type

  { TJeezSplash }

  TJeezSplash = class(TForm)
    Image: TImage;
    Timer: TTimer;
    procedure FormClose(ASender: TObject; var ACloseAction: TCloseAction);
    procedure FormCreate(ASender: TObject);
    procedure ImageClick(ASender: TObject);
    procedure TimerTimer(ASender: TObject);
  private
  public
  end;

var
  JeezSplash: TJeezSplash;

implementation

{$R *.lfm}

procedure TJeezSplash.FormCreate(ASender: TObject);
begin
  Caption := GsJeezTitle;
end;

procedure TJeezSplash.ImageClick(ASender: TObject);
begin
  Close;
end;

procedure TJeezSplash.FormClose(ASender: TObject; var ACloseAction: TCloseAction);
begin
  ACloseAction := caFree;
end;

procedure TJeezSplash.TimerTimer(ASender: TObject);
begin
  Close;
end;

end.


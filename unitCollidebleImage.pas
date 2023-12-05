unit unitCollidebleImage;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, raylib;

type CollidebleImage = class
private
  image: TImage;
  texture: TTexture2D;
  position: TVector2;
  left, right, top, bottom: Single;

public
  constructor Create(_position: TVector2; _image: TImage);
  function IsPointColliding(point: TVector2): boolean;
  function IsCollidingWithOther(other: CollidebleImage): boolean;
  procedure SetPosition(_position: TVector2);
  function GetPosition(): TVector2;
  procedure Draw();
end;

implementation

constructor CollidebleImage.Create(_position: TVector2; _image: TImage);
begin
     image    := _image;
     texture  := LoadTextureFromImage(image);

     SetPosition(_position);
end;

function CollidebleImage.IsPointColliding(point: TVector2): Boolean;
var x, y: Integer;
begin
     if ((point.x <= left) or (point.x >= right) or
         (point.y <= top)  or (point.y >= bottom))
     then
         Exit(false);

     x := round(point.x - left);
     y := round(point.y - top);

     Exit(GetImageColor(image, x, y).a <> 0);
end;

function CollidebleImage.IsCollidingWithOther(other: CollidebleImage): boolean;
var i, j: integer;
begin
     for i := 0 to image.height-1 do begin
       for j := 0 to image.width-1 do begin;
         if (GetImageColor(image, j, i).a = 0) then continue;

         if (other.IsPointColliding(Vector2Create(left + j, top + i))) then
             Exit(true);
       end;
     end;

     Exit(false);
end;

procedure CollidebleImage.SetPosition(_position: TVector2);
begin
     position := _position;
     left     := position.x - image.width / 2;
     right    := position.x + image.width / 2 - 1;
     top      := position.y - image.height / 2;
     bottom   := position.y + image.height / 2 - 1;
end;

function CollidebleImage.GetPosition(): TVector2;
begin
     Exit(position);
end;

procedure CollidebleImage.Draw();
begin
     DrawTextureV(texture, Vector2Create(left, top), WHITE);
end;

end.


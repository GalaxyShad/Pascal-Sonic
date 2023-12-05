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
  procedure Draw();
end;

implementation

constructor CollidebleImage.Create(_position: TVector2; _image: PImage);
begin
     image := _image;
     position := _position;
     texture := LoadTextureFromImage(image);
     left := 0;
     right := 256;
     top := 0;
     bottom := 256;
     //left := position.x - image.width / 2;
     //right := position.y + image.width / 2;
     //top := position.y - image.height / 2;
     //bottom := position.y + image.height / 2;
end;

function CollidebleImage.IsPointColliding(point: TVector2): boolean;
var x, y: Single;
begin
     if (point.x < left || point.x > right ||
         point.y < top || point.y > bottom)
     then
        return false;

     x := point.x - left;
     y := point.y - top;

     return GetImageColor(image, x, y) != BLANK;
end;

procedure CollidebleImage.Draw();
begin
     //DrawTextureV(texture, Vector2Create(left, top), WHITE);
end;

end.


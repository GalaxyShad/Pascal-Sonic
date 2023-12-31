unit unitTerrain;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fgl, unitCollidebleImage, raylib;

type TMyList = specialize TFPGList<CollidebleImage>;
type

{ Terrain }

 Terrain = class

private
   listSolidObjects: TMyList;
public
   constructor Create();
   procedure Add(image: CollidebleImage);
   function IsCollidingWith(other: CollidebleImage): Boolean;
   function IsCollidingWithPoint(point: TVector2): Boolean;
   procedure Draw();

end;


implementation
constructor Terrain.Create();
begin
     listSolidObjects := TMyList.Create;
end;

procedure Terrain.Add(image: CollidebleImage);
begin
     listSolidObjects.Add(image);
end;

function Terrain.IsCollidingWith(other: CollidebleImage): Boolean;
var i: integer;
begin
     for i := 0 to listSolidObjects.Count-1 do begin
       if (other.IsCollidingWithOther(listSolidObjects.Items[i])) then
          Exit(true);
     end;
     Exit(false);
end;

function Terrain.IsCollidingWithPoint(point: TVector2): Boolean;
var i: integer;
begin
  for i := 0 to listSolidObjects.Count-1 do begin
     if (listSolidObjects.Items[i].IsPointColliding(point)) then
        Exit(true);
   end;
   Exit(false);
end;

procedure Terrain.Draw();
var i: integer;
begin
    for i := 0 to listSolidObjects.Count-1 do begin
       listSolidObjects.Items[i].Draw()
     end;
end;

end.


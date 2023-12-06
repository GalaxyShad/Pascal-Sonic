unit unitTerrain;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fgl, unitCollidebleImage;

type TMyList = specialize TFPGList<CollidebleImage>;
type Terrain = class

private
   listSolidObjects: TMyList;
public
   constructor Create();
   procedure Add(image: CollidebleImage);
   function IsCollidingWith(other: CollidebleImage): Boolean;
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

procedure Terrain.Draw();
var i: integer;
begin
    for i := 0 to listSolidObjects.Count-1 do begin
       listSolidObjects.Items[i].Draw()
     end;
end;

end.


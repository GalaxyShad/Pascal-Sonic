unit unitSensor;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, unitCollidebleImage, unitTerrain, raylib, raymath, Math;

type Sensor = class
  private
     position:     TVector2;
     angle:        Single;

     terrain:      unitTerrain.Terrain;

     sensorMain:   CollidebleImage;

     sensorGround: CollidebleImage;

     sensorLeft:   CollidebleImage;
     sensorRight:  CollidebleImage;
     sensorTop:    CollidebleImage;
     sensorBottom: CollidebleImage;

     sensorSlopeLeft: CollidebleImage;
     sensorSlopeRight: CollidebleImage;
  public
     constructor Create(
       _terrain: unitTerrain.Terrain;
       _position: TVector2;
       _imgMaskMain: TImage;
       _imgMaskSmall: TImage);

     procedure SetPosition(_position: TVector2);
     function GetPosition(): TVector2;

     function GetAngle(): Single;
     procedure SetAngle(_angle: Single);

     function IsCollisionMain(): Boolean;

     function IsCollidingGround(): Boolean;

     function IsCollidingLeft(): Boolean;
     function IsCollidingRight(): Boolean;
     function IsCollidingTop(): Boolean;
     function IsCollidingBottom(): Boolean;

     function CalculateAngle(): Single;

     procedure Draw();
end;

implementation

constructor Sensor.Create(
  _terrain: unitTerrain.Terrain;
  _position: TVector2;
  _imgMaskMain: TImage;
  _imgMaskSmall: TImage);
begin
     terrain        := _terrain;
     position       := _position;
     angle          := 0;

     sensorMain     := CollidebleImage.Create(position, _imgMaskMain);

     sensorLeft     := CollidebleImage.Create(position, _imgMaskSmall);
     sensorRight    := CollidebleImage.Create(position, _imgMaskSmall);
     sensorTop      := CollidebleImage.Create(position, _imgMaskSmall);
     sensorBottom   := CollidebleImage.Create(position, _imgMaskSmall);

     sensorGround   := CollidebleImage.Create(position, _imgMaskSmall);

     sensorSlopeLeft := CollidebleImage.Create(position, _imgMaskSmall);
     sensorSlopeRight := CollidebleImage.Create(position, _imgMaskSmall);

     SetPosition(_position);
end;

procedure Sensor.SetPosition(_position: TVector2);
begin
     position := _position;

     sensorMain.SetPosition(position);

     sensorBottom.SetPosition(Vector2Create(
         position.x - 20 * Sin(angle),
         position.y + 20 * Cos(angle)
     ));

     sensorTop.SetPosition(Vector2Create(
         position.x + 20 * Sin(angle),
         position.y - 20 * Cos(angle)
     ));

     sensorLeft.SetPosition(Vector2Create(
         position.x - 20 * Cos(angle),
         position.y - 20 * Sin(angle)
     ));

     sensorRight.SetPosition(Vector2Create(
         position.x + 20 * Cos(angle),
         position.y + 20 * Sin(angle)
     ));


     sensorGround.SetPosition(Vector2Create(
         position.x - 30 * Sin(angle),
         position.y + 30 * Cos(angle)
     ));
end;

function Sensor.GetPosition(): TVector2;
begin
     Exit(position);
end;

function Sensor.GetAngle(): Single;
begin
     Exit(angle)
end;

procedure Sensor.SetAngle(_angle: Single);
begin
     angle := _angle;
     SetPosition(position);
end;

function Sensor.IsCollidingGround(): Boolean;
begin
     Exit(terrain.IsCollidingWith(sensorGround));
end;

function Sensor.IsCollisionMain(): Boolean;
begin
     Exit(terrain.IsCollidingWith(sensorMain));
end;

function Sensor.IsCollidingLeft(): Boolean;
begin
    Exit(terrain.IsCollidingWith(sensorLeft));
end;

function Sensor.IsCollidingRight(): Boolean;
begin
    Exit(terrain.IsCollidingWith(sensorRight));
end;

function Sensor.IsCollidingTop(): Boolean;
begin
    Exit(terrain.IsCollidingWith(sensorTop));
end;

function Sensor.IsCollidingBottom(): Boolean;
begin
    Exit(terrain.IsCollidingWith(sensorBottom));
end;

function Sensor.CalculateAngle(): Single;
var
  i: integer;
  foundLeft, foundRight: boolean;
begin

    foundLeft := false;
    foundRight := false;

    for i := 0 to 20 do begin
       if (not foundRight) then begin
         sensorSlopeRight.SetPosition(Vector2Create(
             position.x - (15+i) * Sin(angle) + 8 * Cos(angle),
             position.y + (15+i) * Cos(angle) + 8 * Sin(angle)
         ));

         if (terrain.IsCollidingWith(sensorSlopeRight)) then foundRight := true;
       end;

       if (not foundLeft) then begin
         sensorSlopeLeft.SetPosition(Vector2Create(
             position.x - (15+i) * Sin(angle) - 8 * Cos(angle),
             position.y + (15+i) * Cos(angle) - 8 * Sin(angle)
         ));

         if (terrain.IsCollidingWith(sensorSlopeLeft)) then foundLeft := true;
       end;
    end;

    if (foundLeft and foundRight) then begin
      Exit(ArcTan2(
       sensorSlopeRight.GetPosition().y - sensorSlopeLeft.GetPosition().y,
       sensorSlopeRight.GetPosition().x - sensorSlopeLeft.GetPosition().x
      ))
    end;

    Exit(angle);

end;

procedure Sensor.Draw();
begin
    sensorMain.Draw();

    sensorGround.Draw();

    sensorLeft.Draw();
    sensorRight.Draw();
    sensorTop.Draw();
    sensorBottom.Draw();

    sensorSlopeLeft.Draw();
    sensorSlopeRight.Draw();
end;

end.


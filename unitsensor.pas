unit unitSensor;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, unitCollidebleImage, unitTerrain, raylib, raymath, Math;

type

  { Sensor }

  Sensor = class
  private
    position: TVector2;
    angle: single;

    terrain: unitTerrain.Terrain;

    sensorMain: CollidebleImage;

    sensorGround: CollidebleImage;

    sensorLeft: CollidebleImage;
    sensorRight: CollidebleImage;
    sensorTop: CollidebleImage;
    sensorBottom: CollidebleImage;

    sensorSlopeLeft: CollidebleImage;
    sensorSlopeRight: CollidebleImage;
  public
    constructor Create(_terrain: unitTerrain.Terrain;
      _position: TVector2; _imgMaskMain: TImage; _imgMaskSmall: TImage);

    procedure SetPosition(_position: TVector2);
    function GetPosition(): TVector2;

    function GetAngle(): single;
    procedure SetAngle(_angle: single);

    function IsCollisionMain(): boolean;

    function IsCollidingGround(): boolean;

    function IsCollidingLeft(): boolean;
    function IsCollidingRight(): boolean;
    function IsCollidingTop(): boolean;
    function IsCollidingBottom(): boolean;

    function IsCollidingSlopeLeft(): boolean;
    function IsCollidingSlopeRight(): boolean;

    function CalculateAngle(): single;

    procedure Draw();
  end;

implementation

constructor Sensor.Create(_terrain: unitTerrain.Terrain; _position: TVector2;
  _imgMaskMain: TImage; _imgMaskSmall: TImage);
begin
  terrain := _terrain;
  position := _position;
  angle := 0;

  sensorMain := CollidebleImage.Create(position, _imgMaskMain);

  sensorLeft := CollidebleImage.Create(position, _imgMaskSmall);
  sensorRight := CollidebleImage.Create(position, _imgMaskSmall);
  sensorTop := CollidebleImage.Create(position, _imgMaskSmall);
  sensorBottom := CollidebleImage.Create(position, _imgMaskSmall);

  sensorGround := CollidebleImage.Create(position, _imgMaskSmall);

  sensorSlopeLeft := CollidebleImage.Create(position, _imgMaskSmall);
  sensorSlopeRight := CollidebleImage.Create(position, _imgMaskSmall);

  SetPosition(_position);
end;

procedure Sensor.SetPosition(_position: TVector2);
begin
  position := _position;

  sensorMain.SetPosition(position);

  { Y }
  sensorBottom.SetPosition(Vector2Create(position.x - 15 *
    Sin(angle), position.y + 15 * Cos(angle)));

  sensorTop.SetPosition(Vector2Create(position.x + 15 *
    Sin(angle), position.y - 15 * Cos(angle)));

  { X }
  sensorLeft.SetPosition(Vector2Create(position.x - 15 *
    Cos(angle), position.y - 15 * Sin(angle)));

  sensorRight.SetPosition(Vector2Create(position.x + 15 *
    Cos(angle), position.y + 15 * Sin(angle)));

  { Slopes }
  sensorSlopeRight.SetPosition(Vector2Create(position.x -
    24 * Sin(angle) + 8 * Cos(angle), position.y + 24 * Cos(angle) +
    8 * Sin(angle)));

  sensorSlopeLeft.SetPosition(Vector2Create(position.x -
    24 * Sin(angle) - 8 * Cos(angle), position.y + 24 * Cos(angle) -
    8 * Sin(angle)));

  { Ground }
  sensorGround.SetPosition(Vector2Create(position.x - 24 *
    Sin(angle), position.y + 24 * Cos(angle)));
end;

function Sensor.GetPosition(): TVector2;
begin
  Exit(position);
end;

function Sensor.GetAngle(): single;
begin
  Exit(angle);
end;

procedure Sensor.SetAngle(_angle: single);
begin
  angle := _angle;
  SetPosition(position);
end;

function Sensor.IsCollidingGround(): boolean;
begin
  Exit(terrain.IsCollidingWith(sensorGround));
end;

function Sensor.IsCollisionMain(): boolean;
begin
  Exit(terrain.IsCollidingWith(sensorMain));
end;

function Sensor.IsCollidingLeft(): boolean;
begin
  Exit(terrain.IsCollidingWith(sensorLeft));
end;

function Sensor.IsCollidingRight(): boolean;
begin
  Exit(terrain.IsCollidingWith(sensorRight));
end;

function Sensor.IsCollidingTop(): boolean;
begin
  Exit(terrain.IsCollidingWith(sensorTop));
end;

function Sensor.IsCollidingBottom(): boolean;
begin
  Exit(terrain.IsCollidingWith(sensorBottom));
end;

function Sensor.IsCollidingSlopeLeft: boolean;
begin
  Exit(terrain.IsCollidingWith(sensorSlopeLeft));
end;

function Sensor.IsCollidingSlopeRight: boolean;
begin
  Exit(terrain.IsCollidingWith(sensorSlopeRight));
end;

function Sensor.CalculateAngle(): single;
var
  i: integer;
  pointLeft, pointRight: TVector2;
  foundLeft, foundRight: boolean;
begin
  foundLeft := False;
  foundRight := False;

  for i := 0 to 30 do
  begin
    if (not foundRight) then
    begin
      pointRight := Vector2Create(position.x - (10 + i) *
        Sin(angle) + 8 * Cos(angle), position.y + (10 + i) *
        Cos(angle) + 8 * Sin(angle));

      if (terrain.IsCollidingWithPoint(pointRight)) then foundRight := True;
    end;

    if (not foundLeft) then
    begin
      pointLeft := Vector2Create(position.x - (10 + i) *
        Sin(angle) - 8 * Cos(angle), position.y + (10 + i) *
        Cos(angle) - 8 * Sin(angle));

      if (terrain.IsCollidingWithPoint(pointLeft)) then foundLeft := True;
    end;
  end;

  if (foundLeft and foundRight) then
  begin
    Exit(ArcTan2(pointRight.y - pointLeft.y, pointRight.x -
      pointLeft.x));
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

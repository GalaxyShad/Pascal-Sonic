unit Player;

{$mode objfpc}{$H+}

interface

uses
  Classes, Math, raylib, fgl, unitSensor;

type

  { objPlayer }

  objPlayer = class
  const
    AIR_ACCELERATION_SPEED    = 0.09375;
    GRAVITY_FORCE             = 0.21875;
    MAX_GRAVITY               = 16;

    ACCELERATION_SPEED        = 0.046875;
    DECELERATION_SPEED        = 0.5;
    FRICTION_SPEED            = 0.046875;
    TOP_SPEED                 = 6;

    JUMP_FORCE                = 6.5;

    SLOPE_FACTOR_NORMAL       = 0.125;
    SLOPE_FACTOR_ROLLUP       = 0.078125;
    SLOPE_FACTOR_ROLLDOWN     = 0.3125;

  private
    sensor: unitSensor.Sensor;

    // Texture
    texture: TTexture2D;
    animationFrameRect: TRectangle;

    // Animation
    animation_direction: integer;
    animation: string;
    action: string;
    // Frame
    frame: integer;
    float_frame: real;

    // Player Movement Variables
    x, y, xsp, ysp, gsp: real;
    // ==Y== //
    ground: boolean;

    showSensors: boolean;

    {------------------------------------------------------------------------}

    procedure Landing();
    procedure CollisionsWalls();
    procedure CollisionsGround();
    procedure CollisionsAir();

    procedure MovementGround();
    procedure MovementAir();

    procedure ApplySpeeds();

    procedure ApplyAnimation();
    procedure SetAnimation(sp_frame: real; f_frame, l_frame: integer);

  public
    constructor Create(_x: integer; _y: integer; _texture: TTexture2D;
      _sensor: unitSensor.Sensor); // Create event

    function GetPosition(): TVector2;

    procedure Update();
    procedure Draw();
  end;

implementation

procedure objPlayer.Landing;
var
  angleRad, angleDeg: single;
begin
  angleRad := sensor.CalculateAngle();
  angleDeg := angleRad * RAD2DEG;

  if (angleDeg < 0) then angleDeg += 360;

  if InRange(angleDeg, 0, 23) or InRange(angleDeg, 339, 360) then
    gsp := xsp
  else if InRange(angleDeg, 0, 45) or InRange(angleDeg, 316, 360) then
  begin
    if (abs(xsp) > abs(ysp)) then
      gsp := xsp
    else
      gsp := ysp * 0.5 * sign(sin(angleRad));
  end
  else
  begin
    if (abs(xsp) > abs(ysp)) then
      gsp := xsp
    else
      gsp := ysp * sign(sin(angleRad));
  end;

  action := 'normal';

  ground := True;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

procedure objPlayer.CollisionsWalls;
begin
  //  Stop player
  if (ground) then
  begin
    if ((sensor.IsCollidingLeft()) and (gsp < 0)) or
      ((sensor.IsCollidingRight()) and (gsp > 0)) then
    begin
      gsp := 0;
    end;
  end
  else
  begin
    if ((sensor.IsCollidingLeft()) and (xsp < 0)) or
      ((sensor.IsCollidingRight()) and (xsp > 0)) then
    begin
      xsp := 0;
    end;
  end;

  // Push player
  while (sensor.IsCollidingLeft()) do
  begin
    x += cos(sensor.GetAngle());
    y += sin(sensor.GetAngle());

    sensor.SetPosition(Vector2Create(x, y));
  end;

  while (sensor.IsCollidingRight()) do
  begin
    x -= cos(sensor.GetAngle());
    y -= sin(sensor.GetAngle());

    sensor.SetPosition(Vector2Create(x, y));
  end;
end;

procedure objPlayer.CollisionsGround;
begin
  if not ground then Exit();

  while (sensor.IsCollisionMain()) do
  begin
    x += sin(sensor.GetAngle());
    y -= cos(sensor.GetAngle());

    sensor.SetPosition(Vector2Create(x, y));
  end;


  while (sensor.IsCollidingGround() and not sensor.IsCollisionMain()) do
  begin
    x -= sin(sensor.GetAngle());
    y += cos(sensor.GetAngle());

    sensor.SetPosition(Vector2Create(x, y));
  end;

  sensor.SetAngle(sensor.CalculateAngle());

  if (not sensor.IsCollidingGround()) then ground := False;
end;

procedure objPlayer.CollisionsAir;
begin
  if ground then Exit();

  sensor.SetAngle(0);

  if (sensor.IsCollidingTop()) and (ysp < 0) then
  begin
    while sensor.IsCollidingTop() do
    begin
      y += 1;
      sensor.SetPosition(Vector2Create(x, y));
    end;

    ysp := 0;
  end;

  if (sensor.IsCollidingBottom()) and (ysp > 0) then
  begin
    while sensor.IsCollidingBottom() do
    begin
      y -= 1;
      sensor.SetPosition(Vector2Create(x, y));
    end;

    Landing();
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

procedure objPlayer.MovementGround;
begin
  if not ground then Exit();

  // Slope decceleration
  gsp += SLOPE_FACTOR_NORMAL * sin(sensor.GetAngle());

  // Movement
  if (IsKeyDown(KEY_LEFT)) then
  begin
    if (gsp > 0) then
      gsp := gsp - DECELERATION_SPEED
    else if (gsp > -TOP_SPEED) then
      gsp := gsp - ACCELERATION_SPEED;
  end
  else if (IsKeyDown(KEY_RIGHT)) then
  begin
    if (gsp < 0) then
      gsp := gsp + DECELERATION_SPEED
    else if (gsp < TOP_SPEED) then
      gsp := gsp + ACCELERATION_SPEED;
  end
  else
    gsp := gsp - min(abs(gsp), FRICTION_SPEED) * sign(gsp);

  if (ground) and (IsKeyDown(KEY_UP)) then
  begin
    xsp -= JUMP_FORCE * -sin(sensor.GetAngle());
    ysp -= JUMP_FORCE * cos(sensor.GetAngle());

    action := 'jump';

    ground := False;
  end;

end;

procedure objPlayer.MovementAir;
begin
  if ground then Exit();

  // Movement
  if (IsKeyDown(KEY_LEFT)) then
    xsp -= AIR_ACCELERATION_SPEED
  else if (IsKeyDown(KEY_RIGHT)) then
    xsp += AIR_ACCELERATION_SPEED;

  // Gravity
  ysp += GRAVITY_FORCE;

  if (ysp > MAX_GRAVITY) then
    ysp := MAX_GRAVITY;

end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

procedure objPlayer.ApplySpeeds;
begin
  if ground then
  begin
    xsp := gsp * cos(sensor.GetAngle());
    ysp := gsp * sin(sensor.GetAngle());
  end;

  x += xsp;
  y += ysp;

  sensor.SetPosition(Vector2Create(x, y));
end;

constructor objPlayer.Create(_x: integer; _y: integer; _texture: TTexture2D;
  _sensor: unitSensor.Sensor);
begin
  sensor := _sensor;
  texture := _texture;
  animationFrameRect := RectangleCreate(0, 0, 64, 64);

  //===Positions===//
  x := _x; //set player x
  y := _y; //set player y

  // ===Animation===//
  animation := 'walking';
  action := 'normal';

  animation_direction := 1;
  frame := 0;
  float_frame := 0;

  //===Speed===//
  gsp := 0.0;
  xsp := 0.0;
  ysp := 0.0;

  //===X Values===//

  //===Y Values===//
  ground := False;

  showSensors := False;
end;

function objPlayer.GetPosition(): TVector2;
begin
  Exit(Vector2Create(x, y));
end;

procedure objPlayer.SetAnimation(sp_frame: real; f_frame, l_frame: integer);
begin
  float_frame += sp_frame;
  if (float_frame >= l_frame + 1) or (float_frame < f_frame) then
  begin
    float_frame := f_frame;
  end;
  frame := trunc(float_frame);
end;

procedure objPlayer.ApplyAnimation();
begin
  // SetAnimations

  if (animation = 'idle') then
    SetAnimation(0, 71, 71);
  if (animation = 'walking') then
    SetAnimation(0.1 + abs(gsp / 25), 0, 6)
  else if (animation = 'run') then
    SetAnimation(0.1 + abs(gsp / 25), 32, 35)
  else if (animation = 'jump') then
    SetAnimation(0.1 + abs(gsp / 25), 149, 153);

end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

procedure objPlayer.Update();
begin
  // Apply speeds to position
  ApplySpeeds();

  // Collisions
  CollisionsWalls();

  if (ground) then
  begin
    CollisionsGround();
    MovementGround();
  end
  else
  begin
    CollisionsAir();
    MovementAir();
  end;

  //Anim
  if (action = 'normal') then
  begin
    if gsp = 0 then
      animation := 'idle'
    else if (abs(gsp) > 0) and (abs(gsp) < 6) then
      animation := 'walking'
    else
      animation := 'run';
  end
  else if (action = 'jump') then animation := 'jump';

  //Scale
  if gsp > 0 then
    animation_direction := 1;
  if gsp < 0 then
    animation_direction := -1;

  ApplyAnimation();
end;

procedure objPlayer.Draw();
begin
  animationFrameRect := RectangleCreate(64 * frame, 0, 64 *
    Sign(animation_direction), 64);

  DrawTexturePro(texture, animationFrameRect, RectangleCreate(x, y, 64, 64),
    Vector2Create(32, 32), sensor.GetAngle() * RAD2DEG, WHITE);

  if (IsKeyPressed(KEY_D)) then showSensors := not showSensors;

  if showSensors then sensor.Draw();

end;

{------------------------------------------------------------------------------}

end.

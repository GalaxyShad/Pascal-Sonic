unit Player;

{$mode objfpc}{$H+}

interface

uses
  Classes, Math, raylib, raymath, unitSensor;

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
    animationAngle: single;
    animation: string;
    action: string;

    spinrev: single;

    // Frame
    frame: integer;
    float_frame: real;

    // Player Movement Variables
    x, y, xsp, ysp, gsp: single;

    // ==Y== //
    ground: boolean;

    showSensors: boolean;

    sndJump: TSound;
    sndRoll: TSound;
    sndSpinCharge: TSound;
    sndSpinRelease: TSound;

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

    function SlopeDecceleration: single;

    function AngleDifference(a: single; b: single): single;

  public
    constructor Create(
      _x: integer;
      _y: integer;
      _texture: TTexture2D;
      _sensor: unitSensor.Sensor;
      _sndJump: TSound;
      _sndRoll: TSound;
      _sndSpinCharge: TSound;
      _sndSpinRelease: TSound
    );

    function GetPosition(): TVector2;
    function GetGrounded(): Boolean;
    function GetGsp(): Single;

    procedure Update();
    procedure Draw();
  end;

implementation

constructor objPlayer.Create(
  _x: integer;
  _y: integer;
  _texture: TTexture2D;
  _sensor: unitSensor.Sensor;
  _sndJump: TSound;
  _sndRoll: TSound;
  _sndSpinCharge: TSound;
  _sndSpinRelease: TSound
);
begin
  sndJump := _sndJump;
  sndRoll := _sndRoll;
  sndSpinCharge := _sndSpinCharge;
  sndSpinRelease := _sndSpinRelease;

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

  ground := False;

  spinrev:=0;
  showSensors := False;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

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

  if (sensor.IsCollidingGround()) then
  begin
    while (not sensor.IsCollisionMain()) do
    begin
      x -= sin(sensor.GetAngle());
      y += cos(sensor.GetAngle());

      sensor.SetPosition(Vector2Create(x, y));
    end;

    if (sensor.IsCollidingSlopeLeft()) and (sensor.IsCollidingSlopeRight()) then
      sensor.SetAngle(sensor.CalculateAngle());
  end;

  if (not sensor.IsCollidingGround()) and
     (not sensor.IsCollidingSlopeLeft()) and
     (not sensor.IsCollidingSlopeRight()) then
    ground := False;
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

  CollisionsWalls();
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

function objPlayer.SlopeDecceleration: single;
var sinAngle: single;
begin
  sinAngle := sin(sensor.GetAngle());

  if action = 'roll' then
  begin
    if (sign(gsp) <> sign(sinAngle)) then
      Exit(SLOPE_FACTOR_ROLLUP * sinAngle)
    else
      Exit(SLOPE_FACTOR_ROLLDOWN * sinAngle);
  end;

  Exit(SLOPE_FACTOR_NORMAL * sinAngle);
end;

function objPlayer.AngleDifference(a: single; b: single): single;
begin
  AngleDifference := a - b;

  if AngleDifference > 180 then
    AngleDifference -= 360;

  if AngleDifference < -180 then
    AngleDifference += 360;

  Exit(AngleDifference);
end;

procedure objPlayer.MovementGround;
var ang: single;
begin
  if not ground then Exit();

  gsp += SlopeDecceleration();

  // Movement
  if not (action = 'spindash') and not (action = 'lookdown') then
  begin
    if not (action = 'roll') then
    begin
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
    end
    else
    begin
      gsp := gsp - min(abs(gsp), FRICTION_SPEED / 2) * sign(gsp);
    end;
  end;

  if IsKeyPressed(KEY_Z) and not (action = 'lookdown') and not (action = 'spindash') then
  begin
    xsp -= JUMP_FORCE * -sin(sensor.GetAngle());
    ysp -= JUMP_FORCE * cos(sensor.GetAngle());

    action := 'jump';

    ground := False;

    PlaySound(sndJump);
  end;

  if (action = 'roll') then
  begin
    if (abs(gsp) < 0.5) then
      action := 'normal'
  end
  else if (action = 'normal') and IsKeyDown(KEY_DOWN) and (abs(gsp) >= 0.5) then
  begin
    action := 'roll';
    PlaySound(sndRoll);
  end;

  if (action = 'normal') and (IsKeyDown(KEY_DOWN)) and (gsp = 0) then
  begin
    action := 'lookdown';
  end;

  if (action = 'lookdown') then
  begin
    gsp := 0;

    if not (IsKeyDown(KEY_DOWN)) then
      action := 'normal';

    if (IsKeyPressed(KEY_Z)) then
    begin
      action := 'spindash';
      spinrev := 0;

      PlaySound(sndSpinCharge);
    end;

  end;

  if (action = 'spindash') then
  begin
    gsp := 0;

    if (IsKeyPressed(KEY_Z)) then begin
      spinrev += 2;
      StopSound(sndSpinCharge);
      PlaySound(sndSpinCharge);
    end;


    if not (IsKeyDown(KEY_DOWN)) then begin
      gsp := (8 + (floor(spinrev) / 2)) * animation_direction;
      action := 'roll';
      StopSound(sndSpinCharge);
      PlaySound(sndSpinRelease);

    end;

    if (spinrev > 8) then spinrev := 8;

    spinrev -= ((floor(spinrev * 1000) div 125) / 256000);
  end;

  ang := sensor.GetAngle() * RAD2DEG;
  if (ang < 0) then ang += 360;

  if (abs(gsp) < 2.5) and (InRange(ang, 46, 315)) then
  begin
    ground := false;
    gsp := 0;
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

  // Jump height control
  if (action = 'jump') and (ysp < -4) and (not IsKeyDown(KEY_Z)) then
    ysp := -4;

  // Air Drag
  if (ysp < 0) and (ysp > -4) then
    xsp -= ((floor(xsp * 1000) div 125) / 256000)

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

function objPlayer.GetPosition(): TVector2;
begin
  Exit(Vector2Create(x, y));
end;

function objPlayer.GetGrounded: Boolean;
begin
   Exit(ground);
end;

function objPlayer.GetGsp: Single;
begin
  Exit(gsp);
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
  else if (animation = 'roll') then
    SetAnimation(0.1 + abs(gsp / 25), 149, 153)
  else if (animation = 'spiral') then
    SetAnimation(0.1 + abs(ysp / 50), 48, 59)
  else if (animation = 'spindash') then
    SetAnimation(0.25, 133, 138)
  else if (animation = 'lookdown') then
    SetAnimation(0, 155, 155);

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
    if ground then
    begin
      if gsp = 0 then
        animation := 'idle'
      else if (abs(gsp) > 0) and (abs(gsp) < 6) then
        animation := 'walking'
      else
        animation := 'run';
    end
    else
      animation := 'spiral';
  end
  else if (action = 'jump') or (action = 'roll') then
    animation := 'roll'
  else if (action = 'lookdown') then
    animation := 'lookdown'
  else if (action = 'spindash') then
    animation := 'spindash';

  //Scale
  if gsp > 0 then
    animation_direction := 1;
  if gsp < 0 then
    animation_direction := -1;

  ApplyAnimation();
end;

procedure objPlayer.Draw();
var
  degAngle: single;
  offset: TVector2;
begin
  animationFrameRect := RectangleCreate(64 * frame, 0, 64 *
    Sign(animation_direction), 64);

  if (animation = 'roll') then
    offset := Vector2Create(32, 32)
  else
    offset := Vector2Create(32, 38);

  degAngle := sensor.GetAngle() * RAD2DEG;
  if (degAngle < 0) then degAngle += 360;


  if animation = 'roll' then
    animationAngle := 0
  else
  begin
    if (not ground) then
      animationAngle += AngleDifference(0, animationAngle) / 10.0
    else
    begin

      if (degAngle >= 35) and (degAngle <= 325) then
        animationAngle += AngleDifference(degAngle, animationAngle) / 4.0
      else
        animationAngle += AngleDifference(0, animationAngle) / 4.0;
    end;
  end;

  DrawTexturePro(texture, animationFrameRect, RectangleCreate(x, y, 64, 64),
    offset, animationAngle, WHITE);

  if (IsKeyPressed(KEY_D)) then showSensors := not showSensors;

  if showSensors then sensor.Draw();

end;

{------------------------------------------------------------------------------}

end.

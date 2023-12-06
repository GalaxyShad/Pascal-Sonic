unit Player;

{$mode objfpc}{$H+}

interface

uses
  Classes, Math, raylib, fgl, unitSensor;

type
objPlayer = class
const
   MAX_GRAVITY = 16;
private
   sensor:                      unitSensor.Sensor;

   // Texture
   texture:                     TTexture2D;
   animationFrameRect:          TRectangle;

   // Animation
   animation_direction:         integer;
   animation:                   string;
   action:                      string;
   // Frame
   frame:                       integer;
   float_frame:                 real;

   // Player Movement Variables
   x, y, xsp, ysp, gsp:         real;
   // ==X== //
   acc, frc, topsp, dec:        real;
   // ==Y== //
   gravity, jump:               real;
   ground:                      boolean;
public
   constructor Create(_x: integer; _y: integer; _texture: TTexture2D; _sensor: unitSensor.Sensor); //Create event
   procedure Update();
   procedure PlayerSetAnimation(sp_frame:real; f_frame, l_frame: integer);
   procedure PlayerAnimation();
   procedure PlayerMovement();
   procedure PlayerGamePlay();
   procedure Draw();
end;

implementation

constructor objPlayer.Create(_x:integer; _y:integer; _texture: TTexture2D; _sensor: unitSensor.Sensor);
begin
     sensor := _sensor;
     texture := _texture;
     animationFrameRect := RectangleCreate(0, 0, 64, 64);

     //===Positions===//
     x := _x; //set player x
     y := _y; //set player y

     // ===Animation===//
     animation             := 'walking';
     action                := 'normal';

     animation_direction   := 1;
     frame                 := 0;
     float_frame           := 0;

     //===Speed===//
     gsp                   := 0.0;
     xsp                   := 0.0;
     ysp                   := 0.0;

     //===X Values===//
     acc                   := 0.046875 ;
     dec                   := 0.5;
     frc                   := 0.046875;
     topsp                 := 6;
     //===Y Values===//
     gravity               := 0.21875;
     jump                  := 6.5;
     ground                := false;
end;



procedure objPlayer.PlayerSetAnimation(sp_frame:real; f_frame, l_frame: integer);
begin
float_frame += sp_frame;
   if (float_frame >= l_frame+1) or (float_frame < f_frame)   then
      begin
      float_frame := f_frame;
      end;
frame := trunc(float_frame);
end;

procedure objPlayer.PlayerAnimation();
var i,j,a: integer;
begin
      //SetAnimation

     if (animation = 'idle') then  PlayerSetAnimation(0,71,71);
     if      (animation = 'walking')  then  PlayerSetAnimation(0.1+abs(xsp/25),0,6)
     else if (animation = 'walking1') then  PlayerSetAnimation(0.1+abs(xsp/25),7,12)
     else if (animation = 'walking2') then  PlayerSetAnimation(0.1+abs(xsp/25),13,18)
     else if (animation = 'walking3') then  PlayerSetAnimation(0.1+abs(xsp/25),19,24)
     else if (animation = 'walking4') then  PlayerSetAnimation(0.1+abs(xsp/25),25,30)
     else if (animation = 'run')      then  PlayerSetAnimation(0.1+abs(xsp/25),32,35)
     else if (animation = 'jump')     then  PlayerSetAnimation(0.1+abs(xsp/25),149,153);

end;

procedure objPlayer.PlayerMovement();
var
   i,j: integer;
   test: real;
   angleRad: single;
   angleDeg: single;
begin

  if (IsKeyDown(KEY_LEFT)) then
  begin
      if (gsp > 0)            then gsp := gsp - dec
      else if (gsp > -topsp)  then gsp := gsp - acc;
  end
  else if (IsKeyDown(KEY_RIGHT)) then
  begin
      if (gsp < 0)            then gsp := gsp + dec
      else if (gsp < topsp)   then gsp := gsp + acc;
  end
  else
     gsp := gsp - min(abs(gsp), frc) * sign(gsp);

  if (ground) then begin
     xsp := gsp * cos(sensor.GetAngle());
     ysp := gsp * sin(sensor.GetAngle());
  end;


  x += xsp;
  y += ysp;

  sensor.SetPosition(Vector2Create(x, y));

  if (not ground) then begin
    if ((sensor.IsCollidingLeft()) and (xsp < 0)) or ((sensor.IsCollidingRight()) and (xsp > 0)) then
       xsp := 0;
  end else begin
    if ((sensor.IsCollidingLeft()) and (gsp < 0)) or ((sensor.IsCollidingRight()) and (gsp > 0)) then
       gsp := 0;
  end;


  while (sensor.IsCollidingLeft()) do begin
     x += cos(sensor.GetAngle());
     y += sin(sensor.GetAngle());

     sensor.SetPosition(Vector2Create(x, y));
  end;

  while (sensor.IsCollidingRight()) do begin
     x -= cos(sensor.GetAngle());
     y -= sin(sensor.GetAngle());

     sensor.SetPosition(Vector2Create(x, y));
  end;



  if (ground) then begin
    while (sensor.IsCollisionMain()) do begin
      x += sin(sensor.GetAngle());
      y -= cos(sensor.GetAngle());

      sensor.SetPosition(Vector2Create(x, y));
    end;


    while (sensor.IsCollidingGround() and not sensor.IsCollisionMain()) do begin
      x -= sin(sensor.GetAngle());
      y += cos(sensor.GetAngle());

      sensor.SetPosition(Vector2Create(x, y));
    end;

    sensor.SetAngle(sensor.CalculateAngle());

    if (not sensor.IsCollidingGround()) then
    ground := false;

  end
  else begin
       gsp := 0;
       sensor.SetAngle(0);

       while ((ysp < 0) and (sensor.IsCollidingTop())) do begin
          y  += 1;
          sensor.SetPosition(Vector2Create(x, y));
       end;



       if (sensor.IsCollidingBottom()) and (ysp > 0) then begin
          angleRad := sensor.CalculateAngle();
          angleDeg := angleRad * RAD2DEG;

          if (angleDeg < 0) then angleDeg += 360;

          if ((angleDeg >= 0) and (angleDeg <= 23)) or ((angleDeg >= 339) and (angleDeg <= 360)) then
             gsp := xsp
          else if ((angleDeg >= 0) and (angleDeg <= 45)) or ((angleDeg >= 316) and (angleDeg <= 360)) then begin
            WriteLn(angleDeg, angleDeg > 23);
            if (abs(xsp) > abs(ysp)) then gsp := xsp
            else gsp := ysp * 0.5 * sign(sin(angleRad));
          end else begin
            if (abs(xsp) > abs(ysp)) then gsp := xsp
            else gsp := ysp * sign(sin(angleRad));
          end;

          action := 'normal';

          ground := true;
       end;

       while ((ysp > 0) and (sensor.IsCollidingBottom())) do begin
          y   -=  1;
          sensor.SetPosition(Vector2Create(x, y));
      end;
  end;


   if not(ground) then begin
      ysp := ysp + gravity;

      if (ysp > MAX_GRAVITY) then ysp := MAX_GRAVITY;
   end
   else
      ysp := 0;



   //Anim
   if (action = 'normal') then begin
       if gsp = 0 then
          animation := 'idle'
       else if (abs(gsp) > 0) and (abs(gsp) < 6) then
          animation := 'walking'
       else
           animation := 'run';
   end else if (action = 'jump') then animation := 'jump';




   //Scale
   if gsp > 0 then
      animation_direction := 1;
   if gsp < 0 then
      animation_direction := -1;


end;

procedure objPlayer.PlayerGamePlay();
begin
     if (ground) and (IsKeyDown(KEY_UP)) then
        begin
           xsp -= jump * -sin(sensor.GetAngle());
           ysp -= jump * cos(sensor.GetAngle());

           action := 'jump';

           ground := false;
        end;
end;

procedure objPlayer.Update();
begin

     PlayerMovement();
     PlayerGamePlay();
     PlayerAnimation();
end;

procedure objPlayer.Draw();
begin
     animationFrameRect := RectangleCreate(64 * frame, 0, 64 * Sign(animation_direction), 64);
     DrawTexturePro(texture, animationFrameRect, RectangleCreate(x, y, 64, 64), Vector2Create(32, 32), sensor.GetAngle() * RAD2DEG, WHITE);

     sensor.Draw();
end;

end.


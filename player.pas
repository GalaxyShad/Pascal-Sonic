unit Player;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, Graphics;

type

objPlayer = class
public
   //Animation
   animation_direction:         integer;
   animation:                   string;
   image_scale:                 integer;
   sonic_sprites:               TBitmap;
   //Frame
   frame:                       integer;
   float_frame:                 real;

   //Player Movement Variables
   x,y,xsp,ysp: real;
   //==X==//
   acc,frc,topsp,dec :real;
   //==Y==//
   gravity, jump: real;
   ground: boolean;

   constructor Create(_x:integer;_y:integer); //Create event
   procedure   Update();
   procedure PlayerSetAnimation(sp_frame:real; f_frame, l_frame: integer);
   procedure PlayerAnimation();
   procedure PlayerMovement();
   procedure PlayerGamePlay();

end;

implementation
uses Unit1;

constructor objPlayer.Create(_x:integer;_y:integer);
begin
     //===Positions===//
     x := _x; //set player x
     y := _y; //set player y
     //===Animation===//
     animation             :='walking';
     animation_direction   := 1;
     frame                 := 0;
     float_frame           := 0;
     image_scale           := 2;
     sonic_sprites := TBitmap.Create();
     sonic_sprites.LoadFromFile('sonic_spr.bmp');

     //===Speed===//
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
     if (animation = 'idle') then  PlayerSetAnimation(0,0,0);
     if (animation = 'walking') then  PlayerSetAnimation(0.1+abs(xsp/25),1,8);
     //Draw Player
     for i:=0 to 64 do
      begin
           for j:=0 to 64 do
           begin

                cl := sonic_sprites.Canvas.Pixels[i+64*frame,j];
                     if not(cl = sonic_sprites.Canvas.Pixels[1,1]) and not(cl = sonic_sprites.Canvas.Pixels[0,0])  then
                        begin
                             if (animation_direction = 1) then Form1.image2.Canvas.Pixels[trunc(x)+i-cam.offset_x,trunc(y)+j-cam.offset_y] := cl
                             else Form1.image2.Canvas.Pixels[trunc(x)+64-(i)-cam.offset_x,trunc(y)+j-cam.offset_y] := cl;
                        end;

           end;
      end;

end;

procedure objPlayer.PlayerMovement();
var i,j: integer;
begin
     //==X==//
     if (key_left=1) then
        begin
             if (xsp > 0) then
                begin
                     xsp := xsp- dec;
                end
              else if xsp > -topsp then
                begin
                     xsp := xsp-acc;
                end
        end
    else if (key_right=1) then
        begin
             if (xsp < 0) then
                begin
                     xsp := xsp+ dec;
                end
              else if xsp < topsp then
                begin
                     xsp := xsp+acc;
                end;
        end
   else xsp := xsp-Min(abs(xsp), frc)*sign(xsp);

   x:=x+(xsp);
   y:=y+(ysp);

   //==Y==//
   //Gravity and Block Collisions
   //Collsion Y
   for i:=0 to max_tiles do
       begin
            if ((x+23 >= solid_array[i].x) and (x+23 < solid_array[i].x+solid_array[i].w))
            or ((x+41 >= solid_array[i].x) and (x+41 < solid_array[i].x+solid_array[i].w)) then
                 begin
                      if (y+52 < solid_array[i].y) or  (y+52 > solid_array[i].y+solid_array[i].h)then
                      begin
                              ground:=false;

                      end
                      else  if (y+52 >= solid_array[i].y) and  (y+52 < solid_array[i].y+solid_array[i].h) then
                      begin
                              ground := true;
                              ysp:=0;
                              y:= solid_array[i].y-52;
                              break;
                      end;

                 end
                  else
                      begin
                              ground:=false;
                      end;

       end;
   for j := 0 to max_tiles do
       begin
           if (y+32-4 >= solid_array[j].y) and (y+32-4 < solid_array[j].y+solid_array[j].h)  then
              begin
                  if (x+42 >= solid_array[j].x) and (x+42 < solid_array[j].x+solid_array[j].w)    then
                     begin
                         if (xsp > 0) then xsp:=0;
                         x:= solid_array[j].x-42;
                     end;
                  if (x+22 > solid_array[j].x) and (x+22 <= solid_array[j].x+solid_array[j].w)    then
                     begin
                         if (xsp < 0) then xsp:=0;
                         x:= solid_array[j].x+solid_array[j].w-22;
                     end;
              end;

       end;

   if not(ground) then
      ysp := ysp+gravity;


   //Anim
   if xsp = 0  then
      animation := 'idle';
   if abs(xsp) > 0 then
      animation := 'walking';

   //Scale
   if xsp > 0 then
      animation_direction := 1;
   if xsp < 0 then
      animation_direction := -1;

end;

procedure objPlayer.PlayerGamePlay();
begin
     if (ground) and (key_action=1) then
        begin
         ysp := -jump;
         ground := false;
        end;
end;

procedure objPlayer.Update();
begin
     PlayerMovement();
     PlayerGamePlay();

end;

end.


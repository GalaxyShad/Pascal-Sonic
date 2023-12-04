program game;

{$mode objfpc}{$H+}

uses
Player,
cmem, 
{uncomment if necessary}
//raymath, 
//rlgl, 
raylib; 

var
  texSonic: TTexture2D;
  plr:   objPlayer;
const
  screenWidth = 420;
  screenHeight = 240;
begin
  // Initialization
  InitWindow(screenWidth, screenHeight, 'raylib - simple project');
  SetTargetFPS(60);// Set our game to run at 60 frames-per-second

  SetWindowState(FLAG_WINDOW_TRANSPARENT or FLAG_WINDOW_RESIZABLE);

  texSonic := LoadTexture('./textures/Sonic 3 - Sonic.png');
  plr := objPlayer.Create(32, 32, texSonic);

  // Main game loop
  while not WindowShouldClose() do
    begin
      // Update
      // TODO: Update your variables here
      plr.PlayerAnimation();
      plr.PlayerMovement();
      plr.PlayerGamePlay();
      // Draw
      BeginDrawing();
        ClearBackground(RAYWHITE);
        plr.Draw();

        DrawText('raylib in lazarus !!!', 20, 20, 10, DARKGRAY);
      EndDrawing();
    end;

  // De-Initialization
  CloseWindow();        // Close window and OpenGL context
end.


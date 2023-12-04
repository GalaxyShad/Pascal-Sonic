program game;

{$mode objfpc}{$H+}

uses
cmem,
{uncomment if necessary}
raymath,
rlgl,
raylib, unit1;

const
  screenWidth = 800;
  screenHeight = 450;

begin
  // Initialization
  InitWindow(screenWidth, screenHeight, 'raylib - simple project');
  SetTargetFPS(60);// Set our game to run at 60 frames-per-second

  // Main game loop
  while not WindowShouldClose() do
    begin
      // Update
      // TODO: Update your variables here

      // Draw
      BeginDrawing();
        ClearBackground(RAYWHITE);
        DrawText('raylib in lazarus !!!', 20, 20, 10, DARKGRAY);
        DrawCircle(32, 32, 64, ColorFromHSV(60, 127, 127));
      EndDrawing();
    end;

  // De-Initialization
  CloseWindow();        // Close window and OpenGL context
end.

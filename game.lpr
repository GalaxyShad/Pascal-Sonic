program game;

{$mode objfpc}{$H+}

uses
Player,
cmem, unitCollidebleImage,
raylib, unitTerrain, unitSensor;

var
  texSonic: TTexture2D;
  renderer: TRenderTexture2D;
  plr:   objPlayer;
  terrain: unitTerrain.Terrain;
  pinkStar: CollidebleImage;
  mpos: TVector2;
  sensor: unitSensor.Sensor;
  angle: Real;

  camera: TCamera2D;

  i: integer;

  imgBlock: TImage;
  imgMaskMain: TImage;
  imgMaskSmall: TImage;
const
  screenWidth = 426;
  screenHeight = 240;

{$R *.res}

begin
  // Initialization
  InitWindow(screenWidth, screenHeight, 'Pascal Sonic');

  camera.target := Vector2Create(32, 32);
  camera.offset := Vector2Create(screenWidth / 2, screenHeight / 2);
  camera.rotation := 0;
  camera.zoom:=1;

  SetTargetFPS(60); // Set our game to run at 60 frames-per-second

  SetWindowState(FLAG_WINDOW_TRANSPARENT or FLAG_WINDOW_RESIZABLE);

  renderer := LoadRenderTexture(screenWidth, screenHeight);

  texSonic := LoadTexture('./textures/Sonic 3 - Sonic.png');

  //imgBlock := LoadImage('./textures/solid_obj.png');
  imgMaskMain := LoadImage('./textures/mask-main.png');
  imgMaskSmall := LoadImage('./textures/mask-small.png');

  terrain := unitTerrain.Terrain.Create;

  //for i := 0 to 4 do begin
  //    terrain.Add(CollidebleImage.Create(Vector2Create(32*i, 200-8*i), imgBlock));
  //end;
  //
  //for i := 0 to 8 do begin
  //    terrain.Add(CollidebleImage.Create(Vector2Create(0, 32*i), imgBlock));
  //end;

  //terrain.Add(CollidebleImage.Create(Vector2Create(240, 110), LoadImage('./textures/loop.png')));
  terrain.Add(CollidebleImage.Create(Vector2Create(1024, 1024), LoadImage('./textures/big-lvl.png')));

  sensor := unitSensor.Sensor.Create(terrain, Vector2Create(64, 64), imgMaskMain, imgMaskSmall);
  plr := objPlayer.Create(32, 32, texSonic, sensor);

  angle := 0;

  pinkStar := CollidebleImage.Create(Vector2Create(screenWidth / 2, screenHeight / 2), LoadImage('./textures/pink-star.png'));

  // Main game loop
  while not WindowShouldClose() do
  begin

    plr.Update();

    camera.offset := Vector2Create(GetRenderWidth() / 2, GetRenderHeight() / 2);
    camera.zoom := GetRenderWidth() / 420;
    camera.target :=  plr.GetPosition();

    mpos := GetMousePosition();
    pinkStar.SetPosition(mpos);

    if (IsKeyDown(KEY_A)) then angle -= 0.01;
    if (IsKeyDown(KEY_S)) then angle += 0.01;

    BeginDrawing();
    //BeginTextureMode(renderer);

          ClearBackground(RAYWHITE);

          BeginMode2D(camera);
            terrain.Draw();
            plr.Draw();
            pinkStar.Draw();

            if (terrain.IsCollidingWith(pinkStar)) then
               DrawCircleV(mpos, 8, GREEN)
            else
               DrawCircleV(mpos, 8, RED);
          EndMode2D();

          DrawFPS(32, 32);
          //DrawText('raylib in lazarus !!!', 20, 20, 10, DARKGRAY);


    //EndTextureMode();
    EndDrawing();

    //BeginDrawing();
    //  DrawTexturePro(
    //     renderer.texture,
    //     RectangleCreate(0, 0, screenWidth, -screenHeight),
    //     RectangleCreate(0, 0, GetRenderWidth(), GetRenderHeight()),
    //     Vector2Create(0, 0),
    //     0,
    //     WHITE
    //  );
    //EndDrawing();
  end;

  // De-Initialization
  CloseWindow();        // Close window and OpenGL context
end.


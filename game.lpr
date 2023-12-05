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

  i: integer;

  imgBlock: TImage;
  imgMaskMain: TImage;
  imgMaskSmall: TImage;
const
  screenWidth = 420;
  screenHeight = 240;

{$R *.res}

begin
  // Initialization
  InitWindow(screenWidth, screenHeight, 'Pascal Sonic');

  SetTargetFPS(60); // Set our game to run at 60 frames-per-second

  SetWindowState(FLAG_WINDOW_TRANSPARENT or FLAG_WINDOW_RESIZABLE);

  renderer := LoadRenderTexture(screenWidth, screenHeight);

  texSonic := LoadTexture('./textures/Sonic 3 - Sonic.png');

  imgBlock := LoadImage('./textures/solid_obj.png');
  imgMaskMain := LoadImage('./textures/mask-main.png');
  imgMaskSmall := LoadImage('./textures/mask-small.png');

  terrain := unitTerrain.Terrain.Create;

  for i := 0 to 4 do begin
      terrain.Add(CollidebleImage.Create(Vector2Create(32*i, 200-8*i), imgBlock));
  end;
  terrain.Add(CollidebleImage.Create(Vector2Create(240, 110), LoadImage('./textures/loop.png')));


  sensor := unitSensor.Sensor.Create(terrain, Vector2Create(64, 64), imgMaskMain, imgMaskSmall);
  plr := objPlayer.Create(32, 32, texSonic, sensor);

  angle := 0;

  pinkStar := CollidebleImage.Create(Vector2Create(screenWidth / 2, screenHeight / 2), LoadImage('./textures/pink-star.png'));

  // Main game loop
  while not WindowShouldClose() do
  begin
    // Update
    // TODO: Update your variables here
    plr.PlayerAnimation();
    plr.PlayerMovement();
    plr.PlayerGamePlay();

    mpos := GetMousePosition();
    pinkStar.SetPosition(mpos);

    if (IsKeyDown(KEY_A)) then angle -= 0.01;
    if (IsKeyDown(KEY_S)) then angle += 0.01;


    BeginTextureMode(renderer);
        ClearBackground(RAYWHITE);

        terrain.Draw();
        plr.Draw();
        pinkStar.Draw();

        if (terrain.IsCollidingWith(pinkStar)) then
           DrawCircleV(mpos, 8, GREEN)
        else
           DrawCircleV(mpos, 8, RED);

        DrawText('raylib in lazarus !!!', 20, 20, 10, DARKGRAY);
    EndTextureMode();

    BeginDrawing();
      DrawTexturePro(
         renderer.texture,
         RectangleCreate(0, 0, screenWidth, -screenHeight),
         RectangleCreate(0, 0, GetRenderWidth(), GetRenderHeight()),
         Vector2Create(0, 0),
         0,
         WHITE
      );
    EndDrawing();
  end;

  // De-Initialization
  CloseWindow();        // Close window and OpenGL context
end.


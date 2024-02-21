program game;

{$mode objfpc}{$H+}

uses
  Player,
  cmem,
  math,
  unitCollidebleImage,
  raylib,
  unitTerrain,
  unitSensor;

var
  texSonic: TTexture2D;
  renderer: TRenderTexture2D;
  plr: objPlayer;
  terrain: unitTerrain.Terrain;
  pinkStar: CollidebleImage;
  mpos: TVector2;
  sensor: unitSensor.Sensor;
  angle: real;

  camera: TCamera2D;

  i: integer;

  imgBlock: TImage;
  imgMaskMain: TImage;
  imgMaskSmall: TImage;

  sndPlayerJump: TSound;
  sndPlayerRoll: TSound;
const
  screenWidth = 426;
  screenHeight = 240;

procedure CameraUpdate();
var left, right, top, bottom, px, py: single;
begin
  left := camera.target.x - 16;
  right := camera.target.x;
  top := camera.target.y - 32;
  bottom := camera.target.y + 32;

  px := plr.GetPosition().x;
  py := plr.GetPosition().y;

  if px >= right then
    camera.target.x += min(px - right, 16);

  if px <= left then
    camera.target.x += max(px - left, -16);

  if plr.GetGrounded() then
  begin
    if abs(plr.GetGsp()) <= 8 then
      camera.target.y += min(max(py - camera.target.y, -6), 6)
    else
      camera.target.y += min(max(py - camera.target.y, -16), 16);
  end
  else
  begin
    if py >= bottom then
      camera.target.y += min(py - bottom, 16);

    if py <= top then
      camera.target.y += max(py - top, -16);
  end;
end;

begin
  // Initialization
  InitWindow(screenWidth, screenHeight, 'Pascal Sonic');
  InitAudioDevice();

  SetMasterVolume(0.25);

  camera.target := Vector2Create(32, 32);
  camera.offset := Vector2Create(screenWidth / 2, screenHeight / 2);
  camera.rotation := 0;
  camera.zoom := 1;

  SetTargetFPS(60); // Set our game to run at 60 frames-per-second

  SetWindowState(FLAG_WINDOW_TRANSPARENT or FLAG_WINDOW_RESIZABLE);

  renderer := LoadRenderTexture(screenWidth, screenHeight);

  texSonic := LoadTexture('./textures/Sonic 3 - Sonic.png');


  sndPlayerJump := LoadSound('./sounds/jump.wav');
  sndPlayerRoll := LoadSound('./sounds/roll.wav');

  //imgBlock := LoadImage('./textures/solid_obj.png');
  imgMaskMain := LoadImage('./textures/mask-main.png');
  imgMaskSmall := LoadImage('./textures/mask-small.png');

  terrain := unitTerrain.Terrain.Create;

  terrain.Add(CollidebleImage.Create(Vector2Create(1024, 1024),
    LoadImage('./textures/big-lvl.png')));

  sensor := unitSensor.Sensor.Create(terrain, Vector2Create(64, 64),
    imgMaskMain, imgMaskSmall);


  plr := objPlayer.Create(32, 32, texSonic, sensor,
    sndPlayerJump,
    sndPlayerRoll,
    LoadSound('./sounds/spin-charge.wav'),
    LoadSound('./sounds/spin-release.wav')
  );

  angle := 0;

  pinkStar := CollidebleImage.Create(Vector2Create(screenWidth / 2, screenHeight / 2),
    LoadImage('./textures/pink-star.png'));

  // Main game loop
  while not WindowShouldClose() do
  begin

    plr.Update();

    CameraUpdate();

    camera.offset := Vector2Create(GetRenderWidth() / 2, GetRenderHeight() / 2);
    camera.zoom := GetRenderWidth() / 420;


    mpos := GetMousePosition();
    pinkStar.SetPosition(mpos);

    if (IsKeyDown(KEY_A)) then angle -= 0.01;
    if (IsKeyDown(KEY_S)) then angle += 0.01;

    {---------------------------------------------------------------------}
    BeginDrawing();

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
    {---------------------------------------------------------------------}

    EndDrawing();

  end;

  // De-Initialization
  CloseWindow();        // Close window and OpenGL context
end.

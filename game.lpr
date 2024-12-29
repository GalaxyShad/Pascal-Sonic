program game;

{$mode objfpc}{$H+}{$LINKLIB raylib} 

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

  noiseImage: TImage;
  noiseCollidable: CollidebleImage;
  noiseTexture: TTexture2D;

  mpos: TVector2;


  sensor: unitSensor.Sensor;
  angle: real;

  camera: TCamera2D;

  i, j: integer;

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

function GenerateTerrainChunk(width, height, offsetX, offsetY: Integer): TImage;
var img: TImage;
var i, j: Integer;
begin
  img := GenImagePerlinNoise(width, height, offsetX, offsetY, 1);

  for i := 0 to img.height - 1 do begin
    for j := 0 to img.width - 1 do begin
      if GetImageColor(img, j, i).r < 90 then 
        ImageDrawPixel(@img, j, i, GetColor($AAFF00FF))
      else 
        ImageDrawPixel(@img, j, i, GetColor($0))
    end;
  end;

  Result := img;
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

  
  noiseImage := GenerateTerrainChunk(8192, 8192, 0, 0);
  noiseTexture := LoadTextureFromImage(noiseImage);

  // for i := 0 to 100 do begin
  //   for j := 0 to 1 do begin
  //     noiseImage := GenerateTerrainChunk(512, 512, 512 * i, 512 * j);
  //     terrain.Add(CollidebleImage.Create(Vector2Create(i * 512, j * 512), noiseImage));
  //   end;
  // end;

  terrain.Add(
    CollidebleImage.Create(Vector2Create(8192 / 2, 256), 
    noiseImage)
  );

    // LoadImage('./textures/big-lvl.png')));

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

  noiseCollidable := CollidebleImage.Create(Vector2Create(screenWidth / 2, screenHeight / 2), noiseImage);

  // Main game loop
  while not WindowShouldClose() do
  begin

    plr.Update();

    CameraUpdate();

    camera.offset := Vector2Create(GetRenderWidth() / 4, GetRenderHeight() / 4);
    camera.zoom := 0.2;
    // camera.zoom := GetRenderWidth() / 420;

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
      DrawTextureEx(noiseTexture, Vector2Create(0, 0), 0, 0.005, YELLOW);
    {---------------------------------------------------------------------}

    EndDrawing();

  end;

  // De-Initialization
  CloseWindow();        // Close window and OpenGL context
end.

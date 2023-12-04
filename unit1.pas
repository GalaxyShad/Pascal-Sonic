unit game;

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



unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, Math, Player, SysUtils,LCLType, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls;


type

  { TForm1 }

  TForm1 = class(TForm)
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    SpritePlayer: TPicture;
    UpdateTimer: TTimer;
    Timer2: TTimer;

    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);


    procedure Update(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end;

  Obj = class
  x:     real;
  y:     real;
  w:     integer;
  h:     integer;
  image: TBitmap;
  constructor Create(_x:real; _y:real; _width:integer; _height:integer; _image: string);
  procedure Draw();
  end;

  SolidObject = class(Obj)
    public

  end;

  Camera = class
  offset_x, offset_y: integer;
  constructor Create(cam_x:integer;cam_y:integer);
  end;

var

   solid_array : Array of SolidObject;
   Form1: TForm1;
   max_tiles: integer;
   cl: TColor;
   FPS: integer;
   cam: Camera;

   obj1: SolidObject;

   //Player
   pl: objPlayer;
   //Keys
   key_right,key_left,key_action:integer;




implementation

{$R *.lfm}

{ TForm1 }


procedure TForm1.FormCreate(Sender: TObject);
var i: integer;
begin
 key_right:=0;
 key_left:=0;


//Create Player
pl := objPlayer.Create(32,32);
max_tiles := 8;
SetLength(solid_array, max_tiles);
for i:=1 to max_tiles do
begin
solid_array[i]:=SolidObject.Create(32*i,128,32,32,'solid_obj.bmp');

//solid_array[0]:=SolidObject.Create(0,96,32,32,'solid_obj.bmp');

//solid_array[8]:=SolidObject.Create(32*30,96,32,32,'solid_obj.bmp');
end;

//Create Cam
cam := Camera.Create(0,0);



end;

constructor Camera.Create(cam_x:integer;cam_y:integer);
begin
offset_x := cam_x;
offset_y := cam_y;
end;

constructor Obj.Create(_x:real; _y:real; _width:integer; _height:integer; _image: string);
begin
    x := _x;
    y := _y;
    w := _width;
    h := _height;
    image := TBitmap.Create;
    image.LoadFromFile(_image);
end;

procedure Obj.Draw();
begin
      Form1.image2.Canvas.Draw(trunc(x)-cam.offset_x,trunc(y)-cam.offset_y,image);
end;


procedure TForm1.Update(Sender: TObject);
var i: integer;
begin
FPS := FPS+1;

pl.Update();
cam.offset_x := trunc(pl.x)-160;
cam.offset_y := trunc(pl.y)-120;
image2.Canvas.Rectangle(0,0,image2.Width+1,image2.Height+1);
pl.PlayerAnimation();
 for i:= 0 to max_tiles do
     solid_array[i].Draw();

end;



procedure TForm1.Timer2Timer(Sender: TObject);
begin
label1.Caption:=IntToStr(FPS);
FPS:=0;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
  if (Key=VK_RIGHT) then key_right:=1;
  if (Key= VK_LEFT)  then key_left:=1;
  if (Key= Ord('A'))  then key_action:=1;
  if (Key= Ord('F')) then begin


end;
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key=VK_RIGHT) then key_right:=0;
  if (Key= VK_LEFT) then key_left:=0;
  if (Key= Ord('A'))  then key_action:=0;
end;

procedure TForm1.Image1Click(Sender: TObject);
begin

end;

procedure TForm1.Image2Click(Sender: TObject);
begin

end;

procedure TForm1.Label1Click(Sender: TObject);
begin

end;

end.


<div align="center">
  <p align="center">
    <h1 align="center" style="color:red;">Pascal-Sonic</h1>
    <img src="https://github.com/GalaxyShad/Pascal-Sonic/assets/52833080/6578f9fa-2e03-4a21-9d76-a1b6f31293d1" /><br/>
    Sonic game made using Object Pascal programming language and RayLib.
  </p>
</div>

## How to run?
You can download a pre-built version of the game from the [Releases Section](https://github.com/GalaxyShad/Pascal-Sonic/releases). Alternatively, you can build it yourself by following the instructions below.

## How to build?
### Lazarus IDE
1. Clone this repository:
   ```
   git clone https://github.com/GalaxyShad/Pascal-Sonic.git
   ```
3. Download the runtime libraries from [RayLib](https://www.raylib.com/) and place them in the root directory of the project.
4. Install [Lazarus IDE](https://www.lazarus-ide.org/).
5. Open the project in Lazarus IDE and build it.

### FPC
```
fpc -MOBJFPC game.lpr -Fu"ray4laz/source"
```

## Dependencies
* [RayLib](https://www.raylib.com/)
* [Ray4Laz](https://github.com/GuvaCode/Ray4Laz)

## Features
* 360-degree movement
* Image-based collisions (a pixel with `alpha == 0x00` is considered empty)
* High-speed movement
* Jumping
* Sound effects
* Spindash

## Controls
* ***Arrow keys*** - movement
* ***Z key*** - jump/charge spindash
* ***D key*** - enable/disable drawing of collision masks

## How to create your own levels
You can create your own levels by editing the `textures/big-lvl.png` file. Remember, a pixel is considered collideable if its alpha value is 0.

## Why not use a higher-level programming language?
Cuz challenge 😎

## License
Sonic The Hedgehog is a trademark of SEGA. Please do not use any images containing Sonic for commercial purposes. 
The source code is released under the [MIT license](https://github.com/GalaxyShad/Pascal-Sonic/blob/main/LICENSE).

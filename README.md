# GoldSrc Character Controller

A mostly-faithful port of the movement from GoldSrc games like Half-Life and Counter-Strike 1.6 to Godot.

## Attribution

### Trace class, `_cast_trace()` function, and `_move_step()` function
- [Q_Move](https://github.com/Btan2/Q_Move) by [Btan2](https://github.com/Btan2)
- [Godot-Math-Lib](https://github.com/sinewavey/Godot-Math-Lib) by [sinewave](https://github.com/sinewavey)

## Installation

1. Open your Godot project.
2. Copy the "addons" folder from this repository into the project folder for your Godot project.
3. Enable "GoldSrc Character Controller" in your project's addon page.
4. Reload your project.
5. Drop the "Player" scene into whatever other scenes you need it in.

## Setup

### Foreword

I ***heavily*** recommend using [Godot Jolt](https://github.com/godot-jolt/godot-jolt) for the physics engine, but this add-on should still work with the default Godot Physics if you so choose.

### Input Map

GoldGdt has pre-defined inputs that it is programmed around. Unless you want to go into the code and change them to your own input mappings, I recommend recreating these inputs in your Project Settings, binding them to whatever you see fit.

![image](https://github.com/user-attachments/assets/c85a2cbd-5c2c-42b1-a5af-252cc4cb41a6)

### Entity Config

All bundled components require a reference to an Entity Config resource, which contains things like speed, acceleration, etc...

You can create a new Entity Config resource by right clicking in your FileSystem, opening up the Create New Resource window, and creating a new Entity Config resource.

Everything is self explanatory, but anything categorized as "Engine Dependant" *must* be in meters. If you want to convert speed from GoldSrc to Godot, remember that GoldSrc roughly measures units in inches.

![image](https://github.com/user-attachments/assets/51d9a6e7-1649-4d63-bfc1-b83822108ee6)

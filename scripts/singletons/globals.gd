extends Node
# Globals
# This script contains global variables and functions that are used in multiple scripts.

# Layers
const LAYERS = {
  "BACKGROUND": 1,
  "ROOMS": 2,
  "FLOORS": 3,
  "PLAYER": 4,
  "PROJECTILE": 5,
  "HOOK": 6,
  "FIRE": 7,
  "UI": 8
}

const FLOOR_DIRECTORY = "res://assets/entities/rooms/floors"
const WALL_DIRECTORY = "res://assets/sprites/rooms/walls/"
const PROJECTILE_DIRECTORY = "res://assets/entities/projectiles/"

const SCROLL_SPEED = 100
const SFX_MIN_OBJECT_DISTANCE = 100

# Scrolling
# false = Camera is not scrolling
# true = Camera is scrolling
var scroll_threshold = false

## # Game State;
## 0 = Menu state;
## 1 = Game state;
## 2 = Game over state;
## 3 = Paused state;
var game_state = 0

## Hook State;
## 0 = Hook is not thrown;
## 1 = Hook is thrown;
## 2 = Hook is attached;
## 3 = Hook is retracted;
var hook_state = 0

# Room Count
# The number of rooms to initially generate
var room_count = 7

var dim_main_theme = false
var save_data = str_to_var(var_to_str(SaveData.read()))

# Random Number Generator
var rng = RandomNumberGenerator.new()

# Speed Multiplier
var speed_multiplier = 1.0
var speed_increment = 0.01

var score: int = 0

func reset_all_state():
  # Reset global properties
  hook_state = 0
  game_state = 0
  scroll_threshold = false

  # Reset player properties
  PlayerProperties.life_points = 3
  PlayerProperties.immortality_state = false
extends Node
# Globals
# This script contains global variables and functions that are used in multiple scripts.

# Layers
const LAYERS = {
  "BACKGROUND": 1,
  "ROOMS": 2,
  "PLAYER": 3,
  "HOOK": 4,
  "UI": 5
}

# Game State
# 0 = Menu state
# 1 = Game state
# 2 = Game over state
# 3 = Paused state
var game_state = 0

# Hook State
# 0 = Hook is not thrown
# 1 = Hook is thrown
# 2 = Hook is attached
# 3 = Hook is retracted
var hook_state = 0

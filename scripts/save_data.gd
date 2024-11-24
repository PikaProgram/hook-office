extends Node

var music_volume = 1
var sfx_volume = 1
var high_score = 0

const DEFAULT_DATA = { "volume": { "music": 1, "sfx": 1 }, "high_score": 0 }
const DATA_PATH = "user://config.dat"

## Read existing config file.
## Returns DEFAULT_DATA if file is corrupt
func read() -> Dictionary:
  # Open file with read-only access
  var file = FileAccess.open(DATA_PATH, FileAccess.READ)
  
  # File doesn't exists
  if file == null:
    print_debug("Userdata not found! Returning default value")
    write_to_file(JSON.stringify(DEFAULT_DATA))
    return DEFAULT_DATA

  # Get file content
  var content = file.get_var()
  file.close()

  # File exist, but it's empty
  if content == null:
    print_debug("Empty userdata! Returning default value")
    write_to_file(JSON.stringify(DEFAULT_DATA))
    return DEFAULT_DATA

  # Parse config file
  var json = JSON.new()
  var err = json.parse(content)

  # Parse error
  if err != OK:
    printerr("Failed to read user data! Returning default value")
    write_to_file(JSON.stringify(DEFAULT_DATA))
    return DEFAULT_DATA

  return json.data

## Write config with filtering first
func write(new_data: Dictionary):
  # Use str2var and var2str to clone the Dictionary
  var dict: Dictionary = str_to_var(var_to_str(read()))

  # Get new value if exists
  var new_vol = new_data.get("volume", null)
  var new_hi = new_data.get("high_score", null)

  # Volume value should be Dictionary
  if typeof(new_vol) == TYPE_DICTIONARY:
    var music_vol = new_vol.get("music", null)
    var sfx_vol = new_vol.get("sfx", null)

    # Set new value if exists
    dict.volume.music = music_vol if typeof(music_vol) == TYPE_FLOAT else dict.volume.music
    dict.volume.sfx = sfx_vol if typeof(sfx_vol) == TYPE_FLOAT else dict.volume.sfx
  
  # Also same for the high score value
  if typeof(new_hi) == TYPE_INT:
    dict.high_score = new_hi

  # Stringify and write into file
  var stringified = JSON.stringify(dict)
  write_to_file(stringified)

  # Update save_data at Globals
  Globals.save_data = str_to_var(var_to_str(read()))

## Write config into DATA_PATH
func write_to_file(value: String):
  # Open file with write access
  var file = FileAccess.open(DATA_PATH, FileAccess.WRITE)
  file.store_var(value)
  file.close()

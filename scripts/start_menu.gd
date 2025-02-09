extends Control

@onready var bgm: AudioStreamPlayer = $StartMenuBGM

@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")

func _ready() -> void:
  # Set paused into false every time the game enter start menu
  get_tree().paused = false

  # Set audio volumes based on saved config file
  AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(Globals.save_data.volume.music))
  AudioServer.set_bus_mute(MUSIC_BUS_ID, Globals.save_data.volume.music < .05)
  AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(Globals.save_data.volume.sfx))
  AudioServer.set_bus_mute(MUSIC_BUS_ID, Globals.save_data.volume.music < .05)
  bgm.play()

func _on_exit_button_pressed() -> void:
  get_tree().quit()


func _on_start_area_button_pressed() -> void:
  # Fade out and fade in transition
  TransitionScreen.transition()
  await TransitionScreen.on_transition_finished

		# Menu state
  Globals.game_state = 1 # Change to game state
  
  get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_err_pressed() -> void:
  print_debug(SaveData.read())


func _on_sigma_pressed() -> void:
  var new_data = { "volume": { "music": 0.5 } }
  SaveData.write(new_data)

extends Control

@onready var pause_menu: Control = $"../PauseMenu"
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")


func _on_cancel_area_pressed() -> void:
  print_debug("Cancel area pressed")
  visible = false
  pause_menu.visible = true

func _on_sfx_slider_value_changed(value: float) -> void:
  AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(value))
  AudioServer.set_bus_mute(SFX_BUS_ID, value < .05)

func _on_music_slider_value_changed(value: float) -> void:
  AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(value))
  AudioServer.set_bus_mute(MUSIC_BUS_ID, value < .05)

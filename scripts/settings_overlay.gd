extends Control

@onready var pause_menu: Control = $"../PauseMenu"
@onready var music_slider: HSlider = $VolumePanel/VerticalContainer/MusicControl/MusicSlider
@onready var sfx_slider: HSlider = $VolumePanel/VerticalContainer/SFXControl/SFXSlider
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")

func _ready() -> void:
  music_slider.value = Globals.save_data.volume.music
  sfx_slider.value = Globals.save_data.volume.sfx

func _on_cancel_area_pressed() -> void:
  visible = false
  pause_menu.visible = true
  SaveData.write({ "volume": { "music": music_slider.value, "sfx": sfx_slider.value } })

func _on_sfx_slider_value_changed(value: float) -> void:
  AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(value))
  AudioServer.set_bus_mute(SFX_BUS_ID, value < .05)

func _on_music_slider_value_changed(value: float) -> void:
  AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(value))
  AudioServer.set_bus_mute(MUSIC_BUS_ID, value < .05)

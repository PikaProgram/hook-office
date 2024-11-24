extends Control

@onready var bgm: AudioStreamPlayer = $StartMenuBGM
@onready var button_click_bgm: AudioStreamPlayer = $ButtonClickBGM

func _ready() -> void:
  bgm.play()

func _on_exit_button_pressed() -> void:
  get_tree().quit()


func _on_start_area_button_pressed() -> void:
  # Play button pressed SFX
  button_click_bgm.play()
  
  Globals.game_started = true # Obselete!
  
  # Fade out and fade in transition
  TransitionScreen.transition()
  await TransitionScreen.on_transition_finished
  
  get_tree().change_scene_to_file("res://scenes/game.tscn")

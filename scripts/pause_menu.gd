extends Control

@onready var settings_overlay: Control = $"../SettingsOverlay"

var button_pressed = preload("res://assets/audio/sfx/button_press.wav")

func resume() -> void:
  get_tree().paused = false
  visible = false
  Globals.game_state = 1


func play_sfx() -> void:
  UninterruptibleSFX.start(button_pressed)


func _on_resume_button_pressed() -> void:
  play_sfx()
  resume()


func _on_cancel_area_pressed() -> void:
  resume()


func _on_restart_button_pressed() -> void:
  play_sfx()

  # Reset all state
  Globals.reset_all_state()
  get_tree().paused = false
  get_tree().reload_current_scene()


func _on_back_button_pressed() -> void:
  play_sfx()
  
  # Reset all state
  Globals.reset_all_state()
  
  # Fade out and in ahh transition
  TransitionScreen.transition()
  await TransitionScreen.on_transition_finished
  
  get_tree().change_scene_to_file("res://scenes/start_menu.tscn")
  visible = false


func _on_settings_button_pressed() -> void:
  play_sfx()

  # Hide pause menu and show settings overlay
  visible = false
  settings_overlay.visible = true


func _on_visibility_changed() -> void:
  Globals.dim_main_theme = visible

  if visible:
    UninterruptibleSFX.start(button_pressed)

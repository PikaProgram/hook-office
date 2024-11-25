extends Control


func _on_exit_button_pressed() -> void:
  get_tree().quit()


func _on_start_area_button_pressed() -> void:
  TransitionScreen.transition()
  await TransitionScreen.on_transition_finished
  get_tree().change_scene_to_file("res://scenes/game.tscn")
  print_debug("GAME START!")

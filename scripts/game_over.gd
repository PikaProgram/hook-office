extends Control

@onready var sfx_controller = $SFX
@onready var score_label = $MenuContainer/ScoreBoard/ScoreLabel
@onready var score_board = $MenuContainer/ScoreBoard

# SFX preloads
const BUTTON_PRESSED_SFX = preload("res://assets/audio/sfx/button_press.wav")
const GAME_OVER_SFX = preload("res://assets/audio/sfx/game_over.mp3")
const HIGH_SCORE_SFX = preload("res://assets/audio/sfx/high_score.wav")

# Board sprites preloads
const HIGHSCORE_BOARD = preload("res://assets/sprites/ui/gameover/highscore_board.png")
const SCORE_BOARD = preload("res://assets/sprites/ui/gameover/score_board.png")

func _on_visibility_changed() -> void:
  if visible:
    var high_score: int = Globals.save_data.high_score
    var current_score = Globals.score
    score_label.text = var_to_str(current_score)

    if current_score > high_score:
      sfx_controller.stream = HIGH_SCORE_SFX

      score_board.texture = HIGHSCORE_BOARD
      SaveData.write({ "high_score": current_score })

      sfx_controller.play()
      await sfx_controller.finished
    else:
      sfx_controller.stream = GAME_OVER_SFX

      score_board.texture = SCORE_BOARD

      sfx_controller.play()
      await sfx_controller.finished


func _on_restart_pressed() -> void:
  # Reset all state
  visible = false
  Globals.reset_all_state()

  # Reload the scene
  get_tree().paused = false
  get_tree().reload_current_scene()


func _on_menu_pressed() -> void:
  UninterruptibleSFX.start(BUTTON_PRESSED_SFX)

  # Reset all state
  Globals.reset_all_state()

  # Fade out and in ahh transition
  TransitionScreen.transition()
  await TransitionScreen.on_transition_finished
  
  # Change scene
  get_tree().change_scene_to_file("res://scenes/start_menu.tscn")
  visible = false

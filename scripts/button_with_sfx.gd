extends Button

@export var play_sfx: bool = true

@onready var sfx = $ButtonPressedSFX

func _ready() -> void:
  pass

func _on_pressed() -> void:
  if play_sfx:
    sfx.play()

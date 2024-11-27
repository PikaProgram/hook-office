extends RigidBody2D

@onready var player: CharacterBody2D = $"../../Player"
@onready var sfx_controller: AudioStreamPlayer = $Sprite/SFX

var already_played = false

func _process(_delta: float) -> void:
  var distance = player.position - position

  if distance.y > Globals.SFX_MIN_OBJECT_DISTANCE:
    if !already_played and !sfx_controller.playing:
      print_debug("SOUND PLAY! START!")
      sfx_controller.play()

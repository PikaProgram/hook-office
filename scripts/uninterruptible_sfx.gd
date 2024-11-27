extends AudioStreamPlayer

@export var seek_at: float = 0.0

# export var halo = ""

func _ready() -> void:
  seek(seek_at)


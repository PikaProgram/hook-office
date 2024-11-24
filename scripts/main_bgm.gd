extends AudioStreamPlayer

const FADE_TIME: float = 0.5 # In second
const BASE_VOLUME: float = 0
const DIM_VOLUME: float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  volume_db = BASE_VOLUME
  seek(0)
  play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  if Globals.dim_main_theme:
    if volume_db > (BASE_VOLUME - DIM_VOLUME):
      var decrease = delta * (DIM_VOLUME / FADE_TIME)
      volume_db -= decrease
  elif Globals.game_state == 2:
    stop()
    seek(0)
  elif !Globals.dim_main_theme:
    if volume_db < BASE_VOLUME:
      var increase = delta * (DIM_VOLUME / FADE_TIME)
      volume_db += increase

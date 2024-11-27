extends CharacterBody2D

@onready var rope: Line2D = $"../Rope"
@onready var player: CharacterBody2D = $"../Player"
@onready var launch_sfx: AudioStreamPlayer = $LaunchSFX
@onready var travelling_sfx: AudioStreamPlayer = $TravellingSFX
@onready var hit_sfx: AudioStreamPlayer = $HitSFX

## Audio State;
## 0 = No SFX;
## 1 = Launch SFX;
## 2 = Travelling SFX;
## 3 = Hit SFX;
var audio_state = 0

const HOOK_SPEED = 2000.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  add_collision_exception_with(player)
  slide_on_ceiling = false
  visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
  if Globals.hook_state == 0:
    if Input.is_action_just_pressed("left_click"):
      print("Hook thrown")
  
  elif Globals.hook_state == 1:
    if audio_state == 0:
      audio_state = 1
    velocity = (get_global_mouse_position() - player.position).normalized() * HOOK_SPEED
    rotation = -velocity.angle_to(Vector2.UP)
  
  elif Globals.hook_state == 2:
    if audio_state == 1 or audio_state == 2:
      audio_state = 3
    velocity = Vector2.ZERO
  
  elif Globals.hook_state == 3:
    velocity = (player.position - position).normalized() * HOOK_SPEED * 3

  # Hook just launched
  if audio_state == 1:
    if !launch_sfx.playing:
      launch_sfx.play()
      audio_state = 2

  # Hook travelling
  elif audio_state == 2:
    if !travelling_sfx.playing:
      travelling_sfx.play()

  # Hook attached
  elif audio_state == 3:
    # Stop travelling sfx if playing
    if travelling_sfx.playing:
      travelling_sfx.stop()

    hit_sfx.play()
    audio_state = 0

  move_and_slide()

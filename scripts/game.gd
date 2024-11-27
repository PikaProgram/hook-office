extends Node2D
# Game.gd - Main game logic controller script that manages hook, player and rope interactions

# Node references initialized when scene loads
@onready var hook: CharacterBody2D = $Hook
@onready var player: CharacterBody2D = $Player
@onready var player_hit_sfx: AudioStreamPlayer = $Player/HitSFX
@onready var rope: Line2D = $Rope
@onready var camera: Camera2D = $Camera
@onready var floor_border: CollisionShape2D = $"World Borders/Bottom"
@onready var top_control: Control = $TopControl
@onready var pause_menu: Control = $PauseMenu
@onready var settings_overlay: Control = $SettingsOverlay
@onready var score_label: Label = $TopControl/ScoreLabel
@onready var projectile_spawner: Node2D = $ProjectileSpawner
@onready var fire_node: Node2D = $Fire
@onready var bottom: CollisionShape2D = $"World Borders/Bottom"
@onready var player_sprite: AnimatedSprite2D = player.get_child(0)
@onready var game_over: Control = $GameOver

var rooms: Array = []
var room_size = 8
var floors: Array[PackedScene] = [] # List of floors available in the game
var walls: Array[CompressedTexture2D] = [] # List of walls available in the game
var windows_size = DisplayServer.window_get_size()

# Initialize game state when scene loads
func _ready() -> void:
  hook.z_index = Globals.LAYERS["HOOK"]  # Set hook to hook layer
  player.z_index = Globals.LAYERS["PLAYER"]  # Set player to player layer
  fire_node.z_index = Globals.LAYERS["FIRE"]  # Set fire to fire layer

  hook.visible = false
  rope.visible = false 
  fire_node.visible = false

# Main game loop - handles physics and state changes
func _physics_process(delta: float) -> void:
  score_label.text = var_to_str(Globals.score)

  if Globals.game_state == 0:
    top_control.visible = true
    player.position = Vector2(0, -100)
    Globals.game_state = 1
  elif Globals.game_state == 1:
    rope.set_point_position(0, hook.position)
    rope.set_point_position(1, player.position)

    # Scroll the camera if player is close to the top of the screen
    if !Globals.scroll_threshold:
      if player.position.y <= -float(windows_size.y) / 2.0:
        Globals.scroll_threshold = true
        fire_node.visible = true
        for fire: AnimatedSprite2D in fire_node.get_children():
          fire.play("default")
    else:
      var scroll_distance = -Globals.SCROLL_SPEED * Globals.speed_multiplier * delta
      Globals.speed_multiplier += Globals.speed_increment * (windows_size.y / 2.0 + camera.offset.y) / 10000.0  * delta 
      Globals.score += abs(floor(scroll_distance/100))
      camera.offset.y += scroll_distance
      top_control.position.y += scroll_distance
      fire_node.position.y += scroll_distance

    # If the player has fallen off the screen, give a boost
    if player.position.y > windows_size.y / 2.0 + camera.offset.y:
      print("PlayerFallOff")
      player.position.x = 0
      player.position.y = camera.offset.y
      player.velocity = Vector2.UP * PlayerProperties.jump_force
      PlayerProperties.immortality_state = true
      PlayerProperties.life_points -= 1

    if PlayerProperties.life_points <= 0:
      Globals.hook_state = 0
      Globals.game_state = 2

    # Check player collision with projectiles
    for projectile: RigidBody2D in projectile_spawner.get_children():
      var distance = (player.position - projectile.position).normalized()

      if distance.y < Globals.SFX_MIN_OBJECT_DISTANCE:
        pass

      if projectile.get_colliding_bodies().size() > 0:
        for body in projectile.get_colliding_bodies():
          if body == player:
            print_debug("PlayerProjectileHit")
            PlayerProperties.immortality_state = true
            PlayerProperties.life_points -= 1

    if Input.is_key_pressed(KEY_SPACE) and (Globals.hook_state > 0 and Globals.hook_state < 3):
      Globals.hook_state = 0

    # State 0: Hook is ready to be thrown
    if Globals.hook_state == 0:

      hook.visible = false
      rope.visible = false

      # On left click, throw the hook
      if Input.is_action_just_pressed("left_click") and get_global_mouse_position().y > top_control.position.y + top_control.size.y:
        print_debug("HookThrown")
        Globals.hook_state = 1 # Change to throwing state

        # Make hook and rope visible
        hook.visible = true
        rope.visible = true

        # Start hook at player's position
        hook.position = player.position

    # State 1: Hook is flying through air
    elif Globals.hook_state == 1:
      if hook.get_slide_collision_count() > 0:
        print_debug("HookHit")
        Globals.hook_state = 2

    # State 2: Hook is attached, player is swinging
    elif Globals.hook_state == 2:
      # If player hits something, reset hook state
      if player.get_slide_collision_count() > 0 and (player.position.distance_to(hook.position) < 50 or player.velocity.abs() > Vector2.ONE):
          print_debug("PlayerHit")
          Globals.hook_state = 0
  
    # State 3: Hook bounced off
    elif Globals.hook_state == 3:
      if hook.position.distance_to(player.position) < 50:
        print_debug("HookRetracted")
        Globals.hook_state = 0

  elif Globals.game_state == 2:
    # Game over state
    
    # Set game over position to top control position
    game_over.position.y = top_control.position.y
    game_over.visible = true

    # Pause the game
    get_tree().paused = true

  elif Globals.game_state == 3:
    # Paused state
    
    # Set pause menu position to top control position
    pause_menu.position.y = top_control.position.y
    pause_menu.visible = true

    # Set settings overlay position to top control position
    settings_overlay.position.y = top_control.position.y
    settings_overlay.visible = false
    
    # Set game state to paused
    get_tree().paused = true

func _on_button_with_sfx_pressed() -> void:
  Globals.game_state = 3

func player_hit_sound() -> void:
  if !player_hit_sfx.playing:
    player_hit_sfx.play()

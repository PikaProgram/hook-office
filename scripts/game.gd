extends Node2D
# Game.gd - Main game logic controller script that manages hook, player and rope interactions

# Node references initialized when scene loads
@onready var hook: CharacterBody2D = $Hook
@onready var player: CharacterBody2D = $Player  
@onready var rope: Line2D = $Rope
@onready var camera: Camera2D = $Camera
@onready var floor_border: CollisionShape2D = $"World Borders/Bottom"

var rooms: Array = []
var room_size = 8
var rng = RandomNumberGenerator.new()
var floors: Array[PackedScene] = []  # List of floors available in the game
var walls: Array[CompressedTexture2D] = []  # List of walls available in the game

# Initialize game state when scene loads
func _ready() -> void:
	hook.z_index = Globals.LAYERS["HOOK"]  # Set hook to hook layer
	player.z_index = Globals.LAYERS["PLAYER"]  # Set player to player layer
	
	player.visible = false
	hook.visible = false
	rope.visible = false 

# Main game loop - handles physics and state changes
func _physics_process(delta: float) -> void:
	if Globals.game_state == 0:
		# Menu state
		if Input.is_action_just_pressed("left_click"):
			Globals.game_state = 1  # Change to game state
			player.visible = true
			player.position = Vector2(0, 200)
			player.velocity = Vector2(0, PlayerProperties.jump_force)

	elif Globals.game_state == 1:
		rope.set_point_position(0, hook.position)
		rope.set_point_position(1, player.position)

		# Scroll the camera if player is close to the top of the screen
		if !Globals.scroll_threshold:
			if player.position.y <= -float(DisplayServer.screen_get_size().y) / 2.0:
				Globals.scroll_threshold = true
		else:
			var scroll_distance = min(Globals.SCROLL_SPEED * (floor(camera.offset.y / 10000) + 1), -Globals.SCROLL_SPEED) * delta
			camera.offset.y += scroll_distance
			floor_border.position.y += scroll_distance


		# State 0: Hook is ready to be thrown
		if Globals.hook_state == 0:
			hook.visible = false
			rope.visible = false

			# On left click, throw the hook
			if Input.is_action_just_pressed("left_click"):
				print_debug("Hook Thrown")
				Globals.hook_state = 1  # Change to throwing state
				
				# Make hook and rope visible
				hook.visible = true
				rope.visible = true
				
				# Start hook at player's position
				hook.position = player.position

		# State 1: Hook is flying through air
		elif Globals.hook_state == 1:
			# If hook hits something, change to hooked state
			if Input.is_key_pressed(KEY_SPACE):	
				print_debug("Hook Bounced")
				Globals.hook_state = 3
			else:
				if hook.get_slide_collision_count() > 0:
					print_debug("Hook Hit")
					Globals.hook_state = 2

		# State 2: Hook is attached, player is swinging
		elif Globals.hook_state == 2:
			# If player hits something, reset hook state
			if player.get_slide_collision_count() > 0 and (!player.is_on_floor() or !player.is_on_ceiling_only()):
				print_debug("Player Hit")
				Globals.hook_state = 0

		# State 3: Hook bounced off
		elif Globals.hook_state == 3:
			if hook.position.distance_to(player.position) < 50:
				print_debug("Hook Retracted")
				Globals.hook_state = 0
			# if hook.get_last_slide_collision():
			# 	if hook.get_last_slide_collision().get_collider().name == player.name:
			# Globals.hook_state = 0

	elif Globals.game_state == 2:
		# Game over state
		pass
	elif Globals.game_state == 3:
		# Paused state
		pass

extends Node2D
# Game.gd - Main game logic controller script that manages hook, player and rope interactions

# Node references initialized when scene loads
@onready var hook: CharacterBody2D = $Hook
@onready var player: CharacterBody2D = $Player  
@onready var rope: Line2D = $Rope

# Game state variables
var player_is_hooked = false  # Tracks if player is currently hooked
var click_position = Vector2()  # Stores mouse click position
var angle_of_attack = 0.0  # Stores hook's angle of attack

# Initialize game state when scene loads
func _ready() -> void:
	# Set initial upward velocity for player jump
	player.velocity = Vector2(0, PlayerProperties.jump_force)
	# Hide hook and rope initially
	hook.visible = false
	rope.visible = false 

# Main game loop - handles physics and state changes
func _physics_process(_delta: float) -> void:
	# State 0: Hook is ready to be thrown
	if Globals.hook_state == 0:
		hook.visible = false
		rope.visible = false

		# On left click, throw the hook
		if Input.is_action_just_pressed("left_click"):
			print("Hook Thrown")
			Globals.hook_state = 1  # Change to throwing state
			
			# Make hook and rope visible
			hook.visible = true
			rope.visible = true
			
			# Start hook at player's position
			hook.position = player.position

	# State 1: Hook is flying through air
	elif Globals.hook_state == 1:
		# Update rope endpoints to connect hook and player
		rope.set_point_position(0, hook.position)
		rope.set_point_position(1, player.position)
		
		# If hook hits something, change to hooked state
		if hook.get_slide_collision_count() > 0:
			Globals.hook_state = 2

	# State 2: Hook is attached, player is swinging
	elif Globals.hook_state == 2:
		# Keep rope connected to player
		rope.set_point_position(1, player.position)
		# If player hits something, reset hook state
		if player.get_slide_collision_count() > 0:
			Globals.hook_state = 0

	# State 3: Reserved for future use
	elif Globals.hook_state == 3:
		pass

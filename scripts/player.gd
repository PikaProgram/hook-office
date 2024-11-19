# player.gd
# This script handles the player's movement and interaction with the hook and rope.
extends CharacterBody2D

# Godot Imports
@onready var left_border: CollisionShape2D = $"../World Borders/Left"
@onready var right_border: CollisionShape2D = $"../World Borders/Right"
@onready var player_collision_box: CollisionShape2D = $CollisionShape2D
@onready var player: CharacterBody2D = $"."
@onready var hook: Sprite2D = $"../Hook"
@onready var rope: Line2D = $"../Rope"

# Constants
const SPEED = 700.0
const HOOK_SPEED = -100
const RELEASE_DISTANCE = 10

# Variables
var player_is_hooked = false
var target_position = Vector2()
var click_position = Vector2()
var hook_position = Vector2()
var last_position = Vector2()
var angle_of_attack = 0.0

# Called when the node is added to the scene.
func _ready() -> void:
	velocity.y = -500

# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	rope.set_point_position(0, position)
	rope.set_point_position(1, click_position)

	if player_is_hooked:
		# If the hook or rope is not visible, update their positions and make them visible
		if not hook.visible or not rope.visible:

			hook.position = click_position
			hook.visible = true
			rope.visible = true

	# Check if the player is on a wall
	if is_on_wall():
		print("Player Unhooked")
		player_is_hooked = false

	else:
		# Hide the hook and rope if they are visible
		if hook.visible or rope.visible:
			hook.visible = false
			rope.visible = false

		# Check if the left mouse button is just pressed
		if Input.is_action_just_pressed("left_click"):
			print("Player Hooked")

			last_position = position # Store the last position of the player
			click_position = get_global_mouse_position() # Get the global mouse position
			angle_of_attack = Vector2.UP.angle_to(click_position - position) # Get the angle of attack

			player_is_hooked = true # Set the player to be hooked
			velocity = (click_position - position).normalized() * SPEED # Set the player velocity to the direction of the hook
			print("Velocity: ", velocity)

		# Check if the player is not on the floor
		if not is_on_floor():
			# Apply gravity to the player
			velocity += get_gravity() * delta
		else:
			# If the player is on the floor, set the velocity to zero
			if velocity != Vector2.ZERO and not player_is_hooked:
				velocity = Vector2.ZERO

	move_and_slide()

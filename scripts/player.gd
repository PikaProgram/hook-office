# player.gd
# This script handles the player's movement and interaction with the hook and rope.
extends CharacterBody2D

# Godot Imports
@onready var player: CharacterBody2D = $"."
@onready var hook: CharacterBody2D = $"../Hook"

# Constants
const SPEED = 1000.0

# Variables
var player_is_hooked = false
var target_position = Vector2()
var last_position = Vector2()

# Called when the node is added to the scene.
func _ready() -> void:
	pass

# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Globals.hook_state == 0:
		pass

	elif Globals.hook_state == 1:
		pass

	elif Globals.hook_state == 2:
		velocity = (hook.position - position).normalized() * PlayerProperties.speed # Set the player velocity to the direction of the hook

	elif Globals.hook_state == 3:
		pass

	if Globals.hook_state != 2:
		if not is_on_floor():
			# Apply gravity to the player
			velocity += get_gravity() * delta
		else:
			velocity *= Vector2(.5, 1) # Apply friction to the player

	move_and_slide()

# player.gd
# This script handles the player's movement and interaction with the hook and rope.
extends CharacterBody2D

# Godot Imports
@onready var player: CharacterBody2D = $"."
@onready var hook: CharacterBody2D = $"../Hook"
@onready var projectile_spawner: Node2D = $"../ProjectileSpawner"
@onready var room_spawner: Node2D = $"../RoomSpawner"

# Variables
var target_position = Vector2()
var last_position = Vector2()
var immortality_time = PlayerProperties.immortality_time
# Called when the node is added to the scene.
func _ready() -> void:
	pass

# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if PlayerProperties.immortality_state:
		var projectiles = projectile_spawner.get_children()
		if immortality_time <= 0:
			print_debug("ImmortalityOver")
			print_debug(immortality_time)
			PlayerProperties.immortality_state = false
			modulate.a = 1
			immortality_time += PlayerProperties.immortality_time
			for projectile in projectiles:
				player.remove_collision_exception_with(projectile)
		else:
			modulate.a = 0.5
			print_debug("ImmortalityActive")
			for projectile in projectiles:
				player.add_collision_exception_with(projectile)
			immortality_time -= delta
	if Globals.hook_state == 0:
		pass

	elif Globals.hook_state == 1:
		pass

	elif Globals.hook_state == 2:
		if Input.is_anything_pressed():
			if Input.is_action_just_pressed("dash_up"):
				velocity = Vector2(0, -PlayerProperties.speed)
				Globals.hook_state = 3
			elif Input.is_action_just_pressed("dash_left"):
				velocity = Vector2(-PlayerProperties.speed, 0)
				Globals.hook_state = 3
			elif Input.is_action_just_pressed("dash_right"):
				velocity = Vector2(PlayerProperties.speed, 0)
				Globals.hook_state = 3
		else:
			velocity = (hook.position - position).normalized() * PlayerProperties.speed # Set the player velocity to the direction of the hook
	elif Globals.hook_state == 3:
		pass

	if Globals.hook_state != 2:
		if is_on_wall():
			velocity *= Vector2(1, .6) # Apply friction to the player
		if not is_on_floor():
			# Apply gravity to the player
			velocity += get_gravity() * delta
		else:
			velocity *= Vector2(.75, 1) # Apply friction to the player

	move_and_slide()

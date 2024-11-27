# player.gd
# This script handles the player's movement and interaction with the hook and rope.
extends CharacterBody2D

# Godot Imports
@onready var player: CharacterBody2D = $"."
@onready var hook: CharacterBody2D = $"../Hook"
@onready var projectile_spawner: Node2D = $"../ProjectileSpawner"
@onready var room_spawner: Node2D = $"../RoomSpawner"
@onready var dash_sfx_controller: AudioStreamPlayer = $DashSFX
@onready var grounded_sfx_controller: AudioStreamPlayer = $GroundedSFX
@onready var death_sfx_controller: AudioStreamPlayer = $DeathSFX
@onready var hurt_sfx_controller: AudioStreamPlayer = $HurtSFX
@onready var sprite: AnimatedSprite2D = get_child(0)

# Preloads
const SFX_HURT_1: AudioStreamMP3 = preload("res://assets/audio/sfx/players/hurt_01.mp3")
const SFX_HURT_2: AudioStreamMP3 = preload("res://assets/audio/sfx/players/hurt_02.mp3")
const SFX_HURT_3: AudioStreamMP3 = preload("res://assets/audio/sfx/players/hurt_03.mp3")

# Variables
var hurt_sound_sfxs = [[SFX_HURT_1, 0.89], [SFX_HURT_2, 0.86], [SFX_HURT_3, 1.24]] # List of [Audio stream, Seek position]
var target_position = Vector2()
var last_position = Vector2()
var immortality_time = PlayerProperties.immortality_time
var already_grounded_sfx = true
var already_hit_sfx = true

# Play dash sound
func dash_sound() -> void:
	if !dash_sfx_controller.playing:
		dash_sfx_controller.play(0)

# Play grounded sound
func grounded_sound() -> void:
	if !grounded_sfx_controller.playing and !already_grounded_sfx:
		grounded_sfx_controller.play(0.29)

# Play death sound
func death_sound() -> void:
	if !death_sfx_controller.playing:
		death_sfx_controller.play(1.6)

func hurt_sound() -> void:
	if !hurt_sfx_controller.playing and !already_hit_sfx:
		var randomized = hurt_sound_sfxs[Globals.rng.randi_range(0, 2)]
		hurt_sfx_controller.stream = randomized[0]
		hurt_sfx_controller.play(randomized[1])
		already_hit_sfx = true


# Called when the node is added to the scene.
func _ready() -> void:
	sprite.play("idle")

# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_on_floor():
		grounded_sound()
		already_grounded_sfx = true
	else:
		already_grounded_sfx = false

	if Globals.game_state == 2:
		death_sound()

	if PlayerProperties.immortality_state:
		hurt_sound()

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
			get_child(0).play("hit")
			print_debug("ImmortalityActive")
			for projectile in projectiles:
				player.add_collision_exception_with(projectile)
			immortality_time -= delta
	else:
		already_hit_sfx = false

	if Globals.hook_state == 0:
		sprite.play("idle_with_hook")
	elif Globals.hook_state == 1:
		sprite.play("shoot")

		if get_global_mouse_position().x > position.x:
			sprite.flip_h = false
		else:
			sprite.flip_h = true
	elif Globals.hook_state == 2:
		sprite.play("hooking")

		if Input.is_anything_pressed():
			if Input.is_action_just_pressed("dash_up"):
				dash_sound()
				velocity = Vector2(0, -PlayerProperties.speed)
				Globals.hook_state = 3
			elif Input.is_action_just_pressed("dash_left"):
				dash_sound()
				velocity = Vector2(-PlayerProperties.speed, 0)
				Globals.hook_state = 3
				sprite.flip_h = false
			elif Input.is_action_just_pressed("dash_right"):
				dash_sound()
				velocity = Vector2(PlayerProperties.speed, 0)
				Globals.hook_state = 3
				sprite.flip_h = true
		else:
			velocity = (hook.position - position).normalized() * PlayerProperties.speed # Set the player velocity to the direction of the hook
			sprite.flip_h = false if velocity.x > 0 else true
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

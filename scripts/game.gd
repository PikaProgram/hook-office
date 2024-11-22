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
	print_debug(camera.position)
	print_debug(camera.offset)


	var floor_directory = DirAccess.open(Globals.FLOOR_DIRECTORY)  # Open the floor directory

	if floor_directory:
		# Load all the available floors
		floor_directory.list_dir_begin()
		while true:
			var file = floor_directory.get_next()
			if file == "":
				break
			if file.ends_with(".tscn"):
				floors.append(load(Globals.FLOOR_DIRECTORY + "/" + file))
		floor_directory.list_dir_end()

	var wall_directory = DirAccess.open(Globals.WALL_DIRECTORY)  # Open the wall directory

	print(wall_directory)
	if wall_directory:
		# Load all the available walls
		wall_directory.list_dir_begin()
		while true:
			var file = wall_directory.get_next()
			if file == "":
				break
			if file.ends_with(".png"):
				walls.append(load(Globals.WALL_DIRECTORY + "/" + file))
		wall_directory.list_dir_end()

	hook.z_index = Globals.LAYERS["HOOK"]  # Set hook to hook layer
	player.z_index = Globals.LAYERS["PLAYER"]  # Set player to player layer
	
	player.visible = false
	hook.visible = false
	rope.visible = false 

	# Generate the game world
	for i in range(room_size):
		var room = generate_room(floors, walls, i)
		rooms.append([room[0], room[1]])

		add_child(room[0])
		add_child(room[1])

	print_debug(floors)
	print_debug(walls)

func _process(_delta: float) -> void:
	for arr in rooms:
		var floor_scene = arr[0]
		var wall_sprite = arr[1]

		# Check if each room is off the screen
		if floor_scene.position.y > DisplayServer.screen_get_size().y + camera.offset.y:
			remove_child(floor_scene)
			remove_child(wall_sprite)
			room_size += 1	
			rooms.pop_front()

			var room = generate_room(floors, walls, room_size - 1)
			add_child(room[0])
			add_child(room[1])
			rooms.append(room)


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

func generate_room(floor_array, wall_array, index) -> Array:	
		var floor_index	= rng.randi_range(0, floor_array.size() - 1)
		var wall_index = rng.randi_range(0, wall_array.size() - 1)

		var floor_scene = floor_array[floor_index].instantiate()
		var wall_texture = wall_array[wall_index]
		var wall = Sprite2D.new()

		if rng.randi_range(0, 1) == 0:
			floor_scene.scale = Vector2(-1, 1)

		floor_scene.position = Vector2(0, index * -200)
		wall.position = Vector2(0, floor_scene.position.y - 60)

		floor_scene.z_index = Globals.LAYERS["FLOORS"]
		wall.z_index = Globals.LAYERS["ROOMS"]

		floor_scene.scale *= .34
		wall.scale *= .35

		wall.texture = wall_texture

		return([floor_scene, wall])

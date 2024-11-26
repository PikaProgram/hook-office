extends Node2D

@onready var camera: Camera2D = $"../Camera"
@onready var projectile_spawner: Node2D = $"../ProjectileSpawner"

var rng = RandomNumberGenerator.new()

var floors = []
var walls = []
var rooms = []
var room_index = Globals.room_count

func _ready() -> void:
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

	for i in range(room_index + 1):
		var room = generate_room(floors, walls, i)
		rooms.append([room[0], room[1]])

		add_child(room[0])
		add_child(room[1])


func _process(_delta: float) -> void:
	if Globals.game_state == 1:
		for room in rooms:
			var floor_scene = room[0]
			var wall_sprite = room[1]

			if floor_scene.position.y > DisplayServer.screen_get_size().y + camera.offset.y:
				remove_child(floor_scene)
				remove_child(wall_sprite)
				room_index += 1	
				rooms.pop_front()

				var new_room = generate_room(floors, walls, room_index)
				add_child(new_room[0])
				add_child(new_room[1])
				rooms.append(new_room)


func generate_room(floor_array, wall_array, index: int) -> Array: 
	var floor_index = rng.randi_range(0, floor_array.size() - 1)
	var wall_index = rng.randi_range(0, wall_array.size() - 1)

	var floor_scene: StaticBody2D = floor_array[floor_index].instantiate()
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

	var projectiles = projectile_spawner.get_children()

	for projectile in projectiles:
		if projectile.get_class() == "RigidBody2D":
			projectile.add_collision_exception_with(floor_scene)

	return([floor_scene, wall])

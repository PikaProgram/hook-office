extends Node2D

@onready var camera: Camera2D = $"../Camera"
@onready var hook: CharacterBody2D = $"../Hook"
@onready var player: CharacterBody2D = $"../Player"
@onready var room_spawner: Node2D = $"../RoomSpawner"

const spawn_speed: float = 1.0 / 3.0
var spawns_quantity: float = 0.0

var rng = RandomNumberGenerator.new()

var projectiles = {
	"small": [],
	"medium": [],
	"large": []
}

func _ready() -> void:
	var projectile_directory = DirAccess.open(Globals.PROJECTILE_DIRECTORY) # Open the projectile directory

	if projectile_directory:
		# Load all the available projectiles
		projectile_directory.list_dir_begin()
		while true:
			var file = projectile_directory.get_next()
			if file == "":
				break
			if file.ends_with(".tscn"):
				if file.find("small") != -1:
					projectiles["small"].append(load(Globals.PROJECTILE_DIRECTORY + "/" + file))
				elif file.find("medium") != -1:
					projectiles["medium"].append(load(Globals.PROJECTILE_DIRECTORY + "/" + file))
				elif file.find("large") != -1:
					projectiles["large"].append(load(Globals.PROJECTILE_DIRECTORY + "/" + file))
		projectile_directory.list_dir_end()

func _physics_process(delta: float) -> void:
	if Globals.game_state == 1:
		spawns_quantity += spawn_speed * delta

		var projectile_nodes = get_children()
		
		for projectile: RigidBody2D in projectile_nodes:
			projectile.rotate(2 * PI * delta)

		if spawns_quantity > 1:
			spawns_quantity -= 1.0

			var projectile_types = ["small", "medium", "large"]
			var variance = (floor(camera.offset.y / 10000) + 1)
			var weights = [0.6 * (1 - variance), 0.3, 0.1 * variance]

			var projectile_type = projectile_types[rng.rand_weighted(weights)]

			var projectile = generate_projectile(
				projectile_type,
				Vector2(randf_range(-DisplayServer.screen_get_size().x / 2.0, DisplayServer.screen_get_size().x / 2.0), camera.offset.y - DisplayServer.screen_get_size().y)
				)
			add_child(projectile)

func generate_projectile(size: String, projectile_position: Vector2) -> Node:
	var projectile: RigidBody2D = projectiles[size][rng.randi_range(0, projectiles[size].size() - 1)].instantiate()
	projectile.position = projectile_position
	projectile.z_index = Globals.LAYERS["PROJECTILE"]
	projectile.gravity_scale = 0.1

	var children = projectile.get_children()

	for child in children:
		child.scale *= .5

	var rooms = room_spawner.get_children()

	for room in rooms:
		if room.get_class() == "StaticBody2D":
			projectile.add_collision_exception_with(room)

	projectile.add_collision_exception_with(hook)

	return projectile

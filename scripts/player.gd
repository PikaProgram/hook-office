extends CharacterBody2D

@onready var left_border: CollisionShape2D = $"../World Borders/Left"
@onready var right_border: CollisionShape2D = $"../World Borders/Right"
@onready var player_collision_box: CollisionShape2D = $CollisionShape2D
@onready var player: CharacterBody2D = $"."

const SPEED = 700.0
const HOOK_SPEED = -100
const RELEASE_DISTANCE = 10

var player_is_hooked = false
var target_position = Vector2() # The Position of the hook head
var click_position = Vector2()
var hook_position = Vector2()


func _ready() -> void:
	velocity.y = -500

func _physics_process(delta: float) -> void:

	if player_is_hooked:
		if is_on_wall():
			print("Player Unhooked")
			player_is_hooked = false

	else:
		if Input.is_action_just_pressed("left_click"):
			print("Player Hooked")
			click_position = get_global_mouse_position()
			player_is_hooked = true
			velocity = (click_position - position).normalized() * SPEED

		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta

	move_and_slide()

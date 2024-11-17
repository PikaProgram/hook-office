extends CharacterBody2D

@onready var left_border: CollisionShape2D = $"../World Borders/Left"
@onready var right_border: CollisionShape2D = $"../World Borders/Right"
@onready var player_collision_box: CollisionShape2D = $CollisionShape2D
@onready var player: CharacterBody2D = $"."
@onready var hook: Sprite2D = $"../Hook"
@onready var rope: Line2D = $"../Rope"

const SPEED = 700.0
const HOOK_SPEED = -100
const RELEASE_DISTANCE = 10

var player_is_hooked = false
var target_position = Vector2() # The Position of the hook head
var click_position = Vector2()
var hook_position = Vector2()
var last_position = Vector2()


func _ready() -> void:
	velocity.y = -500

func _physics_process(delta: float) -> void:
	rope.set_point_position(0, position)
	rope.set_point_position(1, click_position)

	if player_is_hooked:
		if not hook.visible or not rope.visible:
			hook.position = click_position
			hook.visible = true
			rope.visible = true

		var cursor_passed_y = position.y < click_position.y

		if last_position.y < click_position.y:
			cursor_passed_y = position.y > click_position.y

		if is_on_wall() or cursor_passed_y:
			print("Player Unhooked")
			player_is_hooked = false

	else:
		if hook.visible or rope.visible:
			hook.visible = false
			rope.visible = false

		if Input.is_action_just_pressed("left_click"):
			print("Player Hooked")

			last_position = position
			click_position = get_global_mouse_position()

			player_is_hooked = true
			velocity = (click_position - position).normalized() * SPEED
			print("Velocity: ", velocity)

		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
		else:
			# Actually useless
			# Make player not move when on floor
			if velocity != Vector2.ZERO and not player_is_hooked:
				velocity = Vector2.ZERO

	move_and_slide()

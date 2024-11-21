extends CharacterBody2D

@onready var rope: Line2D = $"../Rope"
@onready var player: CharacterBody2D = $"../Player"

const HOOK_SPEED = 2000.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_collision_exception_with(player)
	slide_on_ceiling = false
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if Globals.hook_state == 0:
		if Input.is_action_just_pressed("left_click"):
			print("Hook thrown")
	
	elif Globals.hook_state == 1:
		velocity = (get_global_mouse_position() - player.position).normalized() * HOOK_SPEED
	
	elif Globals.hook_state == 2:
		velocity = Vector2.ZERO
		
	
	elif Globals.hook_state == 3:
		velocity = velocity.rotated(deg_to_rad(180))

	move_and_slide()

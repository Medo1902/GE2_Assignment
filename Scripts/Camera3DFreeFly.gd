extends Camera3D

@export var mouse_sensitivity: float = 0.1
@export var move_speed: float = 5.0
@export var sprint_multiplier: float = 2.0  # Multiplier for sprinting

var velocity = Vector3.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_camera(event.relative)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	move_camera(delta)
	if Input.is_action_just_pressed("ui_cance"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED)

func rotate_camera(relative_motion):
	rotate_y(deg_to_rad(-relative_motion.x * mouse_sensitivity))
	rotate_x(deg_to_rad(-relative_motion.y * mouse_sensitivity))

	# Clamp the vertical rotation
	rotation_degrees.x = clamp(rotation_degrees.x, -90, 90)

func move_camera(delta):
	velocity = Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		velocity -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		velocity += transform.basis.z
	if Input.is_action_pressed("move_left"):
		velocity -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		velocity += transform.basis.x
	if Input.is_action_pressed("move_up"):
		velocity += transform.basis.y
	if Input.is_action_pressed("move_down"):
		velocity -= transform.basis.y

	if Input.is_action_pressed("sprint"):
		velocity *= sprint_multiplier

	if velocity != Vector3.ZERO:
		velocity = velocity.normalized() * move_speed
		translate(velocity * delta)

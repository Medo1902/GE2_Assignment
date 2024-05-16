extends Camera3D

@export var rotation_speed: float = 20.0
@export var move_speed: float = 5.0
@export var sprint_multiplier: float = 2.0  

var velocity = Vector3.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	move_camera(delta)
	rotate_camera(delta)

func rotate_camera(delta):
	if Input.is_action_pressed("ui_right"):
		rotate_y(deg_to_rad(-rotation_speed * delta))
	if Input.is_action_pressed("ui_left"):
		rotate_y(deg_to_rad(rotation_speed * delta))

	var new_x_rotation = rotation_degrees.x
	rotation_degrees.x = clamp(new_x_rotation, -90, 90)

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

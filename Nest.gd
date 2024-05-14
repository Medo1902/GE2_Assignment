extends Node3D

var branches_count = 0
var max_branches = 100
@export var brickScene:PackedScene

func _ready():
	set_process_input(true)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_F:
		add_random_branch()

func add_random_branch():
	if branches_count < max_branches:
		var branch = brickScene.instantiate()
		var random_pos = generate_random_position()
		branch.global_transform.origin = random_pos
		var direction = (random_pos - global_transform.origin).normalized()
		branch.look_at(random_pos + direction, Vector3.UP)
		add_child(branch)
		branches_count += 1
		print("Branch added. Total branches: ", branches_count)


func generate_random_position():
	var radius = randf_range(0.8, 1.2)  # Slightly vary the radius
	var theta = randf_range(0, 2 * PI)
	var height = pow(randf_range(-1, 1), 3) * 0.2  # Shape control for more realistic nest depth

	var x = radius * cos(theta)
	var y = height  # Lower variation in height to keep it flatter
	var z = radius * sin(theta)
	return global_transform.origin + Vector3(x, y, z)


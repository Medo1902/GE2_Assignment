extends Node3D

var branches_count = 0
var max_branches = 100
@export var brickScene:PackedScene

func _ready():
	pass  # No need to handle input in this script anymore

func add_branch_at_nest():
	if branches_count < max_branches:
		var branch = brickScene.instantiate()
		var random_pos = generate_random_position()
		branch.global_transform.origin = global_transform.origin + random_pos
		var direction = random_pos.normalized()
		branch.look_at(global_transform.origin + random_pos + direction, Vector3.UP)
		add_child(branch)
		branches_count += 1
		print("Branch added at nest. Total branches: ", branches_count)

func generate_random_position():
	var radius = randf_range(0.8, 1.2)  # Slightly vary the radius
	var theta = randf_range(0, 2 * PI)
	var height = pow(randf_range(-1, 1), 3) * 0.2  # Shape control for more realistic nest depth

	var x = radius * cos(theta)
	var y = height  # Lower variation in height to keep it flatter
	var z = radius * sin(theta)
	return Vector3(x, y, z)  # Return local position relative to Node3D's origin

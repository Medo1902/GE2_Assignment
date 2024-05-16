extends Node3D

@export var branch_scene: PackedScene
var branches: Array = []

func _ready():
	pass

func add_branch_at_nest():
	if branch_scene:
		var branch_instance = branch_scene.instantiate()
		add_child(branch_instance)
		branches.append(branch_instance)
		
		# Calculate a new position for the branch
		var new_position = calculate_branch_position(branches.size() - 1)
		branch_instance.global_transform.origin = new_position

func calculate_branch_position(index):
	var radius = 1.0  # Adjust the radius as needed
	var angle_increment = TAU / max(branches.size(), 1)
	var angle = angle_increment * index
	var x = radius * cos(angle)
	var z = radius * sin(angle)
	var y = 0.0  # Adjust the height as needed

	return global_transform.origin + Vector3(x, y, z)

extends Node3D

var branch_scene = preload("res://Scenes/branch.tscn")  # Update path as needed
var number_of_branches = 100
var spawn_area = Vector2(100, 100)  # Define the area size for branch spawning

func _ready():
	spawn_branches()

func spawn_branches():
	for i in range(number_of_branches):
		var branch_instance = branch_scene.instantiate()
		var random_position = Vector3(randf_range(-spawn_area.x/2, spawn_area.x/2), 0, randf_range(-spawn_area.y/2, spawn_area.y/2))
		branch_instance.global_transform.origin = random_position
		branch_instance.add_to_group("branch")  # Ensure this line is added
		add_child(branch_instance)


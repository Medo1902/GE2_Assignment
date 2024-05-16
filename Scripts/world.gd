extends Node3D

var branch_scene = preload("res://Scenes/branch.tscn")  
var number_of_branches = 100
var spawn_area = Vector2(100, 100)  

var cameras = []
var current_camera_index = 0

@export var camera_above_nest: Camera3D
@export var camera_following_bird: Camera3D
@export var camera_free_fly: Camera3D
@export var ui_scene: PackedScene
var bird: Node3D  

func _ready():
	spawn_branches()

	
	cameras.append(camera_above_nest)
	cameras.append(camera_following_bird)
	cameras.append(camera_free_fly)

	
	for camera in cameras:
		if not camera:
			print("One or more Camera3D nodes are not initialized correctly!")
			return

	
	activate_camera(current_camera_index)

	
	if not bird:
		bird = get_node("/root/World/Bird")  

	
	if ui_scene:
		var ui_instance = ui_scene.instantiate()
		add_child(ui_instance)

func _process(delta):
	# Switch camera on 'C' key press
	if Input.is_action_just_pressed("switch_camera"):
		switch_camera()
	
	# Quit application on 'Q' key press
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func spawn_branches():
	for i in range(number_of_branches):
		var branch_instance = branch_scene.instantiate()
		var random_position = Vector3(randf_range(-spawn_area.x/2, spawn_area.x/2), 0, randf_range(-spawn_area.y/2, spawn_area.y/2))
		branch_instance.global_transform.origin = random_position
		branch_instance.add_to_group("branch")
		add_child(branch_instance)

func switch_camera():
	current_camera_index = (current_camera_index + 1) % cameras.size()
	activate_camera(current_camera_index)

func activate_camera(index):
	for i in range(cameras.size()):
		cameras[i].current = (i == index)
		
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_F:
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

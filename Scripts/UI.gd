extends Control

@export var bird_node_path: NodePath
@onready var bird = get_node("/root/World/Bird")

@onready var label_position = $Label_Position
@onready var label_state = $Label_State
@onready var label_exit = $Label_Exit

func _ready():
	label_exit.text = "Exit: Q"

func _process(delta):
	if bird:
		var bird_position = bird.global_transform.origin
		label_position.text = "Position: X=%.2f, Y=%.2f, Z=%.2f" % [bird_position.x, bird_position.y, bird_position.z]
		label_state.text = "State: %s" % [str(bird.current_state)]

func _on_speed_slider_value_changed(value):
	if bird:
		bird.max_speed = value

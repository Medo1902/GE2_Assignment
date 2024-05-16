extends CharacterBody3D

enum State { SEARCHING, MOVING_TO_BRANCH, DELIVERING }
var current_state = State.SEARCHING
var target_branch = null
var nest_position = Vector3.ZERO
var max_force = 0.1
var max_speed = 5.0
var min_speed = 2.0  
var delivery_radius = 4.0
var bank_angle = 10.0

# Reference to the AnimationPlayer
var animation_player: AnimationPlayer

func _ready():
	animation_player = $AnimationPlayer  
	var world_node = get_node("/root/World")
	if world_node.has_node("Nest"):
		nest_position = world_node.get_node("Nest").global_transform.origin
	else:
		print("Nest node not found!")
	# Play the flap animation in a loop
	animation_player.play("Flap")

func _physics_process(delta):
	print("Current State: ", current_state)
	print("Current Velocity: ", velocity)
	print("Current Position: ", global_transform.origin)

	match current_state:
		State.SEARCHING:
			search_for_branch()
		State.MOVING_TO_BRANCH:
			if target_branch:
				move_to_branch(delta)
		State.DELIVERING:
			deliver_branch(delta)

	rotate_and_bank(delta)

func rotate_and_bank(delta):
	var target_dir = velocity.normalized()
	print("Target direction: ", target_dir)
	var current_dir = -global_transform.basis.z.normalized() 
	print("Current direction: ", current_dir)
	
	if target_dir.length() > 0.01 and current_dir.dot(target_dir) > -0.99:
		var new_dir = current_dir.lerp(target_dir, delta * 5.0)
		var look_target = global_transform.origin + new_dir * 10
		print("Look target: ", look_target)
		look_at(look_target, Vector3.UP)

		var angle_diff = current_dir.angle_to(target_dir)
		var bank_direction = sign(current_dir.cross(target_dir).y)
		rotate_object_local(Vector3.UP, angle_diff * bank_angle * delta * bank_direction)

func seek(target_pos, delta):
	apply_steering(target_pos, delta)

func arrive(target_pos, delta):
	apply_steering(target_pos, delta, true)

func apply_steering(target_pos, delta, is_arriving = false):
	var target_vector = target_pos - global_transform.origin
	var distance = target_vector.length()
	var desired_velocity = target_vector.normalized()

	if is_arriving:
		
		var ramped_speed = max_speed * (distance / 5)  
		var clipped_speed = max(min(ramped_speed, max_speed), min_speed)  
		desired_velocity *= clipped_speed
	else:
		desired_velocity *= max_speed

	var steering = desired_velocity - velocity
	if steering.length() > max_force:
		steering = steering.normalized() * max_force

	velocity += steering
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	move_and_slide()

func move_to_branch(delta):
	if target_branch:
		arrive(target_branch.global_transform.origin, delta)
		if global_transform.origin.distance_to(target_branch.global_transform.origin) < 1.0:
			pick_up_branch()

func deliver_branch(delta):
	arrive(nest_position, delta)
	if global_transform.origin.distance_to(nest_position) < delivery_radius:
		drop_branch_at_nest()

func pick_up_branch():
	target_branch.queue_free()
	target_branch = null
	current_state = State.DELIVERING

func drop_branch_at_nest():
	var nest = get_node("/root/World/Nest")
	nest.call("add_branch_at_nest")
	current_state = State.SEARCHING

func search_for_branch():
	var nearest_branch = find_nearest_branch()
	if nearest_branch:
		target_branch = nearest_branch
		current_state = State.MOVING_TO_BRANCH

func find_nearest_branch():
	var min_distance = INF
	var nearest = null
	for branch in get_tree().get_nodes_in_group("branch"):
		var distance = global_transform.origin.distance_to(branch.global_transform.origin)
		if distance < min_distance:
			min_distance = distance
			nearest = branch
	return nearest

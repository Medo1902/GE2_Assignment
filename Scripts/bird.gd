extends CharacterBody3D

enum State { SEARCHING, MOVING_TO_BRANCH, DELIVERING }
var current_state = State.SEARCHING
var target_branch = null
var nest_position = Vector3.ZERO
var max_force = 0.1
var max_speed = 5.0
var delivery_radius = 2.0
var bank_angle = 10.0

func _ready():
	var world_node = get_node("/root/World")
	if world_node.has_node("Nest"):
		nest_position = world_node.get_node("Nest").global_transform.origin
	else:
		print("Nest node not found!")

func _physics_process(delta):
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
	if target_dir.length() > 0.01:
		var current_dir = global_transform.basis.z.normalized()
		if current_dir.dot(target_dir) > -0.99:
			# Smooth rotation towards the target direction
			var new_dir = current_dir.lerp(target_dir, delta * 5.0)
			var look_target = global_transform.origin + new_dir * 10  # Create a target point in the direction to look at
			look_at(look_target, Vector3.UP)

			# Calculate the banking angle based on the steering force
			var cross_product = current_dir.cross(target_dir).normalized()
			var angle_diff = min(cross_product.length() * bank_angle * delta, deg_to_rad(bank_angle))
			rotate_object_local(cross_product, angle_diff)

func seek(target_pos, delta):
	apply_steering(target_pos, delta)

func arrive(target_pos, delta):
	apply_steering(target_pos, delta, true)

func apply_steering(target_pos, delta, is_arriving = false):
	var target_vector = target_pos - global_transform.origin
	var distance = target_vector.length()
	var desired_velocity = target_vector.normalized()
	if is_arriving and distance < 5:
		desired_velocity *= max_speed * (distance / 5)
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

extends CharacterBody3D  # Ensure this is Godot 4.x

enum State { SEARCHING, MOVING_TO_BRANCH, DELIVERING }
var current_state = State.SEARCHING
var target_branch = null
var nest_position = Vector3.ZERO
var max_force = 0.1
var max_speed = 5.0
var delivery_radius = 2.0  # Defines how close the bird needs to be to the nest


func _ready():
	var world_node = get_node("/root/World")  # Adjust the path according to your project structure
	if world_node.has_node("Nest"):
		nest_position = world_node.get_node("Nest").global_transform.origin
	else:
		print("Nest node not found!")

func _physics_process(delta):
	match current_state:
		State.SEARCHING:
			search_for_branch()
			print("State: Searching for branches")
		State.MOVING_TO_BRANCH:
			if target_branch:
				move_to_branch(delta)
				print("State: Moving to Branch")
				print("Current Position: ", global_transform.origin)

				print("Velocity: ", velocity)
		State.DELIVERING:
			deliver_branch(delta)
			print("State: Delivering to Nest")
			print("Current Position: ", global_transform.origin)
			print("Nest Position: ", nest_position)
			print("Velocity: ", velocity)

func seek(target_pos, delta):
	var desired_velocity = (target_pos - global_transform.origin).normalized() * max_speed
	var steering = desired_velocity - velocity
	if steering.length() > max_force:
		steering = steering.normalized() * max_force
	velocity += steering
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	move_and_slide()  # No arguments needed, uses internal 'velocity'

func arrive(target_pos, delta):
	var desired_velocity = (target_pos - global_transform.origin)
	var distance = desired_velocity.length()
	if distance < 5:
		desired_velocity = desired_velocity.normalized() * max_speed * (distance / 5)
	else:
		desired_velocity = desired_velocity.normalized() * max_speed
	var steering = desired_velocity - velocity
	if steering.length() > max_force:
		steering = steering.normalized() * max_force
	velocity += steering
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	move_and_slide()  # No arguments needed
	
func move_to_branch(delta):
	if target_branch:
		arrive(target_branch.global_transform.origin, delta)
		# Check if the bird is close enough to pick up the branch
		if global_transform.origin.distance_to(target_branch.global_transform.origin) < 1.0:
			pick_up_branch()

func deliver_branch(delta):
	arrive(nest_position, delta)
	# Check if arrived at nest
	if global_transform.origin.distance_to(nest_position) < 1.0:
		drop_branch_at_nest()

func pick_up_branch():
	target_branch.queue_free()  # Assume the branch will be removed or made invisible
	target_branch = null
	current_state = State.DELIVERING

func drop_branch_at_nest():
	if global_transform.origin.distance_to(nest_position) < delivery_radius:  # ensure delivery_radius is defined and reasonable
		var nest = get_node("/root/World/Nest")  # Adjust the path as necessary
		nest.call("add_branch_at_nest")
		current_state = State.SEARCHING  # Go back to searching after delivery


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

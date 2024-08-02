class_name EntityMotionComponent extends Node

@export_group("Components")
@export var Config : EntityConfig
@export var Body : EntityBodyComponent

var movement_vector : Vector3

func calculate_movement_vector(input_direction: Vector3, rotation_radians: float) -> void:
	# Gather the horizontal speeds.
	var speeds := Vector2(Config.SIDE_SPEED, Config.FORWARD_SPEED)
	
	# Clamp down the horizontal speeds to MAX_SPEED.
	for i in range(2):
		if speeds[i] > Config.MAX_SPEED:
			speeds[i] *= Config.MAX_SPEED / speeds[i]
	
	# Create vector that stores speed and direction.
	var move_dir = Vector3(input_direction.x * speeds.x, 0, input_direction.z * speeds.y).rotated(Vector3.UP, rotation_radians)
	
	# Bring down the move direction to a third of it's speed.
	if Body.ducked:
		move_dir *= Config.DUCKING_SPEED_MULTIPLIER
	
	# Clamp desired speed to max speed
	if (move_dir.length() > Config.MAX_SPEED):
		move_dir *= Config.MAX_SPEED / move_dir.length()
	
	movement_vector = move_dir

# Adds to the player's velocity based on direction, speed and acceleration.
func accelerate() -> void:
	if !Body: return
	
	var addspeed : float
	var accelspeed : float
	var currentspeed : float
	var delta : float = get_physics_process_delta_time()
	var wishdir : Vector3 = movement_vector.normalized()
	var wishspeed : float = movement_vector.length()
	
	# See if we are changing direction a bit
	currentspeed = Body.velocity.dot(wishdir)
	
	# Reduce wishspeed by the amount of veer.
	addspeed = wishspeed - currentspeed
	
	# If not going to add any speed, done.
	if addspeed <= 0:
		return;
		
	# Determine the amount of acceleration.
	accelspeed = Config.ACCELERATION * wishspeed * delta
	
	# Cap at addspeed
	if accelspeed > addspeed:
		accelspeed = addspeed
	
	# Adjust velocity.
	Body.velocity += accelspeed * wishdir

# Adds to the player's velocity based on direction, speed and acceleration. 
# The difference between _accelerate() and this function is it caps the maximum speed you can accelerate to.
func airaccelerate() -> void:
	if !Body: return
	
	var addspeed : float
	var accelspeed : float
	var currentspeed : float
	var delta : float = get_physics_process_delta_time()
	var wishdir : Vector3 = movement_vector.normalized()
	var wishspeed : float = movement_vector.length()
	var wishspd : float = wishspeed
	
	if (wishspd > Config.MAX_AIR_SPEED):
		wishspd = Config.MAX_AIR_SPEED
	
	# See if we are changing direction a bit
	currentspeed = Body.velocity.dot(wishdir)
	
	# Reduce wishspeed by the amount of veer.
	addspeed = wishspd - currentspeed
	
	# If not going to add any speed, done.
	if addspeed <= 0:
		return;
		
	# Determine the amount of acceleration.
	accelspeed = Config.AIR_ACCELERATION * wishspeed * delta
	
	# Cap at addspeed
	if accelspeed > addspeed:
		accelspeed = addspeed
	
	# Adjust velocity.
	Body.velocity += accelspeed * wishdir

# Applies friction to the player's horizontal velocity
func friction(strength: float) -> void:
	if !Body: return
	
	var speed : float = Body.velocity.length()
	var delta : float = get_physics_process_delta_time()
	
	# Bleed off some speed, but if we have less that the bleed
	# threshold, bleed the threshold amount.
	var control =  Config.STOP_SPEED if (speed < Config.STOP_SPEED) else speed
	
	# Add the amount to the drop amount
	var drop = control * (Config.FRICTION * strength) * delta
	
	# Scale the velocity.
	var newspeed = speed - drop
	
	if newspeed < 0:
		newspeed = 0
	
	if speed > 0:
		newspeed /= speed
	
	Body.velocity.x *= newspeed
	Body.velocity.z *= newspeed

# Applies a jump force to the player.
func jump() -> void:
	var delta : float = get_physics_process_delta_time()
	
	# Apply the jump impulse
	Body.velocity.y = sqrt(2 * Config.GRAVITY * Config.JUMP_HEIGHT)
	
	# Add in some gravity correction
	Body.velocity.y -= (Config.GRAVITY * delta * 0.5 )
	
	# If the Player Config wants us to clip the velocity, do it.
	match Config.BUNNYHOP_CAP_MODE:
		Config.BunnyhopCapMode.NONE:
			pass
		Config.BunnyhopCapMode.THRESHOLD:
			bunnyhop_capmode_threshold()
		Config.BunnyhopCapMode.DROP:
			bunnyhop_capmode_drop()

# Crops horizontal velocity down to a defined maximum threshold.
func bunnyhop_capmode_threshold() -> void:
	var spd : float
	var fraction : float
	var maxscaledspeed : float
	
	# Calculate what the maximum speed is.
	maxscaledspeed = Config.SPEED_THRESHOLD_FACTOR * Config.MAX_SPEED
	
	# Avoid divide-by-zero errors.
	if (maxscaledspeed <= 0): 
		return
	
	spd = Vector3(Body.velocity.x, 0.0, Body.velocity.z).length()
	
	if (spd <= maxscaledspeed): return
	
	fraction = (maxscaledspeed / spd)
	
	Body.velocity.x *= fraction
	Body.velocity.z *= fraction

# Crops horizontal velocity down to a defined dropped amount.
func bunnyhop_capmode_drop() -> void:
	var spd : float
	var fraction : float
	var maxscaledspeed : float
	var dropspeed : float
	
	maxscaledspeed = Config.SPEED_THRESHOLD_FACTOR * Config.MAX_SPEED
	dropspeed = Config.SPEED_DROP_FACTOR * Config.MAX_SPEED
	
	if (maxscaledspeed <= 0): 
		return
	
	spd = Vector3(Body.velocity.x, 0.0, Body.velocity.z).length()
	
	if (spd <= maxscaledspeed): return
	
	fraction = (dropspeed / spd)
	
	Body.velocity.x *= fraction
	Body.velocity.z *= fraction

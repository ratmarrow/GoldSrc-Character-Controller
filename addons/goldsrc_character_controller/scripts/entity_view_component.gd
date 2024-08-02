class_name EntityViewComponent extends Node3D

@export var Config : EntityConfig
@export var Body : EntityBodyComponent

@export_subgroup("Gimbal")
@export var yaw_node : Node3D ## Y-axis Camera Mount gimbal.
@export var pitch_node : Node3D ## X-axis Camera Mount gimbal.
@export var camera_target : Node3D ## Used for player view aesthetics such as view tilt and bobbing.

func _physics_process(_delta) -> void:
	# Add some view bobbing to the Camera Mount
	camera_bob()
	
	global_position = Body.view_target.global_position
	
	camera_target.rotation.z = calc_roll(Config.ROLL_ANGLE, Config.ROLL_SPEED)*2

# Manipulates the Camera Mount gimbals.
func handle_camera_input(look_input: Vector2) -> void:
	yaw_node.rotate_object_local(Vector3.DOWN, look_input.x)
	yaw_node.orthonormalize()
	
	pitch_node.rotate_object_local(Vector3.LEFT, look_input.y)
	pitch_node.rotation.x = clamp(pitch_node.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	pitch_node.orthonormalize()

# Creates a sinusoidal Camera Mount bobbing motion whilst moving.
func camera_bob() -> void:
	var bob : float
	var simvel : Vector3
	simvel = Body.velocity
	simvel.y = 0
	
	if Config.BOB_FREQUENCY == 0.0 or Config.BOB_FRACTION == 0:
		return
	
	if Body.is_on_floor():
		bob = lerp(0.0, sin(Time.get_ticks_msec() * Config.BOB_FREQUENCY) / Config.BOB_FRACTION, (simvel.length() / 2.0) / Config.FORWARD_SPEED)
	else:
		bob = 0.0
	camera_target.position.y = lerp(camera_target.position.y, bob, 0.5)

# Returns a value for how much the Camera Mount should tilt to the side.
func calc_roll(rollangle: float, rollspeed: float) -> float:
	
	if Config.ROLL_ANGLE == 0.0 or Config.ROLL_SPEED == 0:
		return 0
	
	var side = Body.velocity.dot(yaw_node.transform.basis.x)
	
	var roll_sign = 1.0 if side < 0.0 else -1.0
	
	side = absf(side)
	
	var value = rollangle
	
	if (side < rollspeed):
		side = side * value / rollspeed
	else:
		side = value
	
	return side * roll_sign

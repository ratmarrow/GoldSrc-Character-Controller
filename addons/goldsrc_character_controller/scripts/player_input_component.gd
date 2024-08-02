class_name PlayerInputComponent extends Node

@export_group("Components")
@export var Config : EntityConfig
@export var Body : EntityBodyComponent
@export var Move : EntityMotionComponent
@export var View : EntityViewComponent

# Inputs
var movement_input : Vector3
var mouse_input : Vector2
var move_dir : Vector3
var jump_on : bool
var duck_on : bool

func _ready() -> void:
	Input.set_use_accumulated_input(false) # Disable accumulated input for precise inputs.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # Capture the mouse.

func _input(event) -> void:
	
	#---------------------
	# Replace with your own implementation of MOUSE_MODE switching!!
	#---------------------
	
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		if event is InputEventKey:
			if event.is_action_pressed("ui_cancel"):
				get_tree().quit()
		
		if event is InputEventMouseButton:
			if event.button_index == 1:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		return
	
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return
	
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			# Grab the event data and process it.
			gather_mouse_input(event) 

func _process(_delta) -> void:
	# Reset mouse input to avoid drift.
	mouse_input = Vector2.ZERO

func _physics_process(_delta) -> void:
	gather_input()
	act_on_input()

func gather_mouse_input(event: InputEventMouseMotion) -> void:
	# Deform the mouse input to make it viewport size independent.
	var viewport_transform := get_tree().root.get_final_transform()
	mouse_input += event.xformed_by(viewport_transform).relative
	
	var degrees_per_unit : float = 0.0001
	
	# Modify mouse input based on sensitivity and granularity.
	mouse_input *= Config.MOUSE_SENSITIVITY
	mouse_input *= degrees_per_unit
	
	# Send it off to the View Control component.
	View.handle_camera_input(mouse_input)

func gather_input() -> void:
	# Get input strength on the horizontal axes.
	var ix = Input.get_action_raw_strength("pm_moveright") - Input.get_action_raw_strength("pm_moveleft")
	var iy = Input.get_action_raw_strength("pm_movebackward") - Input.get_action_raw_strength("pm_moveforward")
	
	# Collect input.
	movement_input = Vector3(ix, 0, iy).normalized()
	
	Move.calculate_movement_vector(movement_input, View.yaw_node.rotation.y)
	
	# Gather jumping and crouching input.
	jump_on = Input.is_action_pressed("pm_jump") if Config.AUTOHOP else Input.is_action_just_pressed("pm_jump")
	duck_on = Input.is_action_pressed("pm_duck")

func act_on_input() -> void:
	Body.duck(duck_on)
	
	# Check if we are on ground
	if Body.is_on_floor():
		if jump_on:
			# Not running friction on ground if you press jump fast enough allows you to preserve all speed.
			Move.jump()
			# NOTE: This is sort of a band-aid to make bunny-hopping on walkable slopes feel a lot nicer.
			Move.airaccelerate()
		else:
			Move.friction(1.0)
			Move.accelerate()
	else: 
		Move.airaccelerate()

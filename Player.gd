class_name Player
extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.005

var leftHandActive = false
var leftHandDestination = Vector3()
var leftHandDestinationGet = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var leftHand = $Head/Camera3D/LeftHandCast
@onready var head = $Head
@onready var camera = $Head/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func grab():
	if Input.is_action_pressed("LeftHand"):
		if leftHand.is_colliding():
			print("Found thing")
			if not leftHandActive:
				leftHandActive = true
	if leftHandActive:
		if not leftHandDestinationGet:
			leftHandDestination = leftHand.get_collision_point() + Vector3(0, 1.25, 1)
			leftHandDestinationGet = true
		if leftHandDestination.distance_to(transform.origin) > 1:
			if leftHandDestinationGet:
				transform.origin = lerp(transform.origin, leftHandDestination, 0.0025)
				transform.origin = clamp(transform.origin, (leftHandDestination-Vector3(0,.5,0)), (leftHandDestination + Vector3(0,.5,0)))
		if Input.is_action_just_released("LeftHand"):
			leftHandActive = false
			leftHandDestinationGet = false


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	grab()
	move_and_slide()

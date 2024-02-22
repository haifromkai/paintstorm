extends CharacterBody3D

# Gravity variables
const JUMP_VELOCITY = 5.0
var gravity = 9.8

# Movement variables
const SENSITIVITY = 0.0006
const WALK_SPEED = 3.2
const SPRINT_SPEED = 6.6
var speed

# Bob variables
const BOB_FREQ = 2.4
const BOB_AMP = 0.023
var t_bob = 0.0

# FOV variables
const BASE_FOV = 75.0
const FOV_CHANGE = 0.75

# Paintball variables
var paintball = load("res://Scenes/paintball.tscn")
var instance

# Define onready variables so we can use head and camera var later
@onready var head = $head
@onready var camera = $head/Camera3D
@onready var marker_anim = $head/Camera3D/marker/AnimationPlayer
@onready var marker_barrel = $head/Camera3D/marker/RayCast3D
@onready var marker_fire_audio = $head/Camera3D/marker/marker_fire
@onready var marker_smoke = $head/Camera3D/marker/GPUParticles3D

# Disable cursor 
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Camera Rotation based on mouse motion
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# when mouse moves up/down which controls y angle, rotate about the x axis
		head.rotate_y(-event.relative.x * SENSITIVITY)
		# when mouse moves left right which controls x angle, rotate about the y axis
		camera.rotate_x(-event.relative.y * SENSITIVITY)

		# limit camera y angle rotation by clamping camera.rotation.x b/n -55 and 55 degrees
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-55), deg_to_rad(55))



func _physics_process(delta):
	# Add Gravity. Decrement from y velocity the falling speed due to gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta * 1.7

	# Handle Jump. Player presses space AND is on floor.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY * 1.3

	# Handle Sprint
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Implement Intertia
		# Implement Speed

	# while on ground...	
	if is_on_floor():
		# how fast we move
		if direction:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 8.0)
			velocity.y = lerp(velocity.y, direction.y * speed, delta * 8.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 8.0)
		# how fast we stop (using intertia)
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 11.0)
			velocity.y = lerp(velocity.y, direction.y * speed, delta * 3.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 11.0)
	# while in air (using intertia)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 1.5)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 1.5)

	# Bob during movement
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

	# FOV (only activate when sprint is held)
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	if Input.is_action_pressed("sprint"):
		camera.fov = lerp(camera.fov, target_fov, delta * 2.0)
	else:
		camera.fov = lerp(camera.fov, BASE_FOV, delta * 6.0)


	# Firing
	if Input.is_action_pressed("fire"):
		if !marker_anim.is_playing():
			marker_anim.play("fire")

			# play sound effect
			marker_fire_audio.play()

			# instantiate() creates a new object from the loaded paintball scene
			instance = paintball.instantiate()
			# set position of new paintball to global position of marker barrel raycast
			instance.position = marker_barrel.global_position
			# set transform basis or rotation of new paintball to marker barrel raycast
			instance.transform.basis = marker_barrel.global_transform.basis
			# parent is the world, add instance as child
			get_parent().add_child(instance)

			# play smoke animation
			marker_smoke.emitting = true




	move_and_slide()


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

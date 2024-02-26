extends CharacterBody3D

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ VARIABLES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Gravity
const jump_velocity = 5.0
var gravity = 9.8

# Movement
const sensitivity = 0.0006
const walk_speed = 3.2
const crouch_speed = 2.0
const sprint_speed = 6.3
var speed
var is_crouching = false

# Bob
const bob_freq = 2.4
const bob_amp = 0.023
var t_bob = 0.0

# FOV
const base_fov = 75.0
#const fov_change = 0.75
const fov_change = 0.75

# Paintball
var paintball = load("res://Models/marker/paintball.tscn")
var instance

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ DEFINING ONREADY VARIABLES ~~~~~~~~~~~~~~~~~~~~~~~~~~~
@onready var head = $head
@onready var camera = $head/Camera3D
@onready var marker_anim = $head/Camera3D/marker/AnimationPlayer
@onready var marker_barrel = $head/Camera3D/marker/RayCast3D
@onready var marker_fire_audio = $head/Camera3D/marker/marker_fire
@onready var marker_smoke = $head/Camera3D/marker/GPUParticles3D
@onready var crouch_anim = $AnimationPlayer

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
func _ready():
	# Disable cursor 
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Camera Rotation based on mouse motion
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# when mouse moves up/down which controls y angle, rotate about the x axis
		head.rotate_y(-event.relative.x * sensitivity)
		# when mouse moves left right which controls x angle, rotate about the y axis
		camera.rotate_x(-event.relative.y * sensitivity)

		# limit camera y angle rotation by clamping camera.rotation.x b/n -55 and 55 degrees
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-55), deg_to_rad(55))


func _physics_process(delta):
	# Add Gravity. Decrement from y velocity the falling speed due to gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta * 1.7

	# Jump Handling (cant jump when holding crouch)
	if Input.is_action_just_pressed("jump") and is_on_floor() and !Input.is_action_pressed("crouch"):
		velocity.y = jump_velocity * 1.3

	# Speed Handling
	if Input.is_action_pressed("sprint"):
		speed = sprint_speed
	elif Input.is_action_pressed("crouch"):
		speed = crouch_speed
	else:
		speed = walk_speed

	# Movement Handling (Get input direction and handle the movement/deceleration)
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Implement Intertia and Speed
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

	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, sprint_speed * 2)
	var target_fov = base_fov + fov_change * velocity_clamped
	# only activate when sprint is held
	if Input.is_action_pressed("sprint"):
		camera.fov = lerp(camera.fov, target_fov, delta * 2.0)
	else:
		camera.fov = lerp(camera.fov, base_fov, delta * 4.0)

	# Crouch Handling (dont allow crouch when sprinting)
	# stay in crouch animation if ctrl is held down
	if Input.is_action_pressed("crouch"):
		if !is_crouching and is_on_floor() and !Input.is_action_pressed("sprint"):
			crouch_anim.play("crouching")
			is_crouching = true
	# return to standing position if ctrl is let go
	else:
		if is_crouching:
			crouch_anim.play_backwards("crouching")
			is_crouching = false

	# Firing
	if Input.is_action_pressed("fire"):
		if !marker_anim.is_playing():
			marker_anim.play("fire")

			# play sound effect
			marker_fire_audio.play()

			# emit smoke particle (.restart() allows consecutive emits)
			marker_smoke.emitting = true
			marker_smoke.restart()
			
			# instantiate() creates a new object from the loaded paintball scene
			instance = paintball.instantiate()
			# set position of new paintball to global position of marker barrel raycast
			instance.position = marker_barrel.global_position
			# set transform basis or rotation of new paintball to marker barrel raycast
			instance.transform.basis = marker_barrel.global_transform.basis
			# parent is the world, add instance as child
			get_parent().add_child(instance)

	move_and_slide()


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_freq) * bob_amp
	pos.x = cos(time * bob_freq / 2) * bob_amp
	return pos
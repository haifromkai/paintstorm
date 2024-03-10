extends CharacterBody3D

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ VARIABLES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
const sensitivity = 0.0005
const gravity = 9.8
const walk_speed = 3.0
const crouch_speed = 1.4
const crawl_speed = 1.0
const sprint_speed = 5.5
const jump_velocity = 6.8
const head_height = 0.558

var speed
var crouch_depth = -0.7
var crawl_depth = -1.3
var crawl_state = false

# Bob
const bob_freq = 2.4
const bob_amp = 0.023
var t_bob = 0.0

# FOV
const base_fov = 75.0
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
@onready var standing_collision_shape = $Standing_CollisionShape3D
@onready var crouching_collision_shape = $Crouching_CollisionShape3D
@onready var crawling_collision_shape = $Crawling_CollisionShape3D
@onready var player_raycast = $RayCast3D
@onready var player_shapecast = $ShapeCast3D

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
func _ready():
	# Disable cursor 
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# F3 to get debug stats
	Engine.get_frames_per_second()


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# when mouse up/down -> control y angle: rotate about x axis
		head.rotate_y(-event.relative.x * sensitivity)
		# when mouse left/right -> control x angle: rotate about y axis
		camera.rotate_x(-event.relative.y * sensitivity)
		# limit y angle rotation by clamping camera.rotation.x
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(50))


func _physics_process(delta):
	# Add Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta * 1.8

	# Direction Handling
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Jump Handling
	if Input.is_action_just_pressed("jump") and is_on_floor() and !Input.is_action_pressed("crouch") and !Input.is_action_pressed("crawl") and !player_raycast.is_colliding():
		velocity.y = jump_velocity

	# Stance & Speed Handling --------------------------------------------------------
	# Crawling State (Hold)
	if Input.is_action_pressed("crawl") and is_on_floor():
		speed = lerp(speed, crawl_speed, delta * 5.0)
		if head.position.y > head_height + crouch_depth:
			head.position.y = lerp(head.position.y, head_height + crawl_depth, delta * 1.4)
		else:
			head.position.y = move_toward(head.position.y, head_height + crawl_depth, delta * 1.8)

		if head.position.y < head_height + crawl_depth + 0.3:
			standing_collision_shape.disabled = true
			crouching_collision_shape.disabled = true
			crawling_collision_shape.disabled = false
			crawl_state = true

	# Crouching State (Hold)
	elif Input.is_action_pressed("crouch") and is_on_floor() and !Input.is_action_pressed("crawl") and crawl_state == false:
		speed = lerp(speed, crouch_speed, delta * 9.0)
		head.position.y = lerp(head.position.y, head_height + crouch_depth, delta * 3.2)
		if head.position.y < head_height + crouch_depth + 0.3:
			standing_collision_shape.disabled = true
			crouching_collision_shape.disabled = false
			crawling_collision_shape.disabled = true

	# Standing State
	elif !player_shapecast.is_colliding():
		if head.position.y < head_height + crouch_depth:
			head.position.y = lerp(head.position.y, head_height, delta * 1.1)

		else:
			head.position.y = lerp(head.position.y, head_height, delta * 3.2)

		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
		crawling_collision_shape.disabled = true
		crawl_state = false

		# Sprinting
		if Input.is_action_pressed("sprint") and !Input.is_action_pressed("backward"):
			speed = lerp(speed, sprint_speed, delta * 3.6)
		# Walking
		else:
			if head.position.y < head_height + crouch_depth:
				speed = move_toward(crawl_speed, crouch_speed, delta * 0.5)
			else:
				speed = walk_speed
	#-------------------------------------------------------------------------------------
	# Add Inertia
	if is_on_floor():
		# Starting Speed
		if direction:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.y = lerp(velocity.y, direction.y * speed, delta * 6.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
		# Stopping Speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 8.0)
			velocity.y = lerp(velocity.y, direction.y * speed, delta * 3.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 8.0)
	# In Air
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


	# Exit Program
	if Input.is_action_just_pressed("exit"):
		SignalManager._reset_game()
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_freq) * bob_amp
	pos.x = cos(time * bob_freq / 2) * bob_amp
	return pos

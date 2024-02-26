extends Node3D

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ VARIABLES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
const SPEED = 110
const GRAVITY = 9.8

var velocity = Vector3(0, 0, -SPEED)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ DEFINING ONREADY VARIABLES ~~~~~~~~~~~~~~~~~~~~~~~~~~~
@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D
@onready var hit_sound = $AudioStreamPlayer

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# Update velocity with gravity
	velocity.y -= (GRAVITY * 1.3) * delta

	# Move paintball
	position += transform.basis * velocity * delta


	# GPU Particle Animation
	# check if raycast is colliding
	if ray.is_colliding():
		_paintball_hit()

func _paintball_hit():
	# turn off mesh visibilty
	mesh.visible = false
	# turn on gpu particle
	particles.emitting = true
	# play sound when paintball hits
	hit_sound.play()
	# wait 1s until particles done emitting 
	await get_tree().create_timer(1.1).timeout
	# delete the paintball
	queue_free()
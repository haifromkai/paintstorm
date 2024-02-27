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

func _paintball_hit(): # still need to fix paintball colliding through bots

	# get what paintball collided with 
	var collider = ray.get_collider()

	# check if collider exists and if it's in the bot collision layer
	if collider and (collider.name.find("bot") != -1 or collider.name.find("Bone") != -1):
		
		# emit signal
		emit_signal("hit", 1)
		
		# play sound when paintball hitsd
		hit_sound.play()
		# turn off mesh visibilty
		mesh.visible = false
		# turn on gpu particle
		particles.emitting = true
		# wait 1s until particles done emitting 
		await get_tree().create_timer(1.1).timeout
		# delete the paintball
		queue_free()

	else:
		queue_free()

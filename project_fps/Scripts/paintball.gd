extends Node3D

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ VARIABLES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
const SPEED = 110
const GRAVITY = 9.8

var velocity = Vector3(0, 0, -SPEED)

signal enemy_hit
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ DEFINING ONREADY VARIABLES ~~~~~~~~~~~~~~~~~~~~~~~~~~~
@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D
@onready var hit_sound = $AudioStreamPlayer
@onready var bunker_sound = $AudioStreamPlayer3D

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

		if ray.get_collider().is_in_group("bunker"):
			bunker_sound.play()
			await get_tree().create_timer(1.0).timeout
			queue_free()
		# check if raycast colliding with enemy
		elif ray.get_collider().is_in_group("enemy"):
			# play sound when paintball hits
			hit_sound.play()
			# turn off mesh visibilty
			mesh.visible = false
			# turn on gpu particle
			particles.emitting = true
			# emit signal that enemy was hit
			emit_signal("enemy_hit")
			# wait 1s until particles done emitting 
			await get_tree().create_timer(1.1).timeout
			# delete the paintball
			queue_free()

		# when raycast not colliding with enemy
		# else:
			# bunker_sound.play()
			# await get_tree().create_timer(1.1).timeout
			# queue_free()

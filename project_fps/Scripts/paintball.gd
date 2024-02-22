extends Node3D

const SPEED = 110
const GRAVITY = 9.8

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D
@onready var hit_sound = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# movement of bullet is -z direction (original code)
	position += transform.basis * Vector3(0, 0, -SPEED) * delta


	# GPU Particle Animation
	# check if raycast is colliding
	if ray.is_colliding():
		# if it is, turn off mesh visibilty and turn on gpu particle instead
		mesh.visible = false
		particles.emitting = true
		# play sound when paintball hits
		hit_sound.play()
		# wait 1s until particles done emitting 
		await get_tree().create_timer(1.1).timeout
		# delete the paintball
		queue_free()

func _on_timer_timeout():
	queue_free()
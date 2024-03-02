extends Node3D

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ VARIABLES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
const SPEED = 110
const GRAVITY = 9.8

var velocity = Vector3(0, 0, -SPEED)
var mesh
# set a collision flag
var collision_processed = false
var delete_flag = false

# set a bot node hit flag
var hit_bot = null

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ DEFINING ONREADY VARIABLES ~~~~~~~~~~~~~~~~~~~~~~~~~~~
@onready var mesh_day = $MeshInstance3D
@onready var mesh_night = $MeshInstance3D2
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D
@onready var hit_sound = $AudioStreamPlayer
@onready var bunker_sound = $AudioStreamPlayer3D

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
func _ready():
	# turn up emission strength if night map selected
	if SignalManager.night_selected:
		mesh = mesh_night
		mesh_day.visible = false
	else:
		mesh = mesh_day
		mesh_night.visible = false


func _process(delta):
	# Update velocity with gravity
	velocity.y -= (GRAVITY * 1.3) * delta

	# Move paintball
	position += transform.basis * velocity * delta


	# Check if raycast is colliding and collision flag
	if ray.is_colliding() and not collision_processed:

		# check if raycast colliding with bunker
		if ray.get_collider().is_in_group("bunker"):
			queue_free()

		# check if raycast colliding with enemy
		elif ray.get_collider().is_in_group("enemy"):

			# play sound when paintball hits
			hit_sound.play()

			# store reference to the hit bot node
			hit_bot = ray.get_collider()

			# call delete bot function
			delete_hit_bot()

			# turn off mesh visibilty
			mesh.visible = false

			# turn on gpu particle
			particles.emitting = true

			# increment score
			SignalManager.score += 1

			# change collision flag
			collision_processed = true

			# wait 1s until particles done emitting 
			await get_tree().create_timer(1.1).timeout

			# delete the paintball
			queue_free()


func delete_hit_bot():
	if hit_bot != null and hit_bot.name.find("bot") != -1:
		hit_bot.queue_free()
		SignalManager.bots_remaining -= 1
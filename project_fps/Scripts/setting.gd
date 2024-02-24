extends Node3D

@onready var palm_tree1_anim = $palm_tree1/AnimationPlayer
@onready var palm_tree2_anim = $palm_tree2/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	palm_tree1_anim.play("PalmTreeAction")
	palm_tree2_anim.play("PalmTreeAction")
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

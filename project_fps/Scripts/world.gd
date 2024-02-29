extends Node3D

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ VARIABLES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
var score = 0

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ DEFINING ONREADY VARIABLES ~~~~~~~~~~~~~~~~~~~~~~~~~~~
# @onready var paintball_ray = $player/head/Camera3D/marker/RayCast3D
@onready var scoreboard = $player/head/Camera3D/CanvasLayer/Label

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
func _ready():
    print("Game Started")

    # connect to receive "add_point" signal from player node
    $player.connect("add_point", update_score)
    scoreboard.text = str(score)

func update_score():
    score += 1
    scoreboard.text = str(score)
    print("score:", score)
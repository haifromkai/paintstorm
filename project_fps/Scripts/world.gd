extends Node3D

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ VARIABLES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
var hit_count = 0
var bot_names = ["bot1", "bot2", "bot3", "bot4", "bot5", "bot6", "bot7", "bot8"]

var paintball = load("res://Models/marker/paintball.tscn")
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ DEFINING ONREADY VARIABLES ~~~~~~~~~~~~~~~~~~~~~~~~~~~
# @onready var paintball_ray = $player/head/Camera3D/marker/RayCast3D
@onready var paintball_ray = $paintball/RayCast3D
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

func _ready():
    print("Game Started")



func _process(_delta):
    _paintball_hit(paintball.connect("hit", _paintball_hit))


func _paintball_hit(hit_amount):
    print(hit_count)
    hit_count += hit_amount
    print(hit_count)
    pass

extends Node3D

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ VARIABLES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Map
var day_map = load("res://Environments/day.tres")
var sunset_map = load("res://Environments/sunset.tres")
var night_map = load("res://Environments/night.tres")

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ DEFINING ONREADY VARIABLES ~~~~~~~~~~~~~~~~~~~~~~~~~~~
@onready var scoreboard = $player/head/Camera3D/CanvasLayer/Label
@onready var game_won_overlay = $player/head/Camera3D/CanvasLayer/Label2

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
func _ready():

	# update map
	update_map()

	# play game music using autoload music_player
	MusicPlayer.play_game_music()

	# connect receive signal add_score to run func update score
	# $player.connect("add_point", update_score)

	# overlays
	scoreboard.text = str(SignalManager.bots_remaining)
	game_won_overlay.visible = false


func _process(_delta):
	# update scoreboard
	scoreboard.text = str(SignalManager.bots_remaining)

	# if all enemies hit, play win sound and go to main menu
	if SignalManager.bots_remaining == 0:
		game_won()


func update_map():
	# receive autoload var from map_menu to change world lighting and environment
	if SignalManager.day_selected:
		$WorldEnvironment.set_environment(day_map)
		$DirectionalLight3D.visible = true
		$DirectionalLight3D2.visible = false

	elif SignalManager.sunset_selected:
		$WorldEnvironment.set_environment(sunset_map)
		$DirectionalLight3D.visible = false
		$DirectionalLight3D2.visible = true

	elif SignalManager.night_selected:
		$WorldEnvironment.set_environment(night_map)
		$DirectionalLight3D.visible = false
		$DirectionalLight3D2.visible = false


func game_won():
	MusicPlayer.play_win_sound()
	game_won_overlay.visible = true
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	SignalManager.score = 0
	SignalManager.bots_remaining = 10
	SignalManager.day_selected = false
	SignalManager.sunset_selected = false
	SignalManager.night_selected = false
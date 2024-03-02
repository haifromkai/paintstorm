extends Control

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ VARIABLES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
var current_selection = 0

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ DEFINING ONREADY VARIABLES ~~~~~~~~~~~~~~~~~~~~~~~~~~~
@onready var selector_play = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer/HBoxContainer/Selector
@onready var selector_option = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer2/HBoxContainer/Selector
@onready var selector_exit = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer3/HBoxContainer/Selector
@onready var selector_sound = $Selector
@onready var selected_sound = $Selected
@onready var invalid_sound = $Invalid

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
func _ready():
	# initally place > on selector_play
	set_current_selection(0)
	# hide mouse cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# play menu music using autoload music_player
	MusicPlayer.play_menu_music()

func _process(_delta):

	# check user input to move selector by incrementing value
	if Input.is_action_just_pressed("ui_down") and current_selection < 2:
		selector_sound.play()
		current_selection += 1
		set_current_selection(current_selection)
	elif Input.is_action_just_pressed("ui_up") and current_selection > 0:
		selector_sound.play()
		current_selection -= 1
		set_current_selection(current_selection)
	elif Input.is_action_just_pressed("ui_accept"):
		handle_selection(current_selection)


func handle_selection(_current_selection):
	# direct to scene according to value of selector
	if _current_selection == 0:
		selected_sound.play()
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://Scenes/map_menu.tscn")
	elif _current_selection == 1:
		invalid_sound.play()
	elif _current_selection == 2:
		selected_sound.play()
		await get_tree().create_timer(1.0).timeout
		get_tree().quit()


func set_current_selection(_current_selection):
	# set all selector text to empty
	selector_play.text = ''
	selector_option.text = ''
	selector_exit.text = ''

	# check which selector should be set to >
	if _current_selection == 0:
		selector_play.text = '>'
	elif _current_selection == 1:
		selector_option.text = '>'
	elif _current_selection == 2:
		selector_exit.text = '>'


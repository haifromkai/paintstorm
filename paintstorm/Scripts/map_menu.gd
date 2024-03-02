extends Control

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ VARIABLES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
var current_selection = 0

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ DEFINING ONREADY VARIABLES ~~~~~~~~~~~~~~~~~~~~~~~~~~~
@onready var selector_day = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer/HBoxContainer/Selector
@onready var selector_sunset = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer2/HBoxContainer/Selector
@onready var selector_night = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer3/HBoxContainer/Selector
@onready var selector_back = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer4/HBoxContainer/Selector

@onready var selector_sound = $Selector
@onready var selected_sound = $Selected

@onready var day_img = $DayBackground
@onready var sunset_img = $SunsetBackground
@onready var night_img = $NightBackground

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
func _ready():
	# initally place > on selector_play
	set_current_selection(0)
	# hide mouse cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(_delta):
	
	# check user input to move selector by incrementing value
	if Input.is_action_just_pressed("ui_down") and current_selection < 3:
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
	
	selected_sound.play()
	
	# direct to scene according to value of selector
	if _current_selection == 0:
		SignalManager.day_selected = true
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://Scenes/world.tscn")

	elif _current_selection == 1:
		SignalManager.sunset_selected = true
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://Scenes/world.tscn")

	elif _current_selection == 2:
		SignalManager.night_selected = true
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://Scenes/world.tscn")

	elif _current_selection == 3:
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func set_current_selection(_current_selection):
	# set all selector text to empty
	selector_day.text = ''
	selector_sunset.text = ''
	selector_night.text = ''
	selector_back.text = ''

	# check which selector should be set to >
	if _current_selection == 0:
		selector_day.text = '>'
		day_img.visible = true
		sunset_img.visible = false
		night_img.visible = false

	elif _current_selection == 1:
		selector_sunset.text = '>'
		day_img.visible = false
		night_img.visible = false
		sunset_img.visible = true

	elif _current_selection == 2:
		selector_night.text = '>'
		sunset_img.visible = false
		night_img.visible = true

	elif _current_selection == 3:
		selector_back.text = '>'


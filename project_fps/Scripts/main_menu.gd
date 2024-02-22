extends Control

var current_selection = 0

@onready var selector_one = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer/HBoxContainer/Selector
@onready var selector_two = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer2/HBoxContainer/Selector
@onready var selector_three = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer3/HBoxContainer/Selector
@onready var selected_sound = $Selected


func _ready():
    # initally place > on selector_one
    set_current_selection(0)

func _process(_delta):
    # check user input to move selector
    if Input.is_action_just_pressed("ui_down") and current_selection < 2:
        current_selection += 1
        set_current_selection(current_selection)
    elif Input.is_action_just_pressed("ui_up") and current_selection > 0:
        current_selection -= 1
        set_current_selection(current_selection)
    elif Input.is_action_just_pressed("ui_accept"):
        handle_selection(current_selection)
        

func handle_selection(_current_selection):
    if _current_selection == 0:
        selected_sound.play()
        await get_tree().create_timer(1.4).timeout
        get_tree().change_scene_to_file("res://Scenes/world.tscn")
    elif _current_selection == 1:
        selected_sound.play()
        print("Picked Options")
    elif _current_selection == 2:
        get_tree().quit()

func set_current_selection(_current_selection):
    # set all selector text to empty
    selector_one.text = ''
    selector_two.text = ''
    selector_three.text = ''

    # check which selector should be set to >
    if _current_selection == 0:
        selector_one.text = '>'
    elif _current_selection == 1:
        selector_two.text = '>'
    elif _current_selection == 2:
        selector_three.text = '>'

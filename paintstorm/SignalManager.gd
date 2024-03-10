extends Node

var day_selected = false
var sunset_selected = false
var night_selected = false

var score = 0
var bots_remaining = 10


func _reset_game():
	day_selected = false
	sunset_selected = false
	night_selected = false
	score = 0
	bots_remaining = 10
extends AudioStreamPlayer

const menu_music = preload("res://Audio/head_empty.mp3")
const game_music = preload("res://Audio/achoo.mp3")
const win_sound = preload("res://Audio/win_sound.mp3")

func play_music(music: AudioStream, volume = 0.0):
	if stream == music:
		return

	stream = music
	volume_db = volume
	play()


func play_menu_music():
	play_music(menu_music, -14.0)

func play_game_music():
	play_music(game_music, -25.0)

func play_win_sound():
	play_music(win_sound, -12.0)

extends Control

var main_scene: PackedScene
var sound_on: Texture
var sound_off: Texture
var sound_muted: bool = false

func _ready():
	main_scene = preload("res://scenes/main.tscn")
	sound_off = preload("res://art/mute.png")
	sound_on = preload("res://art/sound_layered.png")
	AudioAutoload.regspeed()

func _on_play():
	AudioAutoload.play_pop(0)
	get_tree().change_scene_to_packed(main_scene)

func _on_help():
	AudioAutoload.play_pop(0)
	get_tree().change_scene_to_file("res://scenes/HelpMenu.tscn")

func _on_toggle_music():
	if sound_muted:
		$ToggleMusicButton.texture_normal = sound_on
	else:
		$ToggleMusicButton.texture_normal = sound_off
	sound_muted = !sound_muted
	AudioAutoload.toggle_music()

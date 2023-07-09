extends Control

var main_scene: PackedScene

func _ready():
	main_scene = preload("res://scenes/main.tscn")

func _on_play():
	get_tree().change_scene_to_packed(main_scene)

func _on_toggle_music():
	AudioAutoload.toggle_music()

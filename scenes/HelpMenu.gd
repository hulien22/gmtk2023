extends Control

func _on_return_menu():
	AudioAutoload.play_pop(0)
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

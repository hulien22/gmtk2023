extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_mouse_entered():
	if !disabled:
		var tween: Tween = create_tween()
		tween.tween_property(self,"scale",Vector2(1.1,1.1), 0.05).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
		AudioAutoload.play_bomb()

func _on_mouse_exited():
	if !disabled:
		var tween: Tween = create_tween()
		tween.tween_property(self,"scale",Vector2(1,1), 0.05).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)

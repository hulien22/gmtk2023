extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.connect("animation_finished", _on_clickanimation_complete)
	# fade in
	modulate.a = 0

var next_position: Vector2 = Vector2.INF

func click_at_positions(p1: Vector2, p2: Vector2):
	position = p1
	next_position = p2
	var tween: Tween = create_tween()
	tween.connect("finished", perform_click)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)

func perform_click():
	$AnimatedSprite2D.play("finger_click", 3.0)

func _on_clickanimation_complete():
	if (next_position == Vector2.INF):
		var tween: Tween = create_tween()
		tween.connect("finished", _on_fade_out_complete)
		tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	else:
		var tween: Tween = create_tween()
		tween.connect("finished", perform_click)
		tween.tween_property(self,"position",next_position, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		next_position = Vector2.INF

func _on_fade_out_complete():
	Events.emit_signal("finger_click_complete")

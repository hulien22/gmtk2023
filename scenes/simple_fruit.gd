extends Node2D

var bomb_posn:Vector2

func setup(t: Global.TileType, p: Vector2):
	$Sprites.frame = Global.get_index_from_type(t)
	bomb_posn = p

func _ready():
	modulate.a = 0.7

func animate():
	print("Spawn", global_position, position, bomb_posn)
	var tween: Tween = create_tween()
	tween.connect("finished", delete_self)
	tween.tween_property(self,"global_position",bomb_posn, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func delete_self():
	queue_free()
	pass

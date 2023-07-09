extends Node2D

var global_posn:Vector2

func setup(pts:int, t:Global.TileType, gp: Vector2):
	$ScoreLabel.text = str(pts)
	match t:
		Global.TileType.RED:
			modulate = Color('fe4552')
		Global.TileType.ORANGE:
			modulate = Color('fe9d4a')
		Global.TileType.YELLOW:
			modulate = Color('eebd21')
		Global.TileType.GREEN:
			modulate = Color('acc242')
		Global.TileType.BLUE:
			modulate = Color('6385f6')
		Global.TileType.PURPLE:
			modulate = Color('cd95fe')
	global_posn = gp

# Called when the node enters the scene tree for the first time.
func _ready():
	scale = Vector2(0.5,0.5)
	global_position = global_posn
	var tween: Tween = create_tween()
	tween.tween_property(self,"scale",Vector2(2,2), 1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var tween2: Tween = create_tween()
	tween2.connect("finished", delete_self)
	tween2.tween_property(self,"modulate",Color(modulate, 0), 5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var tween3: Tween = create_tween()
	tween3.tween_property(self,"global_position",Vector2(global_posn.x, global_posn.y - 50), 1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func delete_self():
	queue_free()
	pass

extends Node2D

# Called when the node enters the scene tree for the first time.
var sprites = [preload("res://art/fruits/apple__destroyer.png"), preload("res://art/fruits/orange__destroyer.png"),
			   preload("res://art/fruits/lemon__destroyer.png"), preload("res://art/fruits/pear__destroyer.png"),
			   preload("res://art/fruits/blueberry_destroyer.png"), preload("res://art/fruits/grape__destroyer.png")]
func setup(t: Global.TileType):
	$Sprites.frame = Global.get_index_from_type(t)

func _ready():
	var tween: Tween = create_tween()
	tween.connect("finished", eat_around)
	tween.tween_property($Sprites,"scale",Vector2(3,3), 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)

func eat_around():
	var tween: Tween = create_tween()
	tween.tween_property($Sprites,"scale",Vector2(1,1), 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	
	var tween2: Tween = create_tween()
	tween2.connect("finished", delete_self)
	tween2.tween_property($Sprites,"rotation_degrees",1080, 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)

func delete_self():
	queue_free()
	pass

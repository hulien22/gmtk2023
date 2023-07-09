extends Node2D

func setup(t: Global.TileType, m: Global.Modifier):
	match m:
		Global.Modifier.NONE:
			$Sprites.set_animation("Fruit")
		Global.Modifier.VERTICAL:
			$Sprites.set_animation("VerticalBomb")
		Global.Modifier.HORIZONTAL:
			$Sprites.set_animation("HorizontalBomb")
		Global.Modifier.DESTROYER_OF_EIGHT_TILES:
			$Sprites.set_animation("DestroyerBomb")
		Global.Modifier.BOMB:
			$Sprites.set_animation("FruitBomb")
	$Sprites.frame = Global.get_index_from_type(t)

func _ready():
	$Sprites.scale = Vector2(0.2,0.2)
	var tween: Tween = create_tween()
	tween.connect("finished", explode)
	tween.tween_property($Sprites,"scale",Vector2(1.3,1.3), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func explode():
	var tween: Tween = create_tween()
	tween.connect("finished", delete_self)
	tween.tween_property($Sprites,"scale",Vector2(1,1), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func delete_self():
	queue_free()
	pass

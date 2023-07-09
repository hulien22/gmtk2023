extends Node2D

# Called when the node enters the scene tree for the first time.
var sprites = [preload("res://art/fruits/apple_horizontal.png"), preload("res://art/fruits/orange_horizontal.png"),
			   preload("res://art/fruits/lemon_horizontal.png"), preload("res://art/fruits/pear_horizontal.png"),
			   preload("res://art/fruits/blueberry_horizontal.png"), preload("res://art/fruits/grape_horizontal.png")]
func setup(t: Global.TileType):
	$Sprites.frame = Global.get_index_from_type(t)
	$GPUParticles2D.texture = sprites[Global.get_index_from_type(t)]

func _ready():
	var tween: Tween = create_tween()
	tween.connect("finished", fly_right)
	tween.tween_property($Sprites,"scale",Vector2(3,3), 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	$GPUParticles2D.emitting = true
	print("SPAWNED", global_position)

func fly_right():
	var tween: Tween = create_tween()
	tween.tween_property($Sprites,"scale",Vector2(1,1), 0.1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	
	var tween2: Tween = create_tween()
	tween2.connect("finished", fly_right2)
	tween2.tween_property($Sprites,"position",Vector2(1000,0), 0.1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	
func fly_right2():
	$Sprites.position.x = -100
	var tween2: Tween = create_tween()
	tween2.connect("finished", delete_self)
	tween2.tween_property($Sprites,"position",Vector2(1000,0), 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	
func delete_self():
#	queue_free()
	pass

extends Node2D

# Called when the node enters the scene tree for the first time.
var sprites = [preload("res://art/fruits/apple_explode.png"), preload("res://art/fruits/orange_explode.png"),
			   preload("res://art/fruits/lemon_explode.png"), preload("res://art/fruits/pear_explode.png"),
			   preload("res://art/fruits/blueberry_explode.png"), preload("res://art/fruits/grape_explode.png")]
var explosion_shader: ShaderMaterial = preload("res://shaders/explosion_material.tres").duplicate(true)

func setup(t: Global.TileType):
	$Sprites.frame = Global.get_index_from_type(t)
	explosion_shader.set_shader_parameter("sprite", sprites[Global.get_index_from_type(t)])
	$GPUParticles2D.process_material = explosion_shader
	$GPUParticles2D.scale = Vector2(5,5)

func _ready():
	var tween: Tween = create_tween()
	tween.connect("finished", explode)
	tween.tween_property($Sprites,"scale",Vector2(5,5), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func explode():
	var tween: Tween = create_tween()
	tween.connect("finished", explode2)
	tween.tween_property($Sprites,"scale",Vector2(1,1), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func explode2():
	$Sprites.hide()
	$GPUParticles2D.emitting = true
	var tween: Tween = create_tween()
	tween.connect("finished", delete_self)
	tween.tween_property($Sprites,"scale",Vector2(1,1), 2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	

func delete_self():
	queue_free()
	pass

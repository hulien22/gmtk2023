extends Node2D

# POSITION is (column, row)
var posn: Vector2 = Vector2.ZERO
var is_player: bool = false
var type: Global.TileType
var modifier: Global.Modifier

var marked_for_destruction: bool = false
var placing_bomb: bool = false
var endpoints: Array[Vector2] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	set_is_player(false)
	$Node/Button.pressed.connect(self._button_pressed)

func set_type_and_modifier(t: Global.TileType, m: Global.Modifier):
	set_modifier(m)
	set_type(t)

func set_type(t: Global.TileType):
	type = t
	match t:
		Global.TileType.RED:
			$Node/ColorRect.modulate = Color.RED
		Global.TileType.ORANGE:
			$Node/ColorRect.modulate = Color.ORANGE
		Global.TileType.YELLOW:
			$Node/ColorRect.modulate = Color.YELLOW
		Global.TileType.GREEN:
			$Node/ColorRect.modulate = Color.GREEN
		Global.TileType.BLUE:
			$Node/ColorRect.modulate = Color.BLUE
		Global.TileType.PURPLE:
			$Node/ColorRect.modulate = Color.PURPLE
		Global.TileType.EMPTY:
			# explode and delete?
#			visible = false
			pass
	$Node/ColorRect.modulate.a = 1
	
	# don't change player to empty frame on death
	if !(is_player && type == Global.TileType.EMPTY):
		$Node/Sprites.frame = Global.get_index_from_type(t)

func set_modifier(m: Global.Modifier):
	if (is_player):
		return
	modifier = m
	match m:
		Global.Modifier.NONE:
			$Node/Sprites.set_animation("Fruit")
		Global.Modifier.VERTICAL:
			$Node/Sprites.set_animation("VerticalBomb")
		Global.Modifier.HORIZONTAL:
			$Node/Sprites.set_animation("HorizontalBomb")
		Global.Modifier.DESTROYER_OF_EIGHT_TILES:
			$Node/Sprites.set_animation("DestroyerBomb")
		Global.Modifier.BOMB:
			$Node/Sprites.set_animation("FruitBomb")

func copy_from(tile):
	#posn = tile.posn
	set_is_player(tile.is_player)
	set_type(tile.type)
#	print("::", posn, is_player, type)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_is_player(enable:bool):
	is_player = enable
	if (is_player):
		set_emotion("Happy")
	else:
		$Node/PlayerFaces.visible = false

func set_clickable(enable: bool):
	#print(posn, enable)
	$Node/Button.visible = enable
	if (enable):
		$Node/Button/AnimatedSprite2D.play()
	else:
		$Node/Button/AnimatedSprite2D.stop()
	$Node/RichTextLabel.clear()
	$Node/RichTextLabel.add_text(str(posn))

func set_emotion(emotion: String):
	if is_player:
		$Node/PlayerFaces.visible = true
		$Node/PlayerFaces.set_animation(emotion)
		$Node/PlayerFaces.play()
		

func _button_pressed():
	Events.emit_signal("move_player_click", posn)

func move(target, transformation, secs):
	var tween: Tween = create_tween()
	tween.tween_property(self,"position",target, secs).set_trans(transformation).set_ease(Tween.EASE_OUT)


var sprites = [preload("res://art/fruits/apple.png"), preload("res://art/fruits/orange.png"),
			   preload("res://art/fruits/lemon.png"), preload("res://art/fruits/pear.png"),
			   preload("res://art/fruits/blueberry.png"), preload("res://art/fruits/grape.png")]
var explosion_shader: ShaderMaterial = preload("res://shaders/explosion_material.tres")

var explosions = [preload("res://scenes/horizontal_bomb_anim.tscn"),preload("res://scenes/destroyer_bomb_anim.tscn"),preload("res://scenes/color_bomb_anim.tscn")]

func play_destroy_anim(points: int, global_posn: Vector2):
	$Node/RichTextLabel.add_text(str(points))
	#play destruction animation
#	var tween: Tween = create_tween()
#	tween.connect("finished", delete_self)
#	tween.tween_property(self,"position",Vector2(position.x, position.y + 100), 3).set_trans(Tween.TRANS_QUAD)
	# TODO handle bombs specially?
	$Node.visible = false
	if (is_player):
		AudioAutoload.play_die()
		z_index = 1000
		var tween: Tween = create_tween()
		tween.connect("finished", explode_player.bind(type))
		tween.tween_property(self,"scale",Vector2(5,5), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		$Node.visible = true
		set_emotion("Fear")
	elif (modifier == Global.Modifier.NONE || placing_bomb):
		explosion_shader.set_shader_parameter("sprite", sprites[Global.get_index_from_type(type)])
		$GPUParticles2D.process_material = explosion_shader
		$GPUParticles2D.emitting = true

func destroy_bomb_tile(global_posn: Vector2, t: Global.TileType, mod: Global.Modifier):
	if (mod == Global.Modifier.HORIZONTAL):
		var s:Node2D = explosions[0].instantiate()
		s.setup(t)
		s.z_index = 100
		s.visible = false
		get_parent().add_child(s)
		s.global_position = global_posn
		s.visible = true
	elif (mod == Global.Modifier.VERTICAL):
		var s:Node2D = explosions[0].instantiate()
		s.setup(t)
		s.z_index = 100
		s.visible = false
		s.rotation_degrees = 270
		get_parent().add_child(s)
		s.global_position = global_posn
		s.visible = true
	elif (mod == Global.Modifier.DESTROYER_OF_EIGHT_TILES):
		var s:Node2D = explosions[1].instantiate()
		s.setup(t)
		s.z_index = 100
		s.visible = false
		get_parent().add_child(s)
		s.global_position = global_posn
		s.visible = true
	elif (mod == Global.Modifier.BOMB):
		var s:Node2D = explosions[2].instantiate()
		s.setup(t)
		s.z_index = 100
		s.visible = false
		get_parent().add_child(s)
		s.global_position = global_posn
		s.visible = true

func destroy():
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = $GPUParticles2D.lifetime
	timer.one_shot = true
	timer.connect("timeout", delete_self)
	timer.start()
	# TODO special effect if this is the player object??

func delete_self():
#	print("delete_self")
	queue_free()

var simple_fruit: PackedScene = preload("res://scenes/simple_fruit.tscn")
var bomb_spawn: PackedScene = preload("res://scenes/bomb_spawn_anim.tscn")
func make_bomb():
	if (is_player):
		return
	for p in endpoints:
		var f = simple_fruit.instantiate()
		f.setup(type, global_position)
		f.visible = false
		add_child(f)
		f.global_position = p
		f.visible = true
		f.animate()
	var b = bomb_spawn.instantiate()
	b.setup(type, modifier)
	b.visible = false
	add_child(b)
	b.global_position = global_position
	b.visible = true
	
	$Node.visible = true

func explode_player(t: Global.TileType):
	Engine.time_scale = 1
	explosion_shader.set_shader_parameter("sprite", sprites[Global.get_index_from_type(t)])
	$GPUParticles2D.process_material = explosion_shader
	$GPUParticles2D.amount = 10000
	$GPUParticles2D.emitting = true
	$Node.visible = false
	Global.GAME_OVER = true
